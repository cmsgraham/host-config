---
name: re7-wiring-and-catalogue-v2-refill-2026-11-14
description: "2026-11-14 ~05Z refill - 11.70 catalogue RE7 grammar / 11.71 scan RE7 wiring (BY only, out of RW) / 11.72 confirm RE7 / 15.50 planted_world E-H-<pair>+E-K / 11.73 catalogue v2 append (signed 99fe91a); ask decision:bench-v4-catalogue sent; next free 3.244 / 11.74 / 15.51 / 16.96"
metadata:
  node_type: memory
  type: project
  originSessionId: 8453828e-7676-45bc-a793-9efd33de4e34
  modified: 2026-11-14T05:32:22.127Z
---

Refill 2026-11-14 ~05Z (main 99fe91a). Both asks rare-edge-rw (a) and rare-edge-bench-v4 (a) were RESOLVED, and the
operator signed approvals/CATALOGUE_V2_DEV.txt + INDICES_DEV.txt (99fe91a).

- 11.70 catalogue.py: RE_PAIR "RE7", GRID_PAIRS = (*PAIRS, RE7) as the pairs domain; PAIRS UNCHANGED (idea_scan.py uses
  it as the idea scans' default universe - adding RE7 there would grow every idea scan's m).
- 11.71 scan.py (959 -> ~978, protected cap 985 in test_hz_scan_helpers): scan.RE, _re_parts, _statistics(re_parts=),
  RE ids excluded from rep (RW), shadow NaN; scan.__all__ pinned (do not export). Proto /tmp/p_re7, test copy
  /tmp/proto_test_hz_scan_re7.py (run_scan e2e by monkeypatching scan._run_jobs).
- 11.72 confirm.py: _re_result = re_summary of ORIENTED per-pair trades; e2e by monkeypatching confirm._symbol_work.
- 15.50 owns the protected tests/synthetic/test_planted_world.py for ONE set-equality assert (LIBRARY vs bench.yaml).
- 11.73 catalogue v2: appends `sed -n 9,285p` of the untracked state/proposals/catalogue-v2/catalogue-v2-conditions.yaml
  (sha 8c66b9fa...), hash 6dc33a53..., 7188 cells; owns catalogue.yaml + 5 protected test files (9 pin failures).

NOT specced (waiting on ask decision:bench-v4-catalogue, rec (a) bench-only catalogue v1 + RE7 next to each POOL7 =
2,856 cells): bench_hz RE7 scoring (_matches RE7 = any planted pair; d = mean over 7 MAJORS of per-pair EV, 0 where
unplanted; edge_ids list) and score.py E-H grouping - score.py is 994/1000 lines, needs a split task first;
bench-v4.yaml; bench_hz/driver catalogue_path from the yaml (bench_hz passes catalogue_path=None = LIVE catalogue,
which becomes v2 = 7,188 cells after 11.73 - bench v3 reruns would change).

**Why:** next writer must not re-survey. **How to apply:** on RESOLVED bench-v4-catalogue -> score.py split, bench_hz
RE7 scoring, bench-v4.yaml (+ catalogue file if (a)). See [[refill-log]].
