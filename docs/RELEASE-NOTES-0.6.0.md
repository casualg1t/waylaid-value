# Waylaid Value 0.6.0 candidate

Adds a user-started targeted AH scan and the approved Settings panel. Crates/Rewards tabs and window dimensions are preserved.

- **Scan AH** collects prices at the AH; **Stop scan** cancels without replacing the previous complete snapshot. Closing the AH or starting another search also interrupts it.
- A complete scan selects **AH scan** as its source. Quotes are dated unit-price estimates, not guaranteed stock or whole-stack purchase plans.
- **Settings** selects compact, Shift-expanded, always-detailed or disabled crate item tooltips; toggles bag reminders and minimap visibility. Changes save immediately.
- Right-click the crate minimap icon or use `/crates settings` to open preferences. `/crates scan` and `/crates stop` remain available.
- Auto preserves TSM → Auctionator priority, then falls back to saved AH scan quotes for missing items.

## Field check before stable publication

1. `/reload`, then `/crates`. Check both tabs and the new header controls. Outside the AH, Scan AH should be disabled with a hover explanation.
2. Open Settings, change tooltip detail, hide/restore the minimap icon and reopen Settings by right-click or slash command. Filters, selected reward and held Favor should remain intact.
3. At the AH, select a reward if its crafting reagents should be included, then click Scan AH. Let it complete and inspect the source, timestamp and prices. Do not run another AH search concurrently.
4. Start another scan and stop it; also try closing the AH or starting a manual search. Previous complete prices should remain.
5. Hover a crate in bags or an item link, with and without Shift; try Off. Hovering must never start a scan.

Automated Lua/current and Lua 5.1 suites, callback tests, 963 Lua/JS cost comparisons and ZIP/source parity pass. Actual server responses and native-client rendering remain unverified. This candidate is for local testing; public 0.5.4 marketplace files are unchanged.
