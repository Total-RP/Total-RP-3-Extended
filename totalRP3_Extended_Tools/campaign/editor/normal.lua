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
local tostring, tonumber, tinsert, strtrim, pairs, assert, wipe = tostring, tonumber, tinsert, strtrim, pairs, assert, wipe;
local tsize = Utils.table.size;
local getFullID, getClass = TRP3_API.extended.getFullID, TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;
local color = Utils.str.color;
local toolFrame, main, pages, params, manager, notes, npc, quests;

local TABS = {
	MAIN = 1,
	QUESTS = 2,
	INNER = 3,
	WORKFLOWS = 4,
	EXPERT = 5,
	ACTIONS = 6
}

local tabGroup, currentTab, linksStructure;
local actionEditor = TRP3_ActionsEditorFrame;
local linksEditor = TRP3_LinksEditor;
local scriptEditor = TRP3_ScriptEditorNormal;
local innerEditor = TRP3_InnerObjectEditor;

local questClipboard = {};
local questClipboardID;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- NPC
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onIconSelected(icon)
	main.vignette.Icon:SetTexture("Interface\\ICONS\\" .. (icon or "TEMP"));
	main.vignette.selectedIcon = icon;
end

local function onCampaignPortraitSelected(portrait)
	main.vignette.IconBorder:SetTexture("Interface\\ExtraButton\\" .. (portrait or "GarrZoneAbility-Stables"));
	main.vignette.selectedPortrait = portrait or "GarrZoneAbility-Stables";
end

local function onNPCIconSelected(icon)
	TRP3_API.ui.frame.setupIconButton(npc.editor.icon, icon);
	npc.editor.icon.selectedIcon = icon;
end

local function decorateNPCLine(line, npcID)
	local data = toolFrame.specificDraft;
	local npcData = data.ND[npcID];

	TRP3_API.ui.frame.setupIconButton(line.Icon, npcData.IC or Globals.icons.profile_default);
	line.Name:SetText(npcData.NA or loc.CA_NPC_NAME);
	line.Description:SetText(npcData.DE or "");
	line.ID:SetText(loc.CA_NPC_ID .. ": " .. npcID);
	line.click.npcID = npcID;
end

local function refreshNPCList()
	local data = toolFrame.specificDraft;
	TRP3_API.ui.list.initList(npc.list, data.ND, npc.list.slider);
	npc.list.empty:Hide();
	if tsize(data.ND) == 0 then
		npc.list.empty:Show();
	end
end

local UnitExists = UnitExists;

local function newNPC(npcID)
	npc.editor.oldID = nil;
	npc.editor.id:SetText(npcID or "");
	if UnitExists("target") then
		local unitType, npcID = Utils.str.getUnitDataFromGUID("target");
		if unitType == "Creature" and npcID then
			npc.editor.id:SetText(npcID);
		end
	end
	npc.editor.name:SetText("");
	npc.editor.description.scroll.text:SetText("");
	onNPCIconSelected(Globals.icons.profile_default);
	TRP3_API.ui.frame.configureHoverFrame(npc.editor, npc.list.add, "TOP", 0, 5, false);
end

local function createFrom(npcID)
	if not npcID then
		newNPC();
	else
		local npcData = toolFrame.specificDraft.ND[npcID];
		newNPC(npcID);
		npc.editor.name:SetText(npcData.NA or "");
		npc.editor.description.scroll.text:SetText(npcData.DE or "");
		onNPCIconSelected(npcData.IC or Globals.icons.profile_default);
	end
end

local function openNPC(npcID, frame)
	if not npcID then
		newNPC();
	else
		local npcData = toolFrame.specificDraft.ND[npcID];
		if npcData then
			npc.editor.oldID = npcID;
			npc.editor.id:SetText(npcID);
			npc.editor.name:SetText(npcData.NA or "");
			npc.editor.description.scroll.text:SetText(npcData.DE or "");
			onNPCIconSelected(npcData.IC or Globals.icons.profile_default);
			TRP3_API.ui.frame.configureHoverFrame(npc.editor, frame, "RIGHT", 0, 5);
		else
			newNPC();
		end
	end
end

