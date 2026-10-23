# Configuration

## Precedence (highest wins)

1. CLI flags
2. Environment variables
3. `.env.local` (git-ignored)
4. `.env` / profile file (`config/<profile>.json`)
5. Built-in defaults

## Rules

- Config is loaded **once**, validated against a schema, and exposed as a frozen typed
  object. No `process.env` / `os.environ` reads outside the config module.
- Validation failure = refuse to start, with a message naming every bad or missing key.
  Never boot with a silently wrong default.
- Every key is documented in `.env.example` with purpose, type, default, and whether it
  is a secret. A key absent from `.env.example` fails review.
- Secrets never have defaults, never appear in logs, never appear in error messages, and
  are tagged in the schema so the redactor and the support bundle know to mask them.
- Secret values in local env files are encrypted at rest as `encrypted:<base64>` and
  decrypted transparently on read; the config loader runs each value through
  `Unprotect-EnvSecret` (see [`scripts/env-secrets.ps1`](../../scripts/env-secrets.ps1)
  and [security.md](security.md)) before validation, so plain and encrypted values are
  interchangeable.
- On start, log `config.loaded` with non-secret values and a hash fingerprint of the
  whole effective config — so you can tell two environments apart without exposing them.
- `app config show` prints the effective, redacted config and where each value came from
  (which layer won). This is the first thing to ask for when behaviour differs by machine.

## Baseline keys

The canonical list lives in [`.env.example`](../../.env.example) — it is the single
source of truth and is not duplicated here, so the two cannot drift. It is grouped by
standard (core, logging, diagnostics, debug, database, auth, limits, flags,
observability, build/deploy, outbound) with every key annotated `[required]` or
`[secret]` where it applies.

Secrets in `.env.example` carry placeholder values that still pass schema validation, so
a fresh clone boots and then fails with a clear message naming the key — rather than
crashing on a null, or worse, silently running with a development secret in production.
Production must reject the known placeholders outright.

`make setup` copies `.env.example` → `.env.local`. Only `.env.example` is committed;
`.gitignore` ignores `.env` and `.env.*` with an explicit `!.env.example` exception.

CI runs `scripts/check-env-example.sh`, which fails if the code reads a key that
`.env.example` does not document, or documents a key nothing reads.

## Checklist

- [ ] One config module, schema-validated, frozen
- [ ] No direct env reads elsewhere (lint-enforced)
- [ ] `.env.example` complete and current
- [ ] Secrets tagged and redacted
- [ ] `app config show` with provenance per key
