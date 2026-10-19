---
name: fxplat-dashboard-publisher
description: "2026-10-13 fxplat.trade went from baked-in SAMPLE fixtures to real data - exporters in ui/scripts, publisher service fxplat-publish pushes changed files every minute to /app/bundle, views poll 60 s"
metadata:
  node_type: memory
  type: project
  originSessionId: 24bbbdc2-d19a-4e73-883e-d7ea2954387e
  modified: 2026-10-13T21:31:51.539Z
---

Until 2026-10-13 the deployed dashboard showed hand-made sample fixtures in most tabs (deploy built with
VITE_BUNDLE_BASE=./fixtures); the user was rightly upset ("not a panel but a static html"). Now:
- exporters ui/scripts/export_{runs,verdict,research,decisions,pnl,overview,risk}.py + make_*_fixture.py
  (market, system, settings, admin, coverage) write FXPLAT_BUNDLE_OUT; ui/scripts/run_labels.json names runs.
- ui/scripts/publish.py (systemd user unit fxplat-publish, --watch 60 s, WorkingDirectory ~/Dukascopy):
  re-runs an exporter on source change or refresh period, pushes only changed files (sha256) to
  /opt/fxplat/web/current/app/bundle via one sudo shell; stage ~/.cache/fxplat/bundle; --repush resends all.
- deploy/server/redeploy-ui.sh builds production (./bundle), drops fixtures, keeps the bundle across deploys.
- useBundle re-reads every 60 s + on focus; missing file -> nodata.<stem> message (no samples in prod).

**Why:** the user expects a working, live dashboard; never ship sample data as if real, and say so early.
**How to apply:** new view/data -> add an exporter + EXPORTERS entry in publish.py, never a hand-pushed file.
Run events are picked up by the runs exporter automatically (no tab edits). Do not edit a shell script while a
running bash instance is executing it (bash reads by offset) - happened with run-o.sh / sync-run-events.sh.
Trap: system python3 imports fxplat from a stale ~/.local .pth (/mnt/c/.../TASK-2.3); always use .venv python.
Related: [[fxplat-run-analysis]], [[ui-no-ai-app-look]].
2026-10-14: Repetición magazine live - server container fxplat-requests (python stdlib, /app/api/replay-requests via a 2nd oauth2-proxy upstream; data /opt/fxplat/requests/replay-requests.jsonl), PC unit fxplat-replay (ui/scripts/replay_service.py + replay_day.py) builds days into the bundle (replay/<PAIR>-<DAY>.json, replay-library.json). Only DEV/warm-up days (bars derived there); holdout refused.
