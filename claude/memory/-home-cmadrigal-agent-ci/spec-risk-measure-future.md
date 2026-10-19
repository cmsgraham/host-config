---
name: spec-risk-measure-future
description: 2026-10-15 Cristian asked how to measure risky specs and decompose them for local builds - future design work, not started
metadata:
  type: project
---
Cristian (2026-10-15) wants, for FUTURE designs: a way to know at design time which specs are risky, and how to decompose risky ones so the local builder (qwen3.8:27b) lands them instead of routing to Claude. Not for now.

Proposed (not built): (1) recalibrate agent_ci/contour.py on fxplat's ~150 task outcomes - its weights came from snoopy_frog 2026-09-07 with the old 30b builder; (2) add a coupling term (importers of changed modules via git/modules.py, shared contracts like the cost model / schemas, "bit-identical" requirements, protected paths); (3) machine-check spec claims and hand values before release (see [[spec-given-claims-trap]]); (4) decomposition patterns: expand/contract (schema first, consumers one by one, remove old), characterization tests first, pure logic separate from wiring, test migrations batched mechanically, cite an existing module to imitate.

**Why:** fxplat 2026-10-14 failures were coupling and spec-correctness (v4 flip broke 172 tests; 3.102a self-contradiction; 3.103 wrong hand values), not size.
**How to apply:** when he says "let's do the risk measure", start with the recalibration analysis (no model needed), then the coupling term.
