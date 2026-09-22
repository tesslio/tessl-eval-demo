# Eval demo — measuring whether skills help

A worked example of using Tessl evals to answer two questions about a set of
agent skills:

1. **Do the skills help?** Run the same tickets with and without them.
2. **Which model should run them?** Run the same tickets on Opus, Sonnet and
   Haiku, all with the skills installed.

Everything here is self-contained: the skills being measured, the codebase
they are measured against, and the tickets used to measure them.

## Start here

You need the Tessl CLI and an account. Eval runs consume credits.

```bash
# 1. install and sign in
curl -fsSL https://install.tessl.io | sh
tessl login

# 2. give this directory its own project, in a workspace you can write to
tessl project create --workspace <your-workspace>

# 3. run both eval sweeps
./run.sh
```

That works on a fresh clone. The four plugins in `arms.json` are published
and public, so nothing needs building or publishing first — `run.sh` pulls
them from the registry.

Cheaper first run, one model and one repetition instead of three:

```bash
MODEL=claude-sonnet-4-6 RUNS=1 ./run.sh
```

`run.sh` prints a run id for each sweep. Watch them at
`https://tessl.io/workspaces/<your-workspace>/eval-runs/<id>`, or from the
terminal with `tessl eval view <id>`.

## What's in here

```
plugins/            the skills under test — source, not a dependency
  sdlc-planning/          writing-plans
  sdlc-implementation/    executing-plans, test-driven-development,
                          systematic-debugging
  sdlc-assurance/         verification-before-completion,
                          requesting-code-review, receiving-code-review,
                          finishing-a-development-branch
  sdlc-router/            delivery-flow — dispatches to the other eight
scenarios/
  repo/                   the toy codebase every scenario works against
  linkbox-expiry-sweep/       ticket + rubric
  linkbox-namespace-isolation/
  linkbox-safe-handoff/
arms.json           skills vs no skills
arms-models.json    opus vs sonnet vs haiku, all with skills
publish.sh          push plugins/ to a workspace you control
run.sh              both eval runs
```

### Two arms files, one variable each

An arm is one configuration to compare. `arms.json` holds the skills
constant and varies whether they are installed; `arms-models.json` holds the
skills installed and varies the model:

```json
[
  { "label": "no-components", "includeContext": false },
  { "label": "components", "includeContext": true, "fixtures": { ... } }
]
```

Arms can carry a per-arm `model`, which is what makes the model comparison a
single run rather than three. Keeping one variable per run means each run
page answers one question.

## Point it at your own codebase

Replace `scenarios/repo/` with a checkout of your own service and rewrite the
tickets. The wiring in each scenario's `scenario.json` does not change:

```json
{ "fixtures": { "codebase": { "type": "directory", "path": "../repo", "installPath": "." } } }
```

That installs the codebase at the sandbox root before the agent starts, so it
reads real files rather than a description of them. Several scenarios can
share one `repo/`, which is how a real team would use this — one codebase,
many tickets.

A scenario is three files:

| file | what it is |
|---|---|
| `task.md` | the ticket, as an engineer would receive it |
| `criteria.json` | a weighted checklist the scorer grades against |
| `scenario.json` | which codebase to install |

## The improvement loop

The plugins are **source here, not a dependency**. That makes the full cycle
available:

```
edit a skill in plugins/  ->  bump its version  ->  ./publish.sh
                                     |
                          point arms.json at the new version
                                     |
                              ./run.sh  ->  did the number move?
```

Publish into a workspace you control:

```bash
WORKSPACE=my-workspace ./publish.sh
sed -i '' 's|tessleng/sdlc-|my-workspace/sdlc-|g' arms.json arms-models.json
./run.sh
```

An eval that scores badly tells you something is wrong. Owning the skill
source is what lets you then fix it and measure the fix.

## The toy codebase

