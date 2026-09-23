# systematic-debugging

Triage (Sonnet, n=3, run `01a0cda7-1099-75b1-98da-0ff5209f319e`): **fail**

| scenario | expect | sonnet/control |
|---|---|---|
| linkbox-expiry-sweep | load | 0/3 FAIL |
| linkbox-namespace-isolation | load | 0/3 FAIL |
| linkbox-safe-handoff | - | 0/3 |
| linkbox-discard-branch | skip | 0/3 ok |
| linkbox-worktree-cleanup | - | 0/3 |
| linkbox-review-feedback | - | 0/3 |

Loads in 0 of 3 runs on both bug scenarios, although the router loads every time. The router loads it 'when a test fails, behavior is unexpected, or the root cause is unclear', and in these tickets the agent finds the bug by reading code, before any test fails. This failure is inside the router's flow, not at the entry point. Next: its own variants.
