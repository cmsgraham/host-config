---
name: moto-mock-aws-endpoints-and-speed
description: "moto mock_aws only intercepts AWS-shaped hosts (not localhost:5000 or linodeobjects.com), and boto3.client creation costs ~7s per call on /mnt/c so scope moto fixtures to the module"
metadata: 
  node_type: memory
  type: project
  originSessionId: d1224b00-417e-4177-8480-3fe88ead58c2
  modified: 2026-09-03T03:19:48.247Z
---

Two moto facts learned while fixing TASK-6.1's object storage tests (2026-09-02):

1. `from moto import mock_aws` (moto 5) intercepts botocore only for hosts matching
   `s3*.amazonaws.com`. A custom `endpoint_url` like `http://localhost:5000`
   (the moto *server* default the local builders cargo-cult) or
   `https://<region>.linodeobjects.com` goes to the real network and burns the
   retry budget. Either use an AWS-shaped fake endpoint in tests
   (`https://s3.<any-region>.amazonaws.com`, bucket created with a
   `LocationConstraint`) or set `MOTO_S3_CUSTOM_ENDPOINTS` before moto imports.
2. moto resets `boto3.DEFAULT_SESSION` for every mock context, and creating an S3
   client reloads the service model from disk, which takes ~7s on the WSL
   `/mnt/c` checkout. Function-scoped `mock_aws` + client fixtures made 18 tests
   take 93s against a 180s acceptance timeout; module-scoped fixtures with
   distinct keys per test take 23s.

**How to apply:** in `tests/orchestrator/test_object_storage_client.py` keep the
`fake_s3`/`client` fixtures module-scoped, and reuse that pattern for any new
moto-backed test in this repo. See [[worktree-venv-truncated-installs]].
