---
name: fxplat-health-timer
description: 2026-10-14 ~/.local/bin/fxplat-health + user timer every 30 min - phone alerts for what the agent-ci watchdog does not watch (dashboard tasks_error, data download, IB feed, publisher, replay, loop alive)
metadata:
  type: project
---
Added after the dashboard silently showed 0 tasks for hours (the 8767 dashboard ran pre-`builder.tier` agent-ci code
and rejected the new task YAML; restarting agent-ci-dashboard-fxplat fixed it). Checks: /_dash/agentci/status
tasks_error or 0 tasks; fxplat-update failed or ~/fxdata/update.log silent > 3 h; fxplat-ib-gateway/-market/
-publish/-replay, ollama, ollama-gateway active; market-live.json fresh on weekdays; agent-ci auto loop alive
> 45 min. One ntfy alert per new problem (markers in ~/.cache/fxplat-health), "OK" on resolve.

**Why:** the user wants no time lost while the pipeline runs unattended for days.
**How to apply:** after ANY agent-ci loader/schema change, restart the agent-ci dashboards (they keep old code)
and let the watchdog restart the loop. Related: [[watchdog-role]], [[agent-ci-ops-triage]].
