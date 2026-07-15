# Art Request Queue

This queue is the engine-to-art handoff. Every request must follow `docs/ART_ASSET_MANIFEST.md` and be committed and pushed to GitHub before production begins.

Request IDs use `AR-YYYYMMDD-NNN`. Allowed states are `queued`, `approved`, `in-production`, `delivered`, `validated`, and `integrated`.

## Open requests

No open requests. Stage 1 currently has sufficient approved art for engine implementation.

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
