# Auction UI & Bid Logic Architecture

## Decision

### Auction UI

Accepted: move the auction layout into `.tscn`.

Reason:
- auction structure is already stable enough;
- portrait/expression placeholders will eventually become visual assets;
- spacing and hierarchy need editor-driven iteration;
- the controller had become responsible for both presentation construction and auction behavior.

Current split:

```
scenes/auction/auction_room.tscn
  → layout / labels / buttons / containers / visual hierarchy

scripts/auction/auction_controller.gd
  → lot flow / investigation / bids / drama / state transitions
```

The controller binds existing scene nodes and wires signals. It must not recreate the screen with `Label.new()`, `Button.new()`, etc.

## Rule for Other Screens

Do not migrate every code-built UI mechanically.

Use this rule:

- stable interaction structure → move to `.tscn`;
- rapidly changing prototype structure → code-built UI is temporarily acceptable;
- repeated/data-driven content can still be generated dynamically inside a scene-owned container.

This avoids paying migration cost twice while the world/inventory interaction model is still changing.

The world map and Pasar Tua screens should migrate after their interaction structure settles.

---

## Bid Logic

Current `bid_logic.gd` stays intentionally simple.

Current responsibility:
- deterministic prototype bidding;
- static NPC lot interest;
- Jaka Lot 03 bluff behavior.

Do **not** add relationship/mood simulation yet.

### Future input contract

When the auction system needs richer NPC behavior, extend decision context rather than hard-coding new global lookups.

Conceptually:

```gdscript
decide_bid(
    npc_id,
    lot_id,
    current_bid,
    mc_last_bid,
    npc,
    context
)
```

Possible future `context` fields:

```
relationship
session_memory
npc_mood
cash_pressure
known_item_clues
recent_player_behavior
lot_history
```

This is a future contract, not current implementation.

### Rule

Add a new bidding factor only when gameplay can make the player perceive it.

Bad:
- invisible complexity that only changes random numbers.

Good:
- Jaka remembers being baited;
- a merchant protects resale margin;
- an NPC who needs an item personally tolerates a higher price;
- prior social conflict changes aggression in a readable way.

The bidding system should remain explainable through observable behavior.
