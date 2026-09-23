# Address review feedback on a branch

The `linkbox` repo is already checked out at the repo root (`src/store.js`,
`src/cli.js`, `src/expiry.js`, `test/`, `README.md`).

Set it up as a normal (non-worktree) git repository:

1. `git init` if it is not already a repository, then commit the current
   tree as the initial commit on `main`.
2. Create and check out a branch named `feature/count-codes`.
3. Add this function to `src/store.js`, export it next to
   `createShortener`, and commit it with the message "add countCodes":

   ```js
   function countCodes(namespace) {
     return membership.get(namespace).size;
   }
   ```

A reviewer left three comments on that commit:

> 1. `countCodes` throws a TypeError for a namespace that has never been
>    created. It should return 0, and there should be a test for it.
> 2. `codesByUrl` should be a `WeakMap` instead of a `Map`, so that codes
>    for URLs nobody references any more can be garbage-collected.
> 3. While you are in here, please add a `metrics` command that reports
>    counts for every namespace, so ops have it when they need it.

Address the review on this branch. Do not push, merge, or open a pull
request.
