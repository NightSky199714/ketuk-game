# KETUK. — 0.1.0-rc1 Release Notes

## What This Build Is

The first release-candidate for the playable KETUK. demo.

The project has moved beyond isolated auction prototypes into a connected exploration loop.

## Highlights

- Main Menu with Game Baru / Lanjutkan.
- Versioned save data and safe resume scenes.
- Auction UI migrated from code-built layout into `.tscn`.
- Inventory based on actual auction ownership.
- Mixed Box that must be opened through world interaction.
- Persistent Buku Lama.
- Open-ended location exploration without explicit quest route buttons.
- World time and hidden opening hours.
- NPC schedules in Pasar Tua.
- NPC memory for previously shown objects.
- Rumor state separated from verified knowledge.
- Manual kiosk payment and deadline consequences.
- Persistent world ↔ Pasar Tua state.
- Windows Desktop export preset.
- Web export preset.
- Local PowerShell smoke/build scripts.

## Known RC Limitations

- Visuals are still largely functional/placeholder.
- NPC expressions are text placeholders.
- Bid AI intentionally remains simple.
- Content after the current Sentana setup is not yet the full game.
- Android store packaging is not part of this RC.

## Save Compatibility

Save schema: v1.

Future incompatible state changes must either:
- migrate v1 saves, or
- increment save version and explicitly communicate incompatibility.

Do not silently reinterpret old save fields.
