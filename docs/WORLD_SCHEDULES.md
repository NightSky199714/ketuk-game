# KETUK. — Hidden Schedules

## Principle

Places and people have routines.

The player may:
- arrive too early;
- arrive too late;
- find a table empty;
- find a shop closed;
- return later and find someone there.

The UI does not expose exact schedules as quest markers.

## World Locations

Common locations remain visible even when closed.

A failed visit still costs travel time.

Examples:
- Toko Kamera can be closed.
- Bengkel Umum can be closed.
- Kedai Foto can be open without Adi being present.
- Pasar Tua can be mostly closed even though the map location still exists.

The player learns routines by observation and repetition.

## Pasar Tua NPCs

NPC availability depends on world time.

Current prototype examples:
- Pak Wira: afternoon / daytime pattern.
- Pak Damar: often later at Kedai Pojok.
- Bu Sari: workshop hours.
- Yanto: later and irregular-feeling window.

These exact times are implementation data, not player-facing quest text.

## Waiting

The player can spend time naturally:
- wait at home;
- sit for a while at selected public market locations;
- travel;
- talk;
- show an item.

Waiting refreshes who is present.

## Alternate Discovery

Common places do not require a quest lead to exist on the map.

The player can discover:
- Adi by bringing a camera to Kedai Foto;
- Sentana context through Bu Ratna;
- Sentana context later through a poster/photo and people at Terminal Kota;
- Mixed Box opening through Bengkel Umum or Yanto.

The game should support multiple paths to useful context.

## Poster Timing

The Sentana poster appears because world time advances, not because a hidden interaction counter reaches a threshold.

Visiting the board early may show nothing important.
Returning later can reveal the poster.

## Goal

The player should think:

> "Maybe they're here at another time."

and:

> "Maybe this place is useful for this item."

The game should not answer either question automatically.
