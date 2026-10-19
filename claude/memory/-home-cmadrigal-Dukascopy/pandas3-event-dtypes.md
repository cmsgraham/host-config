---
name: pandas3-event-dtypes
description: ".venv has pandas 3.0.6; assemble_events timestamp columns are ms/us/s units, not ns; family categorical never equals an empty one"
metadata:
  node_type: memory
  type: project
  originSessionId: 2b9d6ba1-14b2-4945-ac6a-1dfe89e77be8
  modified: 2026-10-13T13:17:03.215Z
---

.venv runs pandas 3.0.6, measured 2026-10-13 during TASK-3.89 triage. On a non-empty `assemble_events` frame:
- ts_decision is datetime64[ms, UTC] and ts_order_submit is datetime64[us, UTC].
- ts_fill is datetime64[s] with no tz.
- ts_cusum is datetime64[ms, UTC] only when a CUSUM timestamp exists; otherwise it is datetime64[s] with no tz.
- event_id and symbol are 'str'.
- family is a categorical whose categories come from the input.

**Why:** a spec that assumed `[ns, UTC]` and plain `==` dtype equality got BLOCKed by spec review.
**How to apply:** when a spec states dtypes, measure them with .venv first. Compare dtypes as str(dtype) when a categorical is involved.
