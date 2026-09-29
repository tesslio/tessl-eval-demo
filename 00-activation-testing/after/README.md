# After

The four plugins with every change that step 00 has confirmed and applied. Each change was measured against the copy it replaced, and shipped only if it loaded more often where it should, no more often where it should not, took no loads from neighboring skills, and kept the scored tasks within 15 points.

## Changes applied

- **`delivery-flow` description** (in `sdlc-router`). The router now names the kinds of work it takes, in any form, instead of only formal tickets. Everyday requests: loaded 1 of 9 times before, 5 of 9 after; easy-to-miss requests 1 of 6, then 6 of 6; no loads where it should stay out. How it was reached and proven: [`../delivery-flow/`](../delivery-flow/).
- **`finishing-a-development-branch` description** (in `sdlc-assurance`). It now starts with when to use it, and names discarding a branch and removing a worktree as well as merging. Used where it should be 18 of 18 times, against 5 of 18 before, with no loads where it should not.
- **`delivery-flow` stage 3** (in `sdlc-router`). The router loads `systematic-debugging` before fixing any defect, even when the cause looks clear. `systematic-debugging` loaded 8 of 16 times where it should, against 2 of 16 before.

The last two were measured before this step used the ladder method described in [`../README.md`](../README.md), so they have no worked example here.
