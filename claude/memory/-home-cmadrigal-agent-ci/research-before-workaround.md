---
name: research-before-workaround
description: "The user wants the established engineering solution, researched and tested, not the quickest local patch; \"I cannot be the first who hits this\""
metadata:
  node_type: memory
  type: feedback
  originSessionId: bdd81c4e-aab0-404b-852e-e2612ce47dd1
  modified: 2026-09-30T00:51:16.769Z
---

When a problem is likely common (timeouts, truncation, caching, protocol behaviour), research how
the upstream projects and comparable tools solve it BEFORE building a workaround, then verify the
findings on the user's own stack and data.

**Why:** on 2026-09-29 the first fix for the gateway's cold-prefill loop was a home-made, prompt-sized
timeout plus detection heuristics. The user replied: "I'm not convinced we are finding the more
engineering solution but the easiest one, please research on this, I cannot be the first who hits
this issue." Research showed the first fix would still have failed for Cline (its own 300 s limit)
and that Ollama already had the right switch (`truncate: false`). See [[cold-prefill-loop]].

**How to apply:** for such problems, run the research in parallel with local measurements, separate
"confirmed in source / measured here" from "inferred", name which parts of a proposal are standard
practice and which are home-made, and say plainly when an earlier fix of mine was insufficient.
Then offer the decision with the question prompt ([[reporting-style-decisions-first]]).
