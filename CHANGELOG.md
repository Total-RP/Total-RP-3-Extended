# Changelog for version 1.4.1

## Added

- Added variable parsing in campaign NPC descriptions.
- Added an option to play a sound file ID instead of a sound ID for the "Play sound ID" and "Play local sound" effects.

## Changed

- Changed creation tooltip description color and added quotation marks to more accurately match regular item tooltips.
- Items with a Unique count of 1 will no longer show that number.
- Empty stashes will no longer appear on the map scan for other players.
- Cast delays can now be started while moving if they will not be interrupted on movement.
- Cast delays will no longer cancel each other. If a cast is currently in progress, the other cast will return an error.
- The campaign action toolbar will now be hidden if no action is currently active.

## Fixed

- Fixed an issue when trying to place wearable markers on the inventory page if the TRP window had never been moved.
- Fixed an issue with a cutscene step being skipped when starting that cutscene from another cutscene.

# Changelog for version 1.4

## Added

- Added an emote effect.
  - **It is a secure effect**: you have to enable it when receiving a creation from someone else in the creation security settings.
- Added the ability to copy/paste quests and quest steps to help cooperation on creations.
  - They are accessible by right-clicking a quest/step (alongside the delete option).
  - Links to inner items of the quest/quest steps will be converted to the new quest/step ID.
  - This does **not** apply to non-inner items links, make sure to check upon pasting.

## Changed

- The campaign objective tracker has received major improvements:
  - Fixed overlap with world quests / achievement tracking (thanks Seleves).
  - Fixed long texts going off-screen.
  - Changed the appearance of campaign/quests names to be closer to the default quest tracker.
  - Campaign actions can now be found on the tracker instead of the target frame, allowing for easier access without a target.
  - If a campaign action is not currently required, it will appear greyed out.

![New campaign objective tracker](https://i.imgur.com/N8Eyi7r.png)

## Fixed

- Fixed an issue when trying to link an empty inventory slot.
- Fixed an issue causing events to trigger multiple times if the quest was revealed multiple times.
- Replaced dropdowns to fix potential taint issues.
- Fixed a display issue with the sounds history background.