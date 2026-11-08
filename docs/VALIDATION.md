# Validation

## 0.5.0 presentation and role checks

Added regressions for retained/live rarity precedence, actual name colors, icon-frame visibility, reusable rounded skin, native role dropdown and combined filters. Real tooltip cases distinguish healing leather, hybrid spell gear, physical DPS and general engineering bombs. Money tests cover colored denominations, negative amounts and zero; a 20-Favor turn-in must subtract 1,000 copper (10 silver). Native UI callbacks preserve selection, learned state, held Favor and net totals.

The reference screenshot's level-26 hunter with Leatherworking 109/Cooking 2 has 24 equip/skill matches before role filtering; the new class relevance filter shows 13, retaining unclassified items. Role tags come from explicit tooltip stats/effects and are deliberately not talent-weighted upgrade scores. Hybrid classes are not assigned a guessed role.

The style retains the existing window size, tabs and list/detail organization. Reference: https://github.com/smoergi/OneForAll_Forever, installed UI/Widgets.lua and UI/MainFrame.lua. The independent skin uses original generated 4px-radius texture primitives, warm gold/brown colors and native item-quality colors; no reference artwork/code is copied. A labelled HTML implementation preview uses the real catalog, Lua fallback facts and frozen price fixture. It can verify interactions and composition but not native font clipping or the complete WoW lifecycle.

An observed 20-Favor turn-in awarded 10 silver, consistent with the existing 50-copper-per-Favor assumption. This is not general confirmation of every crate tier. TSM's installed public API was checked again: it exposes custom price values and money formatting, but no timestamp for the `dbminbuyout` quote. An age shown by TSM's own tooltip is not silently assigned to this addon's quotes.

## 0.4.1 baseline audit

The 0.4.1 audit covered runtime code, pricing adapters, exact Favor planning, character filters, UI callbacks, catalogue consistency, the offline report and packaging.

The four Lua suites passed with Lua 5.1.5 and 5.5.1. JavaScript checks cover the independent model and generated report handlers. The data audit compares 321 rewards and 96 bundles with retained source tooltip facts, then checks 963 Lua/JavaScript estimates across three character/Favor/learned scenarios. ZIP checks enforce the exact TOC payload, license/README inclusion and byte equality with the current source.

Tests use public item prices and explicit API/DOM doubles. They do not reproduce Blizzard's complete UI lifecycle or measure rendered text. The word "native" in test output refers to the Lua view builders, not a real-client screenshot.

Still awaiting field validation:

- Window rendering, text clipping, scrollbars, display scaling and tooltip loading in Forever.
- Profession API behavior and startup timing in the actual client.
- Live Auctionator integration. Its v1 copper-price API is feature-detected; Forever compatibility is not proven by mocks.
- Real quest silver/Favor payouts and all vendor prices.

TSM uses the installed public `GetCustomPriceValue(customPriceStr, itemString)` API with `dbminbuyout`, per-refresh caching and guarded errors. No raw AppHelper account export ships in the project.

The committed market fixture contains public item IDs, quotes, catalogue facts and icons. Its timestamp is fixed; rebuilding does not refresh it. Price providers supply runtime prices in game. Maintainers should update catalogue facts only against current tooltips/vendors and keep uncertain fields explicit.
