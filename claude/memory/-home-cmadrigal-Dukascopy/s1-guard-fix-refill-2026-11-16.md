---
name: s1-guard-fix-refill-2026-11-16
description: "2026-11-16 23:45Z refill: decision 'S1 guard fix' (RESOLVED 2026-11-16, appended 23:43Z) -> 15.73 driver plant_mismatches(result, edges, pooled) judged cells / per-cell reference / n_ef SE; only task; next free 3.244 / 11.74 / 15.74 / 16.98"
metadata:
  node_type: memory
  type: project
  originSessionId: e24b9f48-ff55-4128-8398-875033cc974a
  modified: 2026-11-16T23:52:55.449Z
---

Refill 2026-11-16 ~23:45Z (main cfd2c40, runnable 0). Source: decisions-pending "RESOLVED 2026-11-16 (operator,
question prompt 'Fix guard, then launch S2'): S1 guard fix" (file mtime 23:43Z, found via the mtime-vs-last-refill check).
- 15.73 driver.py: plant_mismatches(result, edges, pooled=()); _locked_run reads <bench_root>/<id>/planted.json +
  bench yaml library E pooled. Judged: RE7 only for score_rare.GROUPS (E-B/E-H/E-K); pair cells skipped for pooled
  edges and two-direction edges (planted.json has no per-direction EV); POOL7 always. RE7 reference = 7 member pair
  cells n-weighted, planted member at edge ev_population_net, UNPLANTED member at its own scan mean_net (*reading:
  oracle_hz is deleted by the driver before the guard). SE sigma/sqrt(n_ef); RE7 sqrt(s^2/n_ef + re_tau2/7).
- Measured on real bench-v7: de-overlapped h-edge-00 -> 0 flags; _overlapping-plants-20261115 -> E-B POOL7 +3.25,
  RE7 +6.19. Prototype /tmp/proto1573/repo (driver 736 lines, test 279).

**Why:** next writer must not re-spec. **How to apply:** after 15.73 merges, launching S2 v4 is operator/Claude
session work, not a task. See [[refill-log]], [[bench-v4-deoverlap-refill-2026-11-15]].
