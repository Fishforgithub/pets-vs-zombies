# Web Deployment

The browser build uses Godot's single-threaded Web export. The release is stored in OCI Object Storage and served through a Cloudflare Worker so the 37+ MiB Godot WebAssembly file is not constrained by Cloudflare Pages' 25 MiB single-file limit.

## Production endpoints

- Player URL: `https://pets-vs-zombies.fishzero002-games.workers.dev`
- OCI region: `ap-tokyo-1`
- OCI bucket: `pets-vs-zombies-web`
- Cloudflare Worker: `pets-vs-zombies`

No credentials are stored in this repository. Deployment uses the local `teabot-apikey` OCI CLI profile and the local Wrangler login.

## Export

Create `build/web` and run Godot 4.7.1 with:

```powershell
godot --headless --path . --export-release Web build/web/index.html
```

The output entry point must remain `index.html`. Keep `variant/thread_support=false` unless the Cloudflare Worker is also updated to return the required cross-origin isolation headers.

## Upload and publish

Upload every file under `build/web` to the `pets-vs-zombies-web` OCI bucket with its original filename. Preserve these MIME types:

| Extension | Content-Type |
|---|---|
| `.html` | `text/html; charset=utf-8` |
| `.js` | `text/javascript; charset=utf-8` |
| `.wasm` | `application/wasm` |
| `.pck` | `application/octet-stream` |
| `.png` | `image/png` |

Publish the proxy after the OCI upload completes:

```powershell
wrangler deploy
```

The Worker maps `/` to OCI's `index.html`, serves all game files from the same public origin, and applies explicit content types and cache headers.

## Latest verified release

| Item | Verified value |
|---|---|
| Release header | `2026-08-13.1` |
| Source commit | `8054cc9` on `agent/stage2-completion` |
| Cloudflare Worker Version ID | `6aedbfc0-c838-40d3-8103-7c95713b3079` |
| Verified on | 2026-08-13 (Asia/Taipei) |
| Public checks | The campaign map and Stage 1 launch returned successfully from the player URL; HTML returned HTTP 200 with `text/html; charset=utf-8` and WASM returned HTTP 200 with `application/wasm`. |
| Exported PCK size | 6,490,132 bytes |
| Exported WASM size | 39,513,091 bytes |
