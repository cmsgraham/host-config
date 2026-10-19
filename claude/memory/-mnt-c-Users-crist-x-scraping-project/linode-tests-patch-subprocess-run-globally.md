---
name: linode-tests-patch-subprocess-run-globally
description: "The fake terraform in tests/orchestrator/test_linode_provider.py patches subprocess.run process-wide, so any other subprocess.run in the call path (ssh, ssh-keyscan, docker) hits the fake and fails with \"== 'terraform'\""
metadata: 
  node_type: memory
  type: project
  originSessionId: e9a6cbd2-6bd9-43f3-9ff6-1df36484fd73
  modified: 2026-09-04T04:08:58.313Z
---

`patch("orchestrator.providers.linode.subprocess.run", FakeTerraform)` resolves to the shared stdlib `subprocess` module, so every `subprocess.run` in the process (tunnel_supervisor, image_delivery, anything) goes to the fake while the patch is active. Symptom: `assert '<path>/ssh-keyscan' == 'terraform'` raised from inside provider code.

**Why:** TASK-7.2 added SSH/docker subprocess calls to the LinodeProvider join step; the first provider-integration tests failed this way even though the fake ssh scripts were correct.

**How to apply:** wrap the fake in a dispatcher that forwards non-terraform commands to the real `subprocess.run` (see `terraform_only()` in tests/orchestrator/test_host_tunnel.py), or keep the extra subprocess calls out of the patched path. Also: `/usr/bin/cloud-init` exists on this box, so `cloud-init schema --config-file` is a usable check in tests. Related: [[agent-ci-builders-stub-tests-when-stuck]].
