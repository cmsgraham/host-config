---
name: run-research-statement-cap
description: research_run.run_research sits at exactly 100 statements (PLR0915 max) after TASK-3.171; any spec adding a statement there fails strict-lint-new
metadata:
  node_type: memory
  type: project
  originSessionId: 205b2390-ffab-4ebd-8992-f712f11f4a6f
  modified: 2026-11-06T10:30:44.864Z
---

After TASK-3.171 (2026-11-06), `run_research` in src/fxplat/pipeline/research_run.py has exactly 100 statements, the strict-lint-new cap (`lint.pylint.max-statements=100`). Nested `def build` bodies count too. TASK-3.171's spec required a new `child_kw = _child_kwargs(ds_kw)` line, which made 101 and exhausted the builder's attempts. The escalation fix folded it into one statement: `child_kw = _child_kwargs(ds_kw := _dataset_kwargs(v_options))`.

**Why:** spec writers measure line caps and plain ruff, not strict-lint statement counts. ruff passes while lint-new fails.

**How to apply:** when writing or triaging a research_run spec that adds statements to run_research, budget zero new statements. Use a walrus, fold the work into an existing expression, or move the logic into a helper. Related: [[strict-lint-1000-line-cap]], [[lint-new-counts-per-file-rule]].
