---
name: no-progress-with-stop-file
description: "no_progress triage cases while state/STOP exists are operator stops, not failures; report NEEDS YOU, no retry, no re-ask"
metadata:
  node_type: memory
  type: project
  originSessionId: 11c85a33-bbf3-41f0-a93c-1d0fc0f4ef0f
  modified: 2026-10-30T12:14:38.255Z
---

Since 2026-10-28 00:11Z the watchdog raises the same `no_progress` case every 15 min because the operator wrote `state/STOP` and no supervisor runs (only the dashboards on 8767/8768). The ask was answered "wait" at 2026-10-28 09:12Z; triages on 2026-10-28, 2026-10-29 and 2026-10-30 all ended NEEDS YOU without re-asking. The stop is because the operator is committing synthetic-bench work directly on main and running the S2 bench driver (`fxplat.synthetic.driver --stage S2`, writes `~/fxsynth/bench-v3`); confirm with `ps aux | grep synthetic.driver` and `git log --since=<stop date>`.

**Why:** triage may not start the loop or remove STOP; a `retry` does nothing without a supervisor; the runnable specs (16.42, 16.43, 16.44, 3.147) are ELIGIBLE and untouched.

**How to apply:** check `ls state/STOP` and `ps | grep agent_ci` first; if STOP exists and no supervisor runs, copy the previous report's wording, update the hours, write NEEDS YOU and stop. Do not re-send the ask while the "wait" answer stands. Related: [[real-run-task-ids]].
