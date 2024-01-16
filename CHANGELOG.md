# Changelog for version 2.1.0

*This version requires Total RP 3 version 2.7.0 or newer.*

## Added

- Links to workflows are now automatically updated after renaming or deleting a workflow in the following:
  - Actions
  - Event links
  - Cutscene steps
  - Run workflow effect (only when renaming)

## Fixed

- Fixed inconsistent map scans order depending on locale.

# Changelog for version 2.0.3

*This version requires Total RP 3 version 2.6.0 or newer.*

## Added

- Added the UnitGUID operand.
- Added Extended actions to the list of mouse actions available on the minimap button and addon compartment entry. They can be bound in Launcher settings.

## Fixed

- Fixed the loot window hiding behind the cutscene window when trying to use the "Show loot" effect during one.
- Quest actions will now properly be disabled when the quest is on a final step, similar to events.
- Fixed boolean variables display and usage in conditions.
- Fixed obsolete links in the initial disclaimer.

# Changelog for version 2.0.2

*This version requires Total RP 3 version 2.5.5 or newer.*

## Fixed

- Fixed the database resize button not working.
- Increased the animation frame slider in the inventory page to reach the end of some long animations.

# Changelog for version 2.0.1

## Fixed

- Fixed an issue preventing parts of the addon from working with patch 10.1.5.
- Fixed the misalignment of the container close button.
- Fixed the "Show loot" effect editor popup closing on mouse click up.
- Fixed the crafting reagent tag breaking tooltips.

# Changelog for version 2.0.0

## Added

- Added Aura creation type
  - Auras are buffs or debuffs which can be applied to a character via workflow effects.
  - Auras are attached to a character profile and are only active while that character profile is active.
  - Among other things, auras allow you to execute a workflow regularly on a timer while they are active.

- Added a new "Aura item" template, applying a basic buff on item use.
- Added new aura effects and conditions.
