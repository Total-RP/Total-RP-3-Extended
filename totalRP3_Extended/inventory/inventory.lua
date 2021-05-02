----------------------------------------------------------------------------------
-- Total RP 3: Inventory system
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
local _G, assert, tostring, tinsert, wipe, pairs, type, time = _G, assert, tostring, tinsert, wipe, pairs, type, time;
local getClass, isContainerByClassID, isUsableByClass = TRP3_API.extended.getClass, TRP3_API.inventory.isContainerByClassID, TRP3_API.inventory.isUsableByClass;
local isContainerByClass, getItemTextLine = TRP3_API.inventory.isContainerByClass, TRP3_API.inventory.getItemTextLine;
local checkContainerInstance, countItemInstances = TRP3_API.inventory.checkContainerInstance, TRP3_API.inventory.countItemInstances;
local getItemLink = TRP3_API.inventory.getItemLink;
local loc = TRP3_API.loc;
local EMPTY = TRP3_API.globals.empty;
local tcopy = Utils.table.copy;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INVENTORY MANAGEMENT API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local playerInventory;
local CONTAINER_SLOT_MAX = 20;
TRP3_API.inventory.CONTAINER_SLOT_MAX = CONTAINER_SLOT_MAX;
local QUICK_SLOT_ID = "17";
TRP3_API.inventory.QUICK_SLOT_ID = QUICK_SLOT_ID;

local function onItemAddEnd(container, itemClass, returnType, count, ...)
	if count ~= 0 then
		Utils.message.displayMessage(loc.IT_INV_GOT:format(getItemLink(itemClass), count));
		TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG, container);
		TRP3_API.inventory.recomputeAllInventory();
	end
	return returnType, count, ...;
end

local function getItemCount(classID, container)
	if container and isContainerByClassID(container.id) then
		return countItemInstances(container, classID);
	else
		return countItemInstances(playerInventory, classID);
	end
end
TRP3_API.inventory.getItemCount = getItemCount;

local function getContainerWeight(container)
	return (container or playerInventory).totalWeight;
end
TRP3_API.inventory.getContainerWeight = getContainerWeight;

local function copySlotContent(slot, itemClass, itemData)
	if itemClass.CO and itemClass.CO.IT then
		slot.content = {};
		Utils.table.copy(slot.content, itemClass.CO.IT);
	end
	slot.cooldown = itemData.cooldown;
	if itemData.madeBy then
		if type(itemData.madeBy) == "string" then
			slot.madeBy = itemData.madeBy;
		else
			slot.madeBy = Globals.player_id;
		end
	end
	if itemData.vars then
		if not slot.vars then
			slot.vars = {};
		end
		tcopy(slot.vars, itemData.vars);
	end
	if itemData.content then
		if not slot.content then
			slot.content = {};
		end
		tcopy(slot.content, itemData.content);
	end
end

local function dropMeBecauseIMFull(itemClass, itemData, toAdd, classID)
	local dropSlot = {
		count = toAdd or 1,
		id = classID,
	};
	copySlotContent(dropSlot, itemClass, itemData);
	TRP3_API.inventory.dropItemDirect(dropSlot);
end

