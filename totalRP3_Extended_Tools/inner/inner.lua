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
local getFullID, getClass = TRP3_API.extended.getFullID, TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local loc = TRP3_API.loc;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local refreshTooltipForFrame = TRP3_RefreshTooltipForFrame;
local showItemTooltip = TRP3_API.inventory.showItemTooltip;
local initList = TRP3_API.ui.list.initList;

local toolFrame;
local editor = TRP3_InnerObjectEditor;
editor.browser.container.lines = {};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Inner object editor: Logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function createInnerObject(innerID, innerType, innerMode, innerData)
	assert(toolFrame.specificDraft.IN, "No toolFrame.specificDraft.IN for refresh.");
	assert(innerID and innerID:len() > 0, "Bad inner ID");

	if toolFrame.specificDraft.IN[innerID] then
		Utils.message.displayMessage(loc.IN_INNER_NO_AVAILABLE, 4);
		return;
	end

	if innerType == TRP3_DB.types.ITEM then
		toolFrame.specificDraft.IN[innerID] = innerData or {
			TY = TRP3_DB.types.ITEM,
			MD = {
				MO = TRP3_DB.modes.NORMAL,
			},
			BA = {
				NA = loc.IT_NEW_NAME,
			},
		}

		if innerMode then
			toolFrame.specificDraft.IN[innerID].MD.MO = innerMode;
		end
	elseif innerType == TRP3_DB.types.DOCUMENT then
		toolFrame.specificDraft.IN[innerID] = innerData or {
			TY = TRP3_DB.types.DOCUMENT,
			MD = {
				MO = TRP3_DB.modes.NORMAL,
			},
			BA = {
				NA = loc.DO_NEW_DOC,
			},
			BT = true,
		}
	elseif innerType == TRP3_DB.types.DIALOG then
		toolFrame.specificDraft.IN[innerID] = innerData or TRP3_API.extended.tools.getCutsceneData();
	elseif innerType == "quick" then
		toolFrame.specificDraft.IN[innerID] = innerData;
	end

end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Inner object editor: UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function idExists(id)
	assert(toolFrame.specificDraft.IN, "No toolFrame.specificDraft.IN for refresh.");
	return toolFrame.specificDraft.IN[id];
end

local function onLineEnter(line)
	line.Highlight:Show();
	refreshTooltipForFrame(line);
	local class = toolFrame.specificDraft.IN[line.objectID];
	if class.TY == TRP3_DB.types.ITEM then
		showItemTooltip(line, Globals.empty, class, true, "ANCHOR_RIGHT");
	end
end

local function onLineLeave(line)
	line.Highlight:Hide();
	TRP3_MainTooltip:Hide();
	TRP3_ItemTooltip:Hide();
end

local function decorateLine(line, innerID)
	assert(toolFrame.specificDraft.IN[innerID]);
	local innerObject = toolFrame.specificDraft.IN[innerID];
	local _, name, _ = TRP3_API.extended.tools.getClassDataSafeByType(innerObject);
	local typeLocale = getTypeLocale(innerObject.TY) or UNKNOWN;
	local text = ("|cff00ff00%s:|r|cff00ffff %s:|r \"%s\""):format(typeLocale, innerID, name or UNKNOWN);
	line.objectID = innerID;
	line.text:SetText(text);

	local tooltip = ("|cff00ffff%s"):format(innerID);
	local tooltipsub = ("|cffffffff%s, |cff00ff00%s"):format(loc.IN_INNER_S, typeLocale);
	tooltipsub = tooltipsub .. "\n\n|cffffff00" .. loc.CM_CLICK .. ": |cffff9900" .. loc.CM_OPEN;
	tooltipsub = tooltipsub .. "\n|cffffff00" .. loc.CM_R_CLICK .. ": |cffff9900" .. loc.DB_ACTIONS;

	setTooltipForSameFrame(line, "BOTTOMRIGHT", 0, 0, tooltip, tooltipsub);
end

