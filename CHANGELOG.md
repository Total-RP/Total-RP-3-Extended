# Changelog for version 1.5.6

## Added

- Added nameplate customization for campaign NPCs.

## Fixed

- Fixed Extended bindings not showing up properly in the Addons keybindings section.
- Fixed space characters being trimmed at the beginning/end of a document page.
- Fixed color issues in the creation information section.
- Fixed an issue when trying to display text containing a variable with a boolean value.

# Changelog for version 1.5.5

## Fixed

- Fixed right-click on stashes zooming out.
- Fixed an issue that could lead to blocked actions and spells under certain circumstances.
- Fixed an error when the default tracker is not visible. The campaign tracker remains invisible in such cases for now.

# Changelog for version 1.5.4

## Fixed

- Fixed macro effects failing to execute.

# Changelog for version 1.5.3

## Added

- Added support for Retail 10.0.0.

## Fixed

- Fixed a crash when speech effects were given an empty text.

# Changelog for version 1.5.2

## Added

- Campaign NPC tooltips now hide the original NPC tooltip.
  - You can show the original tooltip or add its information at the bottom of the campaign NPC tooltip in Extended settings.

## Changed

- Applied tooltip color settings to campaign NPC tooltips

## Fixed

- Fixed campaign NPC tooltips not showing with Total RP 3 version 2.3.12.
- Fixed the object scope in cutscenes not working.

# Changelog for version 1.5.1

## Fixed

- Fixed URLs not working properly in documents since last version. (Thanks to Seleves for the fix)
- Fixed the emote effect (and future secure effects) not appearing in the security prompt to be enabled.
- The emote effect now prints the command in chat if blocked.
- Added an error message to clarify when the speech effect fails to execute due to a delay or an event.

# Changelog for version 1.5.0

## Added

- Added new operands:
  - Active campaign ID
  - ID of an item in a container slot (must be called from a container)
  - Item name, icon, value, quality, weight (from an item ID)
  - Day, month, year and day of the week
- The random operand now supports variable tags.
- Added an optional fadeout duration for the Stop sound and Stop local sound effects.
- Added buttons on documents to go to the first and last page.
- Added the ability to pass workflow vars in document workflow links. (Thanks to Seleves)
    - Example case: {link\*workflowID(var1=value1,var2=value2)\*Link Text}
- Added tonumber, tostring and date to the restricted Lua environment.

## Fixed

- Fixed the Prompt for input effect always adding the input value as a workflow variable.
