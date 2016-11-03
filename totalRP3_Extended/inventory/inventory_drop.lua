----------------------------------------------------------------------------------
-- Total RP 3: Exchange system
-- ---------------------------------------------------------------------------
-- Copyright 2016 Sylvain Cossement (telkostrasz@totalrp3.info)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
----------------------------------------------------------------------------------
local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local EMPTY = Globals.empty;
local Comm = TRP3_API.communication;
local type, tremove = type, tremove;
local tinsert, assert, strtrim, tostring, wipe, pairs, sqrt, tonumber = tinsert, assert, strtrim, tostring, wipe, pairs, sqrt, tonumber;
local getClass, isContainerByClassID, isUsableByClass = TRP3_API.extended.getClass, TRP3_API.inventory.isContainerByClassID, TRP3_API.inventory.isUsableByClass;
local UnitPosition, SetMapToCurrentZone, GetCurrentMapAreaID, GetPlayerMapPosition = UnitPosition, SetMapToCurrentZone, GetCurrentMapAreaID, GetPlayerMapPosition;
local loc = TRP3_API.locale.getText;
local getItemLink = TRP3_API.inventory.getItemLink;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local broadcast = TRP3_API.communication.broadcast;

local dropFrame, stashEditFrame, stashFoundFrame = TRP3_DropSearchFrame, TRP3_StashEditFrame, TRP3_StashFoundFrame;
local dropData, stashesData;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Drop
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function dropCommon(lootInfo)
	-- Proper coordinates
	local posY, posX, posZ = UnitPosition("player");

	-- We still need map position for potential marker placement
	SetMapToCurrentZone();
	local mapID = GetCurrentMapAreaID();
	local mapX, mapY = GetPlayerMapPosition("player");

	-- Pack the data
	local groundData = {
		posY = posY,
		posX = posX,
		posZ = posZ,
		mapID = mapID,
		mapX = mapX,
		mapY = mapY,
		item = {}
	};
	Utils.table.copy(groundData.item, lootInfo);
	groundData.item.count = groundData.item.count or 1;
	tinsert(dropData, groundData);
end

function TRP3_API.inventory.dropItemDirect(slotInfo)
	dropCommon(slotInfo);
	local count = slotInfo.count or 1;
	local link = getItemLink(getClass(slotInfo.id));
	Utils.message.displayMessage(loc("DR_DROPED"):format(link, count));
end

function TRP3_API.inventory.dropLoot(lootID)
	local loot = TRP3_API.inventory.getLoot(lootID);
	if loot then
		for _, loot in pairs(loot.IT or EMPTY) do
			TRP3_API.inventory.dropItemDirect(loot);
		end
	end
end

