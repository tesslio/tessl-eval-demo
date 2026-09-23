# Ship a small, fully-specified feature on a branch

The `linkbox` repo is already checked out at the repo root (`src/store.js`,
`src/cli.js`, `src/expiry.js`, `test/`, `README.md`).

Set it up as a normal (non-worktree) git repository:

1. `git init` if it is not already a repository, then commit the current
   tree as the initial commit on `main`.
2. Create and check out a branch named `feature/link-count`.

On this branch, implement the following fully approved ticket:

> Add a `countCodes(namespace)` helper to `src/store.js` that returns the
> number of distinct short codes currently held by that namespace. Add a
> `count` command to `src/cli.js`: `node src/cli.js count <namespace>`,
> printing `codes: <n>`. Add `node:test` coverage for both — one test for
> the helper across two namespaces with different numbers of links, and one
> for the command's printed output. Do not add third-party dependencies.

The ticket is sufficiently specified; do not stop to ask which development
process to use, and do not stop to ask permission to implement it.

Once it's implemented and verified, I need to get this work integrated. Tell
me what my options are for doing that, given the state of this repository.
