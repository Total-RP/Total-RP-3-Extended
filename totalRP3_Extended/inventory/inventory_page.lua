----------------------------------------------------------------------------------
-- Total RP 3: Inventory page
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
local _G, assert, tostring, tinsert, wipe, pairs = _G, assert, tostring, tinsert, wipe, pairs;
local createRefreshOnFrame = TRP3_API.ui.frame.createRefreshOnFrame;
local CreateFrame, ToggleFrame, MouseIsOver, IsAltKeyDown = CreateFrame, ToggleFrame, MouseIsOver, IsAltKeyDown;
local TRP3_ItemTooltip = TRP3_ItemTooltip;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local EMPTY = TRP3_API.globals.empty;

local model, main;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Slot equipement management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local QUICK_SLOT_ID = TRP3_API.inventory.QUICK_SLOT_ID;
local DEFAULT_SEQUENCE = 193;
local DEFAULT_TIME = 1;

local function resetEquip(Main, Model)
	local main = Main or main;
	local model = Model or model;
	model:ResetModel();
	if main.Equip then
		main.Equip:Hide();
	end
	model.Marker:Hide();
	model.Line:Hide();
	model.sequence = nil;
	model:SetAnimation(0, 0);
end
TRP3_API.inventory.resetWearable = resetEquip;

local function setModelPosition(self, rotation)
	self.rotation = rotation;
	self:SetRotation(self.rotation);
	self:RefreshCamera();
end

local SLOT_MARGIN = 35;
local SLOT_SPACING = 12;

local function drawLine(from, quality, model)
	model.Line:Show();
	model.Line:SetStartPoint("CENTER", from);
	model.Line:SetEndPoint("CENTER", model.Marker);
	from:SetFrameLevel(model:GetFrameLevel() + 5);
	local r, g, b = TRP3_API.inventory.getQualityColorRGB(quality);
	model.Line:SetVertexColor(r, g, b, 1);
end

local function moveMarker(self, diffX, diffY, oX, oY, quality, frame)
	local model = frame or model;
	local width, height = model:GetWidth() / 2, model:GetHeight() / 2;
	self:ClearAllPoints();
	self.posX = math.max(-width, math.min(oX + diffX, width));
	self.posY = math.max(-height, math.min(oY + diffY, height));
	self:SetPoint("CENTER", self.posX, self.posY);
	local r, g, b = TRP3_API.inventory.getQualityColorRGB(quality);
	self.dot:SetVertexColor(r, g, b, 1);
	self.halo:SetVertexColor(r, g, b, 0.3);
end

local function setButtonModelPosition(self, force, frame)
	local main = (frame and frame.Main) or main;
	local model = (frame and frame.Main.Model) or model;

	if self.info and self.class then
		local isWearable = self.class.BA and self.class.BA.WA;
		local quality = self.class.BA and self.class.BA.QA;
		local pos = self.info.pos;
		if isWearable and (pos or force) then
			pos = pos or EMPTY;
			model.sequence = pos.sequence or DEFAULT_SEQUENCE;
			model.sequenceTime = pos.sequenceTime or DEFAULT_TIME;
			model:setAnimation(model.sequence, model.sequenceTime);
			setModelPosition(model, pos.rotation or 0);
			moveMarker(model.Marker, pos.x or 0, pos.y or 0, 0, 0, quality, model);
			if main.Equip then
				main.Equip.sequence:SetText(model.sequence);
				main.Equip.time:SetValue(model.sequenceTime);
			end
			model.Marker:Show();
			drawLine(self, quality, model);
		else
			resetEquip(main, model);
		end
	end
end
TRP3_API.inventory.setWearableConfiguration = setButtonModelPosition;

local function onSlotEnter(self)
	if not main.Equip:IsVisible() then
		setButtonModelPosition(self);
	end
end

local function onSlotLeave()
	if not main.Equip:IsVisible() then
		resetEquip();
	end
end

local function onSlotDrag()
	resetEquip();
end

local function onSlotDoubleClick()
	main.Equip:Hide();
end

local function onSlotUpdate(self, elapsed)
	if self.info and self.class and self.class.BA.WA then
		self.Locator:Show();
	else
		self.Locator:Hide();
	end
