---
name: agent-ci-capture-teardown-misclassified
description: "agent-ci reports \"missing_test_target\" when pytest dies in its own capture teardown or terraform's provider binary is mid-download; rerun the acceptance commands by hand before believing the classification"
metadata: 
  node_type: memory
  type: project
  originSessionId: e14ed5e2-d06d-47c7-be17-8023f448d0c6
  modified: 2026-09-05T16:30:51.303Z
---

On TASK-7.5 (2026-09-05) agent-ci classified the run as `spec / missing_test_target` ("acceptance command names a test target that does not exist") and routed to a human. The real errors were environmental: every pytest check died with `FileNotFoundError` inside `_pytest/capture.py` (`self.tmpfile.truncate()`, a vanished /tmp capture file), and `terraform validate` failed with "Failed to read any lines from plugin's stdout" because `terraform init` was still writing the 61 MB linode provider into `.terraform/providers` on the 9p /mnt/c mount. Re-running the same commands from the worktree in sequence worked at once.

**Why:** The classifier keys on the traceback signature (`FileNotFoundError|<frozen runpy>`) and reads it as a missing test file; it never checks whether the test file exists. The builder's diff was separately incomplete (placeholder tests, wrong `linode_firewall` schema), so the reviewer findings were real but not the reason the pipeline stopped.

**How to apply:** When HUMAN_REQUIRED.md shows `missing_test_target` but the traceback is in `_pytest/capture.py` or the terraform error mentions plugin stdout, rerun each acceptance command from the worktree first. If they run, the task is repairable locally and the diff (not the spec) is what needs finishing. Related: [[agent-ci-builders-stub-tests-when-stuck]], [[agent-ci-review-only-stalls]]. Terraform validation in unit tests can run offline with `terraform init -plugin-dir=infra/compute/.terraform/providers` plus a fake `LINODE_TOKEN` and `plan -refresh=false`; the linode provider does not call the API at plan time.
