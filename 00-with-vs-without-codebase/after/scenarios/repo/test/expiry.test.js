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
