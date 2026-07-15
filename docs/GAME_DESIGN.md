# Game Design — Vertical Slice

## Fantasy

The player is a resourceful young girl surviving a colorful zombie outbreak. Her pet is not cosmetic: it follows, attacks automatically, and later provides an elemental active skill.

## First playable loop

1. Enter a short city street.
2. Move, jump, aim, and fire while the pet follows.
3. Defeat five pursuing zombies.
4. Reach stage clear or lose all health and retry immediately.

## Character responsibilities

### Human girl

- Directly controlled.
- Owns movement, jumping, aiming, firearms, grenades, damage, and revival state.
- Final animation set: idle, run, jump, crouch, fire, reload, hurt, faint.

### Pet companion

- Follows autonomously without blocking the player.
- Chooses the nearest valid enemy and attacks at intervals.
- Teleports back only if pathing or distance recovery fails.
- First production companion candidate: `spark`, using chain lightning later.

## Vertical-slice content

- One human girl.
- One pet companion.
- One common zombie archetype.
- One short street stage.
- One firearm and pet projectile.
- HUD for health, ammunition, objective, defeat, and clear.

## Explicitly deferred

- Boss battle.
- Grenades and weapon pickups.
- Multiple pets and pet selection.
- Persistent progression and save data.
- Mobile touch controls.
- Online services and LINE account integration.

