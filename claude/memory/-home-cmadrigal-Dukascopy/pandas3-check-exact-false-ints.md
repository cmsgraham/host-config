---
name: pandas3-check-exact-false-ints
description: "pandas 3 assert_frame_equal(check_exact=False, rtol=...) tolerance-compares int columns too; split float/non-float for exact parts"
metadata:
  node_type: memory
  type: project
  originSessionId: fd23fb37-3838-4237-9da6-9ee2680ec788
  modified: 2026-10-13T19:08:54.079Z
---

In pandas 3.0.6, `pd.testing.assert_frame_equal(check_exact=False, rtol=1e-12)` applies the tolerance to int64 columns (10**15 vs 10**15+1 passes). Datetime columns are still compared exactly. Unit tests that change an int 1→2 can't detect this; use large values.

**Why:** TASK-3.90's builder relied on it for `tests/_float_golden.py::assert_close_frame`; the reviewer blocked it (F001), so the task stalled on 2026-10-13.

**How to apply:** for "floats within tolerance, everything else exact", compare non-float columns with `check_exact=True` and float columns by hand. Related: [[pandas3-event-dtypes]].
