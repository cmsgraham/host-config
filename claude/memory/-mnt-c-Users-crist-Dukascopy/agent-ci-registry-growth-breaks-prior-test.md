---
name: agent-ci-registry-growth-breaks-prior-test
description: "TASK-2.3 — adding families to the registry broke TASK-2.2's pinned test_families.py (outside owned_paths), so suite-green could never pass for the builder"
metadata:
  node_type: memory
  type: project
  originSessionId: 8e68c41e-0ed0-438f-bc62-f8f59c4f42a3
  modified: 2026-10-05T13:46:36.200Z
---

When a task extends a shared registry (e.g. `FAMILIES`/`family_ids()`), an earlier task's tests may pin the old list or call every registry entry with the old signature. In TASK-2.3, `tests/sampling/test_families.py` asserted 6 ids and called non-DON families as `f(c)`. That file was not in TASK-2.3's owned_paths, so `suite-green` was unreachable for the builder. The fix was a minimal edit to the old test: the 10-id order, plus `_run` dispatch for NR (h,l,c,rstar) and INSIDE/SQZ (h,l,c).

**Why:** the reviewer findings only blamed the new files, so this cross-task contradiction stayed hidden.
**How to apply:** when suite-green fails on tests from a different task, check whether the requirement changed something that test pins. Requirements outrank the old test. Related: [[agent-ci-reviewer-findings-misdiagnose]], [[agent-ci-requirement-vs-protected-path]], [[agent-ci-builder-system-python]] (the TASK-2.3 builder again used system python and ran `pip install --break-system-packages`).
