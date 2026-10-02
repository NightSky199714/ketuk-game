# KETUK. 0.1.3 — Final Release Checklist

## Definition

0.1.3 adalah responsive/readability polish release untuk Windows-first public playable demo.

Scope:
- portrait overflow protection;
- readability/action hierarchy;
- no story expansion;
- no gameplay expansion.

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
- `build/KETUK-0.1.3-windows.zip`
- `build/KETUK-0.1.3-windows.zip.sha256`

Required markers:
- `WINDOWS_EXPORT_OK=...`
- `WINDOWS_PCK_OK=...`
- `WINDOWS_ARTIFACT_BOOT_OK=...`
- `WINDOWS_BUILD_INFO_OK=...`
- `WINDOWS_PACKAGE_OK=...KETUK-0.1.3-windows.zip`
- `WINDOWS_SHA256=...`
- `WINDOWS_SHA256_FILE=...KETUK-0.1.3-windows.zip.sha256`
- `KETUK_RELEASE_BUILD_COMPLETE`

## Manual Responsive Acceptance

Check:
- Main Menu scrolls on smaller portrait viewport;
- Intro remains readable and Next remains reachable;
- Home inventory/details/exit remain reachable;
- Auction header does not force horizontal overflow;
- Auction inspect/start-bidding actions remain reachable;
- keyboard/controller focus scrolling remains usable.

## Gameplay Regression Guard

Must remain true:
- Save / Continue works;
- owned items persist;
- no duplicated transaction/reward;
- Adi cannot pay twice;
- kiosk/time/world state persist;
- no scene dead ends.

## Protected Logic

0.1.3 UI work must not modify:
- `scripts/auction/auction_state.gd`;
- `scripts/auction/bid_logic.gd`;
- `scripts/system/save_manager.gd`;
- gameplay/discovery/network data files.

## Final Promotion

After exact 0.1.3 head passes final Windows build:
1. mark PR #10 Ready for review;
2. merge PR #10 into `main`;
3. tag `v0.1.3`;
4. publish `KETUK-0.1.3-windows.zip`;
5. publish `KETUK-0.1.3-windows.zip.sha256`.

## Web

Web remains optional and does not block Windows 0.1.3.
