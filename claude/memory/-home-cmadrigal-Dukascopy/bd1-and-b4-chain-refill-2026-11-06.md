---
name: bd1-and-b4-chain-refill-2026-11-06
description: "Spec-writer refill 2026-11-06 ~20:30Z — B-D1 daily model chain 3.189/3.190/3.193 and B4 re-run + full C5 3.191/3.192; left: B-D1 stage (store read) + rerun wiring"
metadata:
  node_type: memory
  type: project
  originSessionId: 6d0b80ee-0920-423a-a597-3a432a0c7e1a
  modified: 2026-11-06T20:46:03.269Z
---

Refill 2026-11-06 20:26-20:50Z (runnable 3.182/3.183/3.186-3.188). Five committed (e8b71f5..d371976):
- 3.189 walkforward.run_walk_forward(embargo_hours=120.0): forwarded to the splitter AND both calibration_split calls.
  GOTCHA: position pins - test_walkforward_noffd pins params[-1] == 'no_ffd', test_walkforward_monotone pins the
  _SplitContext field after ffd_series == 'monotone', test_walkforward_aux pins _fields[-2:] -> the param goes right
  before no_ffd and the field right after risk_pct. walkforward.py 848/850 (two cap pins: _split + _m3).
- 3.190 fxplat.pipeline.bd1_dataset.build_bd1_dataset (deps []) -> Phase2Dataset; proto /tmp/sw3190/s.
- 3.191 fxplat.pipeline.rerun_c5: pool_b4 + c5_with_reruns (PASS only with B4, B5, B-D1 all beaten; B6/B6x excused by PHASE3_PLAN §2).
- 3.192 rerun_b4_stage (deps 3.186, 3.191; B4 scored over the predictions' OOS month span; proto /tmp/sw3192/s).
- 3.193 fxplat.pipeline.bd1_run.run_bd1 (deps 3.189, 3.190; M2, no_ffd, 240 h embargo). Its pinned numbers assume
  3.189's calibration embargo (without it: 110 taken vs 114).
Left: B-D1 stage reading the store per symbol (child) + rerun_run / rerun_cli wiring of B4 and B-D1 into a PENDING C5
(after 3.187/3.188 merge), B-D1 same-bar diagnostic in the report. A task whose depends_on names a not-yet-existing
task id makes the whole `tasks` loader fail - write the dependency first. Next free ids: 3.194, 7.62, 8.15, 9.20.

**Why:** next writer must not redo these and should know the remaining C5 wiring.
**How to apply:** check `git log --oneline -- tasks/` first. See [[b1-rerun-chain-refill-2026-11-06]], [[real-run-task-ids]].
