---
name: registry-commit-breaks-main-suite
description: "Operator commits to experiments/registro.csv break literal assertions in test_trials / test_research_run_n_trials on main; merge_refused suite-green is then NEEDS YOU, not retry"
metadata:
  node_type: memory
  type: project
  originSessionId: 8e397d9f-bc64-47e8-8782-5d9871f61445
  modified: 2026-10-21T18:27:37.645Z
---

When a `merge_refused` case fails `suite-green` on
`tests/common/test_trials.py::test_committed_registry_reads_with_the_two_new_columns` or
`tests/pipeline/test_research_run_n_trials.py::test_committed_registry_copy`, main itself is red: an
operator commit appended rows to `experiments/registro.csv` and the tests carry literals (`variante == ""`,
`n_trials == 17`). Happened 2026-10-13 (O2 row, header-only test) and 2026-10-21 (4 carry/momentum rows,
commits 23b497a/4a2fc57, N became 21).

**Why:** no task owns those tests and triage may not edit tests, so a retry refuses identically.

**How to apply:** confirm the task diff is innocent (`git diff --stat main...agent/<id>`), run the two tests on
main, append a `NEEDS DECISION` section to `state/decisions-pending.md` recommending the operator's one-line test
fix, report NEEDS YOU without retrying. Related: [[containment-false-positive-operator-ui]].
