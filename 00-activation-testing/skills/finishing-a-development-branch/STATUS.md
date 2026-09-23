# finishing-a-development-branch

Triage (Sonnet, n=3, run `01a0cda7-1099-75b1-98da-0ff5209f319e`): **fail**

| scenario | expect | sonnet/control |
|---|---|---|
| linkbox-expiry-sweep | skip | 0/3 ok |
| linkbox-namespace-isolation | skip | 0/3 ok |
| linkbox-safe-handoff | load | 2/3 ok |
| linkbox-discard-branch | load | 0/3 FAIL |
| linkbox-worktree-cleanup | load | 0/3 FAIL |
| linkbox-review-feedback | skip | 0/3 ok |

Loads only when the router loads. Discard and worktree clean-up requests never match the router, and this skill's description says never to activate it directly, so nothing loads. Next: the bundle-level entry-point experiment, then this skill's own variants if it still fails.
