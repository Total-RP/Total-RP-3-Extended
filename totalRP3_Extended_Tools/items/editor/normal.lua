----------------------------------------------------------------------------------
-- Total RP 3: Extended features
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
----------------------------------------------------------------------------------

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local wipe, pairs, tonumber, tinsert, strtrim = wipe, pairs, tonumber, tinsert, strtrim;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local toolFrame, currentTab, display, gameplay, notes, tabGroup;

local TABS = {
	GENERAL = "GENERAL",
	EFFECTS = "EFFECTS",
	DOCUMENT = "DOCUMENT",
	CONTAINER = "CONTAINER",
}

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Main tab
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onIconSelected(icon)
	display.preview.Icon:SetTexture("Interface\\ICONS\\" .. (icon or "TEMP"));
	display.preview.selectedIcon = icon;
end

local function refreshCheck()
	gameplay.uniquecount:Hide();
	gameplay.stackcount:Hide();
	gameplay.usetext:Hide();
	display.preview.Quest:Hide();
	tabGroup:SetTabVisible(2, false);
	if gameplay.unique:GetChecked() then
		gameplay.uniquecount:Show();
	end
	if gameplay.stack:GetChecked() then
		gameplay.stackcount:Show();
	end
	if gameplay.use:GetChecked() then
		gameplay.usetext:Show();
	end
	if display.quest:GetChecked() then
		display.preview.Quest:Show();
	end
	if gameplay.use:GetChecked() then
		tabGroup:SetTabVisible(2, true);
	end
end

local function loadDataMain(data)
	display.name:SetText(data.BA.NA or "");
	display.description:SetText(data.BA.DE or "");
	display.quality:SetSelectedValue(data.BA.QA or LE_ITEM_QUALITY_COMMON);
	display.left:SetText(data.BA.LE or "");
	display.right:SetText(data.BA.RI or "");
	display.component:SetChecked(data.BA.CO or false);
	display.crafted:SetChecked(data.BA.CR or false);
	display.quest:SetChecked(data.BA.QE or false);
	onIconSelected(data.BA.IC);

	gameplay.value:SetText(data.BA.VA or "0");
	gameplay.weight:SetText(data.BA.WE or "0");
	gameplay.soulbound:SetChecked(data.BA.SB or false);
	gameplay.unique:SetChecked((data.BA.UN or 0) > 0);
	gameplay.uniquecount:SetText(data.BA.UN or "1");
	gameplay.stack:SetChecked((data.BA.ST or 0) > 0);
	gameplay.stackcount:SetText(data.BA.ST or "20");
	gameplay.use:SetChecked(data.US or false);
	gameplay.usetext:SetText(data.US and data.US.AC or "");

	notes.frame.scroll.text:SetText(data.NT or "");

	refreshCheck();
end

local function storeDataMain(data)
	if not data.BA then
		data.BA = {};
	end
	data.BA.NA = stEtN(strtrim(display.name:GetText()));
	data.BA.DE = stEtN(strtrim(display.description:GetText()));
	data.BA.LE = stEtN(strtrim(display.left:GetText()));
	data.BA.RI = stEtN(strtrim(display.right:GetText()));
	data.BA.QA = display.quality:GetSelectedValue() or LE_ITEM_QUALITY_COMMON;
	data.BA.CO = display.component:GetChecked();
	data.BA.CR = display.crafted:GetChecked();
	data.BA.QE = display.quest:GetChecked();
	data.BA.IC = display.preview.selectedIcon;
	data.BA.VA = tonumber(gameplay.value:GetText());
	data.BA.WE = tonumber(gameplay.weight:GetText());
	data.BA.SB = gameplay.soulbound:GetChecked();
	data.BA.UN = gameplay.unique:GetChecked() and tonumber(gameplay.uniquecount:GetText());
	data.BA.ST = gameplay.stack:GetChecked() and tonumber(gameplay.stackcount:GetText());
	if gameplay.use:GetChecked() and not data.US then
		data.US = {};
	end
	if gameplay.use:GetChecked() then
		data.US.AC = stEtN(strtrim(gameplay.usetext:GetText()));
	end
	data.NT = stEtN(strtrim(notes.frame.scroll.text:GetText()));
	return data;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TABS
-- Tabs in the list section are just pre-filters
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onTabChanged(tabWidget, tab)
	-- Hide all
	currentTab = tab or TABS.GENERAL;

	-- Show tab
	if currentTab == TABS.MAIN then

	elseif currentTab == TABS.EFFECTS then

	elseif currentTab == TABS.DOCUMENT then

	elseif currentTab == TABS.CONTAINER then

	end
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameItemNormalTabPanel", toolFrame.item.normal);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ "Main", TABS.MAIN, 150 }, -- TODO locals
			{ "On use", TABS.EFFECTS, 150 }, -- TODO locals
		},
		onTabChanged
	);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Load ans save
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadItem(rootClassID, specificClassID, rootDraft, specificDraft)
	if not specificDraft.BA then
		specificDraft.BA = {};
	end
	tabGroup:SelectTab(1);
	loadDataMain(specificDraft);
end

