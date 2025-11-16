# Game Design Document: Solidmaid — Alkoldun Vasiliusavich (Version 2, FPS Reboot)

---

## 0. Intent (Full Reboot → FPS)

- Reboot the project as a first-person folk‑horror shooter (FPS) while preserving the Alkoldun tone, lore, and ideology.
- Ship a compact, replayable vertical slice that a solo dev can finish.
- Keep the Home → Street → Factory day loop but render it in first person.

Non-goals for this slice: progression trees, large inventories, open worlds, multiple bosses. These are stretch after the slice ships.

---

## 1. Overview

### Title
Solidmaid: Alkoldun Vasiliusavich

### Genre Snapshot
First-person folk‑horror shooter with improvised weapons and ritual twists.

### Engine & Platform
- Engine: Godot 4.5 (GDScript for gameplay; optional C++ GDExtension for hotspots).
- Platforms: PC (Windows / Linux); macOS later if needed.

### Visual & Audio Direction
- Low-fi, low-poly industrial 3D, readable forms and limited palette; folklore accents (icons, ornaments, masks).
- Ambient‑industrial music with state transitions (home/street/factory) and sparse diegetic sounds.

### Elevator Pitch
Wake up, step into the corridor, walk the uncanny street, endure the factory. Alkoldun rituals seep into the mundane. Improvise with bricks and pipes; perform a short rite under pressure; get home before it gets worse.

---

## 2. Pillars

1. Routine as narrative: repetition with small, meaningful mutations each loop.
2. Tactile improvised combat: bricks, pipes, short‑range tools over gun fetish.
3. Readable first‑person play: strong telegraphs, low clutter, stable framerate.
4. Small world, big mood: minimal content, focused on tone and pacing.

---

## 3. Audience & Constraints

- Solo‑dev friendly: short tasks with clear acceptance, minimal dependencies.
- Session length: 7–12 minutes per loop; restartable anytime.
- Performance target: 60 FPS on iGPU using forward+ or compatibility.

---

## 4. Experience Goals (FPS Slice)

- Movement, look, throw/melee, and a single under‑pressure interaction are immediately clear.
- Brick throw feels weighty (arc, impact, camera micro‑shake, hitstop).
- Street is legible to navigate; exits and gates are unmistakable.
- Factory encounter escalates once; failure is readable and fair.

---

## 5. Core Loop (Slice)

1) Home (30–60s): optional micro‑interaction; pick up brick/pipe; exit to stairwell.  
2) Street (3–5m): traverse 3–5 blockouts; fight 2 enemy archetypes; reach factory gate.  
3) Factory (2–4m): survive one escalating factory boss while assembling a lamppost via a brief ritual/interaction.  
4) Return: day summary + one new pillar created on factory; loop resets.

Win: complete factory ritual and return home once. Lose: KO anywhere → restart day.

---

## 6. MVP Definition & Acceptance Criteria

- Player: first‑person controller with walk, sprint (optional), crouch (optional), and interaction.
- Combat: brick throwable (primary) + pipe melee (backup); two enemy archetypes with clear telegraphs.
- Levels: one Home room, a short Street path (3–5 chunks), one Factory arena with a single 3‑step assembly/ritual.
- Audio/UI: 3 music states (home/street/factory), crosshair, HP/stamina, minimal prompts.

Acceptance (manual):
- New player completes a loop in ≤ 12 minutes without reading code.
- Enemy damage telegraphs ≥ 300 ms; hits feel punchy (SFX + micro‑hitstop + shake).
- Stable ≥ 60 FPS on an iGPU; no hitches during spawns/loads.

---

## 7. Systems (Target State for FPS V2)

### 7.1 Player & Camera
- Protagonist: Alkoldun Vasiliusavich — a factory worker in a leather coat and a matching wizard hat over work overalls.
- `PlayerFPS.tscn`: `CharacterBody3D` controller, `Camera3D`, light head bob, footstep SFX hooks.
- Interaction raycast (2–3m), prompt widget, optional stamina with quick recovery.

