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

Only use `./publish.sh` if you want to **change** the skills — see
[The loop this exists to demonstrate](#the-loop-this-exists-to-demonstrate).

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
publish.sh          push plugins/ to the tessleng workspace
run.sh              both eval runs
```

## The loop this exists to demonstrate

The plugins are **source here, not a dependency**. That makes the full cycle
available:

```
edit a skill in plugins/  ->  bump its version  ->  ./publish.sh
                                     |
                          point arms.json at the new version
                                     |
                              ./run.sh  ->  did the number move?
```

An eval that scores badly tells you something is wrong. Owning the skill
source is what lets you then fix it and prove the fix.

To run that loop you publish into a workspace you control:

```bash
WORKSPACE=my-workspace ./publish.sh
sed -i '' 's|tessleng/sdlc-|my-workspace/sdlc-|g' arms.json arms-models.json
./run.sh
```

There is a worked example of one full lap further down, under
[linkbox-safe-handoff](#linkbox-safe-handoff-a-worked-example-of-the-loop):
a scenario stuck at the floor, traced to a specific line in a skill, fixed,
republished, and re-measured.

## The toy codebase

`scenarios/repo/` is `linkbox`, a small multi-tenant URL shortener. Swap it
for a checkout of your own service and rewrite the tickets — the wiring in
each scenario's `scenario.json` does not change:

```json
{ "fixtures": { "codebase": { "type": "directory", "path": "../repo", "installPath": "." } } }
```

That installs the codebase at the sandbox root before the agent starts, so
it reads real files rather than a description of them.

It ships with two real bugs, both confirmed by direct repro before the
scenarios were written, and neither caught by the existing tests:

- **`src/store.js`** — `codesByUrl` is one module-level map shared across
  every namespace, so two tenants shortening the same URL get the same code.
  The repo's own `README.md` claims the opposite.
- **`src/expiry.js`** — `sweepExpired` splices out of the queue while
  iterating it with `forEach`, so each removal shifts the rest down and the
  next entry is skipped. A sweep with two or more due links silently leaves
  some behind. The code reads as correct.

## Running it

```
./publish.sh     # once, to get the plugins into the registry
./run.sh         # both runs, n=3
```

`MODEL` and `RUNS` override the defaults:

```
MODEL=claude-opus-4-6 RUNS=1 ./run.sh
```

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

Read the activation column before the score. Two runs can tie while only one
of them ever loaded a skill, and a gap with no activation behind it is noise.

## What the scenarios are for

| scenario | what it tests | how it behaves |
|---|---|---|
| `linkbox-expiry-sweep` | full delivery loop over a subtle bug | **strongest** — skills find the bug, baseline doesn't |
| `linkbox-namespace-isolation` | same loop over an obvious bug | strong on activation, 6 skills every run |
| `linkbox-safe-handoff` | the "don't integrate without asking" gate | improving, still erratic — see below |

A rubric that grades only correctness will not separate the arms, because a
competent model gets correctness right unaided. The gap comes from the
process items — whether a plan, a review, and a verification step actually
happened. `linkbox-expiry-sweep` works because its bug is hard enough that
correctness is contested too.

### `linkbox-safe-handoff`: a worked example of the loop

This scenario started at the floor — 13-30 across all three models, with the
skill it tests never loading once in six runs.

The cause was a contradiction. The router loads
`finishing-a-development-branch` *"only when the user explicitly asks to
integrate, push, or create a pull request"*, and that skill's description
gave no examples of what such a request sounds like. A ticket that raised
integration without using the router's exact vocabulary never reached it.

Two changes: the skill's description now names concrete triggers ("finish
this branch", "merge my work", "open a PR") inside its authorization clause,
and the ticket asks for integration options in plainer terms.

| model | score before | now | `finishing-a-development-branch` loads? |
|---|---|---|---|
| Sonnet | 13.3 | **70.0** | yes, all 3 runs |
| Opus | 16.7 | 56.7 | never |
| Haiku | 30.0 | 40.0 | never |

The activation column separates the two changes. On Sonnet the skill now
loads every run and the score moves most. On Opus and Haiku it still never
loads, so their smaller gains come from the ticket wording alone.

**The remaining defect is now well isolated:** Opus will not load the handoff
skill even when the user asks to integrate in plain language. That is a skill
or router problem, not a scenario problem, and it is fixable in `plugins/`.

## Notes

- Scores are means out of 100 over `n=3`. Treat a gap with overlapping
  ranges as noise; the activation record (which skills actually fired) is
  usually more informative than the score.
- `forceContextActivation: true` is pinned in both arms files. It is the
  default for any arm with `includeContext: true`, set explicitly so it
  cannot drift.
- Both arms files carry the same four plugins. When bumping a version,
  update it in both.

## Run ids

| run | id |
|---|---|
| skills vs none, Sonnet, n=3 | `01a0c983-386f-70db-a6d5-c3df55ae978d` |
| model comparison, n=3 | `01a0c983-4536-73da-b3a5-2c11db7d20b8` |

View either at `https://tessl.io/workspaces/tessleng/eval-runs/<id>`.

The skills-vs-none run reports `failed`: one of its eighteen cells never
scored, so `linkbox-namespace-isolation` without skills is a mean of two runs
rather than three. The other seventeen are complete.
