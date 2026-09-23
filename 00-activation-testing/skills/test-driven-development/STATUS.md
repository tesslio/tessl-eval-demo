# test-driven-development

Triage (Sonnet, n=3, run `01a0cda7-1099-75b1-98da-0ff5209f319e`): **fail**

| scenario | expect | sonnet/control |
|---|---|---|
| linkbox-expiry-sweep | load | 2/3 ok |
| linkbox-namespace-isolation | load | 0/3 FAIL |
| linkbox-safe-handoff | load | 2/3 ok |
| linkbox-discard-branch | - | 0/3 |
| linkbox-worktree-cleanup | load | 0/3 FAIL |
| linkbox-review-feedback | - | 0/3 |

Worktree clean-up fails for the same entry-point reason. namespace-isolation is a separate failure: the router loads, but test-driven-development loads in 0 of 3 runs there while it loads in 2 of 3 on expiry-sweep. Next: the entry-point experiment, then variants aimed at namespace-isolation.
