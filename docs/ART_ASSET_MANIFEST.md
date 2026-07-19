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

The authored direction is right-facing. Display as-is while moving/attacking right; use `flip_h = true` when facing left. Keep damage and movement hitboxes smaller than the satchel.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/enemies/courier_zombie/idle.png` | 1 x 1 | `idle` | Static or subtle procedural bob |
| `assets/enemies/courier_zombie/walk_sheet.png` | 3 x 2, 6 frames | `walk` frames 0-5 | Loop, 8 FPS |
| `assets/enemies/courier_zombie/action_sheet.png` | 3 x 1 | left `attack`, middle `hurt`, right `faint` | One-shot poses; faint holds |

## Umbrella commuter zombie

The authored direction is left-facing. Display as-is when the shield faces left; mirror the complete sprite and shield logic together when facing right. The umbrella is a gameplay shield, not part of the body hurtbox.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/enemies/umbrella_zombie/idle.png` | 1 x 1 | `idle` / shield stance | Static or subtle procedural bob |
| `assets/enemies/umbrella_zombie/walk_sheet.png` | 3 x 2, 6 frames | `walk` / shield-walk frames 0–5 | Loop, 8 FPS |
| `assets/enemies/umbrella_zombie/action_sheet.png` | 3 x 1 | index 0 `attack`, 1 `hurt`, 2 `defeated` | State-selected poses; attack one-shot, defeated holds |

Suggested runtime nodes: one body hurtbox plus a separate forward `Area2D` shield collider. Front-facing bullets should be blocked/deflected by the shield; rear hits and pet attacks can bypass or damage it according to gameplay tuning. Keep the shield collider active and in the same forward offset throughout all six walk frames; do not derive its position from changing opaque pixels. During `attack`, enable the short forward bash hitbox only for the active attack window. During `hurt`, temporarily disable the shield collider. On `defeated`, permanently disable shield, damage, navigation, and body collision before cleanup.

## Stage 2 enemies

### Zombie crow

The authored direction is left-facing. Display as-is while flying or attacking left and use `flip_h = true` for right-facing movement. This enemy is airborne: use a compact body hitbox centered on the torso and do not include full wing tips in collision.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/enemies/zombie_crow/idle.png` | 1 x 1, 256 x 256 | identity anchor / hover fallback | Static until the approved flight cycle is available |
| `assets/enemies/zombie_crow/flight_sheet.png` | 3 x 2, 6 frames of 256 x 256 | `fly` hovering flight frames 0–5 | Loop, 10 FPS |
| `assets/enemies/zombie_crow/action_sheet.png` | 3 x 1, 256 x 256 cells | index 0 `dive`, 1 `hurt`, 2 `defeated` | Dive and hurt are state poses; defeated holds |

For `dive`, rotate/move the enemy body along the authored down-left attack vector and enable damage only during the dive window. `hurt` stops targeting and preserves airborne knockback. `defeated` disables damage and collision before the grounded cleanup pose.

### Zombie dog

The authored direction is left-facing. Display as-is while running/attacking left and use `flip_h = true` for right-facing movement. This is a low-profile fast enemy: use a horizontal torso hitbox that excludes the raised ears, tail tip, and exposed rib silhouette.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/enemies/zombie_dog/idle.png` | 1 x 1, 256 x 256 | identity anchor / ready stance | Static until the approved run cycle is available |
| `assets/enemies/zombie_dog/run_sheet.png` | 3 x 2, 6 frames of 256 x 256 | `run` sprint frames 0–5 | Loop, 12 FPS |
| `assets/enemies/zombie_dog/action_sheet.png` | 3 x 1, 256 x 256 cells | index 0 `pounce`, 1 `hurt`, 2 `defeated` | State-selected poses; defeated holds |

Known delivery defect: `run_sheet.png` has opaque pixels on the shared x=512 boundary in frames 1 and 2. Keep the sheet out of runtime atlas slicing until request `AR-20260719-006` supplies a normalized replacement. The approved identity, frame order, authored direction, and 12 FPS playback remain unchanged.

