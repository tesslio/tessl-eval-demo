# Step 00: activation testing

A skill that does not load does nothing, so this step comes first. It
checks every skill in the bundle against one rule, in
`expectations.json`:

> On every model, a skill loads in at least 2 of 3 runs of each scenario
> that needs it, and in at most 1 of 3 runs of each scenario that does not.

The step is done when every directory under `skills/` is conclusive:
either the skill passes, or its variants have been screened and the best
one confirmed, with any remaining gap written down. Step 01 does not
start before that.

## Layout

| path | what it is |
|---|---|
| `before/plugins/` | the four plugins as they were when this step started |
| `before/scenarios/` | six tickets against the `linkbox` codebase |
| `expectations.json` | per scenario, which skills should load and which should not |
| `skills/<skill>/STATUS.md` | that skill's result and what was decided |
| `skills/<skill>/variants.json` | name, description and text edits to try, one hypothesis each |
| `make-variants.py` | builds a skill's variant plugins and arms from its `variants.json` |
| `run.sh` | triage, screen and confirm |
| `after/plugins/` | the plugins with every confirmed change applied |

## How to run it

1. **Triage.** `./run.sh triage` runs the unchanged plugins on all six
   scenarios on Haiku, Sonnet and Opus. Record each skill's loads per
   scenario and model in its `STATUS.md`, and mark it pass or fail.
2. **Screen each failing skill.** Write `skills/<skill>/variants.json`,
   one hypothesis per variant, then
   `./make-variants.py <skill>` and
   `./run.sh screen <skill> <models that failed>`. Screening runs n=2 on
   only the scenarios that judge that skill.
3. **Confirm.** `./run.sh confirm <skill> <best arms>` reruns the best
   variants against the control on all three models at n=3. A variant
   ships only if it passes the rule without breaking a scenario it
   passed before.
4. **Assemble.** Apply every confirmed change to a copy of
   `before/plugins` in `after/plugins`, and run triage once more against
   it. Variants were each tested alone, so this last run is what shows
   they still work together.

## What a run reports

Every eval cell records which skills the agent loaded. Read that before
the score: a variant can raise activation without changing the score, and
in this step activation is the result being measured.

`forceContextActivation` is on in every arm, as in the rest of this repo.
It adds one fixed line to the prompt, saying that skills are available and
must be used if needed. It names no skill, so which skill loads is still
the agent's choice, and that choice is what this step measures.
