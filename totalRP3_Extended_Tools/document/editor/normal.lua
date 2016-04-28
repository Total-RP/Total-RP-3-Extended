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
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local toolFrame, main, pages, params;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDefaultPanel()
	assert(toolFrame.specificDraft, "specificDraft is nil");

	params.title:SetText(loc("DO_PARAMS_GLOBAL"));

	params:Show();
end

local function loadCustomPanel(page)
	assert(toolFrame.specificDraft, "specificDraft is nil");

	params.title:SetText(loc("DO_PARAMS_CUSTOM"));

	params:Show();
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
	if not data.PA[1] then
		data.PA[1] = {};
	end
	if not data.BA then
		data.BA = {};
	end

	main.name:SetText(data.BA.NA or "");


	-- Temp
	params.title:SetText(loc("DO_PARAMS_GLOBAL"));
	pages.editor.scroll.text:SetText(data.PA[1].TX or "");
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
end

local function saveToDraft()
	assert(toolFrame.specificDraft, "specificDraft is nil");

	local data = toolFrame.specificDraft;
	data.BA.NA = stEtN(strtrim(main.name:GetText()));
	data.PA[1].TX = stEtN(strtrim(pages.editor.scroll.text:GetText()));
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
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initDocumentEditorNormal(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.document.normal.load = load;
	toolFrame.document.normal.saveToDraft = saveToDraft;

	-- Main
	main = toolFrame.document.normal.main;
	main.title:SetText(loc("TYPE_DOCUMENT"));

	-- Name
	main.name.title:SetText(loc("DO_NAME"));
	setTooltipForSameFrame(main.name.help, "RIGHT", 0, 5, loc("DO_NAME"), loc("DO_NAME_TT"));

	-- Default params button
	main.params:SetText(loc("DO_PARAMS_GLOBAL"));
	setTooltipForSameFrame(main.params, "BOTTOM", 0, -5, loc("DO_PARAMS_GLOBAL"), loc("DO_PARAMS_GLOBAL_TT"));
	main.params:SetScript("OnClick", function()
		loadDefaultPanel();
	end);
	main.params:Hide(); -- TODO: ;)

	-- Preview
	main.preview.Name:SetText(loc("EDITOR_PREVIEW"));
	main.preview.InfoText:SetText(loc("DO_PREVIEW"));
	main.preview.Icon:SetTexture("Interface\\ICONS\\inv_darkmoon_eye");
	main.preview.Quest:Hide();
	main.preview:SetScript("OnClick", function(self)
		saveToDraft();
		TRP3_API.extended.document.showDocumentClass(toolFrame.specificDraft);
	end);

	-- Params
	params = toolFrame.document.normal.params;

	-- Background
	TRP3_API.ui.listbox.setupListBox(params.background, TRP3_API.ui.frame.getTiledBackgroundList(), nil, nil, 205, true);

	-- Border
	TRP3_API.ui.listbox.setupListBox(params.border, {
		{TRP3_API.formats.dropDownElements:format(loc("DO_PAGE_BORDER"), loc("DO_PAGE_BORDER_1")), TRP3_API.extended.document.BorderType.PARCHMENT},
	}, nil, nil, 205, true);

	-- Height
	params.height.title:SetText(loc("DO_PAGE_HEIGHT"));
	setTooltipForSameFrame(params.height.help, "RIGHT", 0, 5, loc("DO_PAGE_HEIGHT"), loc("DO_PAGE_HEIGHT_TT"));

	-- Width
	params.width.title:SetText(loc("DO_PAGE_WIDTH"));
	setTooltipForSameFrame(params.width.help, "RIGHT", 0, 5, loc("DO_PAGE_WIDTH"), loc("DO_PAGE_WIDTH_TT"));

	-- Vertical tiling
	params.tile.Text:SetText(loc("DO_PAGE_TILING"));
	setTooltipForSameFrame(params.tile, "RIGHT", 0, 5, loc("DO_PAGE_TILING"), loc("DO_PAGE_TILING_TT"));

	-- Resizable
	params.resizable.Text:SetText(loc("DO_PAGE_RESIZE"));
	setTooltipForSameFrame(params.resizable, "RIGHT", 0, 5, loc("DO_PAGE_RESIZE"), loc("DO_PAGE_RESIZE_TT"));

	local getFontStructure = function(h)
		return {
			{TRP3_API.formats.dropDownElements:format(loc("DO_PAGE_FONT"):format(h), "DestinyFontHuge"), "DestinyFontHuge"},
			{TRP3_API.formats.dropDownElements:format(loc("DO_PAGE_FONT"):format(h), "QuestFont_Huge"), "QuestFont_Huge"},
			{TRP3_API.formats.dropDownElements:format(loc("DO_PAGE_FONT"):format(h), "GameFontNormalLarge"), "GameFontNormalLarge"},
			{TRP3_API.formats.dropDownElements:format(loc("DO_PAGE_FONT"):format(h), "GameTooltipHeader"), "GameTooltipHeader"},
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
	pages.title:SetText(loc("DO_PAGE_EDITOR"));
	TRP3_API.ui.text.setupToolbar(pages.toolbar, pages.editor.scroll.text, pages, "RIGHT", "LEFT");
	TRP3_API.events.listenToEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, function(containerwidth, containerHeight)
		pages.editor.scroll.text:GetScript("OnShow")(pages.editor.scroll.text);
	end);

end