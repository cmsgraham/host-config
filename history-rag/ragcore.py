"""Core library for the Claude Code conversation-history RAG.

Data flow:
  ~/.claude/projects/*/*.jsonl  --parse-->  turn chunks  --ollama embed-->  sqlite (history.db)
  idle sessions                 --ollama chat summarize-->  session summaries (also embedded)

Search is brute-force cosine over normalized float32 vectors with numpy —
at this corpus size (tens of thousands of chunks) it is < 50 ms and needs
no native sqlite extensions.
"""

import json
import os
import re
import sqlite3
import struct
import sys
import time
from datetime import datetime
from pathlib import Path

import numpy as np
import requests

# ---------------------------------------------------------------- config

CLAUDE_DIR = Path.home() / ".claude"
PROJECTS_DIR = CLAUDE_DIR / "projects"
# Since 2026-09-29 the RAG runs in WSL and indexes BOTH homes: the Linux one (native
# WSL sessions) and the Windows one (mounted). HISTORY_RAG_ROOTS overrides (os.pathsep-
# separated); a listed root that does not exist is skipped, so one config serves both.
WINDOWS_HOME = Path("/mnt/c/Users/crist")
_DEFAULT_ROOTS = [PROJECTS_DIR, WINDOWS_HOME / ".claude" / "projects"]
PROJECT_ROOTS = [Path(p) for p in os.environ["HISTORY_RAG_ROOTS"].split(os.pathsep)] \
    if os.environ.get("HISTORY_RAG_ROOTS") else _DEFAULT_ROOTS
RAG_DIR = CLAUDE_DIR / "history-rag"
DB_PATH = RAG_DIR / "history.db"
LOCK_PATH = RAG_DIR / "index.lock"

OLLAMA = os.environ.get("OLLAMA_HOST_URL", "http://127.0.0.1:11434")  # -> smart gateway (moved 11500->11434)
EMBED_MODEL = "qwen3-embedding:0.6b"
EMBED_NUM_CTX = 4096               # see embed_batch
# Summaries go to the gateway's SERVING alias: whatever model is serving Cline right now,
# at its pinned window. Asking for a fixed model (qwen3.8:27b) while a different one was
# serving made Ollama evict the serving model and the prompt it had read (2026-09-29).
CHAT_MODEL_PREFERENCE = ["qwen3.8:27b-64k", "qwen3.8:27b", "qwen3-coder:30b"]
USER_AGENT = "history-rag/2 python-requests"     # the gateway names the caller by it
MAX_SUMMARIES_PER_RUN = 4          # a run holds the generation slot for minutes, not an hour
# Summaries wait for a QUIET gateway. The serving model has one slot: a summary prompt
# swaps an active agent conversation (180k tokens of read prompt) out of it and back,
# which cost that agent about a minute per summary when measured (2026-09-29). Indexing
# (embeddings, a separate small model) is not gated.
GATEWAY_QUIET_MINUTES = 10

CHUNK_TARGET_CHARS = 2500          # emit a chunk when the buffer reaches this
MSG_CAP_CHARS = 4000               # truncate any single message to this
SESSION_IDLE_SECS = 10 * 60        # only summarize sessions idle this long
MIN_SUMMARY_CHARS = 500            # don't summarize trivial sessions
SUMMARY_SAMPLE_HEAD = 6000         # chars of transcript start fed to summarizer
SUMMARY_SAMPLE_TAIL = 14000        # chars of transcript end fed to summarizer

_SYS_REMINDER_RE = re.compile(r"<system-reminder>.*?</system-reminder>", re.DOTALL)
_SKIP_PREFIXES = (
    "<command-", "<local-command", "Caveat: The messages below",
    "[Request interrupted", "<task-notification", "[SYSTEM NOTIFICATION",
)

# The Cline VSCode extension stores its own task conversations outside
# ~/.claude/projects, so they are ingested by a separate source (see
# index_cline_tasks). Auto-generated context blocks are stripped as noise.
CLINE_PROJECT = "cline-extension"
_ENV_DETAILS_RE = re.compile(r"<environment_details>.*?</environment_details>",
                             re.DOTALL)


