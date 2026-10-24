---
name: fxplat-synthetic-known-answer
description: 2026-10-23 operator wants a synthetic known-answer bench (planted edges in calibrated fake markets, turbulent days etc.) BEFORE G3; scope all three parts; design doc being written
metadata:
  type: project
---
Operator 2026-10-23: G3 NOT yet. First: "create days with synthetic data ... test the methodology can identify opportunities successfully, like the turbulent days ... like using the simulator over synthetic data". Chose: cover ALL THREE (Hallazgos/Caleidoscopio scanner, V1 pipeline walk-forward + C1-C18, simulator + K1-K17) and a CALIBRATED generator (DEV 2010-2015 stats only, no outcomes).
Design (agent): ~/agent-ci/docs/research/2026-10-23-synthetic-known-answer-bench.md; drafts ~/Dukascopy/state/proposals/synthetic/TASK-15.N.yaml (unqueued until operator OK). Extends §10.13 (random walk / deliberate leak) with realistic planted edges + traps + null worlds; scores recall per size, false-positive rate, EV bias, empirical MDE vs F2 0.0755R. cuenta_para_N = 0.
Related: [[handoff-2026-10-20]] (G2c done, G3 next), [[fxplat-hallazgos-caleidoscopio]], [[fxplat-turbulence-design]].
