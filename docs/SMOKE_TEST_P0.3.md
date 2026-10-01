# Smoke Test — P0.3 Human Network

## Setup

1. Checkout `prototype/p0.3-human-network`.
2. Mainkan sampai P0.2.
3. Pilih target TATAKAN, KOREK, ADAPTOR, atau BELUM YAKIN.
4. Tekan `CARI ORANG YANG TAHU`.

## Expected

### Entry
- Scene menampilkan pertanyaan/target yang dipilih.
- Scene berupa peta Pasar Tua, bukan daftar tiga specialist.
- Lokasi tersedia:
  - PINTU PASAR
  - KIOS TENGAH
  - GANG TIMUR
  - LORONG BELAKANG
- Pak Wira dapat dicari di Kios Tengah berdasarkan petunjuk Pak Slamet.
- Bu Sari dan Yanto berada di lokasi berbeda dan tidak harus diketahui sejak awal.

### Wrong Specialist
- Salah memilih orang tidak menyebabkan failure.
- NPC menyatakan batas pengetahuannya.
- Referral muncul hanya jika masuk akal.

### TATAKAN
- Bu Sari memberi konteks logam.
- Tidak ada "harga sebenarnya".
- Hasil mempersempit: bukan kuningan padat / permukaan berlapis.

### KOREK
- Yanto memberi konteks mekanisme.
- Cap aus tetap belum memastikan identitas/kelangkaan.

### ADAPTOR
- Tidak ada kontak prototype yang memberi identifikasi final.
- Pak Wira menyatakan perlu memperluas jaringan.

### BELUM YAKIN
- Tetap boleh masuk ke Human Network.
- NPC tidak memberi appraisal.
- Respons membantu pemain menyadari bahwa pertanyaannya terlalu luas dan perlu dipersempit.

## Fail Fast

Perbaiki sebelum sistem map jika:
- semua NPC memberi jawaban yang sama;
- NPC salah tetap memberi appraisal final;
- game otomatis memilih specialist yang benar;
- target ADAPTOR tetap mendapat jawaban sempurna;
- NPC memberi harga kolektor tanpa dasar.


### Continuation from P0.1
- End panel P0.1 selalu punya jalur lanjut.
- Jika MC memiliki Lot 02: tombol `LANJUT KE TEMUAN`.
- Jika MC tidak memiliki Lot 02: tombol `UJI DISCOVERY P0.2`.
- Fallback prototype tidak mengubah pemenang Lot 02; hanya menyediakan sampel agar P0.2/P0.3 dapat diuji.
- Setelah memilih target di Discovery, tombol `CARI ORANG YANG TAHU` harus membawa pemain ke P0.3.


### Referral + Travel
- Referral tidak boleh memindahkan pemain otomatis.
- Pak Wira → Bu Sari harus memberi petunjuk Gang Timur.
- Pak Wira → Yanto harus memberi petunjuk Lorong Belakang.
- Pemain kembali memilih lokasi sendiri di peta.
- Hitungan langkah perjalanan bertambah saat berpindah lokasi.
- Pemain boleh menjelajah Gang Timur/Lorong Belakang dan menemukan kontak tanpa referral.
