---
name: grep-acceptance-checks-hit-pycache
description: "agent-ci acceptance checks that grep -r a source tree also match .pyc bytecode and prose in comments, not just imports"
metadata: 
  node_type: memory
  type: project
  originSessionId: 37f00c83-de00-4970-b4ac-b5b0b9a3da4e
  modified: 2026-09-08T09:32:23.721Z
---

TASK-7.4's acceptance check `test "$(grep -rln 'boto3' services/api/app/ | grep -vc '…/storage.py')" -eq 0`
fails for two reasons that have nothing to do with the code being wrong:

1. `__pycache__/storage.cpython-312.pyc` keeps the names its source imported, so
   the bytecode pytest itself just wrote counts as a second file "using boto3".
   Fixed by `sys.dont_write_bytecode = True` as the first statement in
   `tests/conftest.py` (before it imports `app.main`), plus deleting the stale
   `__pycache__` dirs once.
2. `grep` matches **prose**. A comment saying "the SDK" is fine; one saying
   "boto3 falls back to the instance role" fails the check even in a docstring.

**Why:** these checks are text matches over a directory, not import analysis, and
the pipeline treats them as the only authority on whether a task is done.

**How to apply:** when a task spec has a `grep -r` acceptance check, run it
*after* a full pytest run (not before), and grep with `-n` to see every hit
including comments. See [[agent-ci-escalation-pattern]].
