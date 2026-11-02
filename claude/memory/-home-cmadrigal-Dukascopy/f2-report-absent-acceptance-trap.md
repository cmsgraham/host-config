---
name: f2-report-absent-acceptance-trap
description: "f2_budget task specs copying TASK-3.133's `test ! -e reports/F2_PRESUPUESTO.md` acceptance make builders delete the operator's tracked report"
metadata:
  node_type: memory
  type: project
  originSessionId: 97a69b27-d51e-462d-b8ab-309ddbc9eca0
  modified: 2026-11-02T20:01:06.140Z
---

TASK-3.133's lint acceptance had `test ! -e reports/F2_PRESUPUESTO.md` (written before the report existed). The operator committed the real report on 2026-10-23 (1a925e3, run F2C-20261024-030046-065e5b0), so any later f2_budget spec that copies the clause (TASK-3.151, 2026-11-02) can only pass by deleting a tracked file. The 3.151 builder did exactly that (`D reports/F2_PRESUPUESTO.md`, -409 lines in the diff). Its three reviewer calls all failed with HTTP 400, and the HUMAN_REQUIRED report blamed infrastructure.

**Why:** a merge would delete the operator's report from main and leave F2_PRESUPUESTO.json without its .md.

**How to apply:** on an f2_budget escalation, `git checkout -- reports/F2_PRESUPUESTO.md` and report the clause as DISPUTED (escalation may not edit tasks/). Spec fix for the operator: replace it with `test -z "$(git status --porcelain reports)"`. Related: [[stale-reviewer-lint-findings]], [[real-run-task-ids]].
