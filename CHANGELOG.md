# Version 1.1

## New chat links support

We have added support for Total RP 3's chat links system. You can now insert links to Items and Campaigns in chat by Shift-Clicking them. People will be able to see the creation's information, and even import them if you set the links to be importable.

[PICTURES OF THE CHAT LINKS FEATURE GOES HERE]

Shift-Click on an item in your inventory, on a campaign in your quest log or in the database list to insert a link inside the chat frame. Make the link importable if you want the other players to be able to import the creation and use it, or make it viewable if you just want them to see the information. When sending a link from your inventory or quest log, the campaign progress is visible in the tooltip and variables in the text fields are resolved so that the tooltip looks exactly like what you see at the moment you created the link (if the variables change, the link won't be automatically updated).

_Note: You can already send links to player who have Total RP 3 version 1.3 or above, but they will need Total RP 3: Extended 1.1 or above to import the content. **It is also strongly advised to use Total RP 3 version 1.3.4.3 (currently in beta) or above to get the download progress on the tooltip buttons during the importing process.**_

## Added
- Added workflow effects to stop sounds, local sounds, and local musics. You can either stop a specific sound/music ID, or all sounds/musics you've triggered so far.
- Inventory effects can now parse variables, meaning you can now add ${amount} of an item.
- Added a Trade button on the target frame to initiate a trade with another player (only shows if the target is using Extended).  
[IMAGE OF THE TRADE BUTTON GOES HERE]
- The Restricted Lua script effect has now access to new functions to access variables from workflows, objects and active campaign. [Learn more](https://github.com/Ellypse/Total-RP-3-Extended/wiki/"Execute-restricted-Lua-script"-effect))
- Added a button to create an expert item directly from the database.
- Added an optional field in the dice roll effect to store the result in a variable.

## Changed

- Numeric variables are now displayed with 2 decimal values by default. You can manually choose how many decimals to display on a variable by using ${variable#X} for X decimals.
- "Next step index" has been removed from the bottom of cut-scene dialogs, replaced by "Choose an option" when the player has to make a choice.
- Trying to input an inner item ID with a space will now result in a warning popup.
- Creating an inner item by copying another item will now upgrade the inner item mode to match the parent's mode.
- The `TRP3_KILL` event arguments (to track kills from player & party) has been changed to return the killed entity type, and different info in case of a player killed. [Learn more](https://github.com/Ellypse/Total-RP-3-Extended/wiki/Total-RP-3-:-Extended-custom-events)
- TRP3_SIGNAL now gives the sender's name as 3rd argument.
- New stashes will now set the current character as owner of the stash. Its name will be shown on scans even if you're playing on another character. Existing stashes can set or change the stash owner by using the "Set ownership" option in the dropdown shown when clicking the stash icon.
[IMAGE OF THE MENU AND THE ICON GOES HERE]

## Fixed

- Fixed incorrect colors after using item links variables in item descriptions or use text.
- Variables in item descriptions will now be resolved in the item browser.
- Quest progress percentage doesn't try to show decimals anymore. (It would just show "..." at the end)
- Containers and sounds history now close when pressing Esc.
- Fixed a bug that wouldn't display the prompt window if the effect was called in the callback workflow of another prompt.
- Fixed a bug that would show incorrect stash icons on the map after a scan.
- "Loot all" now properly loots everything it can without asking for permission when reaching a stack.
- "Loot all" won't show "Received: [Item] x 0" when loot fails (because of full inventory, unique item...).
- Fixed a bug that would add a condition to a player choice in a cut-scene even if "Condition" was exited without saving.