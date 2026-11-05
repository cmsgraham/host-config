---
name: spec-blocked-case-is-diagnosis-hold
description: "A triage \"spec_blocked / spec held by review\" case can come from a delivered diagnosis, not a review BLOCK, even when state/spec_reviews says OK; retry does not lift it, only a spec edit does"
metadata:
  node_type: memory
  type: project
  originSessionId: d7cd3b88-3e21-4ab8-a788-312d60a1ed2c
  modified: 2026-11-05T16:43:47.243Z
---

ops.py lists `spec_blocked` cases from `escalation.awaiting_person_ids`, which covers BOTH a spec-review BLOCK and a diagnosis
(cell mode 'diagnose') delivered for the current spec hash. Example: TASK-3.158 on 2026-11-05. Its review was OK, but
state/DIAGNOSIS-TASK-3.158.md had found an environmental 1200 s acceptance timeout. `agent-ci retry` does NOT lift that hold
(its docstring says so). Fix: apply the diagnosis's minimal spec change. For 3.158 that meant dropping the protected noise
test module from the task-local acceptance (a0e4191). Then commit once MERGING.json is gone.

**Why:** retrying looks like the obvious move for a transient cause, but it does nothing here, and the task stays held.
**How to apply:** for a spec_blocked case, first `cat state/spec_reviews/<id>.json` (verdict) and `ls state/DIAGNOSIS-<id>.md`.
If the verdict is OK and a diagnosis exists, make a spec edit. See [[merge-gate-wipes-uncommitted-task-edits]], [[suite-green-timeout-diagnosis]].
