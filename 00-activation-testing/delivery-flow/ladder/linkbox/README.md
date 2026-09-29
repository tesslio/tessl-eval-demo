# linkbox

A tiny multi-tenant URL shortener. Each tenant gets its own `namespace`.
Shortening the same URL in two namespaces gives two different codes, and a
code from one namespace never resolves inside another.

Links expire. A link registered without a ttl lasts one day.

## Usage

    node src/cli.js shorten <namespace> <url> [--ttl-ms <ms>]
    node src/cli.js resolve <namespace> <code>
    node src/cli.js status <code> [--now <ms>]
