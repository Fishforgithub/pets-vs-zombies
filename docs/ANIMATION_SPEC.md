# Animation State Vocabulary

## Human girl

`idle`, `run`, `jump`, `fall`, `crouch`, `fire`, `reload`, `hurt`, `faint`

## Pet

`idle`, `run`, `attack`, `hurt`, `faint`, `skill`

## Zombie

`idle`, `walk`, `attack`, `hurt`, `faint`

## Runtime-only effects

These should usually remain procedural and not require full character frames:

- recoil
- screen shake
- hit flash
- damage numbers
- spawn fade
- knockback
- muzzle flash
- projectile trails

## Frame requirements

- All frames in one action share canvas size and pivot.
- Feet baseline remains stable except during airborne actions.
- Character occupies no more than 85% of the frame.
- Right-facing frames are authoritative; left-facing display uses horizontal flip unless asymmetry requires dedicated art.
- Default playback target is 8–12 FPS, adjusted per action.

