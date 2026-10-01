# Smoke Test — Clue-Driven Exploration

## Chapter 2

At Chapter 2 start verify:
- no buttons named JUAL SEKARANG;
- no CARI ADI;
- no KEJAR SENTANA;
- map initially shows only places MC already knows;
- camera is still an owned object, not a route.

### Camera Shop
Visit TOKO KAMERA.

Expected:
- talking to Pak Harun produces an offer;
- accepting offer is possible only after the offer exists;
- Harun naturally mentions Adi;
- KEDAI FOTO LAMA becomes known after that conversation;
- if player leaves and returns after 18:00, stale Rp1.650.000 offer must not survive unchanged.

### Bu Ratna
Visit WARUNG BU RATNA.

Expected:
- Sentana appears as a rumor, not a route title;
- TERMINAL KOTA becomes knowable from the context;
- no exact Sentana address is given yet.

### Terminal
Visit TERMINAL KOTA after hearing the rumor.

Expected:
- asking around consumes time;
- an uncertain address can be discovered;
- ALAMAT DI KOTA appears only after this information exists.

### Kiosk Payment
After selling:
- money is in player cash;
- kiosk is not automatically saved;
- player must remember to visit Pak Arman and pay;
- wandering too long can still lose the kiosk.

### Adi
After Harun lead:
- Kedai Foto on Sunday reveals Monday timing and lens-only offer;
- player must infer that Pak Arman is relevant for the deadline;
- extension comes from talking to Pak Arman, not a route-selection menu.

## Chapter 3

Verify:
- map buttons show place names, not NPC names;
- no UI string "Petunjuk: NAME — LOCATION";
- no PERGI KE PAPAN PENGUMUMAN button from another location;
- player can visit wrong locations freely;
- dialogue clues suggest where someone may be without creating a waypoint;
- notice board must be visited directly;
- SENTANA poster becomes meaningful at the board, not through teleport.

## Target Continuity

Choose KOREK in Chapter 1.

Expected Chapter 3:
- Wira discusses the korek/mechanism uncertainty;
- Damar points indirectly toward a person who handles small mechanisms;
- Yanto resolves the mechanical context;
- Bu Sari is optional and does not hijack the route into tatakan.

Repeat with TATAKAN:
- metal-related clues should naturally make Gang Timur relevant.

Repeat with ADAPTOR:
- network gap remains valid;
- game does not manufacture a universal electronics expert.

## Fail Fast

Blockers:
- route-selection menu returns;
- map labels include expert answers;
- referral teleports the player;
- stale offer ignores time;
- sold item remains available for another sale;
- wrong object becomes the active topic;
- deadline is paid automatically after a sale.
