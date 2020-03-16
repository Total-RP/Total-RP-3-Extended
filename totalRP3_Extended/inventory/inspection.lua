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
local Communications = AddOn_TotalRP3.Communications;
local tinsert, tostring, _G, wipe, pairs, time, tonumber = tinsert, tostring, _G, wipe, pairs, time, tonumber;
local getClass, isContainerByClassID, isUsableByClass = TRP3_API.extended.getClass, TRP3_API.inventory.isContainerByClassID, TRP3_API.inventory.isUsableByClass;
local loc = TRP3_API.loc;
local EMPTY = TRP3_API.globals.empty;
local CreateFrame = CreateFrame;
local parseArgs = TRP3_API.script.parseArgs;

local inspectionFrame = TRP3_InspectionFrame;
local decorateSlot;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- DATA EXCHANGE
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local INSPECTION_REQUEST = "IIRQ";
local INSPECTION_RESPONSE = "IIRS";
local REQUEST_PRIORITY = Communications.PRIORITIES.MEDIUM;
local RESPONSE_PRIORITY = Communications.PRIORITIES.LOW;

local loadingTemplate;

local function receiveResponse(response, sender)
	if sender == inspectionFrame.current then
		-- Weight and value
		local weight = TRP3_API.extended.formatWeight(response.totalWeight or 0) .. Utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15);
		local formatedValue = ("%s: %s"):format(loc.INV_PAGE_TOTAL_VALUE, GetCoinTextureString(response.totalValue or 0));
		inspectionFrame.Main.Model.WeightText:SetText(weight);
		inspectionFrame.Main.Model.ValueText:SetText(formatedValue);
		inspectionFrame.Main.Model.WeightText:Show();
		inspectionFrame.Main.Model.ValueText:Show();

		for _, button in pairs(inspectionFrame.Main.slots) do
			local slotInfo = (response.slots or EMPTY)[button.slotID];
			if slotInfo then
				button.info = {
					count = slotInfo.count,
					id = slotInfo.id,
					noAlt = true,
					pos = slotInfo.pos
				};
				button.class = {
					BA = slotInfo.BA,
					CO = slotInfo.CO,
					US = slotInfo.US,
				};
			end
		end
	end
end

local function receiveRequest(request, sender)
	local reservedMessageID = request[1];
	local playerInventory = TRP3_API.inventory.getInventory();

	local response = {
		totalWeight = playerInventory.totalWeight,
		totalValue = playerInventory.totalValue,
		slots = {},
	};
	for slotID, slot in pairs(playerInventory.content or EMPTY) do
		-- Don't send the default bag
		if slotID ~= "17" then
			local class = getClass(slot.id);
			local slotInfo = { object = slot };

			-- Parsing arguments in the item info
			local parsedBA = {};
			Utils.table.copy(parsedBA, class.BA);
			parsedBA.RI = parseArgs(parsedBA.RI, slotInfo);
			parsedBA.LE = parseArgs(parsedBA.LE, slotInfo);
			parsedBA.DE = parseArgs(parsedBA.DE, slotInfo);

			response.slots[slotID] = {
				count = slot.count,
				id = slot.id,
				BA = parsedBA,
				pos = slot.pos,
			};
			if isContainerByClassID(slot.id) then
				response.slots[slotID].CO = class.CO;
			end
			if isUsableByClass(class) then
				-- Parsing arguments in the use text
				local parsedUS = {};
				Utils.table.copy(parsedUS, class.US);
				parsedUS.AC = parseArgs(parsedUS.AC, slotInfo);

				response.slots[slotID].US = parsedUS;
			end
		end
	end

	Communications.sendObject(INSPECTION_RESPONSE, response, sender, RESPONSE_PRIORITY, reservedMessageID);
end

local function sendRequest()
	local reservedMessageID = Communications.getNewMessageToken();
	local data = {reservedMessageID};
	inspectionFrame.time = time();
	inspectionFrame.Main.Model.Loading:SetText("... " .. loc.INV_PAGE_WAIT .. " ...");
	Communications.registerMessageTokenProgressHandler(reservedMessageID, inspectionFrame.current, function(_, total, current)
		inspectionFrame.Main.Model.Loading:SetText(loadingTemplate:format(current / total * 100));
		if current == total then
			inspectionFrame.Main.Model.Loading:Hide();
		end
	end);
	Communications.sendObject(INSPECTION_REQUEST, data, inspectionFrame.current, REQUEST_PRIORITY);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onSlotEnter(self)
	TRP3_API.inventory.setWearableConfiguration(self, nil, inspectionFrame);
