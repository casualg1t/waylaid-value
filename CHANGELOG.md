# Changelog

## 0.6.1 candidate

- Match compact WoW money notation: colored denomination letters, two-digit silver/copper below gold, and explicit zero denominations (for example, 6g 06s 90c and 59g 00s 00c).

## 0.6.0 candidate — not publicly released

- Add an independent targeted AH scanner, started/stopped with `/crates scan`, with guarded pagination, throttling, cancellation and atomic snapshot replacement.
- Keep scan snapshots local to the realm/faction and show their actual timestamps; preserve TSM and Auctionator priority in Auto.
- Add crate item-tooltip sections with Off, Compact, Shift and Always modes, without triggering AH requests on hover.
- Preserve market-price ranking and owned-item reminders; scan quotes remain unit estimates, not stock-aware purchase plans.
- Add the approved Settings panel and Scan AH / Stop scan header controls, including disabled-state explanations.
- Save tooltip detail, bag reminders and minimap visibility immediately; right-click the minimap icon or use /crates settings to open preferences.

## 0.5.4

- Show owned/required filling-material counts below ranked bundles and beside every selected-crate alternative.
- Update counts when bags change; explain the reminder in item tooltips.
- Keep cheapest-bundle selection, market costs and ranking unchanged.

## 0.5.3

- Mark owned empty crates with a muted bag count, refreshed when bags change.
- Preserve market-price ranking, selection and shopping costs regardless of ownership.
- Explain the reminder in crate tooltips; exclude bank contents.

## 0.5.2

- Add explanatory tooltips to buttons, tabs, dropdown choices, inputs and profession navigation.
- Explain Expert crate tiers, provisional 15/30-Favor estimates and their opt-in behavior.
- Explain craft/unlock/net/upfront costs, filtering, missing data and price status on hover.
- Keep disabled controls explainable and make checkbox labels part of their hit area.
- Preserve row selection when clicking a price and hide owned tooltips when their controls disappear.

## 0.5.1

- Tighten reward rows from 44px to 32px and give item names more room.
- Show one-craft material cost directly beside every craftable reward, with Favor kept separate.
- Move repeated role labels to tooltips and selected detail; flag blocked requirements compactly.
- Keep missing prices explicit and show a dash for direct rewards.

## 0.5.0

- Color reward, crate and material names/icons by item rarity.
- Format gold, silver and copper units consistently; remove zero denominations from displayed money.
- Add separate class/role relevance filters for physical DPS, spell DPS, healing, tanking and general use.
- Keep uncertain roles visible under class relevance, and distinguish equip permission from role affinity.
- Refine the existing layout with a warm dark palette, original rounded skin assets, framed tabs and compact reward rows.
- Label the turn-in money deduction explicitly. A 20-Favor/10-silver field observation matches the existing math.
- Keep TSM age uncertainty in About these prices; no invented timestamp is shown.

## 0.4.1

- Correct minimap drag angles under Lua 5.1.
- Keep profession eligibility unverified after partial API failures.
- Preserve learned-recipe state when clicking the selected reward again.
- Clear reward tooltips and allow larger shopping quantities.
- Reject non-finite Favor balances and invalid HTML price inputs.
- Bound offline planning and handle missing item metadata safely.
- Verify release ZIP contents against the TOC and source files.

## 0.4.0

- Add own/other profession navigation and combined search, armor, level/class and crafting-skill filters.
- Keep total cost and inputs visible above scrolling shopping details.

## 0.3.1

- Add crafted-item and enchantment-effect tooltips with character requirements.

## 0.3.0

- Improve Crates and Rewards interiors; show line net total above cost per Favor.
- Add item-name fallbacks, price-source status and a draggable minimap crate launcher.

## 0.2.0

- Add reward unlock planning, exact whole-crate shopping, held Favor, learned recipes and one-craft materials.
