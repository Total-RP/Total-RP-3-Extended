----------------------------------------------------------------------------------
--- Total RP 3: Extended
---
--- Items chat link module
---	------------------------------------------------------------------------------
---	Copyright 2018 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---
---	Licensed under the Apache License, Version 2.0 (the "License");
---	you may not use this file except in compliance with the License.
---	You may obtain a copy of the License at
---
---		http://www.apache.org/licenses/LICENSE-2.0
---
---	Unless required by applicable law or agreed to in writing, software
---	distributed under the License is distributed on an "AS IS" BASIS,
---	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
---	See the License for the specific language governing permissions and
---	limitations under the License.
----------------------------------------------------------------------------------

---@type TRP3_API
local TRP3_API = TRP3_API;

---@type Ellyb
local Ellyb = TRP3_API.Ellyb;

-- Lua imports
local tcopy = Ellyb.Tables.copy;
local date = date;
local tContains = tContains;

-- Total RP 3 imports
local iconToString = TRP3_API.utils.str.icon;
local loc = TRP3_API.loc;

local Colors = Ellyb.ColorManager;
local USED_FOR_PROFESSIONS_COLOR = Ellyb.Color("66BBFF"):Freeze();

local ItemsChatLinkModule = TRP3_API.ChatLinks:InstantiateModule(loc.CL_CREATION, "EXTENDED_DB_ITEM_LINK");

local SUPPORTED_CREATION_TYPES = { "CA", "QU", "ST", "IT"}

function ItemsChatLinkModule:IsSupportedCreationType(creationType)
	return tContains(SUPPORTED_CREATION_TYPES, creationType);
end

-- TODO 3rd argument should be the slot info from the bag. The system would handle having no slot info as an item coming from the DB
function ItemsChatLinkModule:GetLinkData(fullID, rootID, canBeImported)
	local itemData = TRP3_API.extended.getClass(fullID);
	local tooltipData = {
		class = {}
	};
	local _, itemName = TRP3_API.extended.getClassDataSafe(itemData);

	tcopy(tooltipData.class, itemData);
	tooltipData.fullID = fullID;
	tooltipData.rootID = rootID;
	tooltipData.canBeImported = canBeImported;

	return itemName, tooltipData
end

-- TODO When we get slot info, use those info the parse the variables inside the fields
function ItemsChatLinkModule:GetTooltipLines(tooltipData)
	local class = tooltipData.class;

	-- Get a new tooltipLines object that we will fill
	local tooltipLines = TRP3_API.ChatLinkTooltipLines();

	local icon, name, description = TRP3_API.extended.getClassDataSafe(class)

	-- Get the quality and quality color of the tiem
	local itemQuality = class.BA.QA or LE_ITEM_QUALITY_COMMON;
	---@type Color
	local itemQualityColor = TRP3_API.inventory.getQualityColor(itemQuality);

	tooltipLines:SetTitle(iconToString(icon) .. " " .. itemQualityColor:WrapTextInColorCode(name));

	local creationType = TRP3_API.extended.tools.getTypeLocale(class.TY);

	tooltipLines:AddDoubleLine(" ", creationType, nil, Colors.YELLOW);

	-- Custom left and right texts
	if class.BA.LE or class.BA.RI then
		local left = class.BA.LE or "";
		local right = class.BA.RI or "";
		tooltipLines:AddDoubleLine(left, right, Colors.WHITE, Colors.WHITE)
	end

	-- Flagged as quest item
	if class.BA.QE then
		tooltipLines:AddLine(ITEM_BIND_QUEST, Colors.WHITE)
	end

	-- Flagged as soulbound
	if class.BA.SB then
		tooltipLines:AddLine(ITEM_SOULBOUND, Colors.WHITE);
	end

	-- Specific to containers
	if TRP3_API.inventory.isContainerByClass(class) then
		local slotCount = (class.CO.SR or 5) * (class.CO.SC or 4);
		tooltipLines:AddLine(loc("IT_CON_TT"):format(0, slotCount), Colors.WHITE);
	end

	-- Unique item
	if class.BA.UN and class.BA.UN > 0 then
		tooltipLines:AddLine(ITEM_UNIQUE .. " (" .. class.BA.UN .. ")", Colors.WHITE);
	end

	-- Description
	if description and description:len() > 0 then
		tooltipLines:AddLine(description, Colors.ORANGE)
	end

	-- On use effect
	if class.US and class.US.AC then
		tooltipLines:AddLine(USE .. ": " .. class.US.AC, Colors.GREEN);
	end

	-- Used for profession flag
	if class.BA.CO then
		tooltipLines:AddLine(PROFESSIONS_USED_IN_COOKING, USED_FOR_PROFESSIONS_COLOR);
	end

	return tooltipLines;
