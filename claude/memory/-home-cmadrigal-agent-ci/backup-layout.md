---
name: backup-layout
description: 2026-10-19 where everything is backed up - GitHub (agent-ci, fxplat) + NAS bare repos (\\nas1\home, all 3 repos incl. gateway + pipeline refs) hourly via git-backup.timer; what is still NOT backed up
metadata:
  type: project
---

Cristian, 2026-10-19: "scared we lose this computer or disk and lose all this progress" - wants everything on GitHub AND the NAS.
- git-backup.timer (user unit, hourly): pushes Dukascopy/agent-ci/ollama-gateway `--all` + fxplat `refs/agent-ci/*`
  (attempt/escalation snapshots = replay-bench data) to bare repos in `\\nas1\home\msi31-backup\git\` (mounted
  /mnt/nas-home via /etc/fstab drvfs; ExecStartPre mounts it; NAS pushes are "-" so an outage never blocks GitHub),
  then fxplat main + agent-ci master to GitHub (cmsgraham/fxplat, cmsgraham/agent-ci, private).
- NAS shares: the Seagate 6TB USB drive on the NAS was HFS+ with a corrupt catalog (writes failed "File exists"); Cristian reformatted it ext4 2026-10-19 -> share `6TB` again (renamed in DSM; on the NAS it is /volumeUSB1/usbshare; 5.5 TB free), mounted /mnt/nas-usb over NFSv3 (fstab; DSM rule for 192.168.1.119 = PC LAN IP, Sin asignación/no squash, async, non-privileged ports) - owners/perms/symlinks preserved, 111 MB/s (gigabit line rate); folder msi31-backup/ = target for the weekly full copy. NAS SSH: cmsgraham@192.168.1.200 -p 10022 (my ed25519 key; sudo needs his password).
  `home` and `Main` (internal volume, 4 TB free) are writable.
  /etc/fstab also had a pre-existing `//192.168.1.201/main /mnt/z` (the Z: NAS drive), not mounted.
- Weekly full backup (2026-10-19, approved "go backup"): /usr/local/bin/msi31-backup.sh via msi31-backup.timer
  (system, Sun 03:30): rsync -aH --numeric-ids of /home/cmadrigal (minus ~/.cache, pycache), /etc, /usr/local, /root
  -> /mnt/nas-usb/msi31-backup/current + _meta (dpkg selections, crontab, df); log /var/log/msi31-backup.log;
  ntfy alert on failure via `agent-ci notify`. First run 2026-10-19 09:49, ~10 MB/s on small files (idle priority).
- host-config repo ~/host-config (sync.sh redacts KEY/TOKEN/SECRET/PASSWORD values; units, drop-ins, fstab, bin,
  ollama patches, history-rag code, CLAUDE.md + all memory, Windows scripts); refreshed + pushed hourly by git-backup.
- GitHub repos cmsgraham/ollama-gateway + cmsgraham/host-config: remotes set, pushes in git-backup ("-" prefixed)
  but the REPOS DON'T EXIST until Cristian creates them - the classifier denied creating them via the API with the
  stored git credential (2026-10-19).
- F: no longer holds the 2026-10-05 WSL vhdx copy (other files there now).
- 2026-11-05: git-backup "timeout" failures 11-04 06:08 .. 11-05 10:20 were NOT failed pushes (all pushes done,
  "Everything up-to-date"): a leftover background `gc --auto` on the 9p/SMB NAS repo (pack-refs rename denied) did
  not exit within TimeoutStopSec 90 s under host memory pressure. Set receive.autogc=false + gc.auto=0 on all four
  NAS bare repos. fxplat-health now alerts when no clean run in 3 h. GitHub ollama-gateway/host-config still absent.
