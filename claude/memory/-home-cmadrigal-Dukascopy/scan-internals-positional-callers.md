---
name: scan-internals-positional-callers
description: confirm.py / promote.py build hallazgos.scan _Job/_FrameCtx/_stamp positionally — any scan.py spec must add fields LAST with defaults; scan.py ~930/1000 lines
metadata:
  node_type: memory
  type: project
  originSessionId: 5c739215-be4f-4c00-9060-2339957e0049
  modified: 2026-10-22T21:36:16.711Z
---

`fxplat.hallazgos.confirm` builds `scan._Job` (12 positional args) and `scan._FrameCtx` (5), calls
`scan._stamp` (9 positional) and `_condition_trades`; `promote.rule_signal` builds
`scan._FrameCtx(frame, ts, None, None, inp)` and calls `_predicate_mask` / `_hint_ok`. Both are protected.
test_hz_promote requires a ValueError matching 'calendar_event' from rule_signal.

**Why:** a 2026-10-22 spec-review BLOCKed TASK-11.34 on this; a builder adding a required field breaks suite-green.

**How to apply:** any spec that edits scan.py (11.34, 12.7 W1 frame) must say: new NamedTuple fields LAST with
default None, no signature change to these helpers. scan.py was 930 lines on 2026-10-22 — with
[[strict-lint-1000-line-cap]], 11.34 + 12.7 together may not fit; 12.7 may need a split-out module.
