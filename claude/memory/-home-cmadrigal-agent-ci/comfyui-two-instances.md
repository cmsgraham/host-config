---
name: comfyui-two-instances
description: Since 2026-11-10 ComfyUI runs as two instances (GPU0 :8188, GPU1 :8189) on the LAN for the Mac; comfy.sh drives both
metadata:
  type: project
---
Set up 2026-11-10 for the user's Mac client (192.168.1.97).
- comfyui.service = GPU 0, :8188 (drop-ins lan.conf COMFY_LISTEN=0.0.0.0, gpu0.conf COMFY_GPUS=0).
- comfyui-gpu1.service = GPU 1, :8189, own temp_gpu1/ output_gpu1/ user_gpu1 db (COMFY_EXTRA_ARGS, added to
  comfy_supervisor.py; backup .bak-2026-11-10). Input dir shared. Each leases only its own card.
- ~/comfyui/bin/comfy.sh start|stop|status covers both (the gateway's Image/Pipeline mode calls it).
- LAN: ports 8188/8189 in ~/ollama-gateway/contrib/publish-on-lan-nat.ps1 defaults; re-publish WITHOUT UAC by
  `Start-ScheduledTask 'agent-ci gateway LAN'` (elevated logon task). Firewall: 192.168.1.0/24 only.
- GPU 1 is PCIe Gen4 x2 (shares lanes with the SN730 in M2_3): model copies to it are slow; A/B 11-10: Wan split
  (low-noise + umt5 on gpu:1) 60 s vs 70 s only when Wan jobs run back to back, 83 s when alternating.
- birefnet.safetensors added (core LoadBackgroundRemovalModel/RemoveBackground; InvertMask before JoinImageWithAlpha).
- Gateway meter: GPU-lease hours per client; 11-10 fix in telemetry.lease_savings: the 4 h cap now applies only to
  'gateway restart'-ended leases (uncommitted in ~/ollama-gateway with the publish-script change).
- While ComfyUI works: gateway Image mode, claude-history-index.timer STOPPED, S2 bench paused (see [[fxplat-synthetic-known-answer]]).
- 2026-11-10: GPU 0 briefly set 250 -> 300 W, REVERTED to 250 W the same hour: 250 W is the measured efficiency optimum
  (2026-08-07 sweep: compute-bound 15.3 tok/s/W at 250 vs 14.3 at 300, +10% speed for +20% power; hashcat agreed).
  Do not raise caps for speed without the user. Mechanism for any change: at the user's request, via the HashPanel helper
  (write markov/hashpanel/data/gpu_requests/request.json {gpu_index,watts,request_id}, then
  `schtasks /run /tn "HashPanel GPU PowerHelper"`; result.json). Kept below 370 W: the 1000 W PSU budget note in
  thermal-profiles/scripts/Test-GpuThermalImpact.ps1 assumes both cards at 250 W. The boot task resets 250 W on reboot.
