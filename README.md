# SenBar

**Clean, dynamic health and power bars for World of Warcraft Forever (Classic).**
Smooth animation, combo points for Rogues and Cat Form Druids, 12 color presets, draggable bars and texts, and a modern settings panel. No libraries, one small folder.

Inspired by *SenseiClassResourceBar*.

![SenBar logo](SenBar-logo.png)

---

## Features

- **Health bar and power bar** that update smoothly and follow your resource automatically (Mana, Rage, Energy, Focus). Druids switch resource when they shapeshift.
- **Combo points row** for Rogues and Druids in Cat Form, with its own height, spacing and colors.
- **Swing timer** with separate bars for main hand, off hand (dual wield) and ranged (Auto Shot for Hunters, Shoot for wand users). Bars show the time left, are only shown while a swing is running, and play a preview while the settings are open. The lighter zone at the end of the ranged bar is the 0.5s Auto Shot cast.
- **Per-bar swing settings:** each swing bar (main hand, off hand, ranged) has its own width and height (Swing tab) and color (Colors tab).
- **Move bars the way you want.** The settings open with the bars unlocked, and the "Bars unlocked / locked" button in the panel header locks or unlocks moving at any time (bars always lock again when the panel closes). By default all bars move together as one group. Tick **Move freely** (Layout tab) to move each bar on its own: health + power together, and the combo bar, each swing bar and the cast bar separately. "Reset bar positions" returns to the automatic layout.
- **Cooldown tracker** (Tracker tab, editor with `/sb tracker`): build your own icon groups for class spells, buffs on you, your debuffs on the target and items or trinkets, as a replacement for the Blizzard Cooldown Manager.
  - Up to 6 groups with 24 icons each. Each group has its own size, spacing, icons per row, fill direction (right, left, centered), row direction and position (drag it on screen).
  - Timer numbers, stack and charge counts, grey-out while on cooldown, and a soft pulse when a spell is ready or a buff appears.
  - Show cooldown icons always, only on cooldown or only when ready. Show buffs only when active, or always dimmed.
  - Add icons by typing a name or ID, from your **spellbook** (with search), from your **active buffs**, or with one click for both trinkets.
  - **Import from Blizzard** copies your Cooldown Manager setup (Essential, Utility, Buffs) into groups, and you can hide the Blizzard one.
  - Tracker groups are part of your profiles and share codes.
