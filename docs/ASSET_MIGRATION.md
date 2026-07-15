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

No production assets have been copied from `tea-line-bot` yet.
