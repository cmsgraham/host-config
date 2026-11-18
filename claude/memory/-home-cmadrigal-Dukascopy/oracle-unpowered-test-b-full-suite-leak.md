---
name: oracle-unpowered-test-b-full-suite-leak
description: "TASK-15.74 test_b_calibrate_joint fails only in the full xdist merge-gate suite (3/3), passes alone and in serial tests/synthetic — cross-test state leak, not a flake"
metadata:
  node_type: memory
  type: project
  originSessionId: 0763c2aa-b143-4575-afeb-8a2b885a88be
  modified: 2026-11-18T13:27:27.509Z
---

2026-11-18: merge gate refused TASK-15.74 three times (runs 114457, 121441, 124459) on
tests/synthetic/test_oracle_unpowered.py::test_b_calibrate_joint_leaves_an_empty_period_out
("E-S/discovery +0.6187"). The test passes alone (18 s) and in all of tests/synthetic run serially (-p no:xdist),
so a test OUTSIDE tests/synthetic leaks state on the same worker. Ruled out: bare MonkeyPatch() (all undone),
os.chdir (restored), src lru_caches. Not checked yet: policy_snapshot.load_config is imported by name, so it is NOT
covered by the test's config.load_config patch, and it reads the real config.

**Why:** retrying alone does not help, because every retry passes the task checks and then fails the gate again.
**How to apply:** triage committed a spec evidence note (78843a2) and retried. If the gate refuses again,
bisect `pytest tests -q`. Never commit during a gate: the watchdog restarts the loop and new gates start within minutes.
See also [[module-fixture-monkeypatch-leak-xdist]].
13:26Z: the watchdog raised the same mr case (run 124459) again while the retry (run 132012, strong escalation) was
still running. Check `ls -dt logs/run-*` and ps for a live escalation before retrying. If one is live → NOTHING TO DO.
