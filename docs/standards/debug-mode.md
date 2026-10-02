# Debug mode

## Purpose

When a developer (or a user on a support call) turns on debug mode, the UI explains
itself: every panel says what it is, every control says what it calls. "The Submit button
is broken" becomes "`POST /api/v1/invoices` returned `E_VALIDATION` with correlation ID
`01JB2F…`" without anyone opening devtools.

## Turning it on

- `?debug=1` in the URL, or `--debug` on launch, or `DEBUG_UI=1`
- Keyboard toggle: `Ctrl/Cmd+Shift+D`
- A hidden gesture for shipped builds (click version number 5×) so support can enable it
  on a user's machine
- State persists per session and is visibly indicated — a persistent badge, so nobody
  ships screenshots wondering why there are labels everywhere

## What it renders

**On every panel/region:** a small corner badge with the component ID and source path.
```
[InvoiceForm · src/components/InvoiceForm.tsx]
```

**On every interactive control:** a hoverable annotation giving
action key → method + path → handler. Example for a Submit button:
```
action:  invoice.submit
calls:   POST /api/v1/invoices
handler: server/routes/invoices.ts:submitInvoice
state:   idle   last: 412 ms, 200 OK, cid 01JB2F9T7K3QX8Z
```

**A dockable inspector panel** with tabs:

| Tab | Contents |
| --- | --- |
| Network | Every API call this session: action, method, path, status, duration, size, correlation ID. Click to see request/response bodies (redacted). |
| Logs | Live tail of the structured log, filtered to this session's correlation IDs |
| State | Current client store snapshot, copyable as JSON |
| Config | Effective client config + API base URL + build commit |
| Actions | The full action registry; each row has **Call now**, **Copy as CLI**, **Copy as curl** |
| Flags | Feature flags and their current values, with local overrides |

**Per-control context menu** (right-click in debug mode): Copy action key, Copy as curl,
Copy as CLI, Open handler in editor (`vscode://file/...` link), Show last response.

## Implementation rule

Annotations come from the action registry and a single `useDebug()` / `debugProps()`
helper — never hand-written per component. A control without a registered action key
renders a red badge `⚠ unregistered action`, which makes the gap impossible to miss.

```tsx
<Button {...debugProps('invoice.submit')} onClick={submit}>Submit</Button>
```

Debug chrome is tree-shaken or lazy-loaded so production bundle size is unaffected, but
the **capability ships in production builds** — support needs it on real installs.

## Checklist

- [ ] Toggle via URL, keyboard, env var, and hidden gesture
- [ ] Component badges on every panel
- [ ] Action/endpoint/handler annotation on every control
- [ ] Inspector with Network, Logs, State, Config, Actions, Flags
- [ ] Copy as curl / Copy as CLI on every action
- [ ] Unregistered controls visibly flagged
- [ ] Debug state visible so it is never on by accident
