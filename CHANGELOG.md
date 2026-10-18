# SenBar Changelog

## v0.2.1

### Settings and interface

- Display the addon version beside the SenBar title in the main settings panel.
- Simplify the main settings heading by removing the “Health & Power Bars” subtitle.
- Reorganize the tracker editor with **Class layout** first and **Adjust** second.
- Keep shared tracker controls at the top right, accessible from both tabs.
- Refine panel width, spacing, and the “Add to selected group” area.
- Display buff bar previews in rows of three.
- Improve Shown/Hidden button click areas.
- Fix opening the tracker editor.
- Keep settings panels, tracker editor, and right-click menus in the foreground while interacting with them.

### Tracker groups

- Protect the built-in Essential, Utility, and Buffs groups from deletion.
- Allow user-created groups to be deleted, including fixes for custom group deletion.
- Include an empty, deletable **Custom group** in the default setup to demonstrate additional groups.
- Restore clickable group mode selection for Normal and supported form or stance modes.
- Position custom groups above Essential by default.
- Split the Buffs layout into separate **Buff Icons** and **Buff Bars** areas, each with an add control and drag-and-drop support.
- Show bar-shaped previews for buff bar entries.
- Add individual buff bar color controls with a common initial color and per-bar overrides.
- Keep color pickers open while choosing a color.
- Remove the duplicate “Bar look” adjustment section and obsolete global buff/debuff bar color controls; retain **Adjust buff bars**.

### Right-click menus

- Support right-click menus on both tracker icons and buff bars.
- Order menu actions as Mark as proc, Remove from this row, Glow/Pulse color, and Cooldown text.
- Add a Glow/Pulse color submenu with Default, Class color, and Custom choices.
- Use **#FFD133** as the default glow/pulse color.
- Store custom glow/pulse colors per spell instead of applying one custom color to every entry.
- Add a Cooldown text submenu with an on/off control and text size adjustment.
- Clarify menu labels to refer to cooldown text.
- Open submenus on hover.
- Switch directly to another icon or bar’s menu when it is right-clicked, closing the previous menu.
- Dismiss menus with Escape or by clicking elsewhere.

### Default tracking and spell loading

- Enable the tracker and hide Blizzard’s Cooldown Manager by default.
- Automatically populate a new or fully reset setup from suitable learned spells and available cooldown/aura information.
- Target a starter layout of **5 Essential spells**, **4 Utility spells**, **3 buff icons**, and **2 harmful aura bars**, when enough suitable entries are available.
- Support characters installing the addon at different levels; characters with fewer available spells may receive fewer starter entries.
- Exclude the basic Attack spell and passive spells from automatic spell loading, and prefer the highest learned rank.
- Track the initial spell baseline so surplus or removed initial entries are not repeatedly added on login.
- Automatically add genuinely newly learned spells.
- Keep manual Blizzard cooldown import available for larger selections.
- Place harmful tracked auras on buff bars by default.
- Set default icon size to **31**, spacing to **2**, and Essential/Utility icons per row to **10**.
- Set default buff icons per row to **4**.
- Grow new Essential and Buff icon rows upward; grow Utility rows downward.

### Profiles

- Replace the previous profile workflow with a **Saved profiles** dropdown plus Create and Delete buttons.
- Load a profile immediately when selected.
- Automatically save changes to the active profile, including Default and Yurri-Default.
- Create profiles through a name-entry popup and confirm deletion before removing the selected profile.
- Save all active tracker settings alongside bar settings, including spell groups, entries, positions, proc flags, per-spell colors, cooldown text options, and layout settings.
- Correct tracker class-cache binding when loading profiles.
- Highlight the Profiles button in sky blue at the bottom right, following Reset position and Reset all settings.

### Profile import and export

- Include tracker settings in exported profiles alongside bar settings.
- Generate export text directly in the settings panel without an export popup.
- Keep long export codes inside a clipped, scrollable text box.
- Automatically select generated export text.
- Provide **Select code** and **Copy code** controls.
- Focus and select export text for copying, and show green “Copied” feedback after Ctrl+C is detected. WoW still requires the user’s keyboard copy action; the addon does not copy to the clipboard automatically on a button click.
- Open a paste-code popup for imports, followed by a category-selection popup.
- Offer **Bars** and **Cooldown manager icons (tracker)** import categories, both selected initially when tracker data is present.
- Import either category or both while preserving the current settings of unselected categories.
- Support older bar-only profile codes without replacing existing tracker settings.
- Reject imports with no category selected and avoid duplicate profile names by adding a suffix when needed.

### Reset behavior and default positions

- Require confirmation before Reset all settings.
- Reset both bars and tracker settings, including reloading the starter spell selection and default Custom group.
- Retain other named profiles when resetting the Default setup.
- Make Reset position restore positions without resetting sizes, scales, colors, text sizes, spell selections, or other configuration.
- Include bar offsets, text X/Y offsets, minimap position, tracker group positions, and independently positioned buff bars in position resets.
- Keep the settings and tracker editor windows at their current positions during resets.
- Place Essential above the main bar stack and Utility below the cast bar by default.
- Raise the default Buff Icons block to the upper-left area of the bar stack.
- Place Buff Bars to the left of the buff icons, starting one icon row lower.
- Align default positions for linked and independently positioned buff bars.

### Fixes

- Remove direct dragging of health and power text; adjust each text element through its Text section X/Y controls.
- Remove outdated text-drag guidance.
- Fix leftover buff icons after the Buff Icons group is emptied by clearing unused cached icon and bar widgets reliably.
- Improve consistency between loaded profiles, active tracker data, and saved settings.

### Commands and package metadata

- Update addon version metadata to **0.2.1**.
- Use **/sb** or **/senbar** to open the main settings.
- Replace **/sb tracker** with **/sbc** to open the tracker editor.
- Support **/sbc on** and **/sbc off** to enable or disable the tracker.
- Preserve the supplied TOC interface value, icon path, and SavedVariables declarations, including legacy settings migration variables.

---

This changelog covers the v0.2.1 changes. Earlier release history is not included.
