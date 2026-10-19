---
name: worktree-pyarrow-drift-golden-hash
description: Fresh worktree .venv resolves pyarrow 26 (pyproject says >=15) but registered dataset hashes are pyarrow 25.0.1 — golden-creation hash gate fails
metadata:
  node_type: memory
  type: project
  originSessionId: e06a0efe-588b-45d5-b393-68b85f2be48a
  modified: 2026-10-18T04:42:30.280Z
---

Since ~2026-10-17, `git.worktree_setup` builds `.venv` with pyarrow 26.0.0 / numpy 2.5.4, while the home
venv `/home/cmadrigal/Dukascopy/.venv` has pyarrow 25.0.1 / numpy 2.5.3. Parquet files embed
`created_by` (parquet-cpp-arrow version), so every table sha256 — and `dataset_sha256` in
fxplat.pipeline.symbol_stage — differs even when the content is identical. Registered hashes
(DATASET_SHA256_HOME in tests/pipeline/test_symbol_stage.py, test_research_run_datasets.py) are measured
in the home venv, so the golden "reference creation" gate fails in the worktree venv (seen TASK-3.115).

**Why:** pyproject only pins `pyarrow>=15`; builders may not pip install.

**How to apply:** when a task regenerates golden/symbol_stage or golden/research_run, run the creation
step with `PYTHONPATH=$PWD/src /home/cmadrigal/Dukascopy/.venv/bin/python -m pytest <hash test>` (check
`fxplat.__file__` points at the worktree), then run acceptance with the worktree `.venv` (the compare
path is rtol-based, not hash-based, so it passes on pyarrow 26). Diagnose with
`pq.ParquetFile(p).metadata.created_by`. Operator fix: pin pyarrow==25.0.1 or re-measure hashes.
