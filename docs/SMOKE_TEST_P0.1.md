# Smoke Test — P0.1 Auction Feel

## Setup

1. Install Godot 4.x.
2. Clone repository.
3. Checkout branch:
   `prototype/p0.1-auction-feel`
4. Import `project.godot` in Godot.
5. Run project.

## Expected Flow

### Investigation — semua lot
Setiap lot harus masuk layar investigasi sebelum bidding.
- Lot 01: LUAR / BAWAH / KABEL
- Lot 02: ATAS / SAMPING / ANGKAT
- Lot 03: BODY / LENSA / TAS
- Pemain boleh memeriksa satu, beberapa, semua, atau langsung menekan MULAI BIDDING.
- Investigasi tidak boleh langsung memberi label "langka", "mahal", atau jawaban nilai final.

### Lot 01
- Opening bid Rp40.000.
- BID path lets Bu Ratna counter up to Rp130.000.
- At MC bid Rp125.000, Pak Slamet says:
  `Yang baru harganya berapa?`
- If MC bids above Bu Ratna's limit, she stops.

### Lot 02
- Jaka counters through Rp75.000 then Rp90.000.
- At Rp95.000, Jaka should stop and MC wins.

### Lot 03 — Investigation
- Buttons BODY / LENSA / TAS are visible.
- Investigation remains optional.
- LENSA clue must mention:
  - number format differs from body;
  - engraving appears only on lens.

### Lot 03 — Bluff
Expected main path:
- Bu Ratna: Rp100.000
- Jaka: Rp120.000
- MC: Rp150.000
- Jaka: Rp180.000
- MC: Rp200.000
- Jaka: Rp230.000

Then:
- STOP → Jaka wins and should switch to SURPRISED.
- BID → MC bids Rp260.000; Jaka refuses to cross bluff threshold and MC wins.

### Post-Lot Drama
- Setelah lot selesai, harus ada 1–4 beat sosial pendek sebelum pindah lot/reveal.
- Reaksi harus mengikuti pemenang, bukan selalu dialog yang sama.
- Lot 01: Bu Ratna menang → komentar soal nilai guna; MC menang → Jaka/Bu Ratna mempertanyakan hitungannya.
- Lot 02: MC menang → Jaka mengejek harga, Pak Slamet menahan kesimpulan; Jaka menang → Bu Ratna membalas sindiran.
- Lot 03: Jaka menang → ia sempat mengejek lalu mulai melihat kameranya; MC menang → Jaka mengejek risiko lalu Pak Slamet hanya `Hm.`.
- Drama tidak boleh membuat reveal bocor lebih awal.

### Reveal
- Scene changes automatically after Lot 03 drama.
- Reveal sequence lasts roughly half a minute.
- Body value appears before lens value.
- Lens estimate ends at Rp2.800.000–Rp3.600.000.
- MAIN LAGI returns to Lot 01.

## Fail Fast Conditions

Stop testing and fix before adding art if:
- scene fails to load;
- any button becomes permanently disabled unexpectedly;
- current bid or bidder desynchronizes;
- Jaka bids above Rp230.000;
- money is deducted when Jaka wins;
- reveal does not know who owns the camera.

## Playtest Observation

Do not explain bluff logic before the test.

After play:
1. Tadi Jaka sebenarnya mau barangnya atau tidak?
2. Kenapa kamu memilih STOP / BID?
3. Sebelum reveal, menurutmu kamera itu bernilai berapa?
4. Kalau main lagi, apa yang ingin kamu ubah?
