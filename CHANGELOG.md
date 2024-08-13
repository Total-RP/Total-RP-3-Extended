# Changelog for version 2.2.1

## Changed

- Added a checkbox to set if the ID for a casting delay sound is a sound file ID instead of a sound ID.
  - This is identical to the one already present in the "Play sound" effect.
- The document editor now uses the background browser to select the document background.
  - This also fixes the issue where selecting a background in the dropdown would turn the document transparent.

## Fixed

- Fixed campaign tracker scaling and display issues.
- Fixed the casting delay duration not properly updating, as well as not respecting the position of the player's castbar.

# Changelog for version 2.2.0

*This version supports patch 11.0 and requires Total RP 3 version 3.0.0 or newer.*

## Added

- Added right-click menu options on players to initiate a trade or a character inspection.
- Local sounds and musics can once again be played in instances, but will only play for your party/raid members.

## Changed

- The UI has received some minor graphical adjustments tied to Total RP 3's UI rework.
  - Some UI elements sizes and positions were also adjusted to align better with one another.
- The "Execute macro" effect is now restricted to 255 characters.
  - Existing macro effects longer than 255 characters will error out.
  - A character count was added at the bottom of the editbox to keep track of the limit.
- The toolbar and target frame buttons have had their icons updated to make their actions clearer.
- Some frames, like stashes or the main container, can now be closed by pressing Escape.
- Tooltip texts for the toolbar and target frame buttons, as well as settings, were reworked to follow a more consistent format and add clarity when needed.

## Fixed

- The item/campaign creation popups properly close when opening the Quick Import popup to prevent overlap.