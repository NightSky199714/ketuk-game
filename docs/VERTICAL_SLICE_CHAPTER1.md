# Vertical Slice 1.0 — Chapter 1

## Purpose

Mengubah hasil P0.1–P0.3 dari kumpulan prototype menjadi satu chapter yang terasa sebagai game lengkap.

Prototype P0.2 dan P0.3 tetap ada sebagai fondasi sistem, tetapi **bukan urutan cerita Chapter 1**.

Chapter 1 mengikuti baseline canon:

```
Kios / Buku Lama
      ↓
Balai Lelang
      ↓
Lot 01 / Lot 02 / Lot 03
      ↓
Sesudah Lelang
      ↓
Pemeriksaan Pak Harun — jika pemain mengejar
      ↓
Pulang
      ↓
Buku
      ↓
BAB 1 SELESAI
```

## Opening

State awal:
- uang MC: Rp430.000;
- tunggakan kios: Rp1.200.000;
- batas pembayaran: Minggu 20:00.

Buku lama menampilkan margin:
> Kalau ragu, lihat bagian yang tidak dilihat orang.

Opening tidak menyatakan MC berbakat, genius, atau punya kemampuan supernatural.

## Auction

Menggunakan fondasi P0.1:
- investigation sebelum bidding;
- Bu Ratna sebagai end-user;
- Jaka sebagai reseller/rival;
- social post-lot drama;
- camera bluff;
- STOP/BID tetap bermakna.

Pemain harus membaca Jaka melalui perilaku/ekspresi. Narasi tidak boleh langsung berkata bahwa Jaka sedang membaca MC.

## Camera Follow-up

Reveal tidak otomatis.

Jika MC menang:
- Pak Slamet memberi alasan untuk menemui Pak Harun;
- pemain boleh periksa atau menunda.

Jika Jaka menang:
- appraisal hanya diketahui jika pemain tetap berada di sana ketika Jaka meminta Pak Harun melihat kamera.

State `camera_appraisal_seen` menentukan apakah informasi tersebut boleh dibawa ke scene rumah.

## Home

Scene rumah hanya menampilkan barang yang benar-benar dimenangkan MC.

Tidak boleh:
- menampilkan Lot 02 jika MC kalah;
- menampilkan kamera sebagai milik MC jika Jaka menang;
- membawa informasi appraisal jika pemain tidak menyaksikannya.

## Book

Jalur canon Lot 02:
> Rp95.000. Sepertinya tidak salah.

Jika pemain membayar angka berbeda dalam jalur non-canon prototype, Buku mencatat angka aktual alih-alih memalsukan Rp95.000.

Jika MC tidak memenangkan Lot 02:
- Buku tidak membuat entry kepemilikan palsu.

## End

Chapter 1 berakhir di rumah.

P0.2 Discovery Loop dan P0.3 Human Network tidak otomatis dijalankan dari Chapter 1. Keduanya tetap tersedia sebagai fondasi sistem untuk integrasi chapter berikutnya.

## Success Criteria

Vertical Slice Chapter 1 lolos jika:
1. F5 dimulai dari konteks kios, bukan ruang lelang;
2. pemain memahami tekanan uang tanpa exposition panjang;
3. auction tetap merupakan inti gameplay;
4. hasil lot mengubah barang yang benar-benar dibawa pulang;
5. appraisal hanya diketahui jika disaksikan;
6. Buku merekam hasil yang benar-benar terjadi;
7. chapter punya pembuka dan penutup yang terasa utuh.
