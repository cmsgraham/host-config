---
name: fxplat-eventos-panel
description: 2026-11-10 Eventos view (g j) + fxplat.eventshock.study for NVDA after the CEO scandal; exploration; timer install + UI redeploy left to operator
metadata:
  node_type: memory
  type: project
  originSessionId: 65592fdb-22b6-4529-9491-76c88746cc4c
  modified: 2026-11-11T04:35:25.375Z
---

2026-11-10 operator asked for a panel on the NVDA CEO-scandal drop ("how good or bad fxplat can model it, the
breaking point, suggest the buy"). Built in ~/Dukascopy-claude branch claude/event-shock, ff-merged to main fd95a68.
- Study: `PYTHONPATH=src .venv/bin/python -m fxplat.eventshock.study` (cases in experiments/eventshock/cases.yaml,
  Yahoo daily cached in ~/fxdata-eq/yahoo, out artifacts/eventshock/<case>.json). Exploration, counts toward nothing.
- First result: 1,353 idiosyncratic shocks (120 large caps since 2005), 274 "similar" (already weak before);
  0 of 5 timing rules beat buying at the day-2 close in both halves (pre-2017 / 2017+); similar day-2 entries
  median +6-8 % vs SPY at day 180, hit ~60 %; typical further dip -9.7 % around day 27 (65 % dip >= 5 %).
- UI: Eventos view, exporter export_eventshock.py, publisher entry "eventshock"; deploy/home/fxplat-eventshock.timer.
- The auto-mode classifier denied installing the user timer (persistence); operator must copy the units,
  enable the timer, restart fxplat-publish (new EXPORTERS entry), and run deploy/server/redeploy-ui.sh.
Related: [[fxplat-dashboard-publisher]], [[root-edits-quarantined]], [[ui-no-ai-app-look]].
2026-11-10 23:00: phone alerts added (fxplat.eventshock.alerts, run after each study run): own ntfy topic in
~/.config/fxplat/eventos-ntfy.env (600; never in chat/repo), separate from agent-ci ops topic. Rodrigo's setup sheet:
C:\Users\crist\Documents\alertas-eventos-para-rodrigo.txt. Test: `.venv/bin/python -m fxplat.eventshock.alerts --test`
(PYTHONPATH=src, from ~/Dukascopy). Alerts depend on the fxplat-eventshock timer being installed.
Manual chapter 15 (ui/src/manual/15-eventos.md) documents the method; panel button opens it.
