---
name: docker-pool-slot-leak
description: Per-task compose stacks were never torn down; docker ran out of address pools and the merge gate failed. Fixed 17a17f3 (agent-ci) + 2cd057a (v3)
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-11T23:08:03.299Z
---

2026-09-11, snoopy_frog v3 with 2 runners. A task's compose stack outlived the
task, and it broke things twice:

1. **Slot port squat.** TASK-11.6 drew slot 38 (port 23834), but finished
   TASK-11.4's container still held it, so 11.6's own container published no
   port and `migrate_local.py` reached 11.4's database:
   `InvalidCatalogNameError: database "agentci_task_11_6" does not exist`.
   It cost 11.6 an attempt (and the classifier mislabelled it, see
   [[enomem-classifier-trap]] for the sibling bug; boundary fix b2a7550).
2. **Address pools exhausted.** 28 per-task networks, 30 subnets, then
   `all predefined address pools have been fully subnetted`. The merge gate
   could not create its own database, every db test errored, and 11.6's merge
   was REFUSED as "passes alone but not combined with main".

Fix: `isolation.teardown_cmd` in agent-ci (17a17f3), run after a SUCCESSFUL
merge with that task's isolation env, never able to fail a landed merge; v3 sets
`bash scripts/test_db.sh down` (2cd057a). Manual clear-out:
`docker compose -p agentci-task-<slug> -f docker-compose.test.yml down -v`
per merged task, then check with `docker network create probe`.

**Why:** both failures read as the task's fault; neither was.

**How to apply:** when the GATE fails `db-up`, suspect the host, not the diff.
Also: any uncommitted tracked file in the integration tree refuses every merge
("the integration tree has uncommitted changes") -- my own edit to v3's
config.yaml refused 11.6's merge once. Commit operator edits there before
letting a run reach its gate. Related: [[merge-pending-race]],
[[snapshot-filemode-trap]]
