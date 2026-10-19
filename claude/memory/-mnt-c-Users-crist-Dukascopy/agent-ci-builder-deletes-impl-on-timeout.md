---
name: agent-ci-builder-deletes-impl-on-timeout
description: "TASK-2.11 \"transport/timeout\" report was really a builder that rm'd its own module and left a self-contradictory test file; mirror-to-1e-9 needs zero price-proportional costs"
metadata:
  node_type: memory
  type: project
  originSessionId: adeea71a-625a-4ada-81fc-15ea73f1e356
  modified: 2026-10-05T22:23:34.535Z
---

TASK-2.11 (2026-10-05): HUMAN_REQUIRED said "builder timed out, re-run helps", but the worktree had NO
src/fxplat/labeling/barriers.py (builder `rm`'d it at 15:57, see builder-activity.log) and only an
untracked builder-written test file whose hand vectors were wrong: SIZE 12500 vs spec 12000, paths
that never reached the barrier they asserted, two identical events expected to exit differently,
a short "stop" with an exit price below entry, wrong 17:00-NY crossing instants.

**Why:** the failure class "transport" only describes the last attempt; the real state is in the tree.
**How to apply:** always `git status` + check that owned modules exist before trusting the failure
class. Re-derive every test number from the requirements by hand. A "mirror to 1e-9 in outcome_R"
requirement can't hold when slippage/commission scale with price (negating around P changes the
level), so check the mirror with those costs set to zero. See [[agent-ci-spec-hand-vector-contradiction]].
