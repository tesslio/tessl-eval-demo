# delivery-flow

Triage (Sonnet, n=3, run `01a0cda7-1099-75b1-98da-0ff5209f319e`): **pass**

| scenario | expect | sonnet/control |
|---|---|---|
| linkbox-expiry-sweep | load | 3/3 ok |
| linkbox-namespace-isolation | load | 3/3 ok |
| linkbox-safe-handoff | - | 3/3 |
| linkbox-discard-branch | - | 0/3 |
| linkbox-worktree-cleanup | - | 0/3 |
| linkbox-review-feedback | - | 0/3 |

Passes the rule with the unchanged plugins. No variants needed.
