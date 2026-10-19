---
name: nvidia-smi-probe-trap
description: "Never run nvidia-smi in a loop from a session; each call logs 5 dxg lines, trips the gateway gpu_pv rule and arms the watchdog's host GPU reset"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 0c1852ef-3212-4405-b486-5cda3eb63786
  modified: 2026-10-16T04:47:36.135Z
---

Each `nvidia-smi` start in WSL logs 5 `misc dxg: dxgkio_escape: Ioctl failed: -22` kernel lines (measured 2026-10-15:
106 -> 111 after one call). A once-a-minute heat monitor I armed pushed the gateway's dxg rate to 2-2.7/min, the
health went `degraded (gpu_pv_errors)`, and the watchdog's next pass would have stopped the loop and run the
host GPU reset (wsl --shutdown) on a false alarm. I paused the watchdog timer for 20 min to let the window age out.

**Why:** the gateway's gpupv rule counts every dxg line; the dangerous 10-05 signature is `wait_for_completion
failed` building up, the -22 escape lines are probe noise. See [[host-crash-2026-10-05]].

**How to apply:** read GPU temps/util/memory from the gateway (`/_dash/health` -> `gpu_summary15`), never by
spawning nvidia-smi repeatedly; a single one-off call is fine. When judging a gpu_pv alert, check the line kinds
(`journalctl -k | grep dxg`) and whether my own probes line up with the bursts before acting.
