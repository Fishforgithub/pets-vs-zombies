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

- Release header: `2026-07-16.1`
- Cloudflare Worker Version ID: `e64950c0-2120-482a-9a11-6f60de1ca9a9`
- Verified on: 2026-07-16 (Asia/Taipei)
- Public checks: HTML, JavaScript, PCK, and WASM returned HTTP 200 with their expected MIME types.
- Exported PCK size: 1,535,124 bytes.
- WASM header: `00 61 73 6D 01 00 00 00`.
