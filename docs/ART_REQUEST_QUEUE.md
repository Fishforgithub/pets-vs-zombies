# Art Request Queue

This queue is the engine-to-art handoff. Every request must follow `docs/ART_ASSET_MANIFEST.md` and be committed and pushed to GitHub before production begins.

Request IDs use `AR-YYYYMMDD-NNN`. Allowed states are `queued`, `approved`, `in-production`, `delivered`, `validated`, and `integrated`.

## Open requests

### AR-20260716-001 — Stage result panel

- Status: `queued`
- Screen use: Center frame behind the Stage 1 clear title, earned XP, earned gears, level summary, next-stage card, and retry control after the Foreman is defeated.
- Godot node: `NinePatchRect` at `StageResultScreen/Overlay/ResultPanel` in `game/ui/stage_result.tscn`.
- Output path: `res://assets/ui/stage_result_panel.png`.
- Pixel dimensions: 384 x 256 pixels.
- Grid / slicing: 1 x 1 static panel; no animation frames. Preserve a clean center region for runtime labels and controls.
- Interaction states: none; all text, buttons, rewards, and focus states remain Godot `Control` nodes layered above it.
- Nine-patch borders: left 32 px, top 32 px, right 32 px, bottom 32 px. Corners and border ornaments must stay outside the stretchable center.
- Acceptance criteria:
  - File decodes as a valid lossless 384 x 256 PNG with transparency outside the panel silhouette.
  - Crisp pixel-art edges, limited palette, and visual language match the Stage 1 city assets and existing character art.
  - The 32 px borders remain visually intact when the node scales from 576 x 384 through 768 x 512.
  - The center has enough contrast and uncluttered space for white/yellow runtime text at 18–34 px font sizes.
  - No baked text, numbers, reward values, button labels, or copyrighted marks.
  - Pixel-art filtering and mipmaps can remain disabled without seams.

### AR-20260716-002 — Next-stage card states

- Status: `queued`
- Screen use: Fixed-size route card on the Stage 1 result screen; initially shows Stage 2 as locked/coming soon and later supports selection from the campaign route.
- Godot node: `TextureButton` at `StageResultScreen/Overlay/ResultPanel/NextStageCard` in `game/ui/stage_result.tscn`, with runtime labels and stage illustration layered separately.
- Output path: `res://assets/ui/stage_card_frames.png`.
- Pixel dimensions: 960 x 256 pixels total; five 192 x 256 cells.
- Grid / slicing: 5 x 1, each cell 192 x 256. Left-to-right order: `normal`, `hover`, `pressed`, `selected`, `locked`.
- Interaction states: normal, hover, pressed, selected, locked. Locked must remain readable without relying only on color and must not contain baked text.
- Nine-patch borders: N/A — non-resizable fixed-size card frame; runtime may apply only integer-safe uniform scaling.
- Acceptance criteria:
  - File decodes as a valid lossless 960 x 256 PNG with five cells exactly once in the documented order.
  - Every cell keeps identical outer bounds, content opening, and alignment so state changes do not jump.
  - Locked state has a distinct silhouette treatment or lock emblem and remains distinguishable for color-vision differences.
  - Center opening safely supports a separate 160 x 112 illustration plus runtime stage name, status, and reward labels.
  - No baked stage names, localized text, prices, or reward numbers.
  - Unused pixels are transparent; filtering and mipmaps can remain disabled without seams.

## Request template

### AR-YYYYMMDD-NNN — Short name

- Status: `queued`
- Screen use: Where and why the asset appears on screen.
- Godot node: Exact intended node type and owning scene, for example `NinePatchRect` in `game/ui/stage_result.tscn`.
- Output path: Exact production path, for example `res://assets/ui/stage_result_panel.png`.
- Pixel dimensions: Final canvas width and height in pixels.
- Grid / slicing: Columns, rows, cell dimensions, frame order, and animation names. Use `1 x 1` for a static image.
- Interaction states: Required states such as normal, hover, pressed, disabled, hit, breaking, or selected. Use `none` when the asset is not interactive.
- Nine-patch borders: Left, top, right, and bottom inset in pixels. Use `N/A — non-resizable sprite` when nine-patch scaling is forbidden.
- Acceptance criteria:
  - File decodes as a valid lossless PNG with the documented dimensions.
  - Alpha, facing direction, pivot, palette, and frame order match `ART_ASSET_MANIFEST.md`.
  - All requested cells and interaction states are present exactly once.
  - Unused cells are transparent.
  - Pixel-art filtering and mipmaps can remain disabled without visual seams.
  - The asset works at its documented Godot scale and node type.

## Completed requests

Move a request here only after the delivered file is validated and integrated. Record the delivery commit SHA and engine integration commit SHA.

## UI-specific rules

- Build layout, text, prices, localization, timers, and dynamic values with Godot `Control` nodes. Do not bake them into generated images.
- Request reusable components instead of one flattened screenshot: panels, NinePatch frames, icons, button states, tabs, badges, card art, and decorative overlays.
- Every interactive element must list all required states. If hover does not apply to the first target platform, say so explicitly.
- NinePatch requests must specify safe stretch regions and content padding.
- Card systems must distinguish background frame, illustration, rarity/state treatment, and runtime text layers.
- Skill icons must remain readable at the smallest intended in-game size and include locked/cooldown treatment requirements.

## Review policy

- Always require explicit user visual approval for human characters, pets, common enemies, bosses, portraits that depict them, and any asset that changes an established character identity.
- Art production may self-review and automatically deliver ordinary environments, tiles, props, pickups, VFX, and functional UI components when they follow the approved style and request specification.
- Escalate any asset for explicit user review when it changes the core visual identity, introduces a major new style direction, depicts paid-purchase/monetization UI, or has ambiguous gameplay meaning.
- Self-reviewed delivery still requires dimension, alpha, slicing, palette, manifest, and repository validation.

## Agent handoff procedure

1. The implementation agent creates or updates a request and marks it `queued`.
2. Commit and push the request; report the branch and commit SHA to the user for relay to art production.
3. Art production marks the request `in-production` and produces a review image.
4. Character or creature imagery pauses for explicit user review; eligible environment, prop, VFX, and ordinary UI work may pass art-production self-review.
5. Delivery updates `docs/ART_ASSET_MANIFEST.md`, `docs/ASSET_MIGRATION.md`, and the request with the art commit SHA.
