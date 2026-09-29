Implement this approved ticket on the branch you are on, `feature/ttl-cap`.

> **Cap link lifetime.** `shorten` rejects `--ttl-ms` above 30 days (2592000000 ms) with the message `--ttl-ms must be at most 30 days` and exit code 1. Exactly 30 days is allowed.

When it is done and reviewed, merge `feature/ttl-cap` into `main` locally and delete the branch. Do not push anything.

Before you end your turn, write what you are saying to me in `REPLY.md` at the repo root, including any question you want me to answer. Do not commit it.
