# Stage 1 Delivery Plan

Updated: 2026-07-16

## Definition of done

Stage 1 is complete when the player can finish five escalating waves, defeat the Undead Foreman boss, receive experience and currency, see a stage-clear result, and reach a next-stage card placeholder. Losing all health must still allow an immediate retry.

## Current implementation

- [x] Player movement, jump, crouch, fire, reload, damage, and death.
- [x] Production girl animations and crouch collision switching.
- [x] Pet follow and automatic attack.
- [x] Courier zombie pursuit, contact attack, damage, and death.
- [x] Stage 1 background and ground art with procedural fallbacks.
- [x] HUD health, ammunition, result message, and simple objective count.
- [x] Godot gameplay, animation, and crouch smoke tests.
- [x] Godot Web export and OCI/Cloudflare deployment.
- [x] Integrate the complete remote Foreman art set through `86fd34c`.
- [x] Replace the truncated courier walk sheet with the valid `8912004` delivery.
- [x] Replace fixed five-enemy spawning with a five-wave director.
- [x] Add wave HUD, inter-wave transitions, and configurable spawn pacing.
- [x] Add a separately testable Foreman boss scene, boss health bar, and sweep attack.
- [ ] Add enemy XP/currency rewards and player progression state.
- [ ] Add weapon and pet-skill upgrade data models.
- [ ] Add Stage 1 reward result and next-stage card placeholder.
- [ ] Re-run all checks, export Web release, deploy, and verify the public URL.

## Default wave tuning

| Wave | Total enemies | Spawn behavior |
|---|---:|---|
| 1 | 3 | One side, generous interval |
| 2 | 4 | One side, shorter interval |
| 3 | 5 | Alternate left and right |
| 4 | 6 | Higher alive cap |
| 5 | 8 | Short interval and highest alive cap |

These are data values, not hard-coded branches. They may be tuned without changing enemy scenes.

## Planned commit stages

1. `art: integrate Stage 1 Foreman assets`
2. `gameplay: add five-wave Stage 1 director`
3. `gameplay: add Undead Foreman boss encounter`
4. `progression: add combat rewards and upgrade foundations`
5. `ui: add Stage 1 results and next-stage card`
6. `deploy: publish completed Stage 1 Web build`

## Asset status

Stage 1 has all production art required for the five courier waves and the initial Undead Foreman implementation. Optional UI decoration and a dedicated boss shockwave sheet do not block the playable milestone.
