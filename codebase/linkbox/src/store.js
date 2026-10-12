// In-memory URL-shortener store. Each namespace owns its own code space.

const namespaces = new Map(); // namespace -> { codeByUrl, urlByCode }
let nextCounter = 0;

function nextCode() {
  nextCounter += 1;
  return nextCounter.toString(36);
}

function createShortener(namespace) {
  if (!namespaces.has(namespace)) {
    namespaces.set(namespace, { codeByUrl: new Map(), urlByCode: new Map() });
  }
  const { codeByUrl, urlByCode } = namespaces.get(namespace);

  return {
    shorten(url) {
      if (codeByUrl.has(url)) {
        return codeByUrl.get(url);
      }
      const code = nextCode();
      codeByUrl.set(url, code);
      urlByCode.set(code, url);
      return code;
    },

    resolve(code) {
      return urlByCode.has(code) ? urlByCode.get(code) : null;
    },
  };
}

module.exports = { createShortener };
