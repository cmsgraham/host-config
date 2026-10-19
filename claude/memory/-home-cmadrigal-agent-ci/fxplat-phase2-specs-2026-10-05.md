---
name: fxplat-phase2-specs-2026-10-05
description: Phase 2 of fxplat fully specified 2026-10-05 (2.7-2.18 minus 2.13); spec bugs caught before builds; leakage suite is governance-owned and self-arming
metadata:
  node_type: memory
  type: project
  originSessionId: 3a91d4ce-6c57-429b-bb07-fa1f0b28fae3
  modified: 2026-10-05T21:12:07.920Z
---

On 2026-10-05 the user asked to "build as much as we can to keep the pace"; every remaining
Phase 2 task of fxplat (Dukascopy repo) was specified in session, each API machine-checked
against the merged tree first (see [[spec-given-claims-trap]]):

- 2.8 groups A/B, 2.9 groups C/G, NEW 2.15 groups D/H (split from 2.9 to stay in the local
  band), NEW 2.16 frozen-sigma CUSUM (merged sampler only takes a scalar sigma), NEW 2.17
  event assembly O(n log n) against a frozen golden table (assemble_events was quadratic:
  329 s for 66 weeks of one pair), 2.14 composition `fxplat.pipeline.phase2.build_dataset`,
  NEW 2.18 Phase-2 report generator. DVC model/validation rewiring left to Phase 3.
- 2.13 was retired: tests/leakage/ is a PROTECTED dir (builders may not define correctness),
  so the leakage suite was committed by the operator side with a `[governance]` tag. It
  skips a module until it merges, then arms itself and gates every later merge.
- Spec bugs caught before they cost attempts: 2.7 rejected CUSUM decisions inside an hour;
  2.11 excluded every order below 25k units (source says odd lots are costed, not excluded);
  event timestamp units differ per column (ts_decision ms, ts_order_submit us).
- Ops changes the same day: agent-ci classifier no longer files "builder timed out after Ns"
  as transient (2.11 burned 3 h of free retries); fxplat merge-gate full suite 900 -> 1800 s.

**Why:** spec quality is the #1 stall lever; the user wants the pipeline never idle.
**How to apply:** Phase 3 needs the same treatment (6 placeholders); write those specs while
Phase 2 builds. When 2.14 merges, add a composition truncation test to tests/leakage (field
names of SymbolData were unknown when the suite was written). See [[focus-fxplat-2026-10]].
