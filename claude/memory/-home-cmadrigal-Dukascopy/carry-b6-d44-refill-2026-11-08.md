---
name: carry-b6-d44-refill-2026-11-08
description: "Spec-writer refill 2026-11-08 ~23Z after decision carry RESOLVED (b) 'B6/B6x + d44 en V1': 3.226 d44 fill (+3 golden features tables), 3.229 carry_events, 3.230 carry_labels; left: B-D1 carry_dir, B6 re-run stage, C5 wiring, variants.yaml"
metadata:
  node_type: memory
  type: project
  originSessionId: 70906776-cd77-4f6f-b651-24993ae2e2ad
  modified: 2026-11-09T00:26:45.571Z
---

Decision `carry` RESOLVED 2026-11-08 (b) (VS Code, after the phone ask expired): B6/B6x + fill d44_carry in V1.
Refill ~23Z wrote (ids 3.227/3.228 deliberately left free for B-D1 carry_dir):
- 3.226 context.carry_at + build_context fills d44 (NaN only w/o snapshot or rate known on NY date - 1 day). Breaks
  ONLY features.d44_carry of golden/symbol_stage + golden/research_run/{EURUSD,GBPUSD}; task owns those 3 parquet
  files + both tests' hash literals (home-venv hashes 68e9a865 / f5aeb7c7 / 49a3f081). Committed HELD ea99910: spec-review TIMED OUT twice under load (cached ERROR by spec sha) -> next writer: re-run spec-review when the box is quiet (a trivial edit changes the sha), apply, lift. Prototype full-suite run was clipped; only the 2 golden tests were seen failing (tests/features, phase2, bd1, symbol_stage, models subset all green apart from those).
- 3.229 fxplat.validation.carry_events (differential / carry_entries B6 / cross_carry_entries B6x: top-3 |diff| of the
  7 majors, ties by universe order, any NaN -> no_rate). Committed 213dc0c.
- 3.230 fxplat.labeling.carry_labels (exit_labels' _enter/_row; stop only, no target, 504 market h; windowed twin
  with CARRY_SPEC). Committed 09edf18.

NEXT (in order): 3.227 daily_bd1_events.bd1_event_features(policy_rates=None) fills carry_dir via context.carry_at
(deps 3.226; tests/features/test_daily_bd1_events.py:277 pins carry_dir all-NaN -> own it); 3.228 bd1_dataset passes
policy_rates (tests/pipeline/test_bd1_dataset.py::test_policy_rates_not_forwarded passes object() -> must change);
rerun_b6_stage (twin of rerun_b4_stage, after 3.229/3.230 merge); rerun_c5 REQUIRED += B6, B6x (EXCUSED -> ()),
rerun_run/rerun_cli flags; variants.yaml B6/B6x needs-text + V4 "V1 already runs with V4 carry" note (stale after 3.226).
Prototype pattern: git archive HEAD src tests config prompt.txt experiments docs into scratchpad, PYTHONPATH=src.
Protected-list generator = expand 3.225's list minus owned (dirs containing an owned file expanded).

**Why:** next writer continues the carry chain without re-surveying.
**How to apply:** `git log --oneline -- tasks/` first; see [[carry-phase2b-ask-2026-11-08]], [[bd1-b4-c5-wiring-refill-2026-11-07]].
