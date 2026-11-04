---
name: ib-paper-node-pieces-refill-2026-11-04
description: "Spec-writer refill 2026-11-04 04Z — the TASK-7.2 option-B (IB paper via Nautilus) stub split into Nautilus-light pieces 7.29 paper_gate / 7.30 node_settings / 7.31 node_recovery / 7.32 node_orders / 7.33 node_reanchor / 8.13 daily_reconcile; ibapi NOT installed (ask decision:ib-paper-node-ibapi); measured Nautilus facts (OTO children not open at the entry fill; cache API); what is still unspecified"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261104-040150
  modified: 2026-11-04T04:52:53.134Z
---

Refill 2026-11-04 04:01Z (runnable 15.46 / 5.4 / 6.1 / 6.2 / 6.5 < low water 6; no drafts, no new RESOLVED decision;
all sources above the roadmap stubs exhausted). Source = brief item 1: the 7.2 / 8.4 stubs. Decision 2026-10-14 item 4
keeps option B as "the evidence path" ("G7 (Rodrigo) is required for paper that counts"), so 7.2 was SPLIT (stub kept,
hold kept, objective now points at the pieces) into deps-[] tasks:
- 7.29 fxplat.execution.paper_gate: G7 gate reusing live_gate's public names (parse_approval, ssh_keygen_verifier,
  signature_public_key, GateDecision); ONE approver Rodrigo (SIGNER_PRINCIPALS), APRUEBO names G7 not G8, risk '1 %'
  or '0,5 %' stated == configured, the DU paper account cited == account_id; 25 REASONS. Prototype /tmp/proto729.
- 7.30 node_settings: JSON settings; PORTS paper {7497, 4002} / live {7496, 4001}; account DU\d+ / U\d+; RISK_FRACTIONS
  paper (0.01, 0.005) live (0.005,); s1 {ports, client_ids, accounts, source} overlap refused; reconcile_at_pa HH:MM.
- 7.31 node_recovery: reconcile_cache (broker_snapshot fills_since_ns = ms*1e6 -> reconcile -> Reconciled), recover()
  catches ValueError of the snapshot -> error + 'not_reconciled', resume_gate, health_record, recovery_line.
- 7.32 node_orders: OrderMixin (vars(self).setdefault registry), place_bracket outcomes placed / not_executable /
  duplicate_group / known_at_broker, our_open_orders (KIND_OF MARKET/LIMIT/STOP_MARKET->STOP), cancel_entries.
- 7.33 node_reanchor (deps 7.32): reanchor_amendments against the CACHE reference (stop only when strictly tighter in
  ticks; target when different), ReanchorMixin holds changes pending until on_order_accepted of each leg.
- 8.13 daily_reconcile: daily_due (one per Panama day >= HH:MM, catch-up), daily_check -> K6 Evaluation + line.

MEASURED (nautilus 1.231, .venv): a Python mixin before Strategy works in a BacktestEngine (methods dispatched via
MRO, vars(self) writable); at on_order_filled of the entry the OTO children are NOT open (modify lost) -> apply on
on_order_accepted; after that the cache shows trigger 1.0951 / price 1.1101 (P_LONG fill 1.1001, atr .0025, m 2,
tick .00005); Order.avg_px is a float; Quantity/Price -> int/float(x.as_decimal()); cache.order_exists/order/
orders_open/instrument; default_fx_ccy('EUR/USD') price_increment 0.00001; trade ids NOT deterministic (never pin);
fills_since_ns 2000 ms excludes the fill at 1000 ms. Prototypes /tmp/proto732 (node_orders.py, node_reanchor.py,
scen*.py print every number). ibapi is NOT installed (nautilus IB adapter config import fails) -> decisions-pending
section '2026-11-04 — NEEDS DECISION IB paper node: install the Nautilus IB extra (ibapi)' + ask 001cd70c
(decision:ib-paper-node-ibapi, safe wait; recommendation defer).

LANDED 04:50Z (after the 5.4 gate cleared): 7.29 4339a0f, 7.30 a033b59, 7.31 69cfc46, 7.32 95c42c8, 8.13 abc7046; reviews
(gemma4 local; 7.33 routed strong): all OK first round except 7.30 (BLOCK: 0.0100000000001 is INSIDE 1e-12 - use
0.010000001; tmp_path listing vs helper's repo/ dir; needle searched after the path prefix) -> OK on round 2. 7.33 and
the re-pointed 7.2 stub were committed once the 15.46 gate cleared (check `git log --oneline -3 -- tasks/`). TRAP seen
again: a tracked tasks/ edit (7.2) made while MERGING.json existed was reverted when the gate landed - keep backups in
/tmp/sw729/backup and restore+commit in ONE command once the gate is clear; the `until [ ! -e state/MERGING.json ]`
background wait works. `agent-ci tasks` shows a dependant of an unmerged task as BLOCKED (not INVALID) - expected.

LEFT for 7.2 / 8.4: restart resubmission inside the node (8.6 over 8.12; open design point: bare -S/-T re-submitted
lose the OUO link), node store (append-only logs under out_dir, MODE 'PAPER-IB'), H1 decision cycle over the broker
book (paper_step.run_step with the stub signal), the TradingNode composition (needs ibapi), and 8.4's G8 wiring.

**Why:** the next writer must not re-measure the Nautilus facts nor re-split 7.2, and must know 7.33 depends on 7.32
(commit 7.32 before reviewing 7.33 - the reviewer's worktree is main).
**How to apply:** `git log --oneline -8 -- tasks/`; if decision:ib-paper-node-ibapi is RESOLVED (a), specify the
composition chain. See [[phase5-6-freeze-final-test-refill-2026-11-03]], [[binance-strategy-glue-refill-2026-11-02]].
