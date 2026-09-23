#!/usr/bin/env python3
"""Build the variant plugins and the arms for one experiment.

    ./make-variants.py <dir>

<dir> is skills/<skill> for one skill, or a bundle-level experiment such as
entry-point. Reads <dir>/variants.json and writes <dir>/variants/ and
<dir>/arms.json. A variant may change the skill's description, change any
skills' descriptions by name, rename the skill, or make exact text edits to
any plugin file. The skill is the directory name, and only matters for
description and rename.

Each variant copies only the plugins it edits. Its arm points every other
plugin at the unchanged copy in before/plugins, so an arm differs from the
control only in the edited text. Every arm uploads local plugins, never
published ones, so all arms are packed the same way.

Run it again after editing variants.json. It rewrites the outputs.
"""
import json
import re
import shutil
import sys
from pathlib import Path

STEP = Path(__file__).resolve().parent
BEFORE = STEP / "before" / "plugins"
FIXTURES = {
    "planning": "sdlc-planning",
    "implementation": "sdlc-implementation",
    "assurance": "sdlc-assurance",
    "router": "sdlc-router",
}


def main(experiment):
    skill_dir = (STEP / experiment).resolve()
    skill = skill_dir.name
    spec = json.loads((skill_dir / "variants.json").read_text())
    shutil.rmtree(skill_dir / "variants", ignore_errors=True)
    arms = [build_variant(skill, skill_dir / "variants", v) for v in spec["variants"]]
    (skill_dir / "arms.json").write_text(json.dumps(arms, indent=2) + "\n")
    print(f"{len(arms)} arms written to {skill_dir.relative_to(STEP)}/arms.json")


def build_variant(skill, variants_root, variant):
    root = variants_root / variant["id"]
    edited = set()

    def copy_of(plugin):
        if plugin not in edited:
            shutil.copytree(BEFORE / plugin, root / plugin)
            edited.add(plugin)
        return root / plugin

    descriptions = dict(variant.get("descriptions", {}))
    if "description" in variant:
        descriptions[skill] = variant["description"]
    for name, description in descriptions.items():
        plugin = plugin_holding(name)
        replace_description(copy_of(plugin) / "skills" / name / "SKILL.md", description)

    for edit in variant.get("edits", []):
        plugin, _, rest = edit["file"].partition("/")
        target = copy_of(plugin) / rest
        text = target.read_text()
        assert text.count(edit["find"]) == 1, f"{variant['id']}: edit text not found once in {edit['file']}"
        target.write_text(text.replace(edit["find"], edit["replace"]))

    if "rename" in variant:
        # A rename that missed any file naming the skill would test a broken
        # dispatch, not a better name, so every plugin that mentions it is copied.
        for plugin in plugins_mentioning(skill):
            rename_skill(copy_of(plugin), skill, variant["rename"])

    return arm(variant["id"], root, edited)


def plugin_holding(skill):
    matches = [p.name for p in BEFORE.iterdir() if (p / "skills" / skill).is_dir()]
    assert len(matches) == 1, f"{skill}: expected in one plugin, found {matches}"
    return matches[0]


def plugins_mentioning(skill):
    return [p.name for p in BEFORE.iterdir()
            if any(skill in md.read_text() for md in p.rglob("*.md"))]


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
    for fixture_name, plugin in FIXTURES.items():
        source = variant_root / plugin if plugin in edited else BEFORE / plugin
        fixtures[fixture_name] = {"localPath": "./" + str(source.relative_to(STEP))}
    return {
        "label": label,
        "includeContext": True,
        "forceContextActivation": True,
        "fixtures": fixtures,
    }


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: make-variants.py <dir>")
    main(sys.argv[1])
