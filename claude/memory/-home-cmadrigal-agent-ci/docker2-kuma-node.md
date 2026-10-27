---
name: docker2-kuma-node
description: docker2 = home monitoring node (192.168.1.14), Uptime Kuma on :3001
metadata:
  type: project
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
