# Add a purge command to linkbox, and a suspected sweep bug

The `linkbox` repo is already checked out at the repo root (`src/store.js`,
`src/cli.js`, `src/expiry.js`, `test/`, `README.md`). Read the existing code
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
