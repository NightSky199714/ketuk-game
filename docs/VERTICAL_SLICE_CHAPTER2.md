# Vertical Slice — Chapter 2: BATAS

## Goal

Mengajarkan bahwa:
- nilai tinggi belum tentu likuid;
- harga tertinggi belum tentu keputusan terbaik;
- waktu adalah resource;
- berhenti mengejar juga bisa menjadi keputusan yang benar.

## Starting State

- Deadline kios: Minggu 20:00.
- Tunggakan: Rp1.200.000.
- Warning jam 18:00 hanyalah peringatan, bukan deadline baru.
- Chapter 2 memakai state hasil Chapter 1.

Jika MC tidak memiliki kamera, jalur A tersedia:
- tidak ada aset besar untuk dijual;
- deadline lewat;
- kios hilang;
- papan nama diserahkan kembali dengan hati-hati.

## Route B1 — Camera Shop

Jam 16:00:
- toko kamera menawarkan Rp1.650.000 tunai sekarang.

Jika diterima:
- kamera terjual penuh;
- Rp1.200.000 dibayar;
- kios selamat;
- pemain tidak mendapat harga tertinggi.

## Route B2 — Adi

MC mengejar pembeli lensa:
- jam mencapai 18:00;
- Adi menawarkan Rp2.100.000 untuk lensa saja;
- body dikembalikan;
- Adi baru bisa bertemu Senin pagi.

MC harus meminta perpanjangan kepada Pak Arman:
- batas baru Senin 10:00;
- tidak ada penghapusan utang.

Senin 09:00:
- lens terjual Rp2.100.000;
- MC membayar tepat Rp1.200.000;
- kios selamat;
- body kamera tetap dimiliki.

## Route B3-A — Stop Chasing Sentana

MC mengejar Sentana sampai jam 18:00.

Tidak ada kepastian Sentana akan muncul.

Jika pemain berhenti:
- kembali ke toko kamera;
- penawaran turun ke Rp1.500.000;
- MC menerima;
- kios tetap selamat.

## Route B3-B — Chase Too Long

Jika pemain terus mengejar Sentana:
- waktu lewat 20:00;
- kios hilang;
- papan nama dikembalikan dengan hati-hati.

Senin pagi:
- Sentana ternyata nyata;
- tawaran Rp3.800.000 datang setelah deadline.

Inti:
> harga tertinggi tidak membatalkan konsekuensi waktu.

## Design Rules

- Tidak ada universal ending text.
- Uang bukan skor moral.
- Kios selamat tidak berarti pemain selalu membuat keputusan "terbaik".
- Kios hilang tidak berarti route harus diperlakukan sebagai game over.
- Warning 18:00 tidak boleh terasa seperti deadline palsu.
- Sentana tidak boleh dipastikan nyata sebelum pemain memilih mengejarnya.
- Pak Arman memberi batas, bukan bailout.

## Out of Scope

- Chapter 3;
- full save/load;
- full relationship system;
- market simulation;
- resale UI;
- radio optional branch.
