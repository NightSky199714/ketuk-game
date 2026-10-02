# KETUK. — Clue-Driven Exploration Rules

## Core Rule

The game should not present the solution path as a menu.

Bad:
- JUAL SEKARANG
- CARI ADI
- KEJAR SENTANA
- TEMUI BU SARI
- PERGI KE YANTO

Better:
- present a problem;
- let the player visit places;
- let conversations produce clues;
- add places to the map only when the MC has a reason to know them;
- let the player connect clue → place → person.

## Map Principle

The map shows **places**, not answers.

Examples:
- TOKO KAMERA
- WARUNG BU RATNA
- RUMAH PAK ARMAN
- KEDAI FOTO LAMA
- TERMINAL KOTA
- GANG TIMUR
- LORONG BELAKANG

Do not write:
- TOKO KAMERA — JUAL KAMERA DI SINI
- GANG TIMUR — BU SARI AHLI LOGAM
- LORONG BELAKANG — YANTO UNTUK KOREK

A person name may become visible after the MC has actually met that person, but it must not function as a quest marker.

## Clue Principle

Dialogue can be specific enough to be fair without becoming an instruction overlay.

Example:
> "Damar biasanya ngopi di ujung pasar."

The player can infer:
- Kedai Pojok may be worth checking.

Example:
> "Dia suka bongkar jam dan korek di lorong sempit belakang pasar."

The player can infer:
- Lorong Belakang may contain the right person.

The UI should not append:
> Petunjuk: YANTO — LORONG BELAKANG

## Chapter 2 — Selling Camera

The player is not shown three routes.

Instead:
1. Camera is an owned object.
2. Kiosk debt/deadline is visible.
3. Player chooses where to go.
4. Pak Harun can make a cash offer after seeing the camera.
5. Harun can mention Adi naturally.
6. Bu Ratna can surface the name Sentana as a rumor.
7. New places become known because of those conversations.
8. The player decides whether those leads are worth time.
9. Selling the camera does not automatically pay the kiosk.
10. The player must still remember Pak Arman and the deadline.

This makes time, knowledge, location, and liquidity part of play instead of route-selection text.

## Chapter 3 — Human Network

The Pasar Tua map shows places.

NPC expertise must be discovered by:
- dialogue;
- observation;
- previous knowledge;
- trying the wrong person.

Wrong person is not a failure screen.

The game never teleports the player from a referral to the correct NPC.

## Epistemic UI

The UI may display:
- facts the MC knows;
- names the MC has heard;
- places the MC can locate;
- temporary notes;
- time/deadline.

The UI should not display:
- omniscient NPC positions;
- unexplained expert labels;
- hidden route names;
- "correct next step";
- future consequences.

## Design Goal

The desired feeling is:

> "I think I know where I should try next."

not:

> "The game told me which button advances the quest."
