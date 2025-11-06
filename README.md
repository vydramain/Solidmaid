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

## Current Gameplay Slice

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
docs/                  Codestyle (CGS) and design document (GDD)
resources/
  main/                Main scene that orchestrates level loading
  objects/             Gameplay scenes (levels, player, enemies, items)
  overlap/             Shared building blocks (physics, hit/hurt boxes, throwables, VFX)
  systems/             Gameplay and world systems (audio, enemies, procedural level code)
scripts/utils/         Autoload-style helpers (Custom Logger, Resource Registry)
```

IDs inside `Resource_Registry.gd` resolve UID strings to packed scenes and environment prefabs; the project relies on these mappings instead of hard-coded file paths.

---

## Controls

| Action          | Default Binding                          |
|-----------------|-------------------------------------------|
| Move            | `W`, `A`, `S`, `D` (left stick on gamepad)|
| Attack / Throw  | Left mouse button (`action_attack`)       |
| Throw direction | Right stick (`look_*` actions)            |

Throw direction is currently read from the `look_*` axis actions. If you play with keyboard + mouse, add additional bindings in *Project Settings → Input Map* (for example, arrow keys) so the `Player` can compute a throw vector.

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
