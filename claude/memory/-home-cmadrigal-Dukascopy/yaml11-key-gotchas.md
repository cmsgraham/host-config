---
name: yaml11-key-gotchas
description: "PyYAML safe_load turns bare keys NULL/null/on/yes into None/True — breaks canonical_hash (TypeError sort) and \"verbatim\" spec blocks; quote them"
metadata:
  node_type: memory
  type: project
  originSessionId: 27753301-6914-487c-b499-17d1a503314d
  modified: 2026-10-25T22:42:03.256Z
---

PyYAML (YAML 1.1) parses the bare mapping keys `NULL`, `null`, `on`, `yes`, `no` and `off` as None/True/False. A config containing them then breaks `canonical_hash` (json sort_keys raises `TypeError: '<' not supported between ... 'str' and 'NoneType'`), and family names like `NULL` stop matching. Seen on TASK-15.11 (2026-10-25). The spec's "verbatim" §19.4 relaxation block has `worlds: {NULL: 4, ...}` and `weights: {..., NULL: 0.25, ...}`, so bench.yaml has to quote `'NULL'`. A `null:` world-group key and `on: subset` broke the same way.

**Why:** spec writers copy design text that reads naturally but is not YAML-1.1-safe, and builders assume "verbatim" means byte-identical.

**How to apply:** after writing any config YAML, walk the parsed dict for non-str keys. Quote the affected keys, keep the parsed meaning, and say so in the report.

**Also from 15.11:** the operator can amend the spec on main during the run (91aec93 retired S2 22 minutes after the run started). Run `git diff HEAD main -- tasks/<id>.yaml` before finishing; the worktree's tasks/ copy is stale.
