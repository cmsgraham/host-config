# msi31 disaster recovery: from a blank disk to everything running

Written 2026-11-11 after a week of incidents (info-stealer 11-09, Windows Update reboots 11-10/11-11). Goal: Windows
can be reinstalled (or the PC replaced) and everything comes back from the backups, without relying on memory.

**Read this from GitHub (`cmsgraham/host-config`) or the NAS copy, not from the PC you are rebuilding.**
`windows/state/` in this repo is refreshed every hour and holds the Windows-side facts referenced below.

---

## 0. What is backed up, where

| What | Where | How often | Restores |
|---|---|---|---|
| Everything in WSL: `/home/cmadrigal` (repos, data stores, models, venvs, secrets), `/etc`, `/usr/local`, `/root` | NAS **192.168.1.200**, share `usbshare` (6 TB USB disk) → `msi31-backup/current/`, plus `current/_meta/` (dpkg selections, apt sources, crontab, df) | weekly, Sun 03:30 (`msi31-backup.timer`), ~676 GB | the whole Linux side |
| Code: fxplat, agent-ci, ollama-gateway, host-config (all branches + fxplat `refs/agent-ci/*`) | GitHub `cmsgraham/*` (private) + NAS **192.168.1.201** share `msi31-backup/git/` | hourly (`git-backup.timer`) | code, if the weekly copy is older |
| Hand-built config (units, fstab, scripts, Claude memory, **Windows tasks/config**) | this repo | hourly | review / diff / Windows side |
| Windows profile files (`C:\Users\crist`) | **only OneDrive's folder is synced; the rest is NOT backed up** (see `windows/state/profile-folders.txt`) | — | — |
| Secrets (keys, tokens, ntfy topics, NAS password) | inside the weekly NAS copy (plain files under home/etc); **the master list must be in 1Password** (§7) | weekly | §7 |

Not backed up on purpose: `~/.cache`, `~/malware-lab` (live malware), Docker images (rebuildable).

---

## 1. Before you wipe anything

1. Confirm the last weekly copy finished: `/var/log/msi31-backup.log` (or on the NAS: `msi31-backup/current/_meta/finished`).
   If the PC still runs, take a fresh one: `sudo systemctl start msi31-backup.service` (hours; incremental).
2. Run `systemctl --user start git-backup` and wait for the "git backup OK" phone alert.
3. Note what is NOT in any backup and copy it by hand if it matters: `windows/state/profile-folders.txt`
   (Downloads, Desktop evidence folders, `markov\hashpanel`, `snoopy_frog`, etc.).
4. Have 1Password on the phone (Windows / NAS / GitHub / Google logins; see §7).

---

## 2. Windows (about 2 h)

Machine facts to match: `windows/state/machine.txt` (Windows 11 Pro, MSI MAG B650 TOMAHAWK WIFI, 2× RTX 3090,
disks C: 931 GB, D: "Mecanico", F:, **G: "WSL" 954 GB SN730 = the WSL disk**).

1. Install Windows 11 Pro; computer name **MSI31**, local user **crist** (the scripts and tasks use `C:\Users\crist`).
2. Drivers: MSI B650 chipset/LAN/Wi-Fi (msi.com), **NVIDIA 617.14** (driver 32.0.16.1714; it is the version
   tested with the GPU-PV fixes, see the gateway `docs/research/2026-10-05-gpu-pv-freeze.md` before changing it).
3. Windows Update policy (admin PowerShell): `reg import windows\state\policy-windowsupdate.reg` (AUOptions=3:
   download, ask before installing; never auto-reboot).
4. Apps: `winget import -i windows\state\winget-apps.json --accept-package-agreements --accept-source-agreements`.
   Anything without a winget ID is in `windows/state/installed-programs.tsv` (install by hand if still needed).
   Must-haves: Git for Windows, VS Code (+ Remote-WSL), Docker Desktop (WSL integration), PowerToys, 1Password.
