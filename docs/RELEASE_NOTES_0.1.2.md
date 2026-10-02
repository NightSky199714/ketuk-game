# KETUK. — 0.1.2 Release Notes

## Release

KETUK. 0.1.2 adalah visual-polish lanjutan untuk Windows-first public playable demo.

Rilis ini tetap tidak menambah cerita atau fitur gameplay baru. Fokusnya adalah menuntaskan konsistensi UI pada surface yang masih tersisa dari prototype dan memperkuat kualitas portrait/responsive presentation.

## UI / Visual Highlights

- Discovery Loop dipindah dari code-built UI ke scene-owned UI.
- Human Network dipindah dari code-built UI ke scene-owned UI.
- Discovery memakai:
  - KETUK global theme;
  - worn-paper overlay;
  - responsive object grid;
  - selected-state untuk benda yang sudah diperiksa;
  - icon khusus Tatakan, Korek, dan Adaptor.
- Human Network memakai:
  - KETUK global theme;
  - responsive 2-column market map;
  - selected-state untuk lokasi aktif;
  - panel target, response, status, dan end-state yang konsisten.
- Remaining player-facing prototype/P0 labels dibersihkan.
- Reveal NPC expression formatting disamakan dengan Auction.
- Responsive grid button sizing dinormalisasi.
- Discovery dan Human Network ditambahkan ke automated scene smoke gate.

## Structural UI Cleanup

Discovery dan Human Network tidak lagi membangun primary UI lewat `_build_ui()`.

Dengan ini primary player-facing surfaces berikut semuanya sudah scene-owned:
- Main Menu;
- Intro;
- Auction;
- Reveal;
- Home;
- World;
- Pasar Tua;
- Discovery Loop;
- Human Network.

## Gameplay / Save Compatibility

Tidak berubah:
- AuctionState;
- bid logic;
- SaveManager;
- economy;
- NPC schedules;
- item ownership;
- rumor rules;
- discovery data;
- human-network data;
- save schema.

Save schema tetap v1.

## Validation

Automated gate mencakup:
- Godot import;
- Main Menu;
- Intro;
- Auction;
- Reveal;
- Home;
- World;
- Pasar Tua;
- Discovery Loop;
- Human Network;
- state export/reset/import roundtrip;
- atomic save backup recovery;
- duplicate Adi-sale regression.

## Known Scope

0.1.2 tetap merupakan public playable demo, bukan full game.

Tidak termasuk:
- cerita baru;
- mekanik baru;
- economy/content expansion;
- Android store packaging;
- Web sebagai release blocker.

Web tetap follow-up opsional.
