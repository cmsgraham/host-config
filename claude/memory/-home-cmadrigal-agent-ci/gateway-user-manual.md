---
name: gateway-user-manual
description: "The gateway console's user manual is a Claude Docs doc (8 tabs, one per page), written 2026-09-29 from ui/app.js and health.py; update it when the UI changes"
metadata:
  node_type: memory
  type: reference
  originSessionId: bdd81c4e-aab0-404b-852e-e2612ce47dd1
  modified: 2026-09-29T13:58:01.777Z
---

The user manual for the gateway console lives at
https://claude.ai/artifact/5kijsJtne4n4Q9CMSWGEfy (Claude Docs project
`267f4266-b865-4c03-ba59-415c2a4785f0`). Tabs: Start here (layout, status vocabulary,
glossary, limits, request-lifecycle diagram), Overview, Activity, GPUs, agent-ci, Models,
Logs, Settings. Every section, column and threshold was taken from `~/ollama-gateway/ui/app.js`,
`components.js`, `health.py` and `telemetry.py` as of 2026-09-29.

**How to apply:** when a page of the console changes (see [[gateway-rebuild-2026-09-27]],
[[gateway-dashboard-live-file]]), edit the matching tab through the Docs connector rather than
writing a new manual. Found while writing it and still true then: Settings' "Backend processes"
and "autostart task" rows read Windows tools (PowerShell, schtasks) and show `none` /
`not found` inside WSL; the Activity page hard-codes "1 generation slot"; README.md still opens
with the Windows-era port 11500 instructions.
