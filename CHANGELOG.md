# Changelog for version 2.3.2

## Fixed

- Fixed cast bar issues from patch 12.0.1.

# Changelog for version 2.3.0

## Fixed

- Added support for patch 12.0.0.
- Fixed a rare timing issue with local sounds which could trigger an error on login/reload.

# Changelog for version 2.2.12

## Fixed

- Fixed a Lua error on load.

# Changelog for version 2.2.11

## Added

- Added support local sounds in neighborhoods and private houses.

## Fixed

- Fixed local music not playing if it was enabled but local sounds were disabled.
- Fixed local sounds not working for the player if they're alone in an instance.

## Removed

- Removed the setting to ask for permission to play local sounds/musics, as it was never implemented.
  - Local sounds can still be disabled globally.
  - As a reminder, you can see who is playing local sounds via the Sounds History window accessible from the TRP toolbar, and ignoring a player ignores their local sounds.
