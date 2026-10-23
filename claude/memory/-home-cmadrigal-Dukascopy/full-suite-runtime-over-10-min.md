---
name: full-suite-runtime-over-10-min
description: "fxplat full suite: `pytest tests -q` runs on 6 xdist workers (~10 min); any --deselect/-k makes it serial (35+ min) and exposes a test_rerun_facts MonkeyPatch leak (6 false tests/pipeline failures)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: e7706c60-0b1c-4d51-8f37-911b20aee52e
  modified: 2026-10-23T18:13:40.102Z
---

The fxplat `pytest tests -q` output shows no "N passed" summary line (only dots and `[100%]`), so check the exit code. Since 2026-10-21, `tests/_plugins/fxplat_parallel.py` (addopts `-p fxplat_parallel`) runs the whole suite on 6 xdist workers with `--dist loadfile`. On 2026-10-23 that took about 10 min.

Any narrowing makes the run serial: `--deselect`, `-k`, `-m`, `--lf`, a path other than `tests`, or `FXPLAT_XDIST=0`. A serial run took over 35 min under load. On 2026-10-23 it also failed 6 tests/pipeline tests that are green on xdist:
- test_research_helpers::test_research_run_contract_unchanged
- test_research_run_hallazgo: dev_full_once, verdict_stage_attribution, report, registry_and_manifest, predictions_equal

The errors read `spy_stage() got an unexpected keyword argument 'hallazgo'` / `'pipeline.test_rerun_facts' == 'fxplat.pipeline.research_run'`. Cause: the module fixture `run` in tests/pipeline/test_rerun_facts.py does `_spies(pytest.MonkeyPatch())` and never calls undo, so its spies stay on `research_run` for the rest of the process.

**Why:** in the TASK-14.5 escalation, I deselected the 6 caleidoscopio time-bomb tests to "verify the rest". The run went serial and showed 6 extra failures that are not the task's. Earlier serial runs were killed by short background timeouts (TASK-3.102a, TASK-9.11).

**How to apply:** verify with the exact acceptance command (`.venv/bin/python -m pytest tests -q`; `-p no:cacheprovider` is OK) in the background with timeout 7200000. Compare its FAILED list against known main breakage; don't deselect. If you see those 6 pipeline failures, check whether the run was serial before blaming the branch. The leak is in a protected dir, so fixing it is an operator job. See [[suite-green-timeout-diagnosis]], [[caleidoscopio-test-clock-timebomb]].
