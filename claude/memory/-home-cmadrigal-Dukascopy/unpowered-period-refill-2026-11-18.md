---
name: unpowered-period-refill-2026-11-18
description: "2026-11-18 02:50Z refill: decision 'RESOLVED 2026-11-17 period with no executable event is unpowered' -> 15.74 oracle calibrate_joint/scan_view leave empty keys out + new oracle_keys.py; only task; next free 3.244 / 11.74 / 15.75 / 16.98"
metadata:
  node_type: memory
  type: project
  originSessionId: 3d3dfc60-c1bb-4711-9e65-e4063021b466
  modified: 2026-11-18T13:16:48.850Z
---

Refill 2026-11-18 ~02:21-02:55Z (main b90bb7d, runnable 0). Source: decisions-pending "RESOLVED 2026-11-17 (Claude,
applying the operator's 2026-11-06 unpowered-period rule)" (h-edge-02 crashed: E-H-EURUSD no finite confirmation EV).
- 15.74 owns oracle.py + NEW oracle_keys.py (period_evs / powered / mark_unpowered) + test_oracle_unpowered.py.
  oracle.py is 1217 lines and lint-new fails ANY growth of a >1000-line module, so _period_evs moved out (net -7).
  planted_world unchanged: 'replant' frame's 'unpowered' column already flows to planted.json.
- Toy reproduction: spec_for_weeks('w-ej', 7, 2) has no confirmation half -> calibrate_joint raised in 4 s.
  A build_world e2e test MUST monkeypatch oracle.oracle_spec (real one = 10-year world, hangs).
- An operator waiter ~/fxsynth/bin/rerun-h-edge-02.sh greps tasks for "no executable event" and main commit subjects
  for "decision 2026-11-17": keep both phrases in any follow-up task for this decision.
- Running a /tmp worktree's tests with the home .venv imports main's src (editable) - use PYTHONPATH=src.
Prototype /tmp/proto1574. Review OK (low: init `empty` before the loop, applied). Other sources: 0 asks, 0 ops cases.

**Why:** next writer must not re-spec. **How to apply:** after 15.74 merges, the h-edge-02 re-run is operator-side.
See [[refill-log]], [[s1-guard-fix-refill-2026-11-16]].

Repeat 2026-11-18 08:15Z (main f65fc33, 15.74 BUILDING attempt 1, runnable 1): EMPTY. decisions-pending mtime 02:21Z
(no new RESOLVED / unresolved heading), no draft holds (4.4/7.2/8.4 = anchor stubs), approvals newest 11-14, only new
ask = ops stop_reminder. Nothing queued, no NOTE appended.

Repeat 2026-11-18 11:36Z (main f65fc33, runnable 1 = 15.74): EMPTY again, same sources (decisions-pending mtime still
02:21Z, approvals newest 11-14, no draft holds). New ops case at 11:36Z: 15.74 MERGE REFUSED - its own
test_b_calibrate_joint_leaves_an_empty_period_out raised "E-S/discovery +0.6187" in the gate although branch tree ==
merged tree (branch based on main f65fc33) -> nondeterminism/state leak under xdist, escalation-engineer work, not a spec.

Repeat 2026-11-18 13:16Z (main f65fc33, runnable 1 = 15.74): EMPTY a third time. Same sources unchanged; 15.74
merge refused AGAIN (run-20261118-124459, same test_b failure) - still escalation work. Only new ask = ops
stop_reminder re-sent 12:45Z. Further repeats today will be empty until 15.74 merges or a new RESOLVED lands.
