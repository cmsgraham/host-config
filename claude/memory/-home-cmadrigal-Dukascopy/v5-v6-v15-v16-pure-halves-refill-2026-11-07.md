---
name: v5-v6-v15-v16-pure-halves-refill-2026-11-07
description: "Spec-writer refill 2026-11-07 ~03Z — pure halves of variants V5 chandelier (3.198), V6 native exits (3.199), V15/V16 threshold bars + θ calibration + quote volume (3.200-3.202); V5/V6 wiring asked on the phone"
metadata:
  node_type: memory
  type: project
  originSessionId: 0a1110b1-19c6-4d10-8838-8cba8efc8b1b
  modified: 2026-11-07T03:59:36.928Z
---

Refill 2026-11-07 ~03Z (runnable 3.193/3.195-3.197, all the C5 chain; decisions all specified). Source = config/variants.yaml
needs-build rows. Scratch /tmp/sw3198 (s/ = standalone prototypes chandelier.py, native_exits.py, info_bars.py,
quote_volume.py; gen/c98.py + t31xx.py generators; c98 EXPANDS the protected dirs src/fxplat/labeling/, tests/labeling/,
src/fxplat/data/, tests/data/ into their file lists so the owned new files are not inside a protected dir).
- 3.198 labeling.chandelier: chandelier_path (bars closing STRICTLY after the fill, Wilder ATR22, window truncated at entry,
  round(cand, 9), NaN ATR keeps level) + stop_at.
- 3.199 labeling.native_exits: DON20/DON55 donchian_prev 10/20, MA200X contrary cross, MRZ z level >= 0, RSI2 C vs SMA5;
  '—' families + CUSUM all False.
- 3.200 data.info_bars threshold bars (reset, unfinished tail dropped + counted; GOTCHA reduceat over the whole array
  folds the tail into the last bar - slice to ends[-1]+1). 3.201 calibrate_theta = geometric bisection, returns the
  largest θ with median >= 24 (closed form median/24 lands at 23.5). 3.202 data.quote_volume (bid_vol + ask_vol per minute).
- V5/V6 labeller wiring BLOCKED on phone ask decision:v5-v6-exits (rec (b) pure exit + V1 time limit, no target).
Left: V5/V6 wiring (after the answer), V15/V16 families/features/datasets on info bars (big; NR7 hour-of-week R* etc.
need readings), V7 C11-for-M3, V3/V8/train-subset operator items. Next free ids: 3.203, 7.62, 8.15, 9.20.

**Why:** the next writer must not redo these and should know the V5/V6 question is out.
**How to apply:** `git log --oneline -8 -- tasks/`; check decisions-pending for a RESOLVED v5-v6 answer. See [[bd1-b4-c5-wiring-refill-2026-11-07]], [[real-run-task-ids]], [[owned-inside-protected-dir]].
