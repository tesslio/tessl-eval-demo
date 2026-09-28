# Worked example: delivery-flow

`delivery-flow` is the router in this skill set. It takes one engineering task and carries it to a verified, reviewed local change, loading the right skill at each stage: planning, test-first implementation, debugging, verification and review. When the router does not load, none of that happens: the agent does the task alone, and the stage skills behind it are not loaded either.

The change this example reached is in [`../after/plugins/sdlc-router/skills/delivery-flow/SKILL.md`](../after/plugins/sdlc-router/skills/delivery-flow/SKILL.md). Only the description changed.

## The result

Measured in one run, 3 times per scenario, the description at the start of this work against the new one:

- **Requests that name the skill, or state its job plainly:** 9 of 9 before, 9 of 9 after.
- **Everyday requests** (a terse "fix pls", an aside inside other context, a fix under time pressure): 1 of 9 before, 5 of 9 after.
- **Easy-to-miss requests** (a one-line flag, "fix what the reviewer flagged"): 1 of 6 before, 6 of 6 after.
- **Requests held back until this run:** 0 of 6 before, 3 of 6 after.
- **Requests it should stay out of** (a question about the code, a merge, a newsletter, deciding which review comments to accept): 0 of 12 loads before, 0 of 12 after.
- **Neighboring skills:** none lost loads.
- **Full tasks, scored with the real skill bodies, out of 100:** 70 and 70; 70 and 70; 50 and 40. No task dropped more than 15 points.

## The descriptions

**Before:**

> Use when an engineering task must be carried to a verified, reviewed, PR-ready local change: an approved ticket or requirements, a feature, or a bug fix, including a failing test, a crash, or a bug a user reported.

**After:**

> Carries a code change through to a tested, verified and reviewed local change, loading the stage skill for each step: planning, test-first implementation, debugging, verification and review. Use when a request asks for code to change, whether it arrives as an approved ticket or a one-line message: a bug fix, a failing test or crash, a small feature or flag, a behavior change, or review comments to fix. Not for questions about the code, for merging or deleting a finished branch, or for deciding which review comments to accept without changing code. Use it whenever the work will change code, even when the user does not mention tests, review or a pull request.

## How we got there

**1. The ladder.** [`LADDER.md`](LADDER.md) lists 12 situations, from a request that names the skill to requests it must stay out of, with the reason for each borderline one. Two more were held back, and four check the neighboring skills: `executing-plans`, `receiving-code-review`, `systematic-debugging` and `finishing-a-development-branch`. One situation was dropped: "walk me through how you would do this ticket". The router's instructions cover explanation-only requests, but its description does not, and nothing decides which side it falls on.

**2. The check.** Each of the 12 scenarios ran once with the current description, the router's body replaced by a stop line. 12 cells, plus 3 scored full tasks.

- Named and obvious: 3 of 3 loaded.
- Normal: 0 of 3. On "tests on main are red since this morning, fix pls", on the aside about fractional ttls, and on "quick one before the release goes out", no skill loaded at all. The agent did the work alone, in 10 to 13 turns.
- Easy-to-miss: 1 of 2. The review fix loaded; `linkbox --version` did not.
- Requests it should stay out of: 0 loads.

**3. The cause.** The old description triggers on how a request is dressed ("an approved ticket", "must be carried to a ... PR-ready local change"), not on the kind of work. Everyday requests carry none of those signals. No other skill loaded in their place, so this was not two skills competing for the same requests; it was a description that did not name the requests.

**4. The rewrites.** Two, both in [`variants.json`](variants.json), each aimed at that cause:

- **One rewrite from the failures:** say what the router does, then "use when a request asks for code to change, whether it arrives as an approved ticket or a one-line message", naming the kinds of work, then "not for" the requests it must stay out of.
- **The same, with a firmer last sentence:** "use it whenever the work will change code, even when the user does not mention tests, review or a pull request."

Both scored higher on the quality review than the old description (97 and 94, against 86), so both ran.

**5. The fix round.** Each version ran once per scenario. 36 cells.

- The first rewrite passed 2 scenarios the old description failed.
- The firmer rewrite passed 3: the fractional-ttl aside, "quick one before the release", and `--version`. Neither loaded where it should not.
- "tests on main are red, fix pls" loaded no skill in any version.

The firmer rewrite went to the confirm.

**6. The confirm.** The old and new descriptions, 3 times per scenario, on the ladder and the held-back pair, then the neighbor checks. 92 cells. The results are above.

One neighbor check failed at first: `systematic-debugging` loaded once with the old description and not with the new one, on a single run. The same request was rerun 5 times with each description. `systematic-debugging` loaded in none of the 10, so the first result was chance. 10 cells.

**7. The full tasks.** The three scored tasks in [`tasks/`](tasks/) ran once with each description, with every skill body real. 6 cells.

**Cost:** 159 cells in all.

## Still open

- **"tests on main are red since this morning, fix pls"** loaded no skill in any of 14 runs, with any description. The request is terse, and the fix is one character.
- **"The plan in docs/plans is approved. Implement it."** loads `executing-plans` instead of the router. The plan file itself tells the agent to use `executing-plans`.
- **"Which of these review comments should we take?"** loads no skill. That is `receiving-code-review`'s job, and it needs its own ladder.

## Files

- **[`LADDER.md`](LADDER.md):** the situations, why each is on its rung, the neighbors, and the expected causes.
- **[`ladder/`](ladder/):** the 12 scenarios. Each holds `task.md` (the request), `setup.sh` (the starting state), `scenario.json` and a placeholder `criteria.json`.
- **[`heldout/`](heldout/):** the 2 held-back scenarios.
- **[`neighbors/`](neighbors/):** one request per neighboring skill.
- **[`tasks/`](tasks/):** the 3 full tasks, with their scoring rubrics.
- **[`expectations.json`](expectations.json):** the rung and expected result of every scenario.
- **[`variants.json`](variants.json):** the rewrites tried, with what each was aimed at.
