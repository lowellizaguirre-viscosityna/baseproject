# Security baseline

## Authentication / authorization

- Authorization is checked **server-side on every endpoint**, including read endpoints.
  Hiding a button is not security. The UI's permission state is advisory only.
- Default deny: a route without an explicit policy is rejected, and that rejection is
  logged `auth.denied` with the route, subject, and correlation ID.
- Sessions: short-lived access token, rotating refresh, server-side revocation list.
  Log every issue, refresh, and revoke.

## Input and output

- Validate every input at the boundary with a schema; reject unknown fields rather than
  ignoring them.
- Parameterized queries only — no string-built SQL, ever.
- Escape on output by context (HTML, attribute, URL, shell). Never build a shell command
  from user input; use argument arrays.
- Set a Content-Security-Policy, `X-Content-Type-Options: nosniff`, and HSTS. Cookies are
  `HttpOnly`, `Secure`, `SameSite=Lax` minimum.
- Cap request body size, apply rate limits per IP and per subject, and bound every
  outbound call with a timeout.

## Secrets

- Never in the repo, never in logs, never in error messages, never in the support bundle.
  Enforced by a secret scanner in CI and by the logger's redactor.
- Rotation is a documented procedure in [release.md](release.md), not tribal knowledge.
- Local development uses `.env.local` (git-ignored) with fake values that still validate.

## Dependencies

- Lockfile committed. Automated dependency audit in CI; a high-severity advisory blocks
  merge. No install scripts from untrusted packages.

## Privacy

- Classify fields as public / internal / personal / secret in the data model.
- Personal data is minimized, its retention documented in [data.md](data.md), and excluded
  from diagnostics bundles by default.

## Checklist

- [ ] Default-deny authorization with per-route policies
- [ ] Schema validation rejecting unknown fields
- [ ] Parameterized queries, context-aware escaping, no shell string building
- [ ] Security headers and cookie flags set
- [ ] Rate limits, body-size caps, outbound timeouts
- [ ] Secret scanning and dependency audit in CI
