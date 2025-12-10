# Low-Poly Character Preparation and Texture Generation Pipeline

This document describes the full workflow we used to go from a high‑poly character model to a low‑poly, texture‑ready GLB for use in tools like ComfyUI / Hunyuan3D and, eventually, a game engine (e.g., Godot).

The goal:
- Reduce a heavy 1,315,000‑polygon model to a ~4,400‑polygon game‑ready mesh.
- Prepare clean UVs.
- Render clean multi‑view images for texture generation.
- Export a stable GLB that can be reused in future texturing/baking workflows.

---

## 1. Concepts and Terminology

Before the steps, clarify a few terms you will meet in the pipeline:

- **High‑poly mesh**  
  Original, very dense model (e.g., sculpt or detailed source with 1M+ polygons). Not suitable for real‑time use.

- **Low‑poly / Retopologized mesh**  
  Optimized version of the mesh (~thousands of polygons, not millions). This is what the game engine uses.  
  Often created by:
  - Manual retopology, or
  - Automatic tools + cleanup.

- **UVs / UV unwrapping**  
  The process of projecting the 3D mesh onto a 2D plane so that a texture (image) can be correctly mapped onto the model.

- **GLB**  
  Binary glTF format. Convenient for pipelines, keeps mesh/UVs/material slots in one file.

- **Multi‑view renders**  
  A set of images of the model from several fixed viewpoints (front, 45°, side, 135°, etc.), which are then used by a texturing/ML pipeline to generate coherent textures.

- **Bake**  
  Transferring detail (colors, normals, AO, etc.) from one representation (or from generative output) onto the UV-mapped low‑poly mesh as texture maps.

---

## 2. High‑Poly to Low‑Poly: Mesh Preparation

### 2.1. Open and Inspect the Original Mesh

1. Open the original model in Blender.
2. Switch to **Object Mode** and select the character mesh.
3. Check polygon count:
   - `Object Data Properties` → `Geometry Data` or use `Statistics` in the viewport overlays.
   - Confirm that it is heavy (e.g., ~1,315,000 faces).

**Why this matters:**  
You need to know the starting density to decide how aggressively you must reduce it. Real‑time characters in a first‑person game should be in the low thousands to maybe tens of thousands of polygons, not millions.

### 2.2. Normalize Scale, Rotation, and Position

1. Make sure the character stands at scene origin:
   - Move the mesh so that **feet are at Z = 0**.
   - The character should face **+Y** (or the forward axis your engine uses).
2. Apply transforms:
   - `Ctrl + A` → **Apply** → `All Transforms` (Location, Rotation, Scale).

**Meaning of this step:**  
Consistent transforms avoid future issues when exporting to GLB or importing into other tools. The engine, renderer, and ComfyUI pipeline all assume stable, non‑crazy transforms.

### 2.3. Create the Low‑Poly Version

You have two main options: decimation (fast) or proper retopology (clean but slower).

#### Option A: Quick Decimated Mesh (Prototype / Intermediate)

1. Duplicate the high‑poly mesh:
   - Select the mesh → `Shift + D` → `Enter` to place it.
   - Rename it to something like `Character_low_decimated`.
2. Add a **Decimate** modifier:
   - `Modifier Properties` → Add Modifier → `Decimate`.
3. Choose **Ratio** so that the resulting face count is around 4,400:
   - Start with a low ratio (e.g., 0.01–0.05) and check face count in the modifier panel.
4. Apply the modifier once you’re satisfied.

**Pros:** Very fast, enough for some pipelines.  
**Cons:** Topology is messy, not ideal for deformations/animation, but usable for texturing tests and LODs.

#### Option B: Retopologized Low‑Poly (Recommended for Final)

If you already did proper retopology or plan to:

1. Use retopo tools (Shrinkwrap + snapping, Retopoflow, or your preferred method) to create a clean, animation‑friendly mesh.
2. Target a polygon budget around **4,000–10,000 faces** for a first‑person character.
3. Ensure edge flow follows anatomical logic and deformation zones (joints).

**Why retopo matters:**  
Decimated mesh is ok for rough texturing and tests. But for animation and long‑term maintenance, a retopologized low‑poly is much more predictable and easier to skin.

---

## 3. UV Unwrapping for the Low‑Poly Mesh

### 3.1. Prepare UVs

1. Select the **low‑poly mesh** (retopo or decimated version).
2. Switch to **UV Editing** workspace in Blender.
3. Mark seams:
   - In Edit Mode, select edges where it is natural to "cut" the model.
   - `Ctrl + E` → `Mark Seam`.
4. Unwrap:
   - `A` to select all faces.
   - `U` → `Unwrap`.

