# verification-before-completion

Triage (Sonnet, n=3, run `01a0cda7-1099-75b1-98da-0ff5209f319e`): **fail**

| scenario | expect | sonnet/control |
|---|---|---|
| linkbox-expiry-sweep | load | 3/3 ok |
| linkbox-namespace-isolation | load | 3/3 ok |
| linkbox-safe-handoff | load | 3/3 ok |
| linkbox-discard-branch | - | 0/3 |
| linkbox-worktree-cleanup | load | 0/3 FAIL |
| linkbox-review-feedback | load | 0/3 FAIL |

Same cause as finishing-a-development-branch: loads 3/3 whenever the router loads and 0/3 when it does not (worktree clean-up, review feedback). Next: the entry-point experiment.
