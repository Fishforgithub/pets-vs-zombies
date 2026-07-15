# Pets vs Zombies

An original 2D side-scrolling run-and-gun game. A human girl fights through a zombie outbreak with a pet companion from the existing pet universe.

## Current milestone

The repository contains a playable vertical-slice prototype with production character animation entering integration:

- keyboard movement, jumping, and crouching with stance-specific collision
- mouse aiming, shooting, and timed reload behavior
- complete girl state set: idle, run, jump, fall, crouch, fire, reload, hurt, and faint
- autonomous pet follow and auto-attack
- pursuing zombies with approved courier-zombie idle and action sprites
- approved stage-one city background and street ground tiles with procedural fallbacks
- health, ammunition, defeat, and stage-clear UI

Procedural drawing remains as a fallback while production pet, enemy, effects, and environment art continues to arrive.

## Controls

| Action | Input |
|---|---|
| Move | `A` / `D` or arrow keys |
| Jump | `Space` |
| Crouch | `S` or down arrow |
| Aim | Mouse |
| Fire | Left mouse button or `J` |
| Reload | `R` |
| Restart | `Enter` after defeat or clear |

## Run

1. Install a stable Godot 4 release.
2. Open `project.godot`.
3. Run the project with `F6`/`F5`.

The first target is Windows desktop at 1280×720 with stretch scaling enabled.

