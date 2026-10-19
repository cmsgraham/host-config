# ollama-wslquiet: patched Ollama 0.33.2 (built 2026-10-17, NOT active)

## What
`bin/ollama-wslquiet` is Ollama v0.33.2 (tag commit f96e7aa) plus two small patches
(`wslquiet.patch`, branch `wsl-discovery-quiet`):

- **P1, `server/sched.go` `waitForVRAMRecovery`.** After an unload it used to run a full
  bootstrap GPU discovery every 250 ms for up to 5 s (`waitForRecovery`). Each discovery starts
  up to three GPU-client processes. The patch runs ONE refresh at the mid-point (2.5 s). If that
  refresh shows recovery, it finishes at once. Otherwise it waits out the 5 s with no more probes,
  the same result as the old timeout path. Trade-off: recovery is seen no earlier than 2.5 s
  (it used to be about 0.25 s after it happened), and the free-memory figures logged there are up to ~2.5-5 s staler.
  The next load still runs its own discovery, so placement decisions use fresh numbers.
- **P2, `discover/llama_server.go` + `discover/native_probe.go`.** The three probe commands
  (`llama-server --verbose`, `llama-server --list-devices`, `ollama gpu-discover`) get
  `cmd.Cancel = SIGTERM` instead of exec.CommandContext's SIGKILL. The existing
  `WaitDelay` (5 s) stays as the SIGKILL fallback. On Windows nothing changes.

Built with go1.26.0 (official tarball, sha256 verified) at `~/.local/go-1.26.0`. It uses the release flags:
`-trimpath -buildmode=pie -ldflags "-w -s -X version.Version=0.33.2+wslquiet -X server.mode=release"`,
with `CGO_ENABLED=1` and `CGO_CFLAGS/CXXFLAGS=-O3`. `ollama --version` reports `0.33.2+wslquiet`.

