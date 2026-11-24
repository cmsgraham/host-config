---
name: gateway-3d-print-feature
description: "Gateway '3D Print' tab: upload a picture -> ComfyUI TRELLIS.2/Pixal3D image-to-3D -> print-ready STL; built 2026-11-23, one GPU validation run still pending"
metadata:
  node_type: memory
  type: project
  originSessionId: 65592fdb-22b6-4529-9491-76c88746cc4c
  modified: 2026-11-24T20:51:47.247Z
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

2026-11-24: two Tux failures debugged after deploy. (1) HTTP 400 node_errors = converter widget
alignment (dynamic-combo dotted sub-keys sign_mode.fill/qef + consume linked-widget placeholders);
fixed, validates 0-problem. (2) Then `ComfyUI: Decoder not found` — Tux was an **SVG saved under a
.png name** (submit() kept the claimed extension), so PIL got `<?xml ...>` bytes. Fixed BOTH sides:
UI `m3Rasterize()` draws any browser-decodable image (incl. SVG) to a canvas and uploads a real PNG;
server `_sniff_ext()` sets the extension from magic bytes and rejects SVG/vector with a clear message.
app.js is a static file (hard-refresh to pick it up). SVG/flat logos are weak 3D subjects anyway.

**END-TO-END PROVEN 2026-11-24**: sessions e45cc2df32bb (Linux logo) and eccfabab2ab3 both ran
ComfyUI -> GLB -> STL. The graph converter and the Save3DAdvanced output handling are correct.

**STL repair — the real defect, measured.** Cristian repaired one of our STLs on formware.co and gave
me the before/after pair; that file pair, not the site, was the evidence (the page documents no
algorithm: it is the engine from Formware's resin slicer, free, 6 h retention, API EUR100/mo).
- Pixal3D/TRELLIS output has **non-manifold edges (254), ZERO holes** — marching-cubes pinch points.
  Hole-filling is irrelevant; `trimesh.repair.fill_holes` can't help, and **manifold3d REFUSES a
  non-manifold mesh** (returns empty), so the old fill_holes->manifold chain had no stage that could
  ever fix it => every run reported `fill-holes(not-watertight)`, `printable:false`.
- Formware's fix is surgical: -41 faces, +46 vertices, bbox identical to ~1 micron, 254 nonman -> 0.
  Not a remesh. That is MeshLab's standard repair pipeline.
- Benchmarked MeshLab against it on the same file: `meshing_repair_non_manifold_edges`
  **method="Remove Faces" clears all 254 and reproduces Formware exactly (18.053 cm3)**;
  **"Split Vertices" left all 254 in place (no-op)**. Constant `NM_EDGE_METHOD` — re-measure before
  changing. Order matters: remove faces -> repair_non_manifold_vertices -> close_holes patches the gap.
- Added to model3d_stl.py: MeshLab stage between fill_holes and manifold3d; shell triage (drop bodies
  <0.1% of the largest = AI specks/bubbles, boolean-UNION overlapping bodies so overlaps stop being
  self-intersections); before/after defect report in the metadata; opt-in `--force-solid` voxel wrap.
  Result on the real mesh: 254->0 nonman, watertight+is_solid+printable, 99.98% of triangles kept,
  6.9 s. Note `split()` cuts the mesh at pinch points, so junk-shell removal alone fixed this one.
- Deps now in model3d-venv: **pymeshlab** (needs `apt install libopengl0` in WSL or every plugin
  fails to load; also `uv pip install --python ./model3d-venv/bin/python` — that venv has no pip)
  and **scikit-image** (trimesh's `marching_cubes`, i.e. --force-solid, needs skimage).
- **Texture trap (37x):** the same 700k-tri mesh took 6.9 s from an STL but **>300 s from the
  textured 35 MB GLB** — materials/UV get dragged through split(), the diagnosis and the MeshLab PLY
  round-trip. `_geometry_only()` rebuilds vertices+faces right after the merge: 8.2 s. An STL carries
  no colour anyway, and the GLB is still kept for the colour download.
- Verified on 5 synthetic defects (hole, overlap, junk shells, flipped normals, open sheet): all
  printable. A holed sphere needs the MeshLab stage; trimesh's fill_holes alone fails on big holes.

**PARITY CONFIRMED 2026-11-24 (2nd ground-truth pair).** Cristian ran our NEW output (session
f4e657ed888f, the buff penguin) through formware.co again: **identical** — same 15.013 cm3 volume,
same 42.81x50x23.01 bbox, both watertight/solid, 0 boundary + 0 non-manifold on both. Formware only
re-tessellated (+102 tris, +38 verts). It found nothing to fix, so the local step is at parity and
that website is no longer needed. Second mesh with the UV-seam profile too (59,894 boundary edges,
432 apparent shells -> 1 welded solid). The repair report is in the UI; `printable` drives the chip.

**Watch:** stable-pose auto-orientation LAYS FIGURINES DOWN (the penguin seated on its back — a
top-heavy figure on small feet is not stable upright). Good for printing (less support) but
surprising; untick orientation in the tab to keep a figure standing.

**OPEN:** consider exposing --force-solid as a toggle. Flat 2D logos are weak 3D subjects regardless. Related: [[leonardo-vr-art-gallery]]
[[research-before-workaround]] [[focus-fxplat-2026-10]].
