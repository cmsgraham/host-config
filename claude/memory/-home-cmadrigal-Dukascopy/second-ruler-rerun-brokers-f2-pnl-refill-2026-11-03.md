---
name: second-ruler-rerun-brokers-f2-pnl-refill-2026-11-03
description: "Spec-writer refill 2026-11-03 ~13:30Z (six-per-session brief) — TASK-4.40 export_brokers rulers / 4.41 rerun_facts.rebuild_criteria / 4.42 rerun_report rulers= / 4.43 rerun_cli wiring / 4.44 f2_budget 'Dos reglas' / 9.19 publish.pnl rulers; the remaining second-ruler sites, measured numbers, traps, what is left"
metadata:
  node_type: memory
  type: project
  originSessionId: 4249a2bc-80eb-45a4-b1b0-38453ff832a7
  modified: 2026-11-03T13:55:55.309Z
---

Refill 2026-11-03 13:31Z (runnable 4 = 4.36-4.39 < low water 6; no drafts, ops 0 cases, no new RESOLVED decision).
First session under the SIX-per-session brief (docs/SPEC_WRITER.md, agent-ci b914641: read once, write six, one review
round, `spec-review --accept-amended` after an OK). Source = item 2 again: the 2026-11-02 'Second ruler' decision
("every result at US$1,000 next to US$5,000"); grep for US$5,000 / r_usd / usd_per_r sites found what was left:

- TASK-4.40 ui/scripts/export_brokers.py: r_by_ruler(value, r_usd, rs) = round(value x r_usd / risk_usd, 5) on the
  FIXED 20,000-unit ticket (same US$ at every account -> R scales); build(..., rulers=None) -> reference.rulers +
  row spread_r/fees_r/total_r_by_ruler + model spread_r/commission_r/odd_lot_r_by_ruler (copied dicts). Script has
  54 E501 + ONE B023 (line 274, exness_hourly's num() closure) -> lint acceptance `--extend-ignore E501,B023`.
  Hand: 0.012 -> {0.012, 0.024, 0.06, 0.12}; 0.08 -> {0.08, 0.16, 0.4, 0.8}; 0.092 -> {.., 0.92}.
- TASK-4.41 rerun_facts.rebuild_criteria(run_dir, report_path, symbols, *, cal, oos_*, n_boot, n_paths, n_perm) ->
  RunCriteria for ANY verdict (steps 1-3 + 5-7 of rebuild_facts; no registry); split _rebuild_facts_from into
  _checked_run + _rebuild_criteria_from. Fixture facts: n 173, n_trials 17. Owns test_rerun_facts.py (append).
- TASK-4.42 rerun_report render/json/write gain rulers=None (deps 4.37): with_rulers_markdown on the BASE report
  text before the studies are appended (measured: marker '\n\n## Procedencia\n' once in the whole re-run md too, so
  whole == base-then-studies); JSON keys ['provenance','rows','rulers','seeds','stage','status','studies','variant'];
  read_verdict reads it back. New test file test_rerun_report_rulers.py.
- TASK-4.43 rerun_cli step (7b) after merged facts: rc = rebuild_criteria(...); rulers = f3_rulers(rc,
  load_config().risk) -> write_rerun_report(rulers=) (deps 4.41, 4.42). *reading: a THIRD rebuild (preflight,
  merged facts, rulers) - sharing one would change 3.145/3.146 signatures. Owns test_rerun_cli.py: call order gains
  'rebuild_criteria' before the write; replace calls[3] indexing by name lookup.
- TASK-4.44 f2_budget: v1_rulers(cells, rs) (V1 cell as v1_summary; ValueError not StopIteration when absent) ->
  report['rulers'] (SCHEMA_VERSION stays 2); Markdown table after the §10.16 reference table. Hand cell
  _cell(_distinct_days(50)): mde_central 0.42197 / mde_c1 0.47544 / gross 0.52197 R -> research 21.1 / 23.77 / 26.1,
  live 4.22 / 4.75 / 5.22 US$. tests/pipeline/test_f2_budget_c1.py does NOT exist (C1 tests live in test_f2_budget.py).
- TASK-9.19 publish.pnl build_pnl(..., rulers=None): RulerRow dataclass, six payload dicts + trade usd_net_by_ruler;
  test_publish_pnl.py pins string leaves (+ '/rulers/name'), dump length 3580 -> 3877 with the None fields, allowed
  imports (+ fxplat.common.rulers). publish.schema accepts list[dataclass] | None and dict[str, float] | None.
  Hand RS = rulers(SimpleNamespace(5000, 0.005, 0.0025)) so research risk_usd 25 == KW usd_per_r.

Review round (all six OK after one fix round; --accept-amended used on every OK): 4.40 BLOCK first (protected
test_export_brokers_regression.py::test_source_scan caps the script at 620 lines -> own it for the one-line 620->680
edit; fxplat import needs a blank line after binance_trader or I001; getattr guard for the names check); 4.44 BLOCK
first (test_f2_budget.py TOP_KEYS pins set(report) -> add 'rulers'); 9.19 BLOCK first (three MORE pinned tests:
TradeRow positional literal, len(_dump(p3)) 2648->2873, empty JSON 594->747; cap 470); 4.41 low (test_rerun_facts_merged.py
monkeypatches module globals; cap 500); 4.43 medium (a third rebuild adds ~17 s per real CLI call; module fixture
107 s - extend test_end_to_end_loyo, no new real run). Lesson: grep the WHOLE tests/ tree for pins on a module
(line caps, dump lengths, key sets, positional dataclass literals) before claiming 'exactly N edits'.

Left after this: the F3 conclusion sentence 'para una cuenta de US$5.000' is prompt.txt §0.8 wording (not ours);
publish.signals live sizing would need stop distance + usd_per_unit per card (not carried) -> skip; the IC_RAW-beside-
IB broker question (decisions-pending 2026-11-02 'Second ruler', options a/b/c) was never on the phone. Next free ids:
4.45 / 3.156 / 7.29 / 9.20 / 11.64 / 15.43 / 16.85 / 17.4.

**Why:** the next writer must not re-grep the ruler sites nor re-measure these numbers; the brokers B023 and the
f2 test-file name are false-given traps already hit once.
**How to apply:** check `agent-ci status` for 4.40-4.44 / 9.19; 4.42 and 4.43 wait on 4.37 / 4.41 merging. See
[[second-ruler-f3-report-refill-2026-11-03]], [[second-ruler-exporters-refill-2026-11-03]], [[real-run-task-ids]].
