---
name: partitioned-store-wal-snapshot
description: "A test fixture that writes a tmp PartitionedStore and byte-snapshots it for a \"store untouched\" check must close the store first (with-block), or the WAL checkpoint makes every test fail"
metadata:
  node_type: memory
  type: project
  originSessionId: 34cee403-d5b9-42eb-8a04-76d5d765b7db
  modified: 2026-11-04T00:43:34.082Z
---

`fxplat.data.partition.PartitionedStore(root)` keeps a WAL-mode SQLite connection open, so `development/manifest.sqlite-wal` / `-shm` files sit next to the db. If a module fixture snapshots the store (os.walk bytes) while that writer is still open, the connection later gets GC'd and checkpointed, and the "store equals pristine snapshot" check then fails in EVERY test, even tests that never read the store. Fix: `with PartitionedStore(root) as ps: ...write_day...` before taking the snapshot. StoreTicks / read_ticks readers use query_only connections and leave nothing behind.

Found 2026-11-03 building TASK-4.47 (replay_cli). Related: [[write-run-dir-not-reentrant]].

**How to apply:** any later test with a pristine-store check (the CHARTER "nothing written" requirement).
