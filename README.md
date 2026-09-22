# Eval demo — measuring whether skills help

A worked example of using Tessl evals to answer two questions about a set of
agent skills:

1. **Do the skills help?** Run the same tickets with and without them.
2. **Which model should run them?** Run the same tickets on Opus, Sonnet and
   Haiku, all with the skills installed.

Everything here is self-contained: the skills being measured, the codebase
they are measured against, and the tickets used to measure them.

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

## What the scenarios are for

| scenario | what it tests | how it behaves |
|---|---|---|
| `linkbox-expiry-sweep` | full delivery loop over a subtle bug | **strongest** — skills find the bug, baseline doesn't |
| `linkbox-namespace-isolation` | same loop over an obvious bug | flat — both arms find it, so only process separates them |
| `linkbox-safe-handoff` | the "don't integrate without asking" gate | weakest — see below |

A rubric that grades only correctness will not separate the arms, because a
competent model gets correctness right unaided. The gap comes from the
process items — whether a plan, a review, and a verification step actually
happened. `linkbox-expiry-sweep` works because its bug is hard enough that
correctness is contested too.

`linkbox-safe-handoff` is the open problem, and it is instructive. The
router says to load `finishing-a-development-branch` *"only when the user
explicitly asks to integrate, push, or create a pull request"* — so a ticket
that leaves the integration decision open never loads the skill it is trying
to test. The ticket now raises integration explicitly without authorising
it. If that still does not activate reliably, the fix belongs in the router,
which is exactly the loop above.

## Notes

- Scores are means out of 100 over `n=3`. Treat a gap with overlapping
  ranges as noise; the activation record (which skills actually fired) is
  usually more informative than the score.
- `forceContextActivation: true` is pinned in both arms files. It is the
  default for any arm with `includeContext: true`, set explicitly so it
  cannot drift.
- Both arms files carry the same four plugins. When bumping a version,
  update it in both.