**Goal:**  
Get a UV layout with minimal stretching and logical islands (head, torso, arms, legs, accessories). This is crucial because generated textures will follow this mapping.

### 3.2. Check and Pack UV Islands

1. In the UV editor, enable Stretching or use a checker texture to visualize distortion.
2. Adjust seams/unwrap until stretching is acceptable.
3. Pack islands:
   - `UV` → `Pack Islands`.
   - Keep everything within the 0–1 UV space.

**Why:**  
Texture tools assume well‑packed UV islands in 0–1 space. Bad packing leads to wasted resolution and artifacts.

---

## 4. Setting Up the Scene for Multi‑View Renders (Blender)

The goal is to get clean, material‑agnostic renders from several angles for later texturing/ML stages.

### 4.1. Create and Assign an Active Camera

If you see `No Active Camera` or you don't have a numpad, do this:

1. Add a camera:
   - `Shift + A` → `Camera`.
2. Make it the active camera:
   - Select the camera → `Ctrl + 0` (on the main keyboard, or use `View` menu)  
   or  
   - `View` → `Cameras` → `Set Active Object as Camera`.

**Meaning:**  
Blender needs an **active camera** to render F12. Without it, you get the `No Active Camera` error.

### 4.2. Set Front View Without a Numpad

Because you don’t have a numpad, use menu commands instead of `Numpad 1`:

1. Select the character mesh.
2. Align viewport to front:
   - `View` → `Viewport` → `Front`  
     (equivalent of `Numpad 1`).

Now the 3D viewport is in front‑orthographic view.

### 4.3. Align the Camera to the View

1. With the viewport in front view, align the active camera:
   - `View` → `Align View` → `Align Active Camera to View`  
     (equivalent of `Ctrl + Alt + Numpad 0`).

2. Press `0` (or `View` → `Cameras` → `Active Camera`) to see through the camera.

**Why this step exists:**  
You want the camera to exactly match your current viewport perspective. This guarantees a clean, predictable framing of the character.

### 4.4. Render Settings

1. Go to **Render Properties**:
   - Render Engine: `Cycles` or `Eevee` (does not matter much for flat, untextured geometry).
2. Go to **Output Properties**:
   - Resolution: `1024 x 1024` (square, good balance of detail and speed).
3. Material/Lighting:
   - Use a neutral world background.
   - No complex materials or textures: the mesh should be **pure geometry**, possibly a flat grey.
   - Enable simple lighting (e.g., one sun or HDRI) just to show volume.

**Purpose:**  
You are generating geometric reference views, not final beauty renders. The ML / texture pipeline will use these to infer how to paint the model.

---

## 5. Capturing the Four Core Views

Target images:

- `view_front.png`
- `view_45.png`
- `view_side.png`
- `view_135.png`

### 5.1. Front View (`view_front.png`)

1. Confirm the character faces forward.
2. Ensure the camera is aligned to the front view as in section 4.2–4.3.
3. Render:
   - Press `F12`.
4. Save:
   - `Image` → `Save As…`
   - Name: `view_front.png`.

**Why:**  
Front view is the primary reference: the model’s silhouette, proportions, and central features are all clearly visible.

### 5.2. 45° View (`view_45.png`)

1. Exit the render view back to the 3D viewport.
2. Rotate the model (or the camera) by **+45° around the Z axis**:
   - Select the character mesh.
   - `R`, then `Z`, then type `45`, press `Enter`  
     or use the transform panel to set `Z Rotation = 45°`.
3. Align camera to current view (if needed):
   - `View` → `Align View` → `Align Active Camera to View`.
4. Render with `F12`.
5. Save as `view_45.png`.

**Meaning:**  
This shows partial side and front simultaneously, giving the texture/ML system more information about depth and forms.

### 5.3. Side View (`view_side.png`)

1. From the 45° pose, rotate another +45° around Z (total 90° from the original front):
   - `R`, `Z`, `45`, `Enter` (or set rotation to `Z = 90°`).
2. Align camera to view (same menu as before).
3. Render with `F12`.
4. Save as `view_side.png`.

**Why:**  
Pure side profile defines nose, jawline, chest depth, backpack/profile elements, etc. Critical for believable texture and shading.

### 5.4. 135° View (`view_135.png`)

1. Rotate another +45° (total 135° from the front):
   - `R`, `Z`, `45`, `Enter` (or set rotation to `Z = 135°`).
2. Align the camera to view.
3. Render with `F12`.
4. Save as `view_135.png`.

**Purpose:**  
This angle shows the back‑side transition, capturing details like cloak folds, straps, gear, hair volume, etc.

---

## 6. Exporting the Low‑Poly GLB

Once your low‑poly mesh and UVs are ready, and you’ve generated the reference renders, export the game mesh.

### 6.1. Clean the Scene