### 7.2 Weapons
- Brick (Throwable): starting ranged tool. Throw on an arc; optionally recall to hand after impact on a short cooldown. World scatters spare bricks so the player isn’t hard‑gated by recall. Future: brick variants or other thrown junk.
- Pipe (Melee): short, fast swing to create space and finish enemies; primarily a gap‑maker for safer throws.
- Pillars (Range, unlock): once the first lamppost is assembled, unlock a ranged option. Two candidate designs — pick during M3/M4:
  - Option A (Emitter): assembled lampposts emit a periodic ranged blast the player can trigger while nearby.
  - Option B (Piece‑weapon): a lamppost component becomes a limited‑ammo ranged tool after first assembly.
  Keep this out of MVP until one prototype proves fun and cheap.

### 7.3 Enemies
- Kipuchka (pickpocket/kikimora): small, fast melee pest with jittery movement. On repeated hits can briefly stun and steal the pillar component, fleeing into an alley; recover by chasing it down. Included in slice.
- Midnight Smokers: gopnik‑like courtyard phantoms made of cigarette smoke; grey tracksuits, dim window‑yellow eyes, whispery “hey, bro…”. Exhales a smoke cloud that reduces visibility and deals chip damage. Included in slice.
- Leshaki (low forest spirits): thick‑necked bruisers in crimson jackets with gold chains; high HP, heavy knockback on hit, disorienting. Future (post‑slice) escalation enemy.

### 7.4 Bosses (Factory)
- Warehouse Manager + Zmey Gorynych: a composite boss with corrugated‑pipe body and three heads — Stock, Accounting, Write‑off. Arena clutter spawns, audit debuffs, and item burns map to the heads. Defeat by baiting heads into harming each other. Slice boss candidate.
- Accountant — Baba Yaga: in a spinning office chair, curses via documents (order/act/certificate) that apply debuffs; can “freeze” the screen in tables until a wrong number is found; vulnerable around chair wheels. Future boss.
- Oligarch — Koschei the Deathless: corpulent suit, golden‑coin eyes; weak point is the eyes, heavy ground slams, grab/split move. Future boss.

### 7.5 World & Levels
- Home: one Khrushchyovka‑style apartment room with an interactable radio/TV that flips a mood flag; can look out at bleak courtyard views.
- Street: straight modular street with a few alleys where Kipuchkas can stash stolen pillar parts; no cars in the slice; ends at a checkpoint gate to the factory.
- Factory: a hangar‑like hall with lamp assembly tables, a welding station, and a finishing conveyor; central open arena space reserved for the boss.

### 7.6 Audio & Presentation
- Music states: home/street/factory; minimal SFX (steps, throw, impact, grunt).
- Camera micro‑shake on hits; subtle vignette under low HP.

### 7.7 Tech Notes
- Prefer GDScript for iteration; only consider GDExtension for performance hotspots.
- Foldering suggestion: `resources/fps/` for new scenes/scripts; keep legacy 2D intact.

---

## 8. Milestones

- M1 — FPS Controller & Feel (week 1): look/move, interact ray, crosshair, brick throw placeholder, camera shake.
- M2 — Visual Combat Pack (weeks 2–3): learn low‑poly workflow, block out pipe/enemy kits, integrate melee/telegraph/hitstop into the playable FPS slice.
- M3 — Street Blockout & Dressing (weeks 4–5): greybox → prop pass for 3–5 chunks, gating, basic lighting, perf pass.
- M4 — Factory Slice (weeks 6–7): arena, lamppost assembly (3 steps), single escalate, return trigger, cinematic touches.
- M5 — Cohesion & Polish (week 8+): HUD finish, audio states, home mutation, QA, export builds.
- M6 — High-Fidelity Modeling (optional stretch): upgrade placeholder meshes (hands, weapons, enemies, props) to final art-ready assets.
- M7 — Animation Polish (optional stretch): finalise first-person hands, enemy telegraphs, ritual animation sets.
- M8 — Systems Polish & QoL (optional stretch): HUD stretch goals, ability configs, AI tools.

---

### 8.1 Micro‑milestones (2h sessions estimates)

> Tasks marked with **(Art)** highlight missing models/animations; there are currently no bespoke meshes in the project, so these will be picked up during future art passes.

- M1 — FPS Controller & Feel (~6 sessions)
  - [x] Create `PlayerFPS.tscn` (CharacterBody3D, Camera3D) + look/move basics.
  - [x] Mouse sensitivity + pitch clamp + pause cursor lock.
  - [x] Interact raycast (2–3m) + prompt UI.
  - [x] Crosshair + interact tint; simple head bob (optional).
  - [x] Brick placeholder: hold/throw, cooldown, basic arc.
  - [x] Camera micro‑shake + simple hitstop helper.

