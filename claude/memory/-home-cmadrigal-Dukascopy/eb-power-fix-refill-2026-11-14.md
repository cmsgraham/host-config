---
name: eb-power-fix-refill-2026-11-14
description: "2026-11-14 ~16Z refill: E-B power audit decision -> 15.61 bench_hz (frame, exit) typical sigma + 15.62 new fxplat.synthetic.repower; next free 3.244 / 11.74 / 15.63 / 16.98"
metadata:
  node_type: memory
  type: project
  originSessionId: 4ad42927-6300-4123-96ad-b4a4c0523679
  modified: 2026-11-14T16:26:31.029Z
---

Refill 2026-11-14 16:19Z (main dd1b6a3, runnable 0). Only new source: decisions-pending "E-B power audit result"
RESOLVED 2026-11-14 (Claude, delegated). Specced:
- 15.61: bench_hz._exit_sigma keyed (frame, exit), _power_sigma(cell_sigma, frame, exit_name, typical); owns
  test_bench_hz_re7.py (test_e pinned {"fixed_h": 1.0}). POWER_RULE / result keys untouched so protected-ish
  test_bench_hz.py RESULT_KEYS + power_rule pin stay green.
- 15.62: new module fxplat.synthetic.repower (rescore.py pattern: backup result_hz.pre-repower.json, idempotent,
  'ok <changed>'), covers <bench_root>/baseline/<id> with <bench_root>/<id>/planted.json; no planted.json ->
  both power terms use cell d (*reading: planted_world.LIBRARY has no EV fields).
Measured on a COPY of bench-v6-audit/h-edge-01: E-B POOL7 0.036 -> 0.9699 (decision's 0.970). bench-v6 has NO
planted.json per world; repowering it changes ~626 cells/world mostly via floor_power (pre-15.48 results).
Prototype /tmp/proto1561 (both tasks). Strict lint = config.yaml project_checks strict-lint-new select list.

**Why:** next writer must not re-spec the power fix. **How to apply:** after 15.62 merges the operator may run
`python -m fxplat.synthetic.repower --bench-root ~/fxsynth/bench-v6` then re-score - not spec-writer work.
See [[refill-log]].
