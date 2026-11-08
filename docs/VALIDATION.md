# Validation

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
