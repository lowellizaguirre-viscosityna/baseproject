# Observability

Logging ([logging.md](logging.md)) answers "what happened in this one request." This doc
covers the other two: metrics (is it healthy in aggregate) and audit (who did what).

## Metrics

Expose `GET /metrics` in Prometheus text format. Baseline set, required in every project:

| Metric | Type | Labels |
| --- | --- | --- |
| `http_requests_total` | counter | route, method, status |
| `http_request_duration_seconds` | histogram | route, method |
| `api_action_total` | counter | action, outcome |
| `errors_total` | counter | code, component |
| `job_duration_seconds` | histogram | job, outcome |
| `queue_depth` | gauge | queue |
| `upstream_request_duration_seconds` | histogram | upstream, outcome |
| `build_info` | gauge | version, commit |

Never put a user ID, email, or free-text into a label — unbounded cardinality is an
outage. `app metrics` prints them for a quick local look.

## Tracing

If a project has more than one process, it emits OpenTelemetry spans with the correlation
ID as an attribute on every span, so a trace and a log search find the same thing. One
span per API action and per upstream call, minimum. Off by default, enabled by
`OTEL_EXPORTER_OTLP_ENDPOINT`.

## Audit log

Separate from the application log, append-only, never rotated away: `audit.jsonl`.
One line per security- or money-relevant event, with `who`, `what`, `when`, `from`
(IP/device), `result`, and `correlationId`.

Required audit events: login success/failure, logout, permission denied, role change,
secret or config change, data export, destructive operation (delete, void, bulk update),
and anything that moves money or sends a message to a third party.

Audit lines are written **before** returning success, in the same transaction where
possible. They are included in support bundles only with explicit consent.

## Checklist

- [ ] `/metrics` with the baseline set, no high-cardinality labels
- [ ] `build_info` exposes version and commit
- [ ] Audit log separate, append-only, with the required events
- [ ] Correlation ID on spans and audit lines