local function saveToDraft(draft)
	storeDataMain(draft);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initItemEditorNormal(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.item.normal.loadItem = loadItem;
	toolFrame.item.normal.saveToDraft = saveToDraft;
	createTabBar();

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- DISPLAY
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Display
	display = toolFrame.item.normal.display;
	display.title:SetText(loc("IT_DISPLAY_ATT"));

	-- Name
	display.name.title:SetText(loc("IT_FIELD_NAME"));
	setTooltipForSameFrame(display.name.help, "RIGHT", 0, 5, loc("IT_FIELD_NAME"), loc("IT_FIELD_NAME_TT"));

	-- Quality
	TRP3_API.ui.listbox.setupListBox(display.quality, TRP3_ItemQuickEditor.qualityList, nil, nil, 200, true);

	-- Left attribute
	display.left.title:SetText(loc("IT_TT_LEFT"));
	setTooltipForSameFrame(display.left.help, "RIGHT", 0, 5, loc("IT_TT_LEFT"), loc("IT_TT_LEFT_TT"));

	-- Right attribute
	display.right.title:SetText(loc("IT_TT_RIGHT"));
	setTooltipForSameFrame(display.right.help, "RIGHT", 0, 5, loc("IT_TT_RIGHT"), loc("IT_TT_RIGHT_TT"));

	-- Description
	display.description.title:SetText(loc("IT_TT_DESCRIPTION"));
	setTooltipForSameFrame(display.description.help, "RIGHT", 0, 5, loc("IT_TT_DESCRIPTION"), loc("IT_TT_DESCRIPTION_TT"));

	-- Component
	display.component.Text:SetText(loc("IT_TT_REAGENT"));
	setTooltipForSameFrame(display.component, "RIGHT", 0, 5, loc("IT_TT_REAGENT"), loc("IT_TT_REAGENT_TT"));

	-- Quest
	display.quest.Text:SetText(loc("IT_QUEST"));
	setTooltipForSameFrame(display.quest, "RIGHT", 0, 5, loc("IT_QUEST"), loc("IT_QUEST_TT"));

	-- Crafted
	display.crafted.Text:SetText(loc("IT_CRAFTED"));
	setTooltipForSameFrame(display.crafted, "RIGHT", 0, 5, loc("IT_CRAFTED"), loc("IT_CRAFTED_TT"));

	-- Preview
	display.preview.Name:SetText(loc("EDITOR_PREVIEW"));
	display.preview.InfoText:SetText(loc("EDITOR_ICON_SELECT"));
	display.preview:SetScript("OnEnter", function(self)
		TRP3_API.inventory.showItemTooltip(self, {madeBy = Globals.player_id}, storeDataMain({}), true);
	end);
	display.preview:SetScript("OnLeave", function(self)
		TRP3_ItemTooltip:Hide();
	end);
	display.preview:SetScript("OnClick", function(self)
		TRP3_API.popup.showIconBrowser(onIconSelected, nil, self, 1);
	end);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- DISPLAY
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Display
	gameplay = toolFrame.item.normal.gameplay;
	gameplay.title:SetText(loc("IT_GAMEPLAY_ATT"));

	-- Value
	gameplay.value.title:SetText(loc("IT_TT_VALUE_FORMAT"):format(Utils.str.texture("Interface\\MONEYFRAME\\UI-CopperIcon", 15)));
	setTooltipForSameFrame(gameplay.value.help, "RIGHT", 0, 5, loc("IT_TT_VALUE"), loc("IT_TT_VALUE_TT"));

	-- Weight
	gameplay.weight.title:SetText(loc("IT_TT_WEIGHT_FORMAT"));
	setTooltipForSameFrame(gameplay.weight.help, "RIGHT", 0, 5, loc("IT_TT_WEIGHT"), loc("IT_TT_WEIGHT_TT"));

	-- Soulbound
	gameplay.soulbound.Text:SetText(ITEM_SOULBOUND);
	setTooltipForSameFrame(gameplay.soulbound, "RIGHT", 0, 5, ITEM_SOULBOUND, loc("IT_SOULBOUND_TT"));

	-- Unique
	gameplay.unique.Text:SetText(ITEM_UNIQUE);
	setTooltipForSameFrame(gameplay.unique, "RIGHT", 0, 5, ITEM_UNIQUE, loc("IT_UNIQUE_TT"));

	-- Unique count
	gameplay.uniquecount.title:SetText(loc("IT_UNIQUE_COUNT"));
	setTooltipForSameFrame(gameplay.uniquecount.help, "RIGHT", 0, 5, loc("IT_UNIQUE_COUNT"), loc("IT_UNIQUE_COUNT_TT"));

	-- Stack
	gameplay.stack.Text:SetText(loc("IT_STACK"));
	setTooltipForSameFrame(gameplay.stack, "RIGHT", 0, 5, loc("IT_STACK"), loc("IT_STACK_TT"));

	-- Stack count
	gameplay.stackcount.title:SetText(loc("IT_STACK_COUNT"));
	setTooltipForSameFrame(gameplay.stackcount.help, "RIGHT", 0, 5, loc("IT_STACK_COUNT"), loc("IT_STACK_COUNT_TT"));

	-- Use
	gameplay.use.Text:SetText(loc("IT_USE"));
	setTooltipForSameFrame(gameplay.use, "RIGHT", 0, 5, loc("IT_USE"), loc("IT_USE_TT"));

	-- Use text
	gameplay.usetext.title:SetText(loc("IT_USE_TEXT"));
	setTooltipForSameFrame(gameplay.usetext.help, "RIGHT", 0, 5, loc("IT_USE_TEXT"), loc("IT_USE_TEXT_TT"));

	local onCheckClicked = function()
		refreshCheck();
	end
	gameplay.unique:SetScript("OnClick", onCheckClicked);
	gameplay.stack:SetScript("OnClick", onCheckClicked);
	gameplay.use:SetScript("OnClick", onCheckClicked);
	display.quest:SetScript("OnClick", onCheckClicked);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- NOTES
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Notes
	notes = toolFrame.item.normal.notes;
	notes.title:SetText(loc("EDITOR_NOTES"));
end