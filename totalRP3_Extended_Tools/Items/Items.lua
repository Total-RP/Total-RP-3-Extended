-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local Globals, Utils = TRP3_API.globals, TRP3_API.utils;
local tinsert, error, assert, date = tinsert, error, assert, date;
local loc = TRP3_API.loc;
local toolFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function registerItem(ID, data)
	TRP3_API.extended.registerObject(ID, data, 0);
end

local function createItem(data, ID)
	ID = ID or Utils.str.id();

	if TRP3_DB.global[ID] then
		error("This ID already exists. This shoudn't happen: " .. ID);
	end

	TRP3_DB.my[ID] = data;
	TRP3_API.security.computeSecurity(ID, data);
	registerItem(ID, data);

	return ID, data;
end
TRP3_API.extended.tools.createItem = createItem;

function TRP3_API.extended.tools.getBlankItemData(toMode)
	return {
		TY = TRP3_DB.types.ITEM,
		MD = {
			MO = toMode or TRP3_DB.modes.QUICK,
			V = 1,
			CD = date("%d/%m/%y %H:%M:%S");
			CB = Globals.player_id,
			SD = date("%d/%m/%y %H:%M:%S");
			SB = Globals.player_id,
		},
		BA = {
			NA = loc.IT_NEW_NAME,
		},
	};
end

function TRP3_API.extended.tools.getContainerItemData()
	local data = TRP3_API.extended.tools.getBlankItemData(TRP3_DB.modes.NORMAL);
	data.BA.CT = true;
	data.BA.NA = loc.IT_NEW_NAME_CO;
	data.BA.IC = "inv_misc_bag_36";
	data.CO = {SR = 5, SC = 4};
	return data;
end

local function validator(classID, class, warnings)
	if class.BA.ST and class.BA.ST > 1 and class.BA.CR then
		tinsert(warnings, loc.IT_WARNING_1:format(classID));
	end
	if class.BA.ST and class.BA.ST > 1 and class.BA.CT then
		tinsert(warnings, loc.IT_WARNING_2:format(classID));
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item base frame
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onLoad()
	assert(toolFrame.rootClassID, "rootClassID is nil");
	assert(toolFrame.fullClassID, "fullClassID is nil");
	assert(toolFrame.rootDraft, "rootDraft is nil");
	assert(toolFrame.specificDraft, "specificDraft is nil");

	toolFrame.item.normal:Hide();
	toolFrame.item.normal:Show();
	toolFrame.item.normal.loadItem();
end

local function onSave()
	assert(toolFrame.specificDraft, "specificDraft is nil");
	toolFrame.item.normal.saveToDraft();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initItems(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.item.onLoad = onLoad;
	toolFrame.item.onSave = onSave;
	toolFrame.item.validator = validator;

	TRP3_API.extended.tools.initItemQuickEditor(toolFrame);
	TRP3_API.extended.tools.initItemEditorNormal(toolFrame);
end
