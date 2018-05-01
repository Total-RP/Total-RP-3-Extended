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
local pairs, max, tonumber, tremove, strtrim, assert, tinsert = pairs, math.max, tonumber, tremove, strtrim, assert, tinsert;
local tContains = tContains;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local toolFrame, main, pages, params, manager, linksStructure;

local TABS = {
	MAIN = 1,
	WORKFLOWS = 2,
	EXPERT = 3,
}

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDefaultPanel()
	assert(toolFrame.specificDraft, "specificDraft is nil");

	params.title:SetText(loc.DO_PARAMS_GLOBAL);

	params:Show();
end

local function loadCustomPanel(page)
	assert(toolFrame.specificDraft, "specificDraft is nil");

	params.title:SetText(loc.DO_PARAMS_CUSTOM);

	params:Show();
end

local function saveCurrentPage()
	assert(toolFrame.specificDraft, "specificDraft is nil");
	local data = toolFrame.specificDraft;
	data.PA[manager.current].TX = stEtN(strtrim(pages.editor.scroll.text:GetText()));
end

local function loadPage(page)
	assert(toolFrame.specificDraft, "specificDraft is nil");

	if manager.current ~= nil then
		saveCurrentPage();
	end

	local data = toolFrame.specificDraft;

	if not data.PA[page] then
		data.PA[page] = {};
	end

	local total = #data.PA;

	manager.next:Disable();
	manager.previous:Disable();
	manager.first:Disable();
	manager.last:Disable();
	pages.remove:Disable();
	if page > 1 then
		manager.first:Enable();
		manager.previous:Enable();
	end
	if page < total then
		manager.next:Enable();
		manager.last:Enable();
	end
	if total > 1 then
		pages.remove:Enable();
	end

	pages.editor.scroll.text:SetText(data.PA[page].TX or "");
	pages.title:SetText(loc.DO_PAGE_EDITOR:format(page));
	manager.count:SetText(loc.DO_PAGE_COUNT:format(page, total));

	manager.current = page;
end

local function addPage()
	assert(toolFrame.specificDraft, "specificDraft is nil");
	local data = toolFrame.specificDraft;
	local total = #data.PA;
	data.PA[total + 1] = {};
	loadPage(total + 1);
end

local function removePage()
	assert(toolFrame.specificDraft, "specificDraft is nil");
	local data = toolFrame.specificDraft;
	local current = manager.current;
	assert(#data.PA > 1, "Must have at least one page");
	tremove(data.PA, current);
	manager.current = nil;
	loadPage(max(1, current - 1));
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Script tab
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDataScript()
	-- Load workflows
	if not toolFrame.specificDraft.SC then
		toolFrame.specificDraft.SC = {};
	end
	TRP3_ScriptEditorNormal.loadList(TRP3_DB.types.DOCUMENT);
end

local function storeDataScript()
	-- TODO: compute all workflow order
	for workflowID, workflow in pairs(toolFrame.specificDraft.SC) do
		TRP3_ScriptEditorNormal.linkElements(workflow);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TABS
-- Tabs in the list section are just pre-filters
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local currentTab, tabGroup;

local function onTabChanged(tabWidget, tab)
	assert(toolFrame.fullClassID, "fullClassID is nil");

	-- Hide all
	currentTab = tab or TABS.MAIN;
	main:Hide();
	params:Hide();
	pages:Hide();
	manager:Hide();
	TRP3_ScriptEditorNormal:Hide();
	TRP3_LinksEditor:Hide();
	TRP3_ExtendedTutorial.loadStructure(nil);

	-- Show tab
	if currentTab == TABS.MAIN then
		main:Show();
		params:Show();
		pages:Show();
		manager:Show();
	elseif currentTab == TABS.WORKFLOWS then
		TRP3_ScriptEditorNormal:SetParent(toolFrame.document.normal);
		TRP3_ScriptEditorNormal:SetAllPoints();
		TRP3_ScriptEditorNormal:Show();
	elseif currentTab == TABS.EXPERT then
		TRP3_LinksEditor:SetParent(toolFrame.document.normal);
		TRP3_LinksEditor:SetAllPoints();
		TRP3_LinksEditor:Show();
		TRP3_LinksEditor.load(linksStructure);
	end

	TRP3_API.extended.tools.saveTab(toolFrame.fullClassID, currentTab);
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameDocumentNormalTabPanel", toolFrame.document.normal);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ loc.EDITOR_MAIN, TABS.MAIN, 150 },
			{ loc.WO_WORKFLOW, TABS.WORKFLOWS, 150 },
			{ loc.WO_LINKS, TABS.EXPERT, 150 },
		},
		onTabChanged
	);
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
	if not data.PA then
		data.PA = {};
	end
	if not data.BA then
		data.BA = {};
	end

	-- Temp
	params.title:SetText(loc.DO_PARAMS_GLOBAL);
	params.background:SetSelectedValue(data.BCK or 8);
	params.border:SetSelectedValue(data.BO or TRP3_API.extended.document.BorderType.PARCHMENT);
	params.height:SetText(data.HE or "600");
	params.width:SetText(data.WI or "450");
	params.h1_font:SetSelectedValue(data.H1_F or "DestinyFontHuge");
	params.h2_font:SetSelectedValue(data.H2_F or "QuestFont_Huge");
	params.h3_font:SetSelectedValue(data.H3_F or "GameFontNormalLarge");
	params.p_font:SetSelectedValue(data.P_F or "GameTooltipHeader");
	params.tile:SetChecked(data.BT or false);
	params.resizable:SetChecked(data.FR or false);

	manager.current = nil;
	loadPage(1);

	loadDataScript();
	TRP3_LinksEditor.load(linksStructure);

	tabGroup:SelectTab(TRP3_API.extended.tools.getSaveTab(toolFrame.fullClassID, tabGroup:Size()));
