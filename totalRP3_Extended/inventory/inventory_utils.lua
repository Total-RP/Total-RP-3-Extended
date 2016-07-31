----------------------------------------------------------------------------------
-- Total RP 3
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
local pairs = pairs;
local EMPTY = TRP3_API.globals.empty;
local getClass = TRP3_API.extended.getClass;
local loc = TRP3_API.locale.getText;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UTILS func
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function isContainerByClass(item)
	return item and item.BA and item.BA.CT;
end
TRP3_API.inventory.isContainerByClass = isContainerByClass;

local function isContainerByClassID(itemID)
	return itemID == "main" or isContainerByClass(getClass(itemID));
end
TRP3_API.inventory.isContainerByClassID = isContainerByClassID;

local function isUsableByClass(item)
	return item and item.BA and item.BA.US;
end
TRP3_API.inventory.isUsableByClass = isUsableByClass;

local function isUsableByClassID(itemID)
	return isUsableByClass(getClass(itemID));
end
TRP3_API.inventory.isUsableByClassID = isUsableByClassID;


local function getBaseClassDataSafe(itemClass)
	local icon = "TEMP";
	local name = UNKNOWN;
	local qa = 1;
	if itemClass and itemClass.BA then
		if itemClass.BA.IC then
			icon = itemClass.BA.IC;
		end
		if itemClass.BA.NA then
			name = itemClass.BA.NA;
		end
		if itemClass.BA.QA then
			qa = itemClass.BA.QA;
		end
	end
	return icon, name, qa;
end
TRP3_API.inventory.getBaseClassDataSafe = getBaseClassDataSafe;

local function checkContainerInstance(container)
	if not container.content then
		container.content = {};
	end
end
TRP3_API.inventory.checkContainerInstance = checkContainerInstance;

function TRP3_API.inventory.getItemTextLine(itemClass)
	local icon, name = getBaseClassDataSafe(itemClass);
	return Utils.str.icon(icon, 25) .. " " .. name;
end

local neutral = {r = 0.95, g = 0.95, b = 0.95};
local colorCodeFloatTab = Utils.color.colorCodeFloatTab;
local itemColor = BAG_ITEM_QUALITY_COLORS;

local function getQualityColorTab(quality)
	-- Thanks again Blizz...
	if quality == LE_ITEM_QUALITY_COMMON then
		return neutral;
	elseif quality == LE_ITEM_QUALITY_POOR then
		return itemColor[LE_ITEM_QUALITY_COMMON];
	end
	return itemColor[quality or 0] or neutral;
end
TRP3_API.inventory.getQualityColorTab = getQualityColorTab;

local function getQualityColorText(quality)
	return colorCodeFloatTab(getQualityColorTab(quality));
end
TRP3_API.inventory.getQualityColorText = getQualityColorText;

local function getQualityColorRGB(quality)
	local tab = getQualityColorTab(quality);
	return tab.r, tab.g, tab.b;
end
TRP3_API.inventory.getQualityColorRGB = getQualityColorRGB;

local function getItemLink(itemClass, id)
	if itemClass.TY == TRP3_DB.types.DOCUMENT or itemClass.TY == TRP3_DB.types.QUEST_STEP or itemClass.TY == TRP3_DB.types.DIALOG then
		return "|cffffffff[" .. (id or "???") .. "]|r";
	else
		local _, name, qa = getBaseClassDataSafe(itemClass);
		return getQualityColorText(qa) .. "[" .. name .. "]|r";
	end
end
TRP3_API.inventory.getItemLink = getItemLink;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CONTAINER func
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function isItemInContainer(item, container)
	if not container or not container.content or not isContainerByClassID(container.id) then
		return false;
	end
	if item == container then -- Check by ref
		return true;
	end

	local contains = false;
	for _, slot in pairs(container.content) do
		contains = isItemInContainer(item, slot);
	end
	return contains;
end
TRP3_API.inventory.isItemInContainer = isItemInContainer;

local function countItemInstances(container, itemID)
	local count = 0;

	for _, slot in pairs(container.content or EMPTY) do
		if slot.id == itemID then
			count = count + (slot.count or 1);
		end
		if isContainerByClassID(slot.id) then
			count = count + countItemInstances(slot, itemID);
		end
	end

	return count;
end
TRP3_API.inventory.countItemInstances = countItemInstances;

local function searchForFirstInstance(container, itemID)
	for slotIndex, slot in pairs(container.content or EMPTY) do
		if slot.id == itemID then
			return container, slotIndex;
		end
	end
	for _, slot in pairs(container.content or EMPTY) do
		if isContainerByClassID(slot.id) then
			return searchForFirstInstance(slot, itemID);
		end
	end
end
TRP3_API.inventory.searchForFirstInstance = searchForFirstInstance;

local function countUsedSlot(containerClass, container)
	local slotCount = (containerClass.CO.SR or 5) * (containerClass.CO.SC or 4);
	local total = 0;
	for i=1, slotCount do
		local index = tostring(i);
		if (container.content or EMPTY)[index] then
			total = total + 1;
		end
	end
	return total;
end
TRP3_API.inventory.countUsedSlot = countUsedSlot;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Units
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

--- Get a formated text for this weight based on config
-- @param value in grams !
--
function TRP3_API.extended.formatWeight(value)
	local config = TRP3_API.configuration.getValue(TRP3_API.extended.CONFIG_WEIGHT_UNIT);
	if config == TRP3_API.extended.WEIGHT_UNITS.GRAMS then
		if value < 1000 then
			return ("%s g"):format(value);
		else
			return ("%0.2f kg"):format(value / 1000);
		end
	elseif config == TRP3_API.extended.WEIGHT_UNITS.POUNDS then
		value = value * 0.00220462;
		if value < 1 then
			return ("%0.2f oz"):format(value * 16);
		else
			return ("%0.2f lb"):format(value);
		end
	elseif config == TRP3_API.extended.WEIGHT_UNITS.POTATOES then
		value = value / 160; -- Average potatoe weight. :3
		if value < 1 then
			return ("%0.2f %s"):format(value * 24, loc("UNIT_FRIES")); -- Average fries quantity we can made out of one potatoe. :3
		else
			return ("%0.2f %s"):format(value, loc("UNIT_POTATOES"));
		end
	end
end