--- Add an item to a container.
-- Returns:
-- 0 if OK
-- 1 if container full
-- 2 if too many item already possessed (unique)
-- 3 if givenContainer is not a container
-- 4 if container can't contain the item
function TRP3_API.inventory.addItem(givenContainer, classID, itemData, dropIfFull, toSlot)
	-- Get the best container
	local container = givenContainer or playerInventory;
	if givenContainer == nil then
		local quickSlot = playerInventory.content[QUICK_SLOT_ID];
		if quickSlot and quickSlot.id and TRP3_API.inventory.isContainerByClassID(quickSlot.id) then
			container = quickSlot;
		end
	end

	-- Check data
	if not isContainerByClassID(container.id) then
		return 3;
	end
	local containerClass = getClass(container.id);
	local itemClass = getClass(classID);

	if containerClass.CO.OI and not TRP3_API.extended.objectsAreRelated(container.id, classID) then
		Utils.message.displayMessage(loc.IT_CON_CAN_INNER, Utils.message.type.ALERT_MESSAGE);
		return 4;
	end

	checkContainerInstance(container);
	itemData = itemData or EMPTY;

	local slot;
	local ret;
	local toAdd = itemData.count or 1;
	local canStack = (itemClass.BA.ST or 0) > 0;

	for count = 0, toAdd - 1 do
		local freeSlot, stackSlot;

		-- Check unicity
		if itemClass.BA.UN then
			local currentCount = getItemCount(classID);
			if currentCount + 1 > itemClass.BA.UN then
				Utils.message.displayMessage(loc.IT_INV_ERROR_MAX:format(getItemLink(itemClass)), Utils.message.type.ALERT_MESSAGE);
				if dropIfFull then
					dropMeBecauseIMFull(itemClass, itemData, toAdd - count, classID);
				end
				return onItemAddEnd(container, itemClass, 2, count);
			end
		end

		if toSlot and not container.content[toSlot] then
			freeSlot = toSlot;
		else
			-- Finding an empty slot
			for i = 1, ((containerClass.CO.SR or 5) * (containerClass.CO.SC or 4)) do
				local slotID = tostring(i);
				if not freeSlot and not container.content[slotID] then
					freeSlot = slotID;
				elseif canStack and container.content[slotID] and classID == container.content[slotID].id then
					if not TRP3_API.inventory.isInTransaction(container.content[slotID]) then
						local expectedCount = (container.content[slotID].count or 1) + 1;
						if expectedCount <= (itemClass.BA.ST) then
							stackSlot = slotID;
							break;
						end
					end
				end
			end
		end

		slot = stackSlot or freeSlot;

		-- Container is full
		if not slot then
			Utils.message.displayMessage(loc.IT_INV_ERROR_FULL:format(getItemLink(containerClass)), Utils.message.type.ALERT_MESSAGE);
			if dropIfFull then
				dropMeBecauseIMFull(itemClass, itemData, toAdd - count, classID);
			end
			return onItemAddEnd(container, itemClass, 1, count);
		end

		-- Adding item
		if not container.content[slot] then
			container.content[slot] = {
				id = classID,
			};
			local slot = container.content[slot];
			copySlotContent(slot, itemClass, itemData);
		end
		if stackSlot then
			container.content[slot].count = (container.content[slot].count or 1) + 1;
		end

	end

	return onItemAddEnd(container, itemClass, 0, toAdd);
end

function TRP3_API.inventory.getItem(container, slotID)
	-- Checking data
	local container = container or playerInventory;
	assert(isContainerByClassID(container.id), "Is not a container ! ID: " .. tostring(container.id));
	checkContainerInstance(container);
	return container.content[slotID];
end

function TRP3_API.inventory.removeItem(classID, amount, container)
	if not container or not isContainerByClassID(container.id) then
		container = playerInventory;
	end
	while amount > 0 do
		local container, slotID = TRP3_API.inventory.searchForFirstInstance(container, classID);
		if container and slotID then
			local slot = container.content[slotID];
			local amountFounded = (slot.count or 1);
			local amountToRemove = math.min(amount, amountFounded);
			slot.count = (slot.count or 1) - amountToRemove;
			if slot.count <= 0 then
				wipe(slot);
				container.content[slotID] = nil;
			end
			amount = amount - amountToRemove;
			TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG, container);
		else
			break;
		end
	end
	TRP3_API.inventory.recomputeAllInventory();
end

