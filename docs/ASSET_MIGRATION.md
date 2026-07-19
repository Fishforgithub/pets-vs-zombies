# Asset Migration Register

The source repository `Fishforgithub/tea-line-bot` is read-only. Copy only approved exported assets into this repository and record every copy here.

## Candidate source locations

| Category | Source |
|---|---|
| Pet sprites | `public/liff/pet-game/pets/sprites/<pet>/` |
| Effects | `public/liff/pet-game/pets/fx/` |
| Backgrounds | `public/liff/pet-game/pets/bg/` and `scenes/` |
| Items | `public/liff/pet-game/pets/items/` |
| Character prompts | `docs/pet-game/ART-PROMPTS*.md` |
| Static image pipeline | `scripts/gen-art.mjs`, `compress-art.mjs`, `compress-bg.mjs` |
| Frame animation pipeline | `Fishforgithub/Gen_Sprite_Engine` |

## Import rules

- Preserve the source filename in the provenance table.
- Prefer lossless WebP or PNG with valid alpha for sprites.
- Verify all four corner alpha values for transparent assets.
- Disable texture filtering for pixel-art textures in Godot.
- Do not copy LIFF code, authentication code, secrets, or player data.

## Imported assets

| Target | Source | Status |
|---|---|---|
| `assets/characters/girl/girl_idle.png` | Approved project-specific image generation; pure-magenta source keyed to alpha with the standard image pipeline | Integrated as the human protagonist identity anchor |
| `assets/characters/girl/girl_run_sheet.png` | Six-frame run-cycle generated from the approved identity anchor; keyed to alpha, normalized to six 256×256 cells | Integrated as the `run` animation at 10 FPS |
| `assets/characters/girl/girl_air_sheet.png` | Two-frame airborne sheet generated from the approved identity anchor; keyed to alpha and normalized to two 256×256 cells | Integrated as velocity-driven `jump` and `fall` states |
| `assets/characters/girl/girl_crouch.png` | Approved project-specific crouch sprite from `agent/art-production` commit `28a3b80`; identity-preserving pose normalized from the approved idle anchor; pure-magenta source keyed to alpha and normalized to a 256×256 frame with the standard feet baseline | Integrated as the grounded `crouch` animation |
| `assets/characters/girl/girl_combat_sheet.png` | Approved project-specific sprite sheet from `agent/art-production` commit `323b967`; two 256×256 cells normalized to the standard feet baseline | Integrated as the standing `fire` and timed `reload` states |
| `assets/characters/girl/girl_damage_sheet.png` | Approved project-specific sprite sheet from `agent/art-production` commit `cd14402`; two 256×256 cells normalized to the standard feet baseline | Integrated as the `hurt` and terminal `faint` states |
| `assets/enemies/courier_zombie/idle.png` | Approved project-specific courier zombie sprite from `agent/art-production` commit `9a70fa2`; normalized to a 256×256 frame with the standard feet baseline | Integrated as the courier zombie `idle` presentation |
| `assets/enemies/courier_zombie/walk_sheet.png` | Valid six-frame replacement from `agent/art-production` commit `8912004`; 3x2 cells at 256x256 with transparent corners | Integrated as the courier zombie `walk` animation at 8 FPS |
| `assets/enemies/courier_zombie/action_sheet.png` | Approved three-cell courier zombie action sheet from `agent/art-production` commit `f6420cd`; cells normalized to the standard feet baseline | Integrated as `attack`, `hurt`, and delayed-removal `faint` states |
| `assets/backgrounds/stage1/city_far.png` | Approved stage-one city background from `agent/art-production` commit `01a0346` | Integrated as a repeating far-background layer with procedural fallback |
| `assets/tilesets/stage1/ground_tiles.png` | Approved four-cell street ground strip from `agent/art-production` commit `56fe0dc` | Integrated across the stage floor with procedural fallback |
| `assets/props/stage1/street_props.png` | Approved four-cell street prop sheet from `agent/art-production` commit `743c4bd` | Imported and available for stage-one scene dressing |
| `assets/props/stage1/crate_break_sheet.png` | Approved three-cell breakable crate sheet from `agent/art-production` commit `dfd5e70` | Imported and reserved for the breakable-prop system |
| `assets/items/pickups.png` | Approved four-cell gameplay pickup sheet from `agent/art-production` commit `accee79` | Imported and reserved for the pickup system |
| `assets/vfx/combat_effects.png` | Approved four-cell combat effect sheet from `agent/art-production` commit `956a2f9` | Imported and reserved for runtime combat effects |
| `assets/enemies/umbrella_zombie/idle.png` | Approved umbrella commuter zombie idle sprite from `agent/art-production` commit `cc2f4d7` | Imported and reserved for the next enemy variant |
| `assets/enemies/umbrella_zombie/walk_sheet.png` | Approved six-frame shield-walk sheet from `agent/art-production` commit `f940a94`; 3x2 cells at 256x256 | Imported and reserved for the umbrella zombie enemy scene |
| `assets/bosses/stage1_foreman/idle.png` | Approved Stage 1 boss identity anchor from `agent/art-production` commit `05449ea`; 512x512 with bottom-center pivot | Integrated as the Undead Foreman idle presentation |
| `assets/bosses/stage1_foreman/walk_sheet.png` | Approved four-frame heavy walk from `agent/art-production` commit `6ca9d39`; 2x2 cells at 512x512 | Integrated at 6 FPS; cell-boundary normalization queued as `AR-20260716-005` after clipping/adjacent-frame bleed was found in gameplay |
| `assets/bosses/stage1_foreman/sweep_sheet.png` | Approved four-frame sweep attack from `agent/art-production` commit `92a11e8`; 2x2 cells at 512x512 | Integrated with a frame-2 hammer hitbox; cell-boundary normalization queued as `AR-20260716-005` |
| `assets/bosses/stage1_foreman/slam_sheet.png` | Approved four-frame ground slam from `agent/art-production` commit `5345238`; 2x2 cells at 512x512 | Integrated with a frame-2 local impact and twin shockwave event; cell-boundary normalization queued as `AR-20260716-005` |
| `assets/bosses/stage1_foreman/reaction_sheet.png` | Approved four-pose reaction sheet from `agent/art-production` commit `86fd34c`; 2x2 cells at 512x512 | Integrated for `hurt` and `defeated`, with `rage` and `stunned` reserved; cell-boundary normalization queued as `AR-20260716-005` |
| `assets/vfx/foreman_shockwave.png` | Four-frame Stage 1 slam shockwave from `agent/art-production` commit `843a02e`; 4x1 cells at 256x256 | Integrated as independently moving left/right Foreman shockwaves with frame-2 damage |
| `assets/enemies/umbrella_zombie/action_sheet.png` | Three-pose action delivery from `agent/art-production` commit `99dcec9`; attack, hurt, defeated | Imported and reserved for the umbrella zombie scene |
| `assets/ui/stage1/boss_health_frame.png` | Fixed 640x96 construction-themed overlay from `agent/art-production` commit `e06b862` | Integrated as the fixed overlay around the dynamic Stage 1 boss health fill |
| `assets/enemies/zombie_crow/idle.png` | Approved original Stage 2 aerial-enemy generation | User-approved; 256×256 transparent zombie crow identity anchor |
| `assets/enemies/zombie_crow/flight_sheet.png` | Six-frame generation derived from the zombie crow identity anchor | User-approved; 3×2 flight loop of 256×256 cells |
| `assets/enemies/zombie_crow/action_sheet.png` | Three-pose generation derived from the zombie crow identity anchor | User-approved; dive, hurt, and defeated 256×256 cells |
| `assets/enemies/zombie_dog/idle.png` | Approved original Stage 2 low-runner generation | User-approved; 256×256 transparent zombie dog identity anchor with stylized exposed bone |
| `assets/enemies/zombie_dog/run_sheet.png` | Six-frame generation derived from the approved zombie dog identity anchor | User-approved; 3×2 sprint loop of 256×256 transparent cells |
| `assets/enemies/zombie_dog/action_sheet.png` | Three-pose generation derived from the approved zombie dog identity anchor | User-approved; pounce, hurt, and defeated 256×256 transparent cells |
| `assets/enemies/zombie_nurse/idle.png` | Approved original Stage 2 support-enemy generation | User-approved; 256×256 transparent zombie nurse identity anchor with bandage-roll loadout |
| `assets/enemies/zombie_nurse/walk_sheet.png` | Six-frame generation derived from the approved zombie nurse identity anchor | User-approved corrected 3×2 shamble loop with distinct contact, down, and passing poses |
| `assets/enemies/zombie_nurse/action_sheet.png` | Four-pose generation derived from the approved zombie nurse identity anchor | User-approved; throw, ally-buff, hurt, and defeated 256×256 transparent cells |
| `assets/enemies/zombie_doctor/idle.png` | Approved original Stage 2 electric-controller generation | User-approved; 256×256 transparent zombie doctor identity anchor with portable defibrillator loadout |
| `assets/enemies/zombie_doctor/walk_sheet.png` | Six-frame generation derived from the approved zombie doctor identity anchor | User-approved normalized 3×2 burdened shamble loop with distinct contact, down, and passing poses |
| `assets/enemies/zombie_doctor/action_sheet.png` | Three-pose generation derived from the approved zombie doctor identity anchor | User-approved; zap, hurt, and defeated 256×256 transparent cells |
| `assets/enemies/wheelchair_zombie/idle.png` | Approved original Stage 2 armored-charger generation | User-approved; 256×256 transparent wheelchair-zombie identity anchor with forward shield plate |
| `assets/enemies/wheelchair_zombie/roll_sheet.png` | Corrected six-frame generation derived from the approved wheelchair-zombie identity anchor | User-approved normalized 3×2 rolling loop with wheel marker, suspension phases, and intact shield in every frame |
| `assets/enemies/wheelchair_zombie/action_sheet.png` | Four-pose generation derived from the approved wheelchair-zombie identity anchor | User-approved; charge, hurt, stunned, and safely defeated 256×256 transparent cells |
| `assets/bosses/stage2_chief_surgeon/idle.png` | Approved original Stage 2 boss generation | User-approved; normalized 512×512 transparent Undead Chief Surgeon identity anchor with operating-lamp/IV-stand heavy weapon |
| `assets/bosses/stage2_chief_surgeon/walk_sheet.png` | Four-frame generation derived from the approved Chief Surgeon identity anchor | User-approved normalized 2×2 heavy locomotion loop of 512×512 transparent cells |
| `assets/bosses/stage2_chief_surgeon/sweep_sheet.png` | Four-stage generation derived from the approved Chief Surgeon identity anchor | User-approved normalized 2×2 wind-up, early swing, active sweep, and recovery cells |
| `assets/bosses/stage2_chief_surgeon/slam_sheet.png` | Four-stage generation derived from the approved Chief Surgeon identity anchor | User-approved normalized 2×2 overhead wind-up, downward drive, impact, and recovery cells |
| `assets/bosses/stage2_chief_surgeon/reaction_sheet.png` | Four-pose generation derived from the approved Chief Surgeon identity anchor | User-approved normalized hurt, phase-two rage, stunned, and defeated 512×512 cells |
| `assets/hazards/stage2/rolling_equipment_sheet.png` | Project-specific hospital hazard generation derived from the approved Stage 2 palette | Art-production self-reviewed; four transparent 256×256 roll, pitch, bounce, and settle cells |
| `assets/vfx/stage2_hospital_effects.png` | Project-specific VFX generation derived from the approved Stage 2 hospital palette | Art-production self-reviewed; four independent transparent 256×256 electric-hit, bandage-buff, skid-dust, and lamp-impact cells |
| `assets/backgrounds/stage2/hospital_corridor.png` | Approved project-specific Stage 2 environment generation | User-approved; 960×540 opaque hospital corridor palette and lighting anchor |
| `assets/tilesets/stage2/hospital_ground_tiles.png` | Project-specific tile generation derived from the approved Stage 2 hospital direction | Art-production self-reviewed; basic, cracked, drain, and puddle variants in four aligned transparent 256×256 cells |

No production assets have been copied from `tea-line-bot` yet.
