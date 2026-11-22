---
name: autonomous-progression-policy
description: "Default to moving forward, not waiting; timed wakeup + recommended default on reversible decisions; only money/deploy/gate/STOP calls wait for an explicit human answer"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 65592fdb-22b6-4529-9491-76c88746cc4c
  modified: 2026-11-22T21:08:03.036Z
---

2026-11-22: Cristian said waiting for his response wastes too much time — add a
timeline and move forward if he doesn't answer.

**Why:** he is against the clock and wants an agile design->build->test loop; a turn
that ends on "waiting for you" is the bottleneck, not the work.

**How to apply:**
- Reversible / internal decisions (approach, naming, whether to build a helper, how to
  validate, which world/config, fixing something found): DON'T ASK. Pick the sensible
  default, state it in one line, proceed.
- A decision worth his steer but still reversible: state the recommended default + a
  deadline and set a ScheduleWakeup at it (default ~20 min, longer for bigger calls).
  If silent at the deadline, proceed with the default and log that it was auto-taken.
- Still wait for an explicit human answer (never auto-proceed) — his existing standing
  rules: merge to main / any deploy; live real money / CRYPTO_LIVE; real-data runs behind
  G2c/G3 ([[subagent-real-data-gates]]); stopping/killing pipeline work (only a person's
  STOP ends a task, [[agent-ci-ops-triage]] [[one-suite-per-task]]); anything the 50%
  usage rule triggers ([[claude-usage-50pct-rule]]). Frame these as phone-ready asks
  ([[phone-approvals-asks]]), not open-ended questions.

Generalizes the dated [[overnight-autonomy-2026-11-08]] / [[overnight-autonomy-2026-11-14]]
grants into a standing default.
