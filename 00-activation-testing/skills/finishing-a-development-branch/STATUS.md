# finishing-a-development-branch

Scenarios, requirements and expectations for this skill are in this
directory: `REQUIREMENTS.md`, `scenarios/`, `expectations.json`.

## Baseline

The unchanged plugins, Sonnet, n=3, run `01a0ce0e-f3b5-72ec-ada3-d275bd1cfbae`.
Loads out of 3, and the mean score.

| scenario | expect | sonnet/control |
|---|---|---|
| options-menu | load | 3/3 ok (97) |
| failing-tests | load | 0/3 FAIL (40) |
| detached-head | load | 1/3 FAIL (70) |
| merge-worktree | load | 3/3 ok (97) |
| discard-branch | load | 0/3 FAIL (30) |
| push-rejected | load | 2/3 ok (93) |
| no-integration | skip | 0/3 ok (87) |
| explain-code | skip | 0/3 ok (100) |

Result: FAIL

When the skill loads, the agent scores 90-100. When it does not, 30-60.
Every run where it was missing and should not have been lost points
the skill exists to protect: merging with a failing test, deleting a
branch without confirmation, offering a merge on a detached HEAD.

The router did not load in any of these runs, so the skill's own
description is what decides. The three failing requests each miss a
different part of it:

- "Merge it into main" (failing-tests, 0/3): the description says to use
  the skill "only after implementation is verified", and the tests have
  not run yet.
- "Get rid of it" (discard-branch, 0/3): the description never mentions
  discarding a branch.
- "What should I do with it?" (detached-head, 1/3): no example in the
  description is a question about finished work.

`variants.json` tests one hypothesis per variant against these.

## An earlier baseline that did not count

Run `01a0cdee-738e-7614-9e4e-1e1bfbe08c11` used the first version of the
scenarios. The grader sees only the files left behind, not the
conversation, so every item about what the agent said or which tests it
ran scored 0 with "no transcript available". The scenarios now ask for
the reply in REPLY.md, and npm test logs each run to .git/test-runs.log.