`scenarios/repo/` is `linkbox`, a small multi-tenant URL shortener. It ships
with two real bugs, both confirmed by direct repro before the scenarios were
written, and neither caught by its existing tests:

- **`src/store.js`** — `codesByUrl` is one module-level map shared across
  every namespace, so two tenants shortening the same URL get the same code.
  The repo's own `README.md` claims the opposite.
- **`src/expiry.js`** — `sweepExpired` splices out of the queue while
  iterating it with `forEach`, so each removal shifts the rest down and the
  next entry is skipped. A sweep with two or more due links silently leaves
  some behind. The code reads as correct.

Planting a real, findable bug is what gives a ticket something to be right or
wrong about.

## Results

Means out of 100 over `n=3`, against `tessleng/sdlc-*@0.1.1`.

**Do the skills help?** (Sonnet)

| scenario | without | with | skills fired |
|---|---|---|---|
| `linkbox-expiry-sweep` | 73.3 | **90.0** | 6-7 vs 0 |
| `linkbox-namespace-isolation` | 85.0 | **100** | 6 every run vs 0 |
| `linkbox-safe-handoff` | 36.7 | 40.0 | erratic: 6, 1, 0 |

**Which model?** (all arms with skills)

| scenario | Sonnet | Opus | Haiku |
|---|---|---|---|
| `linkbox-expiry-sweep` | 86.7 | **96.7** | 60.0 |
| `linkbox-namespace-isolation` | 96.7 | 96.7 | 83.3 |
| `linkbox-safe-handoff` | **70.0** | 56.7 | 40.0 |

| run | id |
|---|---|
| skills vs none, Sonnet, n=3 | `01a0c983-386f-70db-a6d5-c3df55ae978d` |
| model comparison, n=3 | `01a0c983-4536-73da-b3a5-2c11db7d20b8` |

One cell of the skills-vs-none sweep did not score, so
`linkbox-namespace-isolation` without skills is a mean of two runs rather
than three.

## Writing a scenario that actually separates the arms

Most of the work is here, and most first attempts do not discriminate.

**Grade process, not just correctness.** A competent model gets correctness
right unaided, so a rubric made only of "did it fix the bug" ties at the
ceiling in both arms. The separation comes from items like
`continuous_composed_flow` and `review_and_fix_loop` — whether a plan, a
review and a verification step actually happened. `linkbox-expiry-sweep` is
the strongest scenario here because its bug is subtle enough that correctness
is contested too, so both halves of the rubric do work.

**Do not instruct the behaviour you are grading.** If the ticket says "verify
the claim before building on it" and the rubric awards points for verifying
on the agent's own initiative, both arms score full marks and the scenario
measures nothing.

**Read activation before score.** Every run records which skills the agent
actually invoked. Two arms can tie while only one of them ever loaded a
skill — identical outcome, completely different process. A gap with no
activation behind it is noise, not evidence.

**Use activation to diagnose a scenario that will not separate.**
`linkbox-safe-handoff` tests a gate: the agent should present integration
options rather than merging on its own. It sat near the floor on every model,
and the activation record showed why — the skill it tests was never loading.
The router loads `finishing-a-development-branch` only when the user
explicitly asks to integrate, and that skill's description gave no examples
of what such a request sounds like. Adding concrete trigger phrases to the
description, and asking for integration in plainer terms in the ticket,
moved Sonnet from 13.3 to 70.0 with the skill now loading on every run. On
Opus and Haiku it still never loads, which is visible in the activation
record and remains an open problem.

**Repeat before believing a gap.** Everything above is `n=3`. At `n=1` a
reversal can appear and disappear between runs; treat overlapping ranges as
no result.

## Notes

- `forceContextActivation: true` is pinned in both arms files. It is the
  default for any arm with `includeContext: true`, set explicitly so it
  cannot drift.
- Both arms files carry the same four plugins. When bumping a version,
  update it in both.
- The skills in `plugins/` are derived from Superpowers (MIT). See `NOTICE`.