Keep the torso collision shape at a stable local offset across the full run cycle; do not move or resize gameplay collision to follow the extended forelegs, hind legs, tail, or exposed ribs. The long airborne stride at frame index 2 is still part of the looping sprint and does not by itself trigger pounce damage.

For `pounce`, move the enemy body along a short authored gameplay arc and enable the bite hitbox only during the active overlap window; the pose alone must not deal continuous damage. `hurt` cancels pounce damage and uses backward knockback. `defeated` permanently disables navigation, damage, and collision before holding the collapsed pose for cleanup.

### Zombie nurse

The authored direction is left-facing. Display as-is while moving or throwing left and use `flip_h = true` for right-facing behavior. This is a mid-range support enemy: keep the body hitbox on the torso and exclude the held bandage roll, belt rolls, pouch, hair, and nurse cap.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/enemies/zombie_nurse/idle.png` | 1 x 1, 256 x 256 | identity anchor / support-ready stance | Static until the approved walk cycle is available |
| `assets/enemies/zombie_nurse/walk_sheet.png` | 3 x 2, 6 frames of 256 x 256 | `walk` shamble frames 0–5 | Loop, 8 FPS |
| `assets/enemies/zombie_nurse/action_sheet.png` | 4 x 1, 256 x 256 cells | index 0 `throw`, 1 `buff`, 2 `hurt`, 3 `defeated` | State-selected poses; defeated holds |

Bandage projectiles and buff effects must be separate gameplay nodes; do not use the bandage pixels in this identity sprite as collision or projectile geometry. Preserve the mint cap, cream-and-mint tunic, coral bandage wraps, turquoise pouch, and three-roll loadout across future animation sheets.

Keep a stable bottom-center pivot while the six-frame cycle alternates contact, down, and passing poses. The visible held roll and belt loadout are decorative during `walk`; throwing and ally-buff behavior must only start from their dedicated action states.

For `throw`, spawn one separate bandage projectile from the forward hand and enable projectile motion only after release. For `buff`, apply the ally effect once at the action event and render the larger range indicator as a separate VFX node; the small authored pulse only identifies the pose. `hurt` cancels throw/buff events. `defeated` permanently disables support logic, navigation, damage, and collision before holding the collapsed pose.

### Zombie doctor

The authored direction is left-facing. Display as-is while moving or attacking left and use `flip_h = true` for right-facing behavior. This is a rear-line electric controller: keep the body hitbox on the torso and exclude the forward paddle, cables, shoulder-mounted defibrillator box, clipped paddle, coat tails, and hair.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/enemies/zombie_doctor/idle.png` | 1 x 1, 256 x 256 | identity anchor / electric-ready stance | Static until the approved walk cycle is available |
| `assets/enemies/zombie_doctor/walk_sheet.png` | 3 x 2, 6 frames of 256 x 256 | `walk` burdened shamble frames 0–5 | Loop, 8 FPS |
| `assets/enemies/zombie_doctor/action_sheet.png` | 3 x 1, 256 x 256 cells | index 0 `zap`, 1 `hurt`, 2 `defeated` | State-selected poses; defeated holds |

The authored paddle spark is an identity cue only. Damage range, zap beam, hit timing, and status-control effects must use separate gameplay/VFX nodes. Preserve the crooked glasses, mismatched eyes, wild dark hair, cream coat, coral tie/armband, turquoise shirt, shoulder box, two paddles, and coiled cables across future animation sheets.

Keep a stable bottom-center pivot while the walk alternates contact, down, and passing poses. The carried box, clipped paddle, and coiled lead visibly lag the body but remain decorative during `walk`; electric damage must only begin from the dedicated attack state.

For `zap`, enable one short forward attack area or separate beam VFX only during the authored discharge window; the visible arc does not define collision length. `hurt` cancels the active zap and any control status application. `defeated` permanently disables electric output, navigation, damage, and collision before holding the grounded pose with a dark device screen.

### Wheelchair zombie

