---
name: fxplat-sensitivity-goal
description: "2026-10-31 operator: fxplat must capture every good opportunity, not only the loud ones; the synthetic bench is only the ruler (not a bench-test company); keep bench work lean"
metadata:
  node_type: memory
  type: user
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-10-31T19:20:33.111Z
---

Operator, 2026-10-31, after S2 v1 showed Hallazgos only finds edges >= ~+0.15 R on frequent patterns
and ~+0.5 R on rare ones: "main focus is test and improve fxplat and not become a bench test company"
and "fxplat [must] capture every good opportunity and not only the ones who come with whistles and flags".

**Why:** the scanner is honest (0 false confirmations, 0/24 traps) but short-sighted; real edges after costs
are likely +0.05..+0.15 R, mostly below its bar.

**How to apply:** keep bench work to the minimum that measures fxplat changes (lean v2 in
agent-ci docs/research/2026-10-31-synthetic-bench-s2-v2.md §8b). Spend effort on fxplat sensitivity
(testing design: focused/weighted hypotheses, pooling, two-stage screening, cheaper-broker costs), and accept a
sensitivity change only when the frozen bench shows higher recall at the same size with null/trap verdicts
unchanged. Bench runs share the machine with the pipeline (guardrails) or go overnight; never pause fxplat
building for the bench. 2026-10-31 analysis (agent-ci docs/research/2026-10-31-hallazgos-sensitivity.md, no new run): judging on IB
costs (0.21 R/trade) hides most edges; IC Raw (0.07 R) catches 2.5x more planted edges at 0 % noise; focused
pre-registered idea lists add 2-4x. Operator DECIDED: Hallazgos judges on IC Raw (IB reported); build the
registered idea-list path (spec back for approval first). Batch size: no gain; POOL7 pooling already exists.
Runs cost ~18 h: decide and pre-flight (~2 h) first, ONE full run per frozen design, analyse offline after.
Related: [[fxplat-synthetic-known-answer]], [[research-before-workaround]].

2026-11-13 (S2 v3, E-B result): operator: "Rare = good and can be where the good opportunities resides too". A +0.6 R
rare-regime edge (turbulent-USD days, 55-98 events per pair) is invisible per pair ('datos insuficientes') and only shows
pooled. **How to apply:** treat rare conditions as a priority, not noise: pooled / partially pooled cells (multilevel /
empirical-Bayes shrinkage across pairs), event-study style cross-asset looks (like Eventos), and an honest bench power for
small-n edges. Never discard a rare idea as NO_EDGE for lack of events ([[scan-only-not-no-edge]]).
