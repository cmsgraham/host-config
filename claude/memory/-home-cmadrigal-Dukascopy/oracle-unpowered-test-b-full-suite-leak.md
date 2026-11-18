---
name: oracle-unpowered-test-b-full-suite-leak
description: "SOLVED 2026-11-18 (escalation run 132012): tests/pipeline/conftest.py session-scoped autouse fixture swaps policy_snapshot.snapshot_path for the whole xdist worker → prepare_oracle tests outside pipeline get synthetic policy rates in the full suite"
metadata:
  node_type: memory
  type: project
  originSessionId: 0763c2aa-b143-4575-afeb-8a2b885a88be
  modified: 2026-11-18T13:58:53.557Z
---

2026-11-18: merge gate refused TASK-15.74 4/4 (runs 105610, 114457, 121441, 124459) on
tests/synthetic/test_oracle_unpowered.py::test_b_calibrate_joint_leaves_an_empty_period_out, always the
identical "E-S/discovery +0.6187". It passed alone and in serial tests/synthetic.

Root cause: `tests/pipeline/conftest.py::_synthetic_policy_snapshot_path` is `scope="session", autouse=True`
and patches `policy_snapshot.snapshot_path` to a flat synthetic WS_CBPOL file until the SESSION ends. Under
`--dist loadfile` every worker runs some of the 147 pipeline files, so every later `oracle.prepare_oracle`
loads the synthetic rates (alone it reads the real /home/cmadrigal/fxdata/rates snapshot). E-S discovery EV is a step
function of drift (9 events), so the financing change flips the calibration path.
Fast repro (~20 s): `pytest tests/pipeline/test_policy_snapshot.py tests/synthetic/<file>`.
Fix (escalation, owned test only): the test's autouse fixture pins `policy_snapshot.snapshot_path` to
`policy_snapshot.load_config().policy_rates_path` (the real loader, imported by name, so a
`config.load_config` patch never reaches it).

**Why:** a per-directory serial bisect cost ~30 min. Reading the session-scoped autouse conftest found it at once.
**How to apply:** if a synthetic/oracle test passes alone but fails in the full xdist suite, first run
`grep -rn 'scope="session", autouse' tests`. Never commit during a gate. If the watchdog re-raises the
mr case while an escalation is live, there is NOTHING TO DO. See also [[module-fixture-monkeypatch-leak-xdist]].
