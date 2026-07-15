# Art Asset Runtime Manifest

This file is the handoff contract between `agent/art-production` and the Godot implementation branch. Read it before integrating or replacing art. Only user-approved, processed assets belong here.

## Global Godot import rules

- Import all pixel-art textures with filtering disabled and mipmaps disabled.
- Use lossless PNG alpha. Do not key magenta at runtime; approved repository files are already transparent.
- Character frame cells are `256 x 256` unless a row below explicitly says otherwise.
- Use the bottom-center of each cell as the visual pivot. Keep the gameplay collision shape independent from visible empty padding.
- Never derive collision polygons from sprite alpha. Use simple authored `CapsuleShape2D`/`RectangleShape2D` shapes.
- Sheets are read left-to-right, then top-to-bottom.
- Do not silently reorder frames or infer a different grid. If implementation needs a different layout, update this document and the processed asset together.
- Use `AnimatedSprite2D` plus `SpriteFrames` for character animation. Atlas extraction is also acceptable if the documented cell size and order are preserved.

## Human girl

The girl's authored gameplay direction is right-facing. Use `flip_h = true` when facing left. Keep the weapon muzzle socket in gameplay code rather than deriving it from opaque pixels.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/characters/girl/girl_idle.png` | 1 x 1 | `idle` | Static or subtle procedural bob |
| `assets/characters/girl/girl_run_sheet.png` | 3 x 2, 6 frames | `run` frames 0–5 | Loop, 10 FPS |
| `assets/characters/girl/girl_air_sheet.png` | 2 x 1 | left `jump`, right `fall` | Select from vertical velocity; do not loop |
| `assets/characters/girl/girl_crouch.png` | 1 x 1 | `crouch` | Static |
| `assets/characters/girl/girl_combat_sheet.png` | 2 x 1 | left `fire`, right `reload` | Fire is a short pose; reload may be held/tweened |
| `assets/characters/girl/girl_damage_sheet.png` | 2 x 1 | left `hurt`, right `faint` | Hurt is brief; faint holds final pose |

## Courier zombie

The authored direction is left-facing. Display as-is while moving/attacking left; use `flip_h = true` when facing right. Keep damage and movement hitboxes smaller than the satchel.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/enemies/courier_zombie/idle.png` | 1 x 1 | `idle` | Static or subtle procedural bob |
| `assets/enemies/courier_zombie/walk_sheet.png` | Expected 3 x 2, 6 frames; current remote blob is invalid | `walk` frames 0–5 after replacement | Blocked pending a valid PNG |
| `assets/enemies/courier_zombie/action_sheet.png` | 3 x 1 | left `attack`, middle `hurt`, right `faint` | One-shot poses; faint holds |

## Umbrella commuter zombie

The authored direction is left-facing. Display as-is when the shield faces left; mirror the complete sprite and shield logic together when facing right. The umbrella is a gameplay shield, not part of the body hurtbox.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/enemies/umbrella_zombie/idle.png` | 1 x 1 | `idle` / shield stance | Static or subtle procedural bob |
| `assets/enemies/umbrella_zombie/walk_sheet.png` | 3 x 2, 6 frames | `walk` / shield-walk frames 0–5 | Loop, 8 FPS |

Suggested runtime nodes: one body hurtbox plus a separate forward `Area2D` shield collider. Front-facing bullets should be blocked/deflected by the shield; rear hits and pet attacks can bypass or damage it according to gameplay tuning. Keep the shield collider active and in the same forward offset throughout all six walk frames; do not derive its position from changing opaque pixels.

## Stage 1 boss: Undead Foreman

Boss frame cells are `512 x 512`, not the normal `256 x 256`. The authored direction is left-facing. Mirror the complete boss and every authored attack collider together when facing right.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/bosses/stage1_foreman/idle.png` | 1 x 1, 512 x 512 | `idle` identity anchor | Static until an approved idle animation is available |
| `assets/bosses/stage1_foreman/walk_sheet.png` | 2 x 2, 4 frames of 512 x 512 | `walk` heavy stomp frames 0–3 | Loop, 6 FPS |
| `assets/bosses/stage1_foreman/sweep_sheet.png` | 2 x 2, 4 frames of 512 x 512 | `sweep`: wind-up, early swing, active sweep, recovery | One shot, 7 FPS; enable hammer hitbox only on frame index 2 |

Use separate authored shapes for the boss body, vulnerable area, and road-barrier hammer. Never include the extended hammer in the persistent body hurtbox. Activate weapon hitboxes only during documented attack windows. For `sweep`, frame index 2 owns the wide leftward attack area; frames 0, 1, and 3 must not damage the player. Preserve the bottom-center pivot when switching animations so the large sprite does not jump vertically.

## Stage 1 environment

| Asset | Grid / order | Runtime use |
|---|---|---|
| `assets/backgrounds/stage1/city_far.png` | 960 x 540 single opaque image | Far/mid parallax background. Stretch to viewport with aspect-cover or repeat horizontally after seam preparation; no collision. |
| `assets/tilesets/stage1/ground_tiles.png` | 4 x 1, 256 x 256 cells | Basic, cracked, drain, puddle. All share one flat top surface. Assign the same rectangular ground collision to each tile. |
| `assets/props/stage1/street_props.png` | 4 x 1, 256 x 256 cells | Crate, traffic cone, two trash bags, fire hydrant. Crate may be breakable; other props default to decoration unless level design opts in to collision. |
| `assets/props/stage1/crate_break_sheet.png` | 3 x 1, 256 x 256 cells | `hit`, `breaking`, `destroyed`. Play once at about 10 FPS, disable crate collision during/after the breaking frame, then spawn any pickup. |

## Pickups and VFX

| Asset | Grid / order | Runtime mapping |
|---|---|---|
| `assets/items/pickups.png` | 4 x 1, 256 x 256 cells | Health snack, ammo box, pet treat, gear coin. Use simple centered pickup areas; visual bob/glow may be procedural. |
| `assets/vfx/combat_effects.png` | 4 x 1, 256 x 256 cells | Muzzle flash, bullet impact, pet-energy hit, heal sparkle. These are single-frame flashes; scale them down in-scene rather than resampling source files. |

## Current integration order

1. Replace graybox girl visuals while retaining existing movement and combat logic.
2. Replace the common zombie with the courier zombie animation set.
3. Add the Stage 1 background, ground tiles, and props without coupling visuals to level logic.
4. Add pickups and VFX.
5. Add the umbrella zombie as a separate enemy scene with a forward shield collider.
6. Add the Stage 1 boss as an independent boss scene with a boss state machine and separate weapon hitbox.
7. Keep procedural placeholders as fallbacks when an optional production asset is absent.

## Approval and branch protocol

- New images are generated for review first.
- Only images explicitly approved by the user are processed and committed.
- Approved art is committed to `agent/art-production`.
- The Godot implementation branch should merge the art branch or cherry-pick the announced art commits.
- When a commit adds or changes runtime-relevant art, this manifest must be updated in the same commit or a directly following documentation commit.