The authored direction is left-facing, with the reinforced bumper and front caster on the left. Display as-is while rolling or charging left and use `flip_h = true` for right-facing behavior. This is an armored directional charger: author separate collision shapes for the zombie body, wheelchair body, and forward shield plate.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/enemies/wheelchair_zombie/idle.png` | 1 x 1, 256 x 256 | identity anchor / braced ready stance | Static until the approved roll cycle is available |
| `assets/enemies/wheelchair_zombie/roll_sheet.png` | 3 x 2, 6 frames of 256 x 256 | `roll` wheel/suspension frames 0–5 | Loop, 10 FPS |
| `assets/enemies/wheelchair_zombie/action_sheet.png` | 4 x 1, 256 x 256 cells | index 0 `charge`, 1 `hurt`, 2 `stunned`, 3 `defeated` | State-selected poses; defeated holds |

The broad cream-and-coral footplate is the forward shield and may block or reduce weak frontal shots. The exposed zombie torso and rear/upper chair remain the vulnerable area. Exclude spokes, wheel rims, front caster, brake lever, hair, and blanket edges from the persistent body hurtbox; never derive collision from sprite alpha. Mirror the shield offset and charge direction together when facing changes.

Keep the gameplay body's ground position stable while the six-frame roll cycle supplies visual suspension compression, rebound, forward pitch, and a brief caster lift. The coral rear-rim marker is an animation cue only. Keep the forward shield collider attached throughout every roll frame even when its artwork rises; do not move collision to follow wheel or shield pixels.

For `charge`, enable forward damage and shield priority only during the explicit rush window. `hurt` cancels charge damage but may retain brief momentum. `stunned` disables movement and the shield collider, opening the body/rear vulnerable window; the visually sideways caster remains part of the intact chair and is not a detached gameplay object. `defeated` permanently disables navigation, shield, damage, and collision while leaving the chair upright and intact.

## Stage 2 boss: Undead Chief Surgeon

Chief Surgeon frame cells are `512 x 512`. The authored direction is left-facing, with the operating-lamp hammer head resting on the left. Mirror the complete boss, weapon, IV canisters, and authored attack colliders together when facing right.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/bosses/stage2_chief_surgeon/idle.png` | 1 x 1, 512 x 512 | `idle` identity anchor | Static until approved locomotion/idle motion is available |
| `assets/bosses/stage2_chief_surgeon/walk_sheet.png` | 2 x 2, 4 frames of 512 x 512 | `walk` heavy contact/down/rebound frames 0–3 | Loop, 6 FPS |
| `assets/bosses/stage2_chief_surgeon/sweep_sheet.png` | 2 x 2, 4 frames of 512 x 512 | `sweep`: wind-up, early swing, active sweep, recovery | One shot, 7 FPS; weapon damage only on frame index 2 |
| `assets/bosses/stage2_chief_surgeon/slam_sheet.png` | 2 x 2, 4 frames of 512 x 512 | `slam`: high wind-up, downward drive, ground impact, recovery | One shot, 7 FPS; impact/shockwaves spawn on frame index 2 |
| `assets/bosses/stage2_chief_surgeon/reaction_sheet.png` | 2 x 2, four independent 512 x 512 poses | index 0 `hurt`, 1 `rage`, 2 `stunned`, 3 `defeated` | State-selected key poses; do not loop as one animation |

Author separate simple shapes for the boss body, vulnerable upper torso/head, IV-stand shaft, and oversized operating-lamp hammer. The lamp head, shaft, hanging canisters, coat tails, hair, and loupe are excluded from the persistent body hurtbox. Weapon damage is enabled only during documented attack windows; never derive collision from sprite alpha. Preserve the bottom-center pivot so the massive body does not jump when switching states.

Keep the gameplay body's ground position stable while the walk cycle supplies heavy contact, compression, opposite stride, and rebound. The lamp head alternates between ground drag and a short visual lift but deals no damage during `walk`. IV canisters, apron, straps, hair, and mask provide secondary motion only.

For `sweep`, frames 0–1 are readable telegraph/startup and must not damage the player. Frame index 2 owns the wide leftward lamp-head attack area; its colored motion arc is visual only and does not define collision. Frame 3 disables weapon damage and recovers toward idle. Mirror the complete attack area and weapon together when facing right.

