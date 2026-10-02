# KETUK. — UI Completion Checklist

Status target: UI selesai sebelum release publik berikutnya.

## Primary Surfaces

Semua surface utama harus scene-owned dan memakai KETUK theme:
- Main Menu
- Intro
- Auction
- Reveal
- Home
- World
- Pasar Tua
- Discovery Loop
- Human Network

## Responsive / Readability

- Semua primary surface memiliki full-page ScrollContainer.
- Full-page scroll memakai `follow_focus = true`.
- Tidak ada fixed-width non-dekoratif yang memaksa horizontal overflow.
- Dynamic/static action buttons tidak memakai touch target di bawah 52 px.
- Inventory/grid controls expand mengikuti lebar container.
- Content tetap dapat dijangkau pada viewport portrait kecil.

## Visual Consistency

- Global KETUK theme aktif.
- Paper / dark-panel / brick-red hierarchy konsisten.
- Focus style aktif.
- Selected state dipakai untuk state pilihan yang relevan.
- Tidak ada player-facing P0/prototype/chapter-number label.
- NPC expression presentation konsisten.

## Structural UI

- Tidak ada primary UI yang dibangun lewat `_build_ui()`.
- Controller `$Node/Path` resolve ke scene.
- Tidak ada stale layout path dari struktur lama.

## Gameplay Guardrails

UI completion tidak boleh mengubah:
- `scripts/auction/auction_state.gd`
- `scripts/auction/bid_logic.gd`
- `scripts/system/save_manager.gd`
- economy
- save schema
- story/gameplay data
- discovery/network data

## Runtime Gate

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\release_check.ps1 \
  -GodotPath "D:\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe"
```

Required:
- `IMPORT_OK`
- all primary scenes `SCENE_OK`
- `STATE_ROUNDTRIP_OK`
- `SAVE_RECOVERY_OK`
- `KETUK_RELEASE_CHECK_OK`

## Manual Visual Acceptance

Before public release:
- check default portrait viewport;
- check 540x960 override/smaller portrait window;
- confirm no clipped labels/buttons;
- confirm scrolling reaches every action;
- confirm keyboard/controller focus follows visible controls;
- confirm selected/focus states are legible;
- confirm MENU/navigation controls remain clickable.

## Publication

Do not create a GitHub release/tag for intermediate UI milestones.

Publish only after:
1. this checklist is complete;
2. final runtime gate passes;
3. manual visual acceptance passes;
4. final release version/package is promoted.
