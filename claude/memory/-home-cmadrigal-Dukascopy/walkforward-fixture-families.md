---
name: walkforward-fixture-families
description: TASK-3.83 walk-forward test fixture uses unregistered families F1/F2; anything reaching run_criteria/baselines needs DON20/RSI2
metadata:
  node_type: memory
  type: project
  originSessionId: 0c49431f-f772-4fb0-8598-847a426fe223
  modified: 2026-10-13T06:46:38.553Z
---

The `_dataset` recipe in tests/pipeline/test_research_run_walkforward.py assigns family "F1"/"F2". The walk-forward ignores family, but `run_criteria` → `baselines._check_families` calls `labeling.barriers.spec_for` and raises ValueError on unknown families. Specs that reuse this fixture past the walk-forward must use registered families ("DON20", "RSI2").

**Why:** TASK-3.84 spec was BLOCKed by spec review for this on 2026-10-13 (fixed in triage commit 6b6b71b).
**How to apply:** When triaging or reviewing specs that copy the 3.83 fixture into criteria/verdict tests, check the family values. Also: child_runner emits timer-driven 'resources' events, so exact event-order assertions must filter them out. Related: [[walkforward-min-train-years-fixture]].
