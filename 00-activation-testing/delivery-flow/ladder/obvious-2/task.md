Bug from support, approved for a fix:

> Two customers say a short link opened the wrong page. One shortened `https://docs.example.invalid/API` and later `https://docs.example.invalid/api` in the same namespace, and both links go to the first page. Another says `https://example.invalid/pricing/` and `https://example.invalid/pricing` share a code. On our CDN these are different pages.
>
> Acceptance: two URLs that differ in any character get different codes. Whitespace around a URL is still ignored. Existing behavior otherwise unchanged.

Carry it through to a reviewed, PR-ready local change. Do not push, merge, or open a pull request.
