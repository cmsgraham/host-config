---
name: fxplat-synthetic-known-answer
description: 2026-10-23 operator wants a synthetic known-answer bench (planted edges in calibrated fake markets, turbulent days etc.) BEFORE G3; scope all three parts; design doc being written
metadata:
  type: project
---
Operator 2026-10-23: G3 NOT yet. First: "create days with synthetic data ... test the methodology can identify opportunities successfully, like the turbulent days ... like using the simulator over synthetic data". Chose: cover ALL THREE (Hallazgos/Caleidoscopio scanner, V1 pipeline walk-forward + C1-C18, simulator + K1-K17) and a CALIBRATED generator (DEV 2010-2015 stats only, no outcomes).
Design (agent): ~/agent-ci/docs/research/2026-10-23-synthetic-known-answer-bench.md; drafts ~/Dukascopy/state/proposals/synthetic/TASK-15.N.yaml (unqueued until operator OK). Extends §10.13 (random walk / deliberate leak) with realistic planted edges + traps + null worlds; scores recall per size, false-positive rate, EV bias, empirical MDE vs F2 0.0755R. cuenta_para_N = 0.
Related: [[handoff-2026-10-20]] (G2c done, G3 next), [[fxplat-hallazgos-caleidoscopio]], [[fxplat-turbulence-design]].
QUEUED 2026-10-23 (7fcaace): TASK-15.1..15.11 in tasks/ + approvals SYNTHETIC_CALIBRATION / SYNTHETIC_BENCH (operator "ok go", P1-P13 accepted as a block; S0 storm day + S1 smoke ONLY; S2-S5 need a new decision with S1's measured times). 15.12 panel = draft. Design committed agent-ci 26821a3. Worlds = 7 majors m1 2009-2018 (~26M minutes, ~2.5 GB, 20-40 min build est.). Operator "I trust your judgement": watch 15.2/15.4 (likely too big -> split/escalate), show storm-day results minute by minute when S0 runs. Code findings to follow up: gap fill at stop without 30-min hole (P6 quantify first), C10 runner not wired (P11), K13 extraordinary input (P7), K8 never fires in sim, switches only on H1 closes, scanner floor ~0.26R, MDE 0.085R at C1 alpha (P8).
