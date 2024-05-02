-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local Globals, Events, Utils = TRP3_API.globals, TRP3_Addon.Events, TRP3_API.utils;
local _G, tostring, tinsert, wipe = _G, tostring, tinsert, wipe;
local createRefreshOnFrame = TRP3_API.ui.frame.createRefreshOnFrame;
local CreateFrame, IsAltKeyDown = CreateFrame, IsAltKeyDown;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local EMPTY = TRP3_API.globals.empty;

local inventoryModel, mainInventoryFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Slot equipement management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local QUICK_SLOT_ID = TRP3_API.inventory.QUICK_SLOT_ID;
local DEFAULT_SEQUENCE = 193;
local DEFAULT_TIME = 1;

local function resetEquip(main, model)
	if not main then main = mainInventoryFrame end;
	if not model then model = inventoryModel end;
	if main.Equip then
		main.Equip:Hide();
	end
	model.Marker:Hide();
	model.Line:Hide();
	model.sequence = nil;
end
TRP3_API.inventory.resetWearable = resetEquip;

local function setModelPosition(self, rotation)
	self.rotation = rotation;
	self:SetRotation(self.rotation);
	self:RefreshCamera();
end

local function drawLine(from, quality, model)
	model.Line:Show();
	model.Line:SetStartPoint("CENTER", from);
	model.Line:SetEndPoint("CENTER", model.Marker);
	from:SetFrameLevel(model:GetFrameLevel() + 5);
	local r, g, b = TRP3_API.inventory.getQualityColorRGB(quality);
	model.Line:SetVertexColor(r, g, b, 1);
end

local function moveMarker(self, diffX, diffY, oX, oY, quality, frame)
	local model = frame or inventoryModel;
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
	local main = (frame and frame.Main) or mainInventoryFrame;
	local model = (frame and frame.Main.Model) or inventoryModel;

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
	if not mainInventoryFrame.Equip:IsVisible() then
		setButtonModelPosition(self);
	end
end

local function onSlotLeave()
	if not mainInventoryFrame.Equip:IsVisible() then
		resetEquip();
	end
end

local function onSlotDrag()
	resetEquip();
end

local function onSlotDoubleClick()
	mainInventoryFrame.Equip:Hide();
end

local function onSlotUpdate(self)
	if self.info and self.class and self.class.BA.WA then
		self.Locator:Show();
	else
		self.Locator:Hide();
	end
end

local function onLocatorClick(button, mode)
	button = button:GetParent();

	if mode == "LeftButton" then
		if mainInventoryFrame.Equip:IsVisible() and mainInventoryFrame.Equip.isOn == button then
			mainInventoryFrame.Equip:Hide();
			return;
		end

		if button.info and button.class then
			if not button.class.BA or not button.class.BA.WA then
				mainInventoryFrame.Equip:Hide();
				return;
			end
		end

		local position, x, y = "RIGHT", -10, 0;
		if button.slotNumber > 8 then
			position, x, y = "LEFT", 10, 0;
		end
		TRP3_API.ui.frame.configureHoverFrame(mainInventoryFrame.Equip, button.Locator, position, x, y);
		mainInventoryFrame.Equip.isOn = button;

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
	local rotation = inventoryModel.rotation;
	self.Camera:SetText(loc.INV_PAGE_CAMERA_CONFIG:format(rotation));

	local button = mainInventoryFrame.Equip.isOn
	if button and button.info then
		local pos =  button.info.pos or {};
		pos.rotation = inventoryModel.rotation;
		pos.x = inventoryModel.Marker.posX or 0;
		pos.y = inventoryModel.Marker.posY or 0;
		pos.sequenceTime = inventoryModel.sequenceTime or DEFAULT_TIME;
		pos.sequence = inventoryModel.sequence or DEFAULT_SEQUENCE;
		button.info.pos = pos;
	end

	-- Marker
	local x = inventoryModel.Marker.posX or 0;
	local y = inventoryModel.Marker.posY or 0;
	self.Marker:SetText(loc.INV_PAGE_MARKER:format(x, y));
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Quick add / create / import
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onSlotClickAction(action, slot)
	local slotID = slot.slotID;
	if action == 1 then
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = mainInventoryFrame, point = "CENTER", parentPoint = "CENTER"}, {function(fromID)
			TRP3_API.popup.showNumberInputPopup(loc.DB_ADD_COUNT:format(TRP3_API.inventory.getItemLink(TRP3_API.extended.getClass(fromID))), function(value)
				local class = TRP3_API.extended.getClass(fromID);
				TRP3_API.inventory.addItem(TRP3_API.inventory.getInventory(), fromID, {count = value or 1, madeBy = class.BA and class.BA.CR}, nil, slotID);
			end, nil, 1);
		end, TRP3_DB.types.ITEM, true});
	elseif action == 2 then
		TRP3_API.extended.tools.openItemQuickEditor(mainInventoryFrame, function(classID, _)
			local class = TRP3_API.extended.getClass(classID);
			TRP3_API.inventory.addItem(TRP3_API.inventory.getInventory(), classID, {count = 1, madeBy = class.BA and class.BA.CR}, nil, slotID);
		end, nil, true);
	end
