---
name: shared-test-db-migration-collision
description: "agent-ci test Postgres per worktree: stale containers from a finished task keep holding the reused slot port, so the new task's DB never starts and every db test errors"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7080c765-cc98-402d-8365-bb50ee667d6b
  modified: 2026-09-10T15:20:31.248Z
---

Two eras, same symptom (db tests fail for reasons nothing in the diff can cause):

**Before commit 6e3767a (2026-09-06):** docker-compose.test.yml pinned
`name: snoopyfrog-v3-test`, so all `.agent-worktrees/*` shared ONE Postgres on
:5434 and another branch's migration made
`tests/db/test_harness.py::test_schema_migrations_match_files` /
`::test_status_format` fail here. Fix was `bash scripts/test_db.sh reset`.

**After 6e3767a:** one stack per worktree. agent-ci exports
`AGENT_CI_SLOT / AGENT_CI_PORT_BASE / AGENT_CI_DB_NAME / AGENT_CI_COMPOSE_PROJECT`;
test_db.sh and tests/conftest.py both derive port = PORT_BASE + 34 (slot 0 keeps
5434). **Slots are reused, but the containers of a finished task are never torn
down.** TASK-5.1 (2026-09-07) got slot 2 → :20234, which TASK-3.6's merged-and-
forgotten container still held: `Bind for 0.0.0.0:20234 failed: port is already
allocated`, DB never created, all 338 db tests error, and the reviewer blames the
diff. Same thing on slot 0, where a legacy `snoopyfrog-v3-test` stack blocked
`agentci-main` from binding 5434 and would have failed the merge gate.
TASK-10.4 (2026-09-08) hit the IDENTICAL pair — slot 2 → :20234, still held by
that same TASK-3.6 container 12 h later. Confirm with
`docker exec agentci-task-3-6-postgres-test-1 psql -U snoopyfrog -l`: the port
answers, but only with the *other* task's database, which is why the error reads
"database agentci_task_10_4 does not exist" rather than a connection refusal.
TASK-7.2 (2026-09-08) was the third: :22234, held by merged TASK-4.2's
container, 10 h old. Nothing reaps these; expect it on every slot reuse until
something does.

TASK-6.7 (2026-09-10) was the fourth: slot 97 -> :29734, held by merged
TASK-4.4's 15 h-old container. It added a second trap. When `compose up` loses
the bind, Docker leaves the container **Created with its PortBindings intact but
never published**, and a later `compose up`/`docker restart` just STARTS that
container — `docker ps` shows a bare `5432/tcp`, nothing listens, and the error
mutates between runs (InvalidCatalogName while the squatter is up, then
ConnectionRefused after it is gone). `docker rm -f` the container and recreate;
re-upping is not enough. Do not trust a quick read of `docker ps` to say which
container owns a port — the columns line up badly and I blamed (and tore down)
the wrong merged task's stack first.

**Why:** the failure text points at migrate_local.py / the test file, never at
Docker, so attempts burn on rewriting perfectly fine code.

**How to apply:** `docker ps -a --format '{{.Names}}\t{{.Status}}\t{{.Ports}}'`
FIRST when db tests error en masse. Any `agentci-task-N-M-postgres-test-1` whose
branch is merged is garbage — `docker rm -f` it plus its
`<project>_sf_v3_test_pg` volume and `<project>_default` network. Then reproduce
the run exactly by exporting the four AGENT_CI_* vars before running the
acceptance commands. The run logs do NOT record them (checked 2026-09-07);
read them off the worktree's own container instead —
`docker inspect agentci-task-N-M-postgres-test-1 --format '{{.Config.Env}}'`
gives `AGENT_CI_DB_NAME` (POSTGRES_DB) and `docker ps` gives the published port,
so `AGENT_CI_PORT_BASE = port - 34`, `AGENT_CI_SLOT=1` (any non-zero).
Without them conftest silently falls back to the shared :5434 tree. Volumes are
throwaway; never touch the VPS DB. See [[agent-ci-escalation-pattern]].
