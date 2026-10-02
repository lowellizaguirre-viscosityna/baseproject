# Health and self-test

## Endpoints

| Endpoint | Answers | Auth |
| --- | --- | --- |
| `GET /api/v1/health` | Is the process alive? Cheap, no dependencies. | none |
| `GET /api/v1/ready` | Can it serve traffic? Checks DB, cache, upstreams. | none |
| `GET /api/v1/version` | Version, commit SHA, build time, runtime version | none |
| `POST /api/v1/selftest` | Runs real end-to-end checks and reports each | yes |

CLI: `app health`, `app health --verbose`, `app selftest`.

## Readiness response

```json
{ "ok": false, "status": "degraded",
  "checks": [
    { "name": "database",  "ok": true,  "durationMs": 4 },
    { "name": "cache",     "ok": true,  "durationMs": 1 },
    { "name": "payments",  "ok": false, "durationMs": 5001,
      "error": { "code": "E_TIMEOUT", "message": "no response in 5s" } }
  ],
  "version": "1.4.2", "commit": "a91f3c2", "uptimeSec": 81234 }
```

Partial failure reports `degraded` and names the failing dependency — never a bare 500.
The UI surfaces degraded state as a banner, not a mystery.

## Self-test

`selftest` exercises the real paths a user would: write and read back a scratch record,
round-trip a queue message, call each upstream's own health route, confirm the log file
is writable, confirm the diagnostics bundle can be produced. It is safe to run in
production, idempotent, and cleans up after itself. Its output is included in support
bundles.

## Checklist

- [ ] All four endpoints exist, with CLI equivalents
- [ ] Readiness names each dependency and its latency
- [ ] Version reports the real commit SHA from the build
- [ ] Self-test is production-safe and self-cleaning
- [ ] Degraded state is visible in the UI