local function onNPCSaved()
	local oldID = npc.editor.oldID;
	local ID = tostring(tonumber(strtrim(npc.editor.id:GetText())) or 0);
	local data = {
		NA = stEtN(strtrim(npc.editor.name:GetText())),
		DE = stEtN(strtrim(npc.editor.description.scroll.text:GetText())),
		IC = npc.editor.icon.selectedIcon or Globals.icons.profile_default
	}
	if ID then
		local structure = toolFrame.specificDraft.ND;
		if oldID and structure[oldID] then
			wipe(structure[oldID]);
			structure[oldID] = nil;
		end
		structure[ID] = data;
	end

	refreshNPCList();
	npc.editor:Hide();
end

local function removeNPC(id)
	TRP3_API.popup.showConfirmPopup(loc.CA_NPC_REMOVE, function()
		if toolFrame.specificDraft.ND[id] then
			wipe(toolFrame.specificDraft.ND[id]);
			toolFrame.specificDraft.ND[id] = nil;
		end
		refreshNPCList();
		npc.editor:Hide();
	end);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- QUESTS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function decorateQuestLine(line, questID)
	local data = toolFrame.specificDraft;
	local questData = data.QE[questID];

	TRP3_API.ui.frame.setupIconButton(line.Icon, questData.BA.IC or Globals.icons.default);
	line.Name:SetText(questData.BA.NA or UNKNOWN);
	if questData.BA.IN then
		line.ID:SetText(questID .. "\n|cff00ff00" .. loc.QE_AUTO_REVEAL);
	else
		line.ID:SetText(questID);
	end
	line.Description:SetText(questData.BA.DE or "");
	line.click.questID = questID;
end

local function refreshQuestsList()
	local data = toolFrame.specificDraft;
	TRP3_API.ui.list.initList(quests.list, data.QE or EMPTY, quests.list.slider);
	quests.list.empty:Hide();
	if tsize(data.QE) == 0 then
		quests.list.empty:Show();
	end
end

local function removeQuest(questID)
	TRP3_API.popup.showConfirmPopup(loc.CA_QUEST_REMOVE, function()
		if toolFrame.specificDraft.QE[questID] then
			wipe(toolFrame.specificDraft.QE[questID]);
			toolFrame.specificDraft.QE[questID] = nil;
		end
		refreshQuestsList();
	end);
end

local function openQuest(questID)
	TRP3_API.extended.tools.goToPage(getFullID(toolFrame.fullClassID, questID));
end

local function renameQuest(questID)
	TRP3_API.popup.showTextInputPopup(loc.CA_QUEST_CREATE, function(newID)
		newID = TRP3_API.extended.checkID(newID);
		if questID ~= newID and not toolFrame.specificDraft.QE[newID] then
			toolFrame.specificDraft.QE[newID] = toolFrame.specificDraft.QE[questID];
			toolFrame.specificDraft.QE[questID] = nil;
			refreshQuestsList();
		else
			Utils.message.displayMessage(loc.CA_QUEST_EXIST:format(newID), 4);
		end
	end, nil, questID);
end

local function createQuest()
	TRP3_API.popup.showTextInputPopup(loc.CA_QUEST_CREATE, function(value)
		value = TRP3_API.extended.checkID(value);
		if not toolFrame.specificDraft.QE[value] then
			toolFrame.specificDraft.QE[value] = TRP3_API.extended.tools.getQuestData();
			refreshQuestsList();
		else
			Utils.message.displayMessage(loc.CA_QUEST_EXIST:format(value), 4);
		end
	end, nil, "quest_" .. (Utils.table.size(toolFrame.specificDraft.QE) + 1) .. "_");
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Script & inner & links tabs
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDataScript()
	-- Load workflows
	if not toolFrame.specificDraft.SC then
		toolFrame.specificDraft.SC = {};
	end
	scriptEditor.loadList(TRP3_DB.types.CAMPAIGN);
end

local function storeDataScript()
	-- TODO: compute all workflow order
	for workflowID, workflow in pairs(toolFrame.specificDraft.SC) do
		scriptEditor.linkElements(workflow);
	end
end