end

local function onLocatorClick(button, mode)
	button = button:GetParent();

	if mode == "LeftButton" then
		if main.Equip:IsVisible() and main.Equip.isOn == button then
			main.Equip:Hide();
			return;
		end

		if button.info and button.class then
			if not button.class.BA or not button.class.BA.WA then
				main.Equip:Hide();
				return;
			end
		end

		local position, x, y = "RIGHT", -10, 0;
		if button.slotNumber > 8 then
			position, x, y = "LEFT", 10, 0;
		end
		TRP3_API.ui.frame.configureHoverFrame(main.Equip, button.Locator, position, x, y);
		main.Equip.isOn = button;

		setButtonModelPosition(button, true);
	else
		if button.info and button.class and button.info.pos then
			wipe(button.info.pos);
			button.info.pos = nil;
		end
		resetEquip();
		setButtonModelPosition(button);
	end

end

local function onEquipRefresh(self)
	-- Camera
	local rotation = model.rotation;
	self.Camera:SetText(loc.INV_PAGE_CAMERA_CONFIG:format(rotation));

	local button = main.Equip.isOn
	if button and button.info then
		local pos =  button.info.pos or {};
		pos.rotation = model.rotation;
		pos.x = model.Marker.posX or 0;
		pos.y = model.Marker.posY or 0;
		pos.sequenceTime = model.sequenceTime or DEFAULT_TIME;
		pos.sequence = model.sequence or DEFAULT_SEQUENCE;
		button.info.pos = pos;
	end

	-- Marker
	local x = model.Marker.posX or 0;
	local y = model.Marker.posY or 0;
	self.Marker:SetText(loc.INV_PAGE_MARKER:format(x, y));
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Quick add / create / import
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onSlotClickAction(action, slot)
	local slotID = slot.slotID;
	if action == 1 then
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = main, point = "CENTER", parentPoint = "CENTER"}, {function(fromID)
			TRP3_API.popup.showNumberInputPopup(loc.DB_ADD_COUNT:format(TRP3_API.inventory.getItemLink(TRP3_API.extended.getClass(fromID))), function(value)
				local class = TRP3_API.extended.getClass(fromID);
				TRP3_API.inventory.addItem(TRP3_API.inventory.getInventory(), fromID, {count = value or 1, madeBy = class.BA and class.BA.CR}, nil, slotID);
			end, nil, 1);
		end, TRP3_DB.types.ITEM, true});
	elseif action == 2 then
		TRP3_API.extended.tools.openItemQuickEditor(main, function(classID, _)
			local class = TRP3_API.extended.getClass(classID);
			TRP3_API.inventory.addItem(TRP3_API.inventory.getInventory(), classID, {count = 1, madeBy = class.BA and class.BA.CR}, nil, slotID);
		end, nil, true);
	end
end

local function onSlotClick(slot, button)
	if TRP3_ToolFrame then
		if not slot.info and button == "RightButton" then
			local menu = {
				{loc.INV_PAGE_CHARACTER_INV},
				{loc.EFFECT_ITEM_ADD, 1},
				{loc.DB_CREATE_ITEM, 2},
				--			{loc.DB_IMPORT_ITEM, 3}
			};
			TRP3_API.ui.listbox.displayDropDown(slot, menu, onSlotClickAction, 0, true);
		elseif button == "LeftButton" and IsAltKeyDown() and slot.info then
			if TRP3_API.extended.isObjectMine(slot.info.id) then
				if (TRP3_API.extended.getClass(slot.info.id).MD or EMPTY).MO == TRP3_DB.modes.QUICK then
					TRP3_API.extended.tools.openItemQuickEditor(main, nil, slot.info.id, true);
				else
					Utils.message.displayMessage(loc.INV_PAGE_EDIT_ERROR2, 4);
				end
			else
				Utils.message.displayMessage(loc.INV_PAGE_EDIT_ERROR1, 4);
			end
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Page management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local onInventoryShow;

function onInventoryShow()
	local playerInventory = TRP3_API.inventory.getInventory();
	main.info = playerInventory;
	model:SetUnit("player", true);
	resetEquip();

	TRP3_API.inventory.loadContainerPageSlots(main);
	TRP3_ContainerInvPageSlot17:SetFrameLevel(model.Blocker:GetFrameLevel() + 1);
