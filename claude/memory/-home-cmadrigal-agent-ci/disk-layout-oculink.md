---
name: disk-layout-oculink
description: Planned 2026-10-05 disk reshuffle for a 3rd RTX 3090 over OCuLink on the MAG B650 TOMAHAWK WIFI; WSL moves to a spare 1TB WD SN730
metadata:
  node_type: memory
  type: project
  originSessionId: 55bd64a2-66e1-476a-8bda-736c6625733c
  modified: 2026-10-06T00:46:50.468Z
---

Board: MSI MAG B650 TOMAHAWK WIFI, Ryzen 9 9900X. M2_1 and M2_2 are CPU PCIe 4.0 x4; M2_3 is chipset and
SHARES bandwidth with PCI_E2 (both drop to x2 when both are populated — why GPU 1 runs x2 today).
Disks 2026-10-05: C: WD SN750 SE 1TB (Windows), F: Samsung 960 EVO 250GB (WSL vhdx, sparse), WD SN750 SE
500GB (old native Ubuntu, 3 Linux partitions, no letter), D: HGST 1TB SATA HDD.

Plan the user is following: a 3rd 3090 via an M.2→OCuLink adapter (user said the "third" slot); the user found a
spare WD SN730 1TB. Target: C: SN750 1TB + SN730 1TB for WSL (`wsl --manage Ubuntu --move`), pull the 960 EVO and
the 500GB. Advice given: put the OCuLink in a CPU slot (M2_2) rather than M2_3, otherwise GPU 1 and GPU 3 share
a chipset x4. After the move: raise the disk guard, check SN730 wear (admin
`Get-StorageReliabilityCounter`), check the new GPU's link width. See [[fxplat-80b-hand-registered]].

**Progress 2026-10-05 19:15 CST:** the SN730 is installed in M2_3 (disk 2; it arrived with old GPT partitions). Slot
map from PCIe paths: M2_1 = SN750 1TB C:, M2_2 = 960 EVO F: (WSL), M2_3 = SN730. Move scripts are in
`C:\Users\crist\wsl-move\`: 1-prepare-sn730.ps1 (shows partitions, wipes only after a typed YES, NTFS G:),
2-move-wsl.ps1 (wsl --shutdown, robocopy ext4.vhdx F:->G:, sets the HKCU Lxss BasePath to `G:\wsl\Ubuntu`,
F: kept as the backup), 3-rollback.ps1. Sparse VHD deliberately NOT enabled (WSL gates it behind --allow-unsafe).
The guest ext4 is already 1007G virtual, so no resize is needed. After the move: raise the disk guard threshold in
/usr/local/bin/disk-guard.sh, check SN730 wear, and install NVIDIA 617.14 (still 610.88 after the first reboot).

**Done 2026-10-05 19:41 CST:** WSL Ubuntu runs from `G:\wsl\Ubuntu\ext4.vhdx` (SN730, NTFS "WSL", 954 GB).
F: copy untouched since 19:23:49, kept as the cold backup (3-rollback.ps1 points back at it). The disk guard now
trips at 850G. Gotcha: WSL distros share one VM, so `/proc/uptime` is the VM's (Docker Desktop booted it 16 min
earlier); the gateway's GPU-PV boot-settle window now starts at max(VM boot, PID 1 start). Still open: SN730 wear
check, NVIDIA 617.14, and the OCuLink in M2_2 (pull the 960) when it arrives.
Boot fix 2026-10-05: the old native Ubuntu's GRUB lived on Windows' ESP (HarddiskVolume1) and was first in the
firmware order; 4-fix-boot.ps1 deleted both "ubuntu" firmware entries and \EFI\ubuntu, so {fwbootmgr} = {bootmgr} only.

2026-10-05 C: cleanup: deleted rockyou2021.txt, LM Studio (app+models), comfyui, the Steam games; Docker pruned to empty. C: 195 -> 372 GB free. Left: Docker's 35 GB docker_data.vhdx (empty; user to "Clean / Purge data"). Adobe 2025 uninstalled by the user (C: 391.6 GB free after). Keep pagefile.sys and Dukascopy on C.

Measured 2026-10-05 21:40 CST: the SN730 in M2_3 links at **x2 gen3** (chipset, shared with PCI_E2) -> 1.5-1.6 GB/s
direct-I/O reads of model blobs; the 960 EVO in M2_2 was x4 gen3 (CPU). The move bought capacity, not speed: 27b load
median 30 s before vs 28 s after (n=3). If load times ever matter, the SN730 belongs in a CPU slot (M2_2 competes with
the OCuLink plan). **Decided 2026-10-05: the user accepts this layout -- SN730 stays in M2_3 at x2; do not re-raise.**
