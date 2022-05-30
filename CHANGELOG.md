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
