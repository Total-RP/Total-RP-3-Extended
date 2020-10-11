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

local Globals, Events, Utils, EMPTY = TRP3_API.globals, TRP3_API.events, TRP3_API.utils, TRP3_API.globals.empty;
local wipe, pairs, tonumber, tinsert, strtrim, assert = wipe, pairs, tonumber, tinsert, strtrim, assert;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame, setTooltipAll = TRP3_API.ui.tooltip.setTooltipForSameFrame, TRP3_API.ui.tooltip.setTooltipAll;
local toolFrame, currentTab, display, gameplay, notes, container, tabGroup, linksStructure;

local TABS = {
	MAIN = 1,
	EFFECTS = 2,
	CONTAINER = 3,
	INNER = 4,
	EXPERT = 5
}

local TUTORIAL, CONTAINER_TUTORIAL;

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
	tabGroup:SetTabVisible(3, false);
	tabGroup:SetTabVisible(5, false);
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
	if gameplay.container:GetChecked() then
		tabGroup:SetTabVisible(3, true);
	end
	if toolFrame.specificDraft.MD.MO == TRP3_DB.modes.EXPERT then
		tabGroup:SetTabVisible(2, true);
		tabGroup:SetTabVisible(5, true);
	end
end

local function loadDataMain()
	local data = toolFrame.specificDraft;
	if not data.BA then
		data.BA = {};
	end
	if not data.US then
		data.US = {};
	end

	display.name:SetText(data.BA.NA or "");
	display.description.scroll.text:SetText(data.BA.DE or "");
	display.quality:SetSelectedValue(data.BA.QA or Enum.ItemQuality.Common);
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
	gameplay.use:SetChecked(data.BA.US or false);
	gameplay.usetext:SetText(data.US.AC or "");
	gameplay.wearable:SetChecked(data.BA.WA or false);
	gameplay.container:SetChecked(data.BA.CT or false);
	gameplay.noAdd:SetChecked(data.BA.PA or false);
	gameplay.pickSound:SetSelectedValue(data.BA.PS or 1186);
	gameplay.dropSound:SetSelectedValue(data.BA.DS or 1203);

	notes.frame.scroll.text:SetText(data.NT or "");

	refreshCheck();
end

local function storeDataMain()
	local data = toolFrame.specificDraft;
	data.BA.NA = stEtN(strtrim(display.name:GetText()));
	data.BA.DE = stEtN(strtrim(display.description.scroll.text:GetText()));
	data.BA.LE = stEtN(strtrim(display.left:GetText()));
	data.BA.RI = stEtN(strtrim(display.right:GetText()));
	data.BA.QA = display.quality:GetSelectedValue() or Enum.ItemQuality.Common;
	data.BA.CO = display.component:GetChecked();
	data.BA.CR = display.crafted:GetChecked();
	data.BA.QE = display.quest:GetChecked();
	data.BA.IC = display.preview.selectedIcon;
	data.BA.VA = tonumber(gameplay.value:GetText()) or 0;
	data.BA.WE = tonumber(gameplay.weight:GetText()) or 0;
	data.BA.SB = gameplay.soulbound:GetChecked();
	data.BA.UN = gameplay.unique:GetChecked() and tonumber(gameplay.uniquecount:GetText());
	data.BA.ST = gameplay.stack:GetChecked() and tonumber(gameplay.stackcount:GetText());
	data.BA.WA = gameplay.wearable:GetChecked();
	data.BA.CT = gameplay.container:GetChecked();
	data.BA.PA = gameplay.noAdd:GetChecked();
	data.BA.US = gameplay.use:GetChecked();
	data.US.AC = stEtN(strtrim(gameplay.usetext:GetText()));
	data.US.SC = "onUse";
	data.NT = stEtN(strtrim(notes.frame.scroll.text:GetText()));
	data.BA.PS = gameplay.pickSound:GetSelectedValue() or 1186;
	data.BA.DS = gameplay.dropSound:GetSelectedValue() or 1203;

	return data;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Container tab
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local containerPreview = {};

local function onContainerResize(size)
	container.bag5x4:Hide();
	container.bag2x4:Hide();
	container.bag1x4:Hide();
	if size == "5x4" then
		container.bag5x4:Show();
	elseif size == "2x4" then
		container.bag2x4:Show();
	elseif size == "1x4" then
		container.bag1x4:Show();
	end
