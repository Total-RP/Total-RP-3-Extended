-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

--[[
	Backdrop Tables
	The 9.x Backdrop API requires using <KeyValue> elements in XML that
	reference global variables to provide color and backdrop information;
	the below tables are all of our old <Backdrop> elements converted to
	the appropriate format.
	The naming format matches the Blizzard convention to avoid bikeshedding
	over specific names.
--]]

TRP3_BACKDROP_MIXED_DIALOG_TOOLTIP_16_16_3333 = {
	bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile     = true,
	tileEdge = true,
	tileSize = 16,
	edgeSize = 16,
	insets   = { left = 3, right = 3, top = 3, bottom = 3 },
};

TRP3_BACKDROP_MIXED_DIALOG_TOOLTIP_380_24_5555 = {
	bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile     = true,
	tileEdge = true,
	tileSize = 380,
	edgeSize = 24,
	insets   = { left = 5, right = 5, top = 5, bottom = 5 },
};

TRP3_BACKDROP_MIXED_TUTORIAL_TOOLTIP_418_24_5555 = {
	bgFile   = "Interface\\TutorialFrame\\TutorialFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile     = true,
	tileEdge = true,
	tileSize = 418,
	edgeSize = 24,
	insets   = { left = 5, right = 5, top = 5, bottom = 5 },
};

TRP3_BACKDROP_MIXED_BANK_TOOLTIP_100_16_4222 = {
	bgFile   = "Interface\\BankFrame\\Bank-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile     = true,
	tileEdge = true,
	tileSize = 100,
	edgeSize = 16,
	insets   = { left = 4, right = 2, top = 2, bottom = 2 },
};
