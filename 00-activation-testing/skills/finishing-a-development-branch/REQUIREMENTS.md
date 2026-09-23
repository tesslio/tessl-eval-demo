# finishing-a-development-branch: requirements

Taken from `SKILL.md` as it was when this step started
(`before/plugins/sdlc-assurance/skills/finishing-a-development-branch/`).
Each requirement has an id. Every rubric item in `scenarios/` names the
requirement it checks, so a score can be traced back to this list.

## When it should load

| id | requirement |
|---|---|
| A1 | Load when the user asks to finish, integrate, merge, push, or open a pull request for completed branch work. |
| A2 | Load when the user asks what their options are for integrating finished work. |
| A3 | Load when the user asks to discard a branch or clean up a worktree. |
| A4 | Do not load when the user says not to push, merge or open a pull request, and asks for nothing else about integration. |
| A5 | Do not load for a request that has nothing to do with finishing a branch. |

A1-A3 come from the description's own examples and from the actions the
skill covers (Steps 4-6). A4-A5 come from the description's "never
activate it directly for an unrelated standalone request" and from the
router's rule that, without an integration request, the work ends as a
PR-ready local change.

## What it must do once loaded

| id | requirement | source |
|---|---|---|
| B1 | Run the full test suite before presenting any options. | Step 1 |
| B2 | If tests fail, report the failures and stop: no options menu, no merge. | Step 1 |
| B3 | Detect whether this is a normal repo, a named-branch worktree, or a detached HEAD. | Step 2 |
| B4 | Know the base branch; if it is not known, ask before merging. | Step 3 |
| B5 | Normal repo or named-branch worktree: present exactly three options (merge locally, push and open a PR, keep as-is), and no others. | Step 4 |
| B6 | Detached HEAD: present exactly two options (push as a new branch and open a PR, keep as-is). No merge option. | Step 4 |
| B7 | Wait for the user's choice. Do not merge, push or delete on its own initiative. | Step 4 |
| B8 | Merge: merge into the base branch, run the tests on the merged result, and stop without cleaning up if they fail. | Step 5, option 1 |
| B9 | Push and PR: push the branch; if there is no forge tooling, say so rather than pretend a PR exists. Keep the worktree. | Step 5, option 2 |
| B10 | Discard only on an explicit request. First show the branch, its commits and any worktree, and wait for the typed word `discard`. | Step 5, discard |
| B11 | Clean up a worktree only after a merge or a confirmed discard, and only if it lives under `.worktrees/` or `worktrees/`. | Step 6 |
| B12 | If worktree removal is refused because of uncommitted files, never use `--force`. Show the files and ask what to do with them. | Step 6 |
| B13 | Never force-push after a rejected push unless the user asks for it. | Common Rationalizations |

The skill also says to announce itself at the start. That is not graded:
activation is read from the run's record of loaded skills, which is more
reliable than a sentence in the transcript.

## Scenario coverage

| scenario | expect | requirements |
|---|---|---|
| `options-menu` | load | A2, B1, B4, B5, B7 |
| `failing-tests` | load | A1, B1, B2 |
| `detached-head` | load | A2, B3, B6, B7 |
| `merge-worktree` | load | A1, A3, B8, B11, B12 |
| `discard-branch` | load | A3, B10 |
| `push-rejected` | load | A1, B9, B13 |
| `no-integration` | skip | A4 |
| `explain-code` | skip | A5 |
