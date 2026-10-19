---
name: wsl-disk-exhaustion-crash
description: "WSL VM kills that take VS Code Remote-WSL down are C: exhaustion via pagefile growth, not guest OOM — check NTFS event 141"
metadata: 
  node_type: memory
  type: project
  originSessionId: 025cf55b-64c5-455a-bf92-9d6edbbd538b
  modified: 2026-09-07T14:11:42.491Z
---

When the whole WSL2 VM dies and VS Code Remote-WSL drops, the guest journal
ends mid-line with NO shutdown sequence and NO OOM killer entry. The guest is
usually fine (16+ GB free). The kill comes from Windows.

**Diagnose from the Windows side, not the guest.** The signal is NTFS event 141
in `Microsoft-Windows-Ntfs/Operational`: "An operation failed because the disk
was full", with `Process: System` and a `Requested space` of ~30 GB — that is
the auto-managed pagefile trying to grow to back the WSL VM's memory commit.
Event 142 gives the hourly min/max free space. Volsnap deleting shadow copies
minutes before the death is a corroborating symptom. `Kernel-Power`/bugcheck
entries will be ABSENT — this is not a host crash.

On 2026-09-07 07:05: C: pagefile grew 38 GB -> 64.8 GB, C: hit **20 KB free**,
NTFS could not extend the MFT, and Hyper-V tore down the VM and started a new
one 5 s later. Guest had 16.6 GB free RAM the whole time.

**Why:** two accidental literal-path copies were eating the boot volume —
`C:\wsl.localhost\Ubuntu\home\cmadrigal\.ollama` (143 GB, a full duplicate of
the Ollama store) and `C:\192.168.1.201\MediaCenter` (23 GB). Both came from
using `C:\wsl.localhost\...` / `C:\192.168.1.201\...` instead of the UNC
`\\wsl.localhost\...` / `\\192.168.1.201\...` during the 2026-09-03 migration,
so Windows created real folders on C: instead of writing through the redirector.
Deleting them took C: from 2.7% to 29.7% free (24.9 GB -> 276.4 GB).

**How to apply:** after any WSL/host file move, check for literal `C:\` folders
named after a UNC host. Keep C: above ~15% free. The Ubuntu vhdx is NOT on C:
(it is `F:\wsl\Ubuntu\ext4.vhdx`, ~176 GB, 143 GB of it Ollama models), so guest
disk usage is a red herring here. Load spikes that drive the commit come from
model swap thrash — 29 loads / 19 evictions in 105 min on the crash morning,
because the 80b reviewer (~36 GB) and the builder cannot both stay resident.
See [[docker-wedge-issue]], [[wsl-migration-recovery]].
