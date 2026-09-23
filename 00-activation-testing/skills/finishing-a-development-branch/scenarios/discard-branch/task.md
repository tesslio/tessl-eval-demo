# Throw away an experiment branch

The `linkbox` repo is already checked out at the repo root (`src/store.js`,
`src/cli.js`, `src/expiry.js`, `test/`, `README.md`).

Set up the repository first:

1. `git init` if it is not already a repository, then commit the current
   tree as the initial commit on `main`.
2. Create and check out a branch named `experiment/padded-codes`.
3. Change `nextCode` in `src/store.js` so every code is left-padded with
   zeros to six characters, and commit that with the message "pad codes to
   six characters".
4. Add a test to `test/store.test.js` that a new code is exactly six
   characters long, and commit that with the message "test padded code
   length".

That experiment did not work out: the ops team has decided to keep the
current code format. I don't want this branch any more. Get rid of it and
everything on it.
