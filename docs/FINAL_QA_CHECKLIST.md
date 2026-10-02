# KETUK. — Final QA / Release Readiness

Target: memastikan build kandidat stabil tanpa menambah fitur, cerita, ekonomi, atau schema baru.

## Completed static audit

- [x] UI completion merged to main.
- [x] All referenced scene transition paths exist.
- [x] Main Menu / World / Pasar Tua save-to-menu paths verified.
- [x] SaveManager only resumes to allowlisted safe scenes.
- [x] Primary/backup atomic save recovery covered by automated test.
- [x] Duplicate Adi sale/payout regression covered by automated state test.
- [x] Chapter 3 start is guarded/idempotent.
- [x] Player-facing developer fallback copy removed from Auction.
- [x] Auction terminal fallback no longer leaves a dead-end screen.
- [x] No player-facing P0/prototype/restart-project copy found in primary flow.
- [x] 0.1.3 documentation marked as internal QA candidate, not published release.

## Added regression coverage

`release_state_test.gd` now verifies that calling `start_chapter3()` after imported Chapter 3 progress does not reset:
- people-book state;
- poster state;
- network travel state.

## Runtime gate

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\release_check.ps1 \
  -GodotPath "D:\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe"
```

Required:
- `IMPORT_OK`
- every listed scene `SCENE_OK`
- `STATE_ROUNDTRIP_OK`
- `SAVE_RECOVERY_OK`
- `KETUK_RELEASE_CHECK_OK`

## Manual end-to-end acceptance

Before publication, verify at least one normal path:
1. Main Menu -> Game Baru.
2. Intro -> Auction.
3. Finish auction flow -> Reveal.
4. Return Home.
5. Enter World.
6. Enter/leave Pasar Tua.
7. MENU -> Main Menu.
8. Continue -> returns to saved World/Pasar state.
9. Inventory ownership and money remain unchanged across Continue.

Also verify:
- no unreachable action button;
- no clipped text at target portrait size;
- no input/focus trap;
- no duplicate money/item reward;
- no visible developer/debug copy.

## Publication policy

Do not tag or publish during QA.

Only after runtime + manual acceptance:
1. decide final public version;
2. update package metadata if needed;
3. run one exact-head Windows release build;
4. create one tag and one GitHub Release.
