---
name: no-progress-with-stop-file
description: "no_progress triage cases while state/STOP exists are operator stops, not failures; report NEEDS YOU, no retry, no re-ask"
metadata:
  node_type: memory
  type: project
  originSessionId: 11c85a33-bbf3-41f0-a93c-1d0fc0f4ef0f
  modified: 2026-10-31T09:15:49.113Z
---

Since 2026-10-28 00:11Z the watchdog raises the same `no_progress` case every 15 min because the operator wrote `state/STOP` and no supervisor runs (only the dashboards on 8767/8768). The ask was answered "wait" at 2026-10-28 09:12Z; triages on 2026-10-28, 2026-10-29 and 2026-10-30 all ended NEEDS YOU without re-asking. The stop is because the operator is committing synthetic-bench work directly on main and running the S2 bench driver (`fxplat.synthetic.driver --stage S2`, writes `~/fxsynth/bench-v3`); confirm with `ps aux | grep synthetic.driver` and `git log --since=<stop date>`.

**Why:** triage may not start the loop or remove STOP; a `retry` does nothing without a supervisor; the runnable specs (16.42, 16.43, 16.44, 3.147) are ELIGIBLE and untouched.

**Update 2026-10-31 06Z:** a NEW STOP (ts 2026-10-30T21:04:12Z) after the 10-30 lint fix let the loop merge 16.42/16.44/16.45; the watchdog took no action at that minute (its own `frozen_tasks` → `restart_loop` writes STOP too, e.g. 17:44Z, and `loop_down` → `start_loop` restarts only while no STOP exists — check `acted": true` lines in watchdog.jsonl to tell them apart). Operator stop again, S2 driver pid 1504217 still running. `agent-ci retry` IS accepted under STOP and queues the task for the next loop (16.43 retried 06:2xZ; its worktree files stayed intact), so retry when the task's own cause is transient, then NEEDS YOU for the restart.

**Update 2026-10-31 09Z:** same STOP still there, S2 driver at 16 h / 14.6 GB, 3 open asks had expired unanswered; report np:166059 written NEEDS YOU in ~5 min with no ask, no retry (16.43 already in RETRY.json). The S2 log lives in /tmp/claude-1000/-home-cmadrigal-agent-ci/1c4d5b2e-*/scratchpad/s2_v3_rerun.log; its mtime shows the driver is still progressing.

**How to apply:** check `ls state/STOP` and `ps | grep agent_ci` first; if STOP exists and no supervisor runs, copy the previous report's wording, update the hours, write NEEDS YOU and stop. Do not re-send the ask while the "wait" answer stands. Related: [[real-run-task-ids]].
