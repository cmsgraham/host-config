---
name: gateway-orchestrator
description: Gateway GPU Orchestrator — named workloads, auto/manual switch, live view on the GPUs page
metadata:
  type: project
---

Built 2026-10-27 so GPU contention (voice vs [[voicelab-gpu-contention]] the fxplat
pipeline) is a glance + a switch, not manual lease archaeology. Layers ABOVE the tested
lease arbiter (gpulease.py) — adds no admission logic.

- `~/ollama-gateway/orchestrator.py`: pure `build_status()` (arbiter status + loaded +
  recent requests + gpu.* events + mode -> view) and `Controls` (mode persistence +
  manual presets). Tests: `tests/test_orchestrator.py` (8). Classifies work into named
  WORKLOADS: voicelab (lease client=voicestudio), pipeline (requests carry run_id/task_id),
  rag (embedding model), other. States: running/yielding/idle/off.
- Wired in gateway.py: `dash_data()["orchestrator"]=orch_status()`; `_dash_action`
  actions `orch_auto` / `orch_voice_mode` / `orch_pipeline_mode` / `orch_control`
  (loopback/token only). Mode persists to `orch-mode.json`. Project/paths are env-
  overridable (ORCH_PROJECT=Dukascopy, ORCH_PROJECT_HOME, ORCH_AGENT_CI_HOME, ORCH_VS_SH).
- UI: Orchestrator section at the TOP of the GPUs page (ui/app.js `orchRender`/`orchAct`,
  served per-request — no restart for UI). Mode label + Auto/Voice/Pipeline buttons + live
  workload cards + waiting/ending + recent arbiter events.
- MANUAL switch: **Voice mode** = `agent-ci stop` (pause loop) then a retry-wrapped
  `vs.sh start` (pausing doesn't free GPU1 until the in-flight step idles, so it loops
  ~2.5 min until /health answers). **Pipeline mode** = `vs.sh stop` then rm STOP + start
  the watchdog. Switches run in a background thread (mode shows `busy` while running).
- Deploy = `sudo systemctl restart ollama-gateway.service` (SYSTEM unit, passwordless
  sudo). A restart wipes the in-memory lease registry but voice SURVIVES: vs_lease.py's
  renew thread re-registers as resident when the gateway forgets the lease
  (gpulease_client.py `_renew`). Restart only when inflight==0.
