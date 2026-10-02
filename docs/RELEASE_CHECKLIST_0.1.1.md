# KETUK. 0.1.1 — Final Release Checklist

## Definition

0.1.1 adalah UI / visual-polish release untuk Windows-first public playable demo.

Tidak ada feature/story expansion dalam scope ini.

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

Validated scenes:
- Main Menu;
- Intro;
- Auction;
- Reveal;
- Home;
- World;
- Pasar Tua.

## Windows Build

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build_release.ps1 -GodotPath "PATH_KE_GODOT.exe" -Target windows
```

Expected outputs:
- `build/windows/KETUK.exe`
- `build/windows/KETUK.pck`
- `build/windows/BUILD_INFO.txt`
- `build/KETUK-0.1.1-windows.zip`
- `build/KETUK-0.1.1-windows.zip.sha256`

Required markers:
- `WINDOWS_EXPORT_OK=...`
- `WINDOWS_PCK_OK=...`
- `WINDOWS_ARTIFACT_BOOT_OK=...`
- `WINDOWS_BUILD_INFO_OK=...`
- `WINDOWS_PACKAGE_OK=...KETUK-0.1.1-windows.zip`
- `WINDOWS_SHA256=...`
- `WINDOWS_SHA256_FILE=...KETUK-0.1.1-windows.zip.sha256`
- `KETUK_RELEASE_BUILD_COMPLETE`

## Manual UI Acceptance

Validated before version promotion:
- Main Menu hierarchy readable;
- Auction actions readable;
- Home inventory usable;
- World scroll/layout usable;
- Pasar Tua scroll/layout usable;
- World MENU clickable;
- Pasar Tua MENU clickable;
- selected-state visible for items/locations;
- no inaccessible portrait controls reported.

## Gameplay Regression Guard

Must remain true:
- Save / Continue works;
- owned items are preserved;
- no duplicated transaction/reward;
- Adi cannot pay twice;
- kiosk/time/world state persist;
- no scene dead ends.

## Protected Logic

0.1.1 UI work must not modify:
- `scripts/auction/auction_state.gd`;
- `scripts/auction/bid_logic.gd`;
- `scripts/system/save_manager.gd`;
- gameplay data files.

## Final Promotion

After exact 0.1.1 head passes final Windows build:
1. mark PR #8 Ready for review;
2. merge PR #8 into `main`;
3. tag `v0.1.1`;
4. publish `KETUK-0.1.1-windows.zip`;
5. publish `KETUK-0.1.1-windows.zip.sha256`.

## Web

Web remains optional and does not block Windows 0.1.1.
