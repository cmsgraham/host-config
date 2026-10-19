---
name: pytest-garbage-dir-warnings-are-noise
description: "\"(rm_rf) Directory not empty\" PytestWarnings under /tmp/pytest-of-cmadrigal/garbage-* are root-owned leftovers from earlier Docker runs, not a bug in the code under test"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1e1c09c3-9498-44d6-88d1-582f80b527a5
  modified: 2026-09-03T02:20:03.072Z
---

Every pytest run on this box prints `PytestWarning: (rm_rf) error removing
/tmp/pytest-of-cmadrigal/garbage-.../test_interrupted_local_job_sur0/workers/w-xxxx`
(`OSError: Directory not empty`). Those dirs were written by real
scraper-worker containers (root-owned files) in earlier integration runs and
pytest's basetemp cleanup cannot delete them.

**Why:** In TASK-15.3 (2026-09-03) the agent-ci builder and reviewer both
read these warnings as a LocalProvider storage leak, added an unrelated
`shutil.rmtree` to `stop_worker`, and never fixed the real failures (endpoints
read query params while tests posted JSON; stub tests).

**How to apply:** Filter these lines out of failure reports before diagnosing
(they appear even on fully passing runs). Look at the `FAILED ...` lines and
the tracebacks only. Related: [[agent-ci-builders-stub-tests-when-stuck]],
[[failed-validation-runs-leak-worker-containers]].
