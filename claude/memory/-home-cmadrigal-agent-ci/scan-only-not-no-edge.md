---
name: scan-only-not-no-edge
description: an idea with only discovery-scan evidence (0 survivors under BY, or positive but underpowered) is INCONCLUSIVE, never NO_EDGE; NO_EDGE needs a registered study or a clearly negative estimate
metadata:
  type: feedback
---
2026-10-24 idea inventory (merged d88627f + c7d58547/c9b0791): an agent marked 7 literature anomalies and 2 positive Caleidoscopio ideas NO_EDGE because HZ-SCAN-001 had 0 survivors. Wrong: the scan's BY over ~2542 cells has a ~0.26R floor, and n~110 gives se ~0.12R.
**Why:** NO_EDGE removes an idea from Caleidoscopio's seed pool (ideation quotes it as rejected), so a false NO_EDGE silently kills live ideas.
**How to apply:** NO_EDGE only for a registered study verdict (descartadas.yaml) or an estimate clearly below zero (e.g. -0.18R, se 0.05); otherwise INCONCLUSIVE with the numbers. Check any agent-written verdicts against this before merging. Related: [[fxplat-hallazgos-caleidoscopio]], [[fxplat-discarded-strategies-book]].
