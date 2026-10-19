---
name: escalation-leaked-pytest-holds-suite-lock
description: "suite-green aborting with 'another pytest run already holds …' is usually MY OWN leftover background pytest from the previous escalation, not a broken database"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 97215a2d-cc79-4fc2-bfca-888886ead89b
  modified: 2026-09-10T14:19:11.242Z
---

TASK-8.3 (2026-09-10) stalled a whole run on this: the escalation session that
ran before it fixed the tests, then launched one last
`.venv/bin/python -m pytest tests -q` **in the background** and ended its turn.
That process (13:38) was still alive when the supervisor's handoff run reached
`suite-green` (13:49). `tests/conftest.py` takes a session advisory lock on the
per-task database, waited its 60 s, and aborted with
`another pytest run already holds postgresql://…/agentci_task_8_3 (pid …)` —
having run ZERO tests. The classifier called it
`environment / database` and HUMAN_REQUIRED.md said "the database is missing or
broken. Recreate it", which is wrong and sends the next reader to `docker`.
Nothing was wrong with the diff or the database: re-running the eight acceptance
commands with no edits at all gave 1753 passed / 27 skipped, exit 0.

**Why:** the message names a *database*, so it reads like the container problem
in [[shared-test-db-migration-collision]] — but that one is `docker ps` (port
still held by a finished task's container), and this one is `ps` (a live pytest
of mine). The full suite takes ~17-18 min here, so a background run started near
the end of a session outlives the session by a wide margin.

**How to apply:**
1. Diagnose with connections, not containers:
   `docker exec agentci-task-N-M-postgres-test-1 psql -U snoopyfrog -d <db> -c
   "select pid,state,backend_start,now()-state_change from pg_stat_activity
   where datname=current_database();"` plus `pgrep -af pytest`. A live pytest =
   wait or kill it; zero client backends = the lock is free, just re-run.
2. **Before ending an escalation, make sure no pytest of mine is still running.**
   The supervisor re-validates within a minute or two of the handoff, and a
   background suite left behind will fail the very run I was trying to unblock.
3. The suite is ~1060 s against a 1200 s `timeout_seconds`; don't run anything
   heavy (typecheck, a second pytest) alongside the run that has to pass.

See [[agent-ci-escalation-pattern]].
