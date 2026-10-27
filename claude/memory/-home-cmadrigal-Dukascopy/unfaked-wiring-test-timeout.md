---
name: unfaked-wiring-test-timeout
description: module-tests-green TIMEOUT after a builder wires a heavy real function into a module but never amends the old tests that now reach it unfaked
metadata:
  node_type: memory
  type: project
  originSessionId: 69ef8bc5-3ab9-4e7f-9865-a8477e6df4be
  modified: 2026-10-27T09:36:09.856Z
---

TASK-15.32 (2026-10-27): builder timed out (3600 s) before amending tests/synthetic/test_driver.py.
The driver already called planted_world.build_world, so the OLD driver tests (S1 h-edge-00 /
h-trap-06) ran the real build -> a full 2009-2018 oracle world -> module-tests-green and
suite-green both TIMEOUT (the progress line `.F.F....F...` stalls). Not an environment problem.

**Why:** a TIMEOUT on an acceptance check reads like load/fixture stalls (see
[[suite-green-timeout-diagnosis]]), but here it was a missing fake in an owned test file.

**How to apply:** when a timed-out builder leaves an owned test file unmodified (`git status`),
check whether existing tests now hit newly wired real code; add the spec's fake first, then
run the module tests. Also check fakes' signatures against the real function (15.32's
oracle_ev fake dropped the `base` arg).
