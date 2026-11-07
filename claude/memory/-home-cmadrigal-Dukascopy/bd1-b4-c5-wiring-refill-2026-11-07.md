---
name: bd1-b4-c5-wiring-refill-2026-11-07
description: "Spec-writer refill 2026-11-07 ~01:30Z — closes the B4 / B-D1 -> C5 chain: 3.194 bd1_same_bar (TickSource adapter of daily_diagnostic), 3.195 rerun_bd1_stage, 3.196 rerun_run b4=/bd1=, 3.197 rerun_cli --b4/--bd1"
metadata:
  node_type: memory
  type: project
  originSessionId: 88289b1b-d6ae-43fd-9506-8f03bd47bceb
  modified: 2026-11-07T01:38:51.790Z
---

Refill 2026-11-07 01:24Z (runnable 3.183/3.190-3.193; 3.183 gate running). Scratch /tmp/sw3194 (gen/ t319x.py generators +
common.py protected-list builder from TASK-3.192; s/ = prototype = main 2dbc9b0 + the sw3190/sw3192 protos of 3.190-3.193
(rerun_c5 c5_with_reruns re-implemented to the registered detail strings) + these four; m1-m3.py measurements).
- 3.194 fxplat.pipeline.bd1_same_bar.same_bar_from_source (deps []): validates via same_bar_outcomes on EMPTY ticks, then one
  ticks.window(t_exit+1, _session_ends_ms) per target row; bit-identical to the full-array result. Planted tick -> rows 14/16 flip,
  ev_diff 0.0512 flagged. Put in pipeline/ (not labeling/) to avoid the owned-inside-protected-dir trap.
- 3.195 rerun_bd1_stage: bd1_symbol -> (Phase2Dataset, diag) in a child; rerun_bd1(..., oos_start_ms, oos_end_ms) = caller's
  window, manifest seed, pooled.daily_close; all symbol_kwargs BEFORE read_pooled / children.
- 3.196 rerun_run b4=/bd1= AFTER b1; RerunResult NOT changed (test_rerun_run_b1 pins _fields[-1]=='b1' + _field_defaults).
- 3.197 rerun_cli --b4/--bd1 (parser.error if --bd1 without --b4), cost model resolved once, provenance['bd1_same_bar'].
Note: DEV data starts 2010-01-01 and B-D1 needs 252 sessions warm-up + walk-forward min_train_years 3 -> B-D1's first OOS
window is ~2014, not 2013 (inherent, not compensated). Left after this chain: V7 (C11 for M3), V5/V6 exits, V3/V8 operator
decisions. Next free ids: 3.198, 7.62, 8.15, 9.20.

**Why:** the next writer must not redo the C5 chain.
**How to apply:** `git log --oneline -8 -- tasks/`. See [[bd1-and-b4-chain-refill-2026-11-06]], [[real-run-task-ids]].