local function loadDataInner()
	-- Load inners
	if not toolFrame.specificDraft.IN then
		toolFrame.specificDraft.IN = {};
	end
	innerEditor.refresh();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Load ans save
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function load()
	assert(toolFrame.rootClassID, "rootClassID is nil");
	assert(toolFrame.fullClassID, "fullClassID is nil");
	assert(toolFrame.rootDraft, "rootDraft is nil");
	assert(toolFrame.specificDraft, "specificDraft is nil");

	local data = toolFrame.specificDraft;
	if not data.BA then
		data.BA = {};
	end
	if not data.ND then
		data.ND = {};
	end
	if not data.QE then
		data.QE = {};
	end

	main.name:SetText(data.BA.NA or "");
	main.description.scroll.text:SetText(data.BA.DE or "");
	onIconSelected(data.BA.IC);
	onCampaignPortraitSelected(data.BA.IM)

	notes.frame.scroll.text:SetText(data.NT or "");

	loadDataScript();
	loadDataInner();
	linksEditor.load(linksStructure);

	actionEditor.load();

	tabGroup:SelectTab(TRP3_API.extended.tools.getSaveTab(toolFrame.fullClassID, tabGroup:Size()));
end

local function saveToDraft()
	assert(toolFrame.specificDraft, "specificDraft is nil");

	local data = toolFrame.specificDraft;
	data.BA.NA = stEtN(strtrim(main.name:GetText()));
	data.BA.DE = stEtN(strtrim(main.description.scroll.text:GetText()));
	data.BA.IC = main.vignette.selectedIcon;
	data.BA.IM = main.vignette.selectedPortrait;
	data.NT = stEtN(strtrim(notes.frame.scroll.text:GetText()));
	storeDataScript();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onTabChanged(tabWidget, tab)
	assert(toolFrame.fullClassID, "fullClassID is nil");

	-- Hide all
	currentTab = tab or TABS.MAIN;
	main:Hide();
	npc:Hide();
	notes:Hide();
	quests:Hide();
	actionEditor:Hide();
	scriptEditor:Hide();
	innerEditor:Hide();
	linksEditor:Hide();
	TRP3_ExtendedTutorial.loadStructure(nil);

	-- Show tab
	if currentTab == TABS.MAIN then
		main:Show();
		notes:Show();
		npc:Show();
		refreshNPCList();
	elseif currentTab == TABS.WORKFLOWS then
		scriptEditor:SetParent(toolFrame.campaign.normal);
		scriptEditor:SetAllPoints();
		scriptEditor:Show();
	elseif currentTab == TABS.QUESTS then
		quests:Show();
		refreshQuestsList();
	elseif currentTab == TABS.INNER then
		innerEditor:SetParent(toolFrame.campaign.normal);
		innerEditor:SetAllPoints();
		innerEditor:Show();
	elseif currentTab == TABS.EXPERT then
		linksEditor:SetParent(toolFrame.campaign.normal);
		linksEditor:SetAllPoints();
		linksEditor:Show();
		linksEditor.load(linksStructure);
	elseif currentTab == TABS.ACTIONS then
		actionEditor.place(toolFrame.campaign.normal);
	end

	TRP3_API.extended.tools.saveTab(toolFrame.fullClassID, currentTab);
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameCampaignNormalTabPanel", toolFrame.campaign.normal);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ loc.EDITOR_MAIN, TABS.MAIN, 150 },
			{ loc.QE_QUESTS, TABS.QUESTS, 150 },
			{ loc.IN_INNER, TABS.INNER, 150 },
			{ loc.WO_WORKFLOW, TABS.WORKFLOWS, 150 },
			{ loc.WO_LINKS, TABS.EXPERT, 150 },
			{ loc.CA_ACTIONS, TABS.ACTIONS, 150 },
		},
		onTabChanged
	);
end

