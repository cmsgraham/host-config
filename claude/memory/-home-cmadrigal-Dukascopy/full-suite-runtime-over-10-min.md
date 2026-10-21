---
name: full-suite-runtime-over-10-min
description: fxplat full suite takes >10 min (>32 min under load by 2026-10-20); background Bash default 600s kills it — use timeout 7200000
metadata:
  node_type: memory
  type: feedback
  originSessionId: e7706c60-0b1c-4d51-8f37-911b20aee52e
  modified: 2026-10-21T01:47:38.701Z
---

The fxplat `pytest tests -q` suite (~4,929 tests on 2026-10-14) runs longer than 10 minutes, and its `-q` output shows no "N passed" summary line (only dots and `[100%]`), so check the exit code. On 2026-10-20 (TASK-9.11, load avg ~10 on 24 cores) it was still only at 85% after 32 min. pytest-xdist is not installed.

**Why:** in the TASK-3.102a escalation, a background run with timeout 600000 was killed partway through. In TASK-9.11, a run with timeout 1900000 was also killed, at 85%. A `pgrep -f "<pattern>"` wait loop also matched its own command line and never exited.

**How to apply:** run suite-green in the background (`... > log 2>&1; echo EXIT=$? >> log`) with the maximum Bash background timeout of 7200000 ms. Wait for the completion notification instead of a pgrep loop. See also [[suite-green-timeout-diagnosis]].
