# Changelog for version 1.3.5

## Added

- Added variable tags to get a target's first or last TRP3 name.
- Added conditions on a creature's type, or family (for beasts/demons).
- Added conditions to check if the character is indoors (or outdoors).

## Fixed

- Fixed an issue where editing a stash would move it to the current player position.
- Fixed an issue where sharing a creation through in-game trade could break its conditions.
- Fixed an issue with the race and class tags not working on target.
- When inspecting another player, variables in items tooltips will now be replaced with what the other player sees.

# Changelog for version 1.3.4

## Fixed

- Fixed a bug when trying to access the addon credits.

# Changelog for version 1.3.3

## Fixed

- Fixed an issue preventing the inspection frame from working.
- Fixed an issue preventing the local music effect from working.
- Fixed an issue preventing the model rotation in the inventory page from stopping.

# Changelog for version 1.3.2

## Changed

- The music system has been reworked in Total RP 3 and impacts Total RP 3: Extended as well. **You need to update to have musics working again, and require Total RP 3 version 1.6.1 or later.** Changes should still support older creations with music effects.

## Fixed

- Fixed an issue with the inventory page following 8.2 changes.

# Changelog for version 1.3.1

## Fixed

- Fixed an issue introduced in the previous update that would prevent you from editing some direct values in conditions - #160
- Fixed lingering issues preventing stashes from working
- Fixed an issue with the download progress display while inspecting or exchanging an item.

# Changelog for version 1.3.0

**This update requires Total RP 3 version 1.5.0 or higher.**

## Map scans are back

Map scans for stashes and dropped items have been re-implemented for the new world map system.

- You can now right-click on your own stashes when using the "Scan for my stashes" scan to edit or delete them.
- Thanks to the new map system in Total RP 3's core add-on, stashes and items placed on a specific level of a map will now correctly be associated to that specific level only.

![](https://totalrp3.info/documentation/changelogs/1_3_0_stash_menu.PNG)

## New Execute macro effect

A new effect has been added to allow you to execute a macro when using your Total RP 3: Extended items. You can run macro commands from the game (`/use`, `/cast`, `/roar`, `/equipset`, `/petfollow`, etc.) or any command added by an add-on (`/dbm pull`, `/skada reset`). The macro executed can even resolve TRP3:E variables from your workflow, to inject variable values inside the execution.

![](https://totalrp3.info/documentation/changelogs/1_3_0_macro_example.PNG)

Due to game engine limitations, this effect has the following rules:

- This effect will be completely ignored while in combat.
- This effect ignores delays. The generated macro commands from your workflow effects are compiled when the item is used and executed immediately.
- This effect will only be executed when an item is right-clicked from the inventory by the player (it can be a workflow called by an item being used). It will be ignored if called by a campaign event or a cutscene. (Support for cutscene dialog buttons will be added in an update).
- Due to the dangerous nature of allowing access to commands like `/use`, `/gquit` or `/script`, this effect's security is set to "dangerous" and requires manual approval when receiving an item using such effect via trade or imports.

![](https://totalrp3.info/documentation/changelogs/1_3_0_macro.PNG)

## New encoding for quick exports

Creations exported using the quick export feature are using a new algorithm that combines both compression and safer encoding. Basically, this means you are able to export bigger creations faster and the serialized text is no longer using characters that might be transformed by word processors. This new format will only be compatible with versions 1.3.0 or above.

> Note: The website http://wago.io for sharing Total RP 3 creations has received an update to support this new algorithm (thanks to Ora from the wago team) and will be able to import the new export strings while exporting export strings compatible with both pre and post 1.3.0 versions of Total RP 3: Extended.

## Fixed

- Fixed sound and music broadcasting to other players.
- Fixed an issue in the migration to 8.0's new map IDs in drops that would cause them to not be shown on the map.
- Fixed an issue that could cause some effects to have invalid arguments when leaving the effect editors without confirming.
- Fixed an issue when trying to split stacks following the release of patch 8.1.
- Fixed the maximum amount when splitting a stack to prevent issues when splitting a stack by its entire amount.
