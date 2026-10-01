# Smoke Test — P0.3 Human Network

## Setup

1. Checkout `prototype/p0.3-human-network`.
2. Mainkan sampai P0.2.
3. Pilih target TATAKAN, KOREK, ADAPTOR, atau BELUM YAKIN.
4. Tekan `CARI ORANG YANG TAHU`.

## Expected

### Entry
- Scene menampilkan pertanyaan/target yang dipilih.
- Kontak tersedia:
  - PAK WIRA
  - BU SARI
  - YANTO

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
