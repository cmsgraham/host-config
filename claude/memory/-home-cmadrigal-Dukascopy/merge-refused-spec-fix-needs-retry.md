---
name: merge-refused-spec-fix-needs-retry
description: A spec fix for a merge_refused task does not re-run it automatically; the task stays parked and the case is re-raised — also run retry
metadata:
  node_type: memory
  type: feedback
  originSessionId: 14d805f3-3ba6-427a-9934-ea720d244e61
  modified: 2026-11-06T22:34:03.622Z
---

Fixing `tasks/<id>.yaml` for a `merge_refused` case does NOT trigger the auto re-run (TRIAGE.md's "re-run automatically" holds for spec_blocked/human_required only). TASK-3.182 on 2026-11-06: the spec was fixed at 21:37Z (c283186), but the task stayed parked as merge-refused, other tasks ran, and the same refusal came back as a new triage case an hour later.

**Why:** the merge-refused state keeps the old branch parked until someone runs `retry`/`run`.

**How to apply:** after committing a spec fix for a merge_refused case, also run `agent-ci --config "$AGENT_CI_CONFIG" retry <id> --reason ...`. If a merge_refused case shows up again with the same log, compare the branch commit time with the spec-fix commit time. If the branch is older, the build came before the fix, so just retry. Related: [[spec-blocked-case-is-diagnosis-hold]].
