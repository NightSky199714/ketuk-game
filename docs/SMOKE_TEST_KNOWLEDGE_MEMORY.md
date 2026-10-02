# Smoke Test — Knowledge + NPC Memory

## Book

At game start:
- BUKU LAMA exists in inventory.

Click it:
- no quest list;
- only current notes.

After meeting people / hearing rumors:
- Book updates without requiring a separate quest screen.

---

## Adi Rumor

Show camera at Kedai Foto or hear about Adi from Pak Harun.

Expected Book:
- DENGAR — Adi may buy old lenses.

Do not treat this as verified yet.

Actually meet Adi and sell the lens.

Expected:
- same knowledge becomes TERVERIFIKASI;
- body camera remains in inventory.

---

## Sentana Rumor

Show camera to Bu Ratna.

Expected:
- DENGAR entry about Sentana;
- no claim that the rumor is proven.

Find the poster later.

Expected:
- Sentana/private-auction information becomes verified only to the extent shown by the poster.

Do not infer:
- Sentana personally owns the venue;
- Sentana is present;
- Sentana will buy the camera;
- the uncertain city address is automatically correct.

---

## Address

Hear an address at Terminal Kota.

Expected:
- DENGAR / uncertain context.

Visit the address.

Expected:
- Book may verify that the address exists;
- it must not automatically verify that Sentana is there.

---

## Repeated Item Showing

Show the same item to the same Pasar Tua NPC twice.

Expected second interaction:
- no repeated discovery reward;
- NPC remembers seeing it;
- no duplicate item knowledge.

Repeat with:
- Bu Ratna;
- Kedai Foto keeper;
- Terminal;
- Pak Arman;
- generic craftsman.

Expected:
- repeated showing does not replay first-time information.

---

## Schedule + Memory

Show an item to an NPC, leave, return at another time.

Expected:
- memory survives schedule disappearance/reappearance;
- NPC does not reset because they left the location.

---

## Regression Blockers

- rumor immediately treated as fact;
- poster verifies claims it does not actually prove;
- repeated item showing creates duplicate discoveries;
- Book resets when leaving Pasar Tua;
- Book acts as a route/objective list;
- BUKU LAMA disappears from inventory after reset/start.
