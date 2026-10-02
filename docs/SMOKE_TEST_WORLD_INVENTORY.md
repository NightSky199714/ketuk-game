# Smoke Test — Flowing World + Inventory

## Auction Ownership

### Win Lot 02
Expected inventory:
- KOTAK CAMPURAN

Not expected yet:
- Tatakan
- Korek
- Adaptor

### Lose Lot 02
Expected:
- no mixed box
- no contents later

### Win Lot 03
Expected inventory:
- KAMERA ANALOG

---

## Home

After auction:
- no BAB 1 label
- no automatic box opening
- inventory can be inspected
- mixed box description only says what is physically observable
- KELUAR RUMAH enters the world

---

## Mixed Box Trial

Select KOTAK CAMPURAN.

Try several places.

Expected:
- camera shop does not solve it;
- warung does not solve it;
- generic responses are allowed;
- Bengkel Umum can open it;
- Yanto can also open it if player reaches him in Pasar Tua.

After opening:
- Tatakan Logam appears
- Korek Meja appears
- Adaptor Lama appears

The three items must not exist before opening.

---

## Camera Trial

Select KAMERA ANALOG.

At Toko Kamera:
- talking alone does not automatically sell it;
- showing the selected camera creates a real offer;
- offer can change with time;
- accepting removes camera from inventory and adds cash.

At Warung Bu Ratna:
- showing camera may surface a rumor;
- rumor is not guaranteed truth.

Selling camera:
- does not automatically pay kiosk.

---

## Kiosk

Player must still visit Pak Arman.

If deadline passes while:
- wandering;
- waiting;
- exploring Pasar Tua;
- talking to people;

the kiosk can still be lost.

No game-over wall.

---

## Pasar Tua

- no BAB 3 label
- can enter and exit freely
- inventory persists
- map shows place names only
- player can select any inventory item
- TUNJUKKAN BARANG works with the currently selected item
- wrong NPC can give limited/no useful context
- Yanto can open closed mixed box
- opening box updates inventory immediately

---

## Poster

After enough world activity:
- visit Papan Pengumuman
- inspect locally
- poster is photographed
- FOTO POSTER SENTANA appears in inventory
- player can leave market afterward
- no "chapter complete" screen

---

## Flow Regression

Blockers:
- any visible BAB 1 / BAB 2 / BAB 3 label
- box opens automatically at home
- box contents exist before opening
- sale pays kiosk automatically
- inventory resets when entering/leaving Pasar Tua
- world time resets on re-entry
- deadline pauses inside Pasar Tua
- map labels reveal expert answers
- selected item silently changes to another item
