---
name: fxplat-real-run-plan
description: 2026-10-10 - nothing in fxplat has run on real data; the first real DEV run (R1-R6 tasks + operator runs O1-O4) is TOP priority; plan in Dukascopy docs/REAL_RUN_PLAN.md
metadata:
  type: project
---

As of 2026-10-10 ~130 fxplat tasks are built and tested on SYNTHETIC data only. The DVC DAG
(scripts/stages) is still the Phase-0 stub (5,000 fake ticks, ridge model). Real pieces exist but were
never run on the store: pipeline.sources.store_symbol_data (DEV role), pipeline.phase2.build_dataset,
pipeline.walkforward.run_walk_forward, validation.verdict.

**Why:** Cristian asked "are we close to the final test?" - the honest answer is the first real C1-C18
verdict (DEV 2010-2018, 7 majors) has not happened; it is now top priority, ahead of stubs and UI views.
**How to apply:** spec writer item 3 = R1-R6 (run_events, run_manifest, symbol_stage, research_run, cli,
DVC rewire). Claude runs O1 smoke (EURUSD 3 months) -> O2 one symbol DEV -> O3 7 majors -> O4 VALIDATION,
each under systemd-run MemoryMax (WSL 23 GB shared with agent-ci; free RAM fell to 0.25 GB). Never the
holdout. The run's events.jsonl feeds the UI Run monitor / Model live / P&L views (docs/UI_DESIGN.md §7,
rows 12-14). See [[fxplat-deploy-plan]].
2026-10-10 later: Cristian's vision = a DAY REPLAY SIMULATOR (pick any day, play at chosen speed, watch
go/no-go, orders, balance, close the day, what-if). Added as R7-R9 (fxplat.replay: day_replay, service over
WireGuard, whatif) after R1-R6, and as UI view 0 "Replay" (the centrepiece). Compute-then-reveal, model "as of
that morning" (walk-forward month model). Date rules: DEV free + what-if; VALIDATION logged; holdout closed
until the final test then view-only; forward (>= 2026-10-01) view-only. His "Sep 15 2026" was just an example.
2026-10-11 evening: store PARTITIONED in place (/mnt/d/DukascopyData/{development,validation,sealed_holdout,forward};
flat leftovers in DukascopyData-flat-2026-10-11, raw HF downloads in /mnt/d/DukascopyRaw, provenance labels
restored); hourly update now `fxplat.data ingest update` (script backup .flat-2026-10-11); DEV bars derived
(424 files, ops script state/ops-scripts/derive_dev_bars.py). First real probe EURUSD 2013-2015 via R3: 9,843
events, take-all -0.31 R net, 4 min, 7.8 GB -> R4 must chunk by year; CUSUM hi==0 fires every bar (fix before O3).
2019-2026 gap-fill still open (needed before O4 / final test).