def _cline_tasks_roots():
    """Cline extension task stores, if VS Code (stable or Insiders) has one."""
    appdata = os.environ.get("APPDATA")
    bases = [Path(appdata)] if appdata else []
    bases.append(WINDOWS_HOME / "AppData" / "Roaming")      # the same store, seen from WSL
    roots = []
    for base in bases:
        for variant in ("Code", "Code - Insiders"):
            d = base / variant / "User" / "globalStorage" / "saoudrizwan.claude-dev" / "tasks"
            if d.is_dir() and d not in roots:
                roots.append(d)
    return roots


def project_dirs():
    """(project name, directory) for every project under every root that exists."""
    for root in PROJECT_ROOTS:
        if not root.is_dir():
            continue
        for d in sorted(root.iterdir()):
            if d.is_dir():
                yield d.name, d

# ---------------------------------------------------------------- db

def db_connect():
    RAG_DIR.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(DB_PATH, timeout=30)
    con.execute("PRAGMA journal_mode=WAL")
    con.executescript("""
        CREATE TABLE IF NOT EXISTS files(
            path TEXT PRIMARY KEY, byte_offset INTEGER, mtime REAL);
        CREATE TABLE IF NOT EXISTS chunks(
            id INTEGER PRIMARY KEY, project TEXT, session_id TEXT,
            ts TEXT, kind TEXT, text TEXT, emb BLOB);
        CREATE TABLE IF NOT EXISTS sessions(
            session_id TEXT PRIMARY KEY, project TEXT, title TEXT,
            last_ts TEXT, content_chars INTEGER DEFAULT 0,
            summarized_chars INTEGER DEFAULT 0, summary TEXT, emb BLOB);
        CREATE INDEX IF NOT EXISTS idx_chunks_session ON chunks(session_id);
    """)
    return con


def pack(vec):
    a = np.asarray(vec, dtype=np.float32)
    n = np.linalg.norm(a)
    if n > 0:
        a = a / n
    return a.tobytes()


def unpack(blob):
    return np.frombuffer(blob, dtype=np.float32)

# ---------------------------------------------------------------- ollama

def embed_batch(texts):
    r = requests.post(f"{OLLAMA}/api/embed", headers={"User-Agent": USER_AGENT},
                      json={"model": EMBED_MODEL, "input": texts,
                            # inputs are capped at 3000 chars (~1k tokens); without this the
                            # model loads at its 32k maximum and holds ~4 GB of VRAM for 0.6 GB
                            # of weights. 4096 fits the longest input with room to spare.
                            "options": {"num_ctx": EMBED_NUM_CTX}}, timeout=300)
    r.raise_for_status()
    return r.json()["embeddings"]


def pick_chat_model():
    try:
        tags = requests.get(f"{OLLAMA}/api/tags", headers={"User-Agent": USER_AGENT}, timeout=10).json()
        names = [m["name"] for m in tags.get("models", [])]
    except Exception:
        return CHAT_MODEL_PREFERENCE[0]
    for want in CHAT_MODEL_PREFERENCE:
        if any(n == want or n.startswith(want) for n in names):
            return want
    for n in names:
        if "embed" not in n:
            return n
    return CHAT_MODEL_PREFERENCE[0]


def chat(prompt, system=None, model=None, num_ctx=16384):
    msgs = ([{"role": "system", "content": system}] if system else []) + \
           [{"role": "user", "content": prompt}]
    r = requests.post(f"{OLLAMA}/api/chat", headers={"User-Agent": USER_AGENT}, json={
        "model": model or pick_chat_model(), "messages": msgs, "stream": False,
        "options": {"temperature": 0.2, "num_ctx": num_ctx},
    }, timeout=900)
    r.raise_for_status()
    return r.json()["message"]["content"].strip()

