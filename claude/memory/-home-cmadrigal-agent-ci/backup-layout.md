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
- NOT backed up yet (2026-10-19): ollama-gateway on GitHub (no repo yet), host-config (units, drop-ins, ollama
  patches, memory, Windows scripts - my bundling was blocked by the classifier because a unit holds a password;
  needs Cristian's OK), and the weekly full-home rsync to the NAS (~300 GB incl. models, proposed, awaiting "go backup").
- F: no longer holds the 2026-10-05 WSL vhdx copy (other files there now).
