# host-config — msi31 (WSL2 Ubuntu 24.04) hand-built setup

Snapshot of everything that is configured by hand on this machine and lives outside the project repos
(agent-ci, fxplat, ollama-gateway). Refreshed by `sync.sh` (run hourly by git-backup.service).
Secret values (`*KEY=`, `*TOKEN=`, `*SECRET=`, `*PASSWORD=`) are redacted; credential files are never copied —
they live only in the full NAS backup (/mnt/nas-usb/msi31-backup, msi31-backup.timer).

- `etc/` — system units, drop-ins (Ollama GPU pin/headroom/kv-cache, gateway restart), fstab, wsl.conf
- `systemd-user/` — user units/timers (agent-ci watchdog, fxplat services, git-backup, history index)
- `bin/` — disk-guard, msi31-backup, fxplat health/ops scripts
- `ollama-wslquiet/` — the WSL dxg patches (P1-P3), notes, switch/rollback script, binary hashes
- `history-rag/` — conversation-history RAG code (the index DB is in the NAS backup)
- `claude/` — global CLAUDE.md and Claude Code memory notes per project
- `windows/` — GPU-PV reset task, WSL move scripts, MT5 cost recorder sources

Restore order: full NAS backup first (home, /etc, /usr/local), then use this repo to diff/review config.
