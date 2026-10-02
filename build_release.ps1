param(
    [string]$GodotPath = "godot",
    [ValidateSet("windows","web","all")]
    [string]$Target = "windows"
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
    $WinDir = Join-Path $Build "windows"
    if (Test-Path $WinDir) {
        Get-ChildItem -Path $WinDir -Force | Remove-Item -Recurse -Force
    } else {
        New-Item -ItemType Directory -Force -Path $WinDir | Out-Null
    }

    $WinOut = Join-Path $WinDir "KETUK.exe"
    $null = Invoke-GodotChecked -Arguments @("--headless", "--path", $Root, "--export-release", "Windows Desktop", $WinOut) -FailureMessage "Windows export failed. Check export templates."
    Write-Host "WINDOWS_EXPORT_OK=$WinOut"

    $PckFiles = @(Get-ChildItem -Path $WinDir -Filter "*.pck" -File)
    if ($PckFiles.Count -lt 1) {
        throw "Windows export completed but no .pck companion file was found."
    }
    Write-Host "WINDOWS_PCK_OK=$($PckFiles[0].FullName)"

    $ArtifactProcess = Start-Process -FilePath $WinOut -ArgumentList "--headless --quit-after 3 -- release-check" -PassThru -NoNewWindow
    $ArtifactExited = $ArtifactProcess.WaitForExit(10000)
    if (-not $ArtifactExited) {
        try { $ArtifactProcess.Kill() } catch {}
        throw "Exported Windows artifact did not exit within the 10 second boot-check window."
    }

    $ArtifactExitCode = [int]$ArtifactProcess.ExitCode
    if ($ArtifactExitCode -ne 0) {
        throw "Exported Windows artifact failed boot check. Exit code: $ArtifactExitCode."
    }
    Write-Host "WINDOWS_ARTIFACT_BOOT_OK=$WinOut"

    $GitCommit = "unknown"
    try {
        $GitCommit = (& git -C $Root rev-parse HEAD).Trim()
    } catch {}

    $BuildInfoPath = Join-Path $WinDir "BUILD_INFO.txt"
    @(
        "KETUK. - Di Balik Harga"
        "Version=0.1.0-rc1"
        "Commit=$GitCommit"
        "Platform=Windows x86_64"
        "BuiltAtUtc=$([DateTime]::UtcNow.ToString('o'))"
    ) | Set-Content -Encoding utf8 $BuildInfoPath
    Write-Host "WINDOWS_BUILD_INFO_OK=$BuildInfoPath"

    $WindowsZip = Join-Path $Build "KETUK-0.1.0-rc1-windows.zip"
    if (Test-Path $WindowsZip) {
        Remove-Item -Force $WindowsZip
    }

    Compress-Archive -Path (Join-Path $Build "windows\*") -DestinationPath $WindowsZip -Force
    Write-Host "WINDOWS_PACKAGE_OK=$WindowsZip"

    $Hash = Get-FileHash -Algorithm SHA256 -Path $WindowsZip
    $HashPath = $WindowsZip + ".sha256"
    ($Hash.Hash + "  " + [IO.Path]::GetFileName($WindowsZip)) | Set-Content -Encoding ascii $HashPath
    Write-Host "WINDOWS_SHA256=$($Hash.Hash)"
    Write-Host "WINDOWS_SHA256_FILE=$HashPath"
}

if ($Target -eq "web" -or $Target -eq "all") {
    $WebDir = Join-Path $Build "web"
    $WebZip = Join-Path $WebDir "KETUK-web.zip"
    $WebSite = Join-Path $WebDir "site"

    if (Test-Path $WebZip) {
        Remove-Item -Force $WebZip
    }
    if (Test-Path $WebSite) {
        Remove-Item -Recurse -Force $WebSite
    }

    $null = Invoke-GodotChecked -Arguments @("--headless", "--path", $Root, "--export-release", "Web", $WebZip) -FailureMessage "Web export failed. Check export templates."

    New-Item -ItemType Directory -Force -Path $WebSite | Out-Null
    Expand-Archive -Path $WebZip -DestinationPath $WebSite -Force

    $Index = Join-Path $WebSite "index.html"
    if (-not (Test-Path $Index)) {
        throw "Web export zip was created, but index.html was not found after extraction."
    }

    Write-Host "WEB_EXPORT_ZIP_OK=$WebZip"
    Write-Host "WEB_SITE_OK=$Index"
}

Write-Host "KETUK_RELEASE_BUILD_COMPLETE"
