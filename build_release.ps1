param(
    [string]$GodotPath = "godot",
    [ValidateSet("windows","web","all")]
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Build = Join-Path $Root "build"

function Resolve-GodotRunner {
    param([string]$Path)
    if ($Path -match "\.exe$" -and $Path -notmatch "_console\.exe$") {
        $ConsoleCandidate = $Path -replace "\.exe$", "_console.exe"
        if (Test-Path $ConsoleCandidate) { return $ConsoleCandidate }
    }
    return $Path
}

function Invoke-GodotChecked {
    param([string[]]$Arguments, [string]$FailureMessage)
    $QuotedArgs = @()
    foreach ($Arg in $Arguments) {
        if ($Arg -match "[\s`"]") { $QuotedArgs += "`"" + ($Arg -replace "`"", "\`"") + "`"" }
        else { $QuotedArgs += $Arg }
    }
    $Process = Start-Process -FilePath $script:GodotRunner -ArgumentList ($QuotedArgs -join " ") -Wait -PassThru -NoNewWindow
    $ExitCode = [int]$Process.ExitCode
    if ($ExitCode -ne 0) { throw "$FailureMessage Exit code: $ExitCode." }
    return $ExitCode
}

$GodotRunner = Resolve-GodotRunner -Path $GodotPath
New-Item -ItemType Directory -Force -Path (Join-Path $Build "windows") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Build "web") | Out-Null

Write-Host "KETUK_RELEASE_BUILD_START"
Write-Host "PROJECT=$Root"
Write-Host "GODOT_REQUESTED=$GodotPath"
Write-Host "GODOT_RUNNER=$GodotRunner"

$CheckScript = Join-Path $Root "release_check.ps1"
& $CheckScript -GodotPath $GodotPath

$null = Invoke-GodotChecked -Arguments @("--headless", "--path", $Root, "--import") -FailureMessage "Godot import failed."

if ($Target -eq "windows" -or $Target -eq "all") {
    $WinOut = Join-Path $Build "windows\KETUK.exe"
    $null = Invoke-GodotChecked -Arguments @("--headless", "--path", $Root, "--export-release", "Windows Desktop", $WinOut) -FailureMessage "Windows export failed. Check export templates."
    Write-Host "WINDOWS_EXPORT_OK=$WinOut"
}

if ($Target -eq "web" -or $Target -eq "all") {
    $WebOut = Join-Path $Build "web\index.html"
    $null = Invoke-GodotChecked -Arguments @("--headless", "--path", $Root, "--export-release", "Web", $WebOut) -FailureMessage "Web export failed. Check export templates."
    Write-Host "WEB_EXPORT_OK=$WebOut"
}

Write-Host "KETUK_RELEASE_BUILD_COMPLETE"
