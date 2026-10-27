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
**UNDONE 2026-10-20 01:22 CST** (automatic, after 30 min voicelab idle): STOP removed, gpu-pv-reset.dryrun deleted. Since 2026-10-19 the gateway GPU lease (gpulease.py, b21cad1) arbitrates voicelab vs Ollama.
Longer term: route voicelab's models through the gateway or give it a GPU budget; find who opens dxg with
`sudo lsof /dev/dxg`. Related [[host-crash-2026-10-05]], [[nvidia-smi-probe-trap]].

**2026-10-27 — the FULL voice-job handoff (freeing the GPU is only 1 of 3 steps).** The Mac generator
drives the lab over the LAN and polls every 30s for 4h; "enable the voice generator" needs ALL of:
1. FREE GPU0: `agent-ci stop` (Dukascopy), wait for the in-flight 80b review to end, then unload the reviewer
   via the gateway: `curl -s -X POST http://127.0.0.1:11434/_dash/action -d '{"action":"unload","model":"qwen3-coder-next:80b-iq4xs"}'`
   (this clears keep-warm too; the arbiter refuses to evict a kept-warm model = the "busy" the lab sees).
   Arm the watchdog dry-run: `touch /mnt/c/Users/crist/gpu-pv-reset.dryrun`.
2. voicelab server: a SYSTEM service `sudo systemctl status voicelab` (NOT --user), binds the WSL LAN IP
   172.31.223.42:8765 (reachable from the Mac via Windows portproxy 192.168.1.119:8765). Usually already up.
3. The ACTUAL blocker on 2026-10-27: the Mac uses the `/vs/tts` route, which proxies to a **VoiceStudio
   Docker sidecar at 127.0.0.1:3900 on GPU1 (12GB)** — start it with `~/voicestudio/bin/vs.sh start`.
   Freeing GPU0 does nothing if VoiceStudio is down (every /vs/tts -> 503). Confirm: `vs.sh status` health 200,
   container "healthy", then voicelab log shows `POST /vs/tts ... 200`. GPU0 then does the voxcpm2 compute
   (~96% util, ~20GB), GPU1 holds VoiceStudio's 12GB. vs.sh's gateway lease-helper (vs_lease.py) is flaky when
   launched from a non-interactive shell (dies -> "vs_lease stopped"); with the pipeline stopped GPU1 is
   effectively dedicated so it still runs, but the formal lease may not hold.
UNDO when done (GPU idle, no /vs/tts ~20min): `agent-ci resume` (Dukascopy) + `rm /mnt/c/Users/crist/gpu-pv-reset.dryrun`.
Diagnose a non-start by the CHAIN: gateway /api/gpu/status (GPU free?) -> voicelab log (Mac hitting /vs/tts? what code?)
-> POST /vs/tts body (names the missing hop, e.g. "VoiceStudio is not reachable ... start it with vs.sh start").
