# Waylaid Value 0.5.4

First public download for World of Warcraft: Forever (Interface 16001).

- Compare empty crates plus one accepted filling bundle by total net gold and gold per Merchant’s Favor.
- Browse profession rewards with rarity colors, class/level, crafting-skill, armor and role filters.
- See one-craft material prices directly in the rewards list, plus a whole-crate Favor plan and recipe unlock cost in the detail panel.
- Use TSM cached minimum-buyout prices or a compatible Auctionator v1 API. Refresh recalculates existing quotes; it does not scan the AH.
- Hover controls and items for explanations. Open with `/crates`, `/waylaid` or the draggable crate minimap icon.
- View owned empty crates and filling materials as subtle bag reminders. Inventory does not change prices or ranking.

## Install

In WoWUp, select Forever and use **Get Addons → Install from URL** with https://github.com/casualg1t/waylaid-value.

For manual installation, extract `WaylaidValue-0.5.4-forever.zip` into `_forever_/Interface/AddOns/`. Keep existing SavedVariables when updating. This release supports Forever, not Retail or Classic Era.

## Estimate limits

TSM quotes have no timestamp exposed by the public API used here. Available stock is not verified. Auctionator’s API adapter is feature-detected but has not been field-tested on Forever. Turn-in money assumes 50 copper per base Favor; a 20-Favor/10-silver turn-in was observed. Expert Favor estimates remain unverified and off by default; Rewards planning uses documented tiers only. Unknown prices or catalogue facts remain explicit. Role filters are relevance hints, not gear upgrade scores. One craft may yield multiple items.

Both tabs are shown in real Forever screenshots. Automated Lua 5.1/current Lua, pricing, UI-callback, catalogue, JavaScript and ZIP checks pass; this does not establish every native interaction or integration as field-tested.
