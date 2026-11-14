---
name: bench-v4-wiring-refill-2026-11-14
description: "2026-11-14 ~06-08Z refill after RESOLVED bench-v4-catalogue (a): 15.51 bench catalogues v1/v4 files, 15.52 bench_hz RE7 scoring + catalogue_path, 15.53 driver scan:{catalogue,baseline_catalogue} + baseline rescan, 15.54 score.py split-prep (score_rows); left: scorer v4 rows + bench-v4.yaml; next free 3.244 / 11.74 / 15.55 / 16.96"
metadata:
  node_type: memory
  type: project
  originSessionId: cac9ee97-1a4c-4a1e-b1e7-b4ff157c67c1
  modified: 2026-11-14T06:40:40.350Z
---

Refill 2026-11-14 ~06Z (main e65f78a, 11.70 in merge gate). bench-v4-catalogue RESOLVED (a) "Catalogo propio v1+RE7".

- 15.51 config/synthetic/catalogue-bench-v1.yaml (= `git show e65f78a:config/hallazgos/catalogue.yaml`, sha fc9514...)
  + catalogue-bench-v4.yaml (4 header lines + v1 with ", RE7" on the 3 POOL7 pairs lines; 2,856 cells, sha d617c2...).
  Take v1 from e65f78a ALWAYS: 11.73 turns the live file into v2.
- 15.52 bench_hz: run_world(catalogue_path=) / --catalogue (+ catalogue_sha256 only when given); RE7 cell true on ANY
  matching edge, d = re_d = mean over 7 MAJORS of per-pair EV; never a spillover candidate; pooled_kind / edge_ids keys
  only on RE7 cells (test_bench_hz pins CELL_KEYS / RESULT_KEYS exactly).
- 15.53 driver: bench yaml optional `scan: {catalogue, baseline_catalogue}`; planted worlds re-scored into
  <bench_root>/baseline/<id>; pass catalogue_path ONLY when not None (test_driver's Tiers fake has no such kwarg).
- 15.54 score.py 994 -> 868 via new score_rows.py (leaf helpers; re-imported by name, no fxplat imports in it).
Prototype /tmp/p1551 (TASK-11.70 branch + main synthetic files; scratch/m1552.py, scratch/driver.diff).

NEXT (after 15.52 + 15.54 merge): scorer v4 rows - E-H grouping (planted_world.E_H_PREFIX), RE7 cells (score._load
turns RE7 true cells of a `pooled` label into spillover today!), baseline results from <bench_root>/baseline/, a new
criterion for "recall on E-B / E-H / E-K rises vs baseline at the same power level, H3 unchanged" - put new code in a
module that imports score_rows, not score (cycle). Then bench-v4.yaml (v3 + E-H-<pair>/E-K sizes, scan block, the
criterion, gate). S2 v4 run needs approvals/SYNTHETIC_BENCH_S2_V4 from the operator. See [[refill-log]],
[[re7-wiring-and-catalogue-v2-refill-2026-11-14]].
