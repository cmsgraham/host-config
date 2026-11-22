---
name: refill-2026-11-21-r2-block-pools
description: "2026-11-21 refill: rare-edge R2 block pools - 11.78/11.81/11.79/11.80/11.82/15.75 queued; stubs 15.76, 15.77, 11.83 left; next free 11.84 / 15.78"
metadata:
  type: project
---

Refill 2026-11-21 (~03Z 11-22), decision "Rare-edge lever R2: block pools (COMMODITY + HAVEN)" 2026-11-21.
Queued, all review OK: 11.78 block_cell (merged d5f0c14 during the session), 11.81 catalogue BLOCK_PAIRS (split
out of 11.79), 11.79 scan wiring (scan.py lands exactly on its 985 cap), 11.80 score_rare kinds, 11.82 confirm.py
(not in the decision; needed or a block cell cannot be confirmed/found), 15.75 bench_hz classing.

Left as held stubs for the next writer: 15.76 bench catalogue listing the blocks (needed before the S2 re-run),
15.77 driver S1 plant-mismatch guard + repower re_k (two modules, split), 11.83 marginal-value readout (operator
stub added mid-session; says ground it after 11.80 merges). Next free ids 11.84 / 15.78.

Not yet covered anywhere: ideate.py / remix_ops.py strip only RE7 from idea universes; promote.py expands only
POOL7 / RE7 - both matter only once a LIVE catalogue lists a block.

**Why:** the three stubs named three modules but the pooled pair names are keyed in catalogue, confirm, bench_hz,
driver and repower too; the next writer should not rediscover that.

**How to apply:** prototype = git-archive of main in the scratchpad with PYTHONPATH=src; reuse the fixtures named
in the specs' MEASURED blocks. A draft left uncommitted while a merge gate starts is reset to the committed stub
(the gate restores it afterwards): keep a backup and never run `--accept-amended` without checking the file is
still the draft - see [[real-run-task-ids]].
