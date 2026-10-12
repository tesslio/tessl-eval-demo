const { test } = require('node:test');
const assert = require('node:assert');
const { registerLink, isExpired, sweepExpired } = require('../src/expiry');

test('a link is not expired before its ttl elapses', () => {
  registerLink('a1', 1000, 5000);
  assert.strictEqual(isExpired('a1', 5999), false);
});

test('a link is expired once its ttl elapses', () => {
  registerLink('a2', 1000, 5000);
  assert.strictEqual(isExpired('a2', 6000), true);
});

test('a link registered without a ttl expires after one day', () => {
  registerLink('a3', 0);
  assert.strictEqual(isExpired('a3', 86399999), false);
  assert.strictEqual(isExpired('a3', 86400000), true);
});

test('an unknown code is never reported expired', () => {
  assert.strictEqual(isExpired('nope', 999999), false);
});

test('one sweep removes every link that is due', () => {
  sweepExpired(1000000000); // clear links left by earlier tests
  registerLink('b1', 2000000000, 100);
  registerLink('b2', 2000000000, 200);
  registerLink('b3', 2000000000, 300);
  registerLink('b4', 2000000000, 900000);
  assert.deepStrictEqual(sweepExpired(2000000500).sort(), ['b1', 'b2', 'b3']);
});
