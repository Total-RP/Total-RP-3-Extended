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
local tcopy = TRP3_API.utils.table.copy;
local date = date;

-- Total RP 3 imports
local iconToString = TRP3_API.utils.str.icon;
local loc = TRP3_API.loc;

local Colors = Ellyb.ColorManager;
local USED_FOR_PROFESSIONS_COLOR = Ellyb.Color("66BBFF"):Freeze();

local ItemsChatLinkModule = TRP3_API.ChatLinks.InstantiateModule("Extended Item", "EXTENDED_DB_ITEM_LINK");

-- TODO 3rd argument should be the slot info from the bag. The system would handle having no slot info as an item coming from the DB
function ItemsChatLinkModule:GetLinkData(fullID, rootID, canBeImported)
	local itemData = TRP3_API.extended.getClass(fullID);
	local tooltipData = {};
	local _, itemName = TRP3_API.extended.getClassDataSafe(itemData);

	tcopy(tooltipData, itemData);
	tooltipData.fullID = fullID;
	tooltipData.rootID = rootID;
	tooltipData.canBeImported = canBeImported;

	return itemName, tooltipData
end

-- TODO When we get slot info, use those info the parse the variables inside the fields
function ItemsChatLinkModule:GetTooltipLines(class)

	-- Get a new tooltipLines object that we will fill
	local tooltipLines = TRP3_API.ChatLinkTooltipLines();

	local icon, name, description = TRP3_API.extended.getClassDataSafe(class)

	-- Get the quality and quality color of the tiem
	local itemQuality = class.BA.QA or LE_ITEM_QUALITY_COMMON;
	---@type Color
	local itemQualityColor = TRP3_API.inventory.getQualityColor(itemQuality);

	tooltipLines:SetTitle(iconToString(icon) .. " " .. itemQualityColor:WrapTextInColorCode(name));

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
	if class.BA.DE and class.BA.DE:len() > 0 then
		tooltipLines:AddLine(class.BA.DE, Colors.ORANGE)
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

function ItemsChatLinkModule:GetCustomData(tooltipData)
	return {
		fullID = tooltipData.fullID,
		rootID = tooltipData.rootID,
	}
end

local ImportItemInDatabaseButton = ItemsChatLinkModule:NewActionButton("EXTENDED_IMPORT_DB_ITEM", "Import in database");
local LINK_COMMAND_IMPORT_DB_ITEM_Q = "EXT_DB_I_Q";
local LINK_COMMAND_IMPORT_DB_ITEM_A = "EXT_DB_I_A";

function ImportItemInDatabaseButton:OnClick(IDs, sender)
	TRP3_API.communication.sendObject(LINK_COMMAND_IMPORT_DB_ITEM_Q, IDs.rootID, sender);
end

TRP3_API.communication.registerProtocolPrefix(LINK_COMMAND_IMPORT_DB_ITEM_Q, function(rootID, sender)
	TRP3_API.communication.sendObject(LINK_COMMAND_IMPORT_DB_ITEM_A, {
		rootID = rootID,
		class = TRP3_API.extended.getClass(rootID),
	})
end);

TRP3_API.communication.registerProtocolPrefix(LINK_COMMAND_IMPORT_DB_ITEM_A, function(data, sender)
	local fromClass = data.class;
	local copiedData = {};
	local id = data.rootID;
	TRP3_API.utils.table.copy(copiedData, fromClass);
	copiedData.MD.SD = date("%d/%m/%y %H:%M:%S");
	copiedData.MD.SB = TRP3_API.globals.player_id;

	local ID, _ = TRP3_API.extended.tools.createItem(copiedData, id);
	TRP3_API.extended.tools.goToPage(ID);
end);

-- TODO Create import in bag button. Will additionaly insert a copy of the item into the main container.

TRP3_API.extended.ItemsChatLinkModule = ItemsChatLinkModule;