---
name: walkforward-min-train-years-fixture
description: run_walk_forward skips segments without 3 years of event history; short tick fixtures give zero windows
metadata:
  node_type: memory
  type: project
  originSessionId: ae17b720-4ff6-4b04-a260-f3f2c6e9b225
  modified: 2026-10-13T02:05:44.520Z
---

`run_walk_forward` calls `splitters.walk_forward` with its default `min_train_years=3`, and nothing exposes it. Any test fixture for a walk-forward needs events starting at least 3 calendar years before the out-of-sample range. The 66-week tick fixture in test_research_run_datasets.py gives zero windows, so tests built on it check nothing. TASK-3.83 was BLOCKed by spec review for this on 2026-10-13, and triage fixed the spec in 5cbea77. The fix uses a synthetic Phase2Dataset spanning at least 4 years, written via `symbol_stage._write_dataset`. A tick recipe from 2012 also works but takes about 6 minutes.

**Why:** spec writers keep pointing new pipeline tests at the nearest existing fixture.
**How to apply:** when a spec or triage involves walk-forward tests, check the fixture's event span against the 3-year rule. Related: [[leakage-fixture-d1-warmup-limit]].
