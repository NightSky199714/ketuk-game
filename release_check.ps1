param(
    [string]$GodotPath = "godot"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "KETUK_RELEASE_CHECK_START"
Write-Host "PROJECT=$Root"
Write-Host "GODOT=$GodotPath"

& $GodotPath --headless --path $Root --import
if ($LASTEXITCODE -ne 0) {
    throw "Godot import failed with exit code $LASTEXITCODE."
}

$Scenes = @(
    "res://scenes/system/main_menu.tscn",
    "res://scenes/chapter/chapter1_intro.tscn",
    "res://scenes/auction/auction_room.tscn",
    "res://scenes/reveal/reveal_camera.tscn",
    "res://scenes/chapter/chapter1_home.tscn",
    "res://scenes/chapter/chapter2_batas.tscn",
    "res://scenes/chapter/chapter3_orang_yang_tepat.tscn"
)

foreach ($Scene in $Scenes) {
    Write-Host "CHECK_SCENE=$Scene"
    & $GodotPath --headless --path $Root --scene $Scene --quit-after 3 -- release-check
    if ($LASTEXITCODE -ne 0) {
        throw "Scene check failed for $Scene with exit code $LASTEXITCODE."
    }
}

Write-Host "KETUK_RELEASE_CHECK_OK"
