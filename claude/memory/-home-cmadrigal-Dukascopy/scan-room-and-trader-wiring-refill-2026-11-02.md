---
name: scan-room-and-trader-wiring-refill-2026-11-02
description: "2026-11-02 10Z refill: 11.61 scan_artifacts verbatim move (scan.py 976 -> 856) / 11.62 _STATE_DISPATCH wiring of the 16 family 1+4 primitives / 11.63 family 3 scan half (INDICES_DEV.txt gate, rates from --policy-rates or the run's pr); asks positioning-asof-fix + fsv2-counting sent; family-4 grammar ask NOT sent yet; next free 11.64 / 15.43 / 16.82"
metadata:
  node_type: memory
  type: project
  originSessionId: 93097701-b31d-426d-947e-84ef25ce0aeb
  modified: 2026-11-02T10:47:27.293Z
---

2026-11-02 10:07Z refill (runnable 11.58-11.60 / 16.80-16.81; every RESOLVED decision already specified, grammar asks
(family1 / family3) at 'wait' or unsent, roadmap stubs chained behind the tolerances decision). Found: families 1, 3
and 4 primitives ALL merged (11.42-11.49) but NONE wired - scan._STATE_DISPATCH knew only prim_state/age/cross/
dependence/liquidity, and scan.py sat at 976 of the 985 cap (test_hz_scan_helpers). So:
- 11.61 (deps []): TASK-12.17-style VERBATIM move of DISCOVERY/CONFIRMATION/WARMUP_START/WINDOW + stats/artifact
  constants + code_sha256, _SymbolResult, _ledger_cells, _append_ledger, _scan_dir, _Stamp, _notes, _write_artifacts,
  _workers_arg into new scan_artifacts.py (167 lines); scan.py 856. One declared edit: manifest "scan.py" hash =
  sha256_file(_HALLAZGOS_DIR / "scan.py"). Traps found: `_stamp` must STAY (tests patch scan.data_manifest_hash);
  SCAN_HOME names of test_hz_scan_helpers must stay (_statistics/_cells_frame/_cell_data); `_write_text` and `BY_Q`
  are read as scan.<name> (test_hz_scan_helpers / synthetic.bench_hz) but unused in scan after the move -> F401 on a
  plain re-import, isort splits `BY_Q as BY_Q` into its own statement -> use `from fxplat.hallazgos import
  scan_artifacts as hz_artifacts` + assignments `BY_Q = hz_artifacts.BY_Q`, `_write_text = hz_artifacts._write_text`.
  The owned test must NOT re-pin scan.py's length (later halves need the room; acceptance wc -l only). Prototype
  /tmp/p1161 (build.py, tests.log); scratch tree needs `git init` + experiments/ copy + config symlink for REPO_ROOT.
- 11.62 (deps 11.61): `**dict.fromkeys(<MODULE>_PRIMITIVES, mask_fn)` x 8 modules in _STATE_DISPATCH -> 28 keys;
  scan.py 873. Catalogue grammar still refuses the names (closed-world) until grammar tasks; W1 refusal unchanged.
  Review: pandas 3 bdate_range is datetime64[us] -> never astype('int64') // 10**6 for ms. Prototype /tmp/p1162.
- 11.63 (deps 11.60, 11.62): family 3 scan half - _Job/_FrameCtx `indices`/`rates` LAST fields (confirm/promote build
  positionally), _predicate_mask branches, _load_intermarket behind approvals/INDICES_DEV.txt (require_indices ->
  HallazgosApprovalMissing), rates from --policy-rates FILE or the run's `pr` (lock_rates(pr, LOCK_MS)), stamps
  index_sha256 / rates_sha256 / rates_source_sha256 (+ _notes keys in scan_artifacts), flags --indices/--policy-rates;
  scan.py 946/985 (acceptance cap 960). prim_index.load_indices needs a D1 FILE FOR EVERY YEAR of [2010, 2016] -> the
  synthetic store writes the December weekdays of 2010-2015 (134 rows locked). Prototype /tmp/p1163 (scen.py; modules
  from /tmp/p1158, /tmp/p1159, /tmp/p1160 prototypes).
- Asks sent (held for quiet hours): decision:positioning-asof-fix (a fix asof / b leave / wait) and
  decision:fsv2-counting (a row + shared 20-try counter / b row only / wait). family3-grammar still unsent (quiet hours).
- NOT done / for the next writer: family-4 grammar ask (needs m / rank1_z numbers like the family-1/3 asks); the three
  grammar tasks once answered (catalogue.yaml + catalogue.py mirror, 14.11 pattern) - after 11.62/11.63 the scan
  evaluates everything; operator derive_bars on ~/fxdata-idx + approvals/INDICES_DEV.txt before any family-3 scan.
- Commit trap again: gate for 16.80 started at 10:30Z while committing -> /tmp/p1163/commit_when_clear.sh (backup copies
  + git add -f, 11.61 before 11.62 because of depends_on). COMMITTED 10:44-10:47Z: 11.61 a033498 / 11.62 31cd138 /
  11.63 b236044. 11.63 review (strong route) caught three sibling-test pins the change breaks (wave2 _Job/_FrameCtx
  tail, 11.61's _notes hash, 11.62's "unwired" index_move/rate_diff match) -> own each sibling test with ONE registered
  edit (16.64 precedent). Next free: 11.64 / 15.43 / 16.82.
