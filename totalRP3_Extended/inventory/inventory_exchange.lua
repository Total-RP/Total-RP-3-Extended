----------------------------------------------------------------------------------
-- Total RP 3: Exchange system
--	---------------------------------------------------------------------------
--	Copyright 2016 Sylvain Cossement (telkostrasz@totalrp3.info)
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
local Communications = AddOn_TotalRP3.Communications;
local tonumber, assert, strsplit, tostring, wipe, pairs, type = tonumber, assert, strsplit, tostring, wipe, pairs, type;
local getClass, isContainerByClassID, isUsableByClass = TRP3_API.extended.getClass, TRP3_API.inventory.isContainerByClassID, TRP3_API.inventory.isUsableByClass;
local isContainerByClass, getItemTextLine = TRP3_API.inventory.isContainerByClass, TRP3_API.inventory.getItemTextLine;
local checkContainerInstance, countItemInstances = TRP3_API.inventory.checkContainerInstance, TRP3_API.inventory.countItemInstances;
local getItemLink = TRP3_API.inventory.getItemLink;
local loc = TRP3_API.loc;
local EMPTY = TRP3_API.globals.empty;
local classExists = TRP3_API.extended.classExists;
local getQualityColorRGB = TRP3_API.inventory.getQualityColorRGB;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local SECURITY_LEVEL = TRP3_API.security.SECURITY_LEVEL;
local exchangeFrame = TRP3_ExchangeFrame;
local sendCurrentState, sendAcceptExchange, sendCancel, sendItemDataRequest;
local UnitIsPlayer = UnitIsPlayer;

local UPDATE_EXCHANGE_QUERY_PREFIX = "IEUE";
local CANCEL_EXCHANGE_QUERY_PREFIX = "IECE";
local ACCEPT_EXCHANGE_QUERY_PREFIX = "IEAE";
local DATA_EXCHANGE_QUERY_PREFIX = "IEDE";
local SEND_DATA_QUERY_PREFIX = "IESD";
local FINISH_EXCHANGE_QUERY_PREFIX = "IEFE";

local SEND_DATE_PRIORITY = Communications.PRIORITIES.LOW;
local START_EXCHANGE_PRIORITY = Communications.PRIORITIES.MEDIUM;

local MAX_MESSAGES_SIZE = 25;

local currentDownloads = {};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local MISSING_CLASS = {
	BA = {
		NA = "Item to download",
	},
	MD = {

	},
}

local function getItemClass(id)
	if classExists(id) then
		return getClass(id);
	else
		return MISSING_CLASS;
	end
end

local function getItemClassSecurityLevel()

end

local function reloadDownloads()
	local yourData = exchangeFrame.yourData;
	local myData = exchangeFrame.myData;
	for index, slot in pairs(exchangeFrame.rightSlots) do
		slot.security:Hide();
		slot.details:SetText("");
		if yourData[tostring(index)] then
			local rootClassId = yourData[tostring(index)].id;
			local rootClassVersion = yourData[tostring(index)].vn;
			if currentDownloads[rootClassId] then
				local percent = currentDownloads[rootClassId] * 100;
				slot.details:SetFormattedText(loc.IT_EX_DOWNLOADING, percent);
			elseif classExists(rootClassId) and getClass(rootClassId).MD.V >= rootClassVersion then
				local class = getItemClass(rootClassId);
				if class.securityLevel ~= SECURITY_LEVEL.HIGH then
					-- If at least one effectgroup is blocked, only then we bother the user
					if TRP3_API.security.atLeastOneBlocked(rootClassId) then
						local secLevelText = ("|cffffffff%s: %s"):format(loc.SEC_LEVEL, TRP3_API.security.getSecurityText(class.securityLevel));
						slot.details:SetText("|cffff0000" .. loc.SEC_EFFECT_BLOCKED);
						slot.security:Show();
						setTooltipForSameFrame(slot.security, "TOP", 0, 5, loc.SEC_EFFECT_BLOCKED, loc.SEC_EFFECT_BLOCKED_TT);
						slot.security:SetScript("OnClick", function()
							TRP3_API.security.showSecurityDetailFrame(rootClassId, exchangeFrame);
						end);
					end

				end
			end
		end
	end
	for index, slot in pairs(exchangeFrame.leftSlots) do
		if myData[tostring(index)] then
			slot.details:SetText("");
			slot.security:Hide();
		end
	end
end

