# KETUK. — Flowing World + Inventory

## Direction

The game should feel like a connected place, not a sequence of chapters or route menus.

The player:
- owns physical items;
- carries them in inventory;
- visits places;
- shows items to people;
- learns through trial, error, observation, and conversation.

Visible chapter labels are removed from the playable flow.

Internal scene/variable names may still use old chapter naming for now. That is implementation detail only.

---

## Inventory

Inventory stores only items the MC actually owns.

Auction consequences:
- win Lot 02 → `KOTAK CAMPURAN`
- win Lot 03 → `KAMERA ANALOG`
- lose a lot → its item never appears in inventory

### Mixed Box

Initial state:
- closed
- contains several unknown objects
- lid/mechanism does not open by hand

Inventory does **not** say:
- go to a craftsman
- go to Yanto
- use a specific tool

The player must try places or people.

Possible successful ways in current slice:
- Bengkel Umum
- Yanto in Pasar Tua

After successful opening, inventory adds:
- Tatakan Logam
- Korek Meja
- Adaptor Lama

Only then can those objects be investigated separately.

---

## Item Knowledge

An inventory description represents what the MC currently knows.

It may change when:
- an item is opened;
- an expert observes it;
- a transaction changes ownership/state;
- new context is discovered.

Example:

Before context:
> KOREK MEJA — mekanismenya seret. Ada cap kecil yang aus.

After useful context:
> Mekanisme tua dapat diperiksa, tetapi cap belum cukup menentukan identitas atau kelangkaan.

The description must not jump directly to a final answer.

---

## Showing Items

Selecting an inventory item does not create a quest.

It only makes `TUNJUKKAN BARANG` available where appropriate.

Wrong place/person can respond with:
- not my field;
- I can only comment on one part;
- no useful reaction;
- a vague clue;
- caution against making assumptions.

Correct context may produce:
- a useful observation;
- a new person/place name;
- a transaction;
- a state change.

---

## Camera

The camera is not a prebuilt sell route.

Player flow can be:
- show it to Pak Harun;
- hear a price;
- hear a name;
- leave;
- ask Bu Ratna;
- chase a rumor;
- sell later;
- forget the kiosk deadline;
- or do something else.

Selling the camera only puts money in cash.

It does **not** automatically pay the kiosk.

The player must still remember Pak Arman.

---

## World Map

The map shows places, not answers.

Initial examples:
- Rumah / Kios
- Toko Kamera
- Warung Bu Ratna
- Rumah Pak Arman
- Bengkel Umum
- Pasar Tua

Later-known places can appear from information gained in-world:
- Kedai Foto Lama
- Terminal Kota
- Alamat di Kota

Descriptions should describe the place, not tell the player its gameplay function.

---

## Pasar Tua

Pasar Tua is reusable.

Player can:
- enter;
- leave;
- return later;
- keep the same inventory;
- keep discovered people;
- keep item knowledge;
- keep world time.

It is not a chapter-ending scene.

NPC names are not attached to map buttons as quest markers.

---

## Shared Time

Time continues across:
- world travel;
- Pasar Tua movement;
- conversations;
- item inspection;
- waiting.

Exploration can therefore cause the kiosk deadline to pass.

The world does not pause just because the player entered another scene.

---

## Sentana

Sentana should remain ambiguous until evidence accumulates.

A rumor can produce:
- a name;
- an uncertain address;
- eventually a poster/photo.

The poster becomes an inventory item after photographing it:
`FOTO POSTER SENTANA`

It is a world discovery, not a chapter ending.

---

## Design Rule

The target feeling is:

> "I have this thing. Where could I try using/showing it?"

not:

> "The game told me the next objective."
