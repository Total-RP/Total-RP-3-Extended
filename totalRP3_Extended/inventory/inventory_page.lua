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
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local EMPTY = TRP3_API.globals.empty;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Slot equipement management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local QUICK_SLOT_ID = TRP3_API.inventory.QUICK_SLOT_ID;

local function resetEquip()
	Model_Reset(TRP3_InventoryPage.Main.Model);
	TRP3_InventoryPage.Main.Equip:Hide();
	TRP3_InventoryPage.Main.Model.Marker:Hide();
	TRP3_InventoryPage.Main.Model.Line:Hide();
end

local function setModelPosition(self, rotation)
	self.rotation = rotation;
	self:SetRotation(self.rotation);
	self:RefreshCamera();
end

local SLOT_MARGIN = 35;
local SLOT_SPACING = 12;

local function drawLine(from)
	TRP3_InventoryPage.Main.Model.Line:Show();
	TRP3_InventoryPage.Main.Model.Line:SetStartPoint("CENTER", from);
	TRP3_InventoryPage.Main.Model.Line:SetEndPoint("CENTER", TRP3_InventoryPage.Main.Model.Marker);
	from:SetFrameLevel(TRP3_InventoryPage.Main.Model:GetFrameLevel() + 5);

	TRP3_InventoryPage.Main.Model.Line:SetVertexColor(0.5, 1, 0.5, 1);
end

local function moveMarker(self, diffX, diffY, oX, oY)
	local width, height = TRP3_InventoryPage.Main.Model:GetWidth() / 2, TRP3_InventoryPage.Main.Model:GetHeight() / 2;
	self:ClearAllPoints();
	self.posX = math.max(-width, math.min(oX + diffX, width));
	self.posY = math.max(-height, math.min(oY + diffY, height));
	self:SetPoint("CENTER", self.posX, self.posY);
end

local function setButtonModelPosition(self)
	if self.info and self.class then
		local isWearable = self.class.BA and self.class.BA.WA;
		if isWearable then
			local pos = self.info.pos or EMPTY;
			setModelPosition(TRP3_InventoryPage.Main.Model, pos.rotation or 0);
			moveMarker(TRP3_InventoryPage.Main.Model.Marker, pos.x or 0, pos.y or 0, 0, 0);
			TRP3_InventoryPage.Main.Model.Marker:Show();
			drawLine(self);
		else
			resetEquip();
		end
	end
end

local function onSlotEnter(self)
	if not TRP3_InventoryPage.Main.Equip:IsVisible() then
		setButtonModelPosition(self);
	end
end

local function onSlotLeave()
	if not TRP3_InventoryPage.Main.Equip:IsVisible() then
--		resetEquip();
	end
end

local function onSlotDrag()
	resetEquip();
end

local function onSlotDoubleClick()
	TRP3_InventoryPage.Main.Equip:Hide();
end

local function onSlotUpdate(self, elapsed)
	if self.info and self.class and self.class.BA.WA then
		self.Locator:Show();
	else
		self.Locator:Hide();
	end
end

local function onLocatorClick(button)
	button = button:GetParent();

	if TRP3_InventoryPage.Main.Equip:IsVisible() and TRP3_InventoryPage.Main.Equip.isOn == button then
		TRP3_InventoryPage.Main.Equip:Hide();
		return;
	end

	if button.info and button.class then
		if not button.class.BA or not button.class.BA.WA then
			TRP3_InventoryPage.Main.Equip:Hide();
			return;
		end
	end

	local position, x, y = "RIGHT", -10, 0;
	if button.slotNumber > 8 then
		position, x, y = "LEFT", 10, 0;
	end
	TRP3_API.ui.frame.configureHoverFrame(TRP3_InventoryPage.Main.Equip, button.Locator, position, x, y);
	TRP3_InventoryPage.Main.Equip.isOn = button;

	setButtonModelPosition(button);
end

