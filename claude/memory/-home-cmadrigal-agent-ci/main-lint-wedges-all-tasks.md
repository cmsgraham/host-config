---
name: main-lint-wedges-all-tasks
description: "one ruff error anywhere on Dukascopy main stops EVERY task, because lint-and-no-stray lints the whole merged tree, not the task's diff"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-10-30T18:59:52.755Z
---

A single lint error committed anywhere on Dukascopy `main` wedges the ENTIRE
agent-ci queue, not just one task. On 2026-10-30 operator commit `45323e4` left
3 ruff errors in protected synthetic files (`plant.py:275` E501, `plant.py:296`
B905 zip-without-strict, `test_plant.py:472` E501). Every task's
`lint-and-no-stray` gate runs `ruff check src tests` over the whole merged tree,
so 16.42/16.43/16.44 all failed on code they never touched, hit max_attempts,
and the watchdog STOPped the loop with phone alerts ("needs a person, triage
budget spent"). The triage was correct to escalate, not retry (it would fail
identically). Fixed in `84d01e7` (pathspec commit of the 2 files); the stopped
tasks need `agent-ci retry <ids>` then clear `state/STOP` + `watchdog --once
--fix` to resume.

**Why:** the lint gate is whole-tree, so main must stay green or the whole
pipeline halts — a protected-path lint error can't be fixed by any task.

**How to apply:** before ANY commit to the supervised `~/Dukascopy` root, run
`.venv/bin/ruff check src tests` (and the owning tests) first. If the queue
alerts go "needs a person (max_attempts)" on multiple tasks at once, suspect a
red main before anything task-specific. Related: [[commit-during-merge-gate]],
[[root-edits-quarantined]], [[agent-ci-ops-triage]].