function TRP3_API.inventory.dropItem(container, slotID, initialSlotInfo)
	if slotID and container and isContainerByClassID(container.id) and container.content[slotID] then
		local slotInfo = container.content[slotID];
		-- Check that nothing has changed
		if slotInfo == initialSlotInfo then
			TRP3_API.inventory.dropItemDirect(slotInfo);

			-- Remove from inv
			TRP3_API.inventory.removeSlotContent(container, slotID, initialSlotInfo);
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Scan
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function initScans()
	TRP3_API.map.registerScan({
		id = "inv_scan_self",
		buttonText = loc("IT_INV_SCAN_MY_ITEMS"),
		scanTitle = loc("TYPE_ITEMS"),
		scan = function(saveStructure)
			local mapID = GetCurrentMapAreaID();
			for index, drop in pairs(dropData) do
				if drop.mapID == mapID then
					saveStructure[index] = { x = drop.mapX or 0, y = drop.mapY or 0 };
				end
			end
		end,
		canScan = function()
			local mapID, x, y = TRP3_API.map.getCurrentCoordinates("player");
			return x ~= nil and y ~= nil;
		end,
		scanMarkerDecorator = function(index, entry, marker)
			local drop = dropData[index];
			local item = getClass(drop.item.id);
			marker.scanLine = TRP3_API.inventory.getItemLink(item) .. " x" .. (drop.item.count or 1);
			marker.Icon:SetTexCoord(0.125, 0.250, 0.250, 0.375);
		end,
		noAnim = true,
	});

	TRP3_API.map.registerScan({
		id = "stashes_scan_self",
		buttonText = loc("DR_STASHES_SCAN_MY"),
		scanTitle = loc("DR_STASHES"),
		scan = function(saveStructure)
			local mapID = GetCurrentMapAreaID();
			for index, drop in pairs(stashesData) do
				if drop.mapID == mapID then
					saveStructure[index] = { x = drop.mapX or 0, y = drop.mapY or 0 };
				end
			end
		end,
		canScan = function()
			local mapID, x, y = TRP3_API.map.getCurrentCoordinates("player");
			return x ~= nil and y ~= nil;
		end,
		scanMarkerDecorator = function(index, entry, marker)
			local stash = stashesData[index] or EMPTY;
			local total = 0;
			for index, slot in pairs(stash.item) do
				total = total + 1;
			end
			local line = Utils.str.icon(stash.BA.IC) .. " " .. getItemLink(stash);
			marker.scanLine = line .. " - |cffff9900" .. total .. "/8";
			marker.Icon:SetTexCoord(0.250, 0.375, 0.625, 0.750);
		end,
		noAnim = true,
	});

	local STASHES_SCAN_COMMAND = "SSCAN";

	TRP3_API.map.registerScan({
		id = "stashes_scan_other",
		buttonText = loc("DR_STASHES_SCAN"),
		scan = function()
			local mapID = GetCurrentMapAreaID();
			broadcast.broadcast(STASHES_SCAN_COMMAND, mapID);
		end,
		scanTitle = loc("DR_STASHES"),
		scanCommand = STASHES_SCAN_COMMAND,
		scanResponder = function(sender, requestMapID)
			for _, stash in pairs(stashesData) do
				if stash.mapID == tonumber(requestMapID) then
					local total = 0;
					for index, slot in pairs(stash.item) do
						total = total + 1;
					end
					broadcast.sendP2PMessage(sender, STASHES_SCAN_COMMAND, stash.mapX, stash.mapY, stash.BA.NA or loc("DR_STASHES_NAME"), stash.BA.IC or "TEMP", total);
				end
			end
		end,
		canScan = function(currentlyScanning)
			local posY, posX = UnitPosition("player");
			return posY ~= nil and posY ~= nil and not currentlyScanning;
		end,
		scanAssembler = function(saveStructure, sender, mapX, mapY, NA, IC, total)
			local i = 1;
			while saveStructure[sender .. i] do
				i = i + 1;
			end
			saveStructure[sender .. i] = { x = mapX, y = mapY, BA = { NA = NA, IC = IC }, sender = sender, total = total };
		end,
		scanComplete = function(saveStructure)
		end,
		scanMarkerDecorator = function(index, entry, marker)
			local line = Utils.str.icon(entry.BA.IC) .. " " .. getItemLink(entry);
			marker.scanLine = line .. " - |cffff9900" .. entry.total .. "/8 |cff00ff00- " .. entry.sender;
			marker.Icon:SetTexCoord(0.250, 0.375, 0.625, 0.750);
		end,
		scanDuration = 2.5;
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Loot
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local MAX_SEARCH_DISTANCE = 15;
local searchForItems;

local function isInRadius(maxDistance, posY, posX, myPosY, myPosX)
	local distance = sqrt((posY - myPosY) ^ 2 + (posX - myPosX) ^ 2);
	return distance <= maxDistance, distance;
end

local function onLooted(itemData)
	for index, drop in pairs(dropData) do
		if drop.item.count <= 0 then
			wipe(dropData[index]);
			dropData[index] = nil;
		end
	end
end

function searchForItems()
	-- Proper coordinates
	SetMapToCurrentZone();
	local posY, posX = UnitPosition("player");
	local mapID = GetCurrentMapAreaID();

	local searchResults = {};
	for _, drop in pairs(dropData) do
		if drop.mapID == mapID then
			local isInRadius, distance = isInRadius(MAX_SEARCH_DISTANCE, posY, posX, drop.posY or 0, drop.posX or 0);
			if isInRadius then
				-- Show loot
				tinsert(searchResults, drop);
			end
		end
	end

	if #searchResults > 0 then
		local loot = {
			IT = {},
			BA = {
				IC = "icon_treasuremap",
			}
		}
		local total = 0;
		for index, result in pairs(searchResults) do
			loot.IT[tostring(index)] = result.item;
			total = total + (result.item.count or 1);
		end
		loot.BA.NA = loc("DR_RESULTS"):format(total);
		TRP3_API.inventory.presentLoot(loot, onLooted, nil, function()
			local posY2, posX2 = UnitPosition("player");
			local isInRad = isInRadius(MAX_SEARCH_DISTANCE / 2, posY, posX, posY2, posX2);
			if not isInRad then
				Utils.message.displayMessage(loc("LOOT_DISTANCE"), 4);
			end
			return isInRad;
		end, onLooted);
	else
		Utils.message.displayMessage(loc("DR_NOTHING"), 4);
	end
end

TRP3_API.inventory.searchForItems = searchForItems;

function TRP3_API.inventory.dropOrDestroy(itemClass, callbackDestroy, callbackDrop)
	StaticPopupDialogs["TRP3_DROP_ITEM"].text = loc("DR_POPUP_ASK"):format(TRP3_API.inventory.getItemLink(itemClass));
	local dialog = StaticPopup_Show("TRP3_DROP_ITEM");
	if dialog then
		dialog:ClearAllPoints();
		dialog:SetPoint("CENTER", UIParent, "CENTER");
	end
	dropFrame.callbackDestroy = callbackDestroy;
	dropFrame.callbackDrop = callbackDrop;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Stashes
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local stEtN = Utils.str.emptyToNil;
local showStash;
local stashContainer;
local createRefreshOnFrame = TRP3_API.ui.frame.createRefreshOnFrame;

local iconHandler = function(icon)
	stashEditFrame.icon.Icon:SetTexture("Interface\\ICONS\\" .. icon);
	stashEditFrame.icon.selectedIcon = icon;
end

local function openStashEditor(stashIndex)
	stashEditFrame.stashIndex = stashIndex;
	if stashIndex then
		stashEditFrame.title:SetText(loc("DR_STASHES_EDIT"));
		local stash = stashesData[stashIndex] or EMPTY;
		stashEditFrame.name:SetText(stash.BA and stash.BA.NA or loc("DR_STASHES_NAME"));
		iconHandler(stash.BA and stash.BA.IC or "temp");
	else
		stashEditFrame.title:SetText(loc("DR_STASHES_CREATE"));
		stashEditFrame.name:SetText(loc("DR_STASHES_NAME"));
		iconHandler("temp");
	end
	stashEditFrame:Show();
end

local function saveStash()
	local stash;
	local index = stashEditFrame.stashIndex;
	if index then
		stash = stashesData[index];
	end
	if not stash then
		stash = {
			BA = {},
			item = {}
		};
		tinsert(stashesData, stash);
		index = #stashesData;
	end
	stash.BA.IC = stashEditFrame.icon.selectedIcon or "TEMP";
	stash.BA.NA = stEtN(strtrim(stashEditFrame.name:GetText():sub(1, 50))) or loc("DR_STASHES_NAME");

	-- Proper coordinates
	local posY, posX, posZ = UnitPosition("player");
	SetMapToCurrentZone();
	local mapID, mapX, mapY = TRP3_API.map.getCurrentCoordinates("player");

	if posX and posY then
		stash.posX = posX;
		stash.posY = posY;
		stash.posZ = posZ;
		stash.mapID = mapID;
		stash.mapX = mapX;
		stash.mapY = mapY;
	end

	stashEditFrame:Hide();

	showStash(stash, index);
end

function showStash(stashInfo, stashIndex)
	if stashInfo then
		Utils.texture.applyRoundTexture(stashContainer.Icon, "Interface\\ICONS\\" .. (stashInfo.BA.IC or "TEMP"), "Interface\\ICONS\\TEMP");
		stashContainer.Title:SetText((stashInfo.BA.NA or loc("DR_STASHES_NAME")));

		local owner = stashInfo.owner or Globals.player_id;
		local sub = "|cff00ff00" .. owner;
		if stashIndex then
			sub = sub .. "\n\n|cffffff00" .. loc("CM_CLICK") .. ":|r " .. loc("CM_ACTIONS");
		end

		setTooltipForSameFrame(stashContainer.IconButton, "LEFT", 0, 5, Utils.str.icon(stashInfo.BA.IC or "TEMP") .. " " .. (stashInfo.BA.NA or loc("DR_STASHES_NAME")), sub);

		local data = stashInfo.item or EMPTY;
		for index, slot in pairs(stashContainer.slots) do
			slot.slotID = tostring(index);
			slot.index = index;
			if data[index] then
				slot.info = data[index];
				slot.class = getClass(data[index].id);
				slot.deletable = stashIndex ~= nil;
			else
				slot.info = nil;
				slot.class = nil;
			end
			TRP3_API.inventory.containerSlotUpdate(slot);
		end

		stashContainer:Show();
		stashContainer:Raise();
		stashContainer.stashInfo = stashInfo;
		stashContainer.stashIndex = stashIndex;
	end
end

local function initStashContainer()
	stashContainer = CreateFrame("Frame", "TRP3_StashContainer", UIParent, "TRP3_Container2x4Template");
	stashContainer.LockIcon:Hide();

	local dragStart = function(self)
		self:StartMoving();
	end
	local dragStop = function(self)
		self:StopMovingOrSizing();
	end

	stashContainer.info = { loot = true, stash = true };
	stashContainer.DurabilityText:SetText(loc("DR_STASHES_NAME"));
	stashContainer.WeightText:SetText("");
	stashContainer:RegisterForDrag("LeftButton");
	stashContainer:SetScript("OnDragStart", dragStart);
	stashContainer:SetScript("OnDragStop", dragStop);
	stashContainer:SetScript("OnHide", function(self)
		self.stashInfo = nil;
		self.stashIndex = nil;
		self:Hide();
	end);
	stashContainer.IconButton:SetScript("OnClick", function(self)
		if stashContainer.stashIndex then
			TRP3_API.ui.listbox.displayDropDown(self, {
				{ stashContainer.stashInfo.BA.NA or loc("DR_STASHES_NAME") },
				{ loc("DR_STASHES_EDIT"), 1 },
				{ loc("DR_STASHES_REMOVE"), 2 }
			}, function(value)
				if value == 1 then
					openStashEditor(stashContainer.stashIndex);
					stashContainer:Hide();
				else
					TRP3_API.popup.showConfirmPopup(loc("DR_STASHES_REMOVE_PP"), function()
						if stashContainer.stashIndex then
							wipe(stashesData[stashContainer.stashIndex]);
							tremove(stashesData, stashContainer.stashIndex);
							stashContainer:Hide();
							Utils.message.displayMessage(loc("DR_STASHES_REMOVED"), 1);
						end
					end);
				end
			end, 0, true);
		end
	end);
	TRP3_API.ui.tooltip.setTooltipAll(stashContainer.IconButton, "TOP", 0, 0, loc("CM_ACTIONS"));
	local checkDiscard = function(slotFrom)
		local index = slotFrom.index;
		if index and stashContainer:IsVisible() and stashContainer.stashInfo and stashContainer.stashIndex then
			local stash = stashContainer.stashInfo;
			if stash.item[index] and stash.item[index].count <= 0 then
				wipe(stash.item[index]);
				tremove(stash.item, index);
			end
			showStash(stash, stashContainer.stashIndex);
		end
	end
	stashContainer.onDiscardCallback = function(_, slotFrom)
		checkDiscard(slotFrom);
	end
	stashContainer.onLootCallback = function(_, _, slotFrom)
		checkDiscard(slotFrom);
	end

	stashContainer.Bottom:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Keyring");
	stashContainer.Middle:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Keyring");
	stashContainer.Top:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Keyring");

	TRP3_API.inventory.initContainerSlots(stashContainer, 2, 4, true);

	createRefreshOnFrame(stashContainer, 0.15, function(self)
		local posY, posX = UnitPosition("player");
		if (not posY or not posX) or not self.stashInfo or not isInRadius(MAX_SEARCH_DISTANCE, posY, posX, self.stashInfo.posY, self.stashInfo.posX) then
			self:Hide();
			Utils.message.displayMessage(loc("DR_STASHES_TOO_FAR"), 4);
		end
	end);
end

local function doStashSlot(slotFrom, container, slotID, itemCount)
	assert(slotFrom.info, "No info from origin loot");
	assert(not slotFrom:GetParent().info.loot, "Can't stash from a loot.");

	local slotInfo = container.content[slotID];

	-- Check that nothing has changed
	if slotInfo == slotFrom.info then

		if stashContainer:IsVisible() and stashContainer.stashIndex then
			-- Check that there is a free slot in the stash
			local stashData = stashContainer.stashInfo;
			if #stashData.item < 8 then
				slotFrom.info.count = slotFrom.info.count or 1;

				local stashedSlotInfo = {};
				Utils.table.copy(stashedSlotInfo, slotFrom.info);
				stashedSlotInfo.count = itemCount;

				tinsert(stashData.item, stashedSlotInfo);
				showStash(stashData, stashContainer.stashIndex);

				Utils.message.displayMessage(loc("DR_STASHED"):format(getItemLink(getClass(stashedSlotInfo.id)), itemCount));

				-- Remove from inv
				slotInfo.count = (slotInfo.count or 1) - itemCount;
				if slotInfo.count <= 0 then
					TRP3_API.inventory.removeSlotContent(container, slotID, slotInfo);
				else
					TRP3_API.inventory.recomputeAllInventory();
					TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG, container);
				end
			else
				Utils.message.displayMessage(loc("DR_STASHES_FULL"), 4);
			end
		end
	end

end

function TRP3_API.inventory.stashSlot(slotFrom, container, slotID)
	assert(slotFrom.info, "No info from origin loot");
	assert(not slotFrom:GetParent().info.loot, "Can't stash from a loot.");

	local lootInfo = slotFrom.info;
	local itemID = lootInfo.id;
	local itemCount = slotFrom.info.count or 1;

	if itemCount == 1 then
		doStashSlot(slotFrom, container, slotID, itemCount);
	else
		TRP3_API.popup.showNumberInputPopup(loc("DB_ADD_COUNT"):format(TRP3_API.inventory.getItemLink(TRP3_API.extended.getClass(itemID))), function(value)
			value = math.min(value or 1, itemCount);
			if slotFrom and slotFrom.info and value > 0 and value <= itemCount then
				doStashSlot(slotFrom, container, slotID, value or 1);
			end
		end, nil, itemCount);
	end
end

local SEARCH_STASHES_COMMAND = "SSCM";
local STASHES_REQUEST_DURATION = 2.5;
local stashResponse = {};

local function displayStashesResponse()
	local total = #stashResponse;
	if total == 0 then
		Utils.message.displayMessage(loc("DR_STASHES_NOTHING"), 4);
	else
		stashFoundFrame.title:SetText(loc("DR_STASHES_FOUND"):format(#stashResponse));

		stashFoundFrame:Show();
	end
end

local function startStashesRequest()
	SetMapToCurrentZone();
	local posY, posX = UnitPosition("player");
	local mapID = GetCurrentMapAreaID();
	if posX and posY then
		wipe(stashResponse);
		local cID = TRP3_API.extended.showCastingBar(STASHES_REQUEST_DURATION, 2, nil, nil, loc("DR_STASHES_SCAN"));
		broadcast.broadcast(SEARCH_STASHES_COMMAND, mapID, posY, posX, cID);
		C_Timer.After(STASHES_REQUEST_DURATION, function()
			if TRP3_CastingBarFrame.castID == cID then
				displayStashesResponse();
			end
		end);
	end
end

local function receivedStashesRequest(sender, mapID, posY, posX, castID)
	mapID = tonumber(mapID or 0) or 0;
	posY = tonumber(posY or 0) or 0;
	posX = tonumber(posX or 0) or 0;
	Utils.log.log(("%s is asking for stashes in zone %s."):format(sender, mapID));
	for index, stash in pairs(stashesData) do
		if stash.mapID == mapID then
			local isInRadius, distance = isInRadius(MAX_SEARCH_DISTANCE, posY, posX, stash.posY or 0, stash.posX or 0);
			if isInRadius then
				-- P2P response
				local total = 0;
				for index, slot in pairs(stash.item) do
					total = total + 1;
				end
				Comm.broadcast.sendP2PMessage(sender, SEARCH_STASHES_COMMAND, index, stash.BA.NA, stash.BA.IC, total, castID);
			end
		end
	end
end

local function receivedStashesResponse(sender, index, name, icon, slot, cID)
	Utils.log.log(("Received stash %s from %s."):format(name, sender));
	if TRP3_CastingBarFrame.castID == cID then
		tinsert(stashResponse, {sender, index, name, icon, slot});
	else
		Utils.log.log(("Wrong cast ID for stashes response."));
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Toolbar button
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local ACTION_SEARCH_MY = "a";
local ACTION_STASH_CREATE = "c";
local ACTION_STASH_SEARCH = "d";

local function onDropButtonAction(actionID)
	if actionID == ACTION_SEARCH_MY then
		searchForItems();
	elseif actionID == ACTION_STASH_CREATE then
		openStashEditor(nil);
	elseif actionID == ACTION_STASH_SEARCH then
		startStashesRequest();
	elseif type(actionID) == "number" then
		showStash(stashesData[actionID], actionID);
	end
end

local function getActionValue(value, x, y)
	if x and y then
		return value;
	end
	return nil;
end

local function onToolbarButtonClick(button, mouseButton)
	SetMapToCurrentZone();
	local posY, posX = UnitPosition("player");
	local mapID = GetCurrentMapAreaID();

	local dropdownItems = {};
	tinsert(dropdownItems, { loc("DR_SYSTEM"), nil });
	tinsert(dropdownItems, { loc("DR_SEARCH_BUTTON"), getActionValue(ACTION_SEARCH_MY, posX, posY), loc("DR_SEARCH_BUTTON_TT") });
	tinsert(dropdownItems, { loc("DR_STASHES_SEARCH"), getActionValue(ACTION_STASH_SEARCH, posX, posY), loc("DR_STASHES_SEARCH_TT") });
	tinsert(dropdownItems, { loc("DR_STASHES_CREATE"), getActionValue(ACTION_STASH_CREATE, posX, posY), loc("DR_STASHES_CREATE_TT") });
	if posX and posY then
		local searchResults = {};
		for _, stash in pairs(stashesData) do
			if stash.mapID == mapID then
				local isInRadius, distance = isInRadius(MAX_SEARCH_DISTANCE, posY, posX, stash.posY or 0, stash.posX or 0);
				if isInRadius then
					-- Show loot
					tinsert(searchResults, stash);
				end
			end
		end

		if #searchResults > 0 then
			tinsert(dropdownItems, { "" });
			tinsert(dropdownItems, { loc("DR_STASHES_WITHIN"), nil });
			for index, stash in pairs(searchResults) do
				tinsert(dropdownItems, { getItemLink(stash), index });
			end
		end
	end
	tinsert(dropdownItems, { "" });

	TRP3_API.ui.listbox.displayDropDown(button, dropdownItems, onDropButtonAction, 0, true);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function dropFrame.init()
	-- Init data
	if not TRP3_Drop then
		TRP3_Drop = {};
	end
	dropData = TRP3_Drop;
	if not TRP3_Stashes then
		TRP3_Stashes = {};
	end
	stashesData = TRP3_Stashes;

	-- Cleanup
	for index, dropData in pairs(dropData) do
		if dropData.item.count then
			if dropData.item.count == 0 then
				tremove(dropData, index);
			end
		else
			dropData.item.count = 1;
		end
	end
	for index, stash in pairs(stashesData) do
		for index, stashItem in pairs(stash.item or EMPTY) do
			if stashItem.count then
				if stashItem.count == 0 then
					tremove(stash.item, index);
				end
			else
				stashItem.count = 1;
			end
		end
	end

	initScans();

	-- UI
	-- Button on toolbar
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		if TRP3_API.toolbar then
			local toolbarButton = {
				id = "bb_extended_drop",
				icon = "icon_treasuremap",
				configText = loc("DR_SEARCH_BUTTON"),
				tooltip = loc("DR_SYSTEM"),
				tooltipSub = loc("DR_SYSTEM_TT"),
				onClick = function(Uibutton, buttonStructure, button)
					onToolbarButtonClick(Uibutton, button);
				end,
				visible = 1
			};
			TRP3_API.toolbar.toolbarAddButton(toolbarButton);
		end
	end);

	StaticPopupDialogs["TRP3_DROP_ITEM"] = {
		button1 = loc("DR_POPUP_REMOVE"),
		button2 = CANCEL,
		button3 = loc("DR_POPUP"),
		OnAccept = function()
			if dropFrame.callbackDestroy then
				dropFrame.callbackDestroy();
			end
		end,
		OnAlt = function()
			if dropFrame.callbackDrop then
				dropFrame.callbackDrop();
			end
		end,
		timeout = false,
		whileDead = true,
		hideOnEscape = true,
		showAlert = true,
	};

	-- Stashes
	TRP3_API.ui.frame.setupMove(stashEditFrame);
	stashEditFrame.cancel:SetText(CANCEL);
	stashEditFrame.cancel:SetScript("OnClick", function() stashEditFrame:Hide() end);
	stashEditFrame.ok:SetText(SAVE);
	stashEditFrame.ok:SetScript("OnClick", function() saveStash() end);

	stashEditFrame.name.title:SetText(loc("DR_STASHES_NAME") .. " (" .. loc("DR_STASHES_MAX") .. ")");
	setTooltipForSameFrame(stashEditFrame.icon, "RIGHT", 0, 5, loc("EDITOR_ICON"));
	stashEditFrame.icon:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.ICONS,
			{ parent = stashEditFrame.icon, point = "LEFT", parentPoint = "RIGHT", x = 15 },
			{ iconHandler });
	end);

	initStashContainer();
	Comm.broadcast.registerCommand(SEARCH_STASHES_COMMAND, receivedStashesRequest);
	Comm.broadcast.registerP2PCommand(SEARCH_STASHES_COMMAND, receivedStashesResponse);

	TRP3_API.ui.frame.setupMove(stashFoundFrame);
end