local function decorateSlot(slot, slotData, count, class)
	slot.Quest:Hide();
	slot.Quantity:Hide();
	slot.IconBorder:Hide();

	if classExists(slotData.c.id) then
		slot.name:SetText(getItemLink(class));
	else
		slot.name:SetText(slotData.n or UNKNOWN);
	end

	slot.Icon:SetTexture("Interface\\ICONS\\" .. (class.BA.IC or slotData.i or "temp"));
	if count > 1 then
		slot.Quantity:Show();
		slot.Quantity:SetText(count);
	end
	if slotData.q or class.BA.QE then
		slot.Quest:Show();
	end
	local quality = slotData.qa or class.BA.QA or 1;
	if quality ~= 1 then
		slot.IconBorder:Show();
		local r, g, b = getQualityColorRGB(quality);
		slot.IconBorder:SetVertexColor(r, g, b);
	end

	return class.BA.VA or slotData.v or 0, class.BA.WE or slotData.w or 0;
end

local function estimateSendingTime(messageCount)
	return (messageCount - 16) / 3;
end

local function drawUI()
	local myData = exchangeFrame.myData;
	local yourData = exchangeFrame.yourData;

	do
		local totalValue, totalWeight = 0, 0;
		local empty = true;
		for index, slot in pairs(exchangeFrame.leftSlots) do
			local dataIndex = tostring(index);
			slot:Hide();
			slot.details:SetText("");
			if myData[dataIndex] then
				local slotData = myData[dataIndex];
				local count = slotData.c.count or 1;
				local class = getItemClass(slotData.c.id);
				local value, weight = decorateSlot(slot, slotData, count, class);

				slot.slotInfo = slotData.c or EMPTY;
				slot.itemClass = class;

				totalValue = totalValue + (value * count);
				totalWeight = totalWeight + (weight * count);
				slot:Show();
				empty = false;
			end
		end

		exchangeFrame.left.empty:Hide();
		if empty then
			exchangeFrame.left.empty:Show();
		end

		exchangeFrame.left.value:SetText(GetCoinTextureString(totalValue));
		exchangeFrame.left.weight:SetText(Utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15) .. TRP3_API.extended.formatWeight(totalWeight));
	end

	do
		local totalValue, totalWeight = 0, 0;
		local atLeastOneBad = false;
		local empty = true;
		for index, slot in pairs(exchangeFrame.rightSlots) do
			local dataIndex = tostring(index);
			slot:Hide();
			slot.details:SetText("");
			slot.download:Hide();
			if yourData[dataIndex] then
				local slotData = yourData[dataIndex];
				local count = slotData.c.count or 1;
				local rootClassId = slotData.id;
				local rootClassVersion = tonumber(slotData.vn or 0);
				local class = getItemClass(slotData.c.id);
				if not classExists(rootClassId) or getClass(rootClassId).MD.V < rootClassVersion then
					atLeastOneBad = true;
					class.BA.DE = loc.IT_EX_SLOT_DOWNLOAD:format(exchangeFrame.targetID);
					if slotData.si >= MAX_MESSAGES_SIZE and not currentDownloads[rootClassId] then
						slot.download:Show();
						slot.download:SetScript("OnClick", function()
							sendItemDataRequest(rootClassId, rootClassVersion);
							drawUI();
						end);
						setTooltipForSameFrame(slot.download, "TOP", 0, 5,
							loc.IT_EX_DOWNLOAD, loc.IT_EX_DOWNLOAD_TT:format(slotData.si, estimateSendingTime(slotData.si), exchangeFrame.targetID));
					end
				end
				local value, weight = decorateSlot(slot, slotData, count, class);

				slot.slotInfo = slotData.c or EMPTY;
				slot.itemClass = class;

				totalValue = totalValue + (value * count);
				totalWeight = totalWeight + (weight * count);
				slot:Show();
				empty = false;
			end
		end

		exchangeFrame.right.empty:Hide();
		if empty then
			exchangeFrame.right.empty:Show();
		end

		exchangeFrame.right.value:SetText(GetCoinTextureString(totalValue));
		exchangeFrame.right.weight:SetText(Utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15) .. TRP3_API.extended.formatWeight(totalWeight));

		exchangeFrame.ok:Enable();
		if atLeastOneBad then
			exchangeFrame.ok:Disable();
		end
	end

	-- Confirmation overlay
	exchangeFrame.left.confirm:Hide();
	if myData.ok then
		exchangeFrame.left.confirm:Show();
	end
	exchangeFrame.right.confirm:Hide();
	if yourData.ok then
		exchangeFrame.right.confirm:Show();
	end

	exchangeFrame.target:SetText(TRP3_API.register.getUnitRPNameWithID(exchangeFrame.targetID));

	reloadDownloads();

	exchangeFrame:Show();
end