end

local function onSlotClick(slot, button)
	if TRP3_ToolFrame then
		if not slot.info and button == "RightButton" then
			TRP3_MenuUtil.CreateContextMenu(slot, function(_, description)
				description:CreateTitle(loc.INV_PAGE_CHARACTER_INV);

				description:CreateButton(loc.EFFECT_ITEM_ADD, function() onSlotClickAction(1, slot); end);
				description:CreateButton(loc.DB_CREATE_ITEM, function() onSlotClickAction(2, slot); end);
			end);
		elseif button == "LeftButton" and IsAltKeyDown() and slot.info then
			if TRP3_API.extended.isObjectMine(slot.info.id) then
				if (TRP3_API.extended.getClass(slot.info.id).MD or EMPTY).MO == TRP3_DB.modes.QUICK then
					TRP3_API.extended.tools.openItemQuickEditor(mainInventoryFrame, nil, slot.info.id, true);
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
	mainInventoryFrame.info = playerInventory;
	inventoryModel:InspectUnit("player", true);
	resetEquip();

	TRP3_API.inventory.loadContainerPageSlots(mainInventoryFrame);
	TRP3_ContainerInvPageSlot17:SetFrameLevel(inventoryModel.Blocker:GetFrameLevel() + 1);

	-- A bit of a hack, this ensures that we get a TOPLEFT point for the marker during its MouseUp script.
	TRP3_MainFrame:StartMoving();
	TRP3_MainFrame:StopMovingOrSizing();
end

local function containerFrameUpdate(self)
	-- Weight and value
	local current = self.info.totalWeight or 0;
	local weight = TRP3_API.extended.formatWeight(current) .. Utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15);
	local formatedValue = ("%s: %s"):format(loc.INV_PAGE_TOTAL_VALUE, C_CurrencyInfo.GetCoinTextureString(self.info.totalValue or 0));
	inventoryModel.WeightText:SetText(weight);
	inventoryModel.ValueText:SetText(formatedValue);
end

function TRP3_API.inventory.openMainContainer()
	local playerInventory = TRP3_API.inventory.getInventory();
	local quickSlot = playerInventory.content[QUICK_SLOT_ID];
	if quickSlot and quickSlot.id and TRP3_API.inventory.isContainerByClassID(quickSlot.id) then
		TRP3_API.inventory.switchContainerBySlotID(playerInventory, QUICK_SLOT_ID);
	end
end

