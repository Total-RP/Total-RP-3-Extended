----------------------------------------------------------------------------------
--- Total RP 3: Extended
---
--- Items chat link module
---	------------------------------------------------------------------------------
---	Copyright 2018 Morgane "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
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

-- Total RP 3 imports
local iconToString = TRP3_API.utils.str.icon;
local loc = TRP3_API.loc;
local parseArgs = TRP3_API.script.parseArgs;

local Colors = Ellyb.ColorManager;
local USED_FOR_PROFESSIONS_COLOR = Ellyb.Color("66BBFF"):Freeze();

local ItemsChatLinksModule = TRP3_API.ChatLinks:InstantiateModule(loc.CL_EXTENDED_ITEM, "EXTENDED_DB_ITEM_LINK");


function ItemsChatLinksModule:GetLinkData(fullID, rootID, slotInfo, canBeImported)
	local itemData = TRP3_API.extended.getClass(fullID);

	local tooltipData = {
		class = tcopy(itemData),
		rootClass = tcopy(TRP3_API.extended.getClass(rootID)),
		fullID = fullID,
		rootID = rootID,
		slotInfo = slotInfo,
		canBeImported = canBeImported,
	};
	local _, itemName = TRP3_API.extended.getClassDataSafe(itemData);

	return itemName, tooltipData
end


function ItemsChatLinksModule:GetTooltipLines(tooltipData)
	local class = tooltipData.class;
	local args = {object = tooltipData.slotInfo};

	-- Get a new tooltipLines object that we will fill
	local tooltipLines = TRP3_API.ChatLinkTooltipLines();

	local icon, name, description = TRP3_API.extended.getClassDataSafe(class)

	-- Get the quality and quality color of the item
	local itemQuality = class.BA.QA or Enum.ItemQuality.Common;
	---@type Color
	local itemQualityColor = TRP3_API.inventory.getQualityColor(itemQuality);

	tooltipLines:SetTitle(iconToString(icon, 25) .. " " .. itemQualityColor:WrapTextInColorCode(name));

	-- Custom left and right texts
	if class.BA.LE or class.BA.RI then
		local left = class.BA.LE or "";
		local right = class.BA.RI or "";
		tooltipLines:AddDoubleLine(parseArgs(left, args), parseArgs(right, args), Colors.WHITE, Colors.WHITE)
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
		local slotUsed = TRP3_API.inventory.countUsedSlot(class, tooltipData.slotInfo);
		tooltipLines:AddLine(loc.IT_CON_TT:format(slotUsed, slotCount), Colors.WHITE);
	end

	-- Unique item
	if class.BA.UN and class.BA.UN > 0 then
		tooltipLines:AddLine(ITEM_UNIQUE .. " (" .. class.BA.UN .. ")", Colors.WHITE);
	end

	-- Description
	if description and description:len() > 0 then
		tooltipLines:AddLine(parseArgs(description, args), Colors.ORANGE)
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

local DatabaseItemsImportButton = ItemsChatLinksModule:NewActionButton("EXTENDED_IMPORT_DB_ITEM", loc.CL_IMPORT, "EXT_DB_I_Q", "EXT_DB_I_A");

function DatabaseItemsImportButton:IsVisible(data)
	return data.canBeImported;
end

function DatabaseItemsImportButton:OnAnswerCommandReceived(data, sender)
	local itemID = data.rootID;
	local fromClass = data.rootClass;
	local copiedData = tcopy(fromClass);

	copiedData.MD.SD = date("%d/%m/%y %H:%M:%S");
	copiedData.MD.SB = TRP3_API.globals.player_id;

	TRP3_DB.exchange[data.rootID] = copiedData;

	TRP3_API.security.computeSecurity(itemID, copiedData);
	TRP3_API.extended.unregisterObject(itemID);
	TRP3_API.extended.registerObject(itemID, copiedData, 0);
	TRP3_API.script.clearRootCompilation(itemID);
	TRP3_API.security.registerSender(itemID, sender);
	TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG);
	TRP3_API.events.fireEvent(TRP3_API.quest.EVENT_REFRESH_CAMPAIGN);
	TRP3_API.events.fireEvent(TRP3_API.events.ON_OBJECT_UPDATED);

	TRP3_API.extended.tools.showFrame();
	TRP3_API.extended.tools.goToPage(itemID);
end

local ImportItemInInventoryButton = ItemsChatLinksModule:NewActionButton("EXTENDED_IMPORT_BAG_ITEM", loc.CL_IMPORT_ITEM_BAG, "EXT_B_I_Q", "EXT_B_I_A");

function ImportItemInInventoryButton:IsVisible(data)
	-- Check if item was made to be importable, that it is an item, and that the option to prevent manual adding was not checked
	return data.canBeImported and data.class.TY == "IT" and not data.class.BA.PA;
end

function ImportItemInInventoryButton:OnAnswerCommandReceived(data, sender)
	local rootID = data.rootID;
	local fromClass = data.rootClass;
	local copiedData = tcopy(fromClass);
	copiedData.MD.SD = date("%d/%m/%y %H:%M:%S");
	copiedData.MD.SB = TRP3_API.globals.player_id;

	TRP3_DB.exchange[rootID] = copiedData;

	TRP3_API.security.computeSecurity(rootID, copiedData);
	TRP3_API.extended.unregisterObject(rootID);
	TRP3_API.extended.registerObject(rootID, copiedData, 0);
	TRP3_API.script.clearRootCompilation(rootID);
	TRP3_API.security.registerSender(rootID, sender);
	TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG);
	TRP3_API.events.fireEvent(TRP3_API.quest.EVENT_REFRESH_CAMPAIGN);
	TRP3_API.events.fireEvent(TRP3_API.events.ON_OBJECT_UPDATED);
	TRP3_API.inventory.addItem(nil, data.fullID, { count = 1, madeBy = copiedData.BA and copiedData.BA.CR });
end

TRP3_API.extended.ItemsChatLinksModule = ItemsChatLinksModule;