def gateway_busy(quiet_minutes=None):
    """True while someone other than this RAG is generating, or did so within the last
    `quiet_minutes`. Read from the gateway's own records; unreachable gateway = not busy
    (the summary call itself will then fail fast and be retried next run)."""
    quiet = GATEWAY_QUIET_MINUTES if quiet_minutes is None else quiet_minutes
    try:
        d = requests.get(f"{OLLAMA}/_dash/data", headers={"User-Agent": USER_AGENT}, timeout=5).json()
        if any("history-rag" not in (r.get("ua") or "") for r in d.get("inflight") or []):
            return True
        # voice or ComfyUI holding a GPU lease (2026-11-01): their VRAM is reserved but loaded
        # lazily, so a quiet gateway is NOT a free card - a summary model would take it
        orch = d.get("orchestrator") or {}
        if any(w.get("kind") == "lease" and w.get("state") in ("running", "yielding")
               for w in orch.get("workloads") or []):
            return True
        rows = requests.get(f"{OLLAMA}/_dash/requests?range=15m&limit=60&kind=smart",
                            headers={"User-Agent": USER_AGENT}, timeout=5).json().get("rows") or []
    except Exception:
        return False
    cutoff = time.time() - quiet * 60
    return any((r.get("ts_end") or r.get("ts") or 0) >= cutoff and "history-rag" not in (r.get("ua") or "")
               for r in rows)

# ---------------------------------------------------------------- parsing

def _clean(text):
    text = _SYS_REMINDER_RE.sub("", text).strip()
    if not text or any(text.startswith(p) for p in _SKIP_PREFIXES):
        return None
    return text[:MSG_CAP_CHARS]


def _texts_from_content(content):
    if isinstance(content, str):
        return [content]
    out = []
    if isinstance(content, list):
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                out.append(block.get("text", ""))
    return out


def parse_new_lines(path, offset):
    """Yield events from a transcript starting at byte offset.

    Events: ("msg", session_id, ts, role, text) |
            ("title", session_id, title) |
            ("compact", session_id, ts, text)
    Returns (events, new_offset).
    """
    events = []
    with open(path, "rb") as f:
        f.seek(offset)
        data = f.read()
    if not data:
        return events, offset
    # only consume complete lines; a session mid-write may have a partial tail
    end = data.rfind(b"\n")
    if end == -1:
        return events, offset
    consumed = end + 1
    for raw in data[:consumed].splitlines():
        try:
            obj = json.loads(raw)
        except Exception:
            continue
        t = obj.get("type")
        sid = obj.get("sessionId", "")
        if t == "ai-title" and obj.get("aiTitle"):
            events.append(("title", sid, obj["aiTitle"]))
        elif t == "summary" and obj.get("summary"):
            events.append(("compact", sid, obj.get("timestamp", ""),
                           obj["summary"][:MSG_CAP_CHARS * 2]))
        elif t in ("user", "assistant"):
            if obj.get("isMeta") or obj.get("isSidechain"):
                continue
            msg = obj.get("message") or {}
            role = msg.get("role", t)
            for text in _texts_from_content(msg.get("content")):
                cleaned = _clean(text)
                if cleaned:
                    events.append(("msg", sid, obj.get("timestamp", ""),
                                   role, cleaned))
    return events, offset + consumed

# ---------------------------------------------------------------- indexing

def _flush_chunk(con, project, sid, ts, parts, pending):
    text = "\n".join(parts).strip()
    if len(text) < 80:      # ignore fragments with no retrievable substance
        return
    pending.append((project, sid, ts, "turns", text))


