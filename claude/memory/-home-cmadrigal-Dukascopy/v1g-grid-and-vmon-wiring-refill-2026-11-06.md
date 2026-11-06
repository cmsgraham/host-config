---
name: v1g-grid-and-vmon-wiring-refill-2026-11-06
description: "Spec-writer refill 2026-11-06 ~01Z — V1-g label grid 3.164 barriers barrier_spec / 3.165 phase2 / 3.166 symbol_stage, V-MON 3.167 choose_tau monotone / 3.168 walkforward monotone (997/1000 lines, no helper split needed); phase2 keyword-order trap; what is left"
metadata:
  node_type: memory
  type: project
  originSessionId: 1fcc44da-fd26-4d50-80f5-d97671f475d7
  modified: 2026-11-06T01:32:35.784Z
---

Refill 2026-11-06 01:13Z (runnable 3.159/3.160/3.162/7.59/7.61). Scratch /tmp/sw3164 (git-archive prototype + m/ measurements, gen/ generators).
All five committed hold-free: 3.164 0bb3d04, 3.165 5da4865, 3.166 9a18a1b, 3.167 cd204c1, 3.168 5e1e609.
- 3.164 barriers.check_barrier_spec + label_events / label_events_from_source / _event_window(barrier_spec=None): H1 only; spec_for still called (unknown family KeyError). Fixture = test_barriers_windowed loaded via importlib.
- 3.165 phase2.build_dataset(barrier_spec) goes BEFORE cusum_k (right after feature_set). TRAP (round-1 BLOCK): test_phase2_cusum_decay.py:294-295 pins the last three params as cusum_k/time_decay/latency_s, and test_phase2_latency pins latency_s last. So any future phase2 keyword goes before cusum_k. meta 'barrier_spec' {m, limit_hours} last.
- 3.166 symbol_stage(barrier_spec) LAST after 3.162's time_decay; deps 3.165 + 3.162.
- 3.167 decision.choose_tau(monotone): refuses off M2 up front; None means no kwarg.
- 3.168 walkforward run_walk_forward(monotone): _SplitContext last field, `**mono` into fit_window + choose_tau. The prototype measured 997 lines, so no helper split was needed after all.
V-MON is numbered 1/4..3/4. LEFT: V-MON 4/4 + V1-g 4/4 + CUSUM-k/V-TD research_run/variants halves. These wait for 3.159/3.160 to merge: research_run options -> kwargs, checkpoint key, and variants options keys for the grid (target/limit) and V-MON (monotone). Also left: the B5 stale variants row. Next free ids: 3.169, 7.62, 8.15, 9.20.

**Why:** the next writer must not re-measure, and must respect the phase2 keyword-order pins.
**How to apply:** `git log --oneline -8 -- tasks/`; status of 3.159-3.168. See [[cusum-decay-vmon-refill-2026-11-05]], [[strict-lint-1000-line-cap]].