end

local function decorateContainerPreview(data)
	for _, preview in pairs(containerPreview) do
		TRP3_API.inventory.decorateContainer(preview, data);
	end
end

local function onContainerFrameUpdate(self)
	-- Durability
	local durability = "";
	local durabilityValue = tonumber(container.durability:GetText());
	if durabilityValue and durabilityValue > 0 then
		durability = (Utils.str.texture("Interface\\GROUPFRAME\\UI-GROUP-MAINTANKICON", 15) .. "%s/%s"):format(durabilityValue, durabilityValue);
	end
	self.DurabilityText:SetText(durability);

	-- Weight
	local weight = TRP3_API.extended.formatWeight(0) .. Utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15);
	self.WeightText:SetText(weight);
end

local function loadDataContainer()
	if not toolFrame.specificDraft.CO then
		toolFrame.specificDraft.CO = {};
	end
	local containerData = toolFrame.specificDraft.CO;
	container.type:SetSelectedValue(containerData.SI or "5x4");
	container.durability:SetText(containerData.DU or "0");
	container.maxweight:SetText(containerData.MW or "0");
	container.onlyinner:SetChecked(containerData.OI or false);

	onContainerResize(container.type:GetSelectedValue() or "5x4");
end

local function storeDataContainer()
	local data = toolFrame.specificDraft;
	data.CO.SI = container.type:GetSelectedValue() or "5x4";
	local row, column = data.CO.SI:match("(%d)x(%d)");
	data.CO.SR = row;
	data.CO.SC = column;
	data.CO.DU = tonumber(container.durability:GetText());
	data.CO.MW = tonumber(container.maxweight:GetText());
	data.CO.OI = container.onlyinner:GetChecked() or false;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Script tab
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDataScript()
	-- Load workflows
	if not toolFrame.specificDraft.SC then
		toolFrame.specificDraft.SC = {};
	end
	if toolFrame.specificDraft.MD.MO == TRP3_DB.modes.NORMAL then
		TRP3_ScriptEditorNormal.scriptTitle = loc.IT_ON_USE;
		TRP3_ScriptEditorNormal.scriptDescription = loc.IT_ON_USE_TT;
		TRP3_ScriptEditorNormal.workflowIDToLoad = "onUse";
	elseif toolFrame.specificDraft.MD.MO == TRP3_DB.modes.EXPERT then

	end
	TRP3_ScriptEditorNormal.loadList(TRP3_DB.types.ITEM);
end

local function storeDataScript()
	-- TODO: compute all workflow order
	for workflowID, workflow in pairs(toolFrame.specificDraft.SC) do
		TRP3_ScriptEditorNormal.linkElements(workflow);
	end
end

local function loadDataInner()
	-- Load inners
	if not toolFrame.specificDraft.IN then
		toolFrame.specificDraft.IN = {};
	end
	TRP3_InnerObjectEditor.refresh();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TABS
