---
name: gateway-sigterm-outage
description: 2026-10-01 the gateway got an external SIGTERM (not systemctl stop), exited 0, and Restart=on-failure left it dead 30 min; a restart.conf drop-in now sets Restart=always
metadata:
  type: project
---

On 2026-10-01 14:37 CST `ollama-gateway.service` received SIGTERM with nothing in flight (telemetry event `gateway.stopping`, "signal 15", inflight 0). The journal showed no "Stopping" line, so it was not `systemctl stop`; the unit was `Restart=on-failure`, so a clean exit 0 stayed down until found. Seconds before, an agent loop labeled "Cline" (really any ai-sdk/node client using a model alias) finished a tool-calling reply, and a 1 TiB WSL VHD (sdg) went offline with a plan9 "AcceptAsync canceled". Sender never identified.

**Why:** the gateway is the single front door for every model consumer; a silent clean exit is indistinguishable from "down" for all of them.

**How to apply:** `/etc/systemd/system/ollama-gateway.service.d/restart.conf` now sets `Restart=always` (explicit `systemctl stop` still wins). When "gateway is down": check `systemctl status`, the `events` table in `~/ollama-gateway/telemetry.db` for `gateway.stopping`, then `sudo -n systemctl start`. Related: [[gateway-rebuild-2026-09-27]], [[wsl-passwordless-sudo]], [[gateway-model-override-hijack]].
