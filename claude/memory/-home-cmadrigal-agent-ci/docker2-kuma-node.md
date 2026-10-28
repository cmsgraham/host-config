---
name: docker2-kuma-node
description: "docker2 = home monitoring node (192.168.1.14), Uptime Kuma on :3001"
metadata:
  node_type: memory
  type: project
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-10-28T13:44:18.555Z
---

docker2 (home LAN, 192.168.1.14, ssh cmsgraham@) — the i3/8 GB mini PC brought up
2026-10-27 as the monitoring node decided in [[docker1-binance-node]]. Ubuntu
24.04.5, Kingston 480 GB SSD (root LV only 100 GB; ~344 GB left UNALLOCATED in the
VG by the installer — extend with `lvextend -l +100%FREE` + `resize2fs` if ever
needed). cmsgraham has passwordless sudo (/etc/sudoers.d/cmsgraham-nopasswd) and is
in the docker group; the WSL gateway key (cmadriga@sjo-mpy9l) is installed.

Docker 29.9.2; **Uptime Kuma** runs as container `uptime-kuma` (louislam/uptime-kuma:2,
--restart=always, volume `uptime-kuma`) on http://192.168.1.14:3001. Admin account is
created in the browser (no CLI). Intended monitors: docker1 + its Binance stack, the
gateway (:11434), fxplat.trade (HTTPS + cert expiry), snoopyfrog.com, agent-ci
dashboard (:8768), fxplat-server (Linode) + its IB/sim containers.

**API access (v2):** `getMonitorList` call returns {} — use the pushed `monitorList`
EVENT instead (login via raw socket.io with admin `user:password`; the `uk1_` key only
works on /metrics, and even that returned 401 on 2026-10-27). python-socketio isn't in
any shared venv; make a throwaway `uv venv` + `uv pip install "python-socketio[client]"
websocket-client`. editMonitor/pauseMonitor/add all work over the socket.

**State after 2026-10-27 red-wall cleanup:** 32 monitors. 11 green = 7 direct checks
(gateway :11434, agent-ci dash :8765, fxplat.trade, snoopyfrog.com, pings for Home PC /
docker1 / docker2) + the 3 groups + the fxplat-server monitor. `Linode host
(fxplat-server)` (id 10) was a **ping** monitor showing false-red — the host (172.238.203.34)
blocks ICMP but is up (443/22/80 open) — so it was changed to **type=port 443**.
The **21 container push monitors (ids 13-33) are PAUSED** (grey), not fed: they never had a
heartbeat agent. To actually monitor them, deploy feeders: LAN services (binance-* on
docker1, swfx-capture) can push straight to :3001; Linode fxplat services (ib-gateway,
ib-market, paper-runner, fun-sim, oauth2-proxy, redis...) need the [[wireguard-home-hub]]
tunnel or a server-side pusher; the 7 `snoopyfrog-*` are INTENTIONALLY off since 2026-10-24
([[snoopyfrog-linode-deploy]]) so leave them paused/removed (nginx aside). Tokens are in the
session scratchpad `push_monitors.json`; resume a monitor once its feeder exists.
