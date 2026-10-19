# Conversation history RAG (all projects)

A local RAG indexes ALL my Claude Code conversations across every project and
VSCode window (built 2026-08-01, lives at `~/.claude/history-rag/`, runs on my
local GPUs via Ollama — it is fully automatic, nothing needs to be "loaded").

The `claude-history` MCP server exposes it in every session:

- `mcp__claude-history__search_history` — semantic search over all past conversations
- `mcp__claude-history__recent_sessions` — what I've been working on lately
- `mcp__claude-history__get_session` — full summary of one session
- `mcp__claude-history__synthesize` — cited briefing composed by the local model

USE THESE PROACTIVELY whenever I reference past work, other projects, or prior
decisions ("what did we decide about X", "the thing we built in comfyui",
"continue where we left off") — search history instead of asking me to
re-explain or claiming there is no context. If asked whether "the RAG" is
running: it is this system; verify by calling `recent_sessions`.
