# Validation

## 0.5.4 filling-material reminders

Callback regressions cover partial and excess owned materials, selected-crate alternatives, live bag updates, missing APIs and hidden zero counts. Market totals, ranking and cheapest-bundle choices remain identical with inventory present. Counts describe one filling bundle, not an entire Rewards shopping plan. No inventory is deducted from quotes. Native rendering remains unverified.

## 0.5.3 bag reminder

Callback checks cover modern/legacy item-count fallbacks, unavailable and invalid counts, explicit bank/charge exclusion, bag-change refresh, hidden zero counts, and unchanged ordering, net costs and selection when a more expensive crate is owned. Inventory is a display annotation added after ranking; the pricing model and Rewards optimizer remain unchanged. Native bag-event timing and text rendering still require field verification.

## 0.5.2 explanatory hover help

All clickable addon controls have help, including the minimap button and menu choices. A callback audit checks every clickable Button/CheckButton under the addon and evaluates the explanatory help bodies. Tests check Expert meaning/15-or-30 estimates, dynamic provider status, disabled direct-purchase/empty-selection reasons, price-cell click forwarding, help-frame reuse and tooltip ownership. Existing minimap OnHide drag handling is preserved. Disabled-control hit areas hide when inputs are enabled, and the hidden no-professions message does not leave a hover area over profession navigation.

Menu fields are supported by the retained Blizzard FrameXML interface (`tooltipTitle`, `tooltipText`, `tooltipOnButton`): https://raw.githubusercontent.com/tekkub/wow-ui-source/live/FrameXML/UIDropDownMenu.lua. This source reference and mocked callbacks do not prove popup positioning or every hover transition in the actual Forever client; those remain field checks.

## 0.5.1 compact craft quotes

Reward rows are 32px high at a 34px pitch, with 184px-wide item names. The second line retains Favor and adds right-aligned one-craft material cost. Roles remain available in native tooltips and selected detail. A shared material-cost calculation supplies both the row quote and selected cost breakdown without planning Favor for every row.

Regression checks cover exact row/detail material-cost agreement, updated quotes after Refresh, unchanged row cost when held Favor/learned recipe changes, missing reagent prices, direct rewards, row height and column bounds. The preview is checked for inline prices and compact rows; actual game rendering still requires field verification.

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
