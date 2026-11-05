---
name: isort-import-vs-line-cap
description: a prescribed multi-name from-import is one-name-per-line under ruff I001 (no hanging packing) and can bust a 1000-line cap; budget it as N+2 lines
metadata:
  node_type: memory
  type: feedback
  originSessionId: 23c5b4ec-d779-4f98-b39e-5081e05ee099
  modified: 2026-11-05T00:02:31.110Z
---

TASK-4.50 (2026-11-04) failed lint-and-no-stray: the builder packed an 8-name `from fxplat.pipeline.f1_brokers import (...)` onto 3 lines → ruff I001; `ruff --fix` makes it 10 lines → f1_costs.py 1003 > cap 1000. Builder had also deleted docstring blank lines to make room.

**Why:** pyproject ruff isort uses defaults (vertical, one name per line when wrapping); the spec budgeted ~+22 lines without counting the import at N+2.

**How to apply:** when a spec near a line cap prescribes a long from-import, count it as N+2 lines. Fix by compacting the task's OWN added lines (fold a backslash continuation to one ≤100-char line, walrus for a one-line header splice, merge call-arg lines up to 100 chars, shorten the new docstring additions) and keep untouched lines / blank lines verbatim. Related: [[strict-lint-1000-line-cap]].
