---
name: host-crash-2026-10-05
description: "2026-10-05 10:45 CST whole-machine freeze = host NVIDIA/WDDM driver stopped answering WSL's GPU paravirt (dxgkrnl) after a morning of model-swap failures at near-full VRAM (80b reviewer + 27b at 262144); watchdog auto-recovered fxplat 5 min after boot"
metadata:
  node_type: memory
  type: project
  originSessionId: 3a91d4ce-6c57-429b-bb07-fa1f0b28fae3
  modified: 2026-10-05T17:11:59.958Z
---

On 2026-10-05 the Windows host froze (no bugcheck, no TDR event, no dump; last event-log
write 10:44:55, user keypress logged 10:47:18, reset ~10:49:50 CST). WSL kept running to the
reset. Not thermal (GPU 60-72 C, only SwPowerCap), not disk, not guest OOM.

Mechanism: the host GPU driver stopped answering WSL's dxgkrnl paravirt calls. Guest kernel
logged 9,454 `misc dxg` errors in that boot (`dxgvmb_send_sync_msg: wait_for_completion
failed: fffffe00` = caller killed by timeout; `process_completion_packet: did not find
packet` = late host replies; `create_existing_sysmem: get_user_pages_fast failed` + `-12` =
pinned-memory ENOMEM; `create_hwqueue failed` at 10:41). Every burst coincided with an
Ollama model swap at near-full VRAM: 06:15 (evict gemma3, load 80b reviewer -> 22.6+20.5 GiB
of 2x24), 08:06 (evict 80b, load 27b), 10:40 (27b reload; host dead 5 min later). Gateway
`gpu.unavailable` (nvidia-smi returned no GPU): 0 before 2026-10-04 21:47, 5 that night,
75 on 10-05. Also a WSL kernel WARNING (bug) at drivers/hv/dxgkrnl/dxgvmbus.c:3095
`dxgvmb_send_wait_sync_object_gpu`, PID llama-server, 5x in that boot and 3x right after
reboot while the 27b loaded (kernel 6.18.33.2-microsoft-standard-WSL2). vmwp (the WSL VM)
holds ~2.2 GiB "shared GPU memory" per GPU on the host even at 17/24 GiB VRAM used.

What changed before it started: 80b reviewer hand-registered 10-04 (swap-heavy day one),
27b builder moved to the full 262144 window on 10-05 06:35 (64 requests at 262144 that
boot). Stack otherwise unchanged for weeks (NVIDIA 32.0.16.1088 since 7/29, dxgkrnl.sys
26100.9444 since 9/8, WSL 2.7.12 since 9/1; 26H2 enablement 10-03 kept 26100 binaries).

Recovery was automatic: WSL rebooted 10:55, the 15-min user watchdog cleared the stale
`supervisor.lock`, started `auto`, TASK-2.6 restarted with the builder's untracked files
kept. Only the in-flight attempt was lost.

**Why:** first full-machine freeze since the fxplat model rotation (80b / 27b@262144 /
gemma3 / 8b) began; the signals were visible for 4.5 h before the freeze.

Root cause confirmed upstream (microsoft/WSL#41701, #40732, #41224; same driver 610.88 and
kernel 6.18.33.2): HOST-side GPU-PV state degrades with host uptime, survives `wsl --shutdown`,
clears only with `pnputil /restart-device` on the GPU or a reboot. The gateway amplified it
(two nvidia-smi per 5 s, 6 s kill timeout). The user REFUSED capacity cuts (smaller window,
fewer models) as a fix -- see [[research-before-workaround]]. Built 2026-10-05 instead:
gateway `gpupv.py` (streamed nvidia-smi, kernel dxg follower, `gpu_pv_*` health rules, GPUs
page section, `pv_samples`), watchdog `--host-gpu-reset-cmd` -> Windows task "agent-ci GPU-PV
reset" (boundary stop first, 6 h cooldown), `OLLAMA_GPU_OVERHEAD` 1 GiB. Analysis + update
experiment protocol: agent-ci/docs/research/2026-10-05-gpu-pv-freeze.md.

**How to apply:** after any freeze read `journalctl -b -1 -k | grep -c dxg` and the gateway's
GPUs page "Host GPU link" first. Never propose shrinking models/windows for this; the answers
are the GPU reset (automatic now), headroom, and the driver/WSL update experiment. Dry-run
the reset task with `%USERPROFILE%\gpu-pv-reset.dryrun` before trusting a change to it.
See [[watchdog-role]], [[fxplat-80b-hand-registered]], [[focus-fxplat-2026-10]].

**Contributing load (found the same afternoon):** TASK-2.6's builder timed out at 10:05 CST and
agent-ci ABANDONED the conversation (thread kept running) while a retry started a second one;
request rate doubled and the GPUs had no idle gap for the 40 min before the freeze (and the CPU
spin-polled at ~88 C, measured on a repeat that afternoon). The GPU-link errors predate it by 4 h,
so: degraded host GPU path = root, orphan load = last push. Builder stop fixed in agent-ci 4e61c64.
After a freeze also check events.jsonl for builder_done "timed out" followed by builder_start.
