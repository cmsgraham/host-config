---
name: docker-wedge-issue
description: "Recurrent Docker wedge on this machine - unkillable containers (\"did not receive an exit event\") from Chrome-in-container without init; remedy and prevention"
metadata: 
  node_type: memory
  type: project
  originSessionId: af68436e-152c-4293-ae08-7e6fae3e429b
  modified: 2026-09-01T12:37:50.522Z
---

Recurrent on msi31 (user confirmed it predates agent-ci): containers running
Chrome via a bash PID 1 become unkillable zombies — `docker rm -f` fails with
"could not kill: tried to kill container, but did not receive an exit event";
the processes are already dead but containerd lost the exit event. Un-wedging
needs a Docker engine restart, and on 2026-09-01 a restart attempt while WSL
processes were active deadlocked the entire WSL service (every `wsl` command
hung; fixed by killing stuck wsl.exe clients + service restart + WSL reboot).

**Why:** bash as PID 1 neither reaps Chrome's orphaned grandchildren nor
forwards signals; Chrome forks/crashes constantly (crashpad), zombies
accumulate, shim bookkeeping breaks. `--privileged` (unneeded) widens it.

UPDATE 2026-09-01 morning: overnight, concurrent Chrome containers caused
host-wide process-spawn exhaustion (~05:12 UTC) that killed the supervisor,
dashboard, AND broke the Claude session's shell tools permanently (file I/O
kept working). Root cause of TASK-1.4's failures: healthcheck.sh baked into
the image hardcoded ":99" while test scripts assign per-worker displays
:100+ — fixed in worktree (display-agnostic pgrep) plus a HEALTHCHECK
directive added to the Dockerfile (makes `docker inspect .State.Health`
valid, which the reviewer keeps prescribing). Requires image REBUILD to take
effect — recovery script at x-scraping-project/recover-and-relaunch.sh
(clears stale procs/containers, rebuilds, resumes + auto).

**How to apply:** always run these worker containers with `docker run --init`
(tini as PID 1) and WITHOUT `--privileged` — applied to TASK-1.4's test
scripts 2026-09-01. If wedged containers appear anyway: `docker desktop
restart` ONLY when no WSL-side validation is running; if WSL itself hangs,
kill stuck wsl.exe processes on Windows, then `wsl --shutdown`. Consider a
future task adding `--init` guidance to scraper-node/orchestrator provider
code, and updating Docker Desktop (engine 28.1.1 as of the incident). See
[[agent-ci-build-progress]].
