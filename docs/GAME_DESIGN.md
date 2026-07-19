# Game Design — Stage-Based Campaign

## Fantasy

The player is a resourceful young girl surviving a colorful zombie outbreak. Her pet is not cosmetic: it follows, attacks automatically, and grows into an active combat partner.

## Core campaign loop

1. Enter a side-scrolling stage.
2. Defeat five increasingly difficult waves of zombies.
3. Fight the stage boss after wave five.
4. Earn experience, currency, and stage rewards from combat.
5. Improve the player, buy or upgrade weapons, and improve pet skills.
6. View the stage result and choose the next stage card from the route map.

Waves do not require five unique zombie archetypes. A stage may repeat or mix existing enemies and increase difficulty through enemy count, spawn cadence, spawn direction, and the maximum number alive at once.

## Stage 1 — City Street

Stage 1 intentionally teaches the loop with the common courier zombie. Additional enemy variants are optional and must not block completion of the stage.

| Encounter | Default composition | Difficulty purpose |
|---|---:|---|
| Wave 1 | 3 courier zombies | Single-side introduction |
| Wave 2 | 4 courier zombies | Shorter spawn interval |
| Wave 3 | 5 courier zombies | Mixed left/right spawns |
| Wave 4 | 6 courier zombies | Higher simultaneous-alive limit |
| Wave 5 | 8 courier zombies | Fast final pressure wave |
| Boss | 1 Undead Foreman | Stage mastery check |

The common zombie's base health and damage remain stable across these waves. Stage 1 difficulty comes primarily from encounter composition so weapon damage remains understandable to the player.

## Character responsibilities

### Human girl

- Directly controlled movement, jumping, crouching, aiming, and firearms.
- Owns health, ammunition, reload, damage, faint, experience, level, currency, and weapon inventory.
- Final baseline animations: `idle`, `run`, `jump`, `fall`, `crouch`, `fire`, `reload`, `hurt`, and `faint`.

### Pet companion

- Follows autonomously without blocking the player.
- Chooses the nearest valid enemy and attacks at intervals.
- Teleports back only if pathing or distance recovery fails.
- Gains upgradeable combat skills independently from the player's weapon upgrades.

## Progression economy

- Every defeated enemy grants both experience and currency.
- Experience raises the player level and unlocks weapon tiers or skill capacity.
- Currency buys weapons, weapon upgrades, and pet-skill upgrades.
- Boss and stage-clear rewards are larger than normal enemy rewards.
- Weapon data must keep damage, fire interval, magazine size, reload duration, price, and unlock level independent from player movement code.
- Pet-skill data must keep damage, cooldown, range, targeting behavior, and upgrade price independent from follow movement.

Campaign progression is stored as versioned JSON at `user://campaign_profile.json`. Stage-clear rewards and successful shop purchases persist the player level, XP, gears, weapon levels, pet-skill levels, completed stages, and highest unlocked stage across replay and application restarts. Existing version 1 profiles migrate with Stage 1 completed and Stage 2 unlocked because that profile format was written only from the Stage 1 clear workbench flow. Failed-stage partial rewards remain run-scoped. Invalid or unsupported save data is rejected without replacing safe defaults. Windows desktop remains the first target; the Web build uses the same gameplay data model and Godot `user://` storage.

The project opens on the campaign route instead of immediately starting Stage 1. Players may replay any completed stage, and future playable stage scenes become selectable through the same route-card contract. A stage may be visibly unlocked while remaining non-interactive when its gameplay scene is still under construction.

## Campaign UI roadmap

1. Wave counter and remaining-enemy HUD.
2. Boss entrance presentation and boss health bar.
3. Stage-clear reward screen.
4. Next-stage card.
5. Weapon and pet-upgrade shop.
6. Multi-stage route map and persistent stage unlocks. Implemented as the project entry flow; additional stage scenes plug into their route cards as they are completed.

The Stage 1 result screen includes the first upgrade workbench. Purchases persist through the campaign profile so the same weapon and pet-skill levels can carry into later stages.

## Art handoff

Before requesting new production art, read `docs/ART_ASSET_MANIFEST.md`. Add every new request to `docs/ART_REQUEST_QUEUE.md`, commit it, push it to GitHub, and report the commit SHA to the art-production workflow.

## Deferred beyond the Stage 1 milestone

- Grenades.
- Multiple selectable pets.
- Full playable route content beyond the implemented Stage 1 card and Stage 2 construction placeholder.
- Mobile touch controls.
- Online services and LINE account integration.
