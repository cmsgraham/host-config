---
name: voicelab-gpu-contention
description: 2026-10-19 Cristian's Cline project ~/voicelab (voice server + qwen3 TTS worker) uses the GPUs directly, outside the gateway; GPU-PV nvml errors spiked; pipeline paused + GPU reset in dry-run while it runs - UNDO both when he is done
metadata:
  type: project
---

2026-10-19 ~19:45 CST: dxg errors jumped (~200 in 19h vs 5-18/h before; kind "nvml" = dxgkio_escape -22, GPU-status
queries), watchdog flagged gpu_pv_degraded and requested STOP (armed for the automatic host GPU reset). Cause: Cristian's
new Cline project ~/voicelab (server.py since 19:59, workers/qwen3_worker.py) holds /dev/dxg directly - not via the
gateway/Ollama - so VRAM use is invisible to the scheduler (Oct 5 freeze trigger = swaps at 92-95% VRAM).
He chose "keep voicelab, pause the pipeline" (20:20 CST). Done: operator STOP in ~/Dukascopy/state/STOP (watchdog does
not restart over a non-watchdog STOP) + C:\Users\crist\gpu-pv-reset.dryrun (reset only logs).
**UNDO when he is done with voicelab:** rm state/STOP (watchdog restarts the loop) and delete gpu-pv-reset.dryrun.
Longer term: route voicelab's models through the gateway or give it a GPU budget; find who opens dxg with
`sudo lsof /dev/dxg`. Related [[host-crash-2026-10-05]], [[nvidia-smi-probe-trap]].
