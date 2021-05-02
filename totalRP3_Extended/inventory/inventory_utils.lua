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
local pairs, strsplit = pairs, strsplit;
local EMPTY = TRP3_API.globals.empty;
local getClass = TRP3_API.extended.getClass;
local loc = TRP3_API.loc;

-- Ellyb imports
local Ellyb = TRP3_API.Ellyb;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Tooltip func
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.getTTAction(method, action, notFirst)
	local text = "|cffffff00" .. method .. ":|r |cffff9900" .. action .. "|r";
	if notFirst then
		text = "\n" .. text;
	end
	return text;
end

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

local colorCodeFloatTab = Utils.color.colorCodeFloatTab;

local ITEM_COLORS = {
	[Enum.ItemQuality.Poor] = Ellyb.ColorManager.ITEM_POOR,
	[Enum.ItemQuality.Common] = Ellyb.ColorManager.ITEM_COMMON,
	[Enum.ItemQuality.Uncommon] = Ellyb.ColorManager.ITEM_UNCOMMON,
	[Enum.ItemQuality.Rare] = Ellyb.ColorManager.ITEM_RARE,
	[Enum.ItemQuality.Epic] = Ellyb.ColorManager.ITEM_EPIC,
	[Enum.ItemQuality.Legendary] = Ellyb.ColorManager.ITEM_LEGENDARY,
	[Enum.ItemQuality.Artifact] = Ellyb.ColorManager.ITEM_ARTIFACT,
	[Enum.ItemQuality.Heirloom] = Ellyb.ColorManager.ITEM_HEIRLOOM,
	[Enum.ItemQuality.WoWToken] = Ellyb.ColorManager.ITEM_WOW_TOKEN,
}
local NEUTRAL_COLOR = ITEM_COLORS[Enum.ItemQuality.Common];

local function getQualityColorTab(quality)
	---@type Color
	local color = ITEM_COLORS[quality] or NEUTRAL_COLOR;
	return color:GetRGBATable();
end
TRP3_API.inventory.getQualityColorTab = getQualityColorTab;

---@return Color
function TRP3_API.inventory.getQualityColor(quality)
	return ITEM_COLORS[quality] or NEUTRAL_COLOR
end

local function getQualityColorText(quality)
	return colorCodeFloatTab(getQualityColorTab(quality));
end
TRP3_API.inventory.getQualityColorText = getQualityColorText;

local function getQualityColorRGB(quality)
	local tab = getQualityColorTab(quality);
	return tab.r, tab.g, tab.b;
end
TRP3_API.inventory.getQualityColorRGB = getQualityColorRGB;

local function getItemLink(itemClass, id, complete)
	local ids = {strsplit(TRP3_API.extended.ID_SEPARATOR, id or "???")};
	local name, color;
	if itemClass.TY == TRP3_DB.types.DOCUMENT or itemClass.TY == TRP3_DB.types.QUEST_STEP or itemClass.TY == TRP3_DB.types.DIALOG then
		color = "|cffffffff";
		name = ids[#ids];
	else
		local _, n, qa = getBaseClassDataSafe(itemClass);
		color = getQualityColorText(qa);
		name = n;
	end

	if #ids == 1 or not complete then
		return color .. "[" .. name .. "]|r";
	else
		local totalLink = getItemLink(getClass(ids[1]), ids[1]);
		local idReconstruct = ids[1];
		for i=2, #ids do
			idReconstruct = idReconstruct .. TRP3_API.extended.ID_SEPARATOR .. ids[i];
			totalLink = totalLink .. "|cff00ff00 > " .. getItemLink(getClass(idReconstruct), idReconstruct);
		end
		return totalLink;
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
		if itemID:len() == 0 or slot.id == itemID then
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
	local foundContainer, foundIndex;

	for slotIndex, slot in pairs(container.content or EMPTY) do
		if slot.id == itemID then
			foundContainer, foundIndex = container, slotIndex;
		elseif isContainerByClassID(slot.id) then
			foundContainer, foundIndex = searchForFirstInstance(slot, itemID);
		end

		if foundIndex then
			break;
		end
	end

	return foundContainer, foundIndex;
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
			return ("%0.2f %s"):format(value * 24, loc.UNIT_FRIES); -- Average fries quantity we can made out of one potatoe. :3
		else
			return ("%0.2f %s"):format(value, loc.UNIT_POTATOES);
		end
	end
end