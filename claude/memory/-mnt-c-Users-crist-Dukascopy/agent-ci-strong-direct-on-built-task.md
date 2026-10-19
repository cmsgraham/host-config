---
name: agent-ci-strong-direct-on-built-task
description: "HUMAN_REQUIRED 'strong_direct / nothing attempted' can be a re-run of a task that already PASSED but failed the post-merge gate; check state/unmerged.json"
metadata:
  node_type: memory
  type: project
  originSessionId: 108926fa-e9fc-4c32-9f9f-80d02cb8bdaf
  modified: 2026-10-05T05:51:27.389Z
---

TASK-1.3 (2026-10-04): HUMAN_REQUIRED.md said "Nothing has been attempted ... no failure to diagnose", but the branch already held the PASSED, reviewer-approved commit (run-20261005-012858-067c47). That run's merge was refused: `state/unmerged.json` recorded "post-merge verification failed: lint-and-no-stray", and `logs/<run>-merge/lint-and-no-stray.stdout.log` showed all 32 ruff errors were in main's legacy `src/fxplat/data/*.py`. Main fixed them (e511f8b), the operator relaunched the task to "judge as-is + merge", and the contour routed it straight to the strong tier again, ignoring the existing work.

**Why:** the contour routes on task size, not on the branch's state, so a re-run of a built task looks like "unbuilt".

**How to apply:** for a strong_direct escalation, first check `git log main..HEAD`, `state/unmerged.json` and `logs/<prior-run>-merge/`. If the work is already there and only main's gate failed, verify that the branch includes main's fix and re-run acceptance. Don't rebuild. Counter-case: TASK-1.10 (2026-10-05) was a genuine strong_direct: empty `git log main..HEAD`, `unmerged.json` = `{}`, a single history entry with `origin: unbuilt`. There the "blocker" was only the contour's size routing, and building from the spec was correct. Related: [[agent-ci-real-failure-records]], [[agent-ci-workspace-escape-false-positive]].
