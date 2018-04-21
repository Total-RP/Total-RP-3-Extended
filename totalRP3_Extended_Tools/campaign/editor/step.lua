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
local toolFrame, main;

local TABS = {
	MAIN = 1,
	WORKFLOWS = 2,
	INNER = 3,
	EXPERT = 4,
	ACTIONS = 5
}

local tabGroup, currentTab, linksStructure;
local actionEditor = TRP3_ActionsEditorFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Script & inner & links tabs
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDataScript()
	-- Load workflows
	if not toolFrame.specificDraft.SC then
		toolFrame.specificDraft.SC = {};
	end
	TRP3_ScriptEditorNormal.loadList(TRP3_DB.types.QUEST_STEP);
end

local function storeDataScript()
	-- TODO: compute all workflow order
	for _, workflow in pairs(toolFrame.specificDraft.SC) do
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

	toolFrame.step:Show();

	local data = toolFrame.specificDraft;

	if not data.BA then
		data.BA = {};
	end

	main.pre.scroll.text:SetText(data.BA.TX or "");
	main.post.scroll.text:SetText(data.BA.DX or "");
	main.auto:SetChecked(data.BA.IN or false);
	main.final:SetChecked(data.BA.FI or false);

	loadDataScript();
	loadDataInner();
	TRP3_LinksEditor.load(linksStructure);

	actionEditor.load();

	tabGroup:SelectTab(TRP3_API.extended.tools.getSaveTab(toolFrame.fullClassID, tabGroup:Size()));
end

local function saveToDraft()
	assert(toolFrame.specificDraft, "specificDraft is nil");
	local data = toolFrame.specificDraft;
	data.BA.NA = toolFrame.specificClassID;
	data.BA.TX = stEtN(strtrim(main.pre.scroll.text:GetText()));
	data.BA.DX = stEtN(strtrim(main.post.scroll.text:GetText()));
	data.BA.IN = main.auto:GetChecked();
	data.BA.FI = main.final:GetChecked();
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
	actionEditor:Hide();
	TRP3_ScriptEditorNormal:Hide();
	TRP3_InnerObjectEditor:Hide();
	TRP3_LinksEditor:Hide();
	TRP3_ExtendedTutorial.loadStructure(nil);

	-- Show tab
	if currentTab == TABS.MAIN then
		main:Show();
	elseif currentTab == TABS.WORKFLOWS then
		TRP3_ScriptEditorNormal:SetParent(toolFrame.step);
		TRP3_ScriptEditorNormal:SetAllPoints();
		TRP3_ScriptEditorNormal:Show();
	elseif currentTab == TABS.INNER then
		TRP3_InnerObjectEditor:SetParent(toolFrame.step);
		TRP3_InnerObjectEditor:SetAllPoints();
		TRP3_InnerObjectEditor:Show();
	elseif currentTab == TABS.EXPERT then
		TRP3_LinksEditor:SetParent(toolFrame.step);
		TRP3_LinksEditor:SetAllPoints();
		TRP3_LinksEditor:Show();
		TRP3_LinksEditor.load(linksStructure);
	elseif currentTab == TABS.ACTIONS then
		actionEditor.place(toolFrame.step);
	end

	TRP3_API.extended.tools.saveTab(toolFrame.fullClassID, currentTab);
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameStepNormalTabPanel", toolFrame.step);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ loc.EDITOR_MAIN, TABS.MAIN, 150 },
			{ loc.IN_INNER, TABS.INNER, 150 },
			{ loc.WO_WORKFLOW, TABS.WORKFLOWS, 150 },
			{ loc.WO_LINKS, TABS.EXPERT, 150 },
			{ loc.CA_ACTIONS, TABS.ACTIONS, 150 },
		},
		onTabChanged
	);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initStep(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.step.onLoad = load;
	toolFrame.step.onSave = saveToDraft;

	createTabBar();

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- MAIN
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Main
	main = toolFrame.step.main;
	main.title:SetText(loc.TYPE_QUEST_STEP);

	-- Pre
	main.pre.title:SetText(loc.QE_ST_PRE);

	-- Post
	main.post.title:SetText(loc.QE_ST_POST);

	-- Auto reveal
	main.auto.Text:SetText(loc.QE_ST_AUTO_REVEAL);
	setTooltipForSameFrame(main.auto, "RIGHT", 0, 5, loc.QE_ST_AUTO_REVEAL, loc.QE_ST_AUTO_REVEAL_TT);

	-- Auto reveal
	main.final.Text:SetText(loc.QE_ST_END);
	setTooltipForSameFrame(main.final, "RIGHT", 0, 5, loc.QE_ST_END, loc.QE_ST_END_TT);

	-- Links
	linksStructure = {
		{
			text = loc.QE_ST_LINKS_ON_START,
			tt = loc.QE_ST_LINKS_ON_START_TT,
			icon = "Interface\\ICONS\\achievement_quests_completed_03",
			field = "OS",
		},
		{
			text = loc.QE_ST_LINKS_ON_LEAVE,
			tt = loc.QE_ST_LINKS_ON_LEAVE_TT,
			icon = "Interface\\ICONS\\achievement_quests_completed_04",
			field = "OL",
		}
	}

end