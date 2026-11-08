# Waylaid Value 0.5.0 — UI and relevance

- Item-rarity colors for names and icon borders, including the Rewards list and selected item.
- Consistent colored gold/silver/copper units and clearer turn-in money deductions.
- Class relevance plus explicit physical DPS, spell DPS, healing, tank and general-use filters. Hunter defaults hide clearly healer/caster-only gear; unknown roles remain available without guessed upgrade scores.
- Warmer rounded controls, framed tabs and compact rows within the same window size and layout.

The existing math already subtracts turn-in silver at 50 copper/Favor: 20 Favor corresponds to 10 silver. That observed turn-in matches the model; other tiers and bonuses still need confirmation.

Automated checks pass; the updated native skin still needs in-game visual verification. TSM price age remains unavailable through the public API used here. The addon does not scan, buy, craft or turn in crates.

Quit WoW, replace the WaylaidValue folder with the folder in the install ZIP, and restart so the new skin textures load. Retain SavedVariables. Open /crates.
