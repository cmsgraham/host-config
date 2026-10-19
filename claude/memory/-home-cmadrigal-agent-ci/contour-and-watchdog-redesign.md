---
name: contour-and-watchdog-redesign
description: Contour lints spec shape (5 rules, whole-suite runs count as DB tests, db-up not scored); watchdog counts runnable tasks, retries a set-aside action after 60 min, and a gate-refused task is re-validated not re-built
metadata: 
  node_type: memory
  type: project
  originSessionId: 025cf55b-64c5-455a-bf92-9d6edbbd538b
  modified: 2026-09-08T13:39:25.415Z
---

Both landed 2026-09-08 after a week in which the pipeline reported healthy
while producing stalls.

**Watchdog was liveness-only.** Every check it had — stale_lock,
dead_escalation, loop_down, stale_code, stuck_stage, idle, gateway_down — asks
*is something moving*. None asked *is anything stuck behind what is moving*, so
it truthfully said `healthy` through a night with five tasks stalled holding
escalation budget, one for 8.7 hours.

The cause is structural: `_auto_loop` excludes a task it stalled from
`eligible` for the REST of that loop's life, and the loop keeps running while
other work exists. A frozen task is invisible to every liveness check — loop
up, no dependency block, nothing down.

`watchdog.frozen_with_budget` uses only existing state (task graph +
history.json + escalations.json). Its action `restart_loop` writes a SIGNED
graceful stop; the existing loop_down check then starts a fresh loop, which
begins with an empty stalled set. **Never a kill** — an in-flight escalation is
worth more than the minutes, and stopping mid-merge leaves a half-staged tree.
A task with no escalation budget left is deliberately not retried.

**Contour asked only "how big".** Routing was right on every strong-tier task,
but size was never what cost the week. `contour.lint` adds five rules, each a
defect found by hand after it had already cost builder time:

| rule | blocking |
|---|---|
| `needs_a_database` — tests touch tests/db/, no check starts one | yes |
| `migration_number_taken` — two tasks, one number | yes |
| `unresolvable_citation` — cited path exists nowhere, no task creates it | no |
| `threshold_instability` — score within 0.5 of a routing edge | no |
| `tautological_check` — a required check that cannot fail | no |

Verdict `MALFORMED` outranks `SPLIT`: reshaping something that could not have
worked is a different instruction from splitting something merely big.

**Two lessons worth more than the rules.** A sixth rule (owned source file no
check names) was written and DELETED — checks name test files, never the source
they exercise, so it could not tell "unverified" from "verified by a test with
another name". It fired on 20 of 52 tasks, nearly all wrong. And the first
citation rule joined bare names to the repo root, so `scheduler.py parks the
run` read as missing: 39 of 52 flagged, almost all wrong.

**How to apply:** a rule that cannot be made precise is worse than none — it
teaches people to skim past the ones that are. Measure any new rule's hit rate
across all tasks before shipping it; anything firing on a third of them is
wrong until proven otherwise. See [[open-threads-2026-09-08]],
[[agent-ci-failure-modes]].

**2026-09-08 afternoon additions (commits 2f5d172, 56cba42).**
- `needs_a_database` now treats a pytest run naming no path as the whole
  suite when the tree has tests/db/ (TASK-10.1 was config-only and failed the
  gate with 730 DB errors). Caught 8 queued tasks; all got `db-up`.
- A check matching `_DB_START` is NOT counted in the score: `db-up` had moved
  7.11 local→strong for nothing. 7.11 is back at 8.5, 7.13 at 8.0, 10.2 at
  8.0, 10.4 at 7.5 — the unaided-local experiment is live again.
- `_run_one` passes `validate_first=True` when the task is in unmerged.json
  and its worktree exists: the gate's refusal is judged on the existing tree
  before any builder can break it.
- Watchdog: `runnable_tasks(cfg)` = eligible − contour-refused − stalled with
  budget spent. `loop_down` counts those; otherwise finding `needs_person`.
  A given-up action is retried after `retry_after_minutes` (60); the overnight
  give-up on start_loop was permanent because it never acted again.
- `code_revision` only looks at commits touching agent_ci/ and pyproject.toml,
  so a README commit no longer restarts the loop.
- Leftover per-slot Postgres containers are what let tasks pass in their
  worktrees for the wrong reason; merged tasks' containers were taken down.
  Per-attempt teardown is NOT built — a follow-up.