local function onEquipRefresh(self)
	-- Camera
	local rotation = TRP3_InventoryPage.Main.Model.rotation;

	self.Camera:SetText(loc("INV_PAGE_CAMERA_CONFIG"):format(rotation));

	local button = TRP3_InventoryPage.Main.Equip.isOn
	if button and button.info then
		local pos =  button.info.pos or {};
		pos.rotation = TRP3_InventoryPage.Main.Model.rotation;
		pos.x = TRP3_InventoryPage.Main.Model.Marker.posX or 0;
		pos.y = TRP3_InventoryPage.Main.Model.Marker.posY or 0;
		button.info.pos = pos;
	end

	-- Marker
	self.Marker:SetText(loc("INV_PAGE_MARKER"));
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Page management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local onInventoryShow;

function onInventoryShow()
	local playerInventory = TRP3_API.inventory.getInventory();
	TRP3_InventoryPage.Main.info = playerInventory;
	TRP3_InventoryPage.Main.Model:SetUnit("player", true);
	resetEquip();

	TRP3_API.inventory.loadContainerPageSlots(TRP3_InventoryPage.Main);
	TRP3_ContainerInvPageSlot17:SetFrameLevel(TRP3_InventoryPage.Main.Model.Blocker:GetFrameLevel() + 1);
end

local function containerFrameUpdate(self, elapsed)
	-- Weight and value
	local current = self.info.totalWeight or 0;
	local weight = TRP3_API.extended.formatWeight(current) .. Utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15);
	local formatedValue = ("%s: %s"):format(loc("INV_PAGE_TOTAL_VALUE"), GetCoinTextureString(self.info.totalValue or 0));
	TRP3_InventoryPage.Main.Model.WeightText:SetText(weight);
	TRP3_InventoryPage.Main.Model.ValueText:SetText(formatedValue);
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
	if TRP3_API.target then
		local playerInvText = loc("INV_PAGE_PLAYER_INV"):format(Globals.player);
		TRP3_API.target.registerButton({
			id = "aa_player_d_inventory",
			onlyForType = TRP3_API.ui.misc.TYPE_CHARACTER,
			configText = loc("INV_PAGE_CHARACTER_INV"),
			condition = function(_, unitID)
				return unitID == Globals.player_id;
			end,
			onClick = function(_, _, buttonType, _)
				onToolbarButtonClicked(buttonType);
			end,
			tooltip = playerInvText,
			tooltipSub = loc("IT_INV_SHOW_CONTENT"),
			icon = "inv_misc_bag_16"
		});
	end
end

