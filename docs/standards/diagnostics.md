# Diagnostics: export, open, email

Every project ships a **Diagnostics** screen and matching CLI commands. A user who hits
a bug must be able to hand a developer one file, with no terminal.

## The support bundle

A single zip named `support-<app>-<version>-<YYYYMMDD-HHMMSS>.zip`:

```
manifest.json        bundle version, app version, commit, generated-at, correlation IDs included
environment.json     OS, arch, runtime version, locale, timezone, screen size, install path
config.redacted.json effective config with every secret replaced by "<redacted>"
health.json          output of the health + self-test endpoints
logs/*.jsonl         the retained rotating logs (last N days, configurable)
recent-errors.json   last 100 error/fatal lines, flattened for quick reading
db-schema.txt        migration version and schema dump, no row data
notes.txt            free-text description the user typed before exporting
```

Rules: bundles are **redacted by construction** — assemble from a redacting serializer,
never by filtering afterwards. Row data is never included unless the user explicitly
opts in per-export. Bundle creation is itself logged (`diagnostics.bundle.created`).

## Required capabilities

| Action | UI | CLI | API |
| --- | --- | --- | --- |
| Export bundle | **Export diagnostics…** → save dialog | `app diag export [--out PATH] [--days N]` | `POST /api/v1/diagnostics/bundle` |
| Open log folder | **Open logs folder** | `app diag open-logs` | `POST /api/v1/diagnostics/reveal` |
| Open current log | **View log** → in-app viewer | `app diag tail [-f] [--level warn]` | `GET /api/v1/diagnostics/logs?tail=500` |
| Email it | **Email support** | `app diag email [--to ADDR]` | `POST /api/v1/diagnostics/email` |
| Copy summary | **Copy diagnostic summary** (clipboard) | `app diag summary` | `GET /api/v1/diagnostics/summary` |
| Change log level | level dropdown | `app diag log-level debug` | `POST /api/v1/diagnostics/log-level` |

## Email behaviour

Default is **mailto handoff**, not SMTP: build a `mailto:` with a prefilled subject
(`[<app> <version>] <short error>`) and body (summary + correlation IDs), then reveal
the bundle in the file manager so the user attaches it. No credentials, no outbound
service, nothing leaves the machine without a human pressing send.

Optional direct upload (`SUPPORT_UPLOAD_URL`) is opt-in, off by default, and must show
the user exactly what will be sent plus a "review bundle contents" button first.

## In-app log viewer

Tail the current file with: level filter, free-text filter, correlation-ID filter,
"copy line as JSON", "jump to related lines" (same correlation ID), and auto-scroll
toggle. Clicking an error in any toast opens the viewer filtered to its correlation ID.

## Checklist

- [ ] One-click export produces a redacted zip
- [ ] "Open logs folder" works on Windows, macOS, Linux
- [ ] Email handoff prefills subject/body and reveals the attachment
- [ ] Every error toast offers "Copy details" and "Export diagnostics"
- [ ] Bundle contents documented here and reviewable in the UI before sending
