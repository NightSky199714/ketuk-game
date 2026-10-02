# KETUK. — Di Balik Harga

> Setiap tawaran punya harga.

**KETUK.** adalah game auction-adventure berlatar Indonesia tentang membaca nilai barang, membaca manusia, mencari konteks, mengambil risiko, dan hidup dengan konsekuensi keputusan.

## Status

**0.1.0-rc1 — Release Candidate**

Build ini bukan lagi prototype P0.1 terpisah. Flow utama sekarang menghubungkan:
- pembuka dan lelang;
- inventory nyata berdasarkan barang yang benar-benar dimenangkan;
- eksplorasi lokasi;
- waktu dunia dan jadwal tersembunyi;
- jaringan NPC;
- rumor vs informasi terverifikasi;
- konsekuensi ekonomi kios;
- Save / Continue;
- Windows dan Web export presets.

## Core Loop

```
Lelang
→ memperoleh / kehilangan barang
→ inventory
→ mencoba tempat dan orang
→ observasi / rumor / konteks
→ Buku Lama
→ keputusan ekonomi
→ konsekuensi dunia
→ eksplorasi berikutnya
```

Game tidak menampilkan jalur benar sebagai quest marker. Peta menampilkan tempat yang diketahui MC; pemain menyimpulkan sendiri tempat atau orang yang layak dicoba.

## Current Playable Content

- Balai Lelang Kampung Suka Jaya
- 3 lot awal
- BID / WAIT / STOP
- pre-bid investigation
- post-lot social drama
- KOTAK CAMPURAN yang harus dibuka melalui konteks dunia
- Kamera Analog dengan beberapa kemungkinan transaksi/informasi
- Rumah / Kios
- Toko Kamera
- Warung Bu Ratna
- Rumah Pak Arman
- Bengkel Umum
- Kedai Foto Lama
- Terminal Kota
- Pasar Tua
- hidden schedules / opening hours
- Buku Lama sebagai inventory knowledge record
- rumor state: DENGAR / TERVERIFIKASI
- NPC memory untuk item yang pernah diperiksa
- Save / Continue dari Main Menu

## Engine

Godot 4.x, GL Compatibility.

Viewport target saat ini: 720 × 1280 (portrait-first).

## Local Validation

Headless smoke gate:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\release_check.ps1 -GodotPath "PATH_KE_GODOT.exe"
```

Release build:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build_release.ps1 -GodotPath "PATH_KE_GODOT.exe" -Target all
```

Export templates Godot harus sudah terpasang.

## Release Outputs

```
build/windows/KETUK.exe
build/web/KETUK-web.zip
build/web/site/index.html
```

Folder `build/` tidak masuk Git.

## Branch

Current release-candidate work:
- `vertical-slice/chapter-1-3-complete`

Draft integration PR:
- PR #6

## Design Rule

Pemain seharusnya berpikir:

> “Aku punya benda ini. Coba kubawa ke mana?”

bukan:

> “Game menyuruhku menekan objective berikutnya.”
