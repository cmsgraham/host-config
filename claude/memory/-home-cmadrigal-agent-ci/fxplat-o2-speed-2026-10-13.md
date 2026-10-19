---
name: fxplat-o2-speed-2026-10-13
description: "O2 verdict NO_EDGE, tick store moved to ~/fxdata, profiled hotspots and the quick-wins-then-O3-then-ETL plan"
metadata:
  node_type: memory
  type: project
  originSessionId: cc48b68a-726f-4a75-82ee-bb627b7e7f1c
  modified: 2026-10-13T15:38:30.471Z
---

2026-10-13 facts (fxplat, ~/Dukascopy):
- **Store moved** D: (9p, 7x slower) -> `/home/cmadrigal/fxdata` (all 4 partitions, verified); `config/experiment.yaml`
  data_dir_posix points there; CLAUDE.md builder guard covers both paths. D: copy kept as fallback. Raw sources
  (87 GB: Dukascopy_Forex_Tick_Data_2008-2019, DukascopyRaw) stay on D:, not used by runs.
- **O2** (EURUSD DEV, 45 min): NO_EDGE. Take-all -0.31 R/trade, gross ~0; costs 0.275 R (US$6.9 of US$25, mostly
  IB min commission + odd-lot) -> account size is the business question. Model traded 26x in 60 tested months
  (2014-2018; 3-year history rule), choose_tau found no tau in 49/60 windows. Registry row + reports/F3_DEV_* committed.
- **Profile** (py-spy at ~/.local/bin/py-spy): dataset = tick window concatenation ~30 %, per-event labelling,
  crowding n^2 ~15 %; walk-forward = ADF d* re-selection 53 %, LightGBM ~35 %. Design:
  docs/research/2026-10-13-fast-research-engine.md. GPU rejected (small data, determinism, LLM VRAM, GPU-PV freeze).
- **Plan approved:** quick wins (TASK-3.91/3.92 checkpoints+parallel+progress, 3.93 tick fast path, 3.94 crowding)
  -> O3 -> ETL tables. Identity check: `scripts/real_dataset_hash.py --check`.
- **Before O3:** `.wslconfig` already set to memory=48GB (backup .wslconfig.bak-2026-10-13); user runs
  `wsl --shutdown` when told; pause agent-ci loop during O3; dashboard O-runs via state/ops-scripts/sync-run-events.sh.
- Update job cutover: catch-up watcher on PID 891; launcher already points at ~/fxdata.

**Why:** user wants O3 in minutes and a fast experiment loop; these are the decided steps.
**How to apply:** don't start O3 before 3.91-3.94 merge and the WSL restart; never chain background commits on other
jobs' output (they deadlocked 2026-10-13) - commit directly when the merge gate is free. Related: [[fxplat-real-run-plan]].

2026-10-13 12:46: speed tasks 3.91-3.94 DONE on branch claude/o3-speed (~/Dukascopy-o3, not merged). O2 re-run
(--window-workers 20): 10.5 min vs 45 (dataset 7.1, WF 3.2), byte-identical except provenance hashes; peak 24.6 GB
summed. Trap found: spawned workers each opened ~70 BLAS threads -> slower than serial; fixed with threadpoolctl
limits=1 in the worker initializer (67f824e). WSL now 47 GiB.
2026-10-13 13:30: O3 launched 12:55 (unit fxplat-o3, run 20261013-185459-F3-V1-77dd72b, --dataset-workers 7
--window-workers 12, MemoryMax 32G, live in Corridas). 7 parallel datasets took 18-20 min each (7 min solo).
User decision: AFTER O3, optimize the setup from O3's measurements (profile contention, ETL dataset reuse, d*
cache, worker sizing / shared inputs, run defaults + auto-pause pipeline), present ranked plan before building,
then re-run O3 for identity + time. 2019-2026 gap-fill question deferred to then.
