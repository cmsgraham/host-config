---
name: strict-lint-1000-line-cap
description: strict-lint-new fails any touched module past 1000 lines; research_run.py sits near the cap (996 after TASK-3.131)
metadata:
  node_type: memory
  type: project
  originSessionId: 36faa55b-5aef-456f-9870-f694921aa5ce
  modified: 2026-10-19T04:49:03.193Z
---

agent-ci `lint-new` (strict-lint-new) also enforces a 1000-line module cap: "X.py: N lines (limit 1000; it was M)". Ruff is clean in that case; only the line count fails. `src/fxplat/pipeline/research_run.py` was 995 on main before TASK-3.131 and is 996 after the 2026-10-18 escalation fix.

**Why:** TASK-3.131's builder added 57 lines (a correct feature, passing tests) and got stuck on this cap alone.

**How to apply:** when a task adds code to research_run.py (or any module close to 1000 lines), keep new docstrings short and compact the existing multi-line constructs (dict literals, wrapped emits/raises) without changing behavior. Splitting the module is out of scope unless the task owns the new file. Related: [[lint-new-counts-per-file-rule]].