function TRP3_API.inventory.initInventoryPage()

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
		onPagePostShow = onInventoryShow
	});

	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		initPlayerInventoryButton();
	end);

	createRefreshOnFrame(TRP3_InventoryPage.Main, 0.15, containerFrameUpdate);
	TRP3_InventoryPage.Main.Model:HookScript("OnUpdate", function(self)
		self:SetSequenceTime(61, 15);
	end);

	-- Create model slots
	TRP3_InventoryPage.Main.lockX = 110;
	TRP3_InventoryPage.Main.slots = {};
	local wearText = loc("INV_PAGE_WEAR_TT") .. "\n\n|cffffff00" .. loc("CM_CLICK") .. ":|r " .. loc("INV_PAGE_WEAR_ACTION");
	for i=1, 17 do
		local button = CreateFrame("Button", "TRP3_ContainerInvPageSlot" .. i, TRP3_InventoryPage.Main, "TRP3_InventoryPageSlotTemplate");
		if i == 1 then
			button:SetPoint("TOPRIGHT", TRP3_InventoryPage.Main.Model, "TOPLEFT", -10, 0);
		elseif i == 9 then
			button:SetPoint("TOPLEFT", TRP3_InventoryPage.Main.Model, "TOPRIGHT", 10, 0);
		elseif i == 17 then
			button:SetPoint("BOTTOMLEFT", TRP3_InventoryPage.Main.Model, "BOTTOMLEFT", 5, 10);
			button.First:SetText(loc("INV_PAGE_QUICK_SLOT"));
			button.Second:SetText(loc("INV_PAGE_QUICK_SLOT_TT"));
			button.Locator:Hide();
		else
			button:SetPoint("TOP", _G["TRP3_ContainerInvPageSlot" .. (i - 1)], "BOTTOM", 0, -11);
		end
		if i <= 8 then
			button.Locator:SetPoint("RIGHT", button, "LEFT", -5, 0);
			setTooltipForSameFrame(button.Locator, "LEFT", 0, 0, loc("INV_PAGE_ITEM_LOCATION"), wearText);
		else
			button.Locator:SetPoint("LEFT", button, "RIGHT", 5, 0);
			setTooltipForSameFrame(button.Locator, "RIGHT", 0, 0, loc("INV_PAGE_ITEM_LOCATION"), wearText);
		end

		tinsert(TRP3_InventoryPage.Main.slots, button);
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
			if not TRP3_InventoryPage.Main.Equip:IsVisible() then
				resetEquip();
			end
		end);
		button.Locator:SetScript("OnClick", onLocatorClick);

		button.additionalOnEnterHandler = onSlotEnter;
		button.additionalOnLeaveHandler = onSlotLeave;
		button.additionalOnDragHandler = onSlotDrag;
		button.additionalDoubleClickHandler = onSlotDoubleClick;
		button.additionalOnUpdateHandler = onSlotUpdate;
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
	TRP3_API.inventory.initContainerInstance(TRP3_InventoryPage.Main, 16);

	-- On profile changed
	local refreshInventory = function()
		if TRP3_API.navigation.page.getCurrentPageID() == "player_inventory" then
			onInventoryShow();
		end
	end
	Events.listenToEvent(Events.REGISTER_PROFILES_LOADED, refreshInventory);

	-- Equip
	TRP3_InventoryPage.Main.Model.defaultRotation = 0;
	TRP3_InventoryPage.Main.Equip.Title:SetText(loc("INV_PAGE_ITEM_LOCATION"));
	createRefreshOnFrame(TRP3_InventoryPage.Main.Equip, 0.15, onEquipRefresh);
	TRP3_InventoryPage.Main.Equip:SetScript("OnShow", function() TRP3_InventoryPage.Main.Model.Blocker:Hide() end);
	TRP3_InventoryPage.Main.Equip:SetScript("OnHide", function() TRP3_InventoryPage.Main.Model.Blocker:Show() end);
	setTooltipForSameFrame(TRP3_InventoryPage.Main.Model.Blocker.ValueHelp, "RIGHT", 0, 0, loc("INV_PAGE_TOTAL_VALUE"), loc("INV_PAGE_TOTAL_VALUE_TT"));

	-- Hide unwanted model adaptation
	TRP3_InventoryPage.Main.Model.controlFrame:SetPoint("TOP", 0, 25);
	TRP3_InventoryPage.Main.Model.controlFrame:SetWidth(55);
	_G[TRP3_InventoryPage.Main.Model.controlFrame:GetName() .. "RotateLeftButton"]:ClearAllPoints();
	_G[TRP3_InventoryPage.Main.Model.controlFrame:GetName() .. "RotateLeftButton"]:SetPoint("Left", 2, 0);
	_G[TRP3_InventoryPage.Main.Model.controlFrame:GetName() .. "ZoomInButton"]:Hide();
	_G[TRP3_InventoryPage.Main.Model.controlFrame:GetName() .. "ZoomOutButton"]:Hide();
	_G[TRP3_InventoryPage.Main.Model.controlFrame:GetName() .. "PanButton"]:Hide();
	local MOVE_SCALE = 1;
	TRP3_InventoryPage.Main.Model.Marker:SetScript("OnMouseUp", function(self)
		local _, _, _, x, y = self:GetPoint("TOPLEFT");
		local diffX = x - self.x;
		local diffY = y - self.y;
		self:StopMovingOrSizing();
		moveMarker(self, diffX * MOVE_SCALE, diffY * MOVE_SCALE, self.origX, self.origY);
	end);
end