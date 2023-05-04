-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

---@type TRP3_API
local TRP3_API = TRP3_API;

-- Lua imports
local date = date;

-- Total RP 3 imports
local iconToString = TRP3_API.utils.str.icon;
local loc = TRP3_API.loc;
local parseArgs = TRP3_API.script.parseArgs;

local USED_FOR_PROFESSIONS_COLOR = TRP3_API.CreateColorFromHexString("66BBFF");

local ItemsChatLinksModule = TRP3_API.ChatLinks:InstantiateModule(loc.CL_EXTENDED_ITEM, "EXTENDED_DB_ITEM_LINK");


function ItemsChatLinksModule:GetLinkData(fullID, rootID, slotInfo, canBeImported)
	local itemData = TRP3_API.extended.getClass(fullID);

	local tooltipData = {
		class = CopyTable(itemData),
		rootClass = CopyTable(TRP3_API.extended.getClass(rootID)),
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
		tooltipLines:AddDoubleLine(parseArgs(left, args), parseArgs(right, args), TRP3_API.Colors.White, TRP3_API.Colors.White)
	end

	-- Flagged as quest item
	if class.BA.QE then
		tooltipLines:AddLine(ITEM_BIND_QUEST, TRP3_API.Colors.White)
	end

	-- Flagged as soulbound
	if class.BA.SB then
		tooltipLines:AddLine(ITEM_SOULBOUND, TRP3_API.Colors.White);
	end

	-- Specific to containers
	if TRP3_API.inventory.isContainerByClass(class) then
		local slotCount = (class.CO.SR or 5) * (class.CO.SC or 4);
		local slotUsed = TRP3_API.inventory.countUsedSlot(class, tooltipData.slotInfo);
		tooltipLines:AddLine(loc.IT_CON_TT:format(slotUsed, slotCount), TRP3_API.Colors.White);
	end

	-- Unique item
	if class.BA.UN and class.BA.UN > 0 then
		local uniqueText = ITEM_UNIQUE;
		if class.BA.UN > 1 then
			uniqueText = uniqueText .. " (" .. class.BA.UN .. ")";
		end
		tooltipLines:AddLine(uniqueText, TRP3_API.Colors.White);
	end

	-- Description
	if description and description:len() > 0 then
		tooltipLines:AddLine("\"" .. parseArgs(description, args) .. "\"", TRP3_API.Colors.Yellow)
	end

	-- On use effect
	if class.US and class.US.AC then
		tooltipLines:AddLine(USE .. ": " .. class.US.AC, TRP3_API.Colors.Green);
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
	local copiedData = CopyTable(fromClass);

	copiedData.MD.SD = date("%d/%m/%y %H:%M:%S");
	copiedData.MD.SB = TRP3_API.globals.player_id;

	TRP3_DB.exchange[data.rootID] = copiedData;

	TRP3_API.security.computeSecurity(itemID, copiedData);
	TRP3_API.extended.unregisterObject(itemID);
	TRP3_API.extended.registerObject(itemID, copiedData, 0);
	TRP3_API.script.clearRootCompilation(itemID);
	TRP3_API.security.registerSender(itemID, sender);
	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.REFRESH_BAG);
	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.REFRESH_CAMPAIGN);
	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.ON_OBJECT_UPDATED);

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
	local copiedData = CopyTable(fromClass);
	copiedData.MD.SD = date("%d/%m/%y %H:%M:%S");
	copiedData.MD.SB = TRP3_API.globals.player_id;

	TRP3_DB.exchange[rootID] = copiedData;

	TRP3_API.security.computeSecurity(rootID, copiedData);
	TRP3_API.extended.unregisterObject(rootID);
	TRP3_API.extended.registerObject(rootID, copiedData, 0);
	TRP3_API.script.clearRootCompilation(rootID);
	TRP3_API.security.registerSender(rootID, sender);
	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.REFRESH_BAG);
	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.REFRESH_CAMPAIGN);
	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.ON_OBJECT_UPDATED);
	TRP3_API.inventory.addItem(nil, data.fullID, { count = 1, madeBy = copiedData.BA and copiedData.BA.CR });
end

TRP3_API.extended.ItemsChatLinksModule = ItemsChatLinksModule;
