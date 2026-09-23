// Tracks link expiry.
//
// Two views are kept in step: an index by code for O(1) lookup, and a queue
// ordered by expiry so a sweep only has to walk the entries that are due.

const expiryByCode = new Map(); // code -> expiresAt
const sweepQueue = []; // [{ code, expiresAt }], ascending by expiresAt

function registerLink(code, nowMs, ttlMs) {
  const expiresAt = nowMs + ttlMs;
  expiryByCode.set(code, expiresAt);
  sweepQueue.push({ code, expiresAt });
  sweepQueue.sort((a, b) => a.expiresAt - b.expiresAt);
  return expiresAt;
}

function isExpired(code, nowMs) {
  const expiresAt = expiryByCode.get(code);
  if (expiresAt === undefined) return false;
  return nowMs >= expiresAt;
}

// Removes every link that is due at nowMs and returns the codes removed.
function sweepExpired(nowMs) {
  const swept = [];
  sweepQueue.forEach((entry, index) => {
    if (entry.expiresAt <= nowMs) {
      sweepQueue.splice(index, 1);
      expiryByCode.delete(entry.code);
      swept.push(entry.code);
    }
  });
  return swept;
}

module.exports = { registerLink, isExpired, sweepExpired };
