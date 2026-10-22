---
name: docker1-binance-node
description: docker1 = home Gigabyte BRIX (192.168.1.43) reinstalled 2026-10-22 as the Binance/crypto node - Ubuntu 24.04.5 unencrypted, Docker, hardened; no WireGuard needed (VPN reaches LAN via UCG-Max)
metadata:
  type: reference
---

docker1: Gigabyte BRIX GB-BKi5HA-7200 (i5-7200U 4T, 31 GB RAM, 466 GB NVMe, NO TPM, BIOS F12 boot menu / Del setup),
192.168.1.43 (wired), user cmsgraham, my ~/.ssh/id_ed25519 key, passwordless sudo (/etc/sudoers.d/90-cmsgraham).
Reinstalled 2026-10-22 (previous OS "unifi-network" Ubuntu 20.04 with a redundant UniFi controller + WireGuard peer
10.6.0.2 - wiped at Cristian's request; his controller lives elsewhere). Unencrypted on purpose (headless, no TPM ->
LUKS would wait for a passphrase every boot). Setup: LV 455 GB, sshd 00-hardening.conf (no root, no passwords),
ufw deny-in except 22 from 192.168.1.0/24 + 10.6.0.0/24, unattended-upgrades + reboot window Sat 02:30 CST
(apt-daily-upgrade.timer drop-in), Docker 29.9.2 official repo (json-file 10m x3, live-restore), tz Costa Rica.
One-time USB boot trick: `sudo efibootmgr --bootnext <SanDisk entry>` (BIOS lists USB only if plugged at POST).
VPN: home side is the UCG-Max (peer 10.6.0.11, vpn_setup/ucg-fix-vpn-routing.sh); docker1 needs no wg.
Purpose: Binance node (Binance blocks the US Linode, HTTP 451) - read-only recorder first, crypto connector later.
Related: [[server-hardening-saturday]], [[fxplat-crypto-future]], [[wireguard-home-hub]].

**2026-10-22 deployed** (operator ran redeploy-binance.sh --smoke): compose project fxplat-crypto in /opt/fxplat-crypto - fxplat-binance-recorder (public stream, healthy) + fxplat-binance-trader (TESTNET, healthy); smoke PASS on docker1 (order lifecycle + flatten). Bug: the smoke 'compose run' container did not exit after 'smoke PASS' (removed by hand) - fix in redeploy (--rm / exit code). Home mirror fxplat-binance-mirror installed (5 min -> ~/.cache/fxplat/brokers/binance{,-trader}/). Real [binance] key still -2015 from home (IP whitelist needs 143.255.29.93 / Enable Reading) -> no fee snapshot yet.
