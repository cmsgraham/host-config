---
name: sqlite-heartbeats-are-utc
description: "Worker heartbeats are stored as SQLite CURRENT_TIMESTAMP (UTC, naive) while the dev machine runs CST; compare in UTC via reconciliation.find_stale_workers"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3d3ee87c-79c2-4ac3-b552-ec912cee880d
  modified: 2026-09-02T20:08:06.471Z
---

`DatabaseManager.update_worker_heartbeat` writes SQLite `CURRENT_TIMESTAMP`, which is UTC without a zone marker ("YYYY-MM-DD HH:MM:SS"). The dev box (WSL) runs CST, so `datetime.now()` is 6h behind the stored value. The original `/worker/dead-workers` endpoint compared against local `datetime.now()`, which silently never flagged anyone here (negative age) and would flag every live worker on a UTC+ machine.

**Why:** Found while fixing TASK-5.6 (2026-09-02). Since then `orchestrator/reconciliation.py` owns the shared rule `find_stale_workers(workers, dead_after_seconds, now)` (naive timestamps read as UTC; never-heartbeated workers are not stale) and `worker_api.py` delegates to it.

**How to apply:** When seeding a stale heartbeat in tests, write the UTC string in that exact format (see `_db_timestamp` helpers in tests/orchestrator/test_reconciliation.py); never pass a `datetime` object (Python 3.12 deprecates the adapter) and never use local time. Any new dead-worker logic should call `find_stale_workers` rather than reimplementing the comparison. Related: [[two-sqlite-layers-in-orchestrator]].
