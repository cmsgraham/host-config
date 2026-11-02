---
name: reviewer-blocks-on-audit-uncovered-items
description: "Reviewer turns the test auditor's \"uncovered requirements\" (docstring wording, function placement) into blocking findings that are already satisfied in the code"
metadata:
  node_type: memory
  type: feedback
  originSessionId: fcf44811-8d07-4b8d-b150-7a9d9b3baf53
  modified: 2026-11-02T08:31:30.664Z
---

TASK-16.78 (2026-11-02): every check passed, but the reviewer blocked with F001 (docstring 'Exits' bullet "not updated") and F002 (stop_scale "not before size_for"). Both were already true in the reviewed diff. The findings matched the test auditor's `uncovered_requirements` list in transcript.jsonl word for word ("not covered by a test", not "violated").

**Why:** the reviewer reads "no test covers X" as "X is not done". Escalation stalls with nothing wrong in the code.

**How to apply:** grep `uncovered_requirements` in the run transcript and diff a1-builder.diff against the worktree. If the code already satisfies the item, add cheap pins in the owned test (`src.index("\ndef a(") < src.index("\ndef b(")`, the doc phrases in `mod.__doc__`), and reword the docstring so it uses the spec's exact phrases. Watch the owned line caps. Related: [[stale-reviewer-lint-findings]], [[reviewer-misreads-error-path-tests]].
