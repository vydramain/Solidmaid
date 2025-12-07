# How to Attach a Player Body Model

This guide explains how to plug any GLB mesh into the Character entity via the new BodyComponent.

## 1. Import the GLB
- Drop your `*.glb` file into `assets/models/player/`.
- Godot will create a matching `*.glb.import` file automatically (keep it in Git).

## 2. Set up the BodyComponent
- Open `res://resources/objects/character/Character.tscn`.
- Select the `BodyComponent` child node. In the Inspector set `Body Scene` to your imported GLB (it shows up as a `PackedScene`).
- If you only need this mesh for a specific player variant, make an inherited scene of `Character.tscn` and set `Body Scene` there, so the base prefab stays generic.

## 3. Adjust transforms
- After assigning the GLB, expand the `BodyComponent` node and tweak the spawned mesh transform so it lines up with the capsule collider and `VisionRig`.
- Use the `editable` flag in the Character scene to edit `BodyComponent` directly when instanced.

## 4. Future extensions
- Add sockets/markers (e.g., weapon mounts) as children of the spawned mesh inside BodyComponent—they will follow whatever model is assigned.
- If you need per-model scripts (materials, animation wiring), wrap the GLB in its own scene that already contains the extra nodes, then assign that scene to `Body Scene`.

With this flow, the Character logic stays component-based: BodyComponent owns visuals, while movement, camera, and abilities remain decoupled.
