# Waylaid Value

Compare the gold cost of Waylaid Crates and plan Merchant's Favor recipe unlocks in **World of Warcraft: Forever**.

Version **0.4.1** · Interface **16001** · MIT license

## What it does

- Ranks each crate with its cheapest priced filling bundle, total net cost and cost per Favor.
- Shows every accepted filling option, with native item tooltips.
- Browses rewards by profession, armor type, character level/class and crafting skill.
- Builds an exact whole-crate shopping plan for a selected reward, then adds its crafting materials.
- Separates the one-time recipe unlock from the cost of subsequent crafts.
- Reads cached prices from TSM or compatible Auctionator APIs.

Open **`/crates`**, **`/waylaid`**, or the draggable crate icon on the minimap. The window has **Crates** and **Rewards** tabs.

## Install

Download the **WaylaidValue ZIP**, rather than GitHub's source-code archive. Quit WoW, extract the `WaylaidValue` folder into `_forever_/Interface/AddOns/`, and restart. The TOC must be directly inside `AddOns/WaylaidValue/`. When updating, replace the addon folder and retain SavedVariables.

Use **TSM with TSM AppHelper**, or an Auctionator build exposing the v1 price API. OneForAll is not required. Without a price provider, the catalogue remains accessible but costs are unavailable.

## Prices and calculations

**Auto** uses TSM's `dbminbuyout` per item, then Auctionator when a price is missing. Select **TSM** or **Auctionator** to restrict the source. **Refresh recalculates cached prices; it does not scan the auction house.** TSM's public price API used here does not expose the price timestamp. Auctionator ages appear only when its optional age API is available.

Upfront cost = empty crate + one filling bundle. Net cost subtracts the assumed turn-in silver: **50 copper per base Favor**. First-turn-in and random bonuses are excluded. Check actual payouts in game. Unknown/invalid prices stay unavailable. Estimates do not verify stock, full-stack purchase costs, owned materials or vendor alternatives; no buying, crafting or turn-in automation is included.

The catalogue contains 30 crates, 96 filling bundles and 321 assembled rewards. Apprentice/Journeyman rewards are documented; Expert rewards are provisional and opt-in; unknown Artisan rewards remain unranked. Catalogue completeness is not guaranteed.

## Rewards

**My professions** starts with separate **My level / class** and **Within my skill** filters enabled. Expand **Other professions** to inspect an unlearned profession. **Browse all recipes** disables both requirement filters. Search and armor type combine with them. Unverified requirements are counted and do not pass an active requirement filter; turn the filter off to inspect them.

The level/class filter checks the finished item, including item-use profession requirements. The skill filter checks the recipe's profession rank. They do not confirm trained weapon proficiency, reputation or recipe ownership. Enter your **Favor held** and check **Recipe already learned** when applicable. Total estimated net cost includes the remaining unlock and one craft, not necessarily one output item.

## Status and known limits

This is an early public candidate. Automated Lua/JavaScript tests pass, including 963 cross-language reward-cost comparisons. Actual Forever rendering, startup timing, live Auctionator behavior and quest payouts still need field validation. Three recipe prices, one crafting-data entry, a possible tabard gold fee and consumable output yields retain documented uncertainty. Incomplete totals are labelled.

The optional offline report uses a frozen public-item price fixture from **08 Nov 2026, 07:12:13 CET, EU PvP–Horde**. It is not a live market feed. Neither account data nor SavedVariables are part of this repository or the install ZIP.

## Development

Install Lua 5.1, Node.js and Python 3 with Pillow (`python3 -m pip install -r requirements-dev.txt`), then run:

```sh
python3 tools/check.py
```

This builds the ZIP and offline report, runs the Lua and JavaScript suites, and checks catalogue/tooltip facts plus ZIP/source parity. Set `LUA=lua5.1` to select an interpreter. The addon itself has no Python or Node dependency.

Generated files are written to `outputs/` and ignored by Git. Source is in `addon/WaylaidValue/`; public test data is in `fixtures/`. See [validation](docs/VALIDATION.md), [release preparation](docs/PUBLISHING.md), and [changelog](CHANGELOG.md).

## Credits and licensing

Original addon code is MIT licensed. The reduced ProfessionDB / LibProfessionDB recipe-data extract retains its [MIT notice](addon/WaylaidValue/THIRD_PARTY_LICENSES.txt). Item names, tooltip facts and in-game texture references originate from WoW/Wowhead. Fixture icons are game artwork, not covered by the original-code MIT grant. The listing logo is original project artwork. This is an independent community addon, not affiliated with Blizzard Entertainment.
