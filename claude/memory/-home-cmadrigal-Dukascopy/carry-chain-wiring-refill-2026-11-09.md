---
name: carry-chain-wiring-refill-2026-11-09
description: "Spec-writer refill 2026-11-09 ~02Z: 3.226 lifted; 3.227 bd1 carry_dir / 3.228 bd1_dataset forwards / 3.231 rerun_b6_stage / 3.232 rerun_c5 REQUIRED all five / 3.233 rerun_run b6= / 3.234 rerun_cli --b6; carry chain fully specified except variants.yaml wording"
metadata:
  node_type: memory
  type: project
  originSessionId: 394bc8de-3e37-4a3e-a43e-43877b0db654
  modified: 2026-11-09T02:01:15.543Z
---

Continues [[carry-b6-d44-refill-2026-11-08]]. 3.226 review re-run OK (trivial edit to change sha), lifted.
New specs: 3.227 (daily_bd1_events policy_rates kw -> carry_at; deps 3.226), 3.228 (bd1_dataset passes RAW
policy_rates to features, owns test_bd1_dataset to replace test_policy_rates_not_forwarded; deps 3.227),
3.231 rerun_b6_stage (twin of rerun_b4_stage, takes B4's window; deps 3.229/3.230), 3.232 rerun_c5 REQUIRED =
(B4,B5,B6,B6x,B-D1), EXCUSED=(), EXCUSED_NOTE removed, owns test_rerun_run_c5 for test_a/test_b texts,
3.233 rerun_run b6= (same-window check), 3.234 rerun_cli --b6 (needs --b4).

Traps found:
- 3.229 builder's first attempt was buggy (sorted(...)[:n].index(pos) ValueError); the measurements for 3.231 used a
  spec-writer reference carry_events that reproduces all 3.229 counts (prototype /tmp/p6).
- Merge gate (MERGING.json) running while lifting -> use /tmp/sw/commit_wait.sh (restore from /tmp/sw/bak, wait, commit).
- Protected-list generator /tmp/sw/prot.py (3.226 list + owned + extras, expands dirs holding owned files).

Left: config/variants.yaml B6/B6x needs-text + stale V4 note (config hygiene; operator or a small task).

**Why:** the next writer must not re-specify the carry chain.
**How to apply:** check `git log --oneline -- tasks/` and `agent-ci status`; next free ids 3.235+.