def index_incremental(con, log=lambda s: None):
    """Scan all transcript files, ingest new bytes, embed new chunks."""
    pending = []            # (project, session_id, ts, kind, text)
    for project, proj_dir in project_dirs():
        for jf in sorted(proj_dir.glob("*.jsonl")):
            path = str(jf)
            mtime = jf.stat().st_mtime
            row = con.execute(
                "SELECT byte_offset, mtime FROM files WHERE path=?",
                (path,)).fetchone()
            offset = row[0] if row else 0
            if row and row[1] == mtime and offset >= jf.stat().st_size:
                continue
            events, new_offset = parse_new_lines(path, offset)
            if new_offset == offset and row:
                con.execute("UPDATE files SET mtime=? WHERE path=?",
                            (mtime, path))
                continue

            buf, buf_sid, buf_ts, buf_chars = [], None, "", 0
            for ev in events:
                kind = ev[0]
                if kind == "title":
                    _, sid, title = ev
                    con.execute("""
                        INSERT INTO sessions(session_id, project, title)
                        VALUES(?,?,?)
                        ON CONFLICT(session_id) DO UPDATE SET title=excluded.title
                    """, (sid, project, title))
                    continue
                if kind == "compact":
                    _, sid, ts, text = ev
                    pending.append((project, sid, ts, "compact", text))
                    continue
                _, sid, ts, role, text = ev
                if buf and (sid != buf_sid or buf_chars > CHUNK_TARGET_CHARS):
                    _flush_chunk(con, project, buf_sid, buf_ts, buf, pending)
                    buf, buf_chars = [], 0
                if not buf:
                    buf_sid, buf_ts = sid, ts
                buf.append(f"{role.upper()}: {text}")
                buf_chars += len(text)
                con.execute("""
                    INSERT INTO sessions(session_id, project, last_ts, content_chars)
                    VALUES(?,?,?,?)
                    ON CONFLICT(session_id) DO UPDATE SET
                        last_ts=excluded.last_ts,
                        content_chars=content_chars+excluded.content_chars,
                        project=excluded.project
                """, (sid, project, ts, len(text)))
            if buf:
                _flush_chunk(con, project, buf_sid, buf_ts, buf, pending)
            con.execute("""
                INSERT INTO files(path, byte_offset, mtime) VALUES(?,?,?)
                ON CONFLICT(path) DO UPDATE SET
                    byte_offset=excluded.byte_offset, mtime=excluded.mtime
            """, (path, new_offset, mtime))
            con.commit()

    if pending:
        log(f"embedding {len(pending)} new chunks")
        for i in range(0, len(pending), 16):
            batch = pending[i:i + 16]
            embs = embed_batch([p[4][:3000] for p in batch])
            con.executemany(
                "INSERT INTO chunks(project, session_id, ts, kind, text, emb)"
                " VALUES(?,?,?,?,?,?)",
                [(p[0], p[1], p[2], p[3], p[4], pack(e))
                 for p, e in zip(batch, embs)])
            con.commit()
    return len(pending)


def _ts_from_taskid(taskid):
    try:
        return datetime.fromtimestamp(int(taskid) / 1000).isoformat()
    except (ValueError, OverflowError, OSError):
        return ""


def _first_task_text(messages):
    for m in messages:
        if m.get("role") != "user":
            continue
        for t in _texts_from_content(m.get("content")):
            hit = re.search(r"<task>(.*?)</task>", t, re.DOTALL)
            if hit:
                return " ".join(hit.group(1).split())[:80]
    return ""


