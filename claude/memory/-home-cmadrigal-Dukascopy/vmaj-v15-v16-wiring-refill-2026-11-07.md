---
name: vmaj-v15-v16-wiring-refill-2026-11-07
description: "Spec-writer refill 2026-11-07 ~21Z: 3.211 V-MAJ registry, V15 3.218 phase2 info_theta / 3.219 symbol_stage info_bars, V16 3.220 store quote volume / 3.221 phase2 info_weight / 3.222 stage 'activity'; left = research_run/variants wiring of V15/V16 (after 3.216), V5/V6 chain (3.214 re-review after 3.213)"
metadata:
  node_type: memory
  type: project
  originSessionId: 7854a5b5-eaef-4ed6-ba06-affc48be67ec
  modified: 2026-11-07T21:13:40.121Z
---

Refill 2026-11-07 20:40-21:15Z (runnable 3.208/3.210/3.212/3.213/3.217). All six queued, review OK, committed (8e3207e..8b9a619).

- 3.211 V-MAJ registry: WF_KEYS gains train_symbols BEFORE monotone (test_variants_monotone pins WF_KEYS[-1]); RunOptions field 18; PAIR_RE spelling check only; research_run.py untouched (wf_kwargs flows through). Pins moved: two Counters -> needs-build 9 / runner-ready 12, ("V-MAJ") -> ("B6"), test_variants_ffd_aux WF_KEYS.
- 3.218 phase2 info_theta (V15): SIGNATURE TRAP - test_phase2_cusum_decay / _barrier_spec / _latency pin the tails (latency_s last, build_dataset [-5:] feature_set..latency_s) and 3.214 pins exit_rule IMMEDIATELY before feature_set -> info_theta goes right after extra_label_class (build_dataset) / after extra_signals (sample_events). First review BLOCKed on this.
- 3.219 symbol_stage info_bars='volatility' placed after hallazgo (3.215 owns the latency_s->barrier_spec slot); θ code inline broke C901 (16 > 15) -> helper _info_theta_kwargs.
- 3.220 sources.store_minute_quote_volume (deps [], runnable); 3.221 phase2 info_weight; 3.222 stage 'activity' (moves 3.219's INFO_BARS + 'activity'-refused pins).
- Research runs: stage start = 2010-01-01, train_end = 2012-12-31, so "rows closed by train_end" = the decision's first training window.
- Stale text: 3.218/3.219 objectives say the variants piece is "TASK-3.220" - it is not (3.220 = V16 reader); harmless "Not here" line.

LEFT: V15/V16 research wiring = research_helpers._DS_DEFAULTS + research_run.build_datasets(info_bars=) (research_run at 975 cap; 3.216 raises it to 980 - write after 3.216 lifts), then variants DATASET_KEYS info_bars + yaml V15/V16 dataset rows. V5/V6: re-review 3.214 after 3.213 merges. Next free id 3.223. Prototypes /tmp/sw3211, sw3218, sw3219, sw3220, sw3221, sw3222.

**Why:** next writer should finish these chains, not re-survey. **How to apply:** see [[vmaj-v5v6-v15v16-refill-2026-11-07]], [[real-run-task-ids]].

TRIAGE 2026-11-07 23:50Z: 3.210 failed max_attempts because its spec said train_symbols LAST - run_walk_forward tail is pinned too (noffd [-1]=='no_ffd', embargo [-2:]==['embargo_hours','no_ffd'], aux monotone->mae_target, monotone on_window->monotone). Fixed fd7cd31: after mae_target, before embargo_hours. Same signature-tail trap as phase2 (3.218).
