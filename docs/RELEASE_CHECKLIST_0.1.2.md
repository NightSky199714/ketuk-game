# KETUK. 0.1.2 — Final Release Checklist

## Definition

0.1.2 adalah UI / visual-polish lanjutan untuk Windows-first public playable demo.

Scope:
- complete remaining UI consistency;
- no story expansion;
- no gameplay feature expansion.

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
- Pasar Tua;
- Discovery Loop;
- Human Network.

## Windows Build

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build_release.ps1 -GodotPath "PATH_KE_GODOT.exe" -Target windows
```

Expected outputs:
- `build/windows/KETUK.exe`
- `build/windows/KETUK.pck`
- `build/windows/BUILD_INFO.txt`
- `build/KETUK-0.1.2-windows.zip`
- `build/KETUK-0.1.2-windows.zip.sha256`

Required markers:
- `WINDOWS_EXPORT_OK=...`
- `WINDOWS_PCK_OK=...`
- `WINDOWS_ARTIFACT_BOOT_OK=...`
- `WINDOWS_BUILD_INFO_OK=...`
- `WINDOWS_PACKAGE_OK=...KETUK-0.1.2-windows.zip`
- `WINDOWS_SHA256=...`
- `WINDOWS_SHA256_FILE=...KETUK-0.1.2-windows.zip.sha256`
- `KETUK_RELEASE_BUILD_COMPLETE`

## Manual UI Acceptance

Validated before promotion:
- Discovery object selection readable;
- inspected object selected-state visible;
- Discovery target grid usable on portrait layout;
- Human Network location grid usable;
- active Human Network location selected-state visible;
- no player-facing P0/prototype labels remain;
- Reveal NPC expression presentation consistent with Auction.

## Gameplay Regression Guard

Must remain true:
- Save / Continue works;
- owned items are preserved;
- no duplicated transaction/reward;
- Adi cannot pay twice;
- kiosk/time/world state persist;
- no scene dead ends;
- Discovery/Human Network logic unchanged.

## Protected Logic

0.1.2 UI work must not modify:
- `scripts/auction/auction_state.gd`;
- `scripts/auction/bid_logic.gd`;
- `scripts/system/save_manager.gd`;
- gameplay/discovery/network data files.

## Final Promotion

After exact 0.1.2 head passes final Windows build:
1. mark PR #9 Ready for review;
2. merge PR #9 into `main`;
3. tag `v0.1.2`;
4. publish `KETUK-0.1.2-windows.zip`;
5. publish `KETUK-0.1.2-windows.zip.sha256`.

## Web

Web remains optional and does not block Windows 0.1.2.
