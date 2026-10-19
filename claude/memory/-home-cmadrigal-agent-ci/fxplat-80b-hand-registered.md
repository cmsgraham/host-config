---
name: fxplat-80b-hand-registered
description: "The 80b reviewer is now a proper `ollama create` registration (2026-10-05, blob b11183a…); Ollama 0.33 create needs ~2x model size of temp disk, so big creates are staged on C: with a throwaway instance"
metadata:
  node_type: memory
  type: project
  originSessionId: 55bd64a2-66e1-476a-8bda-736c6625733c
  modified: 2026-10-06T00:46:45.335Z
---

`qwen3-coder-next:80b-iq4xs` (reviewer for fxplat/Dukascopy, snoopy_frog, x-scraping) was hand-registered on
2026-10-04 (manifest written by `register_80b.sh`, GGUF hardlinked as the blob). On 2026-10-05 the user asked
for a proper registration; it is now an `ollama create` product: model blob `sha256-b11183a…` (the rewritten
GGUF, new digest), config with renderer/parser qwen3-coder, params num_ctx 262144 / temp 1 / top_k 40 / top_p 0.95.
The source GGUF in `~/models/qwen3-coder-next-gguf/` was deleted; re-download from unsloth if ever needed.
Verified through the gateway (REVIEWER-OK, 3.5 min cold load).

**Why it was hard:** Ollama 0.33 `create` from a GGUF always runs a `COPY` quantize pass (full rewrite) and
then copies that output into a digest blob — peak temp ≈ 2× model size, even when the source blob already
exists. Root ext4 was at 158G with the disk guard at 200G (`/usr/local/bin/disk-guard.sh`, stops ollama).
Killing the `ollama create` client does NOT stop the server-side rewrite.

**How to apply:** for any create over ~20 GB, run a throwaway CPU-only instance
(`OLLAMA_MODELS=/mnt/c/... OLLAMA_HOST=127.0.0.1:11436 CUDA_VISIBLE_DEVICES=-1 ollama serve`), create there,
then copy blobs + manifest into `~/.ollama/models` (verify the sha256). Stop the staging instance by its PID
only — never `pkill -f 'ollama serve'`, it matches the main service. The WSL vhdx (F:) is sparse, so the guard's
premise is partly stale; a disk move (spare 1TB SN730 for WSL, see [[disk-layout-oculink]]) is planned.
See [[wsl-disk-exhaustion-crash]], [[cold-prefill-loop]].