local function swapContainersSlots(container1, slot1, container2, slot2)
	assert(container1 and slot1, "Missing 'from' container/slot");
	assert(container2 and slot2, "Missing 'to' container/slot");
	checkContainerInstance(container2);

	local slot1Data = container1.content[slot1];
	local slot2Data = container2.content[slot2];
	local done;

	if slot2Data and slot1Data.id == slot2Data.id and (getClass(slot1Data.id).BA.ST or 0) > 0 then
		local stackMax = getClass(slot1Data.id).BA.ST;
		local availableOnTarget = stackMax - (slot2Data.count or 1);
		if availableOnTarget > 0 then
			local canBeMoved = math.min(availableOnTarget, slot1Data.count or 1);
			slot1Data.count = (slot1Data.count or 1) - canBeMoved;
			slot2Data.count = (slot2Data.count or 1) + canBeMoved;
			if slot1Data.count == 0 then
				wipe(container1.content[slot1]);
				container1.content[slot1] = nil;
			end
			done = true;
		end
	end

	if not done then
		if TRP3_API.inventory.isItemInContainer(container2, slot1Data) or TRP3_API.inventory.isItemInContainer(container1, slot2Data) then
			Utils.message.displayMessage(loc.IT_CON_CAN_INNER, Utils.message.type.ALERT_MESSAGE);
			return;
		end

		-- Check if containers can contain this type of item
		if slot1Data and slot1Data.id then
			local containerClass = getClass(container2.id);
			if containerClass.CO.OI and not TRP3_API.extended.objectsAreRelated(container2.id, slot1Data.id) then
				Utils.message.displayMessage(loc.IT_CON_ERROR_TYPE, Utils.message.type.ALERT_MESSAGE);
				return;
			end
		end
		if slot2Data and slot2Data.id then
			local containerClass = getClass(container1.id);
			if containerClass.CO.OI and not TRP3_API.extended.objectsAreRelated(container1.id, slot2Data.id) then
				Utils.message.displayMessage(loc.IT_CON_ERROR_TYPE, Utils.message.type.ALERT_MESSAGE);
				return;
			end
		end

		container2.content[slot2] = slot1Data;
		container1.content[slot1] = slot2Data;
	end

	TRP3_API.inventory.recomputeAllInventory();
	TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG, container1);
	if container1 ~= container2 then
		TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG, container2);
	end
end

local function doUseSlot(info, class, container)
	if info.cooldown then
		Utils.message.displayMessage(ERR_ITEM_COOLDOWN, Utils.message.type.ALERT_MESSAGE);
	else
		local useWorkflow = class.US.SC;
		if class.LI and class.LI.OU then
			useWorkflow = class.LI.OU;
		end
		local retCode = TRP3_API.script.executeClassScript(useWorkflow, class.SC,
			{object = info, container = container, class = class}, info.id);
		Events.fireEvent(TRP3_API.extended.ITEM_USED_EVENT, info.id, retCode);
		return retCode;
	end
end

local function useContainerSlot(slotButton, containerFrame)
	if slotButton.info then
		if slotButton.class.missing then -- If using a missing item : remove it
			TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_DETACH_SLOT, slotButton.info);
			if containerFrame.info.content[slotButton.slotID] then
				wipe(containerFrame.info.content[slotButton.slotID]);
			end
			containerFrame.info.content[slotButton.slotID] = nil;
		elseif slotButton.class and isUsableByClass(slotButton.class) then
			doUseSlot(slotButton.info, slotButton.class, containerFrame.info);
		end
	end
end

function TRP3_API.inventory.useContainerSlotID(container, slotID)
	if container and container.content and container.content[slotID] and container.content[slotID].id then
		local info = container.content[slotID];
		local id = info.id;
		local class = getClass(id);
		if class and isUsableByClass(class) then
			return doUseSlot(info, class, container);
		end
	end
end

