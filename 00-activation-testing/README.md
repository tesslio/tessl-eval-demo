# Step 00: activation

**The question:** does the agent use each skill when it should, and leave it alone when it should not?

## The problem

An agent decides for itself whether to read a skill, from the skill's name and a short description. If the description does not match how people ask, the skill is never read, and the agent does the job without it. You usually cannot see this: the agent finishes the task, and nothing says a skill was skipped.

The opposite fails too. A description wide enough loads the skill on requests it has nothing to do with, and its instructions then push the agent the wrong way.

Every later step in this repository improves what a skill says. None of that matters for a skill the agent never loads, so activation comes first.

## The approach

Loading well is a balance. At one end, a request that names the skill ("use the X skill") loads almost any skill. At the other, a description broad enough loads on every turn. The work is to find where between those ends a skill stops loading, find out why, and move that point without breaking the other end.

Work on one skill at a time. For each skill:

1. **Write its ladder.** Read the skill, the skills next to it, and any router that hands work to it. Write down the situations where it should and should not load, in order:
   - **named:** the request names the skill. It must load; if it does not, the test is broken.
   - **obvious:** the skill's job in plain words.
   - **normal:** typical requests, each in a different form: a command, a question, a terse note, a request inside other context, a request under time pressure.
   - **borderline, should load:** easy to miss: the need is implied, the request is small, or it arises inside other work.
   - **borderline, should not load:** shares the skill's words or topic, but is another skill's job or needs no skill.
   - **should not:** unrelated, or clearly another skill's job.

   For each borderline case, write which side it falls on and the sentence in the skill that decides it. Hold two more requests back, unseen, for the final check. Add one request for each neighboring skill, to check that a change does not take its loads.
2. **Turn each situation into a small scenario.** A short request, and a setup script that builds the state it needs: the branch, the failing test, the review comment.
3. **Check the ladder against the current skill.** Run each scenario once. Replace the skill's body with "you have loaded this skill; stop now", so a run ends as soon as the skill loads. The agent decides from the name and description, before it reads the body, so the decision is unchanged and the run is short.
4. **Give each failure a cause.** The common ones:
   - the description does not name that kind of request;
   - the description tells the agent not to load it;
   - another skill's description claims the request;
   - a router in front of it does not send the work to it;
   - the request is so small that the agent uses no skill at all. No wording fixes this; record it and move on.
5. **Write a rewrite for each cause, and nothing else.** Each rewrite applies one tested idea: plain rules (third person, no superlatives, no "do not use me"); one rewrite from the actual failures, with "use when" and "not for" clauses; firmer wording against under-loading; or, where two skills claim the same work, a change to the router or a merge. Review each rewrite for quality before it runs.
6. **Run the rewrites against the current text on the ladder,** once per scenario. A rewrite is ahead when it passes more scenarios and fails none that the current text passes.
7. **Confirm the best rewrite,** 3 times per scenario, on the ladder and the held-back requests, with the neighbor checks, and on a few full tasks scored with the real skill bodies. It ships only if:
   - it loads more often where it should, and no scenario gets worse;
   - it loads no more often where it should not;
   - it does not lose on the held-back requests;
   - no neighbor loses loads;
   - no scored task drops more than 15 points.

## What it costs

Each eval cell (one scenario, one version, one run) is billed the same, whether it runs for a minute or an hour. So the cost is the number of cells: versions times scenarios times runs. The ladder keeps that low: about 20 scenarios per skill, one run each until the final check, and at most three rewrites at a time.

- A skill whose ladder shows nothing to fix: about 20 cells.
- A skill that needs a fix: about 180 to 220 cells.

Credits are described at https://tessl.io/pricing/.

## Run it yourself

You need the Tessl CLI and an account (see the [top-level README](../README.md)). The commands below check one skill.

**1. Lay out a working directory.** Keep the scenario sets apart, because `tessl eval run` runs every scenario in the directory it is given:

```
my-skill/
  ladder/<codebase>/          the codebase every scenario starts from
  ladder/named-1/             task.md, setup.sh, scenario.json, criteria.json
  ladder/obvious-1/ ...
  heldout/  neighbors/  tasks/
  expectations.json           rung and expected result per scenario
```

See [`delivery-flow/`](delivery-flow/) for a complete example of every file.

**2. Make a copy of your plugins with the skill's body replaced by a stop line.** Only the body after the frontmatter changes; the name and description stay.

```bash
cp -R plugins stubbed
python3 - stubbed/my-plugin/skills/my-skill/SKILL.md <<'PY'
import re, sys
path = sys.argv[1]
text = open(path).read()
frontmatter = re.match(r"^---\n.*?\n---\n", text, re.S).group(0)
open(path, "w").write(frontmatter + "\nYou have loaded this skill, and that completes the task. "
                      "Do not run any commands, read any files, or change anything. Reply with DONE and end your turn now.\n")
PY
```

**3. Write the arms,** one per version, each pointing at a local copy of every plugin:

```json
[
  { "label": "current", "includeContext": true, "forceContextActivation": true,
    "fixtures": { "my-plugin": { "localPath": "./stubbed/my-plugin" } } },
  { "label": "rewrite-1", "includeContext": true, "forceContextActivation": true,
    "fixtures": { "my-plugin": { "localPath": "./rewrite-1/my-plugin" } } }
]
```

**4. Lint, then run the ladder once per scenario, unscored:**

```bash
tessl eval lint ladder
tessl eval run ladder --arms-json arms.json --agent claude --model claude-sonnet-4-6 \
  --scorer-agent claude --scorer-model claude-sonnet-4-6 -n 1 --skip-scoring -f --yes --label ladder-check
```

Always pass a directory. `tessl eval` with no subcommand runs every scenario under the current directory, and a submitted run cannot be cancelled.

**5. Read which skills loaded, per scenario and version:**

```bash
tessl eval view <run-id> --json | jq -r '.data.attributes.scenarios[]
  | (.path | split("/") | last) as $s | .solutions[] | .variant as $v | .runs[]
  | [$s, $v, ((.activation.activatedSkills // []) | map(sub("^tessl__";"")) | join(","))] | @tsv'
```

Compare each line with the scenario's expected result in `expectations.json`.

**6. Confirm** with `-n 3` on `ladder/` and `heldout/`. Run `neighbors/` with the neighbors' bodies stubbed and your skill's body real. Run `tasks/` without `--skip-scoring`, with no bodies stubbed, so the full tasks are scored.

## In this directory

- **[`before/`](before/)**: the skills as this step found them.
- **[`after/`](after/)**: the skills with every confirmed change applied.
- **[`delivery-flow/`](delivery-flow/)**: a worked example: one skill's ladder, its scenarios, the rewrites tried, and how the change in `after/` was reached and proven.
