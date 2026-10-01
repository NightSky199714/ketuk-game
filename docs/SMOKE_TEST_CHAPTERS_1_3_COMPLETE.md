# Smoke Test — Full Run Chapters 1–3

## Goal

One test pass should verify the entire playable arc.

Do not review each subsystem separately unless this full run exposes a failure.

---

## Setup

1. Checkout:
   `vertical-slice/chapter-1-3-complete`
2. Open project in Godot.
3. F5.

Expected boot:
- KETUK. — Di Balik Harga
- Chapter 1 opening
- not a P0.x screen

---

## Full Canon-ish Run

### Chapter 1
Recommended test path:
- skip/lose Lot 01
- win Lot 02 around Rp95.000
- play Lot 03
- witness Pak Harun appraisal

Verify:
- opening state is preserved into auction
- Lot 02 becomes owned only if won
- home offers BUKA KOTAK
- Coaster / Lighter / Adapter can be inspected
- Book uses actual Lot 02 price
- appraisal knowledge is remembered only if witnessed
- button continues to Chapter 2

### Chapter 2
Choose any one route for the first pass.

Recommended:
- pursue Adi
- reach 18:00 warning
- request Pak Arman extension
- complete Monday 09:00 transaction

Verify:
- money carries from Chapter 1
- deadline is Sunday 20:00
- 18:00 is warning, not failure
- lens-only sale is Rp2.100.000
- body is returned
- kiosk payment removes Rp1.200.000
- route continues to Chapter 3

### Chapter 3
Verify:
- Pasar Tua is a location map, not a specialist list
- Pak Wira is the initial known lead
- Pak Damar exists at Kedai Pojok
- Bu Sari is at Gang Timur
- Yanto is at Lorong Belakang
- player must travel between locations
- Book records people
- if Lot 02 is owned, Bu Sari can establish:
  - yellow surface is layered
  - not solid brass
- Yanto does not claim rarity from an unreadable/worn mark
- after all four contacts, player must travel to the notice-board area
- poster reads SENTANA PRIVATE AUCTION
- requirement is INVITE REQUIRED
- MC photographs the poster
- Chapter 3 ends
- MAIN DARI AWAL returns to Chapter 1 opening

---

## Ownership Regression Run

Repeat with Lot 02 lost.

Verify:
- no Mixed Box at home
- Chapter 1 does not invent the box
- Chapter 3 does not invent the coaster
- NPCs discuss network/knowledge boundaries instead
- Chapter 3 still completes

---

## Camera Regression Run

Repeat without winning camera.

Verify:
- Chapter 2 does not create a camera
- no-camera route remains playable
- kiosk can be lost
- story continues to Chapter 3
- no game-over wall

---

## Sentana Long-Chase Run

Win camera, then in Chapter 2:
- choose Sentana
- continue after 18:00

Verify:
- deadline passes
- kiosk is lost
- Sentana offer Rp3.800.000 arrives Monday
- high offer does not restore kiosk
- Chapter 3 poster recognizes the same name
- poster still requires invitation

---

## Fail Fast

Treat these as blockers:
- parse error on F5
- Chapter transition dead-end
- lost item appears later
- money resets between Chapters 1 and 2
- 18:00 treated as deadline
- direct teleport from referral to specialist
- all NPCs behave as universal appraisers
- poster is torn down instead of photographed
- Chapter 3 ends before the poster
- restart does not return to Chapter 1
