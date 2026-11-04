---
name: glm-5-3-flash-local-sizing
description: "GLM-5.3-Flash (Z.ai, MIT, 320B MoE / 18B active) researched 2026-11-03 - does not fit locally; RAM sizing for a future upgrade; revisit later"
metadata:
  node_type: memory
  type: project
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-11-04T03:44:40.302Z
---

Researched 2026-11-03 at Cristian's request; he wants to revisit later. Candidate use: cheap escalation tier
(lower Claude dependency, [[claude-dependency-challenge]]); GLM is its own family ([[model-independence-foundation]]).

- Model: Z.ai GLM-5.3-Flash, released late Aug 2026, MIT, 320B total / 18B active MoE, multimodal, sparse+linear
  attention, ~1.3M ctx (OpenRouter), reasoning_effort low/high/max. Vendor claims only: Terminal-Bench 2.1 84.3,
  DeepSWE 63.4, "approaching Opus 4.8"; no SWE-bench Verified. API ~$0.07 in / $0.25 out per Mtok (Z.ai listing).
- 18B active saves compute, not memory: the router picks different experts every token and layer, so all 320B must
  be resident (VRAM + RAM); SSD/mmap streaming = seconds per token, useless for agent prompts.
- Unsloth GGUF sizes (GB): IQ1_S 93 (top-1 agreement 71%), IQ2_XXS 102 (76%), Q2_K_XL 109 (78%), IQ3_XXS 120 (82%),
  Q3_K_XL 148 (86%), IQ4_XS 157 (88%), Q4_K_XL 200 (92%). Below 4-bit is too degraded for coding.
- This PC (checked 2026-11-03): MSI MAG B650 TOMAHAWK WIFI, 4 DIMM slots, 2x32 GB DDR5 Corsair CMH64GX5M2B6000C30
  running at 4800 (EXPO off), 64 GB total; WSL capped at 48 GB (.wslconfig), Windows keeps ~13 GB. 2x3090 = 48 GB VRAM.
- Sizing (experts offloaded to RAM, builder unloaded while it runs; +~15 GB KV/buffers, +~25 GB other WSL load,
  +13 GB Windows): IQ4_XS needs ~192 GB system RAM (4x48); Q4_K_XL needs 256 GB (4x64; check the board's BIOS
  supports 64 GB DIMMs - WMI reports 128 GB max, often stale on AM5). The third 3090 ([[third-3090-oculink-plan]])
  takes ~24 GB off the RAM need. Expect ~5-7 tok/s generation (dual-channel DDR5, 4 DIMMs run slower) and slow
  prompt processing (long agent prompts: minutes) - fine for overnight escalations, not for interactive use.
- Cheaper first step if revisited: replay ~10 recorded escalations through the API (OpenRouter/Z.ai) and score vs
  Claude; needs the operator's OK on sending fxplat code to a Chinese provider.