- M2 — Visual Combat Pack (~9 sessions)
  - [ ] Pipe melee swing (cone hitbox, cooldown, telegraph) + placeholder pipe mesh for in-editor testing.
  - [ ] Enemy: Kipuchka (stun/steal behavior stub without steal first; add steal later) + greybox mesh/telegraph indicator.
  - [ ] Enemy: Midnight Smoker (AoE cloud with pre‑warm ring) + greybox mesh/telegraph indicator.
  - [ ] Spawner: cap N=5; min distance; 1.5s spawn grace.
  - [ ] Damage/HP/death and optional 10% brick drop.
  - [ ] Telegraph tuning, hitstop, SFX; quick playtest.
  - [ ] Perf sanity: 5 active enemies.

- M3 — Street Blockout & Dressing (~6 sessions)
  - [ ] Greybox 3 street chunks with clear lanes and collisions + placeholder prop placements.
  - [ ] Add gate/end marker + signage/lighting cues.
  - [ ] Hook spawns by chunk index.
  - [ ] Basic lighting pass (baked/cheap GI); sky/fog.
  - [ ] Perf pass (occlusion/cull where useful).

- M4 — Factory Slice (~7 sessions)
  - [ ] Arena blockout, spawn points, lamppost socket (with placeholder machinery/props).
  - [ ] Ritual: 3 hold‑interactions with progress bar; interrupt on hit.
  - [ ] Boss slice: Warehouse Manager + Zmey head gimmick (one cycle) or minimal wave escalate.
  - [ ] Return trigger to Home; state handoff.
  - [ ] Perf/readability polish.

- M5 — Cohesion & Polish (~6 sessions)
  - [ ] HUD: HP bar; stamina/cooldown; prompts.
  - [ ] Music states wiring and mixer levels.
  - [ ] Home mutation (prop/light/picture) after successful loop.
  - [ ] QA checklist run; bug fixes.
  - [ ] Package an internal playtest build.

- M6 — High-Fidelity Modeling (~6 sessions, optional stretch)
  - [ ] FPS hands + weapons: sculpt, unwrap, texture, set up materials for first-person view.
  - [ ] Enemy batch (Kipuchka + Midnight Smoker) final meshes + LOD/collision.
  - [ ] Prop passes for Street/Factory (lamps, lamppost sockets, ritual props).
  - [ ] Boss/Factory centerpiece meshes + lamppost parts.
  - [ ] Import pipeline checklist (naming, scale, collision) for final assets.

- M7 — Animation Polish (~5 sessions, optional stretch)
  - [ ] First-person hand animation set (idle, walk, hold, throw, melee).
  - [ ] Enemy telegraph + attack animations tied to combat timings.
  - [ ] Boss/ritual animation beats + VFX triggers.
  - [ ] Hook final animations to hitstop/shake events.

- M8 — Systems Polish & QoL (optional stretch)
  - [ ] HUD stretch goals: cooldown indicators, ritual/stamina progress, HP bar styling, debug visibility toggle.
  - [ ] Localise interact prompts or drive them from Scriptable data.
  - [ ] Ability dependency config `.tres` (no hard-coded lists inside scenes).
  - [ ] CharacterConfig resource describing default attachments/look pivots.
  - [ ] Expand AI controller to use the new hand API and target locomotion.
  - [ ] Shared service locator/autoload for reusable systems (input routing, target selection, etc.).
  - [ ] Hook hitstop triggers to actual damage/hit events (instead of button presses).
  - [ ] Sandbox interactable library for rapid testing (beyond bricks).

Total core sessions: ~34 (≈ 6–7 weeks at 2h/day, 5 days/week) — extended to account for learning the low‑poly modeling/animation pipeline. Optional stretches (M6–M8) add 15–17 sessions if pursued.

---

## 9. Backlog — Atomic Tasks (by area)

Legend:
- `[S]` = Small (≤1 session / ~2h).
- `[M]` = Medium (≤2 sessions / ~4h). Split further if scope creeps beyond that.

