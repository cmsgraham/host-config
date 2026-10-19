---
name: enomem-classifier-trap
description: "A host out of memory looks like \"ImportError while loading conftest\" on /mnt/c; agent-ci filed it as a code defect until d56fcf5"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-11T20:25:59.987Z
---

On 2026-09-11 TASK-11.3's retry parked as HUMAN_REQUIRED, labelled "code /
persistent / route to builder (import_error)" and blaming tests/conftest.py,
tests/db/api_client.py and services/api/app/main.py. The real stderr was
`OSError: [Errno 12] Cannot allocate memory` while Python listed a directory on
/mnt/c. It happened at a memory peak: two task suites, an escalation, and
Expo/Playwright work in this session all running at once. One minute later,
collecting the same suite in that worktree worked.

agent-ci's category table is first-match. The traceback begins "ImportError
while loading conftest", so import_error won. Fixed in d56fcf5 on
pipeline-revision: a "memory" category ("cannot allocate memory", "[errno 12]")
ahead of import_error, in _TRANSIENT, so it retries without charging an
attempt. A running loop keeps the old classifier until it restarts.

**Why:** a mislabelled environment failure spends the task's only attempt and
its escalations rediscovering a blip. This was the day's third mislabel, after
[[snapshot-filemode-trap]].

**How to apply:** before accepting any HUMAN_REQUIRED, read the failing
check's raw stderr in logs/<run>-a1/, not just the report's class. Parked but
with escalations left means the loop re-picks it by itself. Don't pile heavy
local work (exports, Playwright, extra test DBs) onto a box running two task
suites. Related: [[wsl-disk-exhaustion-crash]], [[agent-ci-failure-modes]]
