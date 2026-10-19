"""MCP server exposing the conversation-history RAG to every Claude Code window.

Registered user-scope, so any VSCode window / project gets these tools:
  search_history       semantic search over all past sessions (summaries + chunks)
  recent_sessions      what have we been working on lately
  get_session          full summary + top chunks for one session
  synthesize           local-LLM-composed briefing that cites sessions

On startup a daemon thread runs an incremental index catch-up, so the corpus
is always fresh by the time you ask.
"""

import threading

from mcp.server import MCPServer

import ragcore

mcp = MCPServer("claude-history")


def _background_catchup():
    if not ragcore.acquire_lock():
        return
    try:
        con = ragcore.db_connect()
        ragcore.index_incremental(con)
        ragcore.index_cline_tasks(con)
        if not ragcore.gateway_busy():
            ragcore.summarize_idle_sessions(con)
        con.close()
    except Exception:
        pass
    finally:
        ragcore.release_lock()


def _fmt_project(p):
    """Short project names for both homes: Windows (c--Users-crist-X), native WSL
    (-home-cmadrigal-X) and WSL paths opened from Windows (--wsl-localhost-Ubuntu-home-cmadrigal-X)."""
    for prefix in ("--wsl-localhost-Ubuntu-home-cmadrigal-", "-home-cmadrigal-", "c--Users-crist-", "C--Users-crist-"):
        if p.startswith(prefix) and len(p) > len(prefix):
            return p[len(prefix):]
    return p


def _fmt_hits(sess_hits, chunk_hits):
    out = []
    if sess_hits:
        out.append("## Matching sessions")
        for score, (sid, project, title, ts, summary, _) in sess_hits:
            out.append(f"\n### [{_fmt_project(project)}] {title or 'untitled'} "
                       f"— {(ts or '')[:10]} — session {sid[:8]} (match {score:.2f})")
            out.append((summary or "(no summary yet)")[:1200])
    if chunk_hits:
        out.append("\n## Matching excerpts")
        for score, (project, sid, ts, kind, text, _) in chunk_hits:
            out.append(f"\n### [{_fmt_project(project)}] {(ts or '')[:10]} "
                       f"— session {sid[:8]} (match {score:.2f})")
            out.append(text[:900])
    return "\n".join(out) if out else "No matches in conversation history."


@mcp.tool()
def search_history(query: str, k: int = 8, project: str = "") -> str:
    """Semantic search over ALL past Claude Code conversations across every
    project/VSCode window. Returns matching session summaries plus verbatim
    excerpts. Use `project` (substring, e.g. 'comfyui') to narrow."""
    con = ragcore.db_connect()
    sess, chunks = ragcore.search(con, query, k=k, project=project or None)
    sess = [h for h in sess if h[0] > 0.35]
    chunks = [h for h in chunks if h[0] > 0.35]
    return _fmt_hits(sess, chunks)


@mcp.tool()
def recent_sessions(n: int = 12) -> str:
    """List the most recent past sessions across all projects with their
    titles and dates — 'what have we been working on lately'."""
    con = ragcore.db_connect()
    rows = con.execute("""
        SELECT session_id, project, COALESCE(title,'untitled'),
               COALESCE(last_ts,''), summary IS NOT NULL
        FROM sessions WHERE content_chars > 0
        ORDER BY last_ts DESC LIMIT ?""", (n,)).fetchall()
    out = []
    for sid, project, title, ts, has_sum in rows:
        mark = "✓" if has_sum else "…"
        out.append(f"- [{_fmt_project(project)}] {title} — {ts[:10]} "
                   f"(session {sid[:8]}) {mark}")
    return "\n".join(out) or "No sessions indexed yet."


@mcp.tool()
def get_session(session_id: str) -> str:
    """Full summary and content overview for one session. Accepts the short
    8-char id shown by search_history / recent_sessions."""
    con = ragcore.db_connect()
    row = con.execute("""
        SELECT session_id, project, COALESCE(title,'untitled'),
               COALESCE(last_ts,''), summary
        FROM sessions WHERE session_id LIKE ?""",
        (f"{session_id}%",)).fetchone()
    if not row:
        return f"No session starting with '{session_id}'."
    sid, project, title, ts, summary = row
    parts = [f"# [{_fmt_project(project)}] {title} — {ts[:10]}",
             f"session {sid}", "",
             summary or "(no summary yet — session may still be active)"]
    texts = [r[0] for r in con.execute(
        "SELECT text FROM chunks WHERE session_id=? ORDER BY id DESC LIMIT 3",
        (sid,))]
    if texts:
        parts += ["", "## Last exchanges"] + [t[:800] for t in reversed(texts)]
    return "\n".join(parts)


@mcp.tool()
def synthesize(question: str, project: str = "") -> str:
    """Answer a question from conversation history using the local GPU model
    to synthesize across many sessions. Slower than search_history but returns
    one coherent, cited briefing. Best for 'what did we decide about X'."""
    con = ragcore.db_connect()
    sess, chunks = ragcore.search(con, question, k=8, project=project or None)
    context = _fmt_hits(sess[:5], chunks[:6])
    if context.startswith("No matches"):
        return context
    try:
        answer = ragcore.chat(
            f"Question: {question}\n\nRetrieved history:\n{context[:20000]}",
            system=("Answer using ONLY the retrieved conversation history. "
                    "Cite session ids like (session ab12cd34). Keep exact "
                    "names, numbers and paths. If history doesn't cover it, "
                    "say so."))
        return answer
    except Exception as e:
        return f"Local synthesis failed ({e}); raw retrieval:\n\n{context}"


threading.Thread(target=_background_catchup, daemon=True).start()

if __name__ == "__main__":
    mcp.run()
