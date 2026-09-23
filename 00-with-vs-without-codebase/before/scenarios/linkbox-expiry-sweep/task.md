# Add a purge command to linkbox, and a suspected sweep bug

Create the `linkbox` repo at the repo root from the files listed under
"Files" at the end of this ticket. Read the existing code
before changing anything.

Implement this fully approved engineering ticket:

> Add a `purge` command to `src/cli.js`: `node src/cli.js purge <nowMs>`.
> It should sweep every link that has expired as of `<nowMs>` using the
> existing `sweepExpired` in `src/expiry.js`, print one `removed: <code>`
> line per code it removed, and finish with `total: <n>`. Also wire
> registration in, so a shortened link starts its clock: `shorten` should
> call `registerLink` with a ttl taken from a `--ttl-ms` flag, defaulting to
> 86400000. Ops are about to run `purge` on a schedule and need confidence
> that one pass removes everything already due — verify that against what
> `sweepExpired` claims to do before building on it, and fix it if it does
> not hold. Add automated coverage for the sweep in isolation, for the
> registration wiring, and for the command's output, each independently. Do
> not add third-party dependencies or implement other commands.

Carry the ticket through planning, implementation, verification, review,
and any valid review fixes, leaving a PR-ready local change. The ticket is
sufficiently specified; do not stop merely to ask which development process
to follow. Do not push, merge, or open a real pull request.

## Files

Create each of these at the given path before starting.

### `package.json`

```json
{
  "name": "linkbox",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "test": "node --test"
  }
}
```

### `README.md`

```markdown
# linkbox

A tiny multi-tenant URL shortener. Each tenant gets its own `namespace`.

## Namespace isolation

Namespaces are fully independent. `createShortener(namespace)` gives each
tenant its own code space: shortening the same URL in two different
namespaces produces two different codes, and a code from one namespace
never resolves inside another. Tenants never need to worry about a
neighboring namespace's activity affecting their own codes.

## Usage

    node src/cli.js shorten <namespace> <url>
    node src/cli.js resolve <namespace> <code>
```

### `src/store.js`

```js
// In-memory URL-shortener store.
//
// Namespaces are meant to be fully isolated (see README.md): each tenant's
// createShortener(namespace) is supposed to own an independent code space.

const membership = new Map(); // namespace -> Set<url>, which URLs belong to which namespace
const codesByUrl = new Map(); // url -> code, shared across every namespace
let nextCounter = 0;

function nextCode() {
  nextCounter += 1;
  return nextCounter.toString(36);
}

function createShortener(namespace) {
  if (!membership.has(namespace)) {
    membership.set(namespace, new Set());
  }
  const owned = membership.get(namespace);

  return {
    shorten(url) {
      owned.add(url);
      if (codesByUrl.has(url)) {
        return codesByUrl.get(url);
      }
      const code = nextCode();
      codesByUrl.set(url, code);
      return code;
    },

    resolve(code) {
      for (const [url, c] of codesByUrl) {
        if (c === code && owned.has(url)) return url;
      }
      return null;
    },
  };
}

module.exports = { createShortener };
```

### `src/expiry.js`

```js
// Tracks link expiry.
//
// Two views are kept in step: an index by code for O(1) lookup, and a queue
// ordered by expiry so a sweep only has to walk the entries that are due.

const expiryByCode = new Map(); // code -> expiresAt
const sweepQueue = []; // [{ code, expiresAt }], ascending by expiresAt

function registerLink(code, nowMs, ttlMs) {
  const expiresAt = nowMs + ttlMs;
  expiryByCode.set(code, expiresAt);
  sweepQueue.push({ code, expiresAt });
  sweepQueue.sort((a, b) => a.expiresAt - b.expiresAt);
  return expiresAt;
}

function isExpired(code, nowMs) {
  const expiresAt = expiryByCode.get(code);
  if (expiresAt === undefined) return false;
  return nowMs >= expiresAt;
}

// Removes every link that is due at nowMs and returns the codes removed.
function sweepExpired(nowMs) {
  const swept = [];
  sweepQueue.forEach((entry, index) => {
    if (entry.expiresAt <= nowMs) {
      sweepQueue.splice(index, 1);
      expiryByCode.delete(entry.code);
      swept.push(entry.code);
    }
  });
  return swept;
}

module.exports = { registerLink, isExpired, sweepExpired };
```

### `src/cli.js`

```js
#!/usr/bin/env node
const { createShortener } = require('./store');

function main(argv) {
  const [command, namespace, ...rest] = argv;

  if (command === 'shorten') {
    const [url] = rest;
    const shortener = createShortener(namespace);
    console.log(shortener.shorten(url));
    return;
  }

  if (command === 'resolve') {
    const [code] = rest;
    const shortener = createShortener(namespace);
    const url = shortener.resolve(code);
    console.log(url === null ? 'not found' : url);
    return;
  }

  console.error('Usage: cli.js <shorten|resolve> <namespace> <url|code>');
  process.exitCode = 1;
}

if (require.main === module) {
  main(process.argv.slice(2));
}

module.exports = { main };
```

### `test/store.test.js`

```js
const { test } = require('node:test');
const assert = require('node:assert');
const { createShortener } = require('../src/store');

test('shortening the same URL twice in one namespace returns the same code', () => {
  const shortener = createShortener('acme');
  const a = shortener.shorten('https://example.com/pricing');
  const b = shortener.shorten('https://example.com/pricing');
  assert.strictEqual(a, b);
});

test('resolve returns the original URL for a code from the same namespace', () => {
  const shortener = createShortener('acme');
  const code = shortener.shorten('https://example.com/docs');
  assert.strictEqual(shortener.resolve(code), 'https://example.com/docs');
});

test('two namespaces can each shorten their own distinct URLs independently', () => {
  const acme = createShortener('acme');
  const globex = createShortener('globex');
  const codeA = acme.shorten('https://acme.example/report');
  const codeB = globex.shorten('https://globex.example/dashboard');
  assert.notStrictEqual(codeA, codeB);
  assert.strictEqual(acme.resolve(codeB), null);
});
```

### `test/expiry.test.js`

```js
const { test } = require('node:test');
const assert = require('node:assert');
const { registerLink, isExpired, sweepExpired } = require('../src/expiry');

test('a link is not expired before its ttl elapses', () => {
  registerLink('a1', 1000, 5000);
  assert.strictEqual(isExpired('a1', 4000), false);
});

test('a link is expired once its ttl elapses', () => {
  registerLink('a2', 1000, 5000);
  assert.strictEqual(isExpired('a2', 6000), true);
});

test('an unknown code is never reported expired', () => {
  assert.strictEqual(isExpired('nope', 999999), false);
});

test('sweeping removes a due link and reports it', () => {
  registerLink('a3', 1000, 1000);
  const swept = sweepExpired(9000);
  assert.ok(swept.includes('a3'));
});
```
