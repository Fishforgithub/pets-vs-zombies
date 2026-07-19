# Art Production Status

Last updated: 2026-07-19 (Asia/Taipei)

Art branch: `agent/art-production`

This is the art-side session handoff. Codex implementation progress and gameplay planning documents on the implementation branch remain authoritative for code and design decisions.

## Current session status

Art production resumed on 2026-07-16. Character and creature images remain user-reviewed; ordinary environment, prop, VFX, and UI assets may be self-reviewed and delivered automatically.

Stage 1 now has an approved visual foundation:

- human girl identity and core movement/combat/damage poses
- courier zombie identity, walk, attack, hurt, and faint states
- umbrella commuter zombie identity and shield-walk cycle
- city background, four ground tiles, street props, and breakable-crate states
- four pickups and four combat effects
- Undead Foreman Stage 1 boss core visual state set
- runtime asset manifest and Codex-to-art request queue

Stage 2 hospital character production is underway:

- zombie crow identity, six-frame flight cycle, dive, hurt, and defeated states are delivered
- zombie dog identity, six-frame sprint cycle, pounce, hurt, and defeated states are delivered
- zombie nurse identity, corrected six-frame walk cycle, throw, ally-buff, hurt, and defeated states are delivered
- zombie doctor identity, six-frame walk cycle, zap, hurt, and defeated states are delivered
- wheelchair zombie identity, corrected six-frame roll cycle, charge, hurt, stunned, and defeated states are delivered
- Chief Surgeon core boss set is delivered: identity, heavy locomotion, horizontal sweep, overhead slam, hurt, phase-two rage, stunned, and defeated states
- phase-two rolling equipment cart hazard is delivered as a four-frame transparent travel loop
- hospital-specific electric-hit, bandage-buff, wheelchair-skid, and Chief Surgeon impact effects are delivered
- hospital corridor background direction is approved and delivered as the Stage 2 palette/lighting anchor
- repeatable hospital ground tiles are delivered in basic, cracked, drain, and puddle variants

## Stage 1 boss completion

The Undead Foreman core art set is complete for initial implementation:

| Asset | Runtime purpose |
|---|---|
| `assets/bosses/stage1_foreman/idle.png` | identity anchor and idle fallback |
| `assets/bosses/stage1_foreman/walk_sheet.png` | four-frame heavy walk |
| `assets/bosses/stage1_foreman/sweep_sheet.png` | wind-up, sweep, active hit, recovery |
| `assets/bosses/stage1_foreman/slam_sheet.png` | overhead wind-up, downward swing, impact, recovery |
| `assets/bosses/stage1_foreman/reaction_sheet.png` | hurt, rage transition, stunned, defeated |

The ground shockwave may initially use procedural movement plus an existing combat-effect sprite. A dedicated shockwave sheet is optional follow-up art, not a blocker for the first playable boss.

## Important recent art commits

| Commit | Contents |
|---|---|
| `f940a94` | umbrella zombie shield-walk plus manifest update |
| `05449ea` | Undead Foreman identity anchor plus boss integration rules |
| `6ca9d39` | Undead Foreman heavy walk |
| `92a11e8` | Undead Foreman horizontal sweep |
| `5345238` | Undead Foreman ground slam and `ART_REQUEST_QUEUE.md` protocol |
| `86fd34c` | Undead Foreman hurt, rage, stunned, and defeated states |

For complete asset paths, frame order, FPS, facing rules, pivots, collision guidance, and attack windows, read `docs/ART_ASSET_MANIFEST.md` rather than inferring behavior from filenames.

## Next-session priorities

1. Read any `ready` items added by Codex to `docs/ART_REQUEST_QUEUE.md`.
2. Verify that Codex has integrated or cherry-picked the latest art branch before changing paths or layouts.
3. Derive repeatable Stage 2 wall/door modules from the approved hospital environment direction.
4. Produce modular beds, carts, signs, and additional corridor hazards.
5. Begin UI production only from a committed request that specifies Godot consumers, dimensions, states, and NinePatch margins.
6. Keep all new character and creature image drafts out of Git until explicit user approval.

## Resume command for Codex

Before integrating art, Codex should fetch the art branch and read:

- `AGENTS.md`
- `docs/ART_ASSET_MANIFEST.md`
- `docs/ART_REQUEST_QUEUE.md`
- this status file

Never use force-push to combine implementation and art work. Merge the art branch or cherry-pick announced commits intentionally.
