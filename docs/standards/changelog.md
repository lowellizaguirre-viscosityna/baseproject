# Changelogs (dual, always current)

Every change updates **both** changelogs in the same commit. A commit that touches
behaviour and not the changelogs fails CI.

| File | Audience | Voice |
| --- | --- | --- |
| [`CHANGELOG.md`](../../CHANGELOG.md) | Users, stakeholders, release notes | Plain language, outcome-focused, no file names |
| [`CHANGELOG-DEV.md`](../../CHANGELOG-DEV.md) | Developers, future maintainers, agents | Specific: files, endpoints, migrations, env vars, flags, rationale |

Both use [Keep a Changelog](https://keepachangelog.com) structure with an `## [Unreleased]`
section at the top that release promotes to a version heading.

## Public entry

Short, user-visible, no internals. If a change is invisible to users, it does not belong
here at all — it belongs only in the developer log.

```markdown
## [Unreleased]
### Added
- Invoices can now be voided with a reason, and the reason appears on the invoice history.
### Fixed
- Submitting an invoice twice quickly no longer creates a duplicate.
```

## Developer entry

Everything a maintainer needs to understand and safely build on the change.

```markdown
## [Unreleased]
### Added
- `POST /api/v1/invoices/:id/void` — action `invoice.void`, handler
  `server/routes/invoices.ts:voidInvoice`. CLI: `app invoices void <id> --reason R`.
  Audit event `invoice.voided`. Contract tests in `tests/contract/invoices.void.test.ts`.
### Changed
- Submission is now idempotent via the `Idempotency-Key` header; keys are retained 24h in
  `idempotency_keys`. **Why:** duplicate submits from double-clicks (#214).
### Migrations
- `0042_add_void_reason.sql` — adds nullable `invoices.void_reason`. Reversible.
### Config
- New: `IDEMPOTENCY_TTL_HOURS` (default `24`). Added to `.env.example`.
### Flags
- Added `newInvoiceEngine` (default off, expires 2026-12-01).
### Breaking
- None.
### Ops
- No action required. Rollback: revert migration 0042 after reverting the release.
```

Developer sections, in order: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`,
`Security`, `Migrations`, `Config`, `Flags`, `Breaking`, `Ops`. Omit empty ones.

## Automation

The point is that this is not remembered, it is enforced.

1. **Commit template** (`.gitmessage`) prompts for both entries; `commit-msg` hook parses
   trailers (`Changelog: …`, `Changelog-Dev: …`) and appends them to `Unreleased` if the
   files were not edited by hand.
2. **`make changelog`** opens both files at the `Unreleased` section.
3. **`app changelog add --public "…" --dev "…" --section Added`** appends correctly
   formatted entries, so scripts and agents never hand-format markdown.
4. **CI gate** (`scripts/check-changelog.sh`): if the diff touches `src/`, `server/`,
   `api/`, or `migrations/`, both changelogs must also change. Bypass only with a
   `[skip changelog]` marker in the commit body, which is reported in the PR summary.
5. **Release** promotes `Unreleased` in both files, inserts the version and date, and
   generates release notes from the public file.

## Agent rule

When an agent makes a code change, updating both changelogs is part of the change, in the
same commit — not a follow-up. The developer entry must name the endpoints, files,
migrations, env vars, and flags touched, and say **why**. Prefer
`app changelog add` over editing markdown directly.

## Checklist

- [ ] `CHANGELOG.md` and `CHANGELOG-DEV.md` exist with `Unreleased` sections
- [ ] `app changelog add` implemented
- [ ] `commit-msg` hook handles trailers
- [ ] CI gate blocks behaviour changes without changelog updates
- [ ] Release promotes both and generates notes from the public one
