Review came back on `feature/resolve-json` (the branch you are on) from Reviewer A:

> 1. `resolve <ns> <code> --json` on an expired link prints the plain word `expired`, not JSON. It should print `{"error":"expired"}`.
> 2. `resolve` calls `createShortener(namespace)` on every call, which builds a fresh, empty namespace each time, so a code shortened in an earlier call can never be found. Cache the shorteners in a module-level map in `cli.js`.
> 3. The usage line for `resolve` does not mention `--json`.

Address the review and leave the branch PR-ready. Do not push, merge, or open a pull request.

Before you end your turn, write what you are saying to me in `REPLY.md` at the repo root, including any question you want me to answer. Do not commit it.