local function onQuestDropdown(value, line)
	if value == 1 then
		wipe(questClipboard);
		questClipboardID = getFullID(toolFrame.fullClassID, line.questID);
		Utils.table.copy(questClipboard, toolFrame.specificDraft.QE[line.questID]);
	elseif value == 2 then
		wipe(toolFrame.specificDraft.QE[line.questID]);
		TRP3_API.extended.tools.replaceID(questClipboard, questClipboardID, getFullID(toolFrame.fullClassID, line.questID));
		Utils.table.copy(toolFrame.specificDraft.QE[line.questID], questClipboard);
		wipe(questClipboard);
		refreshQuestsList();
	elseif value == 3 then
		removeQuest(line.questID);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initCampaignEditorNormal(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.campaign.normal.load = load;
	toolFrame.campaign.normal.saveToDraft = saveToDraft;

	createTabBar();

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- MAIN
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Main
	main = toolFrame.campaign.normal.main;
	main.title:SetText(loc.TYPE_CAMPAIGN);

	-- Name
	main.name.title:SetText(loc.CA_NAME);
	setTooltipForSameFrame(main.name.help, "RIGHT", 0, 5, loc.CA_NAME, loc.CA_NAME_TT);

	-- Description
	main.description.title:SetText(loc.CA_DESCRIPTION);
	setTooltipAll(main.description.dummy, "RIGHT", 0, 5, loc.CA_DESCRIPTION, loc.CA_DESCRIPTION_TT);

	local CAMPAIGN_PORTRAITS = {
		"AirStrike",
		"Amber",
		"BrewmoonKeg",
		"ChampionLight",
		"Default",
		"Engineering",
		"EyeofTerrok",
		"Fel",
		"FengBarrier",
		"FengShroud",
		"GarrZoneAbility-Armory",
		"GarrZoneAbility-BarracksAlliance",
		"GarrZoneAbility-BarracksHorde",
		"GarrZoneAbility-Inn",
		"GarrZoneAbility-LumberMill",
		"GarrZoneAbility-MageTower",
		"GarrZoneAbility-Stables",
		"GarrZoneAbility-TradingPost",
		"GarrZoneAbility-TrainingPit",
		"GarrZoneAbility-Workshop",
		"GreenstoneKeg",
		"HozuBar",
		"LightningKeg",
		"Smash",
		"SoulSwap",
		"Ultraxion",
		"Ysera",
	}

	-- Vignette
	main.vignette:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	main.vignette:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			TRP3_API.popup.showPopup(TRP3_API.popup.ICONS, {parent = self, point = "TOP", parentPoint = "BOTTOM"}, {onIconSelected});
		else
			local values = {};
			tinsert(values, {loc.CA_IMAGE_TT});
			for index, portrait in pairs(CAMPAIGN_PORTRAITS) do
				tinsert(values, {TRP3_API.formats.dropDownElements:format(loc.CA_IMAGE, portrait), portrait, ("|TInterface\\ExtraButton\\%s:96:192|t"):format(portrait)});
			end
			TRP3_API.ui.listbox.displayDropDown(self, values, onCampaignPortraitSelected, 0, true);
		end
	end);
	setTooltipAll(main.vignette, "RIGHT", 0, 5, loc.CA_ICON,
		("|cffffff00%s: |cff00ff00%s\n"):format(loc.CM_CLICK, loc.CA_ICON_TT) .. ("|cffffff00%s: |cff00ff00%s"):format(loc.CM_R_CLICK, loc.CA_IMAGE_TT));

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- NOTES
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Notes
	notes = toolFrame.campaign.normal.notes;
	notes.title:SetText(loc.EDITOR_NOTES);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- NPC
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	npc = toolFrame.campaign.normal.npc;
	npc.title:SetText(loc.CA_NPC);
	npc.help:SetText(loc.CA_NPC_TT);

	-- List
	npc.list.widgetTab = {};
	for i=1, 4 do
		local line = npc.list["line" .. i];
		tinsert(npc.list.widgetTab, line);
		line.click:SetScript("OnClick", function(self, button)
			if button == "RightButton" then
				removeNPC(self.npcID);
			else
				if IsControlKeyDown() then
					createFrom(self.npcID, self);
				else
					openNPC(self.npcID, self);
				end
			end
		end);
		line.click:SetScript("OnEnter", function(self)
			TRP3_RefreshTooltipForFrame(self);
			self:GetParent().Highlight:Show();
		end);
		line.click:SetScript("OnLeave", function(self)
			TRP3_MainTooltip:Hide();
			self:GetParent().Highlight:Hide();
		end);
		line.click:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		setTooltipForSameFrame(line.click, "RIGHT", 0, 5, loc.CA_NPC_UNIT,
			("|cffffff00%s: |cff00ff00%s\n"):format(loc.CM_CLICK, loc.CM_EDIT) ..
			("|cffffff00%s: |cff00ff00%s\n"):format(loc.CM_CTRL .. " + " .. loc.CM_CLICK, loc.CA_NPC_AS) ..
			("|cffffff00%s: |cff00ff00%s"):format(loc.CM_R_CLICK, REMOVE));
	end
	npc.list.decorate = decorateNPCLine;
	TRP3_API.ui.list.handleMouseWheel(npc.list, npc.list.slider);
	npc.list.slider:SetValue(0);
	npc.list.add:SetText(loc.CA_NPC_ADD);
	npc.list.add:SetScript("OnClick", function() openNPC() end);
	npc.list.empty:SetText(loc.CA_NO_NPC);

	-- Editor
	npc.editor.title:SetText(loc.CA_NPC_EDITOR);
	npc.editor.id.title:SetText(loc.CA_NPC_ID);
	setTooltipForSameFrame(npc.editor.id.help, "RIGHT", 0, 5, loc.CA_NPC_ID, loc.CA_NPC_ID_TT);
	npc.editor.name.title:SetText(loc.CA_NPC_EDITOR_NAME);
	npc.editor.description.title:SetText(loc.CA_NPC_EDITOR_DESC);
	npc.editor.icon:SetScript("OnClick", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.ICONS, {parent = npc.editor, point = "RIGHT", parentPoint = "LEFT"}, {onNPCIconSelected});
	end);
	npc.editor.save:SetScript("OnClick", function(self)
		onNPCSaved();
	end);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- QUEST
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	quests = toolFrame.campaign.normal.quests;
	quests.title:SetText(loc.QE_QUESTS);
	quests.help:SetText(loc.QE_QUESTS_HELP);

	-- List
	quests.list.widgetTab = {};
	for i=1, 4 do
		local line = quests.list["line" .. i];
		tinsert(quests.list.widgetTab, line);
		line.click:SetScript("OnClick", function(self, button)
			if button == "RightButton" then
				local context = {};
				tinsert(context, {self.questID});
				tinsert(context, {loc.CA_QUEST_DD_COPY, 1});
				if next(questClipboard) then
					tinsert(context, {loc.CA_QUEST_DD_PASTE, 2});
				end
				tinsert(context, {loc.CA_QUEST_DD_REMOVE, 3});
				TRP3_API.ui.listbox.displayDropDown(line.click, context, onQuestDropdown, 0, true);
			else
				if IsControlKeyDown() then
					renameQuest(self.questID);
				else
					openQuest(self.questID);
				end
			end
		end);
		line.click:SetScript("OnEnter", function(self)
			TRP3_RefreshTooltipForFrame(self);
			self:GetParent().Highlight:Show();
		end);
		line.click:SetScript("OnLeave", function(self)
			TRP3_MainTooltip:Hide();
			self:GetParent().Highlight:Hide();
		end);
		line.click:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		setTooltipForSameFrame(line.click, "RIGHT", 0, 5, loc.TYPE_QUEST,
			("|cffffff00%s: |cff00ff00%s\n"):format(loc.CM_CLICK, loc.CM_EDIT)
			.. ("|cffffff00%s: |cff00ff00%s\n"):format(loc.CM_CTRL .. " + " .. loc.CM_CLICK, loc.CA_QE_ID)
			.. ("|cffffff00%s: |cff00ff00%s"):format(loc.CM_R_CLICK, loc.CA_ACTIONS));
	end
	quests.list.decorate = decorateQuestLine;
	TRP3_API.ui.list.handleMouseWheel(quests.list, quests.list.slider);
	quests.list.slider:SetValue(0);
	quests.list.add:SetText(loc.CA_QUEST_ADD);
	quests.list.add:SetScript("OnClick", function() createQuest() end);
	quests.list.empty:SetText(loc.CA_QUEST_NO);

	-- Links
	linksStructure = {
		{
			text = loc.CA_LINKS_ON_START,
			tt = loc.CA_LINKS_ON_START_TT,
			icon = "Interface\\ICONS\\achievement_quests_completed_08",
			field = "OS",
		}
	}

end