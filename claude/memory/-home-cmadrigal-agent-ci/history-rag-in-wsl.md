---
name: history-rag-in-wsl
description: "2026-09-29 the claude-history RAG moved into WSL (~/.claude/history-rag), indexes both homes, runs on a 15-min user timer, summarizes only when the gateway is quiet; the old Windows split is closed"
metadata:
  node_type: memory
  type: project
  originSessionId: e2e1e562-e852-469b-98e4-f8f9b218520e
  modified: 2026-10-05T04:22:46.539Z
---

The claude-history RAG (search_history / recent_sessions / get_session / synthesize) now runs
natively in WSL at `~/.claude/history-rag` (uv venv `.venv`, mcp 2.0.0). It indexes BOTH homes:
`~/.claude/projects` (native WSL sessions, 157 files as of the move) and
`/mnt/c/Users/crist/.claude/projects` + Cline's task store. The DB was migrated (Windows paths
rewritten to `/mnt/c/...`), so nothing was re-embedded. This session is indexed and searchable.

**Automation:** systemd user timer `claude-history-index.timer` (15 min, linger enabled), SessionEnd
hooks in both homes (Windows runs it through `wsl.exe -d Ubuntu --`), MCP registered in both
`.claude.json` files (Windows via `wsl.exe`; handshake verified from both sides). The Windows copy is
retired (indexer stub); the Windows scheduled task could not be disabled from WSL (needs elevation).

**Why / rules learned:** the Windows-only indexer was blind to every WSL session since the
2026-09-01 migration ([[wsl-migration-recovery]]). Its summarizer asked for `qwen3.8:27b` while
Cline is served by `qwen3.8:27b-uncensored`: both do not fit in 48 GB, so every summary evicted
Cline's model and its prompt cache. Summaries now go to the serving alias `qwen3.8:27b-64k`, at most
4 per run, and ONLY when the gateway has been quiet 10 min: with one slot, a summary swaps a 180k-token
agent conversation out and back, ~1 min of delay per summary (measured). RAG requests carry
`User-Agent: history-rag/2`; the gateway's classify_source names them "history RAG" (patch in the
working tree; needs an idle restart). See [[cold-prefill-loop]], [[gateway-model-override-hijack]].

**2026-10-04:** `ragcore.embed_batch` now sends `options.num_ctx = EMBED_NUM_CTX` (4096; inputs are
capped at 3000 chars). Without it the embedding model loaded at its 32k maximum and held 4.0 GB of VRAM
for 0.6 GB of weights; now 2.2 GB. Backup `ragcore.py.bak-numctx-20261004`. The MCP server process of a
session started before the patch still runs the old code until that session ends.

**How to apply:** if the RAG seems stale, check `systemctl --user list-timers claude-history-index.timer`
and `journalctl --user -u claude-history-index.service`; `indexer.py --stats`; the WSL session's
MCP tools appear only in sessions started after 2026-09-29 19:30.
