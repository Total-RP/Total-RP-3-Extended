-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local Globals, Events, Utils = TRP3_API.globals, TRP3_Addon.Events, TRP3_API.utils;
local _G, tostring, tinsert, wipe = _G, tostring, tinsert, wipe;
local CreateRefreshOnFrame = TRP3_API.ui.frame.createRefreshOnFrame;
local CreateFrame, IsAltKeyDown = CreateFrame, IsAltKeyDown;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local EMPTY = TRP3_API.globals.empty;

local inventoryModel, mainInventoryFrame;

local DEFAULT_SEQUENCE = 193;
local DEFAULT_TIME = 1;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Slot equipment management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local QUICK_SLOT_ID = TRP3_API.inventory.QUICK_SLOT_ID;
local REFRESH_INTERVAL = 0.15;

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

local function onSlotDrag()
	resetEquip();
end

local function onSlotDoubleClick()
	mainInventoryFrame.Equip:Hide();
end

local function onSlotUpdate(self)
	if self.CurrentInventory and self.class and self.class.BA.WA then
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

-- Tutorial
local TUTORIAL_STRUCTURE;

local function CreateTutorialStructure()
	TUTORIAL_STRUCTURE = {
		{
			box = {
				allPoints = mainInventoryFrame.InventorySlots[1]
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
				allPoints = mainInventoryFrame.InventorySlots[17]
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
				allPoints = mainInventoryFrame.InventorySlots[12]
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
				allPoints = mainInventoryFrame.InventorySlots[15]
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

	inventoryModel, mainInventoryFrame = TRP3_InventoryPage.Model, TRP3_InventoryPage;

	TRP3_InventoryPage:Init();
	if 1 == 2 then
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
	end

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
end

------------

local SLOTS_PER_COLUMN = 8;

TRP3_InventoryPageMixin = {};

function TRP3_InventoryPageMixin:OnLoad()
	TRP3_API.RegisterCallback(TRP3_Addon, Events.WORKFLOW_ON_LOADED, function()
		self:AddPlayerInventoryButton();
	end);

	TRP3_API.RegisterCallback(TRP3_Addon, Events.REGISTER_PROFILES_LOADED, function()
		self:OnProfileChanged();
	end);
end

function TRP3_InventoryPageMixin:OnShow()
	local playerInventory = TRP3_API.inventory.getInventory();
	self.CurrentInventory = playerInventory;
	self.Model:InspectUnit("player", true);
	self:ResetModel();
	self:LoadInventorySlots();

	local alwaysStartFromMouse = true;
	TRP3_MainFrame:StartMoving(alwaysStartFromMouse);
	TRP3_MainFrame:StopMovingOrSizing();
end

-- called from TRP3_API.inventory.onStart when the module loads
function TRP3_InventoryPageMixin:Init()
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
		frame = self,
		onPagePostShow = function() self:OnShow() end;
		tutorialProvider = function() return TUTORIAL_STRUCTURE; end,
	});

	self:CreateInventorySlots();
	CreateTutorialStructure(); -- tutorials depend on the inv slots being created

	CreateRefreshOnFrame(self, REFRESH_INTERVAL, function() self:UpdateInventory(); end);
end

function TRP3_InventoryPageMixin:ResetModel()
	local model = self.Model;
	model.Marker:Hide();
	model.Line:Hide();
	model:ResetModel();
end

function TRP3_InventoryPageMixin:CreateInventorySlots()
	if self.InventorySlots and #self.InventorySlots > 0 then
		return; -- already created slots, man
	end

	local function CreateSlot(parent, side)
		local slot = CreateFrame("Button", nil, parent, "TRP3_InventoryPageSlotTemplate");
		slot:Init(side);
		return slot;
	end

	self.InventorySlots = {};
	local invLeft, invRight = self.InventoryLeft, self.InventoryRight;
	invLeft.spacing, invRight.spacing = 5, 5;
	for i=1, SLOTS_PER_COLUMN do
		-- passing the 'side' along too so the slot knows how to position it's friends
		local slotL = CreateSlot(invLeft, 0);
		slotL.layoutIndex = i;
		slotL.bottomPadding = 4;

		local slotR = CreateSlot(invRight, 1);
		slotR.layoutIndex = i;
		slotR.bottomPadding = 4;
		TRP3_API.inventory.initContainerSlot(slotR);

		tinsert(self.InventorySlots, i, slotL);
		tinsert(self.InventorySlots, i + SLOTS_PER_COLUMN, slotR);
	end
	invLeft:MarkDirty();
	invRight:MarkDirty();
end

function TRP3_InventoryPageMixin:LoadInventorySlots()
	if not self.CurrentInventory then
		return;
	end

	local content = self.CurrentInventory.content or EMPTY;
	for i, slot in ipairs(self.InventorySlots) do
		local slotContent = content[tostring(i)]; -- fatcatdespair
		if slotContent then
			slot.info = slotContent;
			slot.class = TRP3_API.extended.getClass(slotContent.id);
		else
			slot.info, slot.class = nil, nil;
		end
		TRP3_API.inventory.containerSlotUpdate(slot);
	end
end

function TRP3_InventoryPageMixin:UpdateInventory()
	local currentWeight = self.CurrentInventory.totalWeight or 0;
	local weight = TRP3_API.extended.formatWeight(currentWeight) .. Utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15);
	local formatedValue = ("%s: %s"):format(loc.INV_PAGE_TOTAL_VALUE, C_CurrencyInfo.GetCoinTextureString(self.CurrentInventory.totalValue or 0));
	self.Model.WeightText:SetText(weight);
	self.Model.ValueText:SetText(formatedValue);
