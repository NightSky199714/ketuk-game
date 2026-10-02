# Smoke Test — Vertical Slice Chapter 2

## Setup

1. Checkout `vertical-slice/chapter-2`.
2. Mainkan Chapter 1.
3. Di akhir Chapter 1 tekan `LANJUT BAB 2`.

## Entry

Expected:
- judul `BAB 2 — BATAS`;
- waktu mulai Minggu 16:00;
- deadline Minggu 20:00;
- tunggakan Rp1.200.000;
- state uang berasal dari hasil Chapter 1.

## Route B1 — Safe Sale

Syarat:
- MC memiliki kamera.

Pilih:
`JUAL SEKARANG — TOKO KAMERA Rp1.650.000`

Expected:
- waktu 16:30;
- uang bertambah Rp1.650.000 lalu berkurang Rp1.200.000 untuk kios;
- kios selamat;
- kamera ditandai terjual penuh.

## Route B2 — Adi

Pilih:
`CARI ADI — PEMBELI LENSA`

Expected:
- waktu menjadi Minggu 18:00;
- muncul warning konteks deadline, bukan failure;
- Adi menawarkan Rp2.100.000 untuk lensa;
- pilih perpanjangan;
- waktu menjadi 18:20;
- Pak Arman memberi batas Senin 10:00;
- Senin 09:00 transaksi selesai;
- Rp1.200.000 dibayar;
- kios selamat;
- body kamera kembali.

## Route B3-A — Return

Pilih:
`KEJAR SENTANA — KOLEKTOR?`

Lalu pada 18:00:
`BERHENTI MENGEJAR — KEMBALI KE TOKO KAMERA`

Expected:
- penawaran terlambat Rp1.500.000;
- kios selamat;
- keputusan stop memiliki konsekuensi harga lebih rendah.

## Route B3-B — Chase

Pada 18:00 pilih:
`LANJUT CARI SENTANA`

Expected:
- waktu lewat deadline ke 20:30;
- kios hilang;
- tidak ada game over;
- Senin 09:10 Sentana ternyata nyata;
- offer Rp3.800.000 muncul;
- teks menegaskan bahwa offer tinggi tidak mengembalikan deadline yang lewat.

## Route A — No Camera

Mainkan Chapter 1 tanpa memenangkan kamera.

Expected:
- Chapter 2 tetap berjalan;
- route tidak memberi kamera palsu;
- deadline lewat;
- kios hilang;
- papan nama dikembalikan dengan hati-hati.

## Fail Fast

Perbaiki jika:
- jam Senin tampil sebagai 33:00;
- warning 18:00 dianggap deadline;
- kamera muncul jika tidak dimenangkan;
- Adi membeli seluruh kamera;
- Sentana dipastikan nyata sebelum route chase;
- B3-B menjadi game over;
- pembayaran kios tidak mengurangi uang;
- hasil route tidak berasal dari state Chapter 1.
