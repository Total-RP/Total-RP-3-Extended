## New features

- You can now add a condition for each individual effect of a workflow, that won't stop the entire workflow. You can right-click on a workflow element to add/remove such condition.
- Added new operand to get the current total weight of a container.
- Added new operand to get the current server time (hours and minutes).

## New feature: script effect

We always wanted to keep a high level of security in Extended. That's why there wasn't any effect letting you freely write lua code. This version brings a new effect: "Execute restricted lua script".
It lets you use the power of lua syntax (if-then, for-while, table and strings API ... etc) but only let you trigger effects from Extended.
That way, people don't have to be worried when using your creation. That also means you can't use freely the game API.

A full unscoped lua script will come later, but it will have serious limitations to keep the Extended players safe.

## Bug fixes

- Fixed a Lua error appearing when a user broadcast a public sound when you are in an instance. — [Ticket #58](https://wow.curseforge.com/projects/total-rp-3-extended/issues/58)
- Fixed the issue where the models would be wrong or not visible for campaign cut-scenes when using an NPC ID. Additionally, a button to get your target's NPC ID has been added next to the input fields. — [Ticket #56](https://wow.curseforge.com/projects/total-rp-3-extended/issues/56)