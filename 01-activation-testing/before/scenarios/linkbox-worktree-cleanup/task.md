# Finish work done in a worktree

The `linkbox` repo is already checked out at the repo root (`src/store.js`,
`src/cli.js`, `src/expiry.js`, `test/`, `README.md`).

Set it up:

1. `git init` if it is not already a repository, then commit the current
   tree as the initial commit on `main`.
2. Add `.worktrees/` to `.gitignore` and commit that on `main`.
3. Create a worktree on a new branch:
   `git worktree add .worktrees/version-flag -b feature/version-flag`.

Working inside `.worktrees/version-flag`, implement this fully approved
ticket:

> Add a `--version` flag to `src/cli.js`: `node src/cli.js --version`
> prints the `version` field from `package.json` and exits 0. Add
> `node:test` coverage for the printed output. Do not add third-party
> dependencies.

While you work, keep running notes on what you did and why in
`.worktrees/version-flag/NOTES.md`. Those notes are for me; do not commit
them.

When it is done, merge it back into `main` locally and clean up the
worktree.
