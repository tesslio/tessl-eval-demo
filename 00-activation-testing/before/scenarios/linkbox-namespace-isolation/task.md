# Add a stats command to linkbox, and a suspected isolation bug

The `linkbox` repo is already checked out at the repo root (`src/store.js`,
`src/cli.js`, `test/store.test.js`, `README.md`). Read the existing code
before changing anything.

Implement this fully approved engineering ticket:

> Add a `stats` command to `src/cli.js`:
> `node src/cli.js stats <namespace> <url...>`. It should shorten each URL
> under the given namespace using the existing `createShortener` in
> `src/store.js`, then print two lines: `urls: <n>` for the number of URLs
> processed and `codes: <n>` for the number of distinct short codes those
> URLs produced. Ops are about to publish these counts per tenant and want
> confidence that one namespace's codes are independent of another's before
> relying on them — verify this against the claim in `README.md` and the
> comment at the top of `src/store.js` before building on it, and fix it if
> it does not hold (for example, the same URL shortened under two different
> namespaces should not come back with the same code). Add automated
> coverage for namespace isolation in the store in isolation, for the
> distinct-code counting logic, and for the command's output, each
> independently. Do not add third-party dependencies or implement other
> commands.

Carry the ticket through planning, implementation, verification, review,
and any valid review fixes, leaving a PR-ready local change. The ticket is
sufficiently specified; do not stop merely to ask which development process
to follow. Do not push, merge, or open a real pull request.
