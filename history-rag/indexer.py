"""CLI for the history RAG: incremental index + summarize, and a test search.

  python indexer.py                incremental index + summarize idle sessions
  python indexer.py --force        also summarize sessions that look active
  python indexer.py --index-only   ingest new turns only; skip summarization
                                   (cheap + freeze-safe; used by the 15-min task)
  python indexer.py --quiet        no output (used by the SessionEnd hook)
  python indexer.py --search "q"   test retrieval from the command line
  python indexer.py --stats        show corpus counts
"""

import sys

import ragcore


def main():
    args = sys.argv[1:]
    quiet = "--quiet" in args
    log = (lambda s: None) if quiet else (lambda s: print(f"[rag] {s}"))

    if "--search" in args:
        query = args[args.index("--search") + 1]
        con = ragcore.db_connect()
        sess, chunks = ragcore.search(con, query, k=6)
        print("=== session summaries ===")
        for score, (sid, project, title, ts, summary, _) in sess:
            print(f"\n--- {score:.3f} [{project}] {title} ({sid[:8]})")
            print((summary or "(not summarized yet)")[:600])
        print("\n=== chunks ===")
        for score, (project, sid, ts, kind, text, _) in chunks:
            print(f"\n--- {score:.3f} [{project}] {kind} {ts[:10]} ({sid[:8]})")
            print(text[:400])
        return

    if "--stats" in args:
        con = ragcore.db_connect()
        for label, q in [
                ("files", "SELECT COUNT(*) FROM files"),
                ("chunks", "SELECT COUNT(*) FROM chunks"),
                ("sessions", "SELECT COUNT(*) FROM sessions"),
                ("summarized", "SELECT COUNT(*) FROM sessions WHERE summary IS NOT NULL")]:
            print(f"{label:>12}: {con.execute(q).fetchone()[0]}")
        return

    if not ragcore.acquire_lock():
        log("another indexer is running; exiting")
        return
    try:
        con = ragcore.db_connect()
        n = ragcore.index_incremental(con, log=log)
        log(f"indexed {n} new chunks")
        c = ragcore.index_cline_tasks(con, log=log)
        log(f"indexed {c} new cline-extension chunks")
        if "--index-only" in args:
            log("index-only: skipping summarization")
        elif "--force" not in args and ragcore.gateway_busy():
            log(f"gateway busy or used in the last {ragcore.GATEWAY_QUIET_MINUTES} min: "
                "summaries wait for a quiet moment")
        else:
            s = ragcore.summarize_idle_sessions(
                con, force="--force" in args, log=log)
            log(f"summarized {s} sessions")
        # Fold the WAL back into history.db so a later crash can't strand
        # committed rows in an un-checkpointed WAL.
        try:
            con.execute("PRAGMA wal_checkpoint(TRUNCATE)")
        except Exception as e:
            log(f"wal checkpoint skipped: {e}")
    finally:
        ragcore.release_lock()


if __name__ == "__main__":
    main()
