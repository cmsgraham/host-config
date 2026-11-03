---
name: second-ruler-exporters-refill-2026-11-03
description: "Spec-writer refill 2026-11-03 ~10Z — TASK-4.34 export_pnl / 4.35 export_risk / 4.36 export_forward carry the US$1,000 live ruler (fxplat.common.rulers) into the three exporters the second-ruler decision note left uncovered; what was verified, the traps, what is left"
metadata:
  node_type: memory
  type: project
  originSessionId: c0fb294c-286c-4367-a2a1-4e3ff45281ac
  modified: 2026-11-03T10:00:08.286Z
---

Refill 2026-11-03 (runnable 5 < low water 6; no "draft, under review" holds, no new RESOLVED decision without a
task). Source = item 2: the operator's second-ruler decision (chat 2026-11-02, recorded under the
state/decisions-pending.md 2026-11-02 "Second ruler" NEEDS-DECISION entry, whose tail names export_pnl /
export_risk / export_forward + "the run result tables" as not yet covered). TASK-4.31 (rulers module) is MERGED,
so all three have depends_on [].

- TASK-4.34 ui/scripts/export_pnl.py: main() body -> payload_for(run); payload rulers / usd_per_r_by_ruler /
  start_balance_by_ruler / total_usd_by_ruler / balance_by_ruler / max_drawdown_usd_by_ruler + per-trade
  usd_by_ruler on the RAW r_net (so ['research'] == 'usd'); run config without risk_pct_alt -> None path.
  Hand case T0 = 1420070400 s, trades 1.5 / -1.0 / 0.25 R (balance_by_ruler 5037.5 / 5018.75 / 1007.5 / 1003.75).
  The script had NO test; the new test builds the run tree (config at run.parents[2]/config/experiment.yaml,
  labels.parquet with pa.timestamp('ms', tz='UTC') -> .timestamp() epoch seconds verified). Lint: the script has
  E401 / I001 / UP017 / E741 besides E501 -> spec makes the builder fix those four, ignores E501 only.
- TASK-4.35 ui/scripts/export_risk.py: module runs at import (no main); Switch gains LAST field
  limit_usd_by_ruler: dict[str, float] | None (K1/K2/K17 R limits x 1R per ruler, K3 = 0.1 x ruler capital),
  RiskPayload gains rulers: list[RulerRow] + r_usd_by_ruler. fxplat.publish.schema.document() accepts these
  types (verified with type_schema). Test = subprocess from the repo root with FXPLAT_STATE_ROOT=tmp (so a real
  ~/Dukascopy/STOP cannot trip K11) + one importlib load for the schema check.
- TASK-4.36 ui/scripts/export_forward.py (732 lines, ruff clean): account_rulers() lazy import (None on any
  Exception, called by global name so tests monkeypatch it); 'rulers' after 'cost_model', trades rows
  usd_net_by_ruler after r_net, reviews rows ev_net_usd_by_ruler. With no decisions file explanations() returns
  {} before any fxplat import, so the test passes market/cache paths under tmp and asserts they are never created.
  Protected test pins only individual keys + p['decisions'] / p['skipped'] whole dicts (unchanged).

Left for a later writer: the "run result tables" (research_run reports; research_run.py is capped at 950 by
test_line_caps -> new owned module), the broker question (b) IC_RAW beside IB at US$1,000 (NEEDS DECISION, not
asked on the phone). Other unresolved asks: c10-externals, family1/3/4 grammars, replay-tolerances. The 4.4
roadmap stub's last piece (replay driver: run dir + ticks + policy rates -> replay_check -> report) is still
unwritten and depends on the replay-tolerances answer only through require_fixed (buildable).

Next free ids: 4.37 / 3.156 / 7.29 / 9.19 / 11.64 / 15.43 / 16.85 / 17.4.

**Why:** the next writer should not re-derive which exporters still lack the live ruler nor re-verify the
schema-builder / timestamp facts.
**How to apply:** check `agent-ci status` for 4.34-4.36 first; if one escalates, the traps above are the likely
cause (E501-only lint line, FXPLAT_STATE_ROOT, lazy import). See [[real-run-task-ids]] for the refill routine.
