# KETUK. — 0.1.3 Draft Release Notes

> Internal QA candidate. Belum dipublikasikan sebagai GitHub Release.

## Release

KETUK. 0.1.3 adalah responsive/readability polish release untuk Windows-first public playable demo.

Rilis ini tidak menambah cerita atau gameplay baru. Fokusnya adalah membuat surface utama lebih tahan terhadap viewport portrait yang lebih kecil dan menjaga action/readability tetap nyaman.

## Responsive / Readability Highlights

- Main Menu mendapat full-page portrait overflow protection.
- Intro mendapat full-page portrait overflow protection.
- Home mendapat full-page portrait overflow protection.
- Auction mendapat full-page portrait overflow protection.
- Full-page ScrollContainer mengikuti keyboard focus.
- Content root tetap mengisi viewport ketika kontennya lebih pendek dari layar.
- Outer margins diperkecil pada empat surface utama agar lebih aman di viewport kecil.
- Auction:
  - fixed-width 245px pada label uang dihapus;
  - header sekarang membagi ruang secara fleksibel;
  - touch target tombol inspeksi diperbesar;
  - touch target MULAI BIDDING diperbesar.
- Semua controller path diperbarui melalui responsive scroll root.

## Structural Safety

Static audit memastikan:
- tidak ada stale `$Margin/Root` controller path;
- tidak ada stale scene parent `Margin/Root`;
- tidak ada fixed-width non-dekoratif tersisa di empat surface target;
- seluruh node binding tetap valid.

## Gameplay / Save Compatibility

Tidak berubah:
- AuctionState;
- bid logic;
- SaveManager;
- economy;
- NPC schedules;
- discovery/network logic;
- gameplay data;
- story flow;
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

0.1.3 tetap merupakan public playable demo.

Tidak termasuk:
- cerita baru;
- mekanik baru;
- content/economy expansion;
- Android store packaging;
- Web sebagai release blocker.

Web tetap follow-up opsional.
