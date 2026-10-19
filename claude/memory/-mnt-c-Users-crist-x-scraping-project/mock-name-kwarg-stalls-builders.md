---
name: mock-name-kwarg-stalls-builders
description: "agent-ci stall pattern — builder tests use Mock(name=\"x\") expecting .name == \"x\"; reviewer then blames the implementation for 3 attempts"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3ddc170b-4a0b-4f10-8b97-5dfe72cf2481
  modified: 2026-09-04T05:53:24.304Z
---

TASK-7.4 burned all 3 attempts on `Mock(name="tracked-host-1").name`, which is a child Mock, not the string (the `name` kwarg only sets the repr). The reviewer's "critical" findings all pointed at `cleanup_orphans` when the test fixture could never match anything.

**Why:** the builder + reviewer loop trusts the diff's tests; a fixture bug looks like an implementation bug in the traceback (`<Mock name='x.name'>` in the assertion message is the tell).

**How to apply:** on escalation, if the failing assertion shows `<Mock name='...'>` objects where strings were expected, the test is wrong. Rewrite the tests against the real fakes (`tests/orchestrator/test_linode_provider.py` FakeLinodeAPI/FakeTerraform, `remote_session_fakes.py` Fakes) instead of Mock. Also expect the rest of the builder's implementation to be placeholders (`pass`, `assert True`, comment-only "drain") and check every YAML requirement, per [[agent-ci-builders-stub-tests-when-stuck]] and [[agent-ci-review-only-stalls]].
