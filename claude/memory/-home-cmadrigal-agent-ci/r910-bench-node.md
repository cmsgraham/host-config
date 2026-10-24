---
name: r910-bench-node
description: operator's home Dell R910 (4x Xeon E7-4870, 40c/80t, 128 GB, no AVX, ~0.7-1 kW) - candidate batch node for synthetic bench S2+/relaxation runs; OFF until S1 is done
metadata:
  type: project
---
Offered 2026-10-24: Dell PowerEdge R910, 4x Xeon E7-4870 2.4 GHz (Westmere-EX: SSE4.2, no AVX/AVX2), 128 GB RAM, currently OFF (operator can power it on). Estimate: ~12-16 synthetic worlds in parallel (RAM-bound), cores ~2-3x slower than the PC -> main bench ~15-25 h instead of ~110 h, relaxation 10-20 h instead of 70-140 h; power ~25-50 kWh per run.
Compat (from fxplat deps, 2026-10-24): numpy 2.5.3 / scipy / numba 0.68 (host JIT) / lightgbm / arch OK; pyarrow 25 + duckdb 1.5 need SSE4.2 (has it); nautilus_trader 1.231 wheel may need AVX2 -> sim tier may stay on PC. No polars.
Plan: after S1 on the PC -> operator powers on; it runs VMware ESXi (FULL licence, likely 6.5/6.7) -> one Ubuntu 24.04 Server VM: 72 vCPU as 4 sockets x 18 cores, 112 GB RAM, 200 GB thin, bridged fixed IP (like docker1), SSH key -> I run a 15-min compat + one-world timing test -> re-estimate S2/relaxation for the operator. Runs as batch, writes only results back; never real data.
Related: [[fxplat-synthetic-known-answer]], [[docker1-binance-node]].
