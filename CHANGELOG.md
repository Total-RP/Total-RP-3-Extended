# Changelog for version 1.3.0

**This update requires Total RP 3 version 1.5.0 or higher.**

## Map scans are back

Map scans for stashes and dropped items have been re-implemented for the new world map system.

- You can now right-click on your own stashes when using the "Scan for my stashes" scan to edit or delete them.
- Thanks to the new map system in Total RP 3's core add-on, stashes and items placed on a specific level of a map will now correctly be associated to that specific level only.

## New encoding for quick exports

Creations exported using the quick export feature are using a new algorithm that combines both compression and safer encoding. Basically, this means you are able to export bigger creations faster and the serialized text is no longer using characters that might be transformed by word processors.

> Note: Creations exported with version 1.3.0 (and higher) of Total RP 3: Extended cannot be imported into older versions, but creation exported with older versions can still be imported. The website http://wago.io for sharing Total RP 3 creations will receive an update to support this new algorithm.

## Fixed

- Fixed sound and music broadcasting to other players.
- Fixed an issue in the migration to 8.0's new map IDs in drops that would cause them to not be shown on the map.
