# Art Request Queue

Use this file to hand implementation-driven art requirements from the Godot/Codex branch to `agent/art-production`. Do not add a request until the gameplay purpose and runtime states are understood.

## Status vocabulary

- `draft`: gameplay/UI design is still changing.
- `ready`: sufficiently specified for art production.
- `generating`: art production has accepted the request.
- `review`: an image is waiting for user approval.
- `approved`: user approved the design; processing/commit may proceed.
- `delivered`: processed asset and manifest entry are committed.
- `blocked`: a named decision or reference is missing.

## Request template

Copy this block for each request. Keep one stable request ID for all revisions.

```md
### ART-000 — Short name

- Status: ready
- Feature/scene: shop, skills, stage select, HUD, character, enemy, boss, environment, or VFX
- Gameplay purpose: what the player does and why the image is required
- Godot consumer: intended scene and node type, for example `ShopScreen/Panel` (`NinePatchRect`)
- Deliverable path: proposed `assets/...` repository path
- Asset type: sprite, sheet, icon, tile set, background, portrait, panel, or NinePatch
- Pixel dimensions: source width × height and per-cell size
- Layout/order: columns × rows and exact state/frame order
- Runtime states: normal, hover, pressed, disabled, selected, locked, cooldown, etc.
- Facing/pivot/baseline: required direction and alignment behavior
- NinePatch margins: left/top/right/bottom pixels, or `not applicable`
- Text policy: normally `no baked text`; list unavoidable symbols only
- Style references: existing approved repository paths to match
- Interaction/collision notes: hitboxes, clickable bounds, animation triggers, or none
- Acceptance criteria: objective checks that define success
- Open decisions: `none` or a short explicit list
```

## UI-specific rules

- Build layout, text, prices, localization, timers, and dynamic values with Godot `Control` nodes. Do not bake them into generated images.
- Request reusable components instead of one flattened screenshot: panels, NinePatch frames, icons, button states, tabs, badges, card art, and decorative overlays.
- Every interactive element must list all required states. If hover does not apply to the first target platform, say so explicitly.
- NinePatch requests must specify safe stretch regions and content padding.
- Card systems must distinguish background frame, illustration, rarity/state treatment, and runtime text layers.
- Skill icons must remain readable at the smallest intended in-game size and include locked/cooldown treatment requirements.

## Agent handoff procedure

1. The implementation agent creates or updates a request and marks it `ready`.
2. Commit and push the request; report the branch and commit SHA to the art-production conversation.
3. Art production reads the request, marks it `generating`, and produces a review image.
4. Only explicit user approval permits processing and repository delivery.
5. Delivery updates `docs/ART_ASSET_MANIFEST.md`, `docs/ASSET_MIGRATION.md`, and this request to `delivered` with the art commit SHA.

## Active requests

No implementation-authored UI requests are queued yet.