5. `.wslconfig`: copy `windows/state/wslconfig.txt` to `C:\Users\crist\.wslconfig` (NAT, 48 GB, dnsTunneling,
   autoMemoryReclaim=dropcache - each line has its reason in the file).
6. Security: re-apply the IOC block from 2026-11-10: admin PowerShell `windows\ioc-block-2026-11-10.ps1`
   (hosts entries + firewall rules; expected output `RESULT: OK`).

## 3. WSL Ubuntu on G: (about 1 h + the restore copy)

1. `wsl --install --no-distribution`, reboot, then `wsl --install -d Ubuntu-24.04`; user **cmadrigal** (uid 1000).
2. Move it to G: (the old layout was `G:\wsl\Ubuntu`): `windows\wsl-move\*.ps1`, or
   `wsl --export Ubuntu-24.04 G:\tmp.tar; wsl --unregister Ubuntu-24.04; wsl --import Ubuntu G:\wsl\Ubuntu G:\tmp.tar`
   then set the default user (`/etc/wsl.conf` `[user] default=cmadrigal`) and `wsl --set-default Ubuntu`.
3. Inside WSL: `sudo apt update && sudo apt install -y nfs-common cifs-utils rsync git`.
4. Mount the weekly copy (NFS export allows **192.168.1.119**; if the PC's LAN IP changed, edit the NFS rule in DSM on
   192.168.1.200 first):
   ```
   sudo mkdir -p /mnt/nas-usb && sudo mount -t nfs -o vers=3 192.168.1.200:/volumeUSB1/usbshare /mnt/nas-usb
   ls /mnt/nas-usb/msi31-backup/current/_meta/finished
   ```
5. Restore (order matters; `--numeric-ids` keeps owners):
   ```
   B=/mnt/nas-usb/msi31-backup/current
   sudo rsync -aH --numeric-ids $B/home/cmadrigal/ /home/cmadrigal/     # hours: ~600 GB (models, data stores)
   sudo rsync -aH --numeric-ids $B/usr/local/ /usr/local/
   sudo rsync -aH --numeric-ids $B/root/ /root/
   # /etc: do NOT copy wholesale over a fresh install; take what we built:
   sudo rsync -a $B/etc/systemd/system/ /etc/systemd/system/
   sudo cp -a $B/etc/fstab $B/etc/wsl.conf /etc/ ; sudo cp -a $B/etc/sudoers.d/. /etc/sudoers.d/
   sudo cp -a $B/etc/samba /etc/ ; sudo cp -a $B/etc/hosts /etc/hosts
   ```
   Compare the rest of `/etc` against `etc/` in this repo and copy what differs on purpose.
6. Packages: `sudo dpkg --set-selections < $B/_meta/dpkg-selections.txt && sudo apt-get dselect-upgrade -y`
   (add the apt sources from `_meta/` first: NVIDIA container toolkit, Docker, etc.).
7. `sudo systemctl daemon-reload`, then `wsl --shutdown` from Windows and open Ubuntu again.

## 4. Services (about 30 min)

1. Ollama: the patched build (`ollama-wslquiet/`, restored under `~/.local/ollama`) and models (`~/.ollama/models`)
   came back with home. `sudo systemctl enable --now ollama ollama-gateway` → `curl -s localhost:11434/` = 200.
2. User units: `systemctl --user daemon-reload` then enable what `systemd-user/` lists (timers: agent-ci watchdog,
   fxplat-health, fxplat-update, git-backup, fxplat-eventshock, claude-history-index, …; services: fxplat-publish,
   mirrors, replay). `loginctl enable-linger cmadrigal` so they run without a login.
3. System units from `etc/`: agent-ci-dashboard-fxplat, msi31-backup.timer, disk-guard, etc.
4. Docker Desktop → Settings → Resources → WSL integration → Ubuntu on.

## 5. Windows tasks that bring WSL back after a reboot (admin PowerShell)

