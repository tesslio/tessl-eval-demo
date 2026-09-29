// Tracks when each link expires.

const DEFAULT_TTL_MS = 86400000; // one day

const expiryByCode = new Map(); // code -> expiresAt

function registerLink(code, nowMs, ttlMs = DEFAULT_TTL_MS) {
  const expiresAt = nowMs + ttlMs;
  expiryByCode.set(code, expiresAt);
  return expiresAt;
}

function isExpired(code, nowMs) {
  const expiresAt = expiryByCode.get(code);
  if (expiresAt === undefined) return false;
  return nowMs >= expiresAt;
}

// Forgets every link that is due at nowMs and returns the codes removed.
function sweepExpired(nowMs) {
  const swept = [];
  for (const [code, expiresAt] of expiryByCode) {
    if (expiresAt <= nowMs) swept.push(code);
  }
  for (const code of swept) expiryByCode.delete(code);
  return swept;
}

module.exports = { registerLink, isExpired, sweepExpired, DEFAULT_TTL_MS };