For `slam`, frames 0–1 are the high telegraph and downward drive. Frame index 2 owns the local lamp-head impact area and spawns one leftward plus one rightward ground shockwave at the contact point; the authored colored burst/debris is visual only. Frame 3 disables impact damage and exposes the recovery window. Mirror the impact origin and shockwave directions with the full boss when facing changes.

`hurt` cancels the current attack but does not enter a long vulnerability by itself. `rage` is the phase-two transition: temporarily lock movement/attacks, play the transition cue once, then enable the faster phase-two behavior after the authored pose. `stunned` disables weapon damage and opens the upper-torso/head vulnerable window. `defeated` permanently disables all boss damage, navigation, body/weapon collision, and lamp output before stage-clear timing; the grounded weapon and IV canisters remain visual only.

## Stage 2 hospital hazards

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/hazards/stage2/rolling_equipment_sheet.png` | 4 x 1, 256 x 256 cells | `roll`: level travel, forward pitch, airborne bounce, settle | Loop, 10 FPS while moving |

The rolling equipment cart is a phase-two Chief Surgeon hazard and may also be reused as a hospital corridor trap. Spawn it as a moving hazard scene with one simple rectangular body/damage shape aligned to the lower cart frame; never derive collision from the monitor, bottles, bandages, loose straps, wheels, or sprite alpha. Keep the gameplay body on a stable ground path while the animation supplies pitch and bounce. Bottles and loose supplies are decorative and must not create separate projectiles.

Enable contact damage only during active travel. Disable damage and collision before despawn, destruction, or off-screen cleanup. Mirror the sprite and travel direction together when launched to the right. The four frames form one continuous motion loop; they are not separate damage states.

## Stage 2 environment

| Asset | Size | Runtime use |
|---|---|---|
| `assets/backgrounds/stage2/hospital_corridor.png` | 960 x 540 opaque image | Approved hospital palette/lighting anchor and single-room corridor or boss-arena background plate. Display aspect-cover at 16:9; no collision. |
| `assets/backgrounds/stage2/hospital_wall_modules.png` | 4 x 1, 256 x 256 cells | Intact wall, closed treatment door, open dark doorway, cracked observation window. Independent background modules; no baked collision. |
| `assets/tilesets/stage2/hospital_ground_tiles.png` | 4 x 1, 256 x 256 cells | Basic, cracked, drain, puddle. Repeatable side-view hospital floor blocks with aligned outer geometry and walkable top. |

This plate establishes the Stage 2 environment language: faded cream plaster, mint wall tiles, muted turquoise fixtures, alternating amber emergency lamps and cyan clinical light, with restrained coral symbols. It contains perspective and unique room landmarks, so do not repeat it horizontally as a seamless texture. Use it for a bounded room/arena, or keep it as the far visual plate behind separately authored repeatable corridor modules. The illustrated floor does not define the player path: author a separate horizontal gameplay floor and collision layer in Godot.

All four hospital ground cells use the same tile origin and aligned top surface. Assign the same simple rectangular ground collision to every variant; cracks, grate openings, puddle edges, drips, and front-face damage are decorative only. The tile artwork reaches both horizontal cell edges so adjacent cells can form a continuous platform. Disable texture filtering and avoid per-tile scaling so seams remain stable.

Treat the wall cells as region-selected `Sprite2D` background modules over a continuous wall-color backing, not as physics tiles. The modules share a bottom baseline and similar side-column width; place adjacent modules with controlled overlap behind the columns rather than assuming transparent cell margins are seamless. Closed and open doors may swap at the same anchor. Door blocking, room transitions, prompts, locks, and triggers must use independent Godot collision/interaction nodes. The cracked observation window is decorative and does not imply a breakable surface unless level design explicitly adds one.

### Stage 2 hospital props

| Asset | Grid / order | Runtime use |
|---|---|---|
| `assets/props/stage2/hospital_props.png` | 4 x 1, 256 x 256 cells | Empty gurney, IV stand, supply cabinet, tipped paired chair. Independent bottom-aligned props at a shared world scale. |

All four props default to decoration with no gameplay collision. When level design requires blocking, use a simple low rectangle for the gurney, cabinet, or chair base and exclude wheels, rails, sheets, drawers, IV bags/pole, and loose paper. The IV stand should remain non-blocking. The cabinet drawer and empty IV bags are static art; pickups, break reactions, and swinging motion require separate nodes or future state art. Preserve the authored relative scale rather than enlarging every cell to fill its region.

## Stage 1 boss: Undead Foreman

Boss frame cells are `512 x 512`, not the normal `256 x 256`. The authored direction is left-facing. Mirror the complete boss and every authored attack collider together when facing right.

Known delivery defect: the current four multi-frame sheets contain opaque content crossing their 512 px cell boundaries, which produces clipping and adjacent-frame fragments under the exact atlas regions below. Request `AR-20260716-005` must normalize the cells without changing these runtime regions, frame orders, pivots, or attack timings. Replacement Boss imagery still requires explicit user visual approval.

| Asset | Grid / order | Runtime mapping | Playback |
|---|---|---|---|
| `assets/bosses/stage1_foreman/idle.png` | 1 x 1, 512 x 512 | `idle` identity anchor | Static until an approved idle animation is available |
| `assets/bosses/stage1_foreman/walk_sheet.png` | 2 x 2, 4 frames of 512 x 512 | `walk` heavy stomp frames 0–3 | Loop, 6 FPS |
| `assets/bosses/stage1_foreman/sweep_sheet.png` | 2 x 2, 4 frames of 512 x 512 | `sweep`: wind-up, early swing, active sweep, recovery | One shot, 7 FPS; enable hammer hitbox only on frame index 2 |
| `assets/bosses/stage1_foreman/slam_sheet.png` | 2 x 2, 4 frames of 512 x 512 | `slam`: high wind-up, downward swing, ground impact, recovery | One shot, 7 FPS; impact and shockwave spawn on frame index 2 |
| `assets/bosses/stage1_foreman/reaction_sheet.png` | 2 x 2, four independent 512 x 512 poses | index 0 `hurt`, 1 `rage`, 2 `stunned`, 3 `defeated` | State-selected key poses; do not loop as one animation |

Use separate authored shapes for the boss body, vulnerable area, and road-barrier hammer. Never include the extended hammer in the persistent body hurtbox. Activate weapon hitboxes only during documented attack windows. For `sweep`, frame index 2 owns the wide leftward attack area; frames 0, 1, and 3 must not damage the player. For `slam`, frame index 2 owns the local impact hitbox and spawns one leftward plus one rightward ground shockwave at the hammer contact point. The `rage` pose is the phase-two transition, `stunned` disables attacks and opens the vulnerable window, and `defeated` disables all damage/collision before stage-clear timing. Preserve the bottom-center pivot when switching animations so the large sprite does not jump vertically.

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
| `assets/vfx/foreman_shockwave.png` | 4 x 1, 256 x 256 cells | Boss slam ground wave: spawn, rise, active travel, dissipate. Play once at 12 FPS, move the effect node horizontally, enable damage only on frame index 2, and use `flip_h` for the rightward copy. |
| `assets/vfx/stage2_hospital_effects.png` | 4 x 1, 256 x 256 cells | Index 0 electric-zap hit, 1 bandage ally-buff aura, 2 wheelchair skid dust, 3 Chief Surgeon lamp-slam impact. Each cell is an independent single-frame effect, not one animation. |

For the Stage 2 hospital effects, place index 0 at the resolved zap contact point and flash/fade it without collision. Center index 1 on the buffed ally's ground pivot and keep it behind the character; gameplay buff duration remains independent of the visual fade. Place index 2 at the wheelchair's rear ground contact, use `flip_h` with travel direction, and emit it only during charge braking or sharp turns. Place index 3 at the Chief Surgeon's lamp contact point on slam frame index 2; it is the local impact flash, while traveling shockwaves and their damage areas remain separate runtime nodes. None of these textures defines a hitbox.

## UI

| Asset | Size | Runtime use |
|---|---|---|
| `assets/ui/stage1/boss_health_frame.png` | 640 x 96 fixed overlay | Construction-themed Stage 1 boss health frame. Place above a dynamic fill node; recommended inner fill rect is x=60, y=16, width=520, height=64. Do not stretch as a NinePatch and do not bake boss name, health, or numbers into this texture. |

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
