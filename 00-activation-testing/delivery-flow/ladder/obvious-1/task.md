Implement this approved ticket.

> **Click stats.**
> 1. Store: each successful `resolve(code)` on a shortener counts one click for that code in that namespace. `clicks(code)` returns the count, and 0 for a code the namespace does not hold.
> 2. Expiry: `sweepExpired(nowMs, onSwept)` takes an optional callback, called once with each code it removes.
> 3. CLI: a new `stats <namespace> <code>` command prints the click count. `resolve` of an expired link prints `expired` and does not count a click. Usage errors follow the pattern of the other commands.
> No third-party dependencies.

Carry it through to a reviewed, PR-ready local change. Do not push, merge, or open a pull request.
