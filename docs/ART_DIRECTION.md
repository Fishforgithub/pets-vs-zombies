# Art Direction

## Shared universe

The game extends the art language of `Fishforgithub/tea-line-bot`:

- retro 8-bit to 16-bit pixel art
- crisp hard pixel edges and no smoothing
- compact chibi silhouettes
- bright limited palettes with readable contrast
- characters authored facing right; left-facing variants may be mirrored at runtime
- transparent character sprites with consistent feet baselines

## New human protagonist

The girl must look original and belong beside the existing pets:

- small chibi body with a large readable head
- practical adventure clothing rather than military branding
- clear side-view silhouette at gameplay scale
- weapon kept on a separate layer where feasible
- age presentation must remain wholesome and non-sexualized

## Animation strategy

- Use frame animation for identity-defining body motion.
- Use Godot tweens for recoil, hit-stop, UI, and small offsets.
- Use shaders for flash, damage tint, and dissolve effects.
- Use particles or short FX sheets for muzzle flash, sparks, smoke, and explosions.
- Never generate every motion as unrelated still images; anchor all actions to an approved idle reference.

## Placeholder policy

The graybox draws simple pixel blocks in code. Placeholder colors and proportions are not final art and may be replaced without changing gameplay scripts.