end

local ImportItemInDatabaseButton = ItemsChatLinkModule:NewActionButton("EXTENDED_IMPORT_DB_ITEM", loc.CL_IMPORT_CREATION_DB, "EXT_DB_I_Q", "EXT_DB_I_A");

function ImportItemInDatabaseButton:IsVisible(data)
	return data.canBeImported and data.rootID and TRP3_DB.global[data.rootID] == nil;
end

function ImportItemInDatabaseButton:OnAnswerCommandReceived(data, sender)
	local itemID = data.rootID;
	local fromClass = data.class;
	local copiedData = {};
	TRP3_API.utils.table.copy(copiedData, fromClass);

	copiedData.MD.SD = date("%d/%m/%y %H:%M:%S");
	copiedData.MD.SB = TRP3_API.globals.player_id;
	TRP3_API.extended.tools.createItem(copiedData, itemID);

	TRP3_API.extended.tools.showFrame();
	TRP3_API.extended.tools.goToPage(itemID);
end

local UpdateItemInDatabaseButton = ItemsChatLinkModule:NewActionButton("EXTENDED_UPDATE_DB_ITEM", loc.CL_UPDATE_CREATION, "EXT_DB_U_Q", "EXT_DB_U_A");

function UpdateItemInDatabaseButton:IsVisible(data)
	return data.canBeImported and data.rootID and TRP3_DB.global[data.rootID] ~= nil;
end

function UpdateItemInDatabaseButton:OnAnswerCommandReceived(data, sender)
	local itemID = data.rootID;
	local fromClass = data.class;
	local copiedData = {};
	TRP3_API.utils.table.copy(copiedData, fromClass);

	copiedData.MD.SD = date("%d/%m/%y %H:%M:%S");
	copiedData.MD.SB = TRP3_API.globals.player_id;

	TRP3_DB.global[data.rootID] = copiedData;

	TRP3_API.extended.tools.showFrame();
	TRP3_API.extended.tools.goToPage(itemID);
end

local ImportItemInInventoryButton = ItemsChatLinkModule:NewActionButton("EXTENDED_IMPORT_BAG_ITEM", loc.CL_IMPORT_ITEM_BAG, "EXT_B_I_Q", "EXT_B_I_A");

function ImportItemInInventoryButton:IsVisible(data)
	-- Check if item was made to be importable, that it is an item, and that the option to prevent manual adding was not checked
	return data.canBeImported and data.class.TY == "IT" and not data.class.BA.PA;
end

function ImportItemInInventoryButton:OnAnswerCommandReceived(data, sender)
	local rootID, item = data.rootID;
	local fromClass = data.class;
	local copiedData = {};
	TRP3_API.utils.table.copy(copiedData, fromClass);
	copiedData.MD.SD = date("%d/%m/%y %H:%M:%S");
	copiedData.MD.SB = TRP3_API.globals.player_id;

	-- If the root item didn't exist before we create it
	if not TRP3_DB.global[rootID] then
		rootID, item = TRP3_API.extended.tools.createItem(copiedData, rootID);
	else
		-- If it existed we update it
		TRP3_DB.global[rootID] = copiedData;
		item = TRP3_DB.global[rootID];
	end
	TRP3_API.inventory.addItem(nil, data.fullID, { count = 1, madeBy = item.BA and item.BA.CR });
end

TRP3_API.extended.ItemsChatLinkModule = ItemsChatLinkModule;