end

local function containerFrameUpdate(self, elapsed)
	-- Weight and value
	local current = self.info.totalWeight or 0;
	local weight = TRP3_API.extended.formatWeight(current) .. Utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15);
	local formatedValue = ("%s: %s"):format(loc.INV_PAGE_TOTAL_VALUE, GetCoinTextureString(self.info.totalValue or 0));
	model.WeightText:SetText(weight);
	model.ValueText:SetText(formatedValue);
end

local function onToolbarButtonClicked(buttonType)
	if buttonType == "LeftButton" then
		local playerInventory = TRP3_API.inventory.getInventory();
		local quickSlot = playerInventory.content[QUICK_SLOT_ID];
		if quickSlot and quickSlot.id and TRP3_API.inventory.isContainerByClassID(quickSlot.id) then
			TRP3_API.inventory.switchContainerBySlotID(playerInventory, QUICK_SLOT_ID);
			return;
		end
	end
	TRP3_API.navigation.openMainFrame();
	TRP3_API.navigation.menu.selectMenu("main_13_player_inventory");
end

local function initPlayerInventoryButton()
	local playerInvText = loc.INV_PAGE_PLAYER_INV:format(Globals.player);
	if TRP3_API.toolbar then
		local toolbarButton = {
			id = "hh_player_d_inventory",
			configText = loc.INV_PAGE_CHARACTER_INV,
			tooltip = playerInvText,
			tooltipSub = loc.IT_INV_SHOW_CONTENT,
			icon = "inv_misc_bag_16",
			onClick = function(_, _, buttonType, _)
				onToolbarButtonClicked(buttonType);
			end,
		};
		TRP3_API.toolbar.toolbarAddButton(toolbarButton);
	end
end

-- Tutorial
local TUTORIAL_STRUCTURE;

local function createTutorialStructure()
	TUTORIAL_STRUCTURE = {
		{
			box = {
				allPoints = main.slots[1]
			},
			button = {
				x = 0, y = 0, anchor = "CENTER",
				text = loc.INV_TU_1,
				textWidth = 400,
				arrow = "RIGHT"
			}
		},
		{
			box = {
				allPoints = main.slots[17]
			},
			button = {
				x = 0, y = 0, anchor = "CENTER",
				text = loc.INV_TU_2,
				textWidth = 400,
				arrow = "LEFT"
			}
		},
		{
			box = {
				x = 0, y = 0, anchor = "CENTER", width = 200, height = 275
			},
			button = {
				x = 50, y = 0, anchor = "CENTER",
				text = loc.INV_TU_3,
				textWidth = 400,
				arrow = "RIGHT"
			}
		},
		{
			box = {
				allPoints = main.slots[12]
			},
			button = {
				x = 0, y = 0, anchor = "CENTER",
				text = loc.INV_TU_4,
				textWidth = 400,
				arrow = "LEFT"
			}
		},
		{
			box = {
				allPoints = main.slots[15]
			},
			button = {
				x = 0, y = 0, anchor = "CENTER",
				text = loc.INV_TU_5_V2,
				textWidth = 400,
				arrow = "LEFT"
			}
		},
	}
end

