# KETUK. — 0.1.1 Release Notes

## Release

KETUK. 0.1.1 adalah visual-polish release untuk public playable demo Windows.

Rilis ini tidak menambah cerita atau gameplay baru. Fokusnya adalah membuat seluruh flow yang sudah ada terasa lebih konsisten, lebih mudah dibaca, dan lebih dekat ke identitas visual KETUK.

## UI / Visual Highlights

- Global visual theme KETUK:
  - cream paper;
  - dark wood / brown;
  - charcoal;
  - restrained brick red.
- Main Menu didesain ulang dengan hierarchy visual yang lebih kuat.
- Auction Room didesain ulang:
  - lot card lebih jelas;
  - bid panel lebih menonjol;
  - NPC cards konsisten;
  - BID / WAIT / STOP lebih terbaca.
- Home / Inventory dipindah dari code-built UI ke scene-owned UI.
- Sukamaju World dipindah dari code-built UI ke scene-owned UI.
- Pasar Tua dipindah dari code-built UI ke scene-owned UI.
- Intro dan Reveal dipindah ke scene-owned polished layouts.
- Lightweight SVG icon system untuk:
  - menu actions;
  - auction actions;
  - inventory items;
  - world locations;
  - market locations.
- Subtle worn-paper overlay ditambahkan pada layar utama.
- Selected-state untuk item inventory aktif dan lokasi aktif.
- Keyboard focus ring ditambahkan.
- Corner MENU pada World / Pasar Tua diperbaiki supaya tetap di atas Scroll UI dan dapat diklik.

## Structural UI Cleanup

Primary UI tidak lagi dibangun lewat `_build_ui()` pada:
- Main Menu;
- Auction;
- Intro;
- Reveal;
- Home;
- World;
- Pasar Tua.

Controller sekarang berfokus pada binding state/logic ke node scene.

## Gameplay / Save Compatibility

Tidak berubah:
- AuctionState;
- bid logic;
- economy;
- NPC schedules;
- rumor rules;
- item ownership;
- Adi transaction guard;
- SaveManager;
- save schema.

Save schema tetap v1.

## Validation

Automated UI branch gate mencakup:
- Godot import;
- Main Menu;
- Intro;
- Auction;
- Reveal;
- Home;
- World;
- Pasar Tua;
- state export/reset/import roundtrip;
- atomic save backup recovery;
- duplicate Adi-sale regression.

Manual UI acceptance mencakup:
- visual hierarchy utama;
- menu corner interaction;
- scroll/accessibility;
- selected states;
- action readability.

## Known Scope

0.1.1 tetap merupakan public playable demo, bukan full game.

Tidak termasuk:
- cerita baru;
- mekanik baru;
- advanced NPC simulation;
- Android store packaging;
- Web sebagai release blocker.

Web tetap follow-up opsional.