-- Tabs in the list section are just pre-filters
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onTabChanged(tabWidget, tab)
	assert(toolFrame.fullClassID, "fullClassID is nil");

	-- Hide all
	currentTab = tab or TABS.MAIN;
	display:Hide();
	gameplay:Hide();
	notes:Hide();
	container:Hide();
	TRP3_ScriptEditorNormal:Hide();
	TRP3_InnerObjectEditor:Hide();
	TRP3_LinksEditor:Hide();
	TRP3_ExtendedTutorial.loadStructure(nil);

	-- Show tab
	if currentTab == TABS.MAIN then
		display:Show();
		gameplay:Show();
		notes:Show();
		TRP3_ExtendedTutorial.loadStructure(TUTORIAL);
	elseif currentTab == TABS.EFFECTS then
		TRP3_ScriptEditorNormal:SetParent(toolFrame.item.normal);
		TRP3_ScriptEditorNormal:SetAllPoints();
		TRP3_ScriptEditorNormal:Show();
	elseif currentTab == TABS.CONTAINER then
		decorateContainerPreview(storeDataMain());
		container:Show();
		TRP3_ExtendedTutorial.loadStructure(CONTAINER_TUTORIAL);
	elseif currentTab == TABS.INNER then
		TRP3_InnerObjectEditor:SetParent(toolFrame.item.normal);
		TRP3_InnerObjectEditor:SetAllPoints();
		TRP3_InnerObjectEditor:Show();
	elseif currentTab == TABS.EXPERT then
		TRP3_LinksEditor:SetParent(toolFrame.item.normal);
		TRP3_LinksEditor:SetAllPoints();
		TRP3_LinksEditor:Show();
		TRP3_LinksEditor.load(linksStructure);
	end

	TRP3_API.extended.tools.saveTab(toolFrame.fullClassID, currentTab);
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameItemNormalTabPanel", toolFrame.item.normal);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ loc.EDITOR_MAIN, TABS.MAIN, 150 },
			{ loc.WO_WORKFLOW, TABS.EFFECTS, 150 },
			{ loc.IT_CON, TABS.CONTAINER, 150 },
			{ loc.IN_INNER, TABS.INNER, 150 },
			{ loc.WO_LINKS, TABS.EXPERT, 150 },
		},
		onTabChanged
	);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Load ans save
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadItem()
	assert(toolFrame.rootClassID, "rootClassID is nil");
	assert(toolFrame.fullClassID, "fullClassID is nil");
	assert(toolFrame.rootDraft, "rootDraft is nil");
	assert(toolFrame.specificDraft, "specificDraft is nil");

	if not toolFrame.specificDraft.BA then
		toolFrame.specificDraft.BA = {};
	end
	gameplay.mute = true;
	loadDataMain();
	loadDataScript();
	loadDataContainer();
	loadDataInner();
	tabGroup:SelectTab(TRP3_API.extended.tools.getSaveTab(toolFrame.fullClassID, tabGroup:Size()));
	gameplay.mute = false;
end

local function saveToDraft()
	storeDataMain();
	storeDataScript();
	storeDataContainer();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function createTutorialStructure()
	TUTORIAL = {
		{
			box = toolFrame, title = "DB", text = "TU_IT_1_TEXT",
			arrow = "DOWN", x = 0, y = 100, anchor = "CENTER", textWidth = 400,
			callback = function()
				tabGroup:SelectTab(1);
			end
		},
		{
			box = display, title = "TU_IT_2", text = "TU_IT_2_TEXT",
			arrow = "DOWN", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
			callback = function()
				tabGroup:SelectTab(1);
			end
		},
		{
			box = gameplay, title = "TU_IT_4", text = "TU_IT_4_TEXT",
			arrow = "DOWN", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
			callback = function()
				tabGroup:SelectTab(1);
			end
		},
		{
			box = notes, title = "TU_IT_3", text = "TU_IT_3_TEXT",
			arrow = "DOWN", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
			callback = function()
				tabGroup:SelectTab(1);
			end
		},
	}

	CONTAINER_TUTORIAL = {
		{
			box = toolFrame, title = "IT_CON", text = "TU_CO_1_TEXT",
			arrow = "DOWN", x = 0, y = 100, anchor = "CENTER", textWidth = 400,
		},
	}
