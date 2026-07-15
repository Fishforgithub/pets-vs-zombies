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
| `assets/enemies/courier_zombie/action_sheet.png` | Approved three-cell courier zombie action sheet from `agent/art-production` commit `f6420cd`; cells normalized to the standard feet baseline | Integrated as `attack`, `hurt`, and delayed-removal `faint` states |
| `assets/backgrounds/stage1/city_far.png` | Approved stage-one city background from `agent/art-production` commit `01a0346` | Integrated as a repeating far-background layer with procedural fallback |
| `assets/tilesets/stage1/ground_tiles.png` | Approved four-cell street ground strip from `agent/art-production` commit `56fe0dc` | Integrated across the stage floor with procedural fallback |
| `assets/props/stage1/street_props.png` | Approved four-cell street prop sheet from `agent/art-production` commit `743c4bd` | Imported and available for stage-one scene dressing |
| `assets/props/stage1/crate_break_sheet.png` | Approved three-cell breakable crate sheet from `agent/art-production` commit `dfd5e70` | Imported and reserved for the breakable-prop system |
| `assets/items/pickups.png` | Approved four-cell gameplay pickup sheet from `agent/art-production` commit `accee79` | Imported and reserved for the pickup system |
| `assets/vfx/combat_effects.png` | Approved four-cell combat effect sheet from `agent/art-production` commit `956a2f9` | Imported and reserved for runtime combat effects |
| `assets/enemies/umbrella_zombie/idle.png` | Approved umbrella commuter zombie idle sprite from `agent/art-production` commit `cc2f4d7` | Imported and reserved for the next enemy variant |
| `assets/enemies/umbrella_zombie/walk_sheet.png` | Approved six-frame shield-walk sheet from `agent/art-production` commit `f940a94`; 3x2 cells at 256x256 | Imported and reserved for the umbrella zombie enemy scene |
| `assets/bosses/stage1_foreman/idle.png` | Approved Stage 1 boss identity anchor from `agent/art-production` commit `05449ea`; 512x512 with bottom-center pivot | Imported for the independently testable Undead Foreman boss scene |
| `assets/bosses/stage1_foreman/walk_sheet.png` | Approved four-frame heavy walk from `agent/art-production` commit `6ca9d39`; 2x2 cells at 512x512 | Imported for the Undead Foreman `walk` animation |
| `assets/bosses/stage1_foreman/sweep_sheet.png` | Approved four-frame sweep attack from `agent/art-production` commit `92a11e8`; 2x2 cells at 512x512 | Imported for the Undead Foreman `sweep` animation and frame-2 attack window |
| `assets/bosses/stage1_foreman/slam_sheet.png` | Approved four-frame ground slam from `agent/art-production` commit `5345238`; 2x2 cells at 512x512 | Imported for the Undead Foreman `slam` animation and frame-2 shockwave event |
| `assets/bosses/stage1_foreman/reaction_sheet.png` | Approved four-pose reaction sheet from `agent/art-production` commit `86fd34c`; 2x2 cells at 512x512 | Imported as `hurt`, `rage`, `stunned`, and `defeated` boss poses |

No production assets have been copied from `tea-line-bot` yet.

> Note: `agent/art-production` commit `2641241` was not integrated because `walk_sheet.png` is not a valid PNG blob. A fresh remote audit on 2026-07-15 confirmed the blob is still corrupt; the authoritative art branch retains it pending replacement.
