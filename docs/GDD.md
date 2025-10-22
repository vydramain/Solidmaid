# Game Design Document: Solidmaid — Alkoldun Vasiliusavich

---

## 1. Overview

### Title
Solidmaid: Alkoldun Vasiliusavich

### Genre Snapshot
Top-down brawler / roguelite experiment with strong narrative tone and procedural street traversal.

### Engine & Platform
- **Engine:** Godot 4.5 (GDScript).
- **Primary platform:** PC (Windows / Linux). macOS builds are feasible once input is finalised.

### Visual & Audio Direction
- Pixel-art sprites with exaggerated proportions, parallax backgrounds, and 16px tilemaps.
- Muted industrial palette punctuated by neon folklore touches.
- Lo-fi industrial ambient soundtrack with state-driven transitions handled by the in-game music player.

### Elevator Pitch
Relive the exhausting loop of an alternate 1990s factory worker. Wake up in a cramped apartment, trudge through a repeating street, report to the factory, and return home. Improvised combat (brick throwing, close brawls) collides with surreal events, while the world subtly mutates to mirror the protagonist’s fraying psyche.

---

## 2. Core Pillars

1. **Routine as Narrative:** The Home → Street → Factory → Home loop communicates monotony and psychological erosion. Small changes matter more than spectacle.
2. **Gritty Street Combat:** Encounters emphasise improvised tools, positioning, and deliberate timing. Throw physics and invincibility windows must feel weighty.
3. **Satirical Folk Horror:** Humor and dread coexist. Post-Soviet mundanity twists into folklore caricature backed by unsettling soundscapes.
4. **Procedural Familiarity:** Chunk-based street generation mixes recognisable blocks to feel both routine and uncanny, supporting replayable loops.

---

## 3. Current Prototype Snapshot

Implemented in the repository today:

- **Playable loop** across Home, Outside, and Factory scenes with automatic cycling.
- **Player system**: WASD / left-stick movement, sprite flipping, timed brick throwing with bounce physics, temporary invulnerability, HP tracking via the shared `Entity` base class.
- **Enemy placeholder**: `Enemy` + `CloudAttack` demonstrates timed hurtboxes and shared entity infrastructure.
- **Street generator**: `OutsideMapLayer` assembles tilemap layers using drawer systems, populating background, decorations, and environment props.
- **Audio state machine**: `MusicPlayerSystem` autoload swaps tracks on `home`, `work`, and `factory` events.
- **Tooling**: `Custom_Logger` for rate-limited logs, `Resource_Registry` for UID lookups, reusable hit/hurt boxes and throwable physics.
- **Known gaps**: Enemy spawner disabled, lamppost gameplay not yet implemented, keyboard aiming requires manual bindings, factory arena is a stub.

---

## 4. Core Loop (Intended Experience)

1. **Home — Preparation**
   - Explore the apartment, trigger flavour interactions, and optionally apply buffs/debuffs (future alcohol or ritual systems).
   - Exit trigger hands control back to `Main`, loading the Outside scene.

2. **Outside — Commute & Encounter**
   - Chunk generator builds a repeating street (sidewalks, buildings, fences, props).
   - Player travels forward, fights enemies, scavenges items, and encounters surreal events.
   - Transition trigger leads toward the factory once objectives are met.

3. **Factory — Work Under Fire**
   - Arena-style encounter that pairs combat with “productive” tasks (assembling lamppost segments under pressure).
   - Boss or wave mechanics escalate tension.
   - Success (or survival timer) returns the player home.

4. **Return — Reflection & Mutation**
   - Home scene updates with new props, dialogue beats, or tone shifts.
   - Difficulty modifiers, street seeds, and narrative flags adjust upcoming loops.

Repeat with incremental escalation until narrative climax (to be defined).

---

## 5. Systems Detail

### 5.1 Player
- Based on `Entity` (`Area2D`) with HP, invincibility, and death signals.
- Nested `CharacterBox` (`CharacterBody2D`) handles movement physics.
- `Player.gd` manages animation switching, sprite facing, attack cooldowns, and throwable instantiation.
- `Brick` + `Throwable` provide parabolic arcs, bounces, and landing checks.
- Planned additions: stamina/fatigue management, alcohol buffs, contextual interactions in Home.

### 5.2 Combat & Items
- **Brick**: Default throwable using physics-based arcs and animation-driven hurtboxes.
- **Hit/Hurt boxes**: Shared scenes grouped by purpose (`Hitboxes`, `Hurtboxes`) for reusable collision logic.
- **Invincibility windows**: Timer-based invulnerability after throws or damage.
- Roadmap: Expand arsenal (bottles, lamppost components), introduce melee chains and parries.

### 5.3 Enemies
- Current `Enemy` showcases base stats and a cloud-like area attack.
- `EnemySpawnerSystem` scaffolds timed radial spawning around the player (spawn call re-enabled once AI is stable).
- Planned archetypes:
  - **Gopnik bruiser** — close-range pressure, crowd control resistance.
  - **Folkloric spirit** — ranged disruption, hallucinatory effects.
  - **Factory foreman (boss)** — multi-phase fight combining labour tasks and attacks.

### 5.4 Level Structure
- **Home**: Hand-authored TileMap layers (`HomeMapLayer`) with background, furniture, walls, and wallpaper front/back.
- **Outside**: `OutsideMapLayer` maintains a 3D layer array (background, decorations, environment layers) and delegates drawing to lower/upper drawer systems. Sidewalk detection and prop placement prepared for future variations.
- **Factory**: TileMap arena with `EnemySpawnerSystem`, placeholders for UI, and loop-back trigger.
- **Transitions**: `LevelLoaderSystem` (Area2D) calls `Main.load_level(next_scene)` while logging current state.

### 5.5 Audio & Atmosphere
- `MusicPlayerSystem.gd` autoload keeps a persistent `AudioStreamPlayer`, steps through state machines (`intro`, `home`, `work`, `factory`, `boss`, `victory`, `defeat`).
- Future work: Ambient SFX layers, dynamic reverb per location, event-driven stingers.

### 5.6 UI / UX
- Current HUD limited (kill counter scaffold in factory).
- Planned features: stamina meter, buff icons, dialogue overlays, day counter, procedural street map.

---

## 6. Content Plan

| Area    | Current Content                                       | Next Steps                                                      |
|---------|--------------------------------------------------------|-----------------------------------------------------------------|
| Home    | Static apartment TileMap, exit trigger, music change   | Interactive props, buff systems, narrative beats, visual decay  |
| Outside | Procedural chunks, placeholder enemy, level trigger    | Enable enemy waves, add lamppost sockets, inject surreal events |
| Factory | Arena TileMap, spawner scaffold, loop trigger          | Implement labour tasks, boss behaviour, win/fail conditions     |

---

## 7. Technical Snapshot

- **Main scene** (`res://resources/main/Main.tscn`): root `Node2D` with `LevelContainer`. Handles cleanup and instantiation.
- **Resource registry** (`scripts/utils/ResourceRegistry.gd`): UID dictionaries for levels, environment prefabs, and enemies.
- **Outside generator**: Drawer systems operate on the shared `layer_data` array before committing to TileMaps or nodes, allowing debug inspection and custom edits.
- **Shared overlap assets**: Contain physics primitives, sprite holders, VFX, and reusable hit/hurt boxes to prevent duplication.
- **Logging**: `Custom_Logger` enforces rate limiting, duplicate suppression, and leveled output.
- **Audio autoload**: `MUSIC_PLAYER` configured in `project.godot` for global playback.
- **Physics layers/groups**: Defined in `project.godot` (`Player`, `Enemies`, `Items`, `Projectiles`, `Triggers`, `Environment`, `Floor Lines`) to keep collisions deterministic.

---

## 8. Roadmap

1. **Combat Prototype Completion**
   - Restore enemy spawning with basic AI and telegraphed attacks.
   - Improve hit feedback (particles, camera shake, audio cues).
   - Finalise non-gamepad aiming defaults.

2. **Loop Cohesion**
   - Implement home buffs, alcohol systems, and narrative state tracking.
   - Develop factory encounter structure with labour tasks + boss.
   - Persist loop variables (fatigue, morale, world corruption).

3. **Content Expansion**
   - Grow chunk library (parks, kiosks, industrial stretches).
   - Script authored surreal events and NPC encounters.
   - Introduce lamppost crafting/placement with gameplay payoff.

4. **UX & Polish**
   - HUD/menu implementation, pause flow, settings.
   - Audio mix pass, bespoke SFX, dialogue system.
   - Optimisation and tooling (debug overlays, profiler hooks).

5. **Release Prep**
   - QA, balancing, playtest iteration.
   - Platform builds and distribution planning (itch.io, Steam).

---

## 9. Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Narrative scope creep | Timeline blow-up | Maintain milestone feature lock; treat optional beats as stretch goals |
| Procedural monotony | Player fatigue | Increase chunk variety, weave authored events into generator |
| Combat lacks punch | Low retention | Iterate on throw physics, telegraphs, hitstop, and enemy behaviours |
| Audio repetition | Mood collapse | Expand music library, add ambient layers, mix based on location |

---

## 10. Open Questions

1. How should alcohol buffs/debuffs influence combat and narrative states?
2. What does lamppost placement unlock (checkpoints, buffs, alternate routes)?
3. How is progress tracked between loops — by days survived, tasks completed, or narrative breakthroughs?
4. Which procedural events recur, and which remain one-offs to preserve surprise?
5. How does productivity in the factory influence endings or world corruption?
6. What accessibility options (controls, colour modes) are required for broader reach?

---

## 11. Closing Note

Solidmaid aims to make the mundane oppressive and the absurd familiar. Every system — from chunk generators to throwables — should reinforce the emotional loop of exhaustion, fleeting agency, and inevitable return to routine. Keep satire empathetic, keep mechanics grounded, and let each iteration of the day feel a little stranger than the last.
