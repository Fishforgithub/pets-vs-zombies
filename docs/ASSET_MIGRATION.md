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
| `assets/characters/girl/girl_crouch.png` | Approved project-specific generation derived from the girl identity anchor | Approved; 256×256 transparent crouch pose |
| `assets/characters/girl/girl_combat_sheet.png` | Approved project-specific generation derived from the girl identity anchor | Approved; two 256×256 cells for fire and reload |
| `assets/characters/girl/girl_damage_sheet.png` | Approved project-specific generation derived from the girl identity anchor | Approved; two 256×256 cells for hurt and faint |
| `assets/enemies/courier_zombie/idle.png` | Approved original project-specific enemy generation | Approved; 256×256 transparent identity anchor |
| `assets/enemies/courier_zombie/walk_sheet.png` | Six-frame generation derived from the courier zombie identity anchor | Approved; 3×2 sheet of 256×256 cells |
| `assets/enemies/courier_zombie/action_sheet.png` | Three-pose generation derived from the courier zombie identity anchor | Approved; attack, hurt, and faint |
| `assets/enemies/umbrella_zombie/idle.png` | Approved original project-specific shield-enemy generation | Approved; 256×256 transparent identity anchor |
| `assets/enemies/umbrella_zombie/walk_sheet.png` | Six-frame generation derived from the umbrella zombie identity anchor | Approved; 3×2 shield-walk sheet of 256×256 cells |
| `assets/enemies/umbrella_zombie/action_sheet.png` | Three-pose generation derived from the umbrella zombie identity anchor | User-approved; attack, hurt, and defeated 256×256 cells |
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
| `assets/enemies/zombie_doctor/walk_sheet.png` | Six-frame generation derived from the approved zombie doctor identity anchor | User-approved; normalized 3×2 burdened shamble loop with distinct contact, down, and passing poses |
| `assets/enemies/zombie_doctor/action_sheet.png` | Three-pose generation derived from the approved zombie doctor identity anchor | User-approved; zap, hurt, and defeated 256×256 transparent cells |
| `assets/enemies/wheelchair_zombie/idle.png` | Approved original Stage 2 armored-charger generation | User-approved; 256×256 transparent wheelchair-zombie identity anchor with forward shield plate |
| `assets/enemies/wheelchair_zombie/roll_sheet.png` | Corrected six-frame generation derived from the approved wheelchair-zombie identity anchor | User-approved; normalized 3×2 rolling loop with wheel marker, suspension phases, and intact shield in every frame |
| `assets/enemies/wheelchair_zombie/action_sheet.png` | Four-pose generation derived from the approved wheelchair-zombie identity anchor | User-approved; charge, hurt, stunned, and safely defeated 256×256 transparent cells |
| `assets/bosses/stage2_chief_surgeon/idle.png` | Approved original Stage 2 boss generation | User-approved; normalized 512×512 transparent Undead Chief Surgeon identity anchor with operating-lamp/IV-stand heavy weapon |
| `assets/bosses/stage2_chief_surgeon/walk_sheet.png` | Four-frame generation derived from the approved Chief Surgeon identity anchor | User-approved; normalized 2×2 heavy locomotion loop of 512×512 transparent cells |
| `assets/bosses/stage2_chief_surgeon/sweep_sheet.png` | Four-stage generation derived from the approved Chief Surgeon identity anchor | User-approved; normalized 2×2 wind-up, early swing, active sweep, and recovery cells |
| `assets/bosses/stage2_chief_surgeon/slam_sheet.png` | Four-stage generation derived from the approved Chief Surgeon identity anchor | User-approved; normalized 2×2 overhead wind-up, downward drive, impact, and recovery cells |
| `assets/bosses/stage2_chief_surgeon/reaction_sheet.png` | Four-pose generation derived from the approved Chief Surgeon identity anchor | User-approved; normalized hurt, phase-two rage, stunned, and defeated 512×512 cells |
| `assets/hazards/stage2/rolling_equipment_sheet.png` | Project-specific hospital hazard generation derived from the approved Stage 2 palette | Art-production self-reviewed; four transparent 256×256 roll, pitch, bounce, and settle cells |
| `assets/backgrounds/stage2/hospital_corridor.png` | Approved project-specific Stage 2 environment generation | User-approved; 960×540 opaque hospital corridor palette and lighting anchor |
| `assets/backgrounds/stage2/hospital_wall_modules.png` | Project-specific module generation derived from the approved Stage 2 hospital direction | Art-production self-reviewed; intact wall, closed door, open doorway, and cracked-window modules in four transparent 256×256 cells |
| `assets/tilesets/stage2/hospital_ground_tiles.png` | Project-specific tile generation derived from the approved Stage 2 hospital direction | Art-production self-reviewed; basic, cracked, drain, and puddle variants in four aligned transparent 256×256 cells |
| `assets/props/stage2/hospital_props.png` | Project-specific prop generation derived from the approved Stage 2 hospital direction | Art-production self-reviewed; empty gurney, IV stand, supply cabinet, and tipped paired chair in four transparent 256×256 cells at shared scale |
| `assets/bosses/stage1_foreman/idle.png` | Approved original Stage 1 boss generation | Approved; 512×512 transparent Undead Foreman identity anchor |
| `assets/bosses/stage1_foreman/walk_sheet.png` | Four-frame generation derived from the Undead Foreman identity anchor | Approved; 2×2 heavy-walk sheet of 512×512 cells |
| `assets/bosses/stage1_foreman/sweep_sheet.png` | Four-frame generation derived from the Undead Foreman identity anchor | Approved; 2×2 horizontal-sweep sheet of 512×512 cells |
| `assets/bosses/stage1_foreman/slam_sheet.png` | Four-frame generation derived from the Undead Foreman identity anchor | Approved; 2×2 ground-slam sheet of 512×512 cells |
| `assets/bosses/stage1_foreman/reaction_sheet.png` | Four-pose generation derived from the Undead Foreman identity anchor | Approved; 2×2 hurt, rage, stunned, and defeated state sheet |
| `assets/backgrounds/stage1/city_far.png` | Approved original project-specific Stage 1 background generation | Approved; 960×540 indexed-color opaque background |
| `assets/tilesets/stage1/ground_tiles.png` | Approved original project-specific Stage 1 tile generation | Approved; four transparent 256×256 ground cells |
| `assets/props/stage1/street_props.png` | Approved original project-specific Stage 1 prop generation | Approved; crate, cone, bags, and hydrant |
| `assets/props/stage1/crate_break_sheet.png` | Approved generation derived from the Stage 1 crate | Approved; three 256×256 break states |
| `assets/items/pickups.png` | Approved original project-specific pickup generation | Approved; four 256×256 pickup cells |
| `assets/vfx/combat_effects.png` | Approved original project-specific VFX generation | Approved; four 256×256 single-frame effects |
| `assets/vfx/foreman_shockwave.png` | Project-specific VFX generation derived from the approved Foreman slam impact palette | Art-production self-reviewed; four transparent 256×256 shockwave frames |
| `assets/vfx/stage2_hospital_effects.png` | Project-specific VFX generation derived from the approved Stage 2 hospital palette | Art-production self-reviewed; four independent transparent 256×256 electric-hit, bandage-buff, skid-dust, and lamp-impact cells |
| `assets/ui/stage1/boss_health_frame.png` | Project-specific UI generation derived from the approved Stage 1 construction palette | Art-production self-reviewed; 640×96 transparent fixed overlay frame |

No production assets have been copied from `tea-line-bot` yet.