end

local function saveToDraft()
	assert(toolFrame.specificDraft, "specificDraft is nil");

	local data = toolFrame.specificDraft;
	data.BCK = params.background:GetSelectedValue() or 8;
	data.BO = params.border:GetSelectedValue() or TRP3_API.extended.document.BorderType.PARCHMENT;
	data.HE = tonumber(params.height:GetText()) or 600;
	data.WI = tonumber(params.width:GetText()) or 450;
	data.H1_F = params.h1_font:GetSelectedValue() or "DestinyFontHuge";
	data.H2_F = params.h2_font:GetSelectedValue() or "QuestFont_Huge";
	data.H3_F = params.h3_font:GetSelectedValue() or "GameFontNormalLarge";
	data.P_F = params.p_font:GetSelectedValue() or "GameTooltipHeader";
	data.BT = params.tile:GetChecked();
	data.FR = params.resizable:GetChecked();

	saveCurrentPage();

	storeDataScript();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initDocumentEditorNormal(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.document.normal.load = load;
	toolFrame.document.normal.saveToDraft = saveToDraft;

	createTabBar();

	-- Main
	main = toolFrame.document.normal.main;
	main.title:SetText(loc.TYPE_DOCUMENT);

	-- Default params button
	main.params:SetText(loc.DO_PARAMS_GLOBAL);
	setTooltipForSameFrame(main.params, "BOTTOM", 0, -5, loc.DO_PARAMS_GLOBAL, loc.DO_PARAMS_GLOBAL_TT);
	main.params:SetScript("OnClick", function()
		loadDefaultPanel();
	end);
	main.params:Hide(); -- TODO: ;)

	-- Preview
	main.preview.Name:SetText(loc.EDITOR_PREVIEW);
	main.preview.InfoText:SetText(loc.DO_PREVIEW);
	main.preview.Icon:SetTexture("Interface\\ICONS\\inv_darkmoon_eye");
	main.preview:SetScript("OnClick", function(self)
		saveToDraft();
		TRP3_API.extended.document.showDocumentClass(toolFrame.specificDraft, nil);
	end);

	-- Params
	params = toolFrame.document.normal.params;

	-- Background
	TRP3_API.ui.listbox.setupListBox(params.background, TRP3_API.ui.frame.getTiledBackgroundList(), nil, nil, 205, true);

	-- Border
	TRP3_API.ui.listbox.setupListBox(params.border, {
		{TRP3_API.formats.dropDownElements:format(loc.DO_PAGE_BORDER, loc.DO_PAGE_BORDER_1), TRP3_API.extended.document.BorderType.PARCHMENT},
	}, nil, nil, 205, true);

	-- Height
	params.height.title:SetText(loc.DO_PAGE_HEIGHT);
	setTooltipForSameFrame(params.height.help, "RIGHT", 0, 5, loc.DO_PAGE_HEIGHT, loc.DO_PAGE_HEIGHT_TT);

	-- Width
	params.width.title:SetText(loc.DO_PAGE_WIDTH);
	setTooltipForSameFrame(params.width.help, "RIGHT", 0, 5, loc.DO_PAGE_WIDTH, loc.DO_PAGE_WIDTH_TT);

	-- Vertical tiling
	params.tile.Text:SetText(loc.DO_PAGE_TILING);
	setTooltipForSameFrame(params.tile, "RIGHT", 0, 5, loc.DO_PAGE_TILING, loc.DO_PAGE_TILING_TT);

	-- Resizable
	params.resizable.Text:SetText(loc.DO_PAGE_RESIZE);
	setTooltipForSameFrame(params.resizable, "RIGHT", 0, 5, loc.DO_PAGE_RESIZE, loc.DO_PAGE_RESIZE_TT);

	local getFontStructure = function(h)
		return {
			{TRP3_API.formats.dropDownElements:format(loc.DO_PAGE_FONT:format(h), "DestinyFontHuge"), "DestinyFontHuge"},
			{TRP3_API.formats.dropDownElements:format(loc.DO_PAGE_FONT:format(h), "QuestFont_Huge"), "QuestFont_Huge"},
			{TRP3_API.formats.dropDownElements:format(loc.DO_PAGE_FONT:format(h), "GameFontNormalLarge"), "GameFontNormalLarge"},
			{TRP3_API.formats.dropDownElements:format(loc.DO_PAGE_FONT:format(h), "GameTooltipHeader"), "GameTooltipHeader"},
		}
	end

	-- H1
	TRP3_API.ui.listbox.setupListBox(params.h1_font, getFontStructure("H1"), nil, nil, 205, true);

	-- H2
	TRP3_API.ui.listbox.setupListBox(params.h2_font, getFontStructure("H2"), nil, nil, 205, true);

	-- H3
	TRP3_API.ui.listbox.setupListBox(params.h3_font, getFontStructure("H3"), nil, nil, 205, true);

	-- P
	TRP3_API.ui.listbox.setupListBox(params.p_font, getFontStructure("P"), nil, nil, 205, true);

	-- Pages
	pages = toolFrame.document.normal.pages;
	TRP3_API.ui.text.setupToolbar(pages.toolbar, pages.editor.scroll.text, pages, "RIGHT", "LEFT");
	TRP3_API.events.listenToEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, function(containerwidth, containerHeight)
		pages.editor.scroll.text:GetScript("OnShow")(pages.editor.scroll.text);
	end);
	pages.remove:SetText(loc.DO_PAGE_REMOVE);
	pages.remove:SetScript("OnClick", removePage);

	-- Manager
	manager = toolFrame.document.normal.summary;
	manager.title:SetText(loc.DO_PAGE_MANAGER);
	manager.add:SetText(loc.DO_PAGE_ADD);
	setTooltipForSameFrame(manager.next, "BOTTOM", 0, -5, loc.DO_PAGE_NEXT);
	setTooltipForSameFrame(manager.previous, "BOTTOM", 0, -5, loc.DO_PAGE_PREVIOUS);
	setTooltipForSameFrame(manager.first, "BOTTOM", 0, -5, loc.DO_PAGE_FIRST);
	setTooltipForSameFrame(manager.last, "BOTTOM", 0, -5, loc.DO_PAGE_LAST);
	manager.next:SetText(">");
	manager.previous:SetText("<");
	manager.first:SetText("<<");
	manager.last:SetText(">>");
	manager.add:SetScript("OnClick", addPage);
	manager.first:SetScript("OnClick", function() loadPage(1); end);
	manager.previous:SetScript("OnClick", function() loadPage(manager.current - 1); end);
	manager.next:SetScript("OnClick", function() loadPage(manager.current + 1); end);
	manager.last:SetScript("OnClick", function() loadPage(#toolFrame.specificDraft.PA); end);

	-- Workflows links
	linksStructure = {
		{
			text = loc.DO_LINKS_ONOPEN,
			tt = loc.DO_LINKS_ONOPEN_TT,
			icon = "Interface\\ICONS\\inv_inscription_scrollofwisdom_01",
			field = "OO",
		},
		{
			text = loc.DO_LINKS_ONCLOSE,
			tt = loc.DO_LINKS_ONCLOSE_TT,
			icon = "Interface\\ICONS\\inv_inscription_scrollofwisdom_02",
			field = "OC",
		}
	}

end