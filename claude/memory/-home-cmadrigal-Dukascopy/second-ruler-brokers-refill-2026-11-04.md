---
name: second-ruler-brokers-refill-2026-11-04
description: "Spec-writer refill 2026-11-04 ~20Z — the RESOLVED 2026-11-04 'Second ruler extended to IC_RAW / DUKASCOPY' decision + the Forward-mirrors TSX half of the cheaper-brokers decision: TASK-4.49 f1_brokers / 4.50 f1_costs wiring (price_instants ignored the raw per-100k commission!) / 4.51 export_f1costs / 4.52 export_brokers / 4.53 F1Costs UI / 4.54 PaperForward mirrors UI; measured numbers, traps, what is left"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261104-19
  modified: 2026-11-04T20:40:27.562Z
---

Refill 2026-11-04 ~19:30Z (runnable 16.87 / 4.48 / 7.42 / 8.13 / 8.14 < low water 6; no drafts; main a9cece9).
Source = brief item 2: "Second ruler (US$1,000) - option (b), extended to Dukascopy" (RESOLVED 2026-11-04) had no
task; the cheaper-brokers decision's item 3 still lacked its TSX half (4.48 is the exporter only).

FOUND while specifying (the key fact): f1_costs.price_instants prices a raw-broker PairCost
(commission_usd_per_100k_base_per_side > 0, per-million 0, minimum 0) with commission 0.0 - it only knows the
per-million + IB-minimum rule. order_commission_usd charges rate x units / 100_000 per order. TASK-4.50 adds
`2.0 * rate * size / 100_000` to commission AND commission_prop (x + 0.0 bit-identical for IB pairs).

Written (hold "draft, under review" first; all six valid, reviews started together ~20:05Z):
- 4.49 fxplat.pipeline.f1_brokers (deps []): LIVE_BROKERS ('IC_RAW','DUKASCOPY'); broker_models (IB refused,
  'distinct'); live_broker_hashes; broker_live_blocks (LAZY `from fxplat.pipeline.f1_costs import
  _cost_aggregates` inside the function - f1_costs imports f1_brokers at top after 4.50); report readers
  has_live_cells / live_rows (verbatim copies of f1_costs._has_live_cells/_live_rows, which 4.50 deletes to stay
  <= 1000 lines), broker_names, live_broker_rows, live_broker_section ('## Cuenta en vivo (US$1.000) por
  corredor'), header_line. Its tests pin STRUCTURE only for raw-broker cost_r (the numbers change when 4.50 lands).
- 4.50 f1_costs wiring (deps 4.49): frame_aggregates(..., live_models=) -> cell['brokers_live'] = {broker:
  {risk_live, risk_live_alt}} only when both live risks given; run_f1_costs(..., live_brokers=LIVE_BROKERS) ->
  report['live_brokers'] = {broker: cost_model_hash} (always present); test_f_end_to_end must pass live_brokers=()
  (it uses the frozen v3 model: raw variants impossible). Cap 1000 (994 today): -22 deleted, ~+22 added.
- 4.51 export_f1costs (deps []): row['live_brokers'] = {broker: {live: level(), live_alt: level()}} | None,
  run['live_brokers'] hashes dict | None, frame_summary['live_brokers'] per broker; cap 340 -> 400.
- 4.52 export_brokers (deps []): model_broker_reference(sym, mid, r_usd, broker) with
  order_commission_usd(..., units=TICKET_UNITS) (without units a raw variant RAISES -> model_reference's broad
  except would publish None); build(..., model_brokers=None) -> payload['model_brokers']; owns
  test_export_brokers_regression.py for the one-line cap 680 -> 720; the `from fxplat.common.rulers` ImportFrom
  must keep exactly its three names (rulers test pins it) -> new imports lazy.
- 4.53 F1Costs.tsx UI-C (deps []): mode research/alt/live/live_alt + broker selector; pickLevel helper; keys after
  f1c.nodataHow. 4.54 PaperForward 'Cuentas espejo' panel from payload.mirrors (deps []): PaperMirror type,
  mirrorCostR; keys after pf.nodata.no_status (distinct i18n regions so both merge cleanly); hints.test needs
  `</h2><Hint t={t} id="pf.mirrors" />` + hint.pf.mirrors es/en. UI acceptance = the 15.46 pattern (ln -sfn main
  ui/node_modules, npm run typecheck, vitest --root ui, git checkout ui/tsconfig.tsbuildinfo).

MEASURED 2026-11-04 (shipped v4 EURUSD + resolve_cost_profile variants, 4-instant frame c 1.10 atr .001/.001/
.005/.007 s_exec 8e-5, RATES of test_f1_costs, raw commission added): IB 1R10 cost_r 0.6125 comm 4.0, 1R5 0.97;
IC_RAW 1R10 0.1325 (per instant 0.1325/0.1325/0.0265) comm 0.3, 1R5 0.106 / 0.12, 1R50 0.0795 / 0.9, 1R25
0.0742 / 0.42; DUKASCOPY 1R10 0.1375 / 0.35, 1R5 0.11 / 0.14, 1R50 0.0825 / 1.05. Hashes: IB 0ad8977c, IC_RAW
475564fd, DUKASCOPY 96faa06d. Brokers model line (20k ticket): IC commission_r 0.024 (r_by_ruler .024/.048/.12/.24),
DUK 0.028; IB EURUSD@1.1 spread_pips 0.55 spread_r 0.022 commission_r 0.08 odd_lot 0.0. round(0.1325*10,2)=1.33,
round(0.1375*10,2)=1.38, round(0.6125*10,2)=6.12; toFixed(3): 0.6125->'0.613', 0.1325->'0.133', 0.1375->'0.138'.
Scratch: /tmp/sw1104b/hand.py, hand2.py.

LANDED 2026-11-04 ~20:3xZ: all six reviews OK (4.53 BLOCK once: the group line hid the k/n when cost_r_min is
null; fixed + re-reviewed), --accept-amended on each, committed after the 4.48 gate via two detached scripts
(/tmp/sw1104b/commit_ok.sh, commit_tail.sh): 4.49 58618db, 4.51 bbdd8d5, 4.52 2dd418a, 4.54 9c1806e, 4.50
f81139e, 4.53 6992e1c. Reviewer traps this round: nan != nan in dict equality (compare after _json_safe),
ast.walk vs module.body for "top-level imports" pins, YAML-escaped quotes in JSX examples read as literal.

LEFT: nothing of the second-ruler decision after these six (pnl / risk / forward / verdict rulers are R->US$
conversions, broker-free by construction: report_rulers' note points to F1 for the real live cost). Still open:
IB-node stubs 7.2 / 8.4 (flatten-at-broker, composition, ibapi ask), 6.6 (final-test hold-out ask), family 3/4
grammar asks, c10-externals ask. Next free ids: 4.55 / 3.157 / 7.45 / 8.15 / 9.20 / 11.65 / 16.88 / 17.4.

**Why:** the next writer must not re-measure these numbers, re-derive the price_instants gap, or re-grep the
rulers-import / line-cap pins.
**How to apply:** `agent-ci status` for 4.49-4.54; 4.50 waits on 4.49. See
[[cheaper-brokers-espejo-refill-2026-11-04]], [[second-ruler-rerun-brokers-f2-pnl-refill-2026-11-03]],
[[real-run-task-ids]].
