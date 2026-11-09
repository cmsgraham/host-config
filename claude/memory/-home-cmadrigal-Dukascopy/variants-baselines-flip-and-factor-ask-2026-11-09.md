---
name: variants-baselines-flip-and-factor-ask-2026-11-09
description: "Spec-writer refill 2026-11-09 ~04Z: only 3.235 (variants.yaml baselines needs texts -> rerun_cli flags, V4 reading) queued 7a66c2a; sources exhausted; ask decision:factor-carry sent; next free 3.236"
metadata:
  node_type: memory
  type: project
  originSessionId: bd3dd45c-e2c5-4af0-9e2f-1b7d510db405
  modified: 2026-11-09T03:42:41.691Z
---

Continues [[carry-chain-wiring-refill-2026-11-09]]. Every source was specified or passed (no draft holds; stubs
4.4/7.2/8.4 fully split - 7.2 waits on the ibapi install decision; all RESOLVED decisions done; R rows / UI-A / PHASE3 map done).

- 3.235 (deps 3.226, 3.234): config-only flip of the carry decision's "variants.yaml flip". B1/B4/B6/B6x/B-D1 KEEP
  status needs-build (*reading: a new status would move STATUSES/Counter pins in 4 protected tests); needs texts =
  "re-run baseline, not a variant run: python -m fxplat.pipeline.rerun_cli RUN_DIR --report F3.json --bX (module; C4/C5)";
  header line 17 -> 2 lines; V4 reading says V1 fills d44_carry since 3.226. New test test_variants_baselines.py checks
  flags against rerun_cli.build_parser() (fails on --b6 until 3.234 merges). Review OK (1 low, no change). Prototype /tmp/sw3235.
- Ask sent: decision:factor-carry (decisions-pending 2026-11-09 "factor regression (track E)"). Fact: validation.factors /
  factor_series exist but NOTHING in pipeline/ calls them. (a) rec: carry factor = B6x portfolio daily return + rerun_cli
  --factors study (~3 tasks); (b) dol+trend only (~2 tasks); wait.

**Why:** next writer should check the factor-carry answer first; otherwise there is nothing left to specify.
**How to apply:** if RESOLVED (a)/(b), spec factor_series carry (validation) -> rerun_factors stage -> rerun_cli flag; next free id 3.236.

2026-11-09 05:1xZ refill (runnable 3.228/3.235, 3.235 merge gate running): NOTHING QUEUED. Re-checked: no draft holds,
no new RESOLVED, ops 0 cases, ask decision:factor-carry still status pending (state/asks/b1e7e5b1..., sent 03:41Z,
240 min). Next writer: check that ask file / decisions-pending first; if still pending/expired -> nothing to write.
