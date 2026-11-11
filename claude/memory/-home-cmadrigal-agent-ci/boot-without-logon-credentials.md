---
name: boot-without-logon-credentials
description: "2026-11-11 WU reboot 03:21; S4U boot task brings WSL up but with NO Windows network creds - NAS drvfs mounts fail, GCM git push hangs (3 h, blocked hourly backups), LAN portproxy stale until logon"
metadata:
  node_type: memory
  type: project
  originSessionId: 65592fdb-22b6-4529-9491-76c88746cc4c
  modified: 2026-11-11T13:02:25.552Z
---

2026-11-11 03:21 + 03:24 CST Windows Update (MoUsoCoreWorker, then TrustedInstaller, KB5132061 Patch Tuesday)
rebooted the PC. NoAutoRebootWithLoggedOnUsers=1 did not help: no Windows session was logged on (the user signs
in by RDP and was signed out), and AUOptions=4 auto-installs. The S4U task "agent-ci WSL boot" worked (WSL up 03:25,
stamp written), and gateway/ollama/watchdog/publish/timers all came back by themselves. What broke:
- WSL started from the S4U token has no Windows network credentials: drvfs UNC mounts /mnt/nas-home, /mnt/z fail
  ("bad option", 0x2000) - already since the 2026-11-10 03:00 WSL-update restart, so NAS git pushes failed ~28 h
  (git-backup still logs "Finished": its NAS steps are failure-tolerant).
- git push to GitHub uses Windows Git Credential Manager (credential.helper = GCM .exe): with no desktop session it
  waited forever; git-backup.service hung 03:35 -> 07:00, blocking every hourly run.
- LAN portproxy (Mac / phone) pointed at the old WSL IP until the 06:47 RDP logon re-ran "agent-ci gateway LAN".
- The transient S2 bench unit died mid h-edge-05 (relaunched 07:01).
- Duplicate dashboard: system agent-ci-dashboard-fxplat.service holds :8767; user fxplat-dashboard.service crash-loops
  on "address in use" (harmless noise).
The classifier refused kill of the hung git processes; `systemctl --user stop git-backup.service` is the clean path.

**Why:** "all was down this morning" = everything reachable from outside and the backups, not the pipeline core.
**How to apply:** after a reboot, check `quser` (logged on?), mountpoint /mnt/nas-home, git-backup state, portproxy
target vs `ip -4 addr show eth0`. Durable fixes need the user: WU AUOptions 3 (notify install), Linux-side creds
(cifs + credentials file for the NAS, SSH key or store helper for GitHub), git-backup timeouts.
Related: [[windows-update-boot-resilience]], [[backup-layout]], [[gateway-lan-access-nat]].
