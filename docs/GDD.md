# Game Design Document: Solidmaid — Alkoldun Vasiliusavich

## 1. Overview
### Title
Solidmaid: Alkoldun Vasiliusavich

### Genre
Experimental Pixel-Art FPS / Immersive Sim with Roguelite and Surreal Narrative Elements.

### Platform
PC (Windows/Linux), future export potential to other platforms via Godot 4.x.

### Target Audience
Adults 18+, primarily players interested in narrative-driven indie experiences with philosophical, surreal, and cultural undertones.  
Comparable references: **Cruelty Squad**, **Hypnagogia**, **Signalis**, **HROT**, **Ultrakill** (stylistically distant, spiritually relevant).

### Core Vision
A deeply atmospheric, surreal journey through the decaying psyche of Alkoldun Vasiliusavich — a mystical worker at a lamppost factory.  
Gameplay and narrative explore themes of **alienation, cyclical meaninglessness, and self-deception through productivity**.

The game’s structure is built around **routine loops** that mirror real-life existential fatigue.

### Core Loop
1. **Home (Preparation)** — the illusion of rest. Player interacts with the environment to prepare (drinks, snacks, self-dialogue).
2. **Street (Commute)** — traversal through surreal procedural landscapes, interacting with distorted NPCs or enemies.
3. **Factory (Work)** — task-based boss encounters combining labor, combat, and absurd dialogue.
4. **Return (Reflection)** — cycle repeats with slight world shifts and growing surrealism.

Each loop subtly alters visuals, tone, and dialogue — reinforcing the protagonist’s mental disintegration.

### Unique Selling Points
- **Satirical Existential Narrative**: Post-Soviet life as dark folklore.
- **Pixel-Art 3D Visuals**: A distinct low-res FPS aesthetic (retro shading, pixel dithering, stylized lighting).
- **Psychological Mechanics**: Alcohol and fatigue alter perception, control, and world geometry.
- **Procedural Routine Generation**: Repetition with variance — the illusion of progress.
- **Meta-Philosophical Twist**: The player’s persistence mirrors the worker’s delusion of purpose.

---

## 2. Story and Setting
### Premise
In an alternate 1990s Russia, folklore collides with industrial decay.  
Alkoldun Vasiliusavich, a mystical yet broken lamppost factory worker, drifts between work, home, and the streets.  
Reality fragments — lampposts glow with occult energy, bosses morph into mythical creatures, and time loops endlessly.

### Narrative Approach
- Minimal exposition.
- Environmental storytelling, cryptic monologues, fragmented dreams.
- Dialogues written in absurdist or bureaucratic tone.

### Ending
The loop collapses as Vasiliusavich realizes his “factory” exists only within his decaying mind.  
Players can “choose” to return to work — or to stop.

---

## 3. Gameplay Mechanics

### Core Controls (FPS-oriented)
- **Movement**: Standard WASD + jump/crouch.
- **Combat**: Throw bricks, bottles, or debris (physics-based).
- **Interact**: Drink, eat, or manipulate lampposts (power conduits).
- **Perception Shift**: Alcohol alters FOV, lighting, and sound.

### Primary Systems

#### 3.1 Alcohol Mechanics (Psychophysical System)
- **Alcohol = Buff/Debuff Blend**: Grants power (strength, speed, visual insight) but destabilizes aim and reality.
- **Overconsumption**: Screen distortions, hallucinations, time loops.
- **Sobriety Mode**: Clarity but existential despair (color desaturation, reduced stamina).

#### 3.2 Lamppost System
- Lampposts act as **anchors** or **checkpoints** in the surreal cityscape.
- Collect, repair, and install them using resources from the factory.
- Lampposts influence the environment: some repel enemies, others distort space or grant temporary buffs.

#### 3.3 Factory Work (Combat Arena / Puzzle Hybrid)
- Boss encounters integrated with “production tasks.”
- Tasks simulate meaningless labor (e.g., assembling glowing lampposts under time pressure).
- Player must multitask between **combat and repetitive mechanical actions**.
- Alcohol rhythm affects timing and perception of these tasks.

#### 3.4 Procedural Routine
- Each loop procedurally regenerates the streets and tasks with minor alterations.
- The illusion of change conceals narrative stagnation — a metaphor for Vasiliusavich’s condition.

---

## 4. Visual and Audio Design
### Visual Style
- **3D Pixel Aesthetic**: Retro PS1-era rendering (Godot 4 shader-based pixelation).
- **Colors**: Muted industrial palette with bursts of magical neon.
- **Design Inspiration**: Eastern European brutalism meets absurdist folklore.
- **Animation**: Skeletal animation for character rigs (Godot AnimationTree + pixel-art shading).

### Audio
- **Music**: Lo-fi industrial ambient with occasional chiptune motifs.
- **Sound Design**: Emphasize monotony (machines, breathing, flickering lamps).
- **Dialogue**: Distorted Russian/English hybrid, deliberately hard to parse.

---

## 5. Progression and Replayability
- **Core Progression**: Unlock lamppost upgrades, alcohol recipes, and internal “memories.”
- **Replay Motivation**: New world variations, surreal dialogue branches, visual hallucinations.
- **Final Goal**: Reach realization (“Break the Loop” ending).

---

## 6. Technical Specifications
- **Engine**: Godot 4.x (GDScript + optional C# modules).
- **Rendering**: 3D Pixel Shader pipeline (custom post-process).
- **Resolution**: 320x240 scaled (integer upscale to HD).
- **Input**: Keyboard + Mouse (controller support later).

---

## 7. Production Roadmap
| Phase | Duration | Goals |
|--------|-----------|--------|
| **Prototype (Month 1–2)** | Build FPS base, alcohol physics, lamppost interaction |
| **Vertical Slice (Month 3–4)** | Add factory boss, one complete loop |
| **Pre-Alpha (Month 5–7)** | Procedural streets, dialogue, hallucinations |
| **Alpha (Month 8+)** | Visual refinement, narrative tuning, playtesting |
| **Beta & Release** | Distribution via itch.io / Steam Early Access |

---

## 8. Risks and Mitigation
- **Scope Creep**: Strict feature lock per milestone.
- **Visual Inconsistency**: Limit shader and model count; stylize via pixel filter.
- **Tone Confusion**: Use consistent absurdist tone to avoid misinterpretation as parody.
- **Performance**: Optimize 3D lighting and post-processing early.

---

## 9. Development Focus Questions
Use these as development checkpoints and creative alignment prompts:

1. What emotion should dominate each loop (hope, dread, apathy)?
2. How can lampposts embody both “progress” and “futility”?
3. When does alcohol enhance clarity vs. chaos — mechanically and thematically?
4. What makes this world believable within its absurdity?
5. How can humor and despair coexist in the same moment?
6. What should the player feel when they throw a brick — empowerment or desperation?
7. Is the player’s persistence rewarded or punished by the narrative loop?
8. How much randomness vs. authored meaning should procedural generation convey?
9. Should “breaking the loop” be an attainable goal — or an illusion?
10. What will remain in the player’s mind after credits roll?

---

## 10. Final Note
*Solidmaid* is not just a parody or surreal experiment — it’s an exploration of **routine, alienation, and coping mechanisms** disguised as a game.  
The project’s success depends on clarity of tone and emotional precision, not on technical excess.
