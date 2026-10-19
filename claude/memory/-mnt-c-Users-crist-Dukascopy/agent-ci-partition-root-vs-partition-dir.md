---
name: agent-ci-partition-root-vs-partition-dir
description: "After TASK-1.10, flat-store helpers (derive_bars, Store, build_data_manifest) need <data_dir>/<partition>, not the root; builders keep passing the root"
metadata:
  node_type: memory
  type: project
  originSessionId: b26aebbf-0189-4f18-9f23-e05c35ad157c
  modified: 2026-10-05T07:02:16.411Z
---

Since TASK-1.10 the archive is `<data_dir>/{development,validation,sealed_holdout,forward}/`, each a flat Store. `derive_bars`, `Store`, `build_data_manifest` operate on ONE partition dir; `PartitionedStore.write_day` only writes parquet (no `days` row — call `ps.partition(name).set_day` yourself). TASK-1.7's builder called `derive_bars(tmp_path, ...)` on the root → "no tick store" in every fixture; it also used column `ts_ms` (stored column is `ts`) and invented bar globs. The reviewer's F001 ("resolve_partition requires symbol") was false — reviewer findings can be wrong.

**Why:** 21 tasks depend on TASK-1.7 (2026-10-05) and will build fixtures on partitioned stores.
**How to apply:** when a downstream task stalls with FileNotFoundError from bars/store helpers, check whether it was handed the partitioned root. Related: [[agent-ci-builder-system-python]].
