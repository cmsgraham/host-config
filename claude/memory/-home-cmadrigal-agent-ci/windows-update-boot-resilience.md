---
name: windows-update-boot-resilience
description: 2026-10-14 Windows Update auto-reboot left the pipeline down 5.5 h (WSL starts only at logon); fixed with WU no-reboot policy + boot task "agent-ci WSL boot"
metadata:
  type: project
---
2026-10-14 00:33 CST TrustedInstaller restarted the PC for the October update (outside active hours 06-00). Windows was
back at 00:34 but WSL only starts at logon, so nothing ran until the 05:48 logon; TASK-9.10 was killed mid-build.

Fixed (user ran an admin PowerShell; the classifier refused my writing a boot-persistence script, so I printed it):
- HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU: NoAutoUpdate=0, AUOptions=4, NoAutoRebootWithLoggedOnUsers=1.
- Task "agent-ci WSL boot": AtStartup +30 s, S4U (no password), wsl.exe -d Ubuntu running `sleep infinity`, writes
  ~/.cache/wsl-boot.stamp. Probe passed (Running); a real boot has not tested it yet - check the stamp after the next reboot.
- Retired Windows task OllamaGateway disabled (failed at every logon, result 2).
- fxplat-ib-gateway.service had After=default.target + WantedBy=default.target -> ordering cycle dropped
  fxplat-ib-market at every boot; line commented out (backup .bak-2026-10-14).

**Why:** the user wants the pipeline back unattended after any reboot.
**How to apply:** after an unexplained outage, check Windows System log events 1074/41/6008 and `journalctl --list-boots`
first. Related: [[host-crash-2026-10-05]], [[focus-fxplat-2026-10]].
