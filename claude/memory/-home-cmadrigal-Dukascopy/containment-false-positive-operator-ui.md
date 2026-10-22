---
name: containment-false-positive-operator-ui
description: "workspace-containment can blame a builder for the operator's own concurrent ui/ commits in the project root"
metadata:
  node_type: memory
  type: project
  originSessionId: 86c0aa9a-0e27-4105-baf3-9a42f44a8bf7
  modified: 2026-10-22T15:50:55.842Z
---

On 2026-10-12, TASK-3.78 failed workspace-containment because of ui/ files that came from the operator's own commit 7baad2d, made in the root while the run was going. The builder did not write them.

It happened again on 2026-10-14 with TASK-9.10. The flagged `config/variants.yaml` was the operator's draft, committed later in root `de14bf4`. The builder transcript never touched it. The builder also timed out because it re-ran the full suite (about 17 minutes each run) 3 times. The code was already complete and nothing needed to change.

It happened a third time on 2026-10-22 with TASK-12.14. The flagged path was `experiments/observations/`, the operator's observation-days DB work from another session (committed later in root `2a309fb`). The supervisor moved those files to `logs/<run>/escaped-files/`, but the operator's commit still holds them. The reviewer findings on that run (missing `turnover`/`name`/`q`) were also wrong: they were stale or did not match the spec.

**Why:** the supervisor treats any root change made during a run as the builder's. It also says it "removes" those files, which could throw away the operator's uncommitted edits.
**How to apply:** when triaging a containment failure, compare the flagged paths with `git log` commits made during the run window before you blame the builder. If they match, the failure is environmental, so retry. Related: [[suite-green-timeout-diagnosis]].