function TRP3_API.inventory.initInventoryPage()

	model, main = TRP3_InventoryPage.Main.Model, TRP3_InventoryPage.Main;

	TRP3_API.navigation.menu.registerMenu({
		id = "main_13_player_inventory",
		text = INVENTORY_TOOLTIP,
		onSelected = function()
			TRP3_API.navigation.page.setPage("player_inventory");
		end,
		isChildOf = "main_10_player",
	});

	TRP3_API.navigation.page.registerPage({
		id = "player_inventory",
		frame = TRP3_InventoryPage,
		onPagePostShow = onInventoryShow,
		tutorialProvider = function() return TUTORIAL_STRUCTURE; end,
	});

	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		initPlayerInventoryButton();
	end);

	createRefreshOnFrame(main, 0.15, containerFrameUpdate);
	model.setAnimation = function(self, sequence, sequenceTime)
		if sequence then
			self:FreezeAnimation(sequence, 0, sequenceTime or DEFAULT_TIME);
		end
	end

	-- Create model slots
	main.lockX = 110;
	main.slots = {};
	local wearText = loc.INV_PAGE_WEAR_TT
			.. "\n\n|cffffff00" .. loc.CM_CLICK .. ":|r " .. loc.INV_PAGE_WEAR_ACTION
			.. "\n|cffffff00" .. loc.CM_R_CLICK .. ":|r " .. loc.INV_PAGE_WEAR_ACTION_RESET;
	for i=1, 17 do
		local button = CreateFrame("Button", "TRP3_ContainerInvPageSlot" .. i, main, "TRP3_InventoryPageSlotTemplate");
		if i == 1 then
			button:SetPoint("TOPRIGHT", model, "TOPLEFT", -15, 0);
		elseif i == 9 then
			button:SetPoint("TOPLEFT", model, "TOPRIGHT", 15, 0);
		elseif i == 17 then
			button:SetPoint("BOTTOMLEFT", model, "BOTTOMLEFT", 5, 10);
			button.First:SetText(loc.INV_PAGE_QUICK_SLOT);
			button.Second:SetText(loc.INV_PAGE_QUICK_SLOT_TT);
			button.Locator:Hide();
		else
			button:SetPoint("TOP", _G["TRP3_ContainerInvPageSlot" .. (i - 1)], "BOTTOM", 0, -11);
		end
		if i <= 8 then
			button.Locator:SetPoint("RIGHT", button, "LEFT", -5, 0);
			setTooltipForSameFrame(button.Locator, "LEFT", 0, 0, loc.INV_PAGE_ITEM_LOCATION, wearText);
		else
			button.Locator:SetPoint("LEFT", button, "RIGHT", 5, 0);
			setTooltipForSameFrame(button.Locator, "RIGHT", 0, 0, loc.INV_PAGE_ITEM_LOCATION, wearText);
		end

		tinsert(main.slots, button);
		button.slotNumber = i;
		button.slotID = tostring(i);
		TRP3_API.inventory.initContainerSlot(button);

		button.Locator:SetScript("OnEnter", function(self)
			TRP3_RefreshTooltipForFrame(self);
			onSlotEnter(self:GetParent());
		end);
		button.Locator:SetScript("OnLeave", function(self)
			TRP3_MainTooltip:Hide();
			onSlotLeave(self:GetParent());
		end);
		button.Locator:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		button.Locator:SetScript("OnClick", onLocatorClick);

		button.additionalOnEnterHandler = onSlotEnter;
		button.additionalOnLeaveHandler = onSlotLeave;
		button.additionalOnDragHandler = onSlotDrag;
		button.additionalDoubleClickHandler = onSlotDoubleClick;
		button.additionalOnUpdateHandler = onSlotUpdate;
		button.additionalClickHandler = onSlotClick;

		button.First:ClearAllPoints();
		if i > 8 then
			button.tooltipRight = true;
			button.First:SetPoint("TOPLEFT", button, "TOPRIGHT", 5, -5);
			button.First:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 5, 15);
			button.First:SetPoint("RIGHT", TRP3_InventoryPage, "RIGHT", -15, 0);
			button.First:SetJustifyH("LEFT");
			button.Second:SetPoint("TOPLEFT", button, "TOPRIGHT", 5, -10);
			button.Second:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 5, -10);
			button.Second:SetPoint("RIGHT", TRP3_InventoryPage, "RIGHT", -15, 0);
			button.Second:SetJustifyH("LEFT");
		else
			button.First:SetPoint("TOPRIGHT", button, "TOPLEFT", -5, -5);
			button.First:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", -5, 15);
			button.First:SetPoint("LEFT", TRP3_InventoryPage, "LEFT", 15, 0);
			button.First:SetJustifyH("RIGHT");
			button.Second:SetPoint("TOPRIGHT", button, "TOPLEFT", -5, -10);
			button.Second:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", -5, -10);
			button.Second:SetPoint("LEFT", TRP3_InventoryPage, "LEFT", 15, 0);
			button.Second:SetJustifyH("RIGHT");
		end
	end
	TRP3_API.inventory.initContainerInstance(main, 16);

	-- On profile changed
	local refreshInventory = function()
		if TRP3_API.navigation.page.getCurrentPageID() == "player_inventory" then
			onInventoryShow();
		end
	end
	Events.listenToEvent(Events.REGISTER_PROFILES_LOADED, refreshInventory);

	-- Equip
	model.defaultRotation = 0;
	main.Equip.Title:SetText(loc.INV_PAGE_ITEM_LOCATION);
	createRefreshOnFrame(main.Equip, 0.15, onEquipRefresh);
	main.Equip:SetScript("OnShow", function() model.Blocker:Hide() end);
	main.Equip:SetScript("OnHide", function() model.Blocker:Show() end);
	setTooltipForSameFrame(model.Blocker.ValueHelp, "RIGHT", 0, 0, loc.INV_PAGE_TOTAL_VALUE, loc.INV_PAGE_TOTAL_VALUE_TT);

	-- Hide unwanted model adaptation
	model.controlFrame:SetPoint("TOP", 0, 25);
	model.controlFrame:SetWidth(55);
	_G[model.controlFrame:GetName() .. "RotateLeftButton"]:ClearAllPoints();
	_G[model.controlFrame:GetName() .. "RotateLeftButton"]:SetPoint("Left", 2, 0);
	_G[model.controlFrame:GetName() .. "ZoomInButton"]:Hide();
	_G[model.controlFrame:GetName() .. "ZoomOutButton"]:Hide();
	_G[model.controlFrame:GetName() .. "PanButton"]:Hide();
	local MOVE_SCALE = 1;
	model.Marker:SetScript("OnMouseUp", function(self)
		local _, _, _, x, y = self:GetPoint("TOPLEFT");
		local diffX = x - self.x;
		local diffY = y - self.y;
		self:StopMovingOrSizing();
		moveMarker(self, diffX * MOVE_SCALE, diffY * MOVE_SCALE, self.origX, self.origY, model);
	end);

	main.Equip.time:SetScript("OnValueChanged", function(self)
		model.sequenceTime = self:GetValue();
		model:setAnimation(model.sequence, model.sequenceTime);
	end);
	local onChange = function(self)
		model.sequence = tonumber(self:GetText()) or DEFAULT_SEQUENCE;
		model:setAnimation(model.sequence, model.sequenceTime);
	end;
	main.Equip.sequence:SetScript("OnTextChanged", onChange);
	main.Equip.sequence:SetScript("OnEnterPressed", onChange);
	main.Equip.sequence.title:SetText(loc.INV_PAGE_SEQUENCE);
	setTooltipForSameFrame(main.Equip.sequence.help, "RIGHT", 0, 5, loc.INV_PAGE_SEQUENCE, loc.INV_PAGE_SEQUENCE_TT);

	-- Preset
	local presets = {
		{"A - M", {
			{"/acclame", 68},
			{"/applause", 80},
			{"/beg", 79},
			{"/bow", 66},
			{"/chicken", 78},
			{"/classypose", 29},
			{"/cry", 77},
			{"/drunk", 14},
			{"/drown", 132},
			{"/fear", 225},
			{"/flex", 82},
			{"/hi", 67},
			{"/kiss", 76},
			{"/lol", 70},
		}},
		{"N - Z", {
			{"/point", 84},
			{"/pickup", 50},
			{"/roar", 55},
			{"/rude", 73},
			{"/run", 5},
			{"/salute", 113},
			{"/sit", 97},
			{"/shout", 81},
			{"/shy", 83},
			{"/sneaky", 120},
			{"/talk", 60},
			{"/train", 195},
			{"/use", 63},
			{"/walk", 4},
			{"/workworkwork", 62},
			{"/!", 64},
			{"/?", 65},
		}},
	};
	main.Equip.preset:SetScript("OnClick", function(self)
		TRP3_API.ui.listbox.displayDropDown(self, presets, function(value)
			main.Equip.sequence:SetText(value or "");
		end, 0, true);
	end);
	setTooltipForSameFrame(main.Equip.preset, "RIGHT", 0, 5, loc.INV_PAGE_SEQUENCE, loc.INV_PAGE_SEQUENCE_PRESET);

	createTutorialStructure();
end