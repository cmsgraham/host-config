---
name: server-hardening-saturday
description: Cristian will run deploy/server/harden-update.sh on Sat 2026-10-24 (FX closed); phone reminder timer set; remind him if asked earlier and verify everything after
metadata:
  type: project
---

2026-10-21 server audit (fxplat-server = snoopyfrog Linode 172.238.203.34, US datacentre): solid basics (ufw default
drop, only 22/80/443, SSH keys only, MaxAuthTries 3, cloud firewall limits SSH to the admin IP, fail2ban, DB/redis not
published, secrets root 600) but 52 pending updates + reboot required, PermitRootLogin prohibit-password, emails.txt 644.
Script ~/Dukascopy/deploy/server/harden-update.sh (preflight, auto-revert on each risky step). Cristian: "run it on
weekend, remind me, don't want to break anything". Reminder: systemd --user timer remind-server-hardening Sat
2026-10-24 09:00 CST (ntfy), backlog item server-harden-update. AFTER he runs it: verify sim-v4 status, IB feed,
cTrader recorder, publisher, snoopyfrog containers. Also: fxplat on its own Linode before live trading (not chosen yet).
Binance blocks this US server for account APIs (HTTP 451) and Canada (exited 2023); Cristian declined VPN routing via home (account risk); DECISION 2026-10-21: a home mini PC in Costa Rica becomes the Binance node (backlog binance-home-node); public market data can also come from data-api.binance.vision on the server.

**Windows PC 2026-10-21:** TightVNC Server (tvnserver, was listening on 0.0.0.0:5900/5800) stopped + disabled and its HKLM Run tray entry (tvncontrol) removed at Cristian's request; remote access is RDP/WireGuard.
DONE 2026-10-24 ~18:10 CST by operator: harden-update.sh ran; kernel 6.8.0-147, PermitRootLogin no (verified), 1 package left upgradable, all fxplat containers back, fxplat.trade 200.
