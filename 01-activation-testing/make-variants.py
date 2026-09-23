#!/usr/bin/env python3
"""Build one plugin set per variant in variants.json, and the arms that run them.

Each variant changes as little as possible: only the plugins it edits are
copied into variants/<id>/, and its arm points every other plugin at the
unchanged copy in before/plugins. The control arm points everything at
before/plugins. Every arm uploads local plugins, never published ones, so
all arms are packed the same way and differ only in the edited text.

Run it again after editing variants.json. It rewrites variants/ and arms.json.
"""
import json
import re
import shutil
from pathlib import Path

STEP = Path(__file__).resolve().parent
BEFORE = STEP / "before" / "plugins"
VARIANTS = STEP / "variants"
PLUGINS = {
    "planning": "sdlc-planning",
    "implementation": "sdlc-implementation",
    "assurance": "sdlc-assurance",
    "router": "sdlc-router",
}
ROUTER_SKILL = "sdlc-router/skills/delivery-flow/SKILL.md"
ROUTER_RULE = re.compile(r"^6\. Load `finishing-a-development-branch`.*$", re.M)


def main():
    spec = json.loads((STEP / "variants.json").read_text())
    shutil.rmtree(VARIANTS, ignore_errors=True)
    arms = [build_variant(spec["skill"], variant) for variant in spec["variants"]]
    (STEP / "arms.json").write_text(json.dumps(arms, indent=2) + "\n")
    print(f"{len(arms)} arms written to arms.json")


def build_variant(skill, variant):
    edited = set()
    root = VARIANTS / variant["id"]

    def copy_of(plugin):
        if plugin not in edited:
            shutil.copytree(BEFORE / plugin, root / plugin)
            edited.add(plugin)
        return root / plugin

    if "description" in variant:
        skill_md = copy_of("sdlc-assurance") / "skills" / skill / "SKILL.md"
        replace_description(skill_md, variant["description"])

    if "routerRule" in variant:
        router_md = copy_of("sdlc-router").parent / ROUTER_SKILL
        text, count = ROUTER_RULE.subn(variant["routerRule"], router_md.read_text())
        assert count == 1, f"{variant['id']}: router rule not found"
        router_md.write_text(text)

    if "rename" in variant:
        # The name appears in the skill itself, the router and executing-plans,
        # so a rename that missed one of them would test a broken dispatch.
        for plugin in ("sdlc-assurance", "sdlc-router", "sdlc-implementation"):
            rename_skill(copy_of(plugin), skill, variant["rename"])

    return arm(variant["id"], root, edited)


def replace_description(skill_md, description):
    # JSON string syntax is valid YAML double-quoted syntax, so a colon or
    # quote in the description cannot break the frontmatter.
    text, count = re.subn(
        r"^description: .*$",
        lambda _: "description: " + json.dumps(description),
        skill_md.read_text(),
        count=1,
        flags=re.M,
    )
    assert count == 1, f"{skill_md}: no description line"
    skill_md.write_text(text)


def rename_skill(plugin_dir, old_name, new_name):
    old_dir = plugin_dir / "skills" / old_name
    if old_dir.exists():
        old_dir.rename(plugin_dir / "skills" / new_name)
    for md in plugin_dir.rglob("*.md"):
        md.write_text(md.read_text().replace(old_name, new_name))


def arm(label, variant_root, edited):
    fixtures = {}
    for fixture_name, plugin in PLUGINS.items():
        source = variant_root / plugin if plugin in edited else BEFORE / plugin
        fixtures[fixture_name] = {"localPath": "./" + str(source.relative_to(STEP))}
    return {
        "label": label,
        "includeContext": True,
        "forceContextActivation": True,
        "fixtures": fixtures,
    }


if __name__ == "__main__":
    main()