function TRP3_API.inventory.consumeItem(slotInfo, containerInfo, quantity) -- Et grominet :D
	if slotInfo and containerInfo then
		slotInfo.count = math.max((slotInfo.count or 1) - quantity, 0);
		if slotInfo.count == 0 then
			for slotIndex, slot in pairs(containerInfo.content) do
				if slot == slotInfo then
					wipe(containerInfo.content[slotIndex]);
					containerInfo.content[slotIndex] = nil;
					TRP3_API.inventory.recomputeAllInventory();
					TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG, containerInfo);
				end
			end
		end
	end
end

function TRP3_API.inventory.changeContainerDurability(containerInfo, durabilityChange)
	if containerInfo and containerInfo.id and isContainerByClassID(containerInfo.id) then
		local class = getClass(containerInfo.id);
		if class.CO.DU and class.CO.DU > 0 then
			durabilityChange = durabilityChange or 0;
			if not containerInfo.durability then -- init from class info
				containerInfo.durability = class.CO.DU;
			end
			local old = containerInfo.durability;
			containerInfo.durability = containerInfo.durability + durabilityChange;
			containerInfo.durability = math.min(math.max(containerInfo.durability, 0), class.CO.DU);
			if old == containerInfo.durability then
				return 1;
			end
			return 0;
		end
	end
end

function TRP3_API.inventory.startCooldown(slotInfo, duration, container)
	if slotInfo and duration then
		if duration == 0 then
			slotInfo.cooldown = nil;
		else
			slotInfo.cooldown = time() + duration;
		end
		if container then
			TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG, container);
		end
	end
end

local function removeSlotContent(container, slotID, slotInfo, manuallyDestroyed)
	-- Check that nothing has changed
	if container.content[slotID] == slotInfo then
		local count = slotInfo.count or 1;
		local class = getClass(slotInfo.id);
		local link = getItemLink(class);

		if manuallyDestroyed then
			if class.LI and class.LI.OD then
				local retCode = TRP3_API.script.executeClassScript(class.LI.OD, class.SC,
					{object = slotInfo, container = container}, slotInfo.id);
			end
			Utils.message.displayMessage(loc.DR_DELETED:format(link, count));
		end

		wipe(container.content[slotID]);
		container.content[slotID] = nil;
		TRP3_API.inventory.recomputeAllInventory();
		TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG, container);
	end
end
TRP3_API.inventory.removeSlotContent = removeSlotContent;

local function splitSlot(slot, container, quantity)

	local containerClass = getClass(container.id);

	local emptySlotID;
	-- Finding an empty slot
	for i = 1, ((containerClass.CO.SR or 5) * (containerClass.CO.SC or 4)) do
		local slotID = tostring(i);
		if not container.content[slotID] then
			emptySlotID = slotID;
			break;
		end
	end

	if not emptySlotID then
		Utils.message.displayMessage(ERR_BAG_FULL, Utils.message.type.ALERT_MESSAGE);
		return;
	end

	container.content[emptySlotID] = {
		count = quantity,
		id = slot.id,
		madeBy = slot.madeBy
	};

	slot.count = slot.count - quantity;

	TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG, container);
end

function TRP3_API.inventory.getInventory()
	-- Structures
	local playerProfile = TRP3_API.profile.getPlayerCurrentProfile();
	if not playerProfile.inventory then
		playerProfile.inventory = {};
	end
	local playerInventory = playerProfile.inventory;
	playerInventory.id = "main";
	if not playerInventory.content then
		playerInventory.content = {};
	end
	return playerInventory;
end