local function onToolbarButtonClicked(buttonType)
	if buttonType == "LeftButton" then
		TRP3_API.inventory.openMainContainer();
		return;
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
			tooltipSub = TRP3_API.FormatShortcutWithInstruction("LCLICK", loc.BINDING_NAME_TRP3_MAIN_CONTAINER)  .. "\n"  .. TRP3_API.FormatShortcutWithInstruction("RCLICK", loc.INV_PAGE_INV_OPEN),
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
				allPoints = mainInventoryFrame.slots[1]
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
				allPoints = mainInventoryFrame.slots[17]
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
				allPoints = mainInventoryFrame.slots[12]
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
				allPoints = mainInventoryFrame.slots[15]
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

	inventoryModel, mainInventoryFrame = TRP3_InventoryPage.Main.Model, TRP3_InventoryPage.Main;

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

	TRP3_API.RegisterCallback(TRP3_Addon, TRP3_Addon.Events.WORKFLOW_ON_LOADED, function()
		initPlayerInventoryButton();
	end);

	createRefreshOnFrame(mainInventoryFrame, 0.15, containerFrameUpdate);
	inventoryModel.setAnimation = function(self, sequence, sequenceTime)
		if sequence then
			self:FreezeAnimation(sequence, 0, sequenceTime or DEFAULT_TIME);
		end
	end

	-- Create model slots
	mainInventoryFrame.lockX = 110;
	mainInventoryFrame.slots = {};
	local wearText = loc.INV_PAGE_WEAR_TT
			.. "\n\n|cffffff00" .. loc.CM_CLICK .. ":|r " .. loc.INV_PAGE_WEAR_ACTION
			.. "\n|cffffff00" .. loc.CM_R_CLICK .. ":|r " .. loc.INV_PAGE_WEAR_ACTION_RESET;
	for i=1, 17 do
		local button = CreateFrame("Button", "TRP3_ContainerInvPageSlot" .. i, mainInventoryFrame, "TRP3_InventoryPageSlotTemplate");
		if i == 1 then
			button:SetPoint("TOPRIGHT", inventoryModel, "TOPLEFT", -15, 0);
		elseif i == 9 then
			button:SetPoint("TOPLEFT", inventoryModel, "TOPRIGHT", 15, 0);
		elseif i == 17 then
			button:SetPoint("BOTTOMLEFT", inventoryModel, "BOTTOMLEFT", 5, 10);
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

		tinsert(mainInventoryFrame.slots, button);
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
	TRP3_API.inventory.initContainerInstance(mainInventoryFrame, 16);

	-- On profile changed
	local refreshInventory = function()
		if TRP3_API.navigation.page.getCurrentPageID() == "player_inventory" then
			onInventoryShow();
		end
	end
	TRP3_API.RegisterCallback(TRP3_Addon, Events.REGISTER_PROFILES_LOADED, refreshInventory);

	-- Equip
	inventoryModel.defaultRotation = 0;
	mainInventoryFrame.Equip.Title:SetText(loc.INV_PAGE_ITEM_LOCATION);
	createRefreshOnFrame(mainInventoryFrame.Equip, 0.15, onEquipRefresh);
	mainInventoryFrame.Equip:SetScript("OnShow", function() inventoryModel.Blocker:Hide() end);
	mainInventoryFrame.Equip:SetScript("OnHide", function() inventoryModel.Blocker:Show() end);
	setTooltipForSameFrame(inventoryModel.Blocker.ValueHelp, "RIGHT", 0, 0, loc.INV_PAGE_TOTAL_VALUE, loc.INV_PAGE_TOTAL_VALUE_TT);

	-- Hide unwanted model adaptation -- TODO: fix this
	--inventoryModel.controlFrame:SetPoint("TOP", 0, 25);
	--inventoryModel.controlFrame:SetWidth(55);
	--_G[inventoryModel.controlFrame:GetName() .. "RotateLeftButton"]:ClearAllPoints();
	--_G[inventoryModel.controlFrame:GetName() .. "RotateLeftButton"]:SetPoint("Left", 2, 0);
	--_G[inventoryModel.controlFrame:GetName() .. "ZoomInButton"]:Hide();
	--_G[inventoryModel.controlFrame:GetName() .. "ZoomOutButton"]:Hide();
	--_G[inventoryModel.controlFrame:GetName() .. "PanButton"]:Hide();
	local MOVE_SCALE = 1;
	inventoryModel.Marker:SetScript("OnMouseUp", function(self)
		local _, _, _, x, y = self:GetPoint(1);
		local diffX = x - self.x;
		local diffY = y - self.y;
		self:StopMovingOrSizing();
		moveMarker(self, diffX * MOVE_SCALE, diffY * MOVE_SCALE, self.origX, self.origY, inventoryModel);
	end);

	mainInventoryFrame.Equip.time:SetScript("OnValueChanged", function(self)
		inventoryModel.sequenceTime = self:GetValue();
		inventoryModel:setAnimation(inventoryModel.sequence, inventoryModel.sequenceTime);
	end);
	local onChange = function(self)
		inventoryModel.sequence = tonumber(self:GetText()) or DEFAULT_SEQUENCE;
		inventoryModel:setAnimation(inventoryModel.sequence, inventoryModel.sequenceTime);
	end;
	mainInventoryFrame.Equip.sequence:SetScript("OnTextChanged", onChange);
	mainInventoryFrame.Equip.sequence:SetScript("OnEnterPressed", onChange);
	mainInventoryFrame.Equip.sequence.title:SetText(loc.INV_PAGE_SEQUENCE);
	setTooltipForSameFrame(mainInventoryFrame.Equip.sequence.help, "RIGHT", 0, 5, loc.INV_PAGE_SEQUENCE, loc.INV_PAGE_SEQUENCE_TT);

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

	mainInventoryFrame.Equip.preset:SetScript("OnClick", function(self)
		TRP3_MenuUtil.CreateContextMenu(self, function(_, description)
			for _, presetCategory in pairs(presets) do
				local presetCat = description:CreateButton(presetCategory[1]);
				for _, preset in pairs(presetCategory[2]) do
					presetCat:CreateButton(preset[1], function() mainInventoryFrame.Equip.sequence:SetText(preset[2] or ""); end);
				end
			end
		end);
	end);
	setTooltipForSameFrame(mainInventoryFrame.Equip.preset, "RIGHT", 0, 5, loc.INV_PAGE_SEQUENCE, loc.INV_PAGE_SEQUENCE_PRESET);

	createTutorialStructure();
end
