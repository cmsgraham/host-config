---
name: c10-rerun-chain-refill-2026-11-11
description: "2026-11-11 23Z refill - C10 wired via the RE-RUN path (3.240 rerun_c10 / 3.241 rerun_run c10= / 3.242 rerun_cli --c10), not research_run; sources left after it; next free 3.243"
metadata:
  node_type: memory
  type: project
  originSessionId: 338c7a60-40de-46f1-83b4-8c35f653d0ec
  modified: 2026-11-11T23:12:44.861Z
---

Refill 2026-11-11 ~23Z (after the 21Z session was cut off mid C10 fork; that one queued 11.65-11.67 + 16.88/16.89).

- C10 externals decision 2026-11-11 (a) is implemented as a re-run stage, NOT inside research_run (982 of its
  pinned 985 lines, [[strict-lint-1000-line-cap]]): 3.240 fxplat.pipeline.rerun_c10 (EXTERNAL_DEV, B3 null interval
  [2*null_mean - p95, p95], run_c10 with read_pooled's V1 wf kwargs, never checkpoint args), 3.241 rerun_run gains
  `c10=` BEFORE b1 (protected pins: last param 'b6', RerunResult._fields[-1] 'b1'), 3.242 rerun_cli --c10 (opt-in,
  date lock = default_periods().locked_holdout.start = 1640995200000, provenance 'c10' line, early refusal if C10
  not PENDING). Ruff isort: rerun_c5 sorts BEFORE rerun_c10 (natural order).
- Skipped on purpose: family 1/3/4 catalogue CONDITIONS (catalogue.yaml entries need operator-signed mechanism /
  counterparty text, decision D10); big-jumps thresholds (a) = run arguments for the 17.3 CLI, an operator run;
  stop_out (a) keep = no task; final test / IB extra = wait; fondeo item-4 known-answer pack mostly duplicates
  16.88/16.89 tests (hold_breach wiring has no Standard profile to bind yet).
- Next free ids: 3.243, 11.68, 16.90.

**Why:** next writer should not re-derive why C10 is not in research_run, nor re-evaluate the skipped items.
**How to apply:** check new RESOLVED decisions first; the sources above are not open work. See [[refill-log]].
