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
local Comm = TRP3_API.communication;
local tonumber, assert, strsplit, tostring, wipe, pairs = tonumber, assert, strsplit, tostring, wipe, pairs;
local getClass, isContainerByClassID, isUsableByClass = TRP3_API.extended.getClass, TRP3_API.inventory.isContainerByClassID, TRP3_API.inventory.isUsableByClass;
local isContainerByClass, getItemTextLine = TRP3_API.inventory.isContainerByClass, TRP3_API.inventory.getItemTextLine;
local checkContainerInstance, countItemInstances = TRP3_API.inventory.checkContainerInstance, TRP3_API.inventory.countItemInstances;
local getItemLink = TRP3_API.inventory.getItemLink;
local loc = TRP3_API.locale.getText;
local EMPTY = TRP3_API.globals.empty;
local classExists = TRP3_API.extended.classExists;

local exchangeFrame = TRP3_ExchangeFrame;
local sendCurrentState, sendAcceptExchange, sendCancel;

local UPDATE_EXCHANGE_QUERY_PREFIX = "IEUE";
local CANCEL_EXCHANGE_QUERY_PREFIX = "IECE";
local ACCEPT_EXCHANGE_QUERY_PREFIX = "IEAE";
local DATA_EXCHANGE_QUERY_PREFIX = "IEDE";
local SEND_DATA_QUERY_PREFIX = "IESD";

local SEND_DATE_PRIORITY = "BULK";
local START_EXCHANGE_PRIORITY = "NORMAL";


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function drawUI()
	local myData = exchangeFrame.myData;
	local yourData = exchangeFrame.yourData;

	local atLeastOneBad = false;
	for index, slot in pairs(exchangeFrame.rightSlots) do
		local dataIndex = tostring(index);
		slot:Hide();
		if yourData[dataIndex] then
			local slotData = yourData[dataIndex];
			local rootClassId = slotData.id;
			local rootClassVersion = tonumber(slotData.vn or 0);

			if not classExists(rootClassId) or getClass(rootClassId).MD.V < rootClassVersion then
				atLeastOneBad = true;
			end

			slot.name:SetText(slotData.n or UNKNOWN);
			TRP3_API.ui.frame.setupIconButton(slot, slotData.i or "temp");

			slot:Show();
		end
	end
	exchangeFrame.ok:Enable();
	if atLeastOneBad then
		exchangeFrame.ok:Disable();
	end

	for index, slot in pairs(exchangeFrame.leftSlots) do
		local dataIndex = tostring(index);
		slot:Hide();
		if myData[dataIndex] then
			local slotData = myData[dataIndex];

			slot.name:SetText(slotData.n or UNKNOWN);
			TRP3_API.ui.frame.setupIconButton(slot, slotData.i or "temp");

			slot:Show();
		end
	end

	-- Deco
	SetPortraitTexture(exchangeFrame.leftPortrait, "player");
	SetPortraitToTexture(exchangeFrame.rightPortrait, "Interface\\ICONS\\achievement_reputation_06");

	-- Confirmation overlay
	exchangeFrame.top.leftConfirm:Hide();
	if myData.ok then
		exchangeFrame.top.leftConfirm:Show();
	end
	exchangeFrame.top.rightConfirm:Hide();
	if yourData.ok then
		exchangeFrame.top.rightConfirm:Show();
	end

	-- local formatedValue = GetCoinTextureString(value);

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

