---
name: oracle-spec-ten-year-hang
description: tests calling oracle.prepare_oracle(oracle.oracle_spec(spec)) build the 10-year oracle world and hang → oracle-tests-green TIMEOUT
metadata:
  node_type: memory
  type: project
  originSessionId: 61e1b73e-9450-449d-a3a5-96decc51a1cc
  modified: 2026-11-18T10:01:55.707Z
---

TASK-15.74 (2026-11-18): the builder's test called `oracle.prepare_oracle(oracle.oracle_spec(spec), ...)`.
`oracle_spec` maps a small world to the real ten-year oracle world, so the test never finished. The
acceptance run hit TIMEOUT at 900 s and the builder timed out at 3600 s. The fix was to pass
`store.spec_for_weeks(...)` directly to prepare_oracle; end-to-end tests monkeypatch `oracle.oracle_spec`.
The spec writer's prototype test in /tmp/proto<id> was spec-compliant and could be adopted as-is
(see [[strong-direct-escalations]]).

**Why:** the hang looks like a code performance bug, so the reviewer blamed an iloc loop in a helper.
**How to apply:** on an oracle/synthetic TIMEOUT, grep the new test for `oracle_spec(` before you profile any code.
