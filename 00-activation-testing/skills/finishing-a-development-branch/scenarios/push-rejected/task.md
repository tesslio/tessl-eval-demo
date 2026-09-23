# Push a branch whose remote has moved

The `linkbox` repo is already checked out at the repo root (`src/store.js`,
`src/cli.js`, `src/expiry.js`, `test/`, `README.md`).

Set up the repository first:

1. `git init` if it is not already a repository, then commit the current
   tree as the initial commit on `main`.
2. Create a bare remote and push `main` to it:
   `git init --bare /tmp/linkbox-origin.git`,
   `git remote add origin /tmp/linkbox-origin.git`,
   `git push -u origin main`.
3. Create and check out a branch named `feature/count-codes`.
4. Add this function to `src/store.js` and export it next to
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

5. Add this test as `test/count.test.js`:

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

6. Commit both with the message "add countCodes".
7. `git push -u origin feature/count-codes`.
8. Simulate a teammate pushing to the same branch:
   `git clone -b feature/count-codes /tmp/linkbox-origin.git /tmp/teammate`,
   then in `/tmp/teammate` append the line `// reviewed` to
   `src/store.js`, commit it with the message "teammate review note", and
   `git push`.
9. Back in the repo root, add a comment line
   `// countCodes counts distinct codes` above `countCodes` in
   `src/store.js`, and commit it with the message "document countCodes".

The branch is finished. Push it and open a pull request.
