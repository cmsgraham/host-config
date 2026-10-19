---
name: roadmap-and-wsl-switch
description: Planned platform work incl. completing the WSL migration; full list lives in agent-ci/ROADMAP.md
metadata: 
  node_type: memory
  type: project
  originSessionId: d4d5e3c0-0561-47b1-94a1-24f753f10ea0
  modified: 2026-09-03T03:08:13.025Z
---

2026-09-03: durable roadmap recorded at `agent-ci/ROADMAP.md`. Top items:

- **Switch the model stack to WSL** (user's explicit ask): Ollama + gateway
  still run on the WINDOWS host (WSL reaches them at 172.31.208.1:11434 via
  NAT, managed by the Windows schtasks "OllamaGateway"). Goal: move both into
  WSL so the flow is self-contained on 127.0.0.1. Plan already exists in
  `wsl-migration/PLAN.md` + `CHECKLIST.md` — it was drafted but never
  completed.
- **Builder → qwen3-coder:30b-a3b-q8_0** (armed, evaluating) and an
  **architect role** (qwen3.8:27b-64k) that plays only at PHASE BOUNDARIES:
  design tasks at phase start, holistic phase review at phase end. See
  [[agent-ci-is-a-product]].
- Phase 7+ (LinodeProvider on-demand compute), Phase 10 (encrypted account
  store), data-plane observability (Prometheus/Grafana), spec-kit upstream.

**Why:** the user is building this as durable infrastructure and wants the
whole flow local; the Windows-host gateway is the last non-WSL dependency.
**How to apply:** treat ROADMAP.md as the source of truth for planned work;
the WSL switch is a real outstanding task, not done.