local function recomputeContainerWeightValue(container)
	assert(container, "Nil container");
	local weight, value = 0, 0;

	if TRP3_API.extended.classExists(container.id) then
		-- Add container own weight
		local containerClass = getClass(container.id);
		if containerClass and containerClass.BA then
			weight = weight + (containerClass.BA.WE or 0);
			value = value + (containerClass.BA.VA or 0);
		end

		-- Add content weight
		for slotID, slotInfo in pairs(container.content or EMPTY) do
			if TRP3_API.extended.classExists(slotInfo.id) then
				if  isContainerByClassID(slotInfo.id) then
					local subWeight, subValue = recomputeContainerWeightValue(slotInfo);
					weight = weight + subWeight;
					value = value + subValue;
				else
					local class = getClass(slotInfo.id);
					if class and class.BA then
						weight = weight + ((class.BA.WE or 0) * (slotInfo.count or 1));
						value = value + ((class.BA.VA or 0) * (slotInfo.count or 1));
					end
				end
			end
		end
	end

	container.totalValue = value;
	container.totalWeight = weight;
	return weight, value;
end

function TRP3_API.inventory.recomputeAllInventory()
	recomputeContainerWeightValue(playerInventory);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.inventory.onStart()
	local refreshInventory = function()
		playerInventory = TRP3_API.inventory.getInventory();
		TRP3_API.inventory.closeBags();
		-- Check if init
		if not playerInventory.init then
			if not playerInventory.content["17"] then
				playerInventory.content["17"] = {
					["content"] = {},
					["id"] = "bag",
				};
			end
			playerInventory.init = true;
		end
		-- Recompute weight and value
		recomputeContainerWeightValue(playerInventory);
	end
	Events.listenToEvent(Events.REGISTER_PROFILES_LOADED, refreshInventory);
	refreshInventory();

	TRP3_API.extended.ITEM_USED_EVENT = "TRP3_ITEM_USED";
	TRP3_API.inventory.EVENT_ON_SLOT_USE = "EVENT_ON_SLOT_USE";
	TRP3_API.inventory.EVENT_ON_SLOT_SWAP = "EVENT_ON_SLOT_SWAP";
	TRP3_API.inventory.EVENT_DETACH_SLOT = "EVENT_DETACH_SLOT";
	TRP3_API.inventory.EVENT_REFRESH_BAG = "EVENT_REFRESH_BAG";
	TRP3_API.inventory.EVENT_ON_SLOT_REMOVE = "EVENT_ON_SLOT_REMOVE";
	TRP3_API.inventory.EVENT_SPLIT_SLOT = "EVENT_SPLIT_SLOT";
	TRP3_API.inventory.EVENT_LOOT_ALL = "EVENT_LOOT_ALL";
	TRP3_API.events.listenToEvent(TRP3_API.inventory.EVENT_ON_SLOT_SWAP, swapContainersSlots);
	TRP3_API.events.listenToEvent(TRP3_API.inventory.EVENT_ON_SLOT_USE, useContainerSlot);
	TRP3_API.events.listenToEvent(TRP3_API.inventory.EVENT_ON_SLOT_REMOVE, removeSlotContent);
	TRP3_API.events.listenToEvent(TRP3_API.inventory.EVENT_SPLIT_SLOT, splitSlot);

	-- Effect and operands
	TRP3_API.script.registerEffects(TRP3_API.inventory.EFFECTS);

	-- Inventory page
	TRP3_API.inventory.initInventoryPage();

	-- Inspection
	TRP3_InspectionFrame.init();

	-- Inventory exchange
	TRP3_ExchangeFrame.init();

	-- Drop system
	TRP3_DropSearchFrame.init();

	-- UI
	TRP3_API.inventory.initLootFrame();
	StackSplitFrame:SetScript("OnMouseWheel",function(_, delta)
		if delta == -1 then
			StackSplitFrameLeft_Click();
		elseif delta == 1 then
			StackSplitFrameRight_Click();
		end
	end);

	BINDING_NAME_TRP3_INVENTORY = loc.BINDING_NAME_TRP3_INVENTORY;
	BINDING_NAME_TRP3_MAIN_CONTAINER = loc.BINDING_NAME_TRP3_MAIN_CONTAINER;
	BINDING_NAME_TRP3_SEARCH_FOR_ITEMS = loc.BINDING_NAME_TRP3_SEARCH_FOR_ITEMS;
end