local function refresh()
	assert(toolFrame.specificDraft.IN, "No toolFrame.specificDraft.IN for refresh.");
	editor.browser.container.empty:Hide();
	if tsize(toolFrame.specificDraft.IN) == 0 then
		editor.browser.container.empty:Show();
	end
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

local LINE_ACTION_DELETE = 1;
local LINE_ACTION_ID = 2;
local LINE_ACTION_COPY = 3;
local LINE_ACTION_PASTE = 4;
local type, tremove = type, tremove;

---
-- Recursivity is bad, people.
-- Always use a stack when you have to parse large structures. :)
--
local function adaptIDs(oldID, newID, object)
	local stack = {object};
	while #stack ~= 0 do
		local current = tremove(stack);
		if type(current) == "table" then
			for index, value in pairs(current) do
				if type(value) == "table" then
					tinsert(stack, value);
				elseif type(value) == "string" then
					current[index] = value:gsub(oldID, newID);
				end
			end
		end
	end
end

local function onLineAction(action, line)
	assert(toolFrame.specificDraft.IN[line.objectID]);
	local id = line.objectID;
	local innerObject = toolFrame.specificDraft.IN[id];
	local _, name, _ = TRP3_API.extended.tools.getClassDataSafeByType(innerObject);
	local _, parentName, _ = TRP3_API.extended.tools.getClassDataSafeByType(toolFrame.specificDraft);

	if action == LINE_ACTION_DELETE then
		TRP3_API.popup.showConfirmPopup(loc.IN_INNER_DELETE_CONFIRM:format(id, name or UNKNOWN, parentName or UNKNOWN), function()
			local innerObject = toolFrame.specificDraft.IN[id];
			wipe(innerObject);
			toolFrame.specificDraft.IN[id] = nil;
			refresh();
		end);
	elseif action == LINE_ACTION_ID then
		TRP3_API.popup.showTextInputPopup(loc.IN_INNER_ID:format(name or UNKNOWN, id), function(newID)
			newID = TRP3_API.extended.checkID(newID);
			if toolFrame.specificDraft.IN[newID] then
				Utils.message.displayMessage(loc.IN_INNER_NO_AVAILABLE, 4);
			elseif newID and newID:len() > 0 then
				toolFrame.specificDraft.IN[newID] = toolFrame.specificDraft.IN[id];
				toolFrame.specificDraft.IN[id] = nil;
				refresh();
			end
		end, nil, id);
	elseif action == LINE_ACTION_COPY then
		wipe(editor.copy);
		Utils.table.copy(editor.copy, innerObject);
		editor.copy_fullClassID = toolFrame.fullClassID .. TRP3_API.extended.ID_SEPARATOR .. id;
	elseif action == LINE_ACTION_PASTE then
		if editor.copy and editor.copy.TY == innerObject.TY then
			TRP3_API.popup.showConfirmPopup(loc.IN_INNER_PASTE_CONFIRM, function()
				wipe(innerObject);
				Utils.table.copy(innerObject, editor.copy);
				adaptIDs(editor.copy_fullClassID, toolFrame.fullClassID .. TRP3_API.extended.ID_SEPARATOR .. id, innerObject);
				refresh();
			end);
		end
	end
end

local function onLineClicked(line, button)
	local id = line.objectID;
	local innerObject = toolFrame.specificDraft.IN[id];

	if button == "LeftButton" then
		TRP3_API.extended.tools.goToPage(getFullID(toolFrame.fullClassID, line.objectID));
	else
		local values = {};
		tinsert(values, {line.text:GetText(), nil});
		tinsert(values, {DELETE, LINE_ACTION_DELETE, loc.IN_INNER_DELETE_TT});
		tinsert(values, {loc.IN_INNER_ID_ACTION, LINE_ACTION_ID});
		tinsert(values, {loc.IN_INNER_COPY_ACTION, LINE_ACTION_COPY});
		if editor.copy.TY == innerObject.TY then
			tinsert(values, {loc.IN_INNER_PASTE_ACTION, LINE_ACTION_PASTE});
		end
		TRP3_API.ui.listbox.displayDropDown(line, values, onLineAction, 0, true);
	end
