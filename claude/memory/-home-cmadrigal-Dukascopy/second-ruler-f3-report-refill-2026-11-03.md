---
name: second-ruler-f3-report-refill-2026-11-03
description: "Spec-writer refill 2026-11-03 ~11:20Z — TASK-4.37 report_rulers (pure F3 'Dos reglas' section) / 4.38 research_run wiring / 4.39 export_verdict 'rulers' passthrough close the 'run result tables' item of the 2026-11-02 second-ruler decision; verified facts, measured e2e numbers, traps, what is left"
metadata:
  node_type: memory
  type: project
  originSessionId: 61ea4dd0-a8b4-4ebd-8bcb-4077ff43e1ce
  modified: 2026-11-03T11:36:55.696Z
---

Refill 2026-11-03 (runnable 5 < low water 6; no drafts, ops 0 cases, no new RESOLVED decision). Source = item 2:
the 2026-11-02 "Second ruler" decision note's tail ("the run result tables" uncovered). The run result tables =
the F3 run report (reports/F3_<role>_<run_id>.md/.json written by research_run step (7) via
validation.verdict.render_report + research_run._report_json); everything there is in R and the conclusion
says "para una cuenta de US$5.000".

- TASK-4.37 (a5c5dfc) fxplat.pipeline.report_rulers, depends_on []: RulerFigures(n, ev, lo, hi, mde_R,
  total_R, take_all_ev) from rc.trade.c1 / rc.trade.trades['outcome_R'] (finite sum) / rc.trade.mde_R /
  rc.b2.mean_R; ruler_rows -> 13-key dicts via usd_by_ruler; total_pct = round(100 x total_R x risk_pct, 2)
  (from R, not from rounded US$ - rows at the same pct then agree); f3_rulers(rc, risk);
  render_rulers_section (heading '## Dos reglas: cuenta de investigación (US$5.000) y cuenta en vivo
  (US$1.000)', 11-column table with verdict.fmt cells, note with ASCII 'x' - '×' trips RUF001);
  with_rulers_markdown inserts before the single '\n\n## Procedencia\n' marker; with_rulers_json re-dumps with
  _report_json's options ('rulers' sorts between 'rows' and 'seeds'). verdict_from_report ignores extra keys;
  export_verdict's Conclusión regex stops at the next '## '. Prototype /tmp/proto437 (report_rulers.py,
  hand.py, check2.py).
- TASK-4.38 (8538006; review OK, 3 findings applied: risk == not `is`, import between cost_profiles and
  research_helpers for isort, reports dir may not exist on the failure path) research_run wiring, depends_on [4.37]: one import + rows_rulers = f3_rulers(rc, cfg.risk) after
  the D4 label, with_rulers_markdown before the .md write, with_rulers_json after _report_json -> 945 lines
  (cap 950, test_research_helpers). MEASURED on scratch /tmp/p438 (cp -r src + ln -s config, PYTHONPATH=src):
  the e2e harness run took 60 s, verdict NO_EDGE, n 173, ev 1.1197 (synthetic), rulers JSON exact. The driver
  script MUST have an `if __name__ == '__main__'` guard (spawned children re-import it; first attempt died).
  Test (e) failure path = monkeypatch research_run.f3_rulers to raise -> no report left, run_failed.
- TASK-4.39 (dc0ec79) ui/scripts/export_verdict.py payload['rulers'] = rep.get('rulers') if list else None,
  appended after 'report'; first test of the script (synthetic FXPLAT_REPO tree: git repo + registro.csv 9
  columns + F3 JSON from _report_json(evaluate({}, 'dev', 'V1')) + render_report md). Dry run verified exit 0.
  Review traps: payload['report'] holds absolute paths (rewrite the JSON in place for the "same except rulers"
  check); UP017 fix must be `from datetime import UTC, datetime` (module imports the class).

Left: the re-run CLI's merged report (rerun_report.render_rerun_markdown) has no ruler section (rc is built
inside rerun_facts and discarded - would need merged_facts to expose it); the IC_RAW-beside-IB broker question
(NEEDS DECISION, not on the phone); 4.4 replay driver; asks c10-externals / family1/3/4 / replay-tolerances
unanswered. Next free ids: 4.40 / 3.156 / 7.29 / 9.19 / 11.64 / 15.43 / 16.85 / 17.4.

**Why:** the next writer must not re-specify the F3 ruler section nor re-measure the e2e harness.
**How to apply:** check `agent-ci status` for 4.37-4.39; if 4.38 escalates, the likely causes are the 950-line
cap (import line wrapping) or the e2e run time under load. See [[second-ruler-exporters-refill-2026-11-03]]
and [[real-run-task-ids]].
