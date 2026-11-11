#!/usr/bin/env bash
# Copy the machine's hand-built setup (units, drop-ins, scripts, patches, Claude memory) into this repo.
# Secrets never land here: *KEY=/TOKEN=/SECRET=/PASSWORD= values are redacted; creds files are not copied.
set -euo pipefail; shopt -s nullglob
R=$(cd "$(dirname "$0")" && pwd)
redact() { sed -E 's/((KEY|TOKEN|SECRET|PASSWORD)[A-Z_]*=)[^" ]+/\1<redacted>/g'; }
cp_r() { mkdir -p "$R/$2"; for f in $1; do [ -f "$f" ] && redact < "$f" > "$R/$2/$(basename "$f")"; done; return 0; }

cp_r "/etc/systemd/system/*.service /etc/systemd/system/*.timer /etc/fstab /etc/wsl.conf" etc
for d in /etc/systemd/system/*.service.d; do cp_r "$d/*.conf" "etc/systemd/$(basename "$d")"; done
cp_r "$HOME/.config/systemd/user/*.service $HOME/.config/systemd/user/*.timer" systemd-user
for d in "$HOME"/.config/systemd/user/*.d; do cp_r "$d/*.conf" "systemd-user/$(basename "$d")"; done
cp_r "/usr/local/bin/*.sh $HOME/.local/bin/fxplat-*" bin
cp_r "$HOME/.local/ollama/*.patch $HOME/.local/ollama/*.md $HOME/.local/ollama/*.sh" ollama-wslquiet
sha256sum "$HOME"/.local/ollama/bin/* > "$R/ollama-wslquiet/binaries.sha256"
cp_r "$HOME/.claude/history-rag/*.py $HOME/.claude/history-rag/README.md" history-rag
cp_r "$HOME/.claude/CLAUDE.md" claude
for m in "$HOME"/.claude/projects/*/memory; do
  p=$(basename "$(dirname "$m")"); mkdir -p "$R/claude/memory/$p"
  for f in "$m"/*.md; do redact < "$f" > "$R/claude/memory/$p/$(basename "$f")"; done
done
W=/mnt/c/Users/crist
cp_r "$W/*.ps1" windows
cp_r "$W/wsl-move/*.ps1" windows/wsl-move
MT=$W/AppData/Roaming/MetaQuotes/Terminal/53785E099C927DB68A545C249CDBCE06/MQL5
cp_r "$MT/Scripts/*.mq5 $MT/Services/*.mq5" windows/mt5
# 2026-11-11 (disaster-recovery prep): Windows-side config - scheduled tasks as importable XML, .wslconfig, WSL
# registration, port forwards, our firewall rules, hosts, Windows Update policy, machine facts, winget app list.
mkdir -p "$W/.host-config" && cp "$R/windows-tools/snapshot.ps1" "$W/.host-config/snapshot.ps1"
if timeout 600 powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'C:\Users\crist\.host-config\snapshot.ps1' \
     -Out 'C:\Users\crist\.host-config\state' >/dev/null 2>&1; then
  rm -rf "$R/windows/state"; mkdir -p "$R/windows/state/tasks"
  for f in "$W"/.host-config/state/*.*; do redact < "$f" | tr -d '\r' > "$R/windows/state/$(basename "$f")"; done
  for f in "$W"/.host-config/state/tasks/*; do redact < "$f" | tr -d '\r' > "$R/windows/state/tasks/$(basename "$f")"; done
else
  echo "sync.sh: Windows snapshot failed or timed out (kept the previous one)" >&2
fi
