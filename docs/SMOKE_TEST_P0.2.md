# Smoke Test — P0.2 Discovery Loop

## Setup

1. Checkout `prototype/p0.2-discovery-loop`.
2. Run project.
3. Mainkan auction sampai Lot 02 dimenangkan MC.
4. Selesaikan Lot 03.
5. Di end panel pilih `LANJUT KE TEMUAN`.

## Expected

### Entry
- Scene berjudul `MEJA PEMERIKSAAN`.
- Lot 02 tersedia hanya jika MC memang memenangkannya.
- Jika MC tidak memiliki Lot 02, scene menjelaskan bahwa tidak ada kotak untuk diperiksa.

### Kotak Campuran
- Tombol `BUKA KOTAK`.
- Setelah dibuka muncul:
  - TATAKAN
  - KOREK MEJA
  - ADAPTOR
- Setiap objek memberi observasi, bukan appraisal final.

### Target
- Setelah minimal dua objek diperiksa, pilihan target aktif.
- Pemain dapat memilih TATAKAN / KOREK / ADAPTOR / BELUM YAKIN.
- Pilihan berakhir dengan kebutuhan konteks, bukan harga atau jawaban final.

## Fail Fast

Perbaiki sebelum P0.3 jika:
- scene memberi tahu material/value final;
- satu objek diberi highlight yang jelas menunjukkan jawaban benar;
- pilihan target aktif sebelum pemain melakukan pemeriksaan;
- state kepemilikan tidak sesuai hasil auction;
- P0.2 membutuhkan peta atau specialist system supaya bisa dipahami.


### Provenance
- Lot 02 harus sudah menjelaskan bahwa kotak berasal dari bersih-bersih gudang rumah toko lama.
- Sebagian isi harus sudah terlihat saat investigasi auction.
- Setelah kotak dibuka, teks harus menjelaskan seluruh isi sebelum tiga objek fokus muncul.
- TATAKAN / KOREK / ADAPTOR dipilih sebagai fokus karena menimbulkan pertanyaan, bukan karena UI menyatakan ketiganya paling bernilai.