Player & Camera
- [x] [S] Create `resources/fps/player/PlayerFPS.tscn` with `CharacterBody3D` + `Camera3D`.
- [x] [S] Mouse look with clamped pitch; configurable sensitivity.
- [x] [S] Raycast interact (2–3m) + on-screen prompt.
- [x] [S] Basic head bob for FPS camera.
- [ ] [S] Footstep SFX hook + audio variation pass.
- [ ] [M] Placeholder FPS hand mesh + first-person animation set.

Weapons
- [x] [S] Brick: hold/throw states; physics arc; cooldown; impact SFX.
- [x] [S] Hitstop helper (0.06–0.1s) + camera micro-shake (2–4px feel in 3D).
- [ ] [S] Pipe: short swing with clear telegraph; cooldown.
- [ ] [M] Model/texture the pipe + brick variants; animate swings/impacts (see M6).

Enemies & Spawning
- [ ] [S] Bruiser: chase, 0.4s windup, lunge, recover.
- [ ] [S] Smog/Spirit: expanding AoE with pre-warm ring.
- [ ] [S] Spawner: cap N=5 active; min distance from player; 1.5s grace.
- [ ] [M] Low-poly enemy meshes + telegraph animation set (see M6).

World
- [ ] [S] Home room blockout; interactable radio toggling mood/music.
- [ ] [S] Street chunks (3–5) with clear lanes and one gate.
- [ ] [S] Factory arena with lamppost socket and spawn points.
- [ ] [M] Prop/model batches for Home → Street → Factory (lamps, machines, signage) — coordinate with M6 outputs.

Ritual/Assembly
- [ ] [S] 3-step hold-to-assemble with progress bar and interrupt on damage.
- [ ] [S] Escalate wave once at step 2; on complete spawn return trigger.

UI/Audio
- [x] [S] Crosshair + interact tint overlay.
- [ ] [S] HP bar; stamina/cooldown indicators + HUD toggle.
- [ ] [S] Music states: home/street/factory.

Tooling & Perf
- [ ] [S] Debug overlay (FPS, active enemies, player HP).
- [ ] [M] Light baking or cheap GI/ambient probe setup for readability.

Tech (Optional)
- [ ] [M] GDExtension hello‑world node; benchmark any hotspots before porting.

---

## 10. Risks & Mitigation

- 3D scope creep → lock to one loop, two enemies, two weapons; defer guns.
- Performance dips → simple materials, baked/cheap lighting, capped spawns.
- First‑person readability → strong telegraphs, low visual noise, loud SFX.
- Content drain → reuse modules across street/factory; keep props minimal.

---

## 11. Metrics & Validation

- Loop time ≤ 12 minutes for first‑time player.
- ≥ 60 FPS on iGPU during spawns and assembly.
- 2 successful loops out of 3 internal attempts.

---

## 12. Open Questions (FPS)

1) Pure improvised tools (brick/pipe) or include one simple firearm later?  
2) What’s the minimal ritual VFX to feel “occult” without art burden?  
3) Which single Home mutation reads best (poster, light flicker, clutter)?  
4) Head bob and FOV: minimal by default or stylised?

---

## 13. Solo Dev Strategy

- Build verticals: finish M1 end‑to‑end (controller → throw → hit feedback) before enemies.
- Timebox every task to 1–2 sessions; split if it doesn’t fit.
- Keep debug overlay visible; profile early in street and factory scenes.

---

## 14. Closing Note

Small, finished, and replayable beats sprawling and unfinished. Ship the FPS slice first; expand only after the loop feels good.

---

## 15. Time Budget & Cadence

- Daily limit: 2 hours (one focused session); weekends optional.
- Weekly capacity: ~10 hours (5 weekdays) with a 20% buffer for overruns.
- Sizing rule: each task must fit in 1 session or be split; anything larger becomes a micro‑milestone item.
- Tracking: end each session by noting duration, blockers, and next “first click”. Use `docs/templates/SESSION_TODO.md`.

---

## 16. Immediate Work Plan (next 10 sessions)

1) PlayerFPS scene + look/move basics (M1).
2) Sensitivity + pitch clamp + pause cursor lock (M1).
3) Interact ray + prompt UI (M1).
4) Crosshair + interact tint; light head bob (M1).
5) Brick placeholder throw + cooldown + basic arc (M1).
6) Camera micro‑shake + hitstop helper (M1).
7) Pipe melee basic swing + cooldown (M2).
8) Enemy Kipuchka basic melee (no steal yet) (M2).
9) Enemy Midnight Smoker AoE + telegraph (M2).
10) Spawner cap N=5 + min distance + grace (M2).

