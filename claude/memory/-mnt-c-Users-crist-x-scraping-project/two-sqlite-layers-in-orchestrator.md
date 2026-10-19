---
name: two-sqlite-layers-in-orchestrator
description: "orchestrator/database.py (DatabaseManager, worker registry) vs orchestrator/task_queue.py (TaskQueue, scheduler queue) — agent-ci builders confuse them"
metadata: 
  node_type: memory
  type: project
  originSessionId: 04521046-1b2e-4472-853e-60951069387c
  modified: 2026-09-02T20:07:58.956Z
---

The orchestrator has two separate SQLite layers: `orchestrator/database.py` (DatabaseManager: hosts, workers, sessions, jobs registry, schema_version pinned to 2 by test_database.py) and `orchestrator/task_queue.py` (TaskQueue: the queue the Scheduler actually uses, with UNIQUE(job, target) and lease semantics).

**Why:** In TASK-4.3 (2026-09-02) the agent-ci builder patched database.py for "task idempotency" because of the file name, which broke test_database.py and test_restart_persistence.py while leaving the real queue untouched. Reviewer findings about "the database layer" for queue/task/lease work almost always mean task_queue.py.

**How to apply:** For any task about tasks, leases, retries, or attempts, edit task_queue.py and pass through Scheduler. Do not bump DatabaseManager's schema version or change its create_task signature unless the task is explicitly about the registry.

Second failure mode (TASK-3.7, 2026-09-02): the two layers must never be pointed at the **same SQLite file**. DatabaseManager creates a legacy `tasks(id, job_id, status)` table; TaskQueue then hits "tasks table is missing identity columns; refusing to migrate". Every existing caller uses two files (e.g. `workers.db` + `task_queue.db`); `orchestrator/job_submission.py` derives `<stem>-tasks.db` for the queue and rejects equal paths. Builders that hit that error message should split the paths, not touch the migration.

Third failure mode (TASK-5.6, 2026-09-02): the reverse order. `Scheduler(path)` first, then `DatabaseManager(path)` on the same file: the queue's `tasks` table wins and `create_task` fails with "table tasks has no column named job_id". The reviewer then wrongly asked to add `job_id` to the schema. `orchestrator/reconciliation.py` (ReconciliationService) now refuses a shared path with ValueError, like JobSubmitter. See [[sqlite-heartbeats-are-utc]].
