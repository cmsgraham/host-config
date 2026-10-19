---
name: third-3090-oculink-plan
description: "2026-10-19 plan (parts NOT bought): 3rd RTX 3090 24GB via OCuLink in M2_2 so builder (27b ~26GB) + reviewer (80b ~42-45GB) stay resident; shopping list and install checklist"
metadata:
  node_type: memory
  type: project
  originSessionId: 0c1852ef-3212-4405-b486-5cda3eb63786
  modified: 2026-10-19T13:42:54.810Z
---

Cristian, 2026-10-19: plans a third RTX 3090 24 GB over OCuLink ("is a plan I dont have the card or oculink").
Why it helps: 2x3090 = 48 GB but builder qwen3.8:27b @262k ~26 GB + reviewer qwen3-coder-next:80b-iq4xs ~42-45 GB
running = ~70 GB -> 56 model swaps in ~31 h (each 30-60 s, and swaps were the trigger of every dxg/GPU-PV error).
With 72 GB both stay resident (tight with 1 GiB/card OLLAMA_GPU_OVERHEAD; may need a shorter builder ctx). Does NOT
raise local landing rate (harness-bound per [[local-builder-gap-research]]); ~10-15% throughput at most.

Parts: used 3090 (check VRAM junction temps / pads), M.2->OCuLink adapter PCIe 4.0 x4 SFF-8612, Gen4 cable <=50 cm,
dock with ATX power + sync (ADT-Link F9G / Minisforum DEG1 style), 850 W PSU for the dock.
Slot: M2_2 (CPU lanes, per [[disk-layout-oculink]]) currently holds the 960 EVO = F: backup -> move it to USB or
retire it and re-home the backup. Dock outside the case (CPU already 88 C under load).

Install checklist (mine): stop the loop at a boundary + stop ollama before power-off; after boot verify 3 GPUs in
Windows + nvidia-smi (one call only - [[nvidia-smi-probe-trap]]), link width/gen; ADD the new UUID to
/etc/systemd/system/ollama.service.d/gpu-pin.conf (CUDA_VISIBLE_DEVICES pins the two current UUIDs - without it
Ollama ignores the card) and restart ollama; check both models resident (api/ps size_vram), gateway gpupv health,
watchdog GPU reset task still finds the cards; watch temps/power on first loads.
