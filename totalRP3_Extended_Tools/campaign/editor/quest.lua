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
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;
local color = Utils.str.color;
local toolFrame, main, notes, objectives;

local TABS = {
	MAIN = 1,
	WORKFLOWS = 2,
	STEPS = 3,
	INNER = 4,
	EXPERT = 5
}

local tabGroup, currentTab, linksStructure;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Quest specifics
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Script & inner & links tabs
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDataScript()
	-- Load workflows
	if not toolFrame.specificDraft.SC then
		toolFrame.specificDraft.SC = {};
	end
	TRP3_ScriptEditorNormal.loadList(TRP3_DB.types.QUEST);
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

	toolFrame.quest:Show();

	local data = toolFrame.specificDraft;
	if not data.BA then
		data.BA = {};
	end
	if not data.OB then
		data.OB = {};
	end
	if not data.ST then
		data.ST = {};
	end

	notes.frame.scroll.text:SetText(data.NT or "");
	main.name:SetText(data.BA.NA or "");
	main.description.scroll.text:SetText(data.BA.DE or "");

	loadDataScript();
	loadDataInner();
	TRP3_LinksEditor.load(linksStructure);

	TRP3_ActionsEditorFrame.load();

	tabGroup:SelectTab(TRP3_Tools_Parameters.editortabs[toolFrame.fullClassID] or TABS.MAIN);
end

local function saveToDraft()
	assert(toolFrame.specificDraft, "specificDraft is nil");

	local data = toolFrame.specificDraft;
	data.NT = stEtN(strtrim(notes.frame.scroll.text:GetText()));
	data.BA.NA = stEtN(strtrim(main.name:GetText()));
	data.BA.DE = stEtN(strtrim(main.description.scroll.text:GetText()));

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
	objectives:Hide();
	TRP3_ActionsEditorFrame:Hide();
	TRP3_ScriptEditorNormal:Hide();
	TRP3_InnerObjectEditor:Hide();
	TRP3_LinksEditor:Hide();

	-- Show tab
	if currentTab == TABS.MAIN then
		main:Show();
		notes:Show();
		objectives:Show();
	elseif currentTab == TABS.WORKFLOWS then
		TRP3_ScriptEditorNormal:SetParent(toolFrame.quest);
		TRP3_ScriptEditorNormal:SetAllPoints();
		TRP3_ScriptEditorNormal:Show();
	elseif currentTab == TABS.STEPS then

	elseif currentTab == TABS.INNER then
		TRP3_InnerObjectEditor:SetParent(toolFrame.quest);
		TRP3_InnerObjectEditor:SetAllPoints();
		TRP3_InnerObjectEditor:Show();
	elseif currentTab == TABS.EXPERT then
		TRP3_LinksEditor:SetParent(toolFrame.quest);
		TRP3_LinksEditor:SetAllPoints();
		TRP3_LinksEditor:Show();
		TRP3_LinksEditor.load(linksStructure);
		TRP3_ActionsEditorFrame:Show();
	end

	TRP3_Tools_Parameters.editortabs[toolFrame.fullClassID] = currentTab;
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameQuestNormalTabPanel", toolFrame.quest);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ loc("EDITOR_MAIN"), TABS.MAIN, 150 },
			{ loc("QE_STEPS"), TABS.STEPS, 150 },
			{ loc("IN_INNER"), TABS.INNER, 150 },
			{ loc("WO_WORKFLOW"), TABS.WORKFLOWS, 150 },
			{ loc("WO_LINKS"), TABS.EXPERT, 150 },
		},
		onTabChanged
	);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initQuest(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.quest.onLoad = load;
	toolFrame.quest.onSave = saveToDraft;

	createTabBar();

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- MAIN
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Main
	main = toolFrame.quest.main;
	main.title:SetText(loc("TYPE_QUEST"));

	-- Name
	main.name.title:SetText(loc("QE_NAME"));
	setTooltipForSameFrame(main.name.help, "RIGHT", 0, 5, loc("QE_NAME"), loc("QE_NAME_TT"));

	-- Description
	main.description.title:SetText(loc("QE_DESCRIPTION"));
	setTooltipAll(main.description.dummy, "RIGHT", 0, 5, loc("QE_DESCRIPTION"), loc("QE_DESCRIPTION_TT"));

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- NOTES
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Notes
	notes = toolFrame.quest.notes;
	notes.title:SetText(loc("EDITOR_NOTES"));

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- OBJECTIVES
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Objectives
	objectives = toolFrame.quest.objectives;
	objectives.title:SetText(loc("QE_OBJ"));


	-- Links
	linksStructure = {
		{
			text = loc("QE_LINKS_ON_START"),
			tt = loc("QE_LINKS_ON_START_TT"),
			icon = "Interface\\ICONS\\achievement_quests_completed_02",
			field = "OS",
		}
	}

end