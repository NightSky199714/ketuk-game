# KETUK. — UI Direction 0.1.4

Status: active visual-polish direction before further feature expansion.

## North star

The current visual references establish KETUK. as a portrait-first Indonesian auction adventure whose UI should feel physically embedded in its world.

The interface should read as:
- old auction hall / village civic space;
- warm wood, worn paper, ink, stamp, brass, and dark painted signboards;
- red-brown action accents;
- tactile cards and buttons rather than flat app panels;
- Indonesian local atmosphere rather than generic fantasy or generic mobile UI.

## Layout principles

1. **Portrait-first, 9:16**
   - Keep the existing 720 × 1280 logical viewport.
   - Primary actions must remain reachable without hunting through scroll.

2. **World first, UI second**
   - The long-term target is illustrated/location-aware backgrounds.
   - Panels should frame the world rather than replace it.

3. **Persistent action zones**
   - Core action buttons belong in a stable bottom dock when practical.
   - Long narrative, inventory, map, and notes may scroll independently.

4. **Clear visual hierarchy**
   - Dark signboard: place/chapter/title.
   - Cream paper: readable information, inventory, notes.
   - Red-brown: primary action / current focus.
   - Near-black: secondary/exit/destructive actions.

5. **Diegetic surfaces**
   - Prefer visual metaphors such as paper slips, auction placards, notebooks, maps, tags, and signboards.
   - Avoid dashboard-like cards when a world object can communicate the same role.

## Reference screen patterns

### Main menu
- Large KETUK. sign/logo.
- Warm auction-hall atmosphere.
- One dominant primary Continue action.
- New Game / Settings / Exit read as physical boards or tickets.

### Auction
- Lot/object remains the hero.
- Bid state is visually dominant.
- BID / WAIT / STOP stay fixed and immediately reachable.
- NPC reactions support the object rather than competing with it.

### Inventory
- Left/list selection plus large item focus/detail.
- Selected item should feel like a physical object on a table.
- Notes belong to the object, not as detached system text.

### World / map
- Location image/map should become the primary canvas.
- Money/status can remain compact in the top HUD.
- Bottom area should surface current contextual actions and notebook/inventory access.

### Pasar Tua / people network
- NPC/place is the hero.
- Dialogue and findings appear on paper/notebook surfaces.
- Book/notes should feel like a persistent investigation object.

## Current implementation phase

Phase A — structure and tactile styling:
- paper/signboard theme variations;
- stronger shadows/borders;
- fixed action docks;
- clearer content hierarchy;
- no gameplay rule changes.

Phase B — art asset pass:
- main-menu background;
- world/map background;
- auction/location scene art;
- inventory object presentation;
- NPC/location-specific backdrops.

Do not start Phase B until Phase A passes runtime and manual portrait acceptance.
