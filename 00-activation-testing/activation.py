#!/usr/bin/env python3
"""Tabulate which skills loaded, and judge them against expectations.json.

    ./activation.py <run-id>... [--skill <skill>]

Pass every run that belongs to one comparison, for example the three triage
runs, so each table covers every model. A cell reads loads/runs, then a
mark: ok when it meets the rule, FAIL when it breaks it, and nothing when
the scenario does not judge that skill.
"""
import argparse
import json
import subprocess
from collections import defaultdict
from pathlib import Path

STEP = Path(__file__).resolve().parent
SKILL_PREFIX = "tessl__"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("run_ids", nargs="+")
    parser.add_argument("--skill")
    args = parser.parse_args()

    expectations = json.loads((STEP / "expectations.json").read_text())["scenarios"]
    views = [load_run(run_id) for run_id in args.run_ids]
    counts, columns, pending = count_loads(views)
    skills = [args.skill] if args.skill else sorted(judged_skills(expectations))
    for skill in skills:
        print(render_skill(skill, counts, columns, expectations))
    if pending:
        print(f"Not finished yet, left out: {pending} run(s).")


# === LOAD ===

def load_run(run_id):
    out = subprocess.run(["tessl", "eval", "view", run_id, "--json"],
                         check=True, capture_output=True, text=True).stdout
    return json.loads(out)["data"]["attributes"]


# === COMPUTE ===

def count_loads(views):
    """-> counts[(scenario, column)] = {"runs": n, skill: loads}, columns, pending."""
    counts = defaultdict(lambda: defaultdict(int))
    columns, pending = [], 0
    for view in views:
        model_by_arm = {arm["label"]: arm.get("model") for arm in view.get("arms") or []}
        for scenario in view["scenarios"]:
            name = scenario["path"].rstrip("/").split("/")[-1]
            for solution in scenario["solutions"]:
                model = model_by_arm.get(solution["variant"]) or view["model"]
                column = f"{short_model(model)}/{solution['variant']}"
                if column not in columns:
                    columns.append(column)
                for run in solution["runs"]:
                    if run["status"] != "completed":
                        pending += 1
                        continue
                    cell = counts[(name, column)]
                    cell["runs"] += 1
                    for skill in (run.get("activation") or {}).get("activatedSkills") or []:
                        cell[skill.removeprefix(SKILL_PREFIX)] += 1
    return counts, columns, pending


def judged_skills(expectations):
    return {s for e in expectations.values() for s in e["load"] + e["skip"]}


def verdict(expected, loads, runs):
    if runs == 0 or expected is None:
        return ""
    if expected == "load":
        return "ok" if loads / runs >= 2 / 3 else "FAIL"
    return "ok" if loads / runs <= 1 / 3 else "FAIL"


def expected_for(skill, scenario):
    if skill in scenario["load"]:
        return "load"
    if skill in scenario["skip"]:
        return "skip"
    return None


def short_model(model):
    return model.removeprefix("claude-").split("-")[0]


# === RENDER ===

def render_skill(skill, counts, columns, expectations):
    lines = [f"## {skill}", "",
             "| scenario | expect | " + " | ".join(columns) + " |",
             "|---|---|" + "---|" * len(columns)]
    failed = False
    for name, scenario in expectations.items():
        expected = expected_for(skill, scenario)
        cells = []
        for column in columns:
            cell = counts.get((name, column))
            if not cell:
                cells.append("")
                continue
            mark = verdict(expected, cell[skill], cell["runs"])
            failed |= mark == "FAIL"
            cells.append(f"{cell[skill]}/{cell['runs']} {mark}".strip())
        lines.append(f"| {name} | {expected or '-'} | " + " | ".join(cells) + " |")
    lines += ["", f"Result: {'FAIL' if failed else 'pass'}", ""]
    return "\n".join(lines)


if __name__ == "__main__":
    main()
