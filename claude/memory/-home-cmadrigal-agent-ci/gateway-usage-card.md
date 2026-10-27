---
name: gateway-usage-card
description: "2026-09-27 rebuild of the gateway's Saved-vs-cloud/Tokens cards into one period card; daily buckets only start after a gateway restart"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9a51435e-4271-433a-aaba-ac31cf3fb017
  modified: 2026-09-28T02:05:09.080Z
---

On 2026-09-27 the two Overview tiles ("Saved vs cloud" pager + "Tokens") in ~/ollama-gateway
were replaced by ONE usage card: cost and tokens of the same period side by side, delta vs the
previous month (per-day rate first, since Aug covers only Aug 19–Sep 3), blended $/Mtok, output
share, $/req, month-end projection, a per-day bar chart (per-month bars on the all-time page)
with a tooltip carrying both figures, and a "By month" table on Overview (also in Settings).

**Why:** the user could page through monthly cost but never see the tokens behind it, compare
months, or see progression. Research (OpenRouter, OpenAI, GCP billing, FinOps tokenomics) agreed
on: tile+delta+sparkline, bars per period, cost+tokens in every tooltip/row, $/Mtok, run-rate.
A dual-axis tokens-over-cost chart was rejected on purpose.

**How to apply:** gateway.py gained `days` buckets (`_usage["days"]`, DAYS_KEPT=400), month
`start/end/days/remaining_days` spans and `days`/`today`/`daily_since` in compute_savings().
The gateway was restarted 2026-09-27 21:34 CST, so daily buckets collect from that moment;
September's earlier spend shows as a single "before daily detail" amount in the card.
Keep the embedded DASHBOARD_HTML in sync with dashboard.html (see [[gateway-dashboard-live-file]]).
The gateway repo also carried a large UNCOMMITTED diff (months, reliability, policy) before this;
nothing was committed.

**2026-10-27 — GPU-lease savings meter (built, DEPLOY PENDING an idle gateway restart).** Extended the
savings meter so ANYTHING that leases a card is metered, not just LLM tokens (user: "anything the gateway
connects should have a counter"). telemetry.py `Store.lease_savings()` = GPU-hours per lease client, each lease
clamped to `GPU_PRICING.cap_hours` (4h) and "gateway restart" closes bounded (an abandoned lease had shown 154h).
gateway.py `GPU_PRICING={per_gpu_hr:0.50,cap_hours:4}` + `compute_savings()` now returns gpu_saved_usd /
gpu_by_client / total_avoided_usd (LLM+GPU). ui/app.js Settings > Savings meter shows "cost avoided = LLM + GPU
leases" + per-client table, degrades gracefully until the backend restarts. All 3 files have .bak-savings-* backups;
gateway.py/telemetry.py py_compile OK, app.js node --check OK. Validated live: LLM $4,725, GPU-lease $5.15.
DEPLOY = restart ollama-gateway.service ONLY when in-flight empty (do it in the voice-job-done undo window, before
resuming the pipeline). LLM ref stays $3/$15 Sonnet-class (editable). Related: [[gateway-usage-card]], [[voicelab-gpu-contention]].