- **Profiles** (Profiles tab): save all your settings under a name, switch between profiles in one click, update or delete them. `/sb profile <name>` loads a profile from chat.
- **Two ready-made profiles** for every new user: **Default** (the standard look, used on first start) and **Yurri-Default** (the author's own setup: slim bars, swing and cast bars placed around the health bar, Cervo Neue text). Loading a ready-made profile never moves your bars.
- **Share codes**: export any profile as one line of text and send it to a friend; they paste it in the Profiles tab and click Import. Codes only carry the settings that differ from the defaults, so they stay short, and they are checked and limited on import.
- **Per-text font size and X/Y offset** (Text tab) for health, power, the three swing timers, the cast spell name and the cast time, plus show/hide for each.
- **Max health color:** a color for health at or above "Max from" % (default 99); the high color applies below it.
- **Gold spark** on the swing and cast bars: a soft glowing texture (`Textures/Spark.tga`) that rides the edge of the fill.
- **Presets** also set the cast and channel colors. The main-hand swing bar can be hidden like the off-hand and ranged ones.
- **Cast bar** for your own spell casts and channels, with spell name, time left, a spark, an interrupted/failed flash, and its own width, height and colors (Cast tab). Blizzard's default cast bar is not touched.
- **Class color health** with default power colors (modern blue Mana, red Rage, yellow Energy), or a **dynamic health color** (high / medium / low, with adjustable percentages and an optional max color at 100% health), or a **solid custom color**.
- **12 color presets** with unique looks: Neon Noir, Ember Forge, Frostbite, Toxic Bloom, Royal Amethyst, Sunset Drive, Deep Ocean, Emerald Moss, Monolith, Blood Moon, Gilded Age, Candy Pop.
- **Fine tune** every color: health, Mana, Rage, Energy, Focus, combo points, border, background and background opacity.
- **Draggable bars and texts**: open the settings and drag the bars, or drag the health and power texts, wherever you want.
- **Text options**: show or hide the health and power text separately, four formats (Current / Max, Percent, Current, Current | Percent), size and color.
- **Arrow selectors**: options with several choices (text format, text style, visibility, which text to edit, profiles) use clear `<` and `>` arrows.
- **Text styles**: Normal, Bold, Condensed, Condensed Bold, plus **Cervo Neue** from the included `Fonts` folder.
- **Type-in sliders**: drag a slider, or click the number next to it and type an exact value.
- **Minimap icon** (can be hidden), with square minimap support.
- **Visibility modes**: always, in combat, in combat or with a target, hidden.
- Works on all Classic classes. No specializations needed.

## Installation

1. Download the latest release.
2. Extract the `SenBar` folder into your add-ons folder, for example:
   `World of Warcraft\_classic_beta_\Interface\AddOns\`
3. Start the game (or type `/reload`).

The folder must be named exactly `SenBar`.

## Usage

Type **`/sb`** (or `/senbar`) or click the minimap icon to open the settings.

- The bars **unlock while the settings panel is open**, so you can drag them (and the health and power texts). Use the lock button in the panel header to lock or unlock them, and tick "Move freely" to move each bar on its own. They lock again when you close the panel.
- Left-click the minimap icon to open the settings. Right-click it to lock or unlock the bars. Drag it to move it around the minimap.

| Command | What it does |
| --- | --- |
| `/sb` | Open or close the settings |
| `/sb lock` / `/sb unlock` | Lock or unlock the bars |
| `/sb minimap` | Show or hide the minimap icon |
| `/sb reset` | Reset the bar position |
| `/sb tracker` | Open or close the tracker editor |
| `/sb tracker on` / `/sb tracker off` | Enable or disable the tracker |
| `/sb profiles` | List your saved profiles |
| `/sb profile <name>` | Load a saved profile |
| `/sb debug` | Print diagnostic lines, including swing timer data (useful for bug reports) |

## Settings overview

- **Swing**: show or hide the timer, off-hand and ranged bars, time text, bar height and colors.
- **Layout**: show or hide bars, smooth animation, minimap icon, width, heights, gap, scale, visibility, and the combo row settings.
- **Colors**: class color, health gradient, presets and fine tune color swatches.
- **Text**: show or hide texts, format, style, size, color, and reset text positions.
- **Tracker**: switch the tracker on, hide the Blizzard Cooldown Manager and open the tracker editor (groups, tracked icons and style).
- **Profiles**: type a name and Save, pick a profile with the arrows, then Load or Delete. A profile keeps every setting, including bar offsets. Your profile list survives "Reset all settings", which returns to the Default profile. The lower part of the tab exports the selected profile (or your current settings) as a code, and imports a code as a new profile.

## Swing timer notes

- Swing times come from Blizzard's own `PLAYER_SWING` event (the same approach as WeaponSwingTimer), so they are exact: main hand, off hand and ranged, with the real weapon speed. Parry haste is applied to the main hand. No combat log is used.
- If a client has no `PLAYER_SWING` event, melee falls back to an estimate (free-running timer once auto-attack is on, restarted by Heroic Strike / Cleave / Raptor Strike / Maul) and the ranged bar restarts on Auto Shot / Shoot / Throw.

## Custom font

Put your `.ttf` file in the `Fonts` folder. SenBar loads `Fonts\CervoNeueBlack.ttf` for the "Cervo Neue" text styles. To use another font, replace that file with your own, keep the same name and type `/reload`. If the file is missing, SenBar falls back to the default game font.

## FAQ

**The text does not show.** Make sure "Show health text" and "Show power text" are on (Text tab). If it is still empty, type `/sb debug` and send the printed line when you report the problem.

**I cannot move the bars.** Open the settings with `/sb`: the bars unlock while the panel is open.

**The minimap icon is off the edge of my square minimap.** Turn on "Square minimap" in the Layout tab.

**How does the tracker read cooldowns in combat?** The game hides some cooldown and aura numbers from addons during combat. SenBar hands the game's own timer to the icon, so swipes and numbers still work, and it only makes decisions (grey out, hide, pulse) from values the game keeps readable. A spell is treated as "on cooldown" after 1.7 seconds, so the global cooldown never greys out or hides your icons.

**A spell icon is missing.** Spells you do not know are hidden. In the editor, the group is shown with dimmed placeholders while it is open, so you can still arrange it.

**How do I share my setup?** Profiles tab: pick a profile (or use "Export current settings"), click Export, press Ctrl+C and send the code. Your friend pastes it in the Code box, optionally types a name in the Name box, and clicks Import.

**I deleted a ready-made profile.** It is not recreated on its own. Ask a friend for the code of "Default" or "Yurri-Default", or just recreate it from your current settings.

**Where are my settings saved?** In the `SenBarDB` saved variable. Settings from earlier test versions are migrated automatically.

## Reporting a bug

Please include your class, the exact error text (from BugSack or the in-game error popup) and the result of `/sb debug`.

## Credits

- Inspired by *SenseiClassResourceBar*.
- Included font: Cervo Neue Black. Its font data lists the Archivo Black project (open font license).

## License

All rights reserved unless you state otherwise. Choose the license you prefer for your release (for example MIT) and replace this section.