end

local function addInnerObject(type, self)
	assert(toolFrame.specificDraft.IN, "No toolFrame.specificDraft.IN for refresh.");
	-- Checking the parent mode to automatically adapt the mode for inner items
	local parentClass = getClass(toolFrame.fullClassID);
	local parentMode = (parentClass.MD and parentClass.MD.MO);
	local innerMode;
	TRP3_API.popup.showTextInputPopup(loc.IN_INNER_ENTER_ID .. "\n\n" .. loc.IN_INNER_ENTER_ID_TT, function(innerID)
		if not innerID or innerID:len() == 0 then
			return;
		elseif innerID:find(" ") then
			TRP3_API.popup.showAlertPopup(loc.IN_INNER_ENTER_ID_NO_SPACE);
		elseif self == editor.browser.add then
			if (parentMode == TRP3_DB.modes.EXPERT) then
				innerMode = TRP3_DB.modes.EXPERT;
			else
				innerMode = TRP3_DB.modes.NORMAL;
			end
			createInnerObject(innerID, type, innerMode);
			refresh();
		elseif self == editor.browser.addcopy then
			TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor, point = "CENTER", parentPoint = "CENTER"}, {function(id)
				local class = getClass(id);
				local sourceMode = (class.MD and class.MD.MO);
				-- We don't want to convert an expert item to a normal item during copy.
				if (parentMode == TRP3_DB.modes.EXPERT or sourceMode == TRP3_DB.modes.EXPERT) then
					innerMode = TRP3_DB.modes.EXPERT;
				else
					innerMode = TRP3_DB.modes.NORMAL;
				end
				local template = {};
				Utils.table.copy(template, class);
				TRP3_API.extended.tools.replaceID(template, id, toolFrame.fullClassID .. TRP3_API.extended.ID_SEPARATOR .. innerID);
				createInnerObject(innerID, type, innerMode, template);
				refresh();
			end, type});
		end
	end, nil, "");
end

local function onAddClicked(self)
	local values = {};
	tinsert(values, {"Select inner object type", nil});
	tinsert(values, {loc.TYPE_ITEM, TRP3_DB.types.ITEM});
	tinsert(values, {loc.TYPE_DOCUMENT, TRP3_DB.types.DOCUMENT});
	tinsert(values, {loc.TYPE_DIALOG, TRP3_DB.types.DIALOG});
	TRP3_API.ui.listbox.displayDropDown(self, values, addInnerObject, 0, true);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function editor.init(ToolFrame)
	toolFrame = ToolFrame;

	editor.copy = {};
	editor.browser.title:SetText(loc.IN_INNER_LIST);
	editor.help.title:SetText(loc.IN_INNER_HELP_TITLE);
	editor.help.text:SetText(loc.IN_INNER_HELP);
	editor.browser.add:SetText(loc.IN_INNER_ADD_NEW);
	editor.browser.addcopy:SetText(loc.IN_INNER_ADD_COPY);
	editor.browser.addText:SetText(loc.IN_INNER_ADD);
	editor.browser.container.empty:SetText(loc.IN_INNER_EMPTY);

	handleMouseWheel(editor.browser.container, editor.browser.container.slider);
	editor.browser.container.slider:SetValue(0);
	-- Create lines
	for line = 0, 8 do
		local lineFrame = CreateFrame("Button", "TRP3_InnerObjectEditorLine" .. line, editor.browser.container, "TRP3_InnerObjectEditorLine");
		lineFrame:SetPoint("TOP", editor.browser.container, "TOP", 0, -10 + (line * (-31)));
		lineFrame:SetScript("OnClick", onLineClicked);
		lineFrame:SetScript("OnEnter", onLineEnter);
		lineFrame:SetScript("OnLeave", onLineLeave);
		tinsert(editor.browser.container.lines, lineFrame);
	end

	editor.browser.add:SetScript("OnClick", onAddClicked);
	editor.browser.addcopy:SetScript("OnClick", onAddClicked);

end