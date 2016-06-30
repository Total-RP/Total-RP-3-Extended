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
local wipe, max, tonumber, strtrim, pairs, assert = wipe, math.max, tonumber, strtrim, pairs, assert;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local toolFrame, main, pages, params, manager, notes;

local TABS = {
	MAIN = 1,
	WORKFLOWS = 2,
	QUESTS = 3,
	NPC = 4,
	INNER = 5,
	EXPERT = 6
}

local tabGroup, currentTab;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Main tab
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onIconSelected(icon)
	main.vignette.Icon:SetTexture("Interface\\ICONS\\" .. (icon or "TEMP"));
	main.vignette.selectedIcon = icon;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Script & inner tabs
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDataScript()
	-- Load workflows
	if not toolFrame.specificDraft.SC then
		toolFrame.specificDraft.SC = {};
	end
	TRP3_ScriptEditorNormal.loadList(TRP3_DB.types.CAMPAIGN);
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

	main.name:SetText(data.BA.NA or "");
	main.description:SetText(data.BA.DE or "");
	main.range:SetText(data.BA.RA or "");
	onIconSelected(data.BA.IC);

	main.vignette.name:SetText(data.BA.NA or "");
	main.vignette.range:SetText(data.BA.RA or "");

	notes.frame.scroll.text:SetText(data.NT or "");

	loadDataScript();
	loadDataInner();

	tabGroup:SelectTab(TRP3_Tools_Parameters.editortabs[toolFrame.fullClassID] or TABS.MAIN);
end

local function saveToDraft()
	assert(toolFrame.specificDraft, "specificDraft is nil");

	local data = toolFrame.specificDraft;
	data.BA.NA = stEtN(strtrim(main.name:GetText()));
	data.BA.DE = stEtN(strtrim(main.description:GetText()));
	data.BA.RA = stEtN(strtrim(main.range:GetText()));
	data.BA.IC = main.vignette.selectedIcon;
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
	notes:Hide();
	TRP3_ScriptEditorNormal:Hide();
	TRP3_InnerObjectEditor:Hide();

	-- Show tab
	if currentTab == TABS.MAIN then
		main:Show();
		notes:Show();
	elseif currentTab == TABS.WORKFLOWS then
		TRP3_ScriptEditorNormal:SetParent(toolFrame.campaign.normal);
		TRP3_ScriptEditorNormal:SetAllPoints();
		TRP3_ScriptEditorNormal:Show();
	elseif currentTab == TABS.QUESTS then

	elseif currentTab == TABS.INNER then
		TRP3_InnerObjectEditor:SetParent(toolFrame.campaign.normal);
		TRP3_InnerObjectEditor:SetAllPoints();
		TRP3_InnerObjectEditor:Show();
	end

	TRP3_Tools_Parameters.editortabs[toolFrame.fullClassID] = currentTab;
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameCampaignNormalTabPanel", toolFrame.campaign.normal);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ loc("EDITOR_MAIN"), TABS.MAIN, 150 },
			{ loc("QE_QUESTS"), TABS.QUESTS, 150 },
			{ loc("QE_NPC"), TABS.NPC, 150 },
			{ loc("IN_INNER"), TABS.INNER, 150 },
			{ loc("WO_WORKFLOW"), TABS.WORKFLOWS, 150 },
			{ loc("WO_EXPERT"), TABS.EXPERT, 150 },
		},
		onTabChanged
	);
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
	main.title:SetText(loc("TYPE_CAMPAIGN"));

	-- Name
	main.name.title:SetText(loc("CA_NAME"));
	setTooltipForSameFrame(main.name.help, "RIGHT", 0, 5, loc("CA_NAME"), loc("CA_NAME_TT"));

	-- Description
	main.description.title:SetText(loc("CA_DESCRIPTION"));
	setTooltipForSameFrame(main.description.help, "RIGHT", 0, 5, loc("CA_DESCRIPTION"), loc("CA_DESCRIPTION_TT"));

	-- Range
	main.range.title:SetText(loc("CA_RANGE"));
	setTooltipForSameFrame(main.range.help, "RIGHT", 0, 5, loc("CA_RANGE"), loc("CA_RANGE_TT"));

	-- Vignette
	main.vignette.current:Hide();
	main.vignette.bgImage:SetTexture("Interface\\Garrison\\GarrisonUIBackground");
	main.vignette.Icon:SetVertexColor(0.7, 0.7, 0.7);
	main.vignette:SetScript("OnClick", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.ICONS, {parent = self, point = "RIGHT", parentPoint = "LEFT"}, {onIconSelected});
	end);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- NOTES
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Notes
	notes = toolFrame.campaign.normal.notes;
	notes.title:SetText(loc("EDITOR_NOTES"));
end