## Why
See `~/agent-ci/docs/research/2026-10-17-ollama-discovery-dxg.md`. Every guest-kernel line
`dxgvmb_send_sync_msg: wait_for_completion failed` coincides with Ollama's
`llama-server GPU discovery watchdog timed out`, about 5.9 s after an eviction. The 5 s deadline
kills a probe in the middle of a dxgkrnl ioctl. Each short-lived GPU client in WSL2 also leaks host
NVRM state (microsoft/WSL#12756). The patch takes a slow swap from roughly 12-18 probe processes
down to about 3 and removes the polling that ran into the deadline.

Limits of P2: SIGTERM only helps a probe that handles it. llama-server's server mode does. The
`--list-devices` path and the Go `gpu-discover` subprocess die on SIGTERM much as they did on SIGKILL.
Another case is not touched: in the normal path, `llamaServerDiscoverDevices` still ends the
`--verbose` server with an explicit `cmd.Process.Kill()` (SIGKILL) once it has read `system_info`.
That is outside the agreed scope. It is a candidate P3 if Phase 1 still shows dxg lines.
P2 also has a side effect: a probe that ignores SIGTERM can now hold up a timed-out discovery for up to 5 s (WaitDelay).

## Current chain
```
ollama.service (system unit)  ExecStart=/home/cmadrigal/.local/bin/ollama serve
/home/cmadrigal/.local/bin/ollama -> /home/cmadrigal/.local/ollama/bin/ollama   (official, sha256 20cca6e2...)
/home/cmadrigal/.local/ollama/bin/ollama-wslquiet                               (patched, sha256 73917a9d...)
```
lib/ollama is found relative to the resolved executable (`os.Executable()` follows the symlink),
and the `gpu-discover` probe re-executes the same binary. Both keep working from `bin/`.

## Switch (only in an idle window: gateway in-flight empty, loop paused)
```
ln -sfn /home/cmadrigal/.local/ollama/bin/ollama-wslquiet /home/cmadrigal/.local/bin/ollama
sudo -n systemctl restart ollama.service
curl -s http://127.0.0.1:11434/api/version     # via the gateway; expect "0.33.2+wslquiet"
```

## Rollback
```
ln -sfn /home/cmadrigal/.local/ollama/bin/ollama /home/cmadrigal/.local/bin/ollama
sudo -n systemctl restart ollama.service
```
The official binary is never modified, so rollback is just the symlink plus a restart.

## Draft upstream issue (not filed)

**Title:** WSL2: VRAM-recovery polling after unload runs a bootstrap GPU discovery every 250 ms; the deadline SIGKILLs probes mid-ioctl

**Body:**

> **Environment:** Ollama 0.33.2 (code unchanged through main as of 2026-10), Linux build running in WSL2
> (kernel 6.18.54.1-microsoft-standard-WSL2), 2x RTX 3090, NVIDIA driver 617.14, frequent model swaps.
>
> **Observed:** after evicting a large model, the guest kernel logs
> `misc dxg: dxgk: dxgvmb_send_sync_msg: wait_for_completion failed: fffffe00` in the same millisecond
> as Ollama logs `llama-server GPU discovery watchdog timed out`, about 5.9 s after `evicting`. Loads still succeed.
>
> **Cause (source reading):** `unload()` clears `runner.gpus`, so every call that
> `waitForVRAMRecovery` makes to `GPUDevices`, once per 250 ms for up to `waitForRecovery` (5 s), is a full
> bootstrap discovery. Each one starts `llama-server --verbose`, `llama-server --list-devices` and
> `ollama gpu-discover` with `exec.CommandContext`. When WDDM takes more than ~5 s to return the VRAM,
> the expired context SIGKILLs whichever probe is in flight. dxgkrnl waits with
> `wait_for_completion_killable`, the ioctl returns `-ERESTARTSYS`, and the host's late reply is logged
> as above. A single slow swap starts about 12-18 GPU-client processes. Every short-lived GPU client in WSL2
> also leaks host NVRM non-paged pool that `wsl --shutdown` does not free (microsoft/WSL#12756), so
> on a box that swaps often this degrades the host as uptime grows.
>
> **Proposed fix (tested locally, patch attached):**
> 1. In `waitForVRAMRecovery`, refresh once at `waitForRecovery/2` instead of polling every 250 ms. If that
>    refresh has not seen recovery, wait out the rest of the window (same outcome as today's timeout path).
>    The cost is that convergence is detected no earlier than 2.5 s.
>    The next load runs its own discovery anyway.
> 2. Give the discovery probes `cmd.Cancel = func() error { return cmd.Process.Signal(syscall.SIGTERM) }`
>    (non-Windows), and keep `WaitDelay` as the SIGKILL fallback.
>
> Possibly better upstream: refresh only the devices the unloaded runner used, through the existing
> runners' non-bootstrap path, instead of running a bootstrap.
>
> Unit tests included: `TestWaitForVRAMRecoveryProbesOnce` (2 getGpuFn calls instead of ~9 in a 2 s
> window) and `TestDiscoveryProbeCancelSendsSIGTERM`.

## P3: `bin/ollama-wslquiet2` (built 2026-10-19, NOT active)

Ollama v0.33.2 + P1 + P2 + P3. Full diff vs v0.33.2: `wslquiet2.patch` (branch
`wsl-discovery-quiet`, second commit). Same toolchain and flags as above, version string
`0.33.2+wslquiet2`. sha256 `5a04c83d7f31958785465794d3f384d2bed7a23fb96d6bb2bbcda199e4db3f03`.

**Why.** On 0.33.2+wslquiet (2026-10-19 05:37) an eviction at 05:37:38.4 still produced a
dxg line: the single mid-point recovery probe was still running when the 5 s settle deadline
expired, and it was killed mid-ioctl at 05:37:43.4 (`dxg ... wait_for_completion failed
fffffe00`). A second `GPU discovery watchdog timed out` followed at 05:37:46.4: the hard-coded
3 s deadline of the bootstrap refresh in `discover/runner.go` (pre-load `GPUDevices`). A healthy
probe takes about 1 s, but under WDDM right after a large unload it can take several seconds.

**What.**
- **P3a, `server/sched.go`.** The one recovery probe runs with its own context
  (`vramRecoveryProbeTimeout`, 15 s, from `context.Background()`), not the 5 s settle context.
  The result is handled as before: recovered means finish now, otherwise finish at the end of
  the settle window. Trade-off: a slow probe can stretch the wait past 5 s (up to 15 s), and
  the next load waits for it.
- **P3b, `discover/runner.go`.** The bootstrap free-memory refresh in `GPUDevices` (the
  `rctx` deadline and the Metal-retry timeout, both 3 s) now uses `refreshBootstrapTimeout` = 15 s.
  The 30 s first-boot timeout is unchanged. The 3 s timeout on the *existing-runner* refresh
  (`runner.GetDeviceInfos`, an HTTP call to a live runner, no new GPU client) is also unchanged.
- **P3c, `discover/llama_server.go`.** After it reads `system_info`, the `--verbose` probe is
  now stopped by `stopDiscoveryProbe`: SIGTERM first, then SIGKILL only if the probe has not
  exited within `llamaServerDiscoveryWaitDelay` (5 s). Windows still gets an immediate Kill.
  Stderr is now drained after `system_info`, so a probe logging its normal shutdown cannot
  block on a full pipe and get pushed onto the SIGKILL path.
- Tests: `TestWaitForVRAMRecoveryProbeOutlivesSettleDeadline` (the probe context is not cancelled
  at the deadline, and its deadline is about 15 s away) and `TestStopDiscoveryProbe` (a child
  that handles TERM exits 42; a child that ignores it is killed after the grace period).
  `TestWaitForVRAMRecoveryProbesOnce` and `TestDiscoveryProbeCancelSendsSIGTERM` still pass.

**What to check after switching.** After each eviction: no `GPU discovery watchdog timed out`,
no guest-kernel `dxg ... wait_for_completion failed`, and `bootstrap discovery took` stays
below 15 s. If a probe really hangs, a load can now wait up to about 15 s plus 5 s before it
falls back to stale numbers.

### Switch to wslquiet2 (only in an idle window: gateway in-flight empty, loop paused)
```
ln -sfn /home/cmadrigal/.local/ollama/bin/ollama-wslquiet2 /home/cmadrigal/.local/bin/ollama && sudo systemctl restart ollama.service
curl -s http://127.0.0.1:11434/api/version     # expect "0.33.2+wslquiet2"
```

### Rollback
```
# to P1+P2 (wslquiet)
ln -sfn /home/cmadrigal/.local/ollama/bin/ollama-wslquiet /home/cmadrigal/.local/bin/ollama && sudo systemctl restart ollama.service
# to the official 0.33.2
ln -sfn /home/cmadrigal/.local/ollama/bin/ollama /home/cmadrigal/.local/bin/ollama && sudo systemctl restart ollama.service
```
Note (2026-10-19): the symlink already pointed at `ollama-wslquiet`, so the "NOT active" in
the first heading is out of date. P1+P2 is the build that is live now.
