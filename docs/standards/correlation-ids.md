# Correlation IDs

## The rule

One ID follows a user action from the click, through every log line, every service hop,
every job it enqueues, and back into the error message the user can copy.

## Generation and propagation

- Generated at the **edge of the action**: the UI mints an ID when the user clicks, puts
  it in the `X-Correlation-Id` header, and shows it in any resulting error.
- If a request arrives without one, the server mints it and returns it in the response
  header. Always echo it back.
- Format: ULID (sortable, timestamped, URL-safe). 26 chars.
- Store it in request-scoped context (`AsyncLocalStorage`, contextvars, or equivalent) so
  the logger attaches it automatically. Never pass it through function signatures by hand.
- Background jobs inherit the ID of whatever enqueued them, plus their own `jobId`.
  A scheduled job mints a fresh ID and logs the schedule name.
- Child operations get `parentId` + their own `spanId` if tracing is enabled
  (see [observability.md](observability.md)).

## Required surfaces

| Surface | Requirement |
| --- | --- |
| HTTP request/response | `X-Correlation-Id` header both directions |
| Log lines | `correlationId` field on every line, injected by the logger |
| Error toast | ID shown, with "Copy details" |
| Error envelope | `correlationId` at the top level |
| CLI | `--correlation-id` to set, printed on every error |
| Support bundle | Manifest lists the IDs of the session's errors |
| Debug inspector | Filter logs and network by ID; click to join related lines |

## The payoff

A user says "it failed." They copy `01JB2F9T7K3QX8Z`. A developer runs:

```
app diag tail --correlation-id 01JB2F9T7K3QX8Z
```

and sees the click, the request, every internal step, the failure, and the response — in
order, with no guessing.

## Checklist

- [ ] ULID minted at action start, in a request-scoped context
- [ ] Logger injects it automatically; no manual threading
- [ ] Echoed in response headers and the error envelope
- [ ] Shown to the user on failure and copyable in one click
- [ ] Jobs and sub-requests inherit it
