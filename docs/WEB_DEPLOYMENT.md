# Web Deployment

The browser build uses Godot's single-threaded Web export. The release is stored in OCI Object Storage and served through a Cloudflare Worker so the 37+ MiB Godot WebAssembly file is not constrained by Cloudflare Pages' 25 MiB single-file limit.

## Production endpoints

- Player URL: `https://pets-vs-zombies.fishzero002-games.workers.dev`
- OCI region: `ap-tokyo-1`
- OCI bucket: `pets-vs-zombies-web`
- Cloudflare Worker: `pets-vs-zombies`

No credentials are stored in this repository. Deployment uses the local `teabot-apikey` OCI CLI profile and the local Wrangler login.

## One-command publishing on Windows

Use the repository root in PowerShell. The default command runs all Godot and structural checks, builds the Web release, uploads every required game asset to OCI, publishes the Worker, then verifies the public HTML, WASM MIME type, and release header.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\publish-web.ps1
```

The script creates a time-based release identifier automatically. To use a specific release identifier, append `-ReleaseId 2026-08-14.1`.

| Workflow | Command | Effect |
|---|---|---|
| Recommended public release | `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\publish-web.ps1` | Runs checks, exports, uploads to OCI, deploys the Worker, and verifies the public site. |
| Safe build verification | `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\publish-web.ps1 -DryRun -SkipTests -ReleaseId local-check` | Exports and hashes the Web build only. It does not change OCI objects or the Cloudflare Worker. |

The publisher requires the existing local OCI CLI profile `teabot-apikey`, an authenticated Wrangler CLI session, and Node.js/npm. If Godot 4.7.1 is not available through `GODOT_PATH` or the `godot` command, the script downloads the official Windows build into the ignored `.tools` directory on its first run. Credentials and tokens are never stored in the script or repository.

The generated asset manifest is written to `build/web/release-manifest.json`. OCI uploads preserve explicit MIME types and use checksum verification; the Worker receives the release identifier through its `PVZ_RELEASE` deployment variable, so the public `X-PVZ-Release` header is updated automatically.

## Manual export fallback

Create `build/web` and run Godot 4.7.1 with:

```powershell
godot --headless --path . --export-release Web build/web/index.html
```

The output entry point must remain `index.html`. Keep `variant/thread_support=false` unless the Cloudflare Worker is also updated to return the required cross-origin isolation headers.

## Manual upload and publish fallback

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
