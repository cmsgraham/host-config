---
name: gateway-3d-print-feature
description: "Gateway '3D Print' tab: upload a picture -> ComfyUI TRELLIS.2/Pixal3D image-to-3D -> print-ready STL; built 2026-11-23, one GPU validation run still pending"
metadata:
  node_type: memory
  type: project
  originSessionId: 65592fdb-22b6-4529-9491-76c88746cc4c
  modified: 2026-11-24T04:58:11.893Z
---

2026-11-23: built a **"3D Print" tab in the gateway** (Cristian's ask: "upload a picture and it
generates the 3d image and one step forward and stl file ready to 3D print"). Decisions he made:
full print-prep · both engines · 50 mm default · build now, defer the GPU test (another session was
using ComfyUI for the Leonardo props [[comfyui-two-instances]]).

Flow: upload image -> ComfyUI (Image mode, both 3090s) runs the TRELLIS.2 / Pixal3D image-to-model
graph -> textured GLB -> a watertight, oriented, 50 mm-scaled **STL** for a slicer.

Files (all in ~/ollama-gateway):
- `model3d.py` — sessions/worker like [[gateway-dashboard-live-file]]'s imagechat.py. The ComfyUI
  graph is NOT hand-wired: it loads the shipped template `3d_pixal3d_trellis2_image_to_model` and
  converts UI->API format driven by live /object_info. Gotchas handled: PreviewImage/MaskPreview
  are PASS-THROUGH here (follow links through them), seeds carry control_after_generate, and
  RemeshMesh.sign_mode is a COMFY_DYNAMICCOMBO_V3 that inlines its option's sub-widgets (fill,qef).
  Offline validator (validate_api) checks the graph vs /object_info with ZERO GPU.
- `model3d_stl.py` + venv `model3d-venv` (trimesh 5.2.2 + manifold3d) — GLB->STL: merge, watertight
  (fill-holes, manifold fallback), stable-pose orient, seat on z=0, scale to mm. Called as a
  subprocess (gateway runs on system /usr/bin/python3, kept clean).
- gateway.py: `import model3d`, GET `/_dash/model3d/{sessions,session,file}`, POST
  `/_dash/model3d/submit` (image as base64 JSON), `model3d.recover()` at start.
- UI: nav `data-page="model3d"`, PAGES.model3d + m3* fns in ui/app.js, styles in ui/app.css.
  3D preview uses `<model-viewer>` from jsdelivr (degrades to download links if offline).

Weights downloaded to ~/comfyui/models (both engines): trellis_2_int8_convrot, pixal3d_int8_convrot,
trellis_2_shape/texture_vae, dino_v3_L_naf, moge_2_vitl_normal, birefnet. TRELLIS.2 nodes are NATIVE
in ComfyUI core now (not a custom-node pack).

**OPEN — the only untested bit:** one real image->3D->STL run on the GPU, to confirm ComfyUI accepts
the V3 dynamic-combo's flattened sub-inputs and to learn the Save3DAdvanced history output key
(_collect_outputs/pick_mesh are generic for now). Run it when ComfyUI is free; a /prompt 400 names
any bad node in one line. Needs Image mode on. Related: [[leonardo-vr-art-gallery]] [[focus-fxplat-2026-10]].
