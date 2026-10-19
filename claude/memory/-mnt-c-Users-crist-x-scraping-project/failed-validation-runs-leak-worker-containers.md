---
name: failed-validation-runs-leak-worker-containers
description: agent-ci validation runs leak LocalProvider Docker containers when a test fails before cleanup; never assert on global counts of the provider label
metadata: 
  node_type: memory
  type: project
  originSessionId: 8f5d8ef1-b696-468b-820f-5b5496638a61
  modified: 2026-09-02T19:24:29.585Z
---

When an agent-ci acceptance test fails mid-way, the `scraper-worker-w-*` containers
it started through LocalProvider stay running (label `com.x-scraping.managed-by=local-provider`).
Each retry then adds more, so any assertion like `len(list_managed_containers()) == 2`
fails with 6, 8, ... (this stalled TASK-5.5 on 2026-09-02).

**Why:** `list_managed_containers()` lists every container carrying the provider's
ownership label host-wide, not just the ones the current test created, and the
acceptance leak check filters on a different label (`managed-by=scraper-orchestrator-test`).

**How to apply:** In Docker-backed tests, tag containers with
`LocalProvider(labels={"managed-by": "scraper-orchestrator-test"})` (via
`scheduler.create_workers(..., labels=...)`), assert on the specific container ids
the test created, and run cleanup in `finally`. When escalating a stalled task, check
`docker ps -a --filter label=com.x-scraping.managed-by=local-provider` for leftovers
first. Related: [[branded-chrome-ignores-load-extension]].
