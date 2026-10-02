param(
    [string]$GodotPath = "godot"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

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

    $Token = [Guid]::NewGuid().ToString("N")
    $StdOutPath = Join-Path $env:TEMP ("ketuk_godot_stdout_" + $Token + ".log")
    $StdErrPath = Join-Path $env:TEMP ("ketuk_godot_stderr_" + $Token + ".log")

    try {
        $QuotedArgs = @()
        foreach ($Arg in $Arguments) {
            if ($Arg -match "[\s`"]") { $QuotedArgs += "`"" + ($Arg -replace "`"", "\`"") + "`"" }
            else { $QuotedArgs += $Arg }
        }

        $Process = Start-Process -FilePath $script:GodotRunner -ArgumentList ($QuotedArgs -join " ") -Wait -PassThru -NoNewWindow -RedirectStandardOutput $StdOutPath -RedirectStandardError $StdErrPath
        $ExitCode = [int]$Process.ExitCode

        $StdOut = if (Test-Path $StdOutPath) { Get-Content -Raw $StdOutPath } else { "" }
        $StdErr = if (Test-Path $StdErrPath) { Get-Content -Raw $StdErrPath } else { "" }

        if (-not [string]::IsNullOrWhiteSpace($StdOut)) { Write-Host $StdOut.TrimEnd() }
        if (-not [string]::IsNullOrWhiteSpace($StdErr)) { Write-Host $StdErr.TrimEnd() }

        $Combined = $StdOut + "`n" + $StdErr
        $FatalPattern = "(?m)^\s*(SCRIPT ERROR:|ERROR:)"

        if ($ExitCode -ne 0 -or $Combined -match $FatalPattern) {
            throw "$FailureMessage Exit code: $ExitCode. Godot reported a fatal script/resource error."
        }

        return $ExitCode
    }
    finally {
        Remove-Item -Force -ErrorAction SilentlyContinue $StdOutPath, $StdErrPath
    }
}

$GodotRunner = Resolve-GodotRunner -Path $GodotPath
Write-Host "KETUK_RELEASE_CHECK_START"
Write-Host "PROJECT=$Root"
Write-Host "GODOT_REQUESTED=$GodotPath"
Write-Host "GODOT_RUNNER=$GodotRunner"

if (-not (Test-Path $GodotRunner) -and $GodotRunner -ne "godot") { throw "Godot executable not found: $GodotRunner" }

$null = Invoke-GodotChecked -Arguments @("--headless", "--path", $Root, "--import") -FailureMessage "Godot import failed."
Write-Host "IMPORT_OK"

$Scenes = @(
    "res://scenes/system/main_menu.tscn",
    "res://scenes/chapter/chapter1_intro.tscn",
    "res://scenes/auction/auction_room.tscn",
    "res://scenes/reveal/reveal_camera.tscn",
    "res://scenes/chapter/chapter1_home.tscn",
    "res://scenes/chapter/chapter2_batas.tscn",
    "res://scenes/chapter/chapter3_orang_yang_tepat.tscn",
    "res://scenes/discovery/discovery_loop.tscn",
    "res://scenes/network/human_network.tscn",
    "res://scenes/system/release_state_test.tscn",
    "res://scenes/system/release_save_recovery_test.tscn"
)

foreach ($Scene in $Scenes) {
    Write-Host "CHECK_SCENE=$Scene"
    $null = Invoke-GodotChecked -Arguments @("--headless", "--path", $Root, "--scene", $Scene, "--quit-after", "3", "--", "release-check") -FailureMessage "Scene check failed for $Scene."
    Write-Host "SCENE_OK=$Scene"
}

Write-Host "KETUK_RELEASE_CHECK_OK"
