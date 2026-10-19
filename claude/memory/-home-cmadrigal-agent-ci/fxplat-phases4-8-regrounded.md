---
name: fxplat-phases4-8-regrounded
description: "2026-10-08 fxplat TASK-3.6 rewritten as the C1-C18 verdict aggregator; Phase 4-8 stubs now follow prompt.txt §12, not CHARTER; two decisions pending"
metadata:
  node_type: memory
  type: project
  originSessionId: e3f80749-559b-49e5-bef8-d00dc5597698
  modified: 2026-10-08T06:01:53.692Z
---

On 2026-10-08 (commit 53e8a02 in ~/Dukascopy) TASK-3.6 was rewritten as a pure aggregator: it takes per-criterion results (each with `passed`) and produces the C1-C18 table, verdict EDGE / NO_EDGE / INCOMPLETE (pending never counts as passed), and the Spanish §0.8 statement. It has depends_on [] so it runs now.
The old 4.1-6.3 stubs (NautilusTrader, risk services, tiny live, from CHARTER §10) were replaced by 4.1-8.1, which follow prompt.txt §12's numbering: 4 = QuantConnect second opinion, 5 = freeze, 6 = single final test, 7 = paper for at least 3 months, 8 = live at minimum size.

**Why:** prompt.txt is the source of truth ([[spec-source-of-truth-fxplat]]); CHARTER and prompt.txt disagreed after Phase 3.

**Decided 2026-10-08 (Cristian):** NautilusTrader IS the backtest + live spine, chosen after research (CHARTER §10, LANDSCAPE). Do not treat it as optional or suggest dropping it. 4.1 = the DON reference strategies in Nautilus, compared with LEAN; 4.4 = the frozen V1 in Nautilus with the cost model; 7.2 / 8.1 use Nautilus's IB adapter. Phase 4 uses the 7 majors we hold, and F4_QC states the deviation.

**How to apply:** CHARTER/LANDSCAPE choices fill in wherever prompt.txt is silent or offers options; prompt.txt still governs the methodology. Phase 3's exit, "Puerta 1" (go / no-go on edge), is the operator's call.

**2026-10-08 decisions closed:** every item in decisions-pending was adopted, then amended after a best-practice review the user asked for. The record is docs/PHASE3_PLAN.md §7. It covers traded factors only in the alpha regression (DOL plus vol-scaled trend; Menkhoff vol as a diagnostic), Andersen-Bollerslev deseasonalisation in the sandbox, an odd-lot cost of 1 bp per IB's documentation, detached SSH signatures per approver on G8 and the final-test approval, and kill switches that never cancel bracket stops. The user wants every decision checked against industry standards before it is adopted ([[research-before-workaround]]).