local function confirmExchangeAction()
	exchangeFrame.myData.ok = true;
	drawUI();
	sendAcceptExchange();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- BUISINESS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function isInTransaction(slotInfo)
	for _, exchangeSlot in pairs(exchangeFrame.myData or EMPTY) do
		if type(exchangeSlot) == "table" and exchangeSlot.c == slotInfo then
			return true;
		end
	end
	return false;
end
TRP3_API.inventory.isInTransaction = isInTransaction;

local slotMapping = {};

local function addToExchange(container, slotID)
	assert(container and slotID, "No container or slotID");
	assert(container.content[slotID], "Can't find slot in container.");

	local slotInfo = container.content[slotID];
	local itemClass = getClass(slotInfo.id);
	local parts = {strsplit(TRP3_API.extended.ID_SEPARATOR, slotInfo.id)};
	local rootClassID = parts[1];
	local rootClass = getClass(rootClassID);

	-- Can't exchange an non-empty bag for now
	if TRP3_API.inventory.isContainerByClass(itemClass) and Utils.table.size(slotInfo.content or EMPTY) > 0 then
		if not itemClass.CO.OI then
			Utils.message.displayMessage(loc.IT_CON_ERROR_TRADE, Utils.message.type.ALERT_MESSAGE);
			return;
		end
	end

	if not exchangeFrame.targetID then
		-- Then it's a new exchange
		exchangeFrame.targetID = Utils.str.getUnitID("mouseover");
	end
	if not exchangeFrame.myData then
		exchangeFrame.myData = {};
	end
	if not exchangeFrame.yourData then
		exchangeFrame.yourData = {};
	end

	if isInTransaction(slotInfo) then
		return;
	end

	-- Add item end of list
	local found = false;
	for i=1, 4 do
		local index = tostring(i);
		if not exchangeFrame.myData[index] then
			exchangeFrame.myData[index] = {
				c = slotInfo,
				i = itemClass.BA.IC,
				n = getItemLink(itemClass),
				v = itemClass.BA.VA,
				w = itemClass.BA.WE,
				q = itemClass.BA.QE,
				qa = itemClass.BA.QA,
				id = rootClassID,
				vn = rootClass.MD.V,
				si = Communications.estimateStructureLoad(rootClass);
			};
			slotMapping[slotInfo] = {container, slotID};
			found = true;
			break;
		end
	end
	-- Already used the 4 exchange slots
	if not found then
		return;
	end

	exchangeFrame.myData.ok = nil;
	exchangeFrame.yourData.ok = nil;

	drawUI();

	Communications.sendObject(UPDATE_EXCHANGE_QUERY_PREFIX, exchangeFrame.myData, exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
end
TRP3_API.inventory.addToExchange = addToExchange;

--- Opens an empty exchange frame with the given unit ID
--- @param targetID string @ The complete unit ID of the target of the exchange
local function startEmptyExchangeWithUnit(targetID)
	exchangeFrame.targetID = targetID;
	exchangeFrame.myData = {};
	exchangeFrame.yourData = {};
	exchangeFrame.myData.ok = nil;
	exchangeFrame.yourData.ok = nil;
	drawUI();
	Communications.sendObject(UPDATE_EXCHANGE_QUERY_PREFIX, exchangeFrame.myData, exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
end
TRP3_API.inventory.startEmptyExchangeWithUnit = startEmptyExchangeWithUnit;

local function removeItem(index)
	assert(exchangeFrame.myData, "No exchangeFrame.myData");
	assert(exchangeFrame.myData[tostring(index)], "Slot is already empty");

	slotMapping[exchangeFrame.myData[tostring(index)].c] = nil;
	exchangeFrame.myData[tostring(index)].c = nil;
	wipe(exchangeFrame.myData[tostring(index)]);
	exchangeFrame.myData[tostring(index)] = nil;

	exchangeFrame.myData.ok = nil;
	exchangeFrame.yourData.ok = nil;

	drawUI();
	sendCurrentState();
end

local function closeTransaction()
	wipe(currentDownloads);
	if exchangeFrame.myData then
		for _, exchangeSlot in pairs(exchangeFrame.myData) do
			if type(exchangeSlot) == "table" and exchangeSlot.c then
				slotMapping[exchangeSlot.c] = nil;
				exchangeSlot.c = nil;
			end
		end
		wipe(exchangeFrame.myData);
	end
	if exchangeFrame.yourData then
		wipe(exchangeFrame.yourData);
	end
	exchangeFrame.myData = nil;
	exchangeFrame.yourData = nil;
	exchangeFrame.targetID = nil;
	exchangeFrame:Hide();
end

local function cancelExchange()
	if exchangeFrame.targetID then
		sendCancel();
	end
	closeTransaction();
	Utils.message.displayMessage(ERR_TRADE_CANCELLED, Utils.message.type.ALERT_MESSAGE);
end

local function lootTransaction()
	-- First remove what you gave
	for i=1, 4 do
		local index = tostring(i);
		if exchangeFrame.myData[index] then
			local slotData = exchangeFrame.myData[index].c;
			if slotMapping[slotData] then
				TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_ON_SLOT_REMOVE, slotMapping[slotData][1], slotMapping[slotData][2], slotData);
			end
		end
	end

	-- Then loot what we received
	for i=1, 4 do
		local index = tostring(i);
		if exchangeFrame.yourData[index] then
			local slotData = exchangeFrame.yourData[index];
			TRP3_API.inventory.addItem(nil, slotData.c.id, slotData.c, true);
		end
	end

end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- NETWORKING
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function sendCurrentState()
	assert(exchangeFrame.targetID, "No targetID");
	Communications.sendObject(UPDATE_EXCHANGE_QUERY_PREFIX, exchangeFrame.myData, exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
end

function sendItemDataRequest(rootClassId, rootClassVersion)
	if currentDownloads[rootClassId] then
		-- We already ask for data
		return;
	end

	local reservedMessageID = Communications.getNewMessageToken();
	local request = {
		id = rootClassId,
		v = rootClassVersion,
		mId = reservedMessageID,
	};

	currentDownloads[rootClassId] = 0;
	Communications.registerMessageTokenProgressHandler(reservedMessageID, exchangeFrame.targetID, function(_, total, current)
		currentDownloads[rootClassId] = current / total;
		reloadDownloads();
		if current == total then
			currentDownloads[rootClassId] = nil;
		end
	end);
	Communications.sendObject(DATA_EXCHANGE_QUERY_PREFIX, request, exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
	reloadDownloads();
end

local function receivedDataRequest(request, sender)
	local classID = request.id;
	local version = request.v;
	local messageID = request.mId;

	local class = getClass(classID);
	local response = {
		id = classID,
		class = class;
	}

	Communications.sendObject(SEND_DATA_QUERY_PREFIX, response, sender, SEND_DATE_PRIORITY, messageID);
end

local function receivedDataResponse(response, sender)
	local classID = response.id;
	local class = response.class;

	-- Last check that we don't got it in the meantime
	if not classExists(classID) or getClass(classID).MD.V < class.MD.V then
		TRP3_DB.exchange[classID] = class;
		TRP3_API.security.computeSecurity(classID, class);
		TRP3_API.extended.unregisterObject(classID);
		TRP3_API.extended.registerObject(classID, class, 0);
		TRP3_API.script.clearRootCompilation(classID);
		TRP3_API.security.registerSender(classID, sender);
		TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG);
		TRP3_API.events.fireEvent(TRP3_API.quest.EVENT_REFRESH_CAMPAIGN);
		TRP3_API.events.fireEvent(Events.ON_OBJECT_UPDATED);
	end

	currentDownloads[classID] = nil;

	drawUI();
end

local function receivedFinish(_, sender)
	if exchangeFrame:IsVisible() and exchangeFrame.targetID == sender then
		lootTransaction();
		exchangeFrame.targetID = nil;
		closeTransaction();
	end
end

-- Received accept from the other side
local function receivedAccept(_, sender)
	if exchangeFrame:IsVisible() and exchangeFrame.targetID == sender then
		exchangeFrame.yourData.ok = true;
		drawUI();
		if exchangeFrame.myData.ok then
			Communications.sendObject(FINISH_EXCHANGE_QUERY_PREFIX, "", exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
			receivedFinish(nil, sender);
		end
	else
		sendCancel(sender);
	end
end

-- Send accept to the other side
function sendAcceptExchange()
	Communications.sendObject(ACCEPT_EXCHANGE_QUERY_PREFIX, exchangeFrame.myData, exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
end

local function receivedUpdate(data, sender)
	exchangeFrame.targetID = sender;

	if exchangeFrame.yourData then
		wipe(exchangeFrame.yourData);
	end
	exchangeFrame.yourData = data;

	if not exchangeFrame.myData then
		exchangeFrame.myData = {};
	end

	exchangeFrame.myData.ok = nil;

	-- Check data for update query
	for i=1, 4 do
		local index = tostring(i);
		if exchangeFrame.yourData[index] then
			local slot = exchangeFrame.yourData[index];
			local rootClassId = slot.id;
			local rootClassVersion = tonumber(slot.vn) or 0;

			if not classExists(rootClassId) or getClass(rootClassId).MD.V < rootClassVersion then
				if slot.si < MAX_MESSAGES_SIZE then
					sendItemDataRequest(rootClassId, rootClassVersion);
				end
			end
		end
	end

	drawUI();
end

function sendCancel(sender)
	if sender or exchangeFrame.targetID then
		Communications.sendObject(CANCEL_EXCHANGE_QUERY_PREFIX, "", sender or exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
	end
end

local function receivedCancel(_, sender)
	if exchangeFrame:IsVisible() and exchangeFrame.targetID == sender then
		exchangeFrame.targetID = nil;
		cancelExchange();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function exchangeFrame.init()

	exchangeFrame.leftSlots = {
		exchangeFrame.left.slot1, exchangeFrame.left.slot2, exchangeFrame.left.slot3, exchangeFrame.left.slot4
	}
	exchangeFrame.rightSlots = {
		exchangeFrame.right.slot1, exchangeFrame.right.slot2, exchangeFrame.right.slot3, exchangeFrame.right.slot4
	}

	for index, slot in pairs(exchangeFrame.leftSlots) do
		slot:SetScript("OnClick", function()
			removeItem(index);
			TRP3_ItemTooltip:Hide();
		end);
		slot:SetScript("OnEnter", function(self)
			TRP3_API.inventory.showItemTooltip(self, self.slotInfo, self.itemClass);
		end);
		slot.download:Hide();
	end
	for index, slot in pairs(exchangeFrame.rightSlots) do
		slot:SetScript("OnEnter", function(self)
			TRP3_API.inventory.showItemTooltip(self, self.slotInfo, self.itemClass);
		end);
		slot.download:SetText(loc.IT_EX_DOWNLOAD);
	end

	exchangeFrame.left.empty:SetText(loc.IT_EX_EMPTY_DRAG);
	exchangeFrame.right.empty:SetText(loc.IT_EX_EMPTY);
	exchangeFrame.title:SetText(TRADE);

	exchangeFrame.cancel:SetText(CANCEL);
	exchangeFrame.cancel:SetScript("OnClick", function() cancelExchange() end);
	exchangeFrame.ok:SetText(TRADE);
	exchangeFrame.ok:SetScript("OnClick", function() confirmExchangeAction() end);

	exchangeFrame.Background:SetTexture("Interface\\BankFrame\\Bank-Background", true, true);

	-- Register prefix for data exchange
	Communications.registerSubSystemPrefix(UPDATE_EXCHANGE_QUERY_PREFIX, receivedUpdate);
	Communications.registerSubSystemPrefix(CANCEL_EXCHANGE_QUERY_PREFIX, receivedCancel);
	Communications.registerSubSystemPrefix(ACCEPT_EXCHANGE_QUERY_PREFIX, receivedAccept);
	Communications.registerSubSystemPrefix(DATA_EXCHANGE_QUERY_PREFIX, receivedDataRequest);
	Communications.registerSubSystemPrefix(SEND_DATA_QUERY_PREFIX, receivedDataResponse);
	Communications.registerSubSystemPrefix(FINISH_EXCHANGE_QUERY_PREFIX, receivedFinish);

	TRP3_API.events.listenToEvent(TRP3_API.security.EVENT_SECURITY_CHANGED, function(arg)
		if exchangeFrame:IsVisible() then
			reloadDownloads();
		end
	end);

	TRP3_API.ui.frame.setupMove(exchangeFrame);
end

-- Button on toolbar
TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
	if TRP3_API.target then
		local UnitIsKnown = TRP3_API.register.isUnitKnown;
		local UnitIsIgnored = TRP3_API.register.isIDIgnored;
		local GetUnitIDCharacter = TRP3_API.register.getUnitIDCharacter;
		TRP3_API.target.registerButton({
			id = "aa_player_e_trade",
			onlyForType = TRP3_API.ui.misc.TYPE_CHARACTER,
			configText = loc.IT_EX_TRADE_BUTTON,
			condition = function(_, unitID)
				if UnitIsPlayer("target") and unitID ~= Globals.player_id and not UnitIsIgnored(unitID) then
					if UnitIsKnown("target") then
						local character = GetUnitIDCharacter(Utils.str.getUnitID("target"));
						return (tonumber(character.extended or 0) or 0) > 0;
					end
				end
				return false;
			end,
			onClick = function()
				startEmptyExchangeWithUnit(Utils.str.getUnitID("target"));
			end,
			tooltip = loc.IT_EX_TRADE_BUTTON,
			tooltipSub = loc.IT_EX_TRADE_BUTTON_TT,
			icon = "garrison_building_tradingpost"
		});
	end
end);
