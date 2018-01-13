# Changelog

## [1.0.7](https://github.com/Ellypse/Total-RP-3/compare/1.0.6...1.0.7) - 2018-01-13

Our thanks again to [Solanya](http://twitter.com/Solanya_) for his help on this release.

### Fixed

- Fixed an issue in the Arcano-Casino backers creation and improve workflow execution.
- Fixed an issue in the coordinates system that would make some features not backward compatible.

### Added

- Variable interpolation for the active campaign (using a `${var}` tag to get the value of a variable stored in the active campaign.)
- You are now prompted to enable a campaign when an effect from this campaign tried to be executed.
- When creating a new campaign you now have the option to copy an existing campaign.
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