# Solidmaid

Project reboot: first-person folk-horror shooter (FPS) built with Godot 4.5. You guide Vasiliusavich through a loop of three locations — a cramped apartment, an uncanny street, and a factory floor — using improvised tools (bricks, pipes) and a brief ritual/assembly under pressure. The current repository still contains the legacy top‑down prototype; the FPS slice is being developed per the new GDD.

---

## Overview

- **Engine:** Godot 4.5 (`renderer: gl_compatibility`).
- **Design direction:** FPS reboot per `docs/design/GDD_v2.md` (legacy 2D systems remain until replaced).
- **Legacy entry point:** `res://resources/main/Main.tscn` (autoloads `MusicPlayerSystem.gd`).
- **Legacy scene flow:** Home → Outside street → Factory → loops back to Home.
- **Current focus:** Building the FPS vertical slice (first‑person controller, brick/pipe combat, street blockouts, factory ritual).

See `docs/design/GDD_v2.md` for the up-to-date design snapshot.

---

## Current Gameplay Slice (legacy top-down)

- **Home level:** Static apartment layout with interactable floor lines and a transition trigger to leave the house.
- **Outside level:** Chunk-based street generator (`OutsideMapLayer`, layered tilemaps, environment pop-in) that instantiates background, decoration, and environment nodes per chunk.
- **Factory level:** Prototype arena with an enemy spawner scaffold and loop-back trigger.
- **Player abilities:** WASD-style movement via `CharacterBox`, sprite facing swap, timed brick throwing (`Brick` + `Throwable` physics), temporary invincibility, and basic HP tracking inherited from `Entity`.
- **Enemies:** Placeholder `Enemy` scene using `CloudAttack` (animated hurtbox) that shares the `Entity` foundation.
- **Level transitions:** `LevelLoaderSystem` watches for player collisions and hands control to `Main.gd` to instance the next level packed scene.
- **Audio:** `MusicPlayerSystem` autoload maintains looping tracks and events (`home`, `work`, `factory`, `boss`, etc.) with stateful transitions.

---

## Project Structure

```
assets/                Art and audio (pixel sprites, tiles, music MP3s)
docs/                  Codestyle (CGS) and design documents (GDD)
resources/
  main/                Legacy entry (2D) and scene orchestration
  objects/
    character/         FPS V2 character scene (`Character.tscn`) + glue (`character.gd`)
    legacy_enitity/    Legacy 2D entities (existing gameplay loop)
  overlap/
    locomotion/        CharacterBody3D movement (`Locomotion.tscn/.gd`)
    controller_slot/   Controller slot + Player/AI controllers
    abilities/         Ability shell + `Melee.tscn`, `Throw.tscn`
    vitality/          Health/HP component
  systems/
    legacy_enemies/    Legacy 2D enemy systems
    legacy_environments/ Legacy 2D environment systems
    legacy_level/      Legacy 2D level systems (loader, outside)
    audio/             Shared audio systems (autoload music player)
scripts/utils/         Helpers (e.g., `CustomLogger.gd`)
```

- FPS V2 scaffolding is not yet wired into the main entry scene; it lives under `resources/objects/character/` and `resources/overlap/` for now.

---

## Controls

- **Legacy prototype:** `move_up/down/left/right` for WASD and `action_attack` on LMB.
- **FPS V2 sandbox:**
  - Move: `move_forward/backward/left/right` (WASD) 
  - Look: mouse (cursor is captured by default, press `Esc` to release, click to recapture)
  - Attack / melee: `attack` (LMB)
  - Throw placeholder: `throw` (RMB)
  - Interact ray: `interact` (`E` / gamepad south button)

---

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/vydramain/Solidmaid.git
   cd Solidmaid
   ```
2. Open `project.godot` with **Godot Engine 4.5** or newer.
3. Ensure the `MUSIC_PLAYER` autoload is enabled (importer sets it up automatically).
4. Run the project (F5) — the main scene loads the outside level by default and listens for level triggers.
   - For FPS testing, open `resources/objects/sandbox/Sandbox.tscn` and run that scene instead.

All dependencies are committed; no external packages are required.

---

## Development Notes

- **Logging:** Use `Custom_Logger` (`scripts/utils/CustomLogger.gd`) to respect rate limiting and colored log levels.
- **Resource access:** `Resource_Registry.gd` provides UID lookups for levels, environment props, and entity scenes.
- **Procedural street:** `OutsideMapLayer.gd` manages a 3D array of layer data, delegating to drawer systems that stamp tile/scene data into background, decoration, and environment layers before applying them to tilemaps or node containers.
- **Combat helpers:** Common hit/hurt boxes, throwable physics, and animation-driven attack collision live in `resources/overlap/`.
- **Audio system:** `MusicPlayerSystem.gd` keeps an `AudioStreamPlayer` child around, advances through state machines, and reacts to gameplay events (`play_next("home")`, etc.).
- **Enemy spawner:** `EnemySpawnerSystem.gd` scaffolds timed spawning around the player; the actual `spawn_enemy()` call is currently commented out.

---

## FPS V2 Progress (in-flight)

- **PlayerFPS scene:** `resources/objects/character/Character.tscn` instantiates the `Locomotion` CharacterBody3D as its root with attached camera, interactor, vitality, abilities, and controller slot.
- **Controller:** `ControllerForPlayer.gd` handles look/move input, cursor capture (Esc releases, click/focus restore), and delegates to ability/interactor components. Stub `ControllerForAI.gd` exists for future NPC behavior.
- **Locomotion:** `resources/overlap/locomotion/locomotion.gd` provides yaw/pitch, gravity, and configurable speed/sensitivity defaults (5 m/s, 0.003 sens, 30 gravity, ±85° pitch clamp).
- **Interactor:** Forward RayCast3D that calls either `interact(by)` or an `interactable` group signal when you hit a target (hooked into the controller). UI prompt still TODO.
- **Sandbox:** `resources/objects/sandbox/Sandbox.tscn` instantiates the Character on a flat floor for quick testing of movement/look/interact. Add a WorldEnvironment/Skybox if you want a horizon reference while prototyping.
- **Input map:** `project.godot` now defines both legacy (`move_up/down/left/right`, `action_attack`) and FPS actions (`move_forward/backward`, `move_left/right`, `attack`, `throw`, `interact`).

> Until FPS content replaces the legacy loop, launch `Sandbox.tscn` for first-person tests and `Main.tscn` for the top-down slice.

---

## Roadmap & Known Gaps

- Enable the enemy spawner once combat balancing is ready.
- Expand the factory encounter and add gameplay objectives.
- Integrate non-gamepad aiming options by default.
- Fill out lamppost/interactable systems referenced in the design goals.
- Add automated tests or debug scenes for chunk generation regressions.

Contribute ideas or fixes through pull requests or issues.

---

## License

Released under the MIT License. See [`LICENSE`](LICENSE) for details.
