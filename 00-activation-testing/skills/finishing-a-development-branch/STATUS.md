# finishing-a-development-branch

Status: **conclusive, passes.** v06-intent-and-safety ships in `after/plugins`.

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

## Screen

Six variants and the control, n=2, run `01a0ce1b-56f7-7438-8a97-78fc8ebd4479`.
Only v05-safety-framing and v06-intent-and-safety loaded on every load
scenario. The others each fixed some of the three failing requests: v01
and v03 fixed detached-head, v02 fixed failing-tests, v04 fixed discard.
The two that framed the skill as a guard on risky git operations fixed
all three.

## Confirm

The control, v05 and v06, n=3, run `01a0ce27-90d5-7755-ae62-360f435090b6`.

| scenario | expect | v00-control | v05-safety-framing | v06-intent-and-safety |
|---|---|---|---|---|
| options-menu | load | 3/3 ok (100) | 3/3 ok (100) | 3/3 ok (100) |
| failing-tests | load | 1/3 FAIL (60) | 3/3 ok (93) | 3/3 ok (97) |
| detached-head | load | 0/3 FAIL (57) | 3/3 ok (100) | 3/3 ok (93) |
| merge-worktree | load | 1/3 FAIL (43) | 3/3 ok (100) | 3/3 ok (100) |
| discard-branch | load | 0/3 FAIL (33) | 3/3 ok (100) | 3/3 ok (100) |
| push-rejected | load | 0/3 FAIL (80) | 3/3 ok (77) | 3/3 ok (100) |
| no-integration | skip | 0/3 ok (93) | 0/3 ok (90) | 0/3 ok (87) |
| explain-code | skip | 0/3 ok (100) | 0/3 ok (100) | 0/3 ok (100) |

Both variants pass the rule: 18/18 loads where the skill is needed, 0/6
where it is not. The control loads 5/18 in the same run. Mean score over
all eight scenarios: control 70 (±30), v05 95 (±10), v06 97 (±6).

The control's own loads moved between runs (push-rejected was 2/3 in the
baseline and 0/3 here). That is why every comparison runs the control in
the same run as the variants.

## Decision

v06 ships. It and v05 both pass; v06 scored 100 against v05's 77 on
push-rejected and varies less. The change is one line, the description:

> Use when the user wants to finish a development branch or asks what to
> do with finished work (merge it, push it and open a pull request, keep
> it for later, throw it away, or remove its worktree), and before any
> merge, push, branch deletion or worktree removal at the end of a piece
> of work. Runs the tests first, presents the options as the user's
> decision, and never destroys unmerged commits or uncommitted files
> without explicit confirmation.

## Correction to the screen

The screen suggested the skill's body was being ignored once loaded:
agents merging over a failing test, and deleting a branch unasked. At
n=3, with REPLY.md required at the end of every turn, failing-tests
scored 93 and 97 and discard-branch 100 for both variants. Most of that
screen-time gap was the reply file going unwritten, not the skill's
instructions. It does not need a mutation step on this evidence.

## Still to check before publishing

The new description has not been through the registry quality review,
which needs a score of at least 80 to publish.
