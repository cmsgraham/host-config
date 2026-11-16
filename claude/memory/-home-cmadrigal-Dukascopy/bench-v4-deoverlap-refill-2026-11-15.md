---
name: bench-v4-deoverlap-refill-2026-11-15
description: "2026-11-15 ~22:40Z refill: decision 'bench v4 worlds de-overlapped + exact RE7 spillover check' -> 15.70 plant de-overlap / 15.71 bench_hz RE7 oracle candidates / 15.72 driver S1 plant_mismatch guard; next free 3.244 / 11.74 / 15.73 / 16.98"
metadata:
  node_type: memory
  type: project
  originSessionId: 3d9b791f-6514-4c75-b757-0ea2e02c282b
  modified: 2026-11-15T22:50:37.357Z
---

Refill 2026-11-15 22:39Z (main fa3cd83, runnable 0). Source: decisions-pending "RESOLVED 2026-11-15 (operator, question
prompt 'Stop, fix, relaunch faster')", appended 18:35Z, one minute AFTER the 18:34Z repeat refill, so that refill
missed it. Lesson: compare the decisions-pending mtime to the previous refill's time, not only "new RESOLVED".
- 15.70 plant.py: _deoverlap inside planted_events (every planting path goes through it); D1 specs only, specs
  order (= LIBRARY order for every bench-v4 world, checked), day = dec_ts_ms // 86_400_000; skipped rows dropped;
  table.attrs["n_overlap_skipped"] only when >= 2 D1 specs, so test_plant test_k (columns) / test_l (exact dict)
  hold. New test file test_plant_overlap.py.
- 15.71 bench_hz.py: RE7 cells become oracle candidates (_cell_spec MAJORS like POOL7), run_world drops
  re_spillover, every RE7 cell gets spillover_rule 'oracle' and re_spillover skips marked cells. A result-level key
  was rejected: test_bench_hz.py pins RESULT_KEYS. Owns test_bench_hz_re7.py (test_a DELTAS + REKS, test_m replaced).
- 15.72 driver.py: plant_mismatches(result) on true reportable cells, |mean_net - d| > 3 * sigma_R/sqrt(n);
  S1 edge worlds only (world.planted non-empty), RAN or DONE; status plant_mismatch + stop; main exit 6.
Prototype /tmp/proto1570 (all three changes; existing tests green).

**Why:** the next writer must not re-spec this chain. **How to apply:** after these merge, re-running S1 on
h-edge-00 and relaunching S2 is operator/Claude-session work, not a task. See [[refill-log]],
[[re7-ruler-fixes-refill-2026-11-15]].

Repeat 2026-11-16 00:11Z (main d16c578, runnable 1 = 15.72 BUILDING): EMPTY. decisions-pending mtime 18:35Z (< 22:39Z
refill), newest approvals = SYNTHETIC_BENCH_S2_V4 (11-14, used), ops cases 0, no open asks, 12.6 NOTE still unanswered.
Only open sources left are person-held tasks; nothing to spec until the operator answers / resolves something new.
