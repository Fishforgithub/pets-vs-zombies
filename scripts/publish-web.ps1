[CmdletBinding()]
param(
    [string]$OciProfile = "teabot-apikey",
    [string]$BucketName = "pets-vs-zombies-web",
    [string]$WorkerConfig = "wrangler.jsonc",
    [string]$PublicUrl = "https://pets-vs-zombies.fishzero002-games.workers.dev",
    [string]$GodotPath = $env:GODOT_PATH,
    [string]$ReleaseId = (Get-Date -Format "yyyy-MM-dd.HHmm"),
    [switch]$DryRun,
    [switch]$SkipTests,
    [switch]$SkipPublicCheck
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$BuildDirectory = Join-Path $ProjectRoot "build\web"
$WorkerConfigPath = Join-Path $ProjectRoot $WorkerConfig
$RequiredAssets = @(
    @{ Name = "index.html"; ContentType = "text/html; charset=utf-8" },
    @{ Name = "index.js"; ContentType = "text/javascript; charset=utf-8" },
    @{ Name = "index.wasm"; ContentType = "application/wasm" },
    @{ Name = "index.pck"; ContentType = "application/octet-stream" },
    @{ Name = "index.png"; ContentType = "image/png" },
    @{ Name = "index.icon.png"; ContentType = "image/png" },
    @{ Name = "index.apple-touch-icon.png"; ContentType = "image/png" },
    @{ Name = "index.audio.worklet.js"; ContentType = "text/javascript; charset=utf-8" },
    @{ Name = "index.audio.position.worklet.js"; ContentType = "text/javascript; charset=utf-8" }
)

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Assert-LastExitCode {
    param([string]$Operation)
    if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
        throw "$Operation failed with exit code $LASTEXITCODE."
    }
}

function Require-Command {
    param([string]$Name)
    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        throw "Required command '$Name' was not found on PATH."
    }
    return $command.Source
}

function Resolve-GodotExecutable {
    param([string]$RequestedPath)
    $toolsDirectory = Join-Path $ProjectRoot ".tools"
    $projectLocalGodot = Join-Path $toolsDirectory "Godot_v4.7.1-stable_win64.exe"
    $candidates = @($RequestedPath, $env:GODOT_PATH, $projectLocalGodot) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $pathGodot = Get-Command "godot" -ErrorAction SilentlyContinue
    if ($null -ne $pathGodot) {
        return $pathGodot.Source
    }

    Write-Step "Downloading the official Godot 4.7.1 Windows build (one-time setup)"
    New-Item -ItemType Directory -Path $toolsDirectory -Force | Out-Null
    $archivePath = Join-Path $toolsDirectory "Godot_v4.7.1-stable_win64.exe.zip"
    $downloadUrl = "https://github.com/godotengine/godot-builds/releases/download/4.7.1-stable/Godot_v4.7.1-stable_win64.exe.zip"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -UseBasicParsing
    Expand-Archive -LiteralPath $archivePath -DestinationPath $toolsDirectory -Force
    Remove-Item -LiteralPath $archivePath -Force
    if (-not (Test-Path -LiteralPath $projectLocalGodot -PathType Leaf)) {
        throw "The Godot archive did not contain the expected executable: $projectLocalGodot"
    }
    return (Resolve-Path -LiteralPath $projectLocalGodot).Path
}

function Invoke-Godot {
    param([string]$Executable, [string[]]$Arguments, [string]$Operation)
    $global:LASTEXITCODE = 0
    & $Executable @Arguments
    Assert-LastExitCode $Operation
}

function Invoke-Oci {
    param([string[]]$Arguments, [string]$Operation)
    $global:LASTEXITCODE = 0
    & oci @Arguments
    Assert-LastExitCode $Operation
}

function Invoke-Wrangler {
    param([string[]]$Arguments, [string]$Operation)
    $global:LASTEXITCODE = 0
    & wrangler @Arguments
    Assert-LastExitCode $Operation
}

function Get-ResponseHeaderValue {
    param($Response, [string]$HeaderName)
    $value = $Response.Headers[$HeaderName]
    if ($value -is [System.Array]) {
        return $value[0]
    }
    return [string]$value
}

function Wait-ForWebExportAssets {
    param([string]$Directory, [array]$Assets, [int]$TimeoutSeconds = 20)
    for ($elapsed = 0; $elapsed -lt $TimeoutSeconds; $elapsed++) {
        $missing = @($Assets | Where-Object { -not (Test-Path -LiteralPath (Join-Path $Directory $_.Name) -PathType Leaf) })
        if ($missing.Count -eq 0) {
            return
        }
        Start-Sleep -Seconds 1
    }
    $missingNames = ($Assets | Where-Object { -not (Test-Path -LiteralPath (Join-Path $Directory $_.Name) -PathType Leaf) } | ForEach-Object Name) -join ", "
    throw "Godot Web export did not produce the required assets within $TimeoutSeconds seconds: $missingNames"
}

