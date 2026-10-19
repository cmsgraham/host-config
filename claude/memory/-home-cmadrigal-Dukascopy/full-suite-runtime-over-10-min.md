---
name: full-suite-runtime-over-10-min
description: fxplat full suite (~4.9k tests) takes >10 min; background Bash default 600s kills it — set timeout ~1900000
metadata:
  node_type: memory
  type: feedback
  originSessionId: e7706c60-0b1c-4d51-8f37-911b20aee52e
  modified: 2026-10-15T01:53:53.332Z
---

The fxplat `pytest tests -q` suite (~4,929 tests on 2026-10-14) runs longer than 10 minutes, and its `-q` output shows no "N passed" summary line (only dots and `[100%]`), so check the exit code.

**Why:** in the TASK-3.102a escalation, a background run with timeout 600000 was killed partway through. A `pgrep -f "<pattern>"` wait loop also matched its own command line and never exited.

**How to apply:** run suite-green in the background with `timeout 1850 ... > log; echo exit=$? >> log` and a Bash timeout of ~1900000 ms. Wait for the completion notification instead of a pgrep loop. See also [[suite-green-timeout-diagnosis]].
