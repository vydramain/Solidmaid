# Game Design Document: Solidmaid: Alkoldun Vasiliusavich

## 1. Overview
### Title
Solidmaid: Alkoldun Vasiliusavich

### Genre
2D Pixel Art Beat'em Up with Roguelite elements, Procedural Generation, and Mini-Games.

### Platform
PC (Windows/Linux/Mac), potentially Mobile/Console (via Godot export).

### Target Audience
Adults 18+ (due to alcohol-themed humor), fans of retro games (e.g., Double Dragon), and indie games with a cultural twist (similar to Cuphead with a Russian spin).

### Core Loop
1. **Preparation**: In the apartment — buff up with alcohol/snacks, equip items.
2. **Travel**: Procedurally generated street, moving right, with combat at lampposts.
3. **Boss/Work**: Factory arena — fight a boss while assembling a lamppost.
4. **Reward**: Earn currency, gain a new lamppost, return home.

The game is cyclical: levels repeat the loop with progression through equipment.

### Unique Selling Points
- Satire of 1990s Russia blended with folklore.
- Alcohol as a tactical mechanic with risks and rewards.
- Procedural levels for replayability.
- Innovations: alcohol combos, upgradeable lampposts, multitasking at the factory, alcohol alchemy, rhythm-based mechanics, folklore mashups, and replayability boosters.

## 2. Story and Setting
Set in an alternate 1990s Russia, a chaotic mix of post-Soviet grit and Russian fairy tales. The protagonist, Alkoldun Vasiliusavich, is a mystical alcoholic working at a lamppost factory. Each day is a struggle to survive and "piece together" his life.

Narrative: Minimal, delivered through dialogues and animations. The campaign ends with a "big boss" (factory director as a Zmey Gorynych, a mythical dragon).

## 3. Gameplay Mechanics
### Controls
- Movement: Rightward auto-scroll, jump/dodge.
- Attacks: Throwing items (bricks/bottles) at lampposts.
- Buffs: In the apartment — select drinks/snacks via UI menu.

### Preparation Phase (Home)
- Buffs: Drinks provide stats (strength, speed, HP). Snacks stabilize effects.
- Innovation: Alcohol Alchemy mini-game for mixing buffs.
- Equipment: Lampposts as weapons/upgrades.

### Travel Phase (Street)
- Procedural Generation: Street with random segments (houses, parks) and enemies (gopniks, leshy-dachnitsy).
- Combat: Triggered only at lampposts (combat zones). Attacks are ranged throws.
- Innovation: Place upgraded lampposts for tactical advantages.

### Boss/Work Phase (Factory)
- Arena: Fight a boss (e.g., robotic foreman) while assembling a lamppost on a conveyor.
- Mechanics: Throw attacks at the boss + timing-based assembly (QTE).
- Innovation: Alcohol Rhythm — buffs affect timing mechanics.

### Progression
- Currency: Earned from enemies/bosses, used to buy drinks/snacks.
- Equipment: Lampposts unlock new abilities (e.g., AOE attacks, healing).
- Levels: 8 for the campaign (escalating enemies/bosses), endless mode (score-based).

### Enemies and Bosses
- Enemies: Gopniks (melee), Leshies (ranged), Dachnitsy (traps).
- Bosses: Thematic (e.g., Level 1: Guard as Baba Yaga).

### Audio/Visual
- Art: Pixel art, 16-bit style.
- Sound: Chiptune with folklore motifs, SFX (bottles, hits).

### Innovative Mechanics and Player Satisfaction Details
To make the game memorable and satisfying, incorporate innovations focusing on replayability, humor, and tactics. These are tied to the core loop (prepare -> travel -> boss/work -> reward):

- **Alcohol as a Dynamic Buff System with Risks**: Beyond static buffs, introduce "alcohol combos." Mix drinks (e.g., beer + vodka = speed boost, but chance of a "hangover" debuff). Snacks neutralize risks (e.g., salted cucumber stabilizes). **Innovation**: "Alcohol Alchemy" — a mini-game in the apartment where players experiment, unlocking hidden effects (e.g., moonshine + berries = temporary invulnerability but blurred vision). **Satisfaction**: Experimentation like in roguelikes (e.g., Binding of Isaac), with randomization for replayability.
- **Lampposts as Tactical Hubs**: Not just catalysts — make them upgradeable. Lampposts collected from the factory can be placed on future streets, creating "safe zones." **Innovation**: Procedurally generated streets include "lamppost slots" where players pre-place lampposts (in the apartment). Lampposts have effects (e.g., one attracts enemies, another grants AOE attacks). **Satisfaction**: Strategic planning, blending tower defense tactics into a beat'em up.
- **Multitasking Factory Gameplay**: Boss fights + work become a rhythm game. Assemble lampposts on a conveyor (timing-based) while dodging the boss. **Innovation**: "Alcohol Rhythm" — buffs affect conveyor timing (e.g., beer speeds it up). Perfect assembly grants a bonus attack on the boss. **Satisfaction**: Flow-state gameplay like Celeste or Rhythm Heaven, with humorous fails (e.g., Vasiliusavich stumbles).
- **Cultural Flavor with Variations**: Enemies evolve across levels (gopniks -> leshy-gopniks). **Innovation**: "Folklore Mashup" — random events where enemies merge (e.g., dachnitsa + gopnik = hybrid with new attacks). Endless mode escalates with "cultural waves" (90s memes vs. fairy tales). **Satisfaction**: Humor and discovery, similar to Hades’ narrative surprises.
- **Replayability Boosters**: Achievements for playstyles (e.g., "Sober Challenge" without alcohol). Equipment mods (lamppost attachments). Social features: share procedural level seeds. **Satisfaction**: Mastery and community engagement.

These mechanics add depth without overcomplicating the core, boosting retention as players return for experimentation.

## 4. Levels
- **Campaign**: 8 levels, each increasing in difficulty (more enemies, new types).
- **Endless**: Infinite street + factory waves, high-score driven.

## 5. Monetization
Free-to-play with donations, or paid release on itch.io/Steam.

## 6. Technical Specs
- Engine: Godot 4.x.
- Resolution: 320x240 scaled.
- Save System: Auto-save progress.

## 7. Roadmap
- Month 1: Prototype core loop.
- Months 2-4: Levels, assets.
- Months 5+: Polish, release.

## 8. Risks and Mitigations
- Balance: Addressed through playtesting.
- Content: Humor-focused, avoiding promotion of harmful behavior.