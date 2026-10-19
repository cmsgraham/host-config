---
name: agent-ci-review-only-stalls
description: "When agent-ci exhausts attempts with validation passing but reviewer verdict FIX every round, diff the script against the requirements list; reviewer findings drift and can contradict requirements"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: bf169cb1-ab04-42e1-b9d0-cfe686b1e2d9
  modified: 2026-09-04T03:05:21.854Z
---

On TASK-6.4 (2026-09-03) all acceptance commands passed on attempts 2 and 3, yet the run hit HUMAN_REQUIRED because the reviewer said FIX three times with different findings each round. One finding ("don't export LINODE_OBJ_SECRET_KEY") directly contradicted requirement 2 ("export the outputs as LINODE_OBJ_*"). The real gaps were requirements the builder never covered (pending-sync-then-reconcile cycle, TEST_STATUS row saying PASS instead of PENDING_CREDENTIALS, no invokable teardown target, `terraform destroy || true`).

TASK-7.1 (2026-09-03) was the same shape but broke validation too: the attempt-3 reviewer told the builder to make `ssh_public_key` mandatory in the LinodeProvider constructor, which contradicted "mocks run credential-free" and failed all 10 unit tests. Underneath, the builder's provider listed terraform workspaces instead of selecting by the Linode tag, and the module labelled every host `xsp-worker-0`; a rewrite against the requirements was needed, not the reviewer's one-line repair.

**Why:** Builders fix only the latest reviewer nit; the reviewer then finds the next gap. Chasing the last finding never converges.

**How to apply:** For a review-only stall, walk the task YAML `requirements` list item by item against the diff and fix every uncovered one at once. Requirements outrank reviewer findings; note contradictions explicitly in the summary. Related: [[agent-ci-builders-stub-tests-when-stuck]].
