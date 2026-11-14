---
name: restart-all-and-re7-refill-2026-11-14
description: "2026-11-14 ~00-01Z refill - restart-all as 16.92-16.95 (fun-profiles/2, paper_out_dir --new-run, export_forward history, export_fun_profiles protocol dir) + 11.69 re_cell.scan_summary; ask decision:rare-edge-rw; next free 3.244 / 11.70 / 15.50 / 16.96"
metadata:
  node_type: memory
  type: project
  originSessionId: 63b1cc74-2583-4a42-8565-a30fc761cc3a
  modified: 2026-11-14T00:58:39.855Z
---

Main 827ea16 -> 03772da. Restart-all (decision 2026-11-13) = 16.92 fun_profiles SCHEMA fun-profiles/2 (format unchanged;
redeploy-fun.sh -> fun-v2 restarts EVERY rung; ui export_fun_profiles bundle SCHEMA stays fun-profiles/1), 16.93 stdlib
deploy/server/paper-runner/paper_out_dir.py (sim-vN = run 1, sim-vN-r<k>; label persists in paper.json out_dir + data/
names; K9 hashes experiment config, not paper.json), 16.94 export_forward run/history, 16.95 export_fun_profiles
protocol_dir. A fork wrote 11.69 (RE7 scan row); part 2 (scan wiring) waits on ask decision:rare-edge-rw (rec a: RE7 out
of RW). Panel TS (history rows) is not spec-writer work (UI-C later).

Traps hit: a protected list copied from a spec ended with 'requirements:' -> duplicate key (review low);
`git diff --quiet HEAD -- tests` with a NEW owned test file fails in the merge gate (staged) - exclude that file.
A wait-then-commit script that pgreps its own loop text self-deadlocks.

**Why:** the next writer must not re-spec restart-all. **How to apply:** when the RE7 ask is RESOLVED, spec 11.70 scan
wiring (+ confirm.py RE7, bench scoring); see [[refill-log]].
