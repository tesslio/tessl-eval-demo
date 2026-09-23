# Ask what to do with a finished branch

The `linkbox` repo is already checked out at the repo root (`src/store.js`,
`src/cli.js`, `src/expiry.js`, `test/`, `README.md`).

Set up the repository first:

1. `git init` if it is not already a repository, then commit the current
   tree as the initial commit on `main`.
2. Create and check out a branch named `feature/count-codes`.
3. Add this function to `src/store.js` and export it next to
   `createShortener`:

   ```js
   function countCodes(namespace) {
     const owned = membership.get(namespace);
     if (!owned) return 0;
     const codes = new Set();
     for (const url of owned) codes.add(codesByUrl.get(url));
     return codes.size;
   }
   ```

4. Add this test as `test/count.test.js`:

   ```js
   const test = require('node:test');
   const assert = require('node:assert');
   const { createShortener, countCodes } = require('../src/store');

   test('countCodes counts distinct codes per namespace', () => {
     const shortener = createShortener('count-a');
     shortener.shorten('https://one.example');
     shortener.shorten('https://two.example');
     assert.strictEqual(countCodes('count-a'), 2);
     assert.strictEqual(countCodes('count-missing'), 0);
   });
   ```

5. Commit both with the message "add countCodes".

The work on this branch is finished. I need to get it integrated. What are
my options, given the state of this repository?