1. Remove or hide the high‑poly mesh (if not needed in this file).
2. Keep only:
   - Low‑poly character mesh.
   - Optional armature (if already rigged).
3. Make sure transforms are applied and mesh stands correctly.

### 6.2. Export GLB

1. Select the low‑poly mesh (and armature if used).
2. `File` → `Export` → `glTF 2.0 (.glb/.gltf)`.
3. Choose:
   - Format: `GLB` (binary).
   - Include: `Selected Objects`.
   - Check `Apply Modifiers`.
   - Ensure `UVs` and `Normals` are included (usually on by default).
4. Name the file meaningfully, e.g.:
   - `alkoldun_lowpoly_retopo.glb`  
   or  
   - `character_v001_retopo_lowpoly.glb`.

**Why GLB:**  
GLB is compact, self‑contained, and well supported by modern tools (ComfyUI nodes, game engines, viewers).

---

## 7. Feeding the Mesh and Views into a Texture Generation Pipeline

This section describes the logic you will follow in tools like ComfyUI / Hunyuan3D. Node names may differ slightly between versions, but the flow stays the same.

### 7.1. High‑Level Flow

The basic flow:

1. **Load mesh** (`alkoldun_lowpoly_retopo.glb`).  
2. (Optional) Re‑wrap UVs if needed.  
3. Configure multi‑view cameras around the model (front, 45°, 90°, 135°, etc.).  
4. Render geometry from these cameras.  
5. Use the renders as conditioning for a texture generation model.  
6. Bake the generated textures back onto the mesh using the UVs.

In many Hunyuan3D / ComfyUI setups this is described as:

> **render → textures → bake**

### 7.2. Typical Node Sequence (Conceptual)

This is a conceptual mapping to nodes you might see:

1. **Hy3DLoadMesh**  
   - Input: `alkoldun_lowpoly_retopo.glb`  
   - Output: `MESH`.

2. **Hy3DMeshUVWrap** (optional)  
   - If you already have good UVs from Blender, you can skip or just pass through.

3. **Hy3DMeshRenderer** or **Hy3DNvdiffrastRenderer**  
   - Takes `MESH` and prepares it for rendering as `MESHRENDER`.

4. **Hy3DCameraConfig / Hy3DSampleMultiView**  
   - Configure camera positions around the character (front, 45°, side, 135°, etc.).
   - Matches the logic of `view_front.png`, `view_45.png`, etc.

5. **Hy3DRenderMultiView**  
   - Input: `MESHRENDER + CAMERA CONFIG`.
   - Output: a set/list of rendered images from each camera view (multi‑view).

6. **Texture Generation Node(s)**  
   - Takes the multi‑view renders as input.
   - May involve text prompts (style, material, "dark fantasy", etc.).
   - Outputs one or more texture maps aligned with your UVs.

7. **Hy3DBakeTextures / Equivalent**  
   - Bakes generated textures into final texture maps on the UV layout of the low‑poly mesh.

**Why the Blender multi‑view still matters:**  
Even if the pipeline renders its own views, your Blender exports and images help you control framing and provide debugging reference: if something looks off in the generated textures, you know what the model and views were supposed to look like.

---

## 8. Naming and Versioning

To avoid confusion as you iterate, use clear names:

- Meshes:
  - `alkoldun_highpoly_source.blend`
  - `alkoldun_lowpoly_retopo.blend`
  - `alkoldun_lowpoly_retopo.glb`

- Renders:
  - `view_front.png`
  - `view_45.png`
  - `view_side.png`
  - `view_135.png`

- Textures (once baked):
  - `alkoldun_albedo_v001.png`
  - `alkoldun_normal_v001.png`
  - `alkoldun_roughness_v001.png`

Add semantic versioning as you iterate: `v001`, `v002`, etc.

---

## 9. Summary of the Pipeline

1. Take **high‑poly** character.
2. Create **low‑poly / retopo** version (~4.4K polys).
3. Clean transforms and pose (origin, orientation, scale).
4. **UV unwrap** the low‑poly with clean seams and packed islands.
5. Set up a camera in Blender, align to front and rotate the model to capture:
   - front, 45°, side, 135° views.
6. Render at `1024 x 1024`, flat shading, no textures:
   - Save `view_front.png`, `view_45.png`, `view_side.png`, `view_135.png`.
7. Export **GLB** of the low‑poly mesh with UVs.
8. Load GLB and views into ComfyUI / Hunyuan3D‑based pipeline:
   - `load mesh → setup cameras → render multi‑view → generate textures → bake`.
9. Save resulting textures and re‑use this document as your reproducible checklist for future characters.

This document is meant to be a stable reference so you can repeat the pipeline without re‑discovering the steps each time.
