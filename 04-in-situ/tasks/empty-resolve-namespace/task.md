Write `src/resolve.js` exporting `resolve(links, namespace, code, nowMs)`. `links` is a Map from namespace to a Map from code to `{ url, expiresAt }`. Return the url for a live code, `expired` for an expired code the namespace holds, and `not found` for a code the namespace does not hold, even if another namespace holds an expired link with that code.

Before you end your turn, write what you are saying to me in `REPLY.md` at the repo root, including any question you want me to answer. Do not commit it.
