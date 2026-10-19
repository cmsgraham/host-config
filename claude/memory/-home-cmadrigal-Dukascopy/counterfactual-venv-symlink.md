---
name: counterfactual-venv-symlink
description: "agent-ci counterfactual BASE_ALREADY_PASSES / proved_nothing is false when the counterfactual tree's .venv symlinks to the task worktree's editable install"
metadata:
  node_type: memory
  type: project
  originSessionId: a0407c3e-65a3-48f4-9a25-b27880d49b9c
  modified: 2026-10-12T19:35:48.916Z
---

2026-10-12 (TASK-3.79): the reviewer's `counterfactual` event said BASE_ALREADY_PASSES and
`proved_nothing: [tests/pipeline/test_store_ticks.py]`, although the review base f93e010 has no
`StoreTicks`. Cause: `.agent-worktrees/.counterfactual-<TASK>/.venv` is a symlink to
`.agent-worktrees/<TASK>/.venv`, whose `__editable__.fxplat-0.1.0.pth` puts `<TASK>/src` on
sys.path, so the "base" run imports the task's own code and passes. This is a bug in agent-ci, outside this repo.

**Why:** that false signal feeds the test audit and reviewer, which then flag the new tests as
vacuous ("FIX" verdicts) for reasons that are not real.

**How to apply:** when a review cites counterfactual "proved nothing", run
`<counterfactual>/.venv/bin/python -I -c "import fxplat.pipeline.sources as s; print(s.__file__)"`.
If it prints the task worktree's path, ignore the signal and report the agent-ci bug. Still harden
any test the audit names so that the next review passes. See [[suite-green-timeout-diagnosis]].
