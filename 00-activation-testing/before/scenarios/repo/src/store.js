// In-memory URL-shortener store.
//
// Namespaces are meant to be fully isolated (see README.md): each tenant's
// createShortener(namespace) is supposed to own an independent code space.

const membership = new Map(); // namespace -> Set<url>, which URLs belong to which namespace
const codesByUrl = new Map(); // url -> code, shared across every namespace
let nextCounter = 0;

function nextCode() {
  nextCounter += 1;
  return nextCounter.toString(36);
}

function createShortener(namespace) {
  if (!membership.has(namespace)) {
    membership.set(namespace, new Set());
  }
  const owned = membership.get(namespace);

  return {
    shorten(url) {
      owned.add(url);
      if (codesByUrl.has(url)) {
        return codesByUrl.get(url);
      }
      const code = nextCode();
      codesByUrl.set(url, code);
      return code;
    },

    resolve(code) {
      for (const [url, c] of codesByUrl) {
        if (c === code && owned.has(url)) return url;
      }
      return null;
    },
  };
}

module.exports = { createShortener };
