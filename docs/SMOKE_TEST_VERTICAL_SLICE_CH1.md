# Smoke Test — Vertical Slice Chapter 1

## Setup

1. Checkout `vertical-slice/chapter-1`.
2. Buka project Godot.
3. F5.

## Boot

Expected:
- project bernama `KETUK. — Di Balik Harga`;
- scene pertama bukan auction;
- tampil konteks:
  - Rp430.000;
  - tunggakan Rp1.200.000;
  - deadline Minggu 20:00;
  - Buku lama;
  - margin "Kalau ragu, lihat bagian yang tidak dilihat orang.";
- tombol akhir opening: `KE BALAI LELANG`.

## Canon-ish Path

Target:
- Lot 01 tidak dimenangkan MC;
- Lot 02 dimenangkan MC di Rp95.000;
- Lot 03 dimainkan sampai cabang kamera;
- jika appraisal Pak Harun dipilih, hasil appraisal dapat diingat di rumah.

Expected home:
- Kotak Campuran muncul sebagai milik MC;
- tombol `BUKA KOTAK` tersedia;
- setelah dibuka, pemain dapat memeriksa TATAKAN / KOREK / ADAPTOR;
- `SELESAI MEMERIKSA` baru aktif setelah minimal satu objek diperiksa;
- observasi tidak memberi appraisal final;
- kamera hanya muncul jika benar-benar dimenangkan MC;
- uang tersisa sesuai transaksi;
- setelah pemeriksaan, Buku menulis:
  `Rp95.000. Sepertinya tidak salah.`

## Ownership Failure Path

Ulangi dan sengaja kalah Lot 02.

Expected:
- Kotak Campuran tidak muncul sebagai milik MC di rumah;
- tombol `BUKA KOTAK` tidak muncul;
- scene langsung menawarkan `BUKA BUKU`;
- Buku tidak menulis seolah-olah MC memilikinya;
- tidak ada P0.2 fallback yang memberikan kotak kepada MC.

## Appraisal Knowledge Path

### A — lihat appraisal
- ikuti pemeriksaan Pak Harun;
- pulang.

Expected:
- scene rumah boleh menyebut informasi tentang kamera yang disaksikan.

### B — jangan lihat appraisal
- pilih `NANTI SAJA` / tinggalkan balai;
- pulang.

Expected:
- scene rumah tidak mengetahui nilai lensa secara ajaib.

## Restart

Dari sesudah lelang atau akhir chapter:
- restart harus kembali ke opening Chapter 1;
- state lama harus bersih setelah opening memulai chapter baru.

## Fail Fast

Perbaiki jika:
- F5 masih langsung ke auction;
- opening ter-reset ketika masuk auction;
- barang kalah muncul di rumah;
- Buku memalsukan harga/ownership;
- appraisal muncul sebagai knowledge tanpa disaksikan;
- Chapter 1 otomatis masuk Pasar Tua/P0.3.
