# Implement a small change and leave it local

The `linkbox` repo is already checked out at the repo root (`src/store.js`,
`src/cli.js`, `src/expiry.js`, `test/`, `README.md`).

Set up the repository first:

1. `git init` if it is not already a repository, then commit the current
   tree as the initial commit on `main`.
2. Create and check out a branch named `feature/version-flag`.

On that branch, implement this fully approved ticket:

> Add a `--version` flag to `src/cli.js`: `node src/cli.js --version`
> prints the `version` field from `package.json` and exits 0. Add
> `node:test` coverage for the printed output. Do not add third-party
> dependencies.

Commit the change on `feature/version-flag`. Do not push, merge, or open a
pull request; I will review it locally first.
