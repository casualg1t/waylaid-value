# WaylaidCost review and 0.6.0 candidate checkpoint

The reviewed addon is WaylaidCost 0.1.2 by Shakam, for Interface 16001. Its distributed files are readable Lua, not compiled binaries. Its public licence is **All Rights Reserved**: https://www.curseforge.com/wow/addons/waylaidcost/license. No files, code blocks or artwork from that project were copied into Waylaid Value. The implementation here uses our existing catalogue and independently written scanner/tooltip modules.

Useful behaviors observed: user-started sequential AH searches, distinction between browse estimates and detailed results, cancellation on competing searches/closing the AH, preserving a completed snapshot on failure, localized search names matched back to item IDs, explicit timestamps, configurable item-tooltip explanations and minimap access to settings.

Implemented independently in this checkpoint:

- Exact item-ID matching after localized-name browse, full browse/search pagination, delayed metadata handling, protected API reads, timeout, search-rate pacing and cancellation when another AH search takes over.
- No partial-price publication: previous complete scan is kept until every target resolves. Realm/faction data isolation. No character names or scan data are exported.
- Minimum purchasable unit-price estimates, excluding known own/account auctions conservatively. No purchase API calls.
- All existing crate/filling IDs plus the selected reward’s reagents, not an entire-AH scan.
- A separate AH-scan price source and final Auto fallback, with true scan timestamps.
- Native item-tooltip extension, exact crate IDs, compact/Shift/always/off modes, modern and legacy tooltip hooks, deduplication and suppression inside our own cost window. Hover never scans.
- Slash commands provide a testable entry point while screen approval is pending.

Pending design approval: Settings and Scan AH controls in the existing header, a compact Settings panel with tooltip mode, bag reminders and minimap visibility. The approved Crates/Rewards organization and window dimensions stay unchanged. No native new-screen code is included yet.

Other ideas remain separate work, not silently added: whole-auction/stock-aware purchase optimization, Craftsman’s Writ reputation orders, editable unverified Favor payouts, an extra auction-house tab, Auctionator search handoff, and full localization. In particular, reusing the current unlimited unit-price Favor optimizer as a finite-stock purchase solver would be incorrect.

API reference: Blizzard’s generated AuctionHouse documentation, mirrored at https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/AuctionHouseDocumentation.lua. Runtime API detection guards client differences. Automated API doubles do not prove native server behavior; a user-started scan at the AH still needs field validation.

The 0.6.0 candidate is not installed or published in this checkpoint. Public 0.5.4 downloads and marketplace files are unchanged.