local function addToExchange(container, slotID)
	assert(container and slotID, "No container or slotID");
	assert(container.content[slotID], "Can't find slot in container.");

	local slot = container.content[slotID];
	local itemClass = getClass(slot.id);
	local parts = {strsplit(TRP3_API.extended.ID_SEPARATOR, slot.id)};
	local rootClassID = parts[1];
	local rootClass = getClass(rootClassID);

	if TRP3_API.inventory.isContainerByClass(itemClass) and Utils.table.size(slot.content or EMPTY) > 0 then
		Utils.message.displayMessage(ERR_TRADE_BAG, Utils.message.type.ALERT_MESSAGE);
		return;
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

	-- Add item end of list
	local found = false;
	for i=1, 4 do
		local index = tostring(i);
		if not exchangeFrame.myData[index] then
			exchangeFrame.myData[index] = {
				c = {},
				i = itemClass.BA.IC,
				n = getItemLink(itemClass),
				v = itemClass.BA.VA,
				id = rootClassID,
				vn = rootClass.MD.V,
			};
			Utils.table.copy(exchangeFrame.myData[index].c, slot);
			found = true;
			break;
		end
	end
	if not found then
		return;
	end

	exchangeFrame.myData.ok = nil;
	exchangeFrame.yourData.ok = nil;

	drawUI();

	Comm.sendObject(UPDATE_EXCHANGE_QUERY_PREFIX, exchangeFrame.myData, exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
end
TRP3_API.inventory.addToExchange = addToExchange;

local function removeItem(index)
	assert(exchangeFrame.myData, "No exchangeFrame.myData");
	assert(exchangeFrame.myData[tostring(index)], "Slot is already empty");

	wipe(exchangeFrame.myData[tostring(index)]);
	exchangeFrame.myData[tostring(index)] = nil;

	exchangeFrame.myData.ok = nil;
	exchangeFrame.yourData.ok = nil;

	drawUI();
	sendCurrentState();
end

local function cancelExchange()
	if exchangeFrame.myData then
		wipe(exchangeFrame.myData);
	end
	if exchangeFrame.yourData then
		wipe(exchangeFrame.yourData);
	end
	exchangeFrame.myData = nil;
	exchangeFrame.yourData = {};

	if exchangeFrame.targetID then
		sendCancel();
	end

	Utils.message.displayMessage(ERR_TRADE_CANCELLED, Utils.message.type.ALERT_MESSAGE);

	exchangeFrame.targetID = nil;

	exchangeFrame:Hide();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- NETWORKING
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function sendCurrentState()
	assert(exchangeFrame.targetID, "No targetID");
	Comm.sendObject(UPDATE_EXCHANGE_QUERY_PREFIX, exchangeFrame.myData, exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
end

local function sendItemDataRequest(rootClassId, rootClassVersion)
	local reservedMessageID = Comm.getMessageIDAndIncrement();
	local request = {
		id = rootClassId,
		v = rootClassVersion,
		mId = reservedMessageID,
	};

	print("I would like the object " .. rootClassId .. " on the message id " .. reservedMessageID);

	Comm.sendObject(DATA_EXCHANGE_QUERY_PREFIX, request, exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
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

	Comm.sendObject(SEND_DATA_QUERY_PREFIX, response, sender, SEND_DATE_PRIORITY, messageID);
end

local function receivedDataResponse(response, sender)
	local classID = response.id;
	local class = response.class;

	-- Last check that we don't got it in the meantime
	if not classExists(classID) or getClass(classID).MD.V < class.MD.V then
		TRP3_DB.exchange[classID] = class;
		TRP3_API.extended.registerObject(classID, class, 0);
	end

	drawUI();
end

-- Received accept from the other side
local function receivedAccept()
	exchangeFrame.yourData.ok = true;
	drawUI();
end

-- Send accept to the other side
function sendAcceptExchange()
	Comm.sendObject(ACCEPT_EXCHANGE_QUERY_PREFIX, exchangeFrame.myData, exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
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
				sendItemDataRequest(rootClassId, rootClassVersion);
			else
				print("No update needed for " .. rootClassId);
			end
		end
	end

	drawUI();
end

function sendCancel()
	if exchangeFrame.targetID then
		Comm.sendObject(CANCEL_EXCHANGE_QUERY_PREFIX, "", exchangeFrame.targetID, START_EXCHANGE_PRIORITY);
	end
end

local function receivedCancel(_, sender)
	exchangeFrame.targetID = nil;
	cancelExchange();
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
		slot:SetScript("OnClick", function() removeItem(index) end)
	end

	exchangeFrame.cancel:SetText(CANCEL);
	exchangeFrame.cancel:SetScript("OnClick", function() cancelExchange() end);
	exchangeFrame.ok:SetText(TRADE);
	exchangeFrame.ok:SetScript("OnClick", function() confirmExchangeAction() end);

	-- Register prefix for data exchange
	Comm.registerProtocolPrefix(UPDATE_EXCHANGE_QUERY_PREFIX, receivedUpdate);
	Comm.registerProtocolPrefix(CANCEL_EXCHANGE_QUERY_PREFIX, receivedCancel);
	Comm.registerProtocolPrefix(ACCEPT_EXCHANGE_QUERY_PREFIX, receivedAccept);
	Comm.registerProtocolPrefix(DATA_EXCHANGE_QUERY_PREFIX, receivedDataRequest);
	Comm.registerProtocolPrefix(SEND_DATA_QUERY_PREFIX, receivedDataResponse);
end