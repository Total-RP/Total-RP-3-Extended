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
local wipe, pairs, error, assert, date = wipe, pairs, error, assert, date;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local loc = TRP3_API.locale.getText;
local toolFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function registerItem(ID, data)
	TRP3_API.extended.registerObject(ID, data, 0);
end

local function createItem(data)
	local ID = Utils.str.id();

	if TRP3_DB.global[ID] then
		error("This ID already exists. This shoudn't happen: " .. ID);
	end

	TRP3_DB.my[ID] = data;
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
			NA = loc("IT_NEW_NAME"),
		},
	};
end

function TRP3_API.extended.tools.getContainerItemData(toMode)
	local data = TRP3_API.extended.tools.getBlankItemData(toMode);
	data.BA.CT = true;
	data.BA.IC = "inv_misc_bag_01";
	return data;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item base frame
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onLoad()
	assert(toolFrame.rootClassID, "rootClassID is nil");
	assert(toolFrame.specificClassID, "specificClassID is nil");
	assert(toolFrame.rootDraft, "rootDraft is nil");
	assert(toolFrame.specificDraft, "specificDraft is nil");

	toolFrame.item.normal:Hide();
	if TRP3_DB.modes.EXPERT ~= (toolFrame.specificDraft.MO or TRP3_DB.modes.NORMAL) then
		toolFrame.item.normal:Show();
		toolFrame.item.normal.loadItem();
	end
end

local function onSave()
	assert(toolFrame.specificDraft, "specificDraft is nil");
	if TRP3_DB.modes.EXPERT ~= (toolFrame.specificDraft.MO or TRP3_DB.modes.NORMAL) then
		toolFrame.item.normal.saveToDraft();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initItems(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.item.onLoad = onLoad;
	toolFrame.item.onSave = onSave;

	TRP3_API.extended.tools.initItemQuickEditor(toolFrame);
	TRP3_API.extended.tools.initItemFrames(toolFrame);
	TRP3_API.extended.tools.initItemEditorNormal(toolFrame);
end