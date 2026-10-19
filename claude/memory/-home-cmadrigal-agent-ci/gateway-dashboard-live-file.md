---
name: gateway-dashboard-live-file
description: "The gateway dashboard is static files in ~/ollama-gateway/ui/ (index.html, app.css, app.js) read per request; no embedded copy, no restart for UI edits"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9a51435e-4271-433a-aaba-ac31cf3fb017
  modified: 2026-09-28T03:52:21.157Z
---

Since 2026-09-27 (rebuild Wave 0, GW-TEL-005) the gateway UI lives in `~/ollama-gateway/ui/`
and is served per request under `/` and `/ui/*` with `Cache-Control: no-cache`. The old
embedded `DASHBOARD_HTML` constant, the `dashboard.html` override and `--dump-ui` are GONE.

**Why:** the gateway is the front door for every generation, so a restart to see a CSS change
killed in-flight work; a 136 KB string constant also made the rebuild impossible to split.

**How to apply:** edit `ui/*` and refresh; never re-embed anything in gateway.py. Backend
(Python) changes still need `sudo -n systemctl restart ollama-gateway.service`, done only when
`/_dash/data` shows an empty in-flight list (see [[wsl-passwordless-sudo]]). Never rebuild
tables on a timer in the UI (the user's earlier rule still stands). Telemetry lives in
`telemetry.db` beside gateway.py (gitignored).