Push-Location $ProjectRoot
try {
    Write-Step "Checking local prerequisites"
    $godot = Resolve-GodotExecutable $GodotPath
    [void](Require-Command "oci")
    [void](Require-Command "wrangler")
    [void](Require-Command "npm")
    if (-not (Test-Path -LiteralPath $WorkerConfigPath -PathType Leaf)) {
        throw "Worker config not found: $WorkerConfigPath"
    }
    $sourceCommit = (& git rev-parse --short HEAD).Trim()
    Assert-LastExitCode "Reading the source commit"
    Write-Host "Release: $ReleaseId"
    Write-Host "Source commit: $sourceCommit"
    Write-Host "Godot: $godot"

    if (-not $SkipTests) {
        Write-Step "Running project checks"
        Invoke-Godot $godot @("--headless", "--editor", "--path", $ProjectRoot, "--quit") "Godot project import"
        $testFiles = Get-ChildItem (Join-Path $ProjectRoot "tests\*.gd") | Sort-Object Name
        foreach ($testFile in $testFiles) {
            Write-Host "Testing $($testFile.Name)"
            Invoke-Godot $godot @("--headless", "--path", $ProjectRoot, "--script", $testFile.FullName) "Godot test $($testFile.Name)"
        }
        & npm test
        Assert-LastExitCode "Project structure test"
    }

    Write-Step "Building the Godot Web release"
    Remove-Item -LiteralPath $BuildDirectory -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $BuildDirectory -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $ProjectRoot "build\.gdignore") -Value "Generated Web output is not a Godot source asset." -Encoding utf8
    Invoke-Godot $godot @("--headless", "--path", $ProjectRoot, "--export-release", "Web", (Join-Path $BuildDirectory "index.html")) "Godot Web export"

    Wait-ForWebExportAssets -Directory $BuildDirectory -Assets $RequiredAssets

    $manifest = [ordered]@{
        release = $ReleaseId
        source_commit = $sourceCommit
        generated_at_utc = (Get-Date).ToUniversalTime().ToString("o")
        files = @(
            foreach ($asset in $RequiredAssets) {
                $assetPath = Join-Path $BuildDirectory $asset.Name
                $hash = Get-FileHash -LiteralPath $assetPath -Algorithm SHA256
                [ordered]@{ name = $asset.Name; bytes = (Get-Item -LiteralPath $assetPath).Length; sha256 = $hash.Hash.ToLowerInvariant() }
            }
        )
    }
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $BuildDirectory "release-manifest.json") -Encoding utf8
    Write-Host "Web build complete: $BuildDirectory"

    if ($DryRun) {
        Write-Step "Dry run completed"
        Write-Host "No OCI objects or Cloudflare Worker were changed."
        exit 0
    }

    Write-Step "Uploading Web assets to OCI Object Storage"
    $namespace = (Invoke-Oci @("--profile", $OciProfile, "os", "ns", "get", "--query", "data", "--raw-output") "OCI namespace lookup" | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($namespace)) {
        throw "OCI namespace lookup returned no value."
    }
    foreach ($asset in $RequiredAssets) {
        $assetPath = Join-Path $BuildDirectory $asset.Name
        Invoke-Oci @("--profile", $OciProfile, "os", "object", "put", "--namespace", $namespace, "--bucket-name", $BucketName, "--name", $asset.Name, "--file", $assetPath, "--content-type", $asset.ContentType, "--verify-checksum", "--force") "OCI upload for $($asset.Name)"
    }

    Write-Step "Publishing the Cloudflare Worker"
    $previousCi = $env:CI
    $env:CI = "1"
    try {
        Invoke-Wrangler @("deploy", "--config", $WorkerConfigPath, "--var", "PVZ_RELEASE:$ReleaseId", "--message", "Pets vs Zombies $ReleaseId ($sourceCommit)") "Cloudflare Worker deployment"
    }
    finally {
        $env:CI = $previousCi
    }

    if (-not $SkipPublicCheck) {
        Write-Step "Verifying the public release"
        $cacheBypass = [uri]::EscapeDataString($ReleaseId)
        $htmlResponse = Invoke-WebRequest -Uri "$PublicUrl/?release=$cacheBypass" -Method Head -UseBasicParsing
        $wasmResponse = Invoke-WebRequest -Uri "$PublicUrl/index.wasm" -Method Head -UseBasicParsing
        $publicRelease = Get-ResponseHeaderValue $htmlResponse "X-PVZ-Release"
        $wasmContentType = Get-ResponseHeaderValue $wasmResponse "Content-Type"
        if ($htmlResponse.StatusCode -ne 200 -or $wasmResponse.StatusCode -ne 200) {
            throw "Public endpoint did not return HTTP 200 for HTML and WASM."
        }
        if ($publicRelease -ne $ReleaseId) {
            throw "Public release header '$publicRelease' does not match expected '$ReleaseId'."
        }
        if ($wasmContentType -notmatch "^application/wasm") {
            throw "Public WASM content type is '$wasmContentType', not application/wasm."
        }
    }

    Write-Step "Release complete"
    Write-Host "Public URL: $PublicUrl" -ForegroundColor Green
    Write-Host "Release header: $ReleaseId" -ForegroundColor Green
}
finally {
    Pop-Location
}
