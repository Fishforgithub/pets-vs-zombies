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

## Review policy

- Always require explicit user visual approval for human characters, pets, common enemies, bosses, portraits that depict them, and any asset that changes an established character identity.
- Art production may self-review and automatically deliver ordinary environments, tiles, props, pickups, VFX, and functional UI components when they follow the approved style and request specification.
- Escalate any asset for explicit user review when it changes the core visual identity, introduces a major new style direction, depicts paid-purchase/monetization UI, or has ambiguous gameplay meaning.
- Self-reviewed delivery still requires dimension, alpha, slicing, palette, manifest, and repository validation. Automatic approval does not lower technical quality requirements.

## Agent handoff procedure

1. The implementation agent creates or updates a request and marks it `ready`.
2. Commit and push the request; report the branch and commit SHA to the art-production conversation.
3. Art production reads the request, marks it `generating`, and produces the requested asset.
4. Character/creature imagery pauses for explicit user review; eligible environment, prop, VFX, and ordinary UI work may pass art-production self-review.
5. Delivery updates `docs/ART_ASSET_MANIFEST.md`, `docs/ASSET_MIGRATION.md`, and this request to `delivered` with the art commit SHA.

## Active requests

### AR-20260716-001 — Stage result panel

- Status: ready
- Godot consumer: `StageResultScreen/Overlay/ResultPanel` (`NinePatchRect`)
- Deliverable path: `assets/ui/stage_result_panel.png`
- Pixel dimensions: 384 x 256
- NinePatch margins: 32 px on every side
- Text policy: no baked text, values, rewards, or controls

### AR-20260716-002 — Next-stage card states

- Status: ready
- Godot consumer: `StageResultScreen/Overlay/ResultPanel/NextStageCard` (`TextureButton`)
- Deliverable path: `assets/ui/stage_card_frames.png`
- Pixel dimensions: 960 x 256; five 192 x 256 cells
- Layout/order: normal, hover, pressed, selected, locked
- Text policy: no baked stage names, status, or rewards

### AR-20260716-003 — Upgrade shop card panel

- Status: ready
- Godot consumer: weapon and pet upgrade `NinePatchRect` panels
- Deliverable path: `assets/ui/upgrade_card_panel.png`
- Pixel dimensions: 192 x 192
- NinePatch margins: 24 px on every side
- Text policy: neutral reusable frame with no category, price, level, or statistics baked in

### AR-20260716-004 — Upgrade button states

- Status: ready
- Godot consumer: weapon and pet upgrade button `StyleBoxTexture` states
- Deliverable path: `assets/ui/upgrade_button_states.png`
- Pixel dimensions: 768 x 48; four 192 x 48 cells
- Layout/order: normal, hover/focus, pressed, disabled
- NinePatch margins: 12 px on every side of each cell
- Text policy: no baked label, value, or currency

## Delivered engine repair requests

### AR-20260716-005 — Normalize Foreman animation cells

- Status: delivered
- Deliverables: `assets/bosses/stage1_foreman/walk_sheet.png`, `sweep_sheet.png`, `slam_sheet.png`, and `reaction_sheet.png`
- Result: user-approved; global 86% scale, shared bottom-center baseline, detached adjacent-cell fragments removed, and safe transparent margins in every 512 x 512 cell
- Delivery commit: the art-branch commit containing this queue update

### AR-20260719-006 — Normalize zombie dog run cells

- Status: delivered
- Deliverable: `assets/enemies/zombie_dog/run_sheet.png`
- Result: user-approved; six-frame order preserved, shared bottom-center baseline, frame-boundary fragments removed, and at least 12 px transparent margins in every 256 x 256 cell
- Delivery commit: the art-branch commit containing this queue update
