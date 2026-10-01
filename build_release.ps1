param(
    [string]$GodotPath = "godot",
    [ValidateSet("windows","web","all")]
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Build = Join-Path $Root "build"

New-Item -ItemType Directory -Force -Path (Join-Path $Build "windows") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Build "web") | Out-Null

Write-Host "KETUK_RELEASE_BUILD_START"
Write-Host "PROJECT=$Root"
Write-Host "GODOT=$GodotPath"

$CheckScript = Join-Path $Root "release_check.ps1"
& $CheckScript -GodotPath $GodotPath

& $GodotPath --headless --path $Root --import
if ($LASTEXITCODE -ne 0) {
    throw "Godot import failed with exit code $LASTEXITCODE."
}

if ($Target -eq "windows" -or $Target -eq "all") {
    $WinOut = Join-Path $Build "windows\KETUK.exe"
    & $GodotPath --headless --path $Root --export-release "Windows Desktop" $WinOut
    if ($LASTEXITCODE -ne 0) {
        throw "Windows export failed with exit code $LASTEXITCODE. Check export templates."
    }
    Write-Host "WINDOWS_EXPORT_OK=$WinOut"
}

if ($Target -eq "web" -or $Target -eq "all") {
    $WebOut = Join-Path $Build "web\index.html"
    & $GodotPath --headless --path $Root --export-release "Web" $WebOut
    if ($LASTEXITCODE -ne 0) {
        throw "Web export failed with exit code $LASTEXITCODE. Check export templates."
    }
    Write-Host "WEB_EXPORT_OK=$WebOut"
}

Write-Host "KETUK_RELEASE_BUILD_COMPLETE"
