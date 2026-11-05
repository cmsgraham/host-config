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

2026-11-05 sweep (operator asked for visibility over all moving parts) - added to fxplat-health (backup copy
fxplat-health.bak-20261105): `datastale` = each config.json symbol's newest stored day >1 business day behind
(replaces the useless is-failed check: `ingest update` exits 4 on ANY quality rejection, every run; XAGUSD is NOT in
the updater's list - its Oct files were a one-off); `backup` = no "Finished git-backup" in 3 h; `unmanaged` =
/non-systemd processes >6 h or >4 GB (editor, shells, ssh mux, the auto loop excluded); daily "still open" reminder
per marker unless `~/.cache/fxplat-health/<key>.ack` exists (ack removed on resolve). paperlatch acked: operator
leaves sim-v4 halted at K3 (-7 %) as a result. Moved into units the same day: fxplat-dashboard.service (8767, was
hand-run), watch-theft-addr.service (was a dead session's scratchpad loop). Long jobs from now on: systemd-run.
