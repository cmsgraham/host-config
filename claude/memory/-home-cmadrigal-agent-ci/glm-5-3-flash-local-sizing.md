---
name: glm-5-3-flash-local-sizing
description: "GLM-5.3-Flash (Z.ai, MIT, 321B MoE / 18B active): plain llama.cpp needs 192-256 GB RAM, but Project Maya runs it on 2x3090 at ~53 tok/s - blocked only because Maya refuses WSL2"
metadata:
  node_type: memory
  type: project
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-11-26T23:00:00.000Z
---

Researched 2026-11-03 at Cristian's request; he wants to revisit later. Candidate use: cheap escalation tier
(lower Claude dependency, [[claude-dependency-challenge]]); GLM is its own family ([[model-independence-foundation]]).

## 2026-11-26 UPDATE: Project Maya answers the "revisit later" - but not inside WSL2
Researched at Cristian's request. `github.com/mw00/project-maya` (MIT, Peasant Smith @mw00 + @needmorevram;
a fork of Strata, itself a llama.cpp fork). Per-model engines that tier experts: hottest on GPU, next in RAM,
the rest streamed from NVMe, moved as the conversation goes. This OVERTURNS the "all 320B must be resident"
premise below - the stated floor is a CC 7.0+ GPU, **32 GB RAM** and a fast NVMe (never a hard disk).
- README's own user-reported table: **2x RTX 3090 24 GB -> Maya-S24: 53.0 tok/s**; 1x 3090 Maya-M 128K ctx
  27.0; 4x 3090 Maya-S24 100.8. Quants for GLM-5.3-Flash: Maya-XS 73.4 GB, Maya-S24 94.7 GB (tuned for
  "cards of 24 GB or less"), Maya-S 96.5, Maya-M 116, Maya-L 156.3.
- **BLOCKER - verbatim in the README's "What you need": "Not WSL2."** docs/WINDOWS.md gives the reason:
  "WSL2's GPU driver pins only about 1 GB of RAM, and Maya pins tens of GB. Run `START-MAYA.bat` in Windows
  itself." So Maya cannot join the in-WSL model stack (the 2026-09-03 decision); it would have to run on
  Windows, reviving the RETIRED Windows-host path to reach the gateway.
- Second conflict: Maya pins all free RAM but ~6 GB (`MAYA_GLM_RAM_HEADROOM_GB`, default 6, raisable) and the
  pinned tier cannot be swapped. On this 64 GB box that starves the gateway, Ollama, agent-ci and the fxplat
  services. It is an exclusive-use experiment for a quiet window, not an addition to the running stack.
- Also supports DeepSeek-V4.1-Flash-1017 748B (MIT), MiniMax-M3.1-Flash 428B, Hy4-Flash 220B, Ling-3.2-air 128B.
  Serves OpenAI- AND Anthropic-compatible APIs on :8080, so it could sit behind the gateway as a backend.
- Install: `./setup.sh --model glm-maya-s24`; `./maya.sh --calibrate` (10-15 min, tunes to the hardware,
  needs the GPUs free). Flags/env: `MAYA_GLM_SPLIT`, `MAYA_GLM_RAM_GB`, `MAYA_GLM_RAM_RESIDENT`,
  `MAYA_GLM_READ_CHUNKS`, `--vram-reserve-mib`, `--parallel`, `--expert-cache auto`.

## 2026-11-03 sizing (plain llama.cpp/Unsloth, no expert streaming - superseded for Maya only)
- Model: Z.ai GLM-5.3-Flash, released late Aug 2026, MIT, 321B total / 18B active MoE, multimodal, sparse+linear
  attention, ~1.3M ctx (OpenRouter), reasoning_effort low/high/max. Vendor claims only: Terminal-Bench 2.1 84.3,
  DeepSWE 63.4, "approaching Opus 4.8"; no SWE-bench Verified. API ~$0.07 in / $0.25 out per Mtok (Z.ai listing).
- 18B active saves compute, not memory: the router picks different experts every token and layer. Without Maya's
  NVMe tiering, all 321B must be resident (VRAM + RAM); naive SSD/mmap streaming = seconds per token.
- Unsloth GGUF sizes (GB): IQ1_S 93 (top-1 agreement 71%), IQ2_XXS 102 (76%), Q2_K_XL 109 (78%), IQ3_XXS 120 (82%),
  Q3_K_XL 148 (86%), IQ4_XS 157 (88%), Q4_K_XL 200 (92%). Below 4-bit is too degraded for coding.
- This PC (checked 2026-11-03): MSI MAG B650 TOMAHAWK WIFI, 4 DIMM slots, 2x32 GB DDR5 Corsair CMH64GX5M2B6000C30
  running at 4800 (EXPO off), 64 GB total; WSL capped at 48 GB (.wslconfig), Windows keeps ~13 GB. 2x3090 = 48 GB VRAM.
- Sizing that way: IQ4_XS ~192 GB system RAM (4x48); Q4_K_XL 256 GB (4x64; check BIOS supports 64 GB DIMMs -
  WMI reports 128 GB max, often stale on AM5). The third 3090 ([[third-3090-oculink-plan]]) takes ~24 GB off the
  RAM need. Expect ~5-7 tok/s and minutes of prompt processing - overnight escalations only.
- Cheaper first step if revisited: replay ~10 recorded escalations through the API (OpenRouter/Z.ai) and score vs
  Claude; needs the operator's OK on sending fxplat code to a Chinese provider.
