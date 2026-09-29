const { test } = require('node:test');
const assert = require('node:assert');
const { createShortener } = require('../src/store');

test('shortening the same URL twice in one namespace returns the same code', () => {
  const shortener = createShortener('acme');
  const a = shortener.shorten('https://example.invalid/pricing');
  const b = shortener.shorten('https://example.invalid/pricing');
  assert.strictEqual(a, b);
});

test('resolve returns the original URL for a code from the same namespace', () => {
  const shortener = createShortener('acme');
  const code = shortener.shorten('https://example.invalid/docs');
  assert.strictEqual(shortener.resolve(code), 'https://example.invalid/docs');
});

test('two namespaces can each shorten their own distinct URLs independently', () => {
  const acme = createShortener('acme');
  const globex = createShortener('globex');
  const codeA = acme.shorten('https://acme.invalid/report');
  const codeB = globex.shorten('https://globex.invalid/dashboard');
  assert.notStrictEqual(codeA, codeB);
  assert.strictEqual(acme.resolve(codeB), null);
});