After‑work starter checklist (daily): see `docs/guides/AFTER_WORK_CHECKLIST.md`.

---

## 17. Asset Creation Plan (AI Low‑Poly)

- Visual style: low‑poly, flat materials, limited palette; readability over detail.
- Pipeline (per asset):
  - Prompt/generate base mesh with low‑poly constraints (or blockout manually).
  - Cleanup in Blender: decimate if needed, fix normals, simple UV unwrap.
  - One material atlas; minimal textures (albedo only where possible).
  - Collision shapes + simple LODs for enemies/props.
  - Import to Godot; StandardMaterial3D; test lighting and scale.
- Time budgets:
  - Prop batch (3–4 items): 1 session per batch.
  - Enemy base mesh + UV + light rig: 1–2 sessions per enemy.
  - Environment chunk dressing: 1 session per chunk (post‑blockout).
- Licensing: keep `docs/SOURCES.md` updated with terms/links.

---

## 18. Music Production Plan

- Tracks: post‑punk (Home), breakcore (Street), boss/Factory theme.
- Deliverables per track: 60–120s loopable stem + 3–5s intro/outro stingers.
- Time budgets:
  - Compose/record: 1–2 sessions per track.
  - Mix/master + loop polish: 1 session per track.
  - Integration + state swap tuning: 1 shared session across tracks.
- Technical: consistent LUFS target; mixer buses; 300–600ms fades for state swaps.

---

## 19. SFX Sourcing Plan

- Sources: record foley, synthesize, or use CC0/royalty‑free libraries.
- Strategy: list gameplay events → map 1–2 candidates each → shortlist → test in‑game.
- Core set: footsteps (2–3), brick throw/impact (2), melee swing/impact (2), enemy grunt/hurt (2), AoE telegraph (1), UI click (1).
- Time budgets:
  - Collection + shortlist: 1 session.
  - Editing/normalising: 1 session.
  - Integration + mixer tuning: 1 session.
- Documentation: update `docs/SOURCES.md`; store raw vs edited.

---

## 20. Shader & Animation Plan

- Shaders: avoid custom; prefer StandardMaterial3D + baked/cheap GI; optional rim/emission via textures.
- VFX: mesh/plane flipbooks and unlit materials over complex particle shaders.
- Animation: minimal keyframes for weapons; enemy telegraphs via scale/tint/pose.
- Time budgets:
  - Shader/material setup per asset batch: 0.5 session.
  - Enemy telegraph animations (2 archetypes): 1 session total.
  - Weapon swing timing polish: 0.5 session.

---

## 21. Additional Risks & Pitfalls

- Motion sickness from head bob/FOV → keep subtle; add slider.
- AI‑generated messy topology → plan cleanup; keep collisions simple.
- Audio loudness variance → set reference LUFS; verify in‑game.
- Lighting/perf variance across GPUs → test forward+ vs compatibility.
- Import/tooling drag → template scenes/materials; batch imports.
- Scope creep → new ideas to backlog; swap only during weekly review.

---

## 22. Completeness Check

- Slice includes purpose, pillars, MVP, systems, milestones, micro‑tasks, time budget, and production plans.
- Out of scope: distribution/marketing, analytics, localisation, monetisation, full narrative arc.
- Potential additions later: accessibility options list, controller support, save/load beyond loop flags.

---

## 23. Budget Rollup (Sessions)

- Core gameplay/dev (M1–M5 micro‑milestones): ~27–28 sessions.
- Art — props (3–4 items/batch): ~3 sessions total for slice dressing.
- Art — enemy meshes (2 archetypes): ~2–4 sessions.
- Environment chunk dressing (post‑blockout): ~3–5 sessions.
- Music — 3 tracks (compose/record 1–2 + mix 1 each + integrate 1 shared): ~6–8 sessions.
- SFX — collect, edit, integrate: ~3 sessions.
- Shaders/animation polish: ~2 sessions.

Estimated total: ~46–52 sessions. At 2h/day (≈5 sessions/week), that’s ~9–10.5 weeks for a solid slice with audio and low‑poly assets. Compress by deferring enemy rigs, reducing props, or composing shorter loops.
