# Logging

## Rules

- One logger, created once, imported everywhere. No `console.log` / `print` in
  committed code — lint rules enforce this.
- Logs are **structured JSON**, one object per line (JSONL). Humans read them via the
  log viewer or `jq`; machines never have to parse prose.
- Every log line carries: `ts`, `level`, `event`, `correlationId`, `component`, and a
  `data` object. Messages are for humans; `event` is the stable machine key.
- Never log a secret, token, password, full card number, or raw request body of an auth
  endpoint. Redaction is applied by the logger, not by callers.
- An error that is caught and handled is still logged at `warn` or above. A caught and
  swallowed error is a bug.

## Levels

| Level | Use for | Shipped to support bundle |
| --- | --- | --- |
| `trace` | Per-call entry/exit, payload shapes. Off by default. | Only in debug mode |
| `debug` | Decision points, cache hits, chosen code path | Yes |
| `info` | State changes a user caused or would care about | Yes |
| `warn` | Recovered failure, retry, deprecated path, degraded mode | Yes |
| `error` | Operation failed; user sees a failure | Yes |
| `fatal` | Process cannot continue | Yes |

Default level: `info` in production, `debug` in development. Override with
`LOG_LEVEL`. Level is changeable **at runtime** via `POST /api/v1/diagnostics/log-level`
so a user can reproduce a bug without a restart.

## Line shape

```json
{
  "ts": "2026-10-01T14:03:22.418Z",
  "level": "error",
  "event": "invoice.submit.failed",
  "correlationId": "01JB2F9T7K3QX8Z",
  "component": "api.invoices",
  "durationMs": 412,
  "userId": "u_8821",
  "data": { "invoiceId": "inv_55", "attempt": 2 },
  "error": { "code": "E_PAYMENT_DECLINED", "message": "card declined", "stack": "..." }
}
```

## Where logs go

- **stdout** always — JSONL. This is the contract for containers and the CLI.
- **Rotating file** at the per-OS app-data path, so the user can export without a
  terminal: `logs/app-YYYY-MM-DD.jsonl`, 10 MB per file, 14 files kept, gzip on roll.
  Resolve the directory with one helper (`logDir()`); never hardcode a path.
- Optional sink (HTTP collector) is configuration, never code.

## Required events

Log at least these, with these exact `event` keys, in every project:

- `app.start` / `app.stop` — with version, commit, config fingerprint (not values)
- `http.request` — method, route, status, `durationMs`
- `api.call.start` / `api.call.end` — for every endpoint, with correlation ID
- `ui.action` — every user-initiated action the UI sends to the API
- `job.start` / `job.end` / `job.failed`
- `unhandled.rejection` / `uncaught.exception` — then exit non-zero
- `config.loaded`, `migration.applied`, `auth.denied`

## Checklist

- [ ] Logger is a singleton with redaction built in
- [ ] JSONL to stdout and to a rotating file
- [ ] `LOG_LEVEL` env var plus runtime endpoint
- [ ] Lint rule bans `console.*` / `print`
- [ ] Unhandled rejection and uncaught exception handlers installed
- [ ] Log directory is created on first run and documented in the README
