# KETUK. 0.1.0 — Final Release Checklist

## Definition

0.1.0 adalah public playable demo / first Windows release, bukan game lengkap.

## Automated Gate

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\release_check.ps1 -GodotPath "PATH_KE_GODOT.exe"
```

Required markers:

```
STATE_ROUNDTRIP_OK
SAVE_RECOVERY_OK
KETUK_RELEASE_CHECK_OK
```

Gate mencakup:
- Main Menu;
- opening;
- auction room;
- reveal;
- home;
- world exploration;
- Pasar Tua;
- critical state serialization roundtrip;
- atomic save backup recovery;
- duplicate Adi-sale regression sebelum dan sesudah save/load.

## Windows Build

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build_release.ps1 -GodotPath "PATH_KE_GODOT.exe" -Target windows
```

Expected final outputs:
- `build/windows/KETUK.exe`
- `build/windows/KETUK.pck`
- `build/windows/BUILD_INFO.txt`
- `build/KETUK-0.1.0-windows.zip`
- `build/KETUK-0.1.0-windows.zip.sha256`

Required markers:
- `WINDOWS_EXPORT_OK=...`
- `WINDOWS_PCK_OK=...`
- `WINDOWS_ARTIFACT_BOOT_OK=...`
- `WINDOWS_BUILD_INFO_OK=...`
- `WINDOWS_PACKAGE_OK=...`
- `WINDOWS_SHA256=...`
- `WINDOWS_SHA256_FILE=...`
- `KETUK_RELEASE_BUILD_COMPLETE`

## Manual Acceptance

Validated flow:
- Game Baru;
- auction;
- correct inventory ownership;
- home;
- Buku Lama;
- world exploration;
- Mixed Box opening;
- Pasar Tua;
- camera/lens transaction;
- Adi cannot pay twice;
- Main Menu → Lanjutkan;
- money, time, inventory, rumors, NPC memory, kiosk state, and world location survive load.

Final UI adjustment:
- world/Pasar Tua `MENU` control is a small top-right overlay rather than a full-width gameplay action.

The exact final 0.1.0 commit must receive one final automated Windows build after this UI/version promotion.

## Release Blockers

Do not tag/publish if any remain:
- parse or script load error;
- any Godot `ERROR:` during release gate;
- dead-end scene transition;
- invalid inventory ownership;
- duplicated sale/reward;
- Save / Continue state loss;
- inaccessible portrait controls;
- Windows artifact boot failure;
- ZIP/checksum generation failure.

## Web

Web export is an optional follow-up and does not block the Windows-first 0.1.0 release.

## Final Promotion

After the exact 0.1.0 commit passes the final Windows build:
1. merge PR #7 into `main`;
2. tag `v0.1.0`;
3. publish `KETUK-0.1.0-windows.zip`;
4. publish `KETUK-0.1.0-windows.zip.sha256`.