end

function TRP3_InventoryPageMixin:OnToolbarButtonClicked(buttonName)
	if buttonName == "LeftButton" then
		return TRP3_API.inventory.openMainContainer();
	end
	TRP3_API.navigation.openMainFrame();
	TRP3_API.navigation.menu.selectMenu("main_13_player_inventory");
end

function TRP3_InventoryPageMixin:OnProfileChanged()
	if TRP3_API.navigation.page.getCurrentPageID() == "player_inventory" then
		self:OnShow();
	end
end

function TRP3_InventoryPageMixin:AddPlayerInventoryButton()
	local text = loc.INV_PAGE_PLAYER_INV:format(Globals.player);
	local toolbarButton = {
		id = "hh_player_d_inventory",
		configText = loc.INV_PAGE_CHARACTER_INV,
		tooltip = text,
		tooltipSub = TRP3_API.FormatShortcutWithInstruction("LCLICK", loc.BINDING_NAME_TRP3_MAIN_CONTAINER)  .. "\n"  .. TRP3_API.FormatShortcutWithInstruction("RCLICK", loc.INV_PAGE_INV_OPEN),
		icon = "inv_misc_bag_16",
		onClick = function(_, _, buttonName, _)
			self:OnToolbarButtonClicked(buttonName);
		end,
	};
	TRP3_API.toolbar.toolbarAddButton(toolbarButton);
end

function TRP3_InventoryPageMixin:DrawItemLocationLine(slot, quality)
    local model = self.Model;
    local line = model.Line;
    line:SetStartPoint("CENTER", slot);
    line:SetEndPoint("CENTER", model.Marker);
    slot:SetFrameLevel(model:GetFrameLevel() + 5); -- TODO: investigate?
    local r, g, b = TRP3_API.inventory.getQualityColorRGB(quality);
    line:SetVertexColor(r, g, b, 1);
    line:Show();
end

function TRP3_InventoryPageMixin:ShowItemPosition(slot)
	if slot.info and slot.class then
        local pos = slot.info.pos or EMPTY;
		local quality = slot.class.BA and slot.class.BA.QA;
		if slot:ShouldShowItemLocation() and pos then
            self.Model:ShowItemPosition(slot);
			self:DrawItemLocationLine(slot, quality);
		else
			self:ResetModel();
		end
	end
end

function TRP3_InventoryPageMixin:ResetMarker()
	local marker = self.Model.Marker;
	marker:SetPoint("CENTER", self.Model, "CENTER", 0, 0);
end

function TRP3_InventoryPageMixin:SetActiveSlot(slot)
	self.ActiveSlot = slot;
	if not slot then
		self:ClearActiveSlot();
		return;
	end

	self.Model.Blocker:Hide();
	self:ShowItemPosition(self.ActiveSlot);
end

function TRP3_InventoryPageMixin:ClearActiveSlot()
	self.ActiveSlot = nil;
	self.Model.Blocker:Show();
	self:ResetModel();
end

function TRP3_InventoryPageMixin:GetActiveSlot()
	return self.ActiveSlot;
end

function TRP3_InventoryPageMixin:IsActiveSlot(slot)
	return self.ActiveSlot == slot;
end

function TRP3_InventoryPageMixin:PreviewSlot(slot)
	self:ShowItemPosition(slot);
end

function TRP3_InventoryPageMixin:ClearPreview()
	self:ResetModel();
end

------------
-- public api

-- TODO: TRP3_API.inventory.setWearableConfiguration fell during battle to collateral damage, will investigate revival

function TRP3_API.inventory.resetWearable()
	TRP3_InventoryPage:ResetModel();
end;

function TRP3_API.inventory.openMainContainer()
	local playerInventory = TRP3_API.inventory.getInventory();
	local quickSlot = playerInventory.content[QUICK_SLOT_ID];
	if quickSlot and quickSlot.id and TRP3_API.inventory.isContainerByClassID(quickSlot.id) then
		TRP3_API.inventory.switchContainerBySlotID(playerInventory, QUICK_SLOT_ID);
	end
end