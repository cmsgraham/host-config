---
name: fxplat-run-analysis
description: "every fxplat Corrida (O-run, probe) gets a written analysis from Claude when it ends - ui/public/fixtures/runs/<id>.analysis.json, shown in Corridas"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 24bbbdc2-d19a-4e73-883e-d7ea2954387e
  modified: 2026-10-13T17:22:31.306Z
---

2026-10-13 Cristian asked: each corrida gets a text analysis from Claude with its results - a summary of what
happened, what went well and wrong, findings good or bad. Built in 08c8d78: `runs/<run>.analysis.json`
(schema run-analysis/1: headline{es,en,tone}, summary, good[], bad[], findings[{tone}], next[]), loaded by
naming convention in RunMonitorView, so a new one can be pushed to the server like events (no rebuild).
O2, O1 and probe analyses written.

**Why:** he reads results in the dashboard, not in F3 reports or chat.
**How to apply:** when any O-run ends (O3 next), write its analysis in es + en from the run files and F3 report
(every figure traceable), commit it under ui/public/fixtures/runs/, and publish it the same way
state/ops-scripts/sync-run-events.sh publishes events. No personal names in the text ([[fxplat-ui-no-names]]).
A UI redeploy publishes the repo's fixtures over the server's - keep the repo's run files current first.
Related: [[fxplat-real-run-plan]], [[fxplat-o2-speed-2026-10-13]].
