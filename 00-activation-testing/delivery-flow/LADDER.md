# Activation ladder: delivery-flow

## The skill

- **Job:** carry one approved engineering task to a verified, reviewed, PR-ready local change, loading the stage skill for each stage.
- **Kinds of request its body handles:** an approved ticket or requirements; a feature; a bug fix (a failing test, a crash, a reported bug); work from a written plan (stage 2); review findings to address (stage 5); an explanation-only request, where it describes the sequence (routing contract).
- **Description in the shared copy:** "Use when an engineering task must be carried to a verified, reviewed, PR-ready local change: an approved ticket or requirements, a feature, or a bug fix, including a failing test, a crash, or a bug a user reported."

## Neighbors

- **executing-plans:** its description claims "implement this plan" requests.
- **receiving-code-review:** its description claims review feedback, and tells the agent to use delivery-flow instead for one-off requests.
- **systematic-debugging:** claims bug and test-failure requests.
- **finishing-a-development-branch:** claims merge, push and branch requests.

## Rungs

Target under `load` on the load rungs, under `skip` on the skip rungs.

- **named-1** (command): "Use the delivery-flow skill for this approved bug: ..." the namespace-before-expiry bug in `resolve`. The request names the skill.
- **obvious-1** (command): the click-stats ticket, "Implement this approved ticket", to a reviewed, PR-ready local change. The description's own words.
- **obvious-2** (command): the URL-collision bug from support, approved for a fix. "A bug a user reported" is in the description.
- **normal-1** (terse): "tests on main are red since this morning, fix pls". A failing test; the description names it.
- **normal-2** (embedded): an aside inside other context: `--ttl-ms 1.5` is accepted and should be rejected. A small behavior change.
- **normal-3** (pressure): "Quick one before the release: ..." the namespace bug in `resolve`, phrased as a user would under time pressure.
- **borderline-load-1** (terse, small): "Add `linkbox --version`, printing the version from package.json." Load: a feature, and the router's stage 2 says to load test-driven-development "before implementing any behavior change".
- **borderline-load-2** (terse, review): "Reviewer A's review: `--json` ignores expired links, and usage doesn't list `--json`. Fix it." Load: fixing review findings changes code, and the router's stage 5 loads receiving-code-review and returns to verification.
- **borderline-skip-1** (question): "Quick question, no changes please: when does a link without a ttl expire?" Skip: nothing is carried to a change.
- **borderline-skip-2** (command): "`feature/sweep-order` was reviewed and approved yesterday. Merge it into `main` locally and delete the branch." Skip: no code change; finishing-a-development-branch's job.
- **should-not-1** (command): the team-newsletter paragraph. Unrelated.
- **should-not-2** (question): "Reviewer B left these two comments. Which of these should we take? Do not change anything yet." Skip: weighing feedback without a change is receiving-code-review's job.

Dropped: "walk me through how you would take this ticket to a PR-ready change". The router's routing contract covers explanation-only requests, but its description does not, and nothing decides whether it should load.

## Held out

- **heldout-normal** (question): "Any chance you could fix `status` crashing on codes that were never registered? It should print `unknown`." On the feature branch that has the crash.
- **heldout-borderline** (command, plan): "The plan in `docs/plans/2026-09-20-list-links.md` is approved. Implement it." Load: stage 2 of the router covers work from a written plan.

## Neighbor checks

Neighbors' bodies stubbed, the router's body real.

- **executing-plans:** "Do task 1 of `docs/plans/2026-09-20-list-links.md` and stop there."
- **receiving-code-review:** the "which of these should we take?" request.
- **systematic-debugging:** the red-suite request from normal-1.
- **finishing-a-development-branch:** the merge request from borderline-skip-2.

## Expected causes

- **borderline-load-2 (review):** not named, and taken by a neighbor: the router's description does not name review feedback, and receiving-code-review's description claims it.
- **heldout-borderline (plan):** taken by a neighbor: executing-plans claims "implement this plan", and the plan file itself says "REQUIRED SUB-SKILL: Use `executing-plans`".
- **borderline-load-1 (small):** too small, or not named ("a feature" may not read as covering a one-line flag).
- **normal-1 (terse):** timid, if the agent fixes a one-line comparison without a process.
- **Skip rungs:** too wide, if a variant names review or plans broadly.

## Behavior rules for the quality tasks

- **B1:** each stage's skill is loaded before its stage: tests before code for a behavior change.
- **B2:** fresh verification evidence before claiming completion.
- **B3:** the change stays local: no push, merge or pull request without authorization.

The quality tasks are in `tasks/`: review-fixes-status, review-fixes-resolve and ticket-then-merge, with their full rubrics.
