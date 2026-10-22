---
name: owned-inside-protected-dir
description: "protected-paths used to fail a task that owns a file under a protected directory; agent-ci 068334d (2026-10-16 19:10 local) exempts EXACT owned files, so it is now a stale-run issue only"
metadata:
  node_type: memory
  type: project
  originSessionId: d0d0f076-1000-4178-9f3f-d8d2c4e650d2
  modified: 2026-10-22T02:39:10.676Z
---

agent-ci's `protected_violations` (agent_ci/git/repository.py) checked changed files against `protected_paths` by prefix or glob and never exempted `owned_paths`. So TASK-3.112, which protects `tests/pipeline/` but owns `tests/pipeline/test_run_criteria_b5.py`, failed `protected-paths` on every attempt.

Fixed in agent-ci commit 068334d (2026-10-16 19:10 -0600). A file listed EXACTLY in owned_paths is now exempt inside a protected dir or glob. Owned directories are still not exempt, and a file listed exactly as protected stays protected.

**Why:** the reviewer used to tell the builder to revert the required edit.

**How to apply:** if this failure shows up on a run that started before 068334d, or under a supervisor that is still running older code (watchdog `stale_code`), just retry. Do not edit the yaml. If it happens after the fix, check whether the owned entry is a directory rather than an exact file. Triage on 2026-10-17 retried 3.112 this way.

Variant (TASK-11.27, 2026-10-21): the local builder itself read "owned file inside protected dir" as a contradiction and called finish without writing anything, which showed up as a missing_owned_test HUMAN_REQUIRED. No contradiction: build the owned files from spec (see [[strong-direct-escalations]]). See [[containment-false-positive-operator-ui]] for another protected-check false positive.
