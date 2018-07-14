# Changelog for version 1.2.0

**This version of Extended requires Total RP 3 version 1.4.0 or above.**

## Compatibility with patch 8.0.1

Due to important technical changes to the World of Warcraft API, older versions of the addon will not work for 8.0.1.

## Battle.net friends support

You can now open a trade for Extended creations and inspect a player's Extended inventory with a player from the opposite faction or on another realm if you are friend with them on Battle.net !

![](https://pbs.twimg.com/media/DhIC1m6W0AYkzMO.jpg:large)

## Added

- Extended modifies Total RP 3's logo on the dashboard to reflect that Extended is installed.
- The "Summon random battle pet" effect now lets you choose if you wish to pull from your entire pet pool or only from your favourites.
- Right-clicking the selected mount in the "Summon mount" effect now resets the selector, letting you summon a random mount.
- Added a game events browser to the game events editor. This browser pulls information from the official API documentation and gives you the list of game events as well as the arguments for each of them. Extended custom events are included in this browser as well.


## Modified

- Stash data are being migrated to use new map IDs introduced in path 8.0.1. Some stashes may be lost in the transition due to this change.

## Fixed

- Fixed the "Container total weight" condition editor dropdown going out of bounds.
- Replaced the dropdown text for the add item effect to better reflect the actual action.
- Fixed an incorrect label for the trade button in the target frame settings.
- Fixed the "Simple rifle" backer item not working.
- Fixed some potential Lua errors with the sound & music workflow effects.
- Fixed version number display in some parts of the add-on.

## Removed

- Scans are currently disabled in Total RP 3 while we are working on re-implementing them for the major changes to the map API brought by Battle for Azeroth.
- Stashes cannot be created and items cannot be dropped anymore in instances, due to the lack of player coordinates.