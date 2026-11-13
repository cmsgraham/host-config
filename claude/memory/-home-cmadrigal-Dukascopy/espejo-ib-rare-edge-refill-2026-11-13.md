---
name: espejo-ib-rare-edge-refill-2026-11-13
description: "2026-11-13 ~23Z refill - finished the 14Z writer's orphaned drafts 16.90/16.91/15.48/15.49 + new 11.68 re_cell; restart-all not specced (no fun new-run path); next free 3.244 / 11.69 / 15.50 / 16.92"
metadata:
  type: project
---

Refill 2026-11-13 ~23Z (main 0bc5ba1 -> de2519d). A ~14Z writer left four untracked drafts (hold "draft, under
review") and died: 16.90/16.91 had OK reviews (lows unapplied), 15.48/15.49 reviews never ran (empty logs in /tmp/p1548).
Finished all four: 15.49 BLOCK once (docstring layout line 113 cols > 100 -> two lines), then OK.
New: 11.68 fxplat.hallazgos.re_cell (pure; pair se = cell_stats.nw_se of session_matrix([cd]) - NOT
clusters.newey_west, whose mean is per-DAY sums; MIN_PAIRS 2 -> None; summed n / n_ef of entered pairs). Proto /tmp/p_re.

Not specced (see decisions-pending NOTE ~23Z): restart-all. fun_sim has no operator new-run path; whole-ladder fresh
start = fun-profiles schema bump (redeploy-fun.sh fun-profiles/N -> fun-vN). Paper --new-run label must persist across
plain redeploys. Rare-edge 2/3b scan wiring waits 11.68.

**Why:** next writer should not redo the restart-all survey. **How to apply:** after 16.90 merges, spec the restart
pieces; after 11.68 merges, the scan wiring. See [[refill-log]].
