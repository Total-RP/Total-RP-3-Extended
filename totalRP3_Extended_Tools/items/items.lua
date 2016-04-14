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
local wipe, tostring, error, assert, date = wipe, tostring, error, assert, date;
local tsize = Utils.table.size;
local getClass, classExists = TRP3_API.extended.getClass, TRP3_API.extended.classExists;
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

function TRP3_API.extended.tools.getContainerItemData()
	local data = TRP3_API.extended.tools.getBlankItemData(TRP3_DB.modes.NORMAL);
	data.BA.CT = true;
	data.BA.NA = loc("IT_NEW_NAME_CO");
	data.BA.IC = "inv_misc_bag_36";
	data.CO = {SR = 5, SC = 4};
	return data;
end


function TRP3_API.extended.tools.getDocumentItemData()
	local data = TRP3_API.extended.tools.getBlankItemData(TRP3_DB.modes.NORMAL);
	data.BA.IC = "inv_misc_book_16";
	data.BA.NA = loc("DO_NEW_DOC");
	data.IN = {
		doc = {
			TY = TRP3_DB.types.DOCUMENT,
			MD = {
				MO = TRP3_DB.modes.NORMAL,
			},
			BA = {
				NA = loc("DO_NEW_DOC"),
			},
		}
	};
	return data;
end

function TRP3_API.extended.tools.createInnerObject(parentID, innerID, innerType, innerData)
	assert(classExists(parentID), "Unknown parent ID: " .. tostring(parentID));
	local parentClass = getClass(parentID);
	if not parentClass.IN then
		parentClass.IN = {};
	end
	if not parentClass.IN[innerID] then
		if innerType == TRP3_DB.types.ITEM then
			parentClass.IN[innerID] = innerData or {
				TY = TRP3_DB.types.ITEM,
				MD = {
					MO = TRP3_DB.modes.NORMAL,
				},
				BA = {
					NA = loc("IT_NEW_NAME"),
				},
			}
		elseif innerType == TRP3_DB.types.DOCUMENT then
			parentClass.IN[innerID] = innerData or {
				TY = TRP3_DB.types.DOCUMENT,
				MD = {
					MO = TRP3_DB.modes.NORMAL,
				},
				BA = {
					NA = loc("DO_NEW_DOC"),
				},
			}
		elseif innerType == "quick" then
			parentClass.IN[innerID] = innerData;
		end
		registerItem(parentID, parentClass);
		return TRP3_API.extended.getFullID(parentID, innerID);
	end
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