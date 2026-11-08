---
name: carry-phase2b-ask-2026-11-08
description: "Spec-writer refill 2026-11-08 ~09Z wrote NO task — all sources exhausted; only gap = carry (B6/B6x, d44_carry) now that BIS policy rates are ingested; ask decision:carry-phase2b sent (held for quiet hours); next free 3.226"
metadata:
  node_type: memory
  type: project
  originSessionId: 09eeada9-bcd4-4a9e-857e-1671c9d81beb
  modified: 2026-11-08T14:23:31.652Z
---

Refill 2026-11-08 ~09Z (runnable 3.215/3.216/3.223-3.225). Surveyed: no draft/roadmap holds to finish (4.4/7.2/8.4 stubs
already split), ops 0 spec-held (only 3.215 merge_refused → triage), every RESOLVED decision specified, PHASE3 map /
research program / R rows / UI-A all passed. Zero tasks written.

Gap found: PHASE3_PLAN §2 says d44_carry, B6, B6x wait for "Phase 2b" policy rates — but the BIS WS_CBPOL 8-ccy snapshot
IS ingested (fxplat.data.policy_rates, <data>/rates/WS_CBPOL_D_8ccy_snapshot.csv, all 8 ccys to 2026-09/10) for v4
financing and already reaches context.build_context. d44_carry + B-D1 carry_dir still all-NaN; B6/B6x unbuilt; variants.yaml
B6/B6x "needs" text stale. Appended "## 2026-11-08 — NEEDS DECISION carry: ..." to state/decisions-pending.md and sent
phone ask key decision:carry-phase2b: (a, rec) B6/B6x only into C5, V1 untouched / (b) also fill d44 in V1 / wait.

If RESOLVED (a)/(b): chain ≈ (1) baseline_events-style carry_entries B6 + B6x (diff = r_base − r_quote in force at t−1
close; 0 → skip; B6x = top-3 |diff| of the 7 USD majors), (2) carry labeller: stop 2×ATR20 D1, NO target, 21 NY sessions
(base on labeling/exit_labels.py), (3) rerun stage like rerun_b4_stage, (4) C5 wiring + rerun_cli flag, (5) variants.yaml
flip. baseline_events.py is 485 lines — put new generators in a new module. Also stale: variants.yaml B1/B4/B-D1 still
"needs-build" though rerun_cli --b1/--b4/--bd1 exist (3.184-3.197 passed) — low-value hygiene, after 3.225.

Refill 2026-11-08 12:52Z: no commits since 6357bb2, ask still `pending` (actually sent 12:45Z, deadline +240 min),
ops = only 3.215 merge_refused → zero tasks again. The variants.yaml hygiene task can't be written yet: 3.223/3.224/3.225
all touch config/variants.yaml (3.225 owns it) — wait for 3.225 to merge.

Refill 2026-11-08 14:23Z: still no commits since 6357bb2; ask 94a96e5e pending (143 min left at 14:25Z); ops = 3.215
merge_refused (triage 14:21Z: branch dropped, rebuilding from main) + no_progress; only stubs 4.4/7.2/8.4 (already split)
→ zero tasks a third time. Don't re-survey: check the RESOLVED line + `git log 6357bb2..` only.

**Why:** the next writer must not re-survey; the queue is empty of spec-able work until this ask is answered.
**How to apply:** check decisions-pending for the RESOLVED line first. See [[v5v6-v15v16-registry-refill-2026-11-08]].
