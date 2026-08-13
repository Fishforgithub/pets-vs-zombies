# Stage 2 Art Plan — Abandoned Hospital

Status: the approved character, boss, environment, hazard, and VFX assets are integrated into an initial complete playable Stage 2 flow.

## Gameplay implementation

- Five escalating data-driven waves mix zombie crow, dog, nurse, doctor, and wheelchair enemies.
- Two animated electric puddles provide frame-gated environmental damage.
- The Undead Chief Surgeon enters after wave five with sweep, slam, phase-two acceleration, hospital impact VFX, and twin rolling-equipment hazards.
- Defeating the boss persists Stage 2 completion, unlocks the next route position, and opens the Stage 2 result/shop screen.
- The campaign route enables Stage 2 only after Stage 1 completion and keeps both completed stages replayable.

The approved zombie dog is now integrated as the Stage 2 fast low runner. It first appears in Wave 2 and returns in later mixed waves, creating a readable speed-and-height pressure pair with aerial crows and rear-line support enemies.

## Stage fantasy

The girl and her pet enter a colorful abandoned neighborhood hospital after crossing the Stage 1 city street. The hospital should feel eerie, energetic, and adventurous rather than graphic or traumatic. Use faded cream walls, cool mint tiles, muted turquoise equipment, warm amber emergency lighting, and restrained coral-red warning accents. No blood, gore, realistic medical trauma, logos, or readable institutional branding.

## Enemy roster and gameplay purpose

| Enemy | Role | Core visual/gameplay read |
|---|---|---|
| Zombie crow | Fragile aerial diver | Circles overhead, telegraphs with a wing tuck, then dives diagonally so the player must aim upward or reposition |
| Zombie dog | Fast low runner | Sprints below normal aim height and uses a short leap; readable crouch-before-pounce telegraph |
| Zombie nurse | Mid-range support | Tosses bundled bandage rolls and briefly buffs nearby zombies; bright uniform accents identify the support role |
| Zombie doctor | Rear-line electric controller | Uses a comical handheld defibrillator device for a short ranged zap and should be prioritized before common enemies |
| Wheelchair zombie | Armored charger | Runaway wheelchair charges in a straight line; front chair silhouette blocks weak shots while rear/body remains vulnerable |
| Chief surgeon boss | Stage boss | Exaggerated giant doctor wielding an operating-lamp-and-IV-stand improvised heavy weapon; phase attacks use sweep, slam, and rolling equipment hazards |

## Safety and tone

- All enemies are fictional adult cartoon zombies.
- No blood, exposed organs, realistic wounds, patient suffering, or identifiable real hospital branding. Restrained stylized exposed bone is allowed only for the already approved zombie-dog design; keep it dry, graphic, and non-gory.
- The wheelchair enemy is designed around runaway momentum and directional defense, not mockery of disability. Defeat leaves the character safely dazed with the chair intact or gently tipped.
- Medical props use abstract symbols only; runtime text and localization remain in Godot UI.

## Production order

1. Zombie crow identity, flight, dive, hurt, and defeat.
2. Zombie dog identity, run, pounce, hurt, and defeat.
3. Zombie nurse identity, walk, throw/buff, hurt, and defeat.
4. Zombie doctor identity, walk, electric attack, hurt, and defeat.
5. Wheelchair zombie identity, roll, charge, hurt/stun, and defeat.
6. Chief surgeon boss identity and full boss state set.
7. Hospital background layers, ground tiles, doors, beds, carts, signs, and hazards.
8. Stage 2 card art, boss HUD treatment, pickups, and hospital-specific VFX.

## Review policy

- Every character, pet, enemy, and boss identity or action sheet requires explicit user visual approval.
- Hospital environment, props, tiles, ordinary UI, and VFX may pass art-production self-review after the first major Stage 2 environment direction is approved.
- Approved assets must be processed, alpha-validated, recorded in `docs/ASSET_MIGRATION.md`, and wired in `docs/ART_ASSET_MANIFEST.md` before delivery.
