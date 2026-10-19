---
name: worktree-venv-truncated-installs
description: "pip installs into a worktree .venv on /mnt/c can die mid-copy, leaving half-installed packages (e.g. botocore without vendored/ or dist-info)"
metadata: 
  node_type: memory
  type: project
  originSessionId: d1224b00-417e-4177-8480-3fe88ead58c2
  modified: 2026-09-03T03:19:40.827Z
---

On 2026-09-02 (TASK-6.1 escalation) the worktree `.venv` had a `botocore/` package
directory with no `vendored/` subpackage and no `*.dist-info`, plus no boto3,
s3transfer or moto at all, after a builder's `pip install -e .[dev]` ran ~60s and
stopped. Symptom in acceptance output: `ModuleNotFoundError: No module named
'botocore.vendored'` and `No module named 'boto3'`, which the local reviewer
misread as a boto3/botocore version conflict.

**Why:** the agent-ci worktrees live on the WSL `/mnt/c` mount, where large
package copies are slow and an interrupted pip leaves partial trees behind
without dist-info, so `pip list` does not show them and a re-run does not repair them.

**How to apply:** when acceptance fails with a missing *submodule* of an
installed package, `ls .venv/lib/python3.12/site-packages/<pkg>*` and look for a
missing dist-info. Delete the partial package dir and re-run
`.venv/bin/python -m pip install -e ".[dev]"` from the worktree with a long
timeout before touching any code. See [[agent-ci-builders-stub-tests-when-stuck]].
