---
name: fxplat-bench-smoke-feasibility
description: "Why fast \"mini\" synthetic-bench runs don't exist via --weeks; the only agile loop is generate-once (full-span) / scan-many"
metadata:
  node_type: memory
  type: project
  originSessionId: 65592fdb-22b6-4529-9491-76c88746cc4c
  modified: 2026-11-22T23:36:20.623Z
---

Investigated 2026-11-22 while trying to build a fast validation smoke for the S2
synthetic bench (rare-edge R2 block pools). Hard-won mechanics:

- **The scan reads a FIXED 2015–2018 DEV partition.** `--weeks N` truncates
  *generation* to the first N weeks starting 2009, so a short world has no data
  in the scan window: weeks=26 → every cell n=0 (empty scan), weeks=156 (→2012)
  → `ValueError: USDJPY: no m1 bars in the DEV partition for 2015-01-01..2018`.
  **A world must be generated full-span (2009→2018) to have any trades.** There
  is no `--weeks` speed shortcut for a bench scan.
- **Planted (edge) worlds run `planting: {calibration: replant}`**, which
  re-simulates the oracle's trade outcomes per planted edge (py-spy:
  `calibrate_replanted → replant_events → scan_view_ev → trade_outcomes →
  minute_ticks`). A latin-square edge world plants ALL ~10 conditions at once →
  worst case; one such world hung >3 h / 15 GB RSS and never reached the scan.
  This replant is the real days-long bottleneck, not scanning.
- **Null worlds skip replant** (no planting) → the cheapest full-span world, and
  the scan still finds trades (conditions trigger on the calm market at ~0 EV),
  so block cells (COMMODITY/HAVEN) aggregate real member trades on a null world.
- **Therefore the only agile loop is generate-once (full-span) / scan-many.**
  Everything an R2-type change touches (catalogue, scoring, confirm, BY, RW
  routing) lives in the SCAN layer, which re-runs against a saved world store in
  seconds–minutes. The driver DELETES the world store after scoring, so a reusable
  smoke must snapshot the store (e.g. ~/fxsynth/smoke-lib/) before cleanup, or call
  bench_hz.run_world / scan.run_scan against a kept store with a fresh bench_root.
- A fresh bench_root needs the existence-only approval markers copied in
  (SYNTHETIC_BENCH.txt, SYNTHETIC_BENCH_S2.txt, and **HALLAZGOS_DEV.txt** — the
  scan gate; a missing one fails the world, not the whole run). Use
  `--approvals-dir <throwaway>` to leave the real approvals/ gate untouched.

Smoke plan built: config/synthetic/bench-smoke-r2.yaml (v4 plan, catalogue v5 vs
v4 baseline). Checker: reuse fxplat.synthetic.score_rare (kind_of / finds /
rare_table) so the check can't drift from the scorer. Catalogue plumbing verified
instantly: v5 adds 84 (condition,pair) slots on COMMODITY/HAVEN; v4 has 0.

2026-11-22 built + proved end to end (docs/bench-smoke.md; commits e8b8acc,
4f8ca59). Two agile loops now exist:
- PLUMBING/H3: kept NULL store ~/fxsynth/smoke-lib/h-null-00; rescan ~12 min.
- RECALL: kept PLANTED store ~/fxsynth/smoke-lib/ek-edge-00 (world h-edge-00,
  seed 20262101, 4.6 GB). Built with tools/bench_make_planted.py from
  config/synthetic/bench-smoke-ek.yaml (library cut to ONLY E-K so the replant
  is light: ~85 min vs the all-10 world that hung >3 h). Rescan v5+v4 with
  tools/bench_rescan.py, check with tools/bench_smoke_check.py <bench_root> h-edge-00.
- GOTCHA (4f8ca59): bench_hz refuses to score a world with a calibration whose
  sha256 != the store marker's. A DRIVER/planted store uses the yaml's MEASURED
  calibration (not the default a bare WorldSpec gives), so bench_rescan now reads
  the store's ground_truth/calibration.json to build the matching spec. A null
  store from the `store` CLI uses the default calibration, which is why the first
  (null) smoke worked with a bare spec.
- Result: v5's COMMODITY block pool FINDS the planted +0.50 R E-K (recall
  E-K: v5 1/1 {POOL7:1, COMMODITY:1} | v4 1/1 {POOL7:1, COMMODITY:0}). CAVEAT:
  +0.50 R on 3 pairs also surfaces via POOL7, so this does NOT show v4 missing it
  nor H7's "strictly higher total" -- those still need the full S2 run.
Related: [[fxplat-synthetic-known-answer]] [[fxplat-sensitivity-goal]]
