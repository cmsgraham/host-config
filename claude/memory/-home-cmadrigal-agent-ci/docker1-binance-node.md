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
- home-ip-watch on docker1 (timer every 10 min, state /var/lib/home-ip-watch/ip, ntfy env /etc/fxplat/ntfy.env root 600); test alert sent 2026-10-22.

**2026-10-27 outage root cause** — docker1 went dark Mon 2026-10-26 10:19:46 CST, all 4 feeds stale ~26 h
(binance recorder/trader/sim + swfx; future-only crypto, no FX impact). Cause: ABRUPT POWER LOSS / hard-off —
journal stops mid-op, zero shutdown sequence, journald flagged "uncleanly shut down" next boot, and NO
panic/OOM/thermal/MCE/disk error. Stayed down 26 h because it halted headless (needed monitor+keyboard to
clear an F1 prompt). Root of the F1 halt + the scrambled RTC/boot history = a dead CMOS coin cell (CR2032) →
"CMOS checksum error, press F1" every boot. FIX APPLIED by operator in BIOS: AC BACK = Always On, Wait-for-F1
= Disabled (so it self-recovers from power blips). Coin cell NOT replaced (box being retired). No intrusion
signature — the only off-LAN traffic was stale WG handshakes from the Linode hub 172.233.190.28 on :51820 (a
leftover peer from the wiped unifi-network install), harmlessly UFW-blocked; docker1 still needs no wg.
Operator will install a NEW mini PC (i3 / 8 GB) to take over / add capacity — DECIDED role: dedicated Linux
uptime/monitoring node running UPTIME KUMA (Docker, ntfy-native; PRTG rejected = Windows-only). Watches all
nodes/feeds/gateway from OUTSIDE the main PC. An independent monitor is the real fix for today's blind spot: the health check lived on the main PC
and alerted only once, so a 26 h outage stayed silent until spotted on the dashboard. Related:
[[fxplat-health-timer]], [[wireguard-home-hub]].

**2026-10-27 DECIDED**: the new i3/8GB box = a dedicated Linux monitoring node running **Uptime Kuma**
(Docker, ntfy-native; PRTG rejected, Windows-only). It watches all nodes/feeds/gateway from OUTSIDE the main
PC — the fix for today being that the on-box health check alerted only once. Not installed yet.
