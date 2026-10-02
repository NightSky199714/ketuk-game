# KETUK. — 0.1.0 Release Notes

## Release

KETUK. 0.1.0 adalah public playable demo pertama untuk Windows.

Build ini menghubungkan loop utama dari lelang ke inventory, eksplorasi lokasi, jaringan NPC, informasi yang belum tentu benar, keputusan ekonomi, dan konsekuensi dunia.

## Highlights

- Main Menu dengan Game Baru / Lanjutkan / Keluar.
- Versi build tampil langsung di Main Menu.
- Save schema v1 dengan safe resume scenes.
- Atomic save dengan backup recovery.
- Auction UI berbasis `.tscn`.
- Inventory mengikuti ownership hasil lelang.
- KOTAK CAMPURAN dibuka melalui interaksi dunia.
- BUKU LAMA sebagai knowledge record, bukan quest log.
- Eksplorasi tempat tanpa objective route yang eksplisit.
- Waktu dunia, opening hours, dan jadwal NPC tersembunyi.
- Rumor DENGAR dipisahkan dari informasi TERVERIFIKASI.
- NPC memory untuk benda yang sudah pernah ditunjukkan.
- Kiosk deadline dan pembayaran manual.
- Persistent world ↔ Pasar Tua state.
- Transaksi lensa Adi idempotent; duplicate payout ditutup.
- Tombol MENU di world/Pasar Tua dipindah ke pojok kanan atas agar tidak tertukar dengan aksi gameplay.
- Windows build menghasilkan executable, PCK, BUILD_INFO, ZIP, dan SHA-256.

## Automated Release Gates

0.1.0 memiliki gate lokal untuk:
- startup semua scene utama;
- state export → reset → import roundtrip;
- atomic save backup recovery;
- duplicate Adi-sale regression;
- Windows export;
- companion PCK;
- boot exported KETUK.exe;
- ZIP packaging;
- SHA-256 generation.

## Manual Acceptance

Manual playthrough dilakukan pada RC sebelum promotion dan mencakup:
- auction → home → inventory → world → Pasar Tua;
- transaksi dan rumor;
- Save / Continue;
- duplicate-sale exploit Adi setelah perbaikan.

Perubahan UI terakhir sebelum final build:
- kontrol MENU world/Pasar Tua dipindah dari full-width action menjadi tombol kecil di pojok kanan atas.

## Known 0.1.0 Limitations

- Visual masih dominan functional/placeholder.
- NPC expression masih berupa placeholder text.
- Bid AI sengaja sederhana.
- Content setelah setup Sentana belum merupakan full game.
- Android store packaging belum termasuk 0.1.0.
- Web export tidak menjadi blocker untuk Windows-first release.

## Save Compatibility

Save schema: v1.

Perubahan state yang tidak kompatibel di masa depan harus:
- memigrasikan save v1; atau
- menaikkan save version dan mengomunikasikan incompatibility dengan jelas.

Jangan menginterpretasikan ulang field save lama secara diam-diam.
