---
name: docker-wsl-socket-proxy
description: docker-desktop-proxy.service DEADLOCKED the engine (ETXTBSY) and was disabled 2026-09-07; the real fix was EnableIntegrationWithDefaultWslDistro
metadata: 
  node_type: memory
  type: project
  originSessionId: 025cf55b-64c5-455a-bf92-9d6edbbd538b
  modified: 2026-09-07T14:11:25.783Z
---

`docker` inside Ubuntu is not a daemon: `/usr/bin/docker` symlinks into
`/mnt/wsl/docker-desktop/cli-tools/`, and `/var/run/docker.sock` is created by
`docker-desktop-user-distro proxy`, which Docker Desktop injects into each
integrated distro.

**The 2026-09-06 unit was wrong and is now DISABLED — do not re-enable it.**
`/etc/systemd/system/docker-desktop-proxy.service` (file still on disk,
disabled 2026-09-07) ran the proxy binary directly off `/mnt/wsl`, which is
tmpfs SHARED between distros, with `Restart=always` and
`TimeoutStartSec=infinity`. A running process pins that binary, so Docker
Desktop's bootstrap could never overwrite it:

    Error: preparing environment: copying wsl distro proxy binary:
    open /mnt/host/wsl/docker-desktop/docker-desktop-user-distro: text file busy

Perfect deadlock — the engine could not start, so the socket the unit waited
for could never appear, so the unit held the binary forever. The `docker-desktop`
distro sat `Stopped` while Docker Desktop showed ~11 running Windows processes.

**The actual root cause** was a Docker Desktop setting, not injection timing:
`EnableIntegrationWithDefaultWslDistro: false` in
`%APPDATA%\Docker\settings-store.json`. Ubuntu is the DEFAULT distro, so its
integration is gated by that toggle; the `EnabledWslDistros: ["Ubuntu"]` entry
does NOT cover the default distro. With the toggle off, the integration hook
created the symlinks every boot but nothing ever populated `cli-tools/`.

**Why:** this cost two builder attempts and two reviewer passes on 2026-09-06
(see the comment at `agent_ci/validation/classify.py:31`), then a full morning
on 2026-09-07 — and the "fix" written for it became the thing blocking recovery.

**How to apply:** set `EnableIntegrationWithDefaultWslDistro: true`. Edit that
JSON only with Docker Desktop STOPPED, and write it **without a BOM** —
PowerShell 5.1 `Set-Content -Encoding UTF8` adds one and Docker dies with
`invalid character 'ï' looking for beginning of value`; use
`[System.IO.File]::WriteAllText($f,$json,(New-Object System.Text.UTF8Encoding($false)))`.
Root inside the distro without a sudo password: `wsl.exe -d Ubuntu -u root -e ...`.
Verify with `docker info --format '{{.ServerVersion}}'` (rc=0) and `wsl -l -v`
showing `docker-desktop  Running`. See [[docker-wedge-issue]],
[[agent-ci-failure-modes]], [[wsl-disk-exhaustion-crash]].

## Second failure mode, 2026-09-09: the VHDX was still locked at WSL restart

Same symptom as the toggle bug — `docker` not found, `/var/run/docker.sock`
missing, `/mnt/wsl/docker-desktop/cli-tools/` EMPTY — but a completely
different cause, and `EnableIntegrationWithDefaultWslDistro` was still `true`.

`%LOCALAPPDATA%\Docker\log\host\com.docker.backend.exe.log` named it exactly:

    wsl.exe -d ubuntu -e sh -c cat - > ~/.docker/config.json failed:
    Failed to attach disk 'F:\wsl\Ubuntu\ext4.vhdx' to WSL2: The process
    cannot access the file because it is being used by another process.
    Error code: Wsl/Service/CreateInstance/MountDisk/HCS/ERROR_SHARING_VIOLATION
    -> distro agent Ubuntu exited unexpectedly

Docker Desktop's per-distro integration agent runs during WSL start; if the
previous VM still holds `ext4.vhdx`, the agent dies and **does not retry**. The
engine itself comes up fine (`engine linux/wsl is running`), so Docker Desktop
looks healthy on Windows — ~10 processes, GUI normal — while Ubuntu has no
socket at all. A modal dialog waits on the Windows desktop offering "Restart
the WSL integration"; nothing in WSL surfaces it.

**Fix (no GUI needed, and it does not need the settings file touched):**

    "/mnt/c/Program Files/Docker/Docker/resources/bin/docker.exe" desktop restart

Then wait for `/var/run/docker.sock`. Took under a minute; `agent-ci doctor`
went straight back to READY.

**How to apply:** after any `wsl --shutdown` or host reboot, check `docker info`
BEFORE starting an overnight run — every snoopy task's suite needs Postgres, so
this blocks the entire queue while looking like nothing is wrong. Read the
backend log rather than assuming the toggle regressed: the two causes present
identically from inside WSL. See [[docker-wedge-issue]], [[agent-ci-conventions]].