end

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
	display.title:SetText(loc.IT_DISPLAY_ATT);

	-- Name
	display.name.title:SetText(loc.IT_FIELD_NAME);
	setTooltipForSameFrame(display.name.help, "RIGHT", 0, 5, loc.IT_FIELD_NAME, loc.IT_FIELD_NAME_TT);

	-- Quality
	TRP3_API.ui.listbox.setupListBox(display.quality, TRP3_ItemQuickEditor.qualityList, nil, nil, 200, true);

	-- Left attribute
	display.left.title:SetText(loc.IT_TT_LEFT);
	setTooltipForSameFrame(display.left.help, "RIGHT", 0, 5, loc.IT_TT_LEFT, loc.IT_TT_LEFT_TT);

	-- Right attribute
	display.right.title:SetText(loc.IT_TT_RIGHT);
	setTooltipForSameFrame(display.right.help, "RIGHT", 0, 5, loc.IT_TT_RIGHT, loc.IT_TT_RIGHT_TT);

	-- Description
	display.description.title:SetText(loc.IT_TT_DESCRIPTION);
	setTooltipAll(display.description.dummy, "RIGHT", 0, 5, loc.IT_TT_DESCRIPTION, loc.IT_TT_DESCRIPTION_TT);

	-- Component
	display.component.Text:SetText(loc.IT_TT_REAGENT);
	setTooltipForSameFrame(display.component, "RIGHT", 0, 5, loc.IT_TT_REAGENT, loc.IT_TT_REAGENT_TT);

	-- Quest
	display.quest.Text:SetText(loc.IT_QUEST);
	setTooltipForSameFrame(display.quest, "RIGHT", 0, 5, loc.IT_QUEST, loc.IT_QUEST_TT);

	-- Crafted
	display.crafted.Text:SetText(loc.IT_CRAFTED);
	setTooltipForSameFrame(display.crafted, "RIGHT", 0, 5, loc.IT_CRAFTED, loc.IT_CRAFTED_TT);

	-- Preview
	display.preview.Name:SetText(loc.EDITOR_PREVIEW);
	display.preview.InfoText:SetText(loc.EDITOR_ICON_SELECT);
	display.preview:SetScript("OnEnter", function(self)
		TRP3_API.inventory.showItemTooltip(self, {madeBy = Globals.player_id}, storeDataMain(), true);
	end);
	display.preview:SetScript("OnLeave", function(self)
		TRP3_ItemTooltip:Hide();
	end);
	display.preview:SetScript("OnClick", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.ICONS, {parent = self, point = "RIGHT", parentPoint = "LEFT"}, {onIconSelected});
	end);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Gameplay
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Gameplay
	gameplay = toolFrame.item.normal.gameplay;
	gameplay.title:SetText(loc.IT_GAMEPLAY_ATT);

	-- Value
	gameplay.value.title:SetText(loc.IT_TT_VALUE_FORMAT:format(Utils.str.texture("Interface\\MONEYFRAME\\UI-CopperIcon", 15)));
	setTooltipForSameFrame(gameplay.value.help, "RIGHT", 0, 5, loc.IT_TT_VALUE, loc.IT_TT_VALUE_TT);

	-- Weight
	gameplay.weight.title:SetText(loc.IT_TT_WEIGHT_FORMAT);
	setTooltipForSameFrame(gameplay.weight.help, "RIGHT", 0, 5, loc.IT_TT_WEIGHT, loc.IT_TT_WEIGHT_TT);

	-- Soulbound
	gameplay.soulbound.Text:SetText(ITEM_SOULBOUND);
	setTooltipForSameFrame(gameplay.soulbound, "RIGHT", 0, 5, ITEM_SOULBOUND, loc.IT_SOULBOUND_TT);

	-- Unique
	gameplay.unique.Text:SetText(ITEM_UNIQUE);
	setTooltipForSameFrame(gameplay.unique, "RIGHT", 0, 5, ITEM_UNIQUE, loc.IT_UNIQUE_TT);

	-- Unique count
	gameplay.uniquecount.title:SetText(loc.IT_UNIQUE_COUNT);
	setTooltipForSameFrame(gameplay.uniquecount.help, "RIGHT", 0, 5, loc.IT_UNIQUE_COUNT, loc.IT_UNIQUE_COUNT_TT);

	-- Stack
	gameplay.stack.Text:SetText(loc.IT_STACK);
	setTooltipForSameFrame(gameplay.stack, "RIGHT", 0, 5, loc.IT_STACK, loc.IT_STACK_TT);

	-- Stack count
	gameplay.stackcount.title:SetText(loc.IT_STACK_COUNT);
	setTooltipForSameFrame(gameplay.stackcount.help, "RIGHT", 0, 5, loc.IT_STACK_COUNT, loc.IT_STACK_COUNT_TT);

	-- Use
	gameplay.use.Text:SetText(loc.IT_USE);
	setTooltipForSameFrame(gameplay.use, "RIGHT", 0, 5, loc.IT_USE, loc.IT_USE_TT);

	-- Use text
	gameplay.usetext.title:SetText(loc.IT_USE_TEXT);
	setTooltipForSameFrame(gameplay.usetext.help, "RIGHT", 0, 5, loc.IT_USE_TEXT, loc.IT_USE_TEXT_TT);

	-- Wearable
	gameplay.wearable.Text:SetText(loc.IT_WEARABLE);
	setTooltipForSameFrame(gameplay.wearable, "RIGHT", 0, 5, loc.IT_WEARABLE, loc.IT_WEARABLE_TT);

	-- Container
	gameplay.container.Text:SetText(loc.IT_CON);
	setTooltipForSameFrame(gameplay.container, "RIGHT", 0, 5, loc.IT_CON, loc.IT_CONTAINER_TT);

	-- No add
	gameplay.noAdd.Text:SetText(loc.IT_NO_ADD);
	setTooltipForSameFrame(gameplay.noAdd, "RIGHT", 0, 5, loc.IT_NO_ADD, loc.IT_NO_ADD_TT);

	-- Pick up sound
	local pickUpList = {};
	for i = 1183, 1199 do
		tinsert(pickUpList, {loc.IT_PU_SOUND .. ": |cff00ff00" .. loc["IT_PU_SOUND_" .. i], i});
	end
	tinsert(pickUpList, {loc.IT_PU_SOUND .. ": |cff00ff00" .. loc["IT_PU_SOUND_".. 1221], 1221});
	TRP3_API.ui.listbox.setupListBox(gameplay.pickSound, pickUpList, function(value)
		if not gameplay.mute then
			TRP3_API.ui.misc.playSoundKit(value, "SFX");
		end
	end, nil, 200, true);

	-- Drop sound
	local dropList = {};
	for i = 1200, 1217 do
		tinsert(dropList, {loc.IT_DR_SOUND .. ": |cff00ff00" .. loc["IT_DR_SOUND_" .. i], i});
	end
	TRP3_API.ui.listbox.setupListBox(gameplay.dropSound, dropList, function(value)
		if not gameplay.mute then
			TRP3_API.ui.misc.playSoundKit(value, "SFX");
		end
	end, nil, 200, true);

	local onCheckClicked = function()
		refreshCheck();
	end
	gameplay.unique:SetScript("OnClick", onCheckClicked);
	gameplay.stack:SetScript("OnClick", onCheckClicked);
	gameplay.use:SetScript("OnClick", onCheckClicked);
	gameplay.container:SetScript("OnClick", onCheckClicked);
	display.quest:SetScript("OnClick", onCheckClicked);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- NOTES
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Notes
	notes = toolFrame.item.normal.notes;
	notes.title:SetText(loc.EDITOR_NOTES);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- CONTAINER
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- container
	container = toolFrame.item.normal.container;
	container.title:SetText(loc.IT_CON);

	-- Type
	container.containerTypes = {
		{(loc.IT_CO_SIZE .. ": |cff00ff00%s"):format(loc.IT_CO_SIZE_COLROW:format(5, 4)), "5x4"},
		{(loc.IT_CO_SIZE .. ": |cff00ff00%s"):format(loc.IT_CO_SIZE_COLROW:format(2, 4)), "2x4"},
		{(loc.IT_CO_SIZE .. ": |cff00ff00%s"):format(loc.IT_CO_SIZE_COLROW:format(1, 4)), "1x4"},
	};
	TRP3_API.ui.listbox.setupListBox(container.type, container.containerTypes, onContainerResize, nil, 230, true);

	-- Durability
	container.durability.title:SetText(loc.IT_CO_DURABILITY);
	setTooltipForSameFrame(container.durability.help, "RIGHT", 0, 5, loc.IT_CO_DURABILITY, loc.IT_CO_DURABILITY_TT);

	-- Max weight
	container.maxweight.title:SetText(loc.IT_CO_MAX);
	setTooltipForSameFrame(container.maxweight.help, "RIGHT", 0, 5, loc.IT_CO_MAX, loc.IT_CO_MAX_TT);

	-- Component
	container.onlyinner.Text:SetText(loc.IT_CO_ONLY_INNER);
	setTooltipForSameFrame(container.onlyinner, "RIGHT", 0, 5, loc.IT_CO_ONLY_INNER, loc.IT_CO_ONLY_INNER_TT);

	-- Preview
	for _, size in pairs({"5x4", "2x4", "1x4"}) do
		local preview = container["bag" .. size];
		containerPreview[size] = preview;
		preview.close:Disable();
		preview.LockIcon:Hide();
		TRP3_API.ui.frame.createRefreshOnFrame(preview, 0.25, onContainerFrameUpdate);
	end

	-- Expert
	linksStructure = {
		{
			text = loc.IT_TRIGGER_ON_USE,
			tt = loc.IT_TRIGGER_ON_USE_TT,
			icon = "Interface\\ICONS\\ability_paladin_handoflight",
			field = "OU",
		},
		{
			text = loc.IT_TRIGGER_ON_DESTROY,
			tt = loc.IT_TRIGGER_ON_DESTROY_TT,
			icon = "Interface\\ICONS\\spell_sandexplosion",
			field = "OD",
		},
	}

	createTutorialStructure();
end