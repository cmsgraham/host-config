---
name: watchdog-frozen-tasks-kills-escalation
description: "CORRECTED 2026-10-31: TASK-16.43's strong escalation was ended by the escalation's OWN 3600 s timeout, not the watchdog; its tree is kept as unvalidated and validated on the next pick. Notify dedups open cases."
metadata:
  node_type: memory
  type: feedback
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-10-31T18:30:26.114Z
---

On 2026-10-30 I told the operator the watchdog's `frozen_tasks` rule killed TASK-16.43's
strong-direct escalation. WRONG. `state/unvalidated.json` says "escalation wrote to the tree
during run-...9c4948 (timed out after 3600s)": the escalation hit its own 1-hour limit. The
watchdog's frozen_tasks WARN at 13:59 CST came AFTER the run had ended (frozen_tasks already
skips tasks with an active run or an ESCALATING/REVIEWING/MERGING marker, watchdog.py
`_active_task_ids`).

**Why:** I inferred cause from timing (WARN at the same minute) without reading the run state.

**How to apply:** for a stopped task read `state/unvalidated.json`, `escalations.json` and the
last history row BEFORE blaming a component. An escalation that wrote to the tree is recorded
as unvalidated, and the next loop pick runs `validate_first` on that tree before any builder
touches it — so "resume and validate the saved work" = `agent-ci retry <id>` + clear STOP +
`watchdog --once --fix`; no manual step. Worktrees live in `~/Dukascopy/.agent-worktrees/`.
The phone notifier (`state/notify.json`) dedups per case id: an already-open case is pushed
once and never re-alerts; a new run_id pushes again.
Related: [[main-lint-wedges-all-tasks]], [[agent-ci-ops-triage]], [[watchdog-role]].
