---
name: task-1-4-escalation-api-deviations
description: "TASK-1.4 (API router tests) escalation on 2026-09-04 - blocker was fixture wiring, plus three API contract deviations found and left unpatched"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4e5b5efe-b680-4e8d-978f-c9be6683de8a
  modified: 2026-09-05T04:15:38.807Z
---

TASK-1.4 stalled 3/3 attempts because the builder never re-exported the `api`/`auth`/`second_org`
fixtures from tests/db/api_client.py into tests/conftest.py (and gave `api` a nonexistent `app`
fixture parameter). Attempts 2-3 misdiagnosed it as an import problem because they ran system
`python` instead of `.venv/bin/python`. Fixed 2026-09-04 by the escalation engineer; 51 new tests.

Three deviations between tasks/TASK-1.4.yaml and services/api behaviour, pinned in tests as
actual behaviour and NOT patched (app code is out of scope for test tasks):
- PATCH /campaigns/{id} clamps minQualificationScore into 0..100 instead of rejecting it.
- PATCH /campaigns/{id} has no end>start window validation; the DB CHECK
  `campaigns_send_window_check` fires and surfaces as an unhandled asyncpg.CheckViolationError (500).
- PATCH /campaigns/{id} silently ignores `timezone` (column missing from its UPDATE).
Also: golive.py preflight `problems` are prose strings with no ids; presets router has no
builtin-delete guard.

**Why:** these are candidate Phase 2 fixes and the pipeline summary is the only other record.
**How to apply:** if a later task touches campaigns.py PATCH, fix these and tighten the
assertions in tests/db/test_api_campaigns.py. See [[agent-ci-escalation-pattern]].
