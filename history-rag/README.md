# claude-history RAG

Local RAG over all Claude Code conversation transcripts, embedded and summarized on the
local GPUs via the Ollama gateway, served to every Claude Code window as a user-scope MCP server.

**Since 2026-09-29 it runs inside WSL (Ubuntu) at `~/.claude/history-rag`** and indexes BOTH homes:
the Linux one (`~/.claude/projects`, native WSL sessions) and the Windows one
(`/mnt/c/Users/crist/.claude/projects`, plus Cline's task store under AppData). Before that it ran on
Windows and was blind to every WSL session. The Windows copy in `C:\Users\crist\.claude\history-rag`
is retired (its `indexer.py` is a stub; the last code is `indexer.py.retired-20260929`).

## Components

| File | Role |
|---|---|
| `ragcore.py` | parsing, chunking, sqlite storage, Ollama embed/chat, search |
| `indexer.py` | CLI: incremental index + summarize; `--search "q"`, `--stats`, `--force`, `--quiet` |
| `server.py` | MCP stdio server: `search_history`, `recent_sessions`, `get_session`, `synthesize` |
| `test_server.py` | smoke test: handshake + tools/list + a real tool call |
| `history.db` | SQLite: chunks + session summaries with normalized float32 embeddings |

## Models

- Embeddings: `qwen3-embedding:0.6b` (1024-dim)
- Summaries / synthesis: the gateway's SERVING alias `qwen3.8:27b-64k` — whatever model serves Cline,
  at its pinned window. Asking for a fixed model while another one was serving evicted the serving
  model and the prompt it had read. Requests carry `User-Agent: history-rag/2` so the gateway names them.
- Summaries run at most `MAX_SUMMARIES_PER_RUN` (4) per run and only when the gateway has been quiet
  for `GATEWAY_QUIET_MINUTES` (10): the serving model has one slot, and a summary prompt swaps an
  active agent conversation out of it and back (measured: ~1 min of delay for the agent per summary).

## Automation (WSL)

- **systemd user timer** `claude-history-index.timer`: every 15 min, `indexer.py --quiet`
  (`~/.config/systemd/user/claude-history-index.{service,timer}`; lingering is enabled so it runs
  without a login session). `systemctl --user list-timers claude-history-index.timer`,
  `journalctl --user -u claude-history-index.service`.
- **SessionEnd hook** in BOTH homes' `settings.json`: WSL runs `.venv/bin/python indexer.py --quiet`
  directly; Windows runs the same through `wsl.exe -d Ubuntu --`. Async, 900 s timeout.
- **MCP registration** in both `~/.claude.json` files: WSL `command: .venv/bin/python server.py`;
  Windows `command: wsl.exe, args: -d Ubuntu -- <same>`. Verified with `test_server.py` from both sides.
- **MCP server startup**: background thread does the same catch-up when any window opens.
- A lock file (`index.lock`, 30-min staleness, dead-PID aware) prevents concurrent indexers.
- The old Windows scheduled task `ClaudeHistoryRAG-Index` still exists but runs the stub; disable it
  from an elevated shell: `schtasks /Change /TN ClaudeHistoryRAG-Index /DISABLE`.

## Maintenance

- Rebuild from scratch: delete `history.db` and run `indexer.py`.
- Registered in `~/.claude.json` under `mcpServers.claude-history` (backups `*.bak-rag-20260929` on both sides).
- Test: `.venv/bin/python test_server.py` (WSL) or, from Windows,
  `venv\Scripts\python.exe test_server.py wsl.exe -d Ubuntu -- /home/cmadrigal/.claude/history-rag/.venv/bin/python /home/cmadrigal/.claude/history-rag/server.py`.
- `HISTORY_RAG_ROOTS` (os.pathsep-separated) overrides the indexed roots.
