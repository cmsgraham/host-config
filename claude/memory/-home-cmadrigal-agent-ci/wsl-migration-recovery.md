---
name: wsl-migration-recovery
description: "2026-09-01 VS Code moved Windows -> Remote-WSL; what was restored, what is still split between the two homes"
metadata:
  node_type: memory
  type: project
---

On 2026-09-01 VS Code switched from a Windows host session to Remote-WSL, so
Claude Code started from an EMPTY `~/.claude` in Ubuntu. The previous profile
still lives at `/mnt/c/Users/crist/.claude` and is the recovery source.

Restored into WSL: global `CLAUDE.md`, this project's `memory/`, the prior
agent-ci transcript (`af68436e-...jsonl`, was under the Windows-side project key
`--wsl-localhost-Ubuntu-home-cmadrigal-agent-ci`), `agent-ci/.env`, and the
Python/Pylance/Docker/git-graph/rainbow-csv extensions in the WSL remote.

Still split, and the reason to keep the Windows profile around: `history-rag`
resolves `CLAUDE_DIR = Path.home()/".claude"` and runs as a WINDOWS python, so
it indexes `C:\Users\crist\.claude\projects` only — sessions recorded in WSL are
NOT indexed. The `claude-history` MCP server works from WSL via interop, but
must use `python.exe`, not `pythonw.exe` (pythonw fails the stdio handshake).

Docker Desktop's WSL integration was never broken by the move: `EnabledWslDistros`
already lists Ubuntu. `agent-ci doctor` fails Docker simply when Docker Desktop
is not running on the Windows host.

**Why:** the move silently reset per-machine state that looked like data loss.
**How to apply:** treat `/mnt/c/Users/crist/.claude` as the archive, not the live
profile; if the RAG "loses" recent work, that is the home-directory split above.
See [[agent-ci-conventions]] and [[agent-ci-build-progress]].
