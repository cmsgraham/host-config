---
name: scan-internals-positional-callers
description: confirm.py / promote.py build hallazgos.scan _Job/_FrameCtx/_stamp positionally — any scan.py spec must add fields LAST with defaults; scan.py cap is 985 (test_hz_scan_helpers), NOT the 1000 lint cap; scan_helpers cap 250, no import of scan, __all__ + home-module pins
metadata:
  node_type: memory
  type: project
  originSessionId: 5c739215-be4f-4c00-9060-2339957e0049
  modified: 2026-11-02T13:20:38.336Z
---

`fxplat.hallazgos.confirm` builds `scan._Job` (12 positional args) and `scan._FrameCtx` (5), calls
`scan._stamp` (9 positional) and `_condition_trades`; `promote.rule_signal` builds
`scan._FrameCtx(frame, ts, None, None, inp)` and calls `_predicate_mask` / `_hint_ok`. Both are protected.
test_hz_promote requires a ValueError matching 'calendar_event' from rule_signal.

**Why:** a 2026-10-22 spec-review BLOCKed TASK-11.34 on this; a builder adding a required field breaks suite-green.

**How to apply:** any spec that edits scan.py (11.34, 12.7 W1 frame) must say: new NamedTuple fields LAST with
default None, no signature change to these helpers. scan.py was 930 lines on 2026-10-22 — with
[[strict-lint-1000-line-cap]], 11.34 + 12.7 together may not fit; 12.7 may need a split-out module.

**2026-11-01 (11.53 second BLOCK):** the binding cap on scan.py is NOT the 1000-line lint cap but the non-owned
`tests/hallazgos/test_hz_scan_helpers.py` (TASK-12.17): scan.py <= 985 lines, scan_helpers.py <= 250, scan_helpers
must never import scan (cell_stats/outcomes imports fine), the 14 moved helpers are pinned by source hash,
`scan.__all__` is pinned (never add a helper to it), and `_cell_data/_statistics/_cells_frame/_stamp/run_scan`
must keep `__module__ == fxplat.hallazgos.scan`. scan.py was 960 on 2026-11-01 (25 lines of room). Any scan.py
spec must cite 985/250 and say "new helper in scan_helpers.py, not in __all__". Also: the shipped brokers.yaml
already says `judged: IC_RAW`, so any scan test that lists `mean_net_IC_RAW` columns breaks once the scan honours judged.

**2026-11-02 (TASK-11.63 built by escalation):** after 11.61's move (scan.py -> 882) and 11.63's family-3 wiring,
scan.py is **959** lines against 11.63's own spec cap of 960 (the 985 test cap still applies after). _Job now 17
fields / _FrameCtx 10 (indices, rates last). Next scan.py spec: budget lines against 985, not 960, and cite it.
