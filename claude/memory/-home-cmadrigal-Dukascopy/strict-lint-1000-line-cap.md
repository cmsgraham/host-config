---
name: strict-lint-1000-line-cap
description: strict-lint-new fails any touched module past 1000 lines; research_run.py (996 after TASK-3.131) and synthetic/storm_day.py (979 after TASK-15.2) sit near the cap
metadata:
  node_type: memory
  type: project
  originSessionId: 36faa55b-5aef-456f-9870-f694921aa5ce
  modified: 2026-10-24T13:41:29.416Z
---

agent-ci `lint-new` (strict-lint-new) also enforces a 1000-line module cap: "X.py: N lines (limit 1000; it was M)". Ruff is clean in that case; only the line count fails. `src/fxplat/pipeline/research_run.py` was 995 on main before TASK-3.131 and is 996 after the 2026-10-18 escalation fix.

**Why:** TASK-3.131's builder added 57 lines (a correct feature, passing tests) and got stuck on this cap alone.

`src/fxplat/synthetic/storm_day.py` was built at 979 lines by the TASK-15.2 escalation (2026-10-24). Any follow-up bench task that extends it must compact the code or put new code in its own module.

**How to apply:** when a task adds code to research_run.py, storm_day.py (or any module close to 1000 lines), keep new docstrings short and compact the existing multi-line constructs (dict literals, wrapped emits/raises) without changing behavior. Splitting the module is out of scope unless the task owns the new file. Related: [[lint-new-counts-per-file-rule]].