def index_cline_tasks(con, log=lambda s: None):
    """Ingest Cline VSCode-extension task conversations into the same corpus.

    Cline rewrites each task's whole JSON on every turn (not append), so we key
    resumption on message count + mtime rather than a byte offset. Each task is
    embedded and its progress marker advanced in ONE commit, so a crash (like the
    freeze) at worst repeats a single task next run — it never strands chunks
    that were counted-as-done but never embedded, and a half-written JSON is
    skipped and retried rather than aborting the whole pass.
    """
    embedded = 0
    for root in _cline_tasks_roots():
        for task_dir in sorted(root.iterdir()):
            if not task_dir.is_dir():
                continue
            taskid = task_dir.name
            hist = task_dir / "api_conversation_history.json"
            if not hist.exists():
                continue
            path = str(hist)
            try:
                mtime = hist.stat().st_mtime
            except OSError:
                continue
            row = con.execute(
                "SELECT byte_offset, mtime FROM files WHERE path=?",
                (path,)).fetchone()
            done = row[0] if row else 0        # messages already ingested
            if row and row[1] == mtime:
                continue                        # unchanged since last pass
            try:
                with open(hist, "r", encoding="utf-8") as f:
                    messages = json.load(f)
            except (OSError, ValueError):       # partial/mid-write -> retry later
                log(f"cline {taskid[:13]} unreadable (partial write?); skipping")
                continue
            if not isinstance(messages, list):
                continue

            sid = f"cline-{taskid}"
            ts = _ts_from_taskid(taskid)
            title = _first_task_text(messages)

            # Chunk only the messages we haven't ingested yet.
            chunks, buf, buf_chars, added = [], [], 0, 0
            for m in messages[done:]:
                if not isinstance(m, dict):
                    continue
                role = m.get("role", "user")
                for text in _texts_from_content(m.get("content")):
                    cleaned = _clean(_ENV_DETAILS_RE.sub("", text))
                    if not cleaned:
                        continue
                    if buf and buf_chars > CHUNK_TARGET_CHARS:
                        chunks.append("\n".join(buf).strip())
                        buf, buf_chars = [], 0
                    buf.append(f"{role.upper()}: {cleaned}")
                    buf_chars += len(cleaned)
                    added += len(cleaned)
            if buf:
                tail = "\n".join(buf).strip()
                if len(tail) >= 80:
                    chunks.append(tail)

            # Embed FIRST; only advance the marker once chunks are safely stored.
            if chunks:
                try:
                    embs = embed_batch([c[:3000] for c in chunks])
                except Exception as e:
                    log(f"cline {taskid[:13]} embed failed ({e}); will retry")
                    continue
                con.executemany(
                    "INSERT INTO chunks(project, session_id, ts, kind, text, emb)"
                    " VALUES(?,?,?,?,?,?)",
                    [(CLINE_PROJECT, sid, ts, "turns", c, pack(e))
                     for c, e in zip(chunks, embs)])
                embedded += len(chunks)

            con.execute("""
                INSERT INTO sessions(session_id, project, title, last_ts,
                                     content_chars)
                VALUES(?,?,?,?,?)
                ON CONFLICT(session_id) DO UPDATE SET
                    title=COALESCE(excluded.title, sessions.title),
                    last_ts=excluded.last_ts,
                    content_chars=content_chars+excluded.content_chars,
                    project=excluded.project
            """, (sid, CLINE_PROJECT, title or None, ts, added))
            con.execute("""
                INSERT INTO files(path, byte_offset, mtime) VALUES(?,?,?)
                ON CONFLICT(path) DO UPDATE SET
                    byte_offset=excluded.byte_offset, mtime=excluded.mtime
            """, (path, len(messages), mtime))
            con.commit()                        # chunks + marker land together
    return embedded


SUMMARY_SYSTEM = (
    "You summarize a developer's AI-assistant coding session so a future "
    "assistant can recover full context. Be concrete: keep exact names, "
    "paths, versions, numbers, commands, decisions. No preamble.")

SUMMARY_PROMPT = """Summarize this Claude Code session transcript in markdown:

## Topics
## Decisions & conclusions
## Built / changed
## Open threads

Transcript (project: {project}, title: {title}):
{sample}"""


def _session_source_mtime(project, sid):
    """Newest mtime of the transcript(s) backing a session, across both sources."""
    latest = 0.0
    for root in PROJECT_ROOTS:
        proj_dir = root / project
        if not proj_dir.is_dir():
            continue
        for jf in proj_dir.glob("*.jsonl"):
            if jf.stem == sid:
                try:
                    latest = max(latest, jf.stat().st_mtime)
                except OSError:
                    pass
    if sid.startswith("cline-"):
        taskid = sid[len("cline-"):]
        for root in _cline_tasks_roots():
            hist = root / taskid / "api_conversation_history.json"
            if hist.exists():
                try:
                    latest = max(latest, hist.stat().st_mtime)
                except OSError:
                    pass
    return latest


def summarize_idle_sessions(con, force=False, log=lambda s: None, limit=None):
    """Summarize sessions with unsummarized content that look finished, at most
    `limit` of them per call (MAX_SUMMARIES_PER_RUN): each summary holds the
    generation slot for a minute or so, and other callers wait behind it."""
    now = time.time()
    limit = MAX_SUMMARIES_PER_RUN if limit is None else limit
    rows = con.execute("""
        SELECT session_id, project, COALESCE(title,''), content_chars,
               summarized_chars FROM sessions
        WHERE content_chars > ? AND content_chars > summarized_chars
    """, (MIN_SUMMARY_CHARS,)).fetchall()
    done = 0
    for sid, project, title, chars, _ in rows:
        if limit and done >= limit:
            log(f"summary limit {limit} reached; the rest waits for the next run")
            break
        if not force:
            # skip sessions whose source was touched recently (still active)
            src_mtime = _session_source_mtime(project, sid)
            if src_mtime and now - src_mtime < SESSION_IDLE_SECS:
                continue
        texts = [r[0] for r in con.execute(
            "SELECT text FROM chunks WHERE session_id=? ORDER BY id", (sid,))]
        full = "\n\n".join(texts)
        if len(full) <= SUMMARY_SAMPLE_HEAD + SUMMARY_SAMPLE_TAIL:
            sample = full
        else:
            sample = (full[:SUMMARY_SAMPLE_HEAD] + "\n\n[... middle omitted ...]\n\n"
                      + full[-SUMMARY_SAMPLE_TAIL:])
        log(f"summarizing {project}/{sid[:8]} ({chars} chars)")
        try:
            summary = chat(SUMMARY_PROMPT.format(
                project=project, title=title or "untitled", sample=sample),
                system=SUMMARY_SYSTEM)
            emb = embed_batch([summary[:3000]])[0]
            con.execute("""
                UPDATE sessions SET summary=?, emb=?, summarized_chars=?
                WHERE session_id=?""", (summary, pack(emb), chars, sid))
            con.commit()
            done += 1
        except Exception as e:
            log(f"summarize failed for {sid[:8]}: {e}")
    return done

