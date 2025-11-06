# Game Design Document: Solidmaid — Alkoldun Vasiliusavich (Version 2)

---

## 0. Intent (V2 Shift)

- Focus the project into a compact, replayable vertical slice that can be built solo in small, verifiable increments.
- Make throwing + dodging feel excellent; everything else supports this feel.
- Keep the Home → Street → Factory loop, but scope each stop to one clear purpose and one shippable objective.

Non-goals for V2: no meta-progression trees, no large questlines, no complex inventory, no multi-boss roster. These can be stretch goals after the slice ships.

---

## 1. Overview

### Title
Solidmaid: Alkoldun Vasiliusavich

### Genre Snapshot
Top-down brawler with procedural street traversal and satirical folk-horror tone.

### Engine & Platform
- Engine: Godot 4.5 (GDScript, optional C++ GDExtension for hotspots).
- Platforms: PC (Windows / Linux); macOS possible later.

### Visual & Audio Direction
- 16px pixel-art with industrial palette and subtle folklore accents.
- Ambient-industrial music with simple state transitions via the in-game music player.

### Elevator Pitch
Relive a worker’s loop in an alternate 1990s. Wake in a cramped apartment, cross the uncanny street, survive a factory “shift”, and return home — each day a little stranger. Core verbs are movement, throwing, and survival under pressure.

---

## 2. Pillars

1. Routine as narrative: repetition with small, meaningful mutations.
2. Tactile throws: readable arcs, weight, and hit feedback.
3. Small world, big mood: minimal content, strong tone and pacing.
4. Procedural familiarity: a few chunks, recombined for flow and surprise.

---

## 3. Audience & Constraints

- Solo-dev friendly: short tasks, one screen at a time, few dependencies.
- Session length: 5–10 minutes per loop; restartable anytime.
- Hardware: runs smoothly on integrated GPUs (use `gl_compatibility`).

---

## 4. Experience Goals (V2)

- Player immediately understands: move, aim/throw, dodge, survive wave/task.
- Throws feel satisfying: arc preview, impact SFX, micro hitstop.
- Street traversal is legible: limited chunk set, zero confusion about exits.
- Factory encounter is fair: teaches pattern, then escalates once.

---

## 5. Core Loop (Slice)

1) Home (30–60s): optional micro-interaction; exit when ready.  
2) Street (2–4m): traverse 4–6 chunks; fight 2 enemy archetypes; reach factory gate.  
3) Factory (2–4m): survive one escalating wave while assembling a single lamppost.  
4) Return: day summary + one mutation visible at Home; loop resets.

Completion condition: survive factory wave and return home once. Failure: KO anywhere → restart day.

---

## 6. MVP Definition & Acceptance Criteria

- Home: one room, 1 interactable (radio/TV) that flips a simple global flag (mood) and changes music.
- Street: generator stitches 4–6 authored chunks; spawns enemies at intervals; clear arrow/marker to factory.
- Combat: brick throwable with cooldown; roll/dodge with brief i-frames; two enemy archetypes with clear telegraphs.
- Factory: one arena, one wave that mixes both enemy archetypes plus lamppost assembly objective (3 parts).
- Audio: at least 3 states (home/street/factory); impact SFX; volume slider stub.
- UI: minimal HUD for HP and brick cooldown; prompt for exit/use.

Acceptance tests (manual):
- New player completes a full loop within 10 minutes without reading code.
- Throws hit reliably; enemies telegraph at least 0.25–0.4s before damage.
- 60 FPS on mid-tier laptop iGPU; no stutters when spawning enemies or loading chunks.

---

## 7. Systems (Target State for V2)

### 7.1 Player & Combat
- Movement via `CharacterBox`; invincibility windows after roll and on damage.
- Brick throwable using `Throwable` base; add arc preview and impact feedback (hitstop + shake).
- Controls: WASD + mouse; add default keyboard aim fallback (arrows) to avoid Input Map step.

### 7.2 Enemies (2 archetypes)
- Bruiser (melee chaser with windup and short lunge).
- Disruptor (cloud-like area attack with telegraph radius).
- Spawning: re-enable `EnemySpawnerSystem` with capped concurrency and spacing.

### 7.3 Street Generation
- Minimal chunk set (background/decoration/environment) with clear nav lanes.
- Spawn rules tied to chunk indices (e.g., enemies on 2 and 4, gate on last).

### 7.4 Factory Encounter
- Arena scene; lamppost assembly as a 3-step interact chain under pressure.
- Single “wave escalate once” pattern; end condition spawns return trigger.

### 7.5 Home & Mutation
- One interactable toggles mood; tiny visual changes per loop (prop on/off, tint, poster swap).

### 7.6 Audio & Presentation
- State swap via `MusicPlayerSystem` for home/street/factory.
- Impact SFX; subtle camera shake and short hitstop on hits.