end

local function onSlotLeave()
	TRP3_API.inventory.resetWearable(inspectionFrame.Main, inspectionFrame.Main.Model);
end

local function onToolbarButtonClicked()
	local unitID = Utils.str.getUnitID("target");
	if unitID and (inspectionFrame.current ~= unitID or not inspectionFrame:IsVisible()) then
		inspectionFrame.current = unitID

		for _, slot in pairs(inspectionFrame.Main.slots) do
			if slot.info then
				wipe(slot.info);
				slot.info = nil;
			end
			if slot.class then
				slot.class = nil;
			end
		end

		inspectionFrame.Main.Model:SetUnit("target");
		inspectionFrame.Main.Model.Title:SetText(UnitName("target"));
		inspectionFrame.Main.Model.WeightText:Hide();
		inspectionFrame.Main.Model.ValueText:Hide();
		inspectionFrame.Main.Model.Loading:Show();
		inspectionFrame.Main.Model.Loading:SetText(loadingTemplate:format(0));
		inspectionFrame:Show();
		TRP3_API.inventory.resetWearable(inspectionFrame.Main, inspectionFrame.Main.Model);

		sendRequest();
	end
end

function inspectionFrame.init()

	loadingTemplate = loc.INV_PAGE_CHARACTER_INSPECTION .. ": %0.2f %%";

	-- Slots
	Mixin(inspectionFrame.Main.Model, ModelFrameMixin);
	inspectionFrame.Main.Model:OnLoad(nil, nil, 0);
	inspectionFrame.Main.slots = {};
	for i=1, 16 do
		local button = CreateFrame("Button", "TRP3_InspectionFrameSlot" .. i, inspectionFrame.Main, "TRP3_InventoryPageSlotTemplate");
		button.Locator:Hide();
		if i == 1 then
			button:SetPoint("TOPRIGHT", inspectionFrame.Main.Model, "TOPLEFT", -10, 4);
		elseif i == 9 then
			button:SetPoint("TOPLEFT", inspectionFrame.Main.Model, "TOPRIGHT", 12, 4);
		else
			button:SetPoint("TOP", _G["TRP3_InspectionFrameSlot" .. (i - 1)], "BOTTOM", 0, -11);
		end
		tinsert(inspectionFrame.Main.slots, button);
		button.slotNumber = i;
		button.slotID = tostring(i);

		button.additionalOnEnterHandler = onSlotEnter;
		button.additionalOnLeaveHandler = onSlotLeave;

		if i > 8 then
			button.tooltipRight = true;
		end

		TRP3_API.inventory.initContainerSlot(button, nil, function() end);
	end
	TRP3_API.inventory.initContainerInstance(inspectionFrame.Main, 16);

	inspectionFrame.Main.Model.setAnimation = function(self, sequence, sequenceTime)
		if sequence then
			self:FreezeAnimation(sequence, 0, sequenceTime);
		end
	end

	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		inspectionFrame:Hide();
		if TRP3_API.target then
			TRP3_API.target.registerButton({
				id = "aa_player_e_inspect",
				onlyForType = TRP3_API.ui.misc.TYPE_CHARACTER,
				configText = loc.INV_PAGE_CHARACTER_INSPECTION,
				condition = function(_, unitID)
					if UnitIsPlayer("target") and unitID ~= Globals.player_id and not TRP3_API.register.isIDIgnored(unitID) then
						if TRP3_API.register.isUnitKnown("target") then
							local character = TRP3_API.register.getUnitIDCharacter(Utils.str.getUnitID("target"));
							return (tonumber(character.extended or 0) or 0) > 0;
						end
					end
					return false;
				end,
				onClick = function(_, _, buttonType, _)
					onToolbarButtonClicked();
				end,
				tooltip = loc.INV_PAGE_CHARACTER_INSPECTION,
				tooltipSub = loc.INV_PAGE_CHARACTER_INSPECTION_TT,
				icon = "inv_helmet_66"
			});
		end
	end);

	-- Register prefix for data exchange
	Communications.registerSubSystemPrefix(INSPECTION_REQUEST, receiveRequest);
	Communications.registerSubSystemPrefix(INSPECTION_RESPONSE, receiveResponse);

	TRP3_API.ui.frame.setupMove(inspectionFrame);
end
