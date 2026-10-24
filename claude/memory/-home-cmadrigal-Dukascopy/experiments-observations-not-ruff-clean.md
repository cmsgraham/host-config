---
name: experiments-observations-not-ruff-clean
description: experiments/observations/*.py on main have long lines (vocab.py 26 E501); acceptance that ruff-checks them makes builders reformat content
metadata:
  node_type: memory
  type: project
  originSessionId: 19fb52ab-813b-43fe-9bc9-4dc0bd8dd1c6
  modified: 2026-10-24T02:29:11.095Z
---

`experiments/observations/vocab.py` (and siblings like build_db.py) on main are not ruff-clean:
vocab.py has 26 E501, one tag per line by design. A task whose acceptance runs `ruff check` on one
of these files while its requirement says "only append X" (TASK-13.9) makes the builder reformat the
whole file. In 13.9 it dropped the section comments and changed a tag definition, which would rewrite
the `tags` table.

**Why:** the tag definitions are synced into observations.sqlite by build_db.build_schema, so any
edit to a definition changes data, not just style.

**How to apply:** `git checkout main -- <file>`, make the minimal change, and add a file-level
`# ruff: noqa: E501 - <reason>` header instead of reformatting. Same pattern as
[[operator-commit-red-lint-on-main]].
