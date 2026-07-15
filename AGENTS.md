# Pets vs Zombies — Agent Guide

## Goal

Build an original 2D side-scrolling run-and-gun game in Godot 4. The player controls a human girl while an autonomous pet companion follows and assists her.

## Product rules

- Keep the visual language compatible with the existing `Fishforgithub/tea-line-bot` pet universe.
- Art direction is crisp 8-bit to 16-bit pixel art with limited palettes and hard edges.
- Existing pet identities must not drift. Their authoritative source remains the `tea-line-bot` repository.
- Do not copy Metal Slug characters, names, stages, audio, or artwork. Only the broad run-and-gun genre is a reference.
- The LIFF repository is a read-only source. Never modify it as part of this project.
- Windows desktop is the first target. Keep mobile and controller support possible without implementing them prematurely.

## Engineering rules

- Use Godot 4 and typed GDScript where practical.
- Keep gameplay code under `game/` and imported production assets under `assets/`.
- Use signals for cross-system events; avoid hard-coded scene-tree paths across unrelated systems.
- Player, pet, enemies, projectiles, and UI must remain independently testable scenes.
- The game must remain playable with procedural placeholder art when production art is absent.
- New production dependencies require an explanation in the PR.

## Verification

Before considering work complete:

1. Run Godot headless project import/check when Godot is available.
2. Confirm `project.godot` points to a valid main scene.
3. Confirm no source API keys or LIFF secrets are committed.
4. Confirm all imported source assets are recorded in `docs/ASSET_MIGRATION.md`.
5. Manually verify movement, jump, firing, pet follow, pet auto-attack, damage, death, and stage completion.

