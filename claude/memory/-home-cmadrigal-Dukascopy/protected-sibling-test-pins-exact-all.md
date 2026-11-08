---
name: protected-sibling-test-pins-exact-all
description: "A spec that adds a name to a module's __all__ fails protected-paths when the predecessor task's protected test pins the exact __all__ list"
metadata:
  node_type: memory
  type: project
  originSessionId: 95fa7a75-c640-4071-b470-b880471ab592
  modified: 2026-11-08T01:19:42.817Z
---

TASK-3.213 (2026-11-08) hit protected-paths: the spec said `__all__` gains `label_exits_from_source`, but TASK-3.212's test `tests/labeling/test_exit_labels.py` (listed in protected_paths) asserted `__all__ == [exact 4 names]`. The builder edited it, and the change was correct.

**Why:** chained specs ("wiring 1/4, 2/4 …") protect the previous task's test, and that test usually pins the exact `__all__`.

**How to apply:** at triage, fix the spec: move that test from protected_paths to owned_paths and add a requirement allowing ONLY the `__all__` assertion to change (fix commit bb96b24), then run `retry`. Spec writers should check for exact `__all__` pins in sibling tests before protecting them. Related: [[owned-inside-protected-dir]], [[spec-all-sorted-means-python-sorted]].
