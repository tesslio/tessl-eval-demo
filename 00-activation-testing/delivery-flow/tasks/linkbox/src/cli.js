#!/usr/bin/env node
const { createShortener } = require('./store');
const { registerLink, isExpired } = require('./expiry');

function main(argv, nowMs = Date.now()) {
  const command = argv[0];

  if (command === 'shorten') {
    const namespace = argv[1];
    const url = argv[2];
    if (!namespace || !url || namespace.startsWith('--') || url.startsWith('--')) {
      console.error('Usage: cli.js shorten <namespace> <url> [--ttl-ms <ms>]');
      process.exitCode = 1;
      return;
    }
    let ttlMs;
    const ttlIndex = argv.indexOf('--ttl-ms');
    if (ttlIndex !== -1) {
      ttlMs = Number(argv[ttlIndex + 1]);
      if (!Number.isFinite(ttlMs) || ttlMs <= 0) {
        console.error('--ttl-ms must be a positive number');
        process.exitCode = 1;
        return;
      }
    }
    const code = createShortener(namespace).shorten(url);
    registerLink(code, nowMs, ttlMs);
    console.log(code);
    return;
  }

  if (command === 'resolve') {
    const namespace = argv[1];
    const code = argv[2];
    if (!namespace || !code || namespace.startsWith('--') || code.startsWith('--')) {
      console.error('Usage: cli.js resolve <namespace> <code>');
      process.exitCode = 1;
      return;
    }
    if (isExpired(code, nowMs)) {
      console.log('expired');
      return;
    }
    const url = createShortener(namespace).resolve(code);
    console.log(url === null ? 'not found' : url);
    return;
  }

  if (command === 'status') {
    const code = argv[1];
    if (!code || code.startsWith('--')) {
      console.error('Usage: cli.js status <code> [--now <ms>]');
      process.exitCode = 1;
      return;
    }
    let at = nowMs;
    const nowIndex = argv.indexOf('--now');
    if (nowIndex !== -1) {
      at = Number(argv[nowIndex + 1]);
      if (!Number.isFinite(at) || at < 0) {
        console.error('--now must be a non-negative number');
        process.exitCode = 1;
        return;
      }
    }
    console.log(isExpired(code, at) ? 'expired' : 'live');
    return;
  }

  console.error('Usage: cli.js <shorten|resolve|status> ...');
  process.exitCode = 1;
}

if (require.main === module) {
  main(process.argv.slice(2));
}

module.exports = { main };
