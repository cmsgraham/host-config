---
name: ollama-wslquiet-patch
description: Since 2026-10-17 12:17 Ollama runs a locally patched 0.33.2+wslquiet (fewer GPU probes per model swap) to stop WSL dxg host leaks; switch/rollback script and Phase 0/1 measurement
metadata:
  node_type: memory
  type: project
  originSessionId: 0c1852ef-3212-4405-b486-5cda3eb63786
  modified: 2026-10-17T18:18:04.247Z
---

Ollama runs ~/.local/ollama/bin/ollama-wslquiet (0.33.2+wslquiet, patch ~/.local/ollama/wslquiet.patch, README
WSLQUIET.md; Go 1.26.0 at ~/.local/go-1.26.0). Switched 2026-10-17 12:17 CST by me with Cristian's explicit OK
("run it for me i approve") — the classifier blocks the swap without that. Both 3090s detected after the switch.
Patch: waitForVRAMRecovery probes once at mid-window instead of every 250 ms (each probe = 3 GPU-client processes);
probes get SIGTERM before the WaitDelay SIGKILL. Research: ~/agent-ci/docs/research/2026-10-17-ollama-discovery-dxg.md.

Phase 0 (official binary, 07:54-10:54): a slow swap launched ~30 GPU-client processes in 8.6 s; Windows NVIDIA
non-paged pool outstanding allocations crept +535 in 2.5 h in the same model state (~5 per probe process, matches
microsoft/WSL#12756). Phase 1 logging: scratchpad phase1/ (pool.csv + exec.data), session-scoped.
Open P3 if dxg lines persist: the normal discovery path still SIGKILLs the --verbose probe after system_info.

Switch/rollback (waits for a safe moment): `~/.local/ollama/switch-wslquiet.sh [--rollback]`. Re-apply the patch on
any Ollama upgrade (upstream code unchanged through v0.40.6; draft upstream issue in WSLQUIET.md, not filed).

**Why:** host-side GPU-PV degradation froze the host on 10-05; probes were the remaining short-lived GPU clients.
**How to apply:** an Ollama upgrade silently drops the patch — rebuild it. Related: [[host-crash-2026-10-05]],
[[nvidia-smi-probe-trap]].

**2026-10-19 07:33 CST: switched to 0.33.2+wslquiet2 (P3, operator-approved)** — recovery probe has its own 15 s
context (not cut at the 5 s settle deadline), bootstrap discovery deadline 3 s -> 15 s, the --verbose probe gets
SIGTERM before kill. Binary ~/.local/ollama/bin/ollama-wslquiet2, patch wslquiet2.patch. Before P3 (P1/P2 only):
1 dxg wait_for_completion in ~41 h (was 8/30 h unpatched). Rollback: symlink to ollama-wslquiet (P1/P2) or ollama.
