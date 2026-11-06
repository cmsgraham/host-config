---
name: m3-vaux-vffd-refill-2026-11-06
description: Spec-writer refill 2026-11-06 ~09Z — V7 M3 / V-AUX / V-FFD runner halves 3.174-3.179; walkforward split; REGRESSION_KINDS keeps variants refusing M3; position-relative signature pins
metadata:
  node_type: memory
  type: project
  originSessionId: 7c76b62f-dc6b-486d-bd74-df44e1ef7dff
  modified: 2026-11-06T09:13:41.758Z
---

Refill 2026-11-06 08:50Z (runnable 3.171-3.173/7.59/7.61). Scratch /tmp/sw3174 (gen/ t31xx.py generators + common.py protected-list builder; s/ = git prototype of all six; m1-m8.py measurements). All six committed hold-free:
- 3.174 fxplat.models.regression (M3_PARAMS literal = M2 + huber/alpha 1.0, clip [-1.5, 4], fit_m3 cost -1, fit_aux, predict_regressor, aux_veto > 0.8). Must NOT import metalabel (3.175 makes metalabel import it).
- 3.175 metalabel fit_window/predict_window kind 'M3' (fit rows only, Calibrator none, p NaN, ev direct); choose_tau works unchanged. Owns test_metalabel.py for the 'M3' -> 'M4' unknown-kind literal.
- 3.176 walkforward split: FFD helpers -> walkforward_ffd.py (999 -> ~788 lines). ffd_series def, _new_ffd_pool and the worker checks STAY (tests patch wf.ProcessPoolExecutor; F811 on imported ffd_series). `global _FFD_CODE` -> functools.cache _ffd_code() (else lint-new counts a NEW PLW0603).
- 3.177 walkforward kind M3 via REGRESSION_KINDS = ('M3',); KINDS unchanged so variants keeps refusing M3 (V7 stays needs-build until C11 / decisions handle NaN p_cal). Kelly refused for M3.
- 3.178 run_walk_forward(mae_target=None) V-AUX veto after tau (target = -labels mae_R, which is <= 0). Owns test_walkforward_monotone.py: its params[-1]=='monotone' pin made position-relative (review BLOCK caught it).
- 3.179 run_walk_forward(no_ffd=False) -> NO_FFD_NOTE in KNOWN_GAP_NOTE's place.
Walkforward caps pinned at 850 by test_walkforward_split / _m3 / _aux. NEXT: research_run halves (pass -mae_R, no_ffd + note check, kind M3) need a research_run split first (989/995 after 3.171); V7 needs a C11-for-M3 reading (maybe operator ask). Next free ids: 3.180, 7.62, 8.15, 9.20.

**Why:** the next writer must not redo the split or re-measure, and must keep new walkforward keyword pins position-relative.
**How to apply:** `git log --oneline -8 -- tasks/`. See [[variants-wiring-refill-2026-11-06]], [[strict-lint-1000-line-cap]].