# ---------------------------------------------------------------- search

def _topk(query_emb, rows, k):
    """rows: list of (payload..., emb_blob) — last element must be the blob."""
    if not rows:
        return []
    mat = np.vstack([unpack(r[-1]) for r in rows])
    q = np.asarray(query_emb, dtype=np.float32)
    q = q / (np.linalg.norm(q) or 1.0)
    sims = mat @ q
    order = np.argsort(-sims)[:k]
    return [(float(sims[i]), rows[i]) for i in order]


def search(con, query, k=8, project=None, session_id=None):
    """Return (session_hits, chunk_hits)."""
    q_emb = embed_batch([query])[0]
    where, args = "WHERE emb IS NOT NULL", []
    if project:
        where += " AND project LIKE ?"
        args.append(f"%{project}%")
    srows = con.execute(
        f"SELECT session_id, project, title, last_ts, summary, emb "
        f"FROM sessions {where}", args).fetchall()
    sess_hits = _topk(q_emb, srows, max(3, k // 2))

    cwhere, cargs = "WHERE 1=1", []
    if project:
        cwhere += " AND project LIKE ?"
        cargs.append(f"%{project}%")
    if session_id:
        cwhere += " AND session_id LIKE ?"
        cargs.append(f"{session_id}%")
    crows = con.execute(
        f"SELECT project, session_id, ts, kind, text, emb "
        f"FROM chunks {cwhere}", cargs).fetchall()
    chunk_hits = _topk(q_emb, crows, k)
    return sess_hits, chunk_hits


def _read_lock_pid():
    try:
        return int((LOCK_PATH.read_text() or "0").strip() or 0)
    except (OSError, ValueError):
        return 0


def _pid_alive(pid):
    """True if the process is running. Never signals/kills the target."""
    if pid <= 0:
        return False
    if os.name == "nt":
        import ctypes
        PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
        STILL_ACTIVE = 259
        k = ctypes.windll.kernel32
        h = k.OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, pid)
        if not h:                       # no such process (or gone)
            return False
        try:
            code = ctypes.c_ulong()
            if k.GetExitCodeProcess(h, ctypes.byref(code)):
                return code.value == STILL_ACTIVE
            return True                 # exists but unqueryable -> assume alive
        finally:
            k.CloseHandle(h)
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    return True


def acquire_lock():
    RAG_DIR.mkdir(parents=True, exist_ok=True)
    try:
        if LOCK_PATH.exists():
            pid = _read_lock_pid()
            age = time.time() - LOCK_PATH.stat().st_mtime
            # Refuse only if a live indexer really holds it. A dead owner (the
            # process was killed by a crash/freeze) means the lock is orphaned —
            # reclaim it now instead of blocking for 30 min. The age check is a
            # fallback for locks whose PID can't be read.
            if pid and _pid_alive(pid):
                return False
            if not pid and age < 30 * 60:
                return False
            LOCK_PATH.unlink()
        fd = os.open(LOCK_PATH, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
        os.write(fd, str(os.getpid()).encode())
        os.close(fd)
        return True
    except OSError:
        return False


def release_lock():
    try:
        LOCK_PATH.unlink()
    except OSError:
        pass
