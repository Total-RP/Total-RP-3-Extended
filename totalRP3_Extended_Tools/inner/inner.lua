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
local CreateFrame = CreateFrame;
local wipe, pairs, error, assert, tinsert = wipe, pairs, error, assert, tinsert;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local loc = TRP3_API.locale.getText;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local initList = TRP3_API.ui.list.initList;

local toolFrame;
local editor = TRP3_InnerObjectEditor;
editor.browser.container.lines = {};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Inner object editor: Logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function createInnerObject(innerID, innerType, innerData)
	assert(toolFrame.specificDraft.IN, "No toolFrame.specificDraft.IN for refresh.");
	assert(innerID and innerID:len() > 0, "Bad inner ID");
	assert(not toolFrame.specificDraft.IN[innerID], "Inner ID not available.");

	if innerType == TRP3_DB.types.ITEM then
		toolFrame.specificDraft.IN[innerID] = innerData or {
			TY = TRP3_DB.types.ITEM,
			MD = {
				MO = TRP3_DB.modes.NORMAL,
			},
			BA = {
				NA = loc("IT_NEW_NAME"),
			},
		}
	elseif innerType == TRP3_DB.types.DOCUMENT then
		toolFrame.specificDraft.IN[innerID] = innerData or {
			TY = TRP3_DB.types.DOCUMENT,
			MD = {
				MO = TRP3_DB.modes.NORMAL,
			},
			BA = {
				NA = loc("DO_NEW_DOC"),
			},
		}
	elseif innerType == "quick" then
		toolFrame.specificDraft.IN[innerID] = innerData;
	end

end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Inner object editor: UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function decorateLine(line, objectID)
	assert(toolFrame.specificDraft.IN[objectID]);
	local innerObject = toolFrame.specificDraft.IN[objectID];
	local icon, name, description = TRP3_API.extended.tools.getClassDataSafeByType(innerObject);
	local text = ("|cff00ff00%s: |r\"%s|r\" |cff00ffff(ID: %s)"):format(getTypeLocale(innerObject.TY) or UNKNOWN, name or UNKNOWN, objectID);
	line.text:SetText(text);

	setTooltipForSameFrame(line, "BOTTOMRIGHT", 0, 0, objectID, "[Don't know yet]"); --TODO: finish
end

local function refresh()
	assert(toolFrame.specificDraft.IN, "No toolFrame.specificDraft.IN for refresh.");
	editor.browser.id:SetText("");
	initList(
		{
			widgetTab = editor.browser.container.lines,
			decorate = decorateLine
		},
		toolFrame.specificDraft.IN,
		editor.browser.container.slider
	);
end
editor.refresh = refresh;

local function onLineClicked(line, button)

end

local function addInnerObject(type)
	assert(toolFrame.specificDraft.IN, "No toolFrame.specificDraft.IN for refresh.");
	local innerID = editor.browser.id:GetText();
	if innerID and innerID:len() > 0 then
		if not toolFrame.specificDraft.IN[innerID] then
			createInnerObject(innerID, type);
			refresh();
		else
			-- TODO: alert exists
		end
	else
		-- TODO: alert ID empty
	end
end

local function onAddClicked(self)
	local values = {};
	tinsert(values, {"Select inner object type", nil});
	tinsert(values, {loc("TYPE_ITEM"), TRP3_DB.types.ITEM});
	tinsert(values, {loc("TYPE_DOCUMENT"), TRP3_DB.types.DOCUMENT});
	tinsert(values, {loc("TYPE_LOOT"), nil}); --TRP3_DB.types.LOOT});
	tinsert(values, {loc("TYPE_DIALOG"), nil}); --TRP3_DB.types.DIALOG});
	TRP3_API.ui.listbox.displayDropDown(self, values, addInnerObject, 0, true);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function editor.init(ToolFrame)
	toolFrame = ToolFrame;

	editor.browser.title:SetText("Inner object list"); -- TODO: local
	editor.help.title:SetText("What are inner objects?"); -- TODO: local
	editor.help.text:SetText("here I will place a pretty wall of text explaining the concept of inner objects."); -- TODO: local
	editor.browser.add:SetText("Add"); -- TODO: local
	editor.browser.addText:SetText("Add inner object"); -- TODO: local
	editor.browser.id.title:SetText("Enter inner object ID");
	setTooltipForSameFrame(editor.browser.id.help, "RIGHT", 0, 5, "Enter inner object ID", "pouic");

	editor.browser.add:SetScript("OnClick", onAddClicked);
	handleMouseWheel(editor.browser.container, editor.browser.container.slider);
	editor.browser.container.slider:SetValue(0);
	-- Create lines
	for line = 0, 8 do
		local lineFrame = CreateFrame("Button", "TRP3_InnerObjectEditorLine" .. line, editor.browser.container, "TRP3_InnerObjectEditorLine");
		lineFrame:SetPoint("TOP", editor.browser.container, "TOP", 0, -10 + (line * (-31)));
		lineFrame:SetScript("OnClick", onLineClicked);
		tinsert(editor.browser.container.lines, lineFrame);
	end
end