Every task is in `windows/state/tasks/*.xml`. Re-register the ones still wanted:
```powershell
Get-ChildItem .\windows\state\tasks\*.xml | ForEach-Object {
  Register-ScheduledTask -TaskName $_.BaseName -Xml (Get-Content $_.FullName -Raw) -Force }
```
S4U / password tasks may ask for the account password on import. The essential ones:
- **agent-ci WSL boot**: starts WSL at boot with no logon (S4U).
- **agent-ci gateway LAN**: portproxy + firewall for the Mac / phone (`windows/publish-on-lan-nat.ps1`); the current
  forwards are in `windows/state/portproxy.txt`.
- **agent-ci GPU-PV reset**: the watchdog's GPU recovery (`windows/gpu-pv-reset.ps1`, `register-gpu-pv-reset.ps1`).
- HashPanel GPU PowerHelper, ThermalWatchdog/Watcher, TuringSmartScreen, ClaudeHistoryRAG-Index, VoiceLabPublish.
Skip: `OllamaGateway`, `Dukascopy update` (retired, disabled).

## 6. Check it is all back

| Check | Expect |
|---|---|
| `curl -s -o /dev/null -w '%{http_code}' localhost:11434/` | 200; gateway Overview loads at http://localhost:11434/ |
| `agent-ci --config ~/Dukascopy/config.yaml status` | "no active run", queue shown |
| `systemctl --user list-timers` | the timers from §4 with a NEXT time |
| `systemctl --user start git-backup` | phone alert "git backup OK" |
| from the Mac: `curl http://192.168.1.119:11434/` | 200 (after the gateway LAN task) |
| fxplat.trade → Overview, Eventos | data younger than a few minutes (publisher works over SSH to fxplat-server) |
| `mountpoint /mnt/nas-backup /mnt/nas-usb` | both mounted (cifs as the NAS backup user; NFS) |
| a reboot with no one logged in | WSL up (`~/.cache/wsl-boot.stamp`), backups OK, alerts arrive |

## 7. Secrets: what to re-enter, where it lives

The weekly copy brings these files back; 1Password must hold the originals in case the copy is lost.

| Secret | File (restored from the weekly copy) | If lost |
|---|---|---|
| NAS backup user `msi31-backup` | `/etc/samba/nas1.cred` (root 600) | reset the password in DSM (192.168.1.201) |
| GitHub push key | `~/.ssh/github_backup` | new key, add at github.com/settings/keys |
| fxplat server / Linode / docker1 / UniFi SSH | `~/.ssh/` (linode, cm-*, unifi_audit, id_ed25519) | Linode console (LISH) to add a new key |
| ntfy topics (operations, Eventos) | `~/.config/agent-ci/ntfy.env`, `~/.config/fxplat/eventos-ntfy.env` | new topic + resubscribe phones |
| phone approvals | `~/.config/agent-ci/approvers.env` | recreate |
| broker / MT5 / iDRAC / other apps | `~/.config/fxplat-brokers.ini`, `mt5-mcp-token`, `idrac6.env`, `snoopyfrog/*.env` | re-issue at each provider |
| fxplat.trade login (Google OAuth) | on the server: `/opt/fxplat/oauth2.env` | Google Cloud console |
| Claude Code | `~/.claude/.credentials.json` | `claude` → log in again |

**After the 2026-11-09 infection: rotate these from a clean device before they are restored anywhere.**

## 8. Known traps during a rebuild

- Starting WSL from the S4U boot task gives it **no Windows network credentials**: drvfs `\\nas` mounts and the
  Windows Git Credential Manager fail. That is why the NAS is mounted with cifs + its own user and GitHub uses SSH.
- `ruff` errors on fxplat `main` stop every pipeline task: lint before merging anything.
- The G: drive must keep free space for the WSL disk to grow (WSL dies on a full host disk; `disk-guard` watches
  the inside at 850 GB).
- Keep NAT networking (`.wslconfig`): mirrored mode never passed Windows → WSL traffic on this machine.
