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
