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
