---
name: unified-dashboard-preference
description: "User wants ONE monitoring dashboard (gateway :11434), and values pipeline views that read as a friendly human-legible conversation rather than raw status"
metadata:
  node_type: memory
  type: feedback
  originSessionId: af68436e-152c-4293-ae08-7e6fae3e429b
  modified: 2026-09-02T01:54:34.269Z
---

2026-08-31: after Phase K shipped the agent-ci dashboard on :8765, the user
said they cannot have one dashboard for each thing — monitoring must converge
into a single view rather than gateway (:11434) + agent-ci (:8765) tabs.

2026-09-01: confirmed again when the Builder/Reviewer transcript panel was
added. The user asked for "a section that looks like a chat where one model
talks to the other" and, on seeing it, said it was "more friendly". They read
these views to understand what the pipeline is doing, so legibility is a
feature, not polish.

**Why:** the user monitors everything from the gateway dashboard; per-tool dashboards fragment their workflow. They also prefer conversational/narrative renderings over raw status tables — the pipeline should explain itself.
**How to apply:** put new agent-ci monitoring in the gateway dashboard (panel under the `agentci` nav page, proxied via `/_dash/agentci`); never add a standalone dashboard. When rendering agent flow, prefer a chat/transcript shape — but keep it honest about the architecture (each builder attempt is a FRESH context with no memory; the validator is deterministic and must not look like a chat participant). See [[agent-ci-build-progress]].
