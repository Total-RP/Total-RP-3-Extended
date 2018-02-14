# Changelog

## [1.0.7.1](https://github.com/Ellypse/Total-RP-3/compare/1.0.7...1.0.7.1) - 2018-02-15

This update improve the quick export and quick import workflows. The WeakAuras sharing website [wago.io](http://wago.io) now support Total RP 3: Extended items and campaigns! Create a quick export string by right-clicking on your creation and choosing the quick export option and paste the generated string on the website. Give your creation a name, a description (they will be pre-populated using your items info!) and add a few screenshots to show exactly what it is (or even YouTube videos!) and get a nice URL to share with people where they can copy the import string to paste inside their own Total RP 3: Extended.

### Changed

- Increased the size limit for the quick export option to 500KB up from 16KB.
- Added indications about the support of wago.io in the quick export and quick import UI.
- Move the quick import button to be more accessible.

## [1.0.7](https://github.com/Ellypse/Total-RP-3/compare/1.0.6...1.0.7) - 2018-01-31

Our thanks again to [Solanya](http://twitter.com/Solanya_) for his help on this release.

### Fixed

- Fixed an issue in the Arcano-Casino backers creation and improve workflow execution.
- Fixed an issue in the coordinates system that would make some features not backward compatible.
- Copying a creation now updates all the workflows in the creation to use the new copy ID instead of the original creation ID

### Added

- Variable interpolation for the active campaign (using a `${var}` tag to get the value of a variable stored in the active campaign.)
- You are now prompted to enable a campaign when an effect from this campaign tried to be executed.
- When creating a new campaign you now have the option to copy an existing campaign.
- When copying a creation, it will now update workflows in that copy to use the new ID instead of the original creation ID.
- Added indication in the tooltip that you can Ctrl + Click on an effect in a workflow to condition that specific instruction's execution.
- Added thank you message for Ellypse's [Patreon](http://patreon.com/Ellypse) supporters.

## 1.0.6  - 2017-11-22

With the help of @Solanya_

### New features / enhancements

- Added achievement condition operand
- Increased quest log progression size
- {trp:target:full} text tag now tries also to use campaign NPCs names
- Included a new backer's creation

### Bug fixes

- Fixed an issue with rolling multiple dices
- Fixed "Summon Mount" effect
- Fixed an issue with inner item display
- Fixed an issue with "Player choices" in cutscenes when there was no left model
- Fixed X & Y position condition operands
- Fixed second scrolling menu display on the prompt effect
- Fixed item tooltip showing on top on frames
- Fixed "crafted" flag when manually added, and changed the english locale to better reflect that.