### 7.7 Tech Notes
- Keep logic in GDScript; consider GDExtension only for future hotspots (e.g., batched collision or arc math).
- Maintain `Resource_Registry.gd` UID lookups; avoid path hardcoding.

---

## 8. Milestones

- M1 — Combat Core (week 1–2): roll/i-frames, brick polish, default aim bindings, basic hit feedback.
- M2 — Street Slice (week 2–3): 4–6 chunks, simple spawns, exit marker, gate.
- M3 — Factory Slice (week 3–4): arena, lamppost assembly, wave escalate, return trigger.
- M4 — Cohesion & Polish (week 5): HUD, audio states, micro-mutations at Home, performance pass.

---

## 9. Backlog — Atomic Tasks (by area)

Combat & Player
- [ ] [S] Add roll/dodge with 8–12 frames i-frames and 0.6s cooldown.
- [ ] [S] Brick: add brief hitstop (0.06–0.1s) on enemy hit.
- [ ] [S] Brick: add subtle camera shake on hit (amplitude 2–4px, 0.1s).
- [ ] [S] Add keyboard arrow bindings for `look_*` actions by default.
- [ ] [M] Arc preview: draw simple dotted trajectory before throw (toggle off while moving).

Enemies & Spawning
- [ ] [S] Re-enable spawn call in `resources/systems/enemies/EnemySpawnerSystem.gd`.
- [ ] [S] Bruiser: implement windup animation and 0.3s telegraph before lunge.
- [ ] [S] Disruptor: use existing `CloudAttack` with pre-warm telegraph ring.
- [ ] [S] Cap active enemies to N=5; add 1.5s grace after spawn near player.
- [ ] [M] Simple drop table: 10% brick pickup on enemy death (optional).

Street Generation
- [ ] [S] Author 4–6 outside chunks with clean nav lanes.
- [ ] [S] Add exit/gate marker on final chunk.
- [ ] [S] Tie spawn schedule to chunk indices {2,4}.
- [ ] [M] Add basic occluders/perf settings for outside layers.

Factory Encounter
- [ ] [S] Build factory arena scene with spawn points and lamppost socket.
- [ ] [S] Implement lamppost assembly: 3 interactions with short progress bars.
- [ ] [S] Wave escalate once at 50% progress; spawn mix of 2 archetypes.
- [ ] [S] On completion: stop spawner, spawn return trigger to Home.

Home & Mutation
- [ ] [S] Add single interactable (radio/TV) toggling music/mood flag.
- [ ] [S] On loop complete: flip one prop or tint to indicate mutation.

HUD & UX
- [ ] [S] Minimal HUD: HP hearts/bars + brick cooldown.
- [ ] [S] On-screen prompt for Use/Exit when in trigger.
- [ ] [S] Settings stub: volume slider affecting `MusicPlayerSystem` bus.

Audio & VFX
- [ ] [S] Wire 3 music states: home/street/factory.
- [ ] [S] Add impact SFX for brick hits.
- [ ] [S] Camera shake utility + hitstop helper.

Tooling & Perf
- [ ] [S] Logger tag for spawner events to tune rates.
- [ ] [S] Debug overlay: active enemies, chunk index, FPS.
- [ ] [M] Simple object pooling for bricks to avoid GC spikes.

Tech (Optional)
- [ ] [M] GDExtension hello-world node compiled and visible in editor.
- [ ] [M] Move arc math into C++ as a micro-benchmark (only if needed).

---

## 10. Risks & Mitigation

- Scope creep → lock features to M1–M4; any new idea enters backlog as stretch.
- Procedural monotony → keep chunk count small but distinct; add one authored event.
- Combat feel → iterate early on throw weight, telegraphs, and feedback before content.
- Performance dips → cap enemies; pool bricks; keep layers light in outside.

---

## 11. Metrics & Validation

- Time-to-complete loop < 10 minutes for a first-time player.
- Median FPS ≥ 60 during spawns and factory wave on iGPU.
- At least 2 successful loops out of 3 attempts in internal playtests.

---

## 12. Open Questions (V2)

1) Does lamppost assembly need micro-fail states or is “hold to assemble” enough?  
2) Is a second throwable (bottle) necessary for variety, or better to polish brick?  
3) What single mutation at Home best signals progress (poster, light, clutter)?  
4) Keyboard + mouse aim defaults — add arrow keys or mouse-only aim with right-stick emulation?

---

## 13. Solo Dev Strategy (Notes)

- Build in verticals: finish one small player–enemy–street slice end-to-end, then expand.
- Timebox additions to 1–2 sessions; if it doesn’t fit, cut or split.
- Keep debug tools visible (FPS, enemies, chunk index) to speed iteration.
- Write short devlog entries tied to milestones (see DEVLOG template in repo).

---

## 14. Closing Note

Small, finished, and replayable beats sprawling and unfinished. Ship the slice; expand only after the loop feels good.

