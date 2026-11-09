# CurseForge listing copy

**Name:** Waylaid Value

**Summary:** Compare Waylaid Crate value and plan Merchant's Favor recipe unlocks with cached auction prices.

**Game:** World of Warcraft

**Class:** Addons

**Flavor:** Forever

**Client:** Forever / Interface 16001. Select the matching Forever version offered by the upload form.

**Main category:** Auction & Economy

**Additional category:** Professions

**License:** MIT License; preserve the included third-party notices.

**Logo:** `assets/inv_crate_07.jpg` — the same WoW crate artwork used in-game.

**Screenshots:** `.previews/crates.png`, `.previews/rewards.png` (real in-game captures, capture metadata removed).

**Source:** https://github.com/casualg1t/waylaid-value

**Issues:** https://github.com/casualg1t/waylaid-value/issues

## Description

Waylaid Value helps you compare Waylaid Crates and estimate the gold needed to unlock and craft Merchant's Favor rewards in WoW Forever.

### Crates

See the cheapest priced filling bundle for each crate, the Favor it gives, the total net cost and cost per Favor. Select a crate to compare all accepted filling options. Missing prices remain visible. Muted bag counts show owned empty crates and filling materials, without changing market costs or ranking.

### Rewards

Start with your character's professions, or browse other professions. Combine search, armor type, level/class, role relevance and crafting-skill filters. For my class keeps physical DPS/general supplies for hunters and leaves unclassified items visible; All roles restores the wider list. Rewards sort by required character level, then name, with the required level and one-craft cost visible in each row. Select a reward to see its recipe Favor cost, an exact whole-crate shopping plan, crafting materials and estimated total gold. Enter Favor already held or mark an already learned recipe to remove costs you no longer need to pay. Item names/icons follow rarity and money units use gold/silver/copper colors.

### Prices

Reads cached TSM minimum-buyout prices or a compatible Auctionator v1 API. Auto prefers TSM, then Auctionator, then saved local scan quotes. Install and configure TSM with AppHelper, or a compatible Auctionator build, to see price estimates. You can also press Scan AH while the auction house is open to collect targeted local quotes. This new scanner is experimental and still needs field validation in Forever. OneForAll is not required.

Refresh recalculates existing cached prices; it does not scan the AH. Quotes do not guarantee available quantities. Turn-in silver uses the documented calculation assumption of 50 copper per base Favor, excluding first-turn-in/random bonuses. Provisional Expert rewards are opt-in; incomplete estimates are labelled.

### Open the addon

Type `/crates` or `/waylaid`, or click the crate icon on the minimap. Drag the minimap icon to reposition it.

Scanning starts only when you request it. No buying, bidding, crafting or turn-ins are automated. Open Settings for crate tooltip detail, bag reminders and minimap visibility.

### Support

Report bugs through the repository's Issues page. Include addon version, price provider and steps to reproduce. Redact character names, chat and account details from screenshots. Do not attach SavedVariables or credentials.
