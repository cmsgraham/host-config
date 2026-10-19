---
name: fxplat-cost-v4-migration
description: 2026-10-16 cost-model-v4 migration queued as TASK-3.114..3.127 (a6ae298); decisions 1-7 in state/decisions-pending.md; final config flip is MY commit after all merge
metadata:
  node_type: memory
  type: project
  originSessionId: 0c1852ef-3212-4405-b486-5cda3eb63786
  modified: 2026-10-17T05:47:08.530Z
---

Probe at bc25b8e: a raw flip of config/cost_model.yaml to v4 breaks 200 tests (120 = phase2 never passes
symbol/policy_rates to label_events under swap.source ib_policy_rate). Real bug found: labeller barriers unrounded
vs nautilus_replay rounded to 9 dp (decided: labeller rounds like replay; Python round() is NOT Nautilus rounding —
spec 3.115 registers the matching formula). Silent consumers: D45 features/context.py, signal_card_costs,
daily_diagnostic, ui/scripts/replay_day.py _alt.

Queued a6ae298: 3.114 frozen v3 helper -> 3.116/3.117/3.118/3.119/3.120[governance] pin tests to v3; 3.115 rounding
(strong, after TASK-4.19); 3.121 D45 v4 (§7.6 literal: 2x slip + 0.5 pip x 0.5) -> 3.122 signal card; 3.123 daily
diagnostic; 3.124 snapshot key data.policy_rates_csv + RUN_REGISTERED_GAPS -> 3.125 phase2/symbol_stage -> 3.126
research_run stamps sha256 (after 3.113). 3.127 ui/scripts = HELD, mine to build in session.
Before the flip also: TASK-3.128 (sim_book / paper execution charge v4: it refuses ib_policy_rate today, and TASK-7.23 makes it the live caller) - found 2026-10-17 night.
Final step (mine, after all merge): copy the v4 file (hash 0ad8977c..., draft in state/proposals/phase3-completion/)
to config/cost_model.yaml + regenerate tests/pipeline/golden/symbol_stage/*, DATASET_SHA256_HOME, research_run
goldens, commit with pathspec outside a merge gate; then the counted V1 re-run (decision 2: counts in N).
Also 2026-10-16: merge-gate full_suite_timeout 1800 -> 3600 (8e31811), suite is ~22 min now.

**Why:** multi-day chain; next sessions must not re-derive it. **How to apply:** check `agent-ci tasks` for
3.114-3.127, then do the flip. Related: [[fxplat-phase3-completion-2026-10-14]], [[parallel-suite-gate-timeout]].
