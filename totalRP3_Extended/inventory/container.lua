----------------------------------------------------------------------------------
-- Total RP 3
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--	Copyright 2018 Morgane "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
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

local _, Private_TRP3E = ...;

---@type SecuredMacroCommandsEnclave
local SecuredMacroCommandsEnclave = Private_TRP3E.SecuredMacroCommandsEnclave

local Ellyb = TRP3_API.Ellyb;

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local _G, assert, tostring, tinsert, wipe, pairs, time = _G, assert, tostring, tinsert, wipe, pairs, time;
local CreateFrame, ToggleFrame, MouseIsOver, IsAltKeyDown, GetMouseFocus = CreateFrame, ToggleFrame, MouseIsOver, IsAltKeyDown, GetMouseFocus;
local createRefreshOnFrame = TRP3_API.ui.frame.createRefreshOnFrame;
local loc = TRP3_API.loc;
local Log = Utils.log;
local getBaseClassDataSafe, isContainerByClass, isUsableByClass = TRP3_API.inventory.getBaseClassDataSafe, TRP3_API.inventory.isContainerByClass, TRP3_API.inventory.isUsableByClass;
local getClass, isContainerByClassID = TRP3_API.extended.getClass, TRP3_API.inventory.isContainerByClassID;
local getQualityColorRGB, getQualityColorText = TRP3_API.inventory.getQualityColorRGB, TRP3_API.inventory.getQualityColorText;
local EMPTY = TRP3_API.globals.empty;
local color = Utils.str.color;
local getItemLink = TRP3_API.inventory.getItemLink;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Slot management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local lootFrame;
local containerInstances = {};
local loadContainerPageSlots;
local switchContainerByRef, isContainerInstanceOpen, highlightContainerInstance;

local function incrementLine(line)
	if line:len() > 0 then
		line = line .. "\n";
	end
	return line;
end

local function incrementLineIfFirst(first, line)
	if first then
		first = false;
		line = line .. "\n";
	end
	return first, line;
end

local function parseArgs(text, info)
	return TRP3_API.script.parseArgs(text, info);
end

local function getItemTooltipLines(slotInfo, class, forceAlt)
	local title, left, right, text1, text1_lower, text2,  extension1, extension2;
	local icon, name = getBaseClassDataSafe(class);
	local rootClassID = TRP3_API.extended.getRootClassID(slotInfo.id);
	local rootClass = TRP3_API.extended.classExists(rootClassID) and getClass(rootClassID);
	local argsStructure = {object = slotInfo};
	title = getQualityColorText(class.BA.QA) .. name;

	if class.BA.LE then
		left = TRP3_API.Ellyb.ColorManager.WHITE(parseArgs(class.BA.LE, argsStructure));
	end
	if class.BA.RI then
		right = TRP3_API.Ellyb.ColorManager.WHITE(parseArgs(class.BA.RI, argsStructure));
	end

	text1 = "";
	if class.BA.QE then
		text1 = TRP3_API.Ellyb.ColorManager.WHITE(ITEM_BIND_QUEST);
	end
	if class.BA.SB then
		text1 = incrementLine(text1);
		text1 = text1 .. TRP3_API.Ellyb.ColorManager.WHITE(ITEM_SOULBOUND);
	end
	if isContainerByClass(class) then
		local slotCount = (class.CO.SR or 5) * (class.CO.SC or 4);
		local slotUsed = TRP3_API.inventory.countUsedSlot(class, slotInfo);
		text1 = incrementLine(text1);
		text1 = text1 .. TRP3_API.Ellyb.ColorManager.WHITE(loc.IT_CON_TT:format(slotUsed, slotCount));
	end
	if class.BA.UN and class.BA.UN > 0 then
		text1 = incrementLine(text1);
		text1 = text1 .. TRP3_API.Ellyb.ColorManager.WHITE(ITEM_UNIQUE .. " (" .. class.BA.UN .. ")");
	end

	if class.BA.DE and class.BA.DE:len() > 0 then
		text1 = incrementLine(text1);
		text1 = text1 .. "|r" .. "\"" .. parseArgs(class.BA.DE, argsStructure) .. "\"";		-- no color as it is the default color for that part of the tooltip
	end

	text1_lower = "";
	if class.US and class.US.AC then
		text1_lower = text1_lower .. USE .. ": " .. parseArgs(class.US.AC, argsStructure);	-- no color as it is the default color for that part of the tooltip
	end

	if class.BA.CO then
		text1_lower = incrementLine(text1_lower);
		text1_lower = text1_lower .. TRP3_API.Ellyb.ColorManager.CRAFTING_REAGENT(PROFESSIONS_USED_IN_COOKING);
	end

	if class.BA.CR and slotInfo.madeBy then
		text1_lower = incrementLine(text1_lower);
		text1_lower = text1_lower .. ITEM_CREATED_BY:format(TRP3_API.register.getUnitRPNameWithID(slotInfo.madeBy));
	end

	if not slotInfo.noAlt and (IsAltKeyDown() or forceAlt) then

		extension1 = "";
		local weight = slotInfo.totalWeight or ((slotInfo.count or 1) * (class.BA.WE or 0));
		local formatedWeight = TRP3_API.extended.formatWeight(weight);
		extension1 = extension1 .. Utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15) .. " " .. TRP3_API.Ellyb.ColorManager.WHITE(formatedWeight);

		if (class.BA.VA or 0) > 0 or (isContainerByClass(class) and (slotInfo.totalValue or 0) > 0) then
			extension2 = "";
			local value;
			if isContainerByClass(class) and slotInfo.totalValue then
				value = slotInfo.totalValue;
			else
				value = (class.BA.VA or 0) * (slotInfo.count or 1);
			end
			value = GetCoinTextureString(value);
			extension2 = extension2 .. TRP3_API.Ellyb.ColorManager.WHITE(value);

		end

		text2 = "";

		if not forceAlt then
			if isUsableByClass(class) then
				text2 = text2 .. "\n";
				text2 = text2 .. Ellyb.Strings.clickInstruction(Ellyb.System.CLICKS.RIGHT_CLICK, USE);
			end

			if isContainerByClass(class) then
				text2 = text2 .. "\n";
				text2 = text2 .. Ellyb.Strings.clickInstruction(Ellyb.System.CLICKS.DOUBLE_CLICK, loc.IT_CON_OPEN);
			end
			text2 = text2 .. "\n";
			text2 = text2 .. Ellyb.Strings.clickInstruction(Ellyb.System:FormatKeyboardShortcut(Ellyb.System.MODIFIERS.SHIFT, Ellyb.System.CLICKS.CLICK), loc.CL_TOOLTIP);

			if class.missing then
				text2 = text2 .. "\n";
				text2 = text2 .. TRP3_API.Ellyb.ColorManager.YELLOW(loc.IT_CON_TT_MISSING_CLASS .. ":|cffff9900 " .. slotInfo.id);
			else
				if TRP3_DB.exchange[rootClassID] or TRP3_DB.my[rootClassID] then
					text2 = text2 .. "\n";
					text2 = text2 .. Ellyb.Strings.clickInstruction(Ellyb.System:FormatKeyboardShortcut(Ellyb.System.MODIFIERS.ALT, Ellyb.System.CLICKS.RIGHT_CLICK), loc.SEC_TT_COMBO_2);
				end
				if TRP3_DB.exchange[rootClassID] and TRP3_API.security.atLeastOneBlocked(rootClassID) then
					text2 = text2 .. "\n\n";
					text2 = text2 .. loc.SET_TT_SECURED_2;
					text2 = text2 .. "\n" .. Ellyb.Strings.clickInstruction(Ellyb.System:FormatKeyboardShortcut(Ellyb.System.MODIFIERS.ALT, Ellyb.System.CLICKS.RIGHT_CLICK), loc.SET_TT_SECURED_2_1);
				end
				if not rootClass.MD.tV or rootClass.MD.tV < Globals.extended_version then
					text2 = text2 .. "\n\n";
					text2 = text2 .. TRP3_API.Ellyb.ColorManager.ORANGE(loc.SET_TT_OLD:format(TRP3_API.extended.tools.getClassVersion(rootClass)));
				end
			end
		end
	else
		local alertCount = 0;
		if class.missing then
			alertCount = alertCount + 1;
		else
			if TRP3_DB.exchange[rootClassID] and TRP3_API.security.atLeastOneBlocked(rootClassID) then
				alertCount = alertCount + 1;
			end
		end
		if alertCount > 0 then
			extension1 = TRP3_API.Ellyb.ColorManager.YELLOW(loc.SET_TT_DETAILS_2:format(alertCount));
			extension2 = TRP3_API.Ellyb.ColorManager.YELLOW(loc.SET_TT_DETAILS_1);
		end
	end

	return title, left, right, text1, text1_lower, text2, extension1, extension2;
end

local TRP3_ItemTooltip = TRP3_ItemTooltip;
local function showItemTooltip(frame, slotInfo, itemClass, forceAlt, anchor)
	TRP3_ItemTooltip:Hide();
	TRP3_ItemTooltip:SetOwner(frame, anchor or (frame.tooltipRight and "ANCHOR_RIGHT") or "ANCHOR_LEFT", 0, 0);

	local title, left, right, text1, text1_lower, text2,  extension1, extension2 = getItemTooltipLines(slotInfo, itemClass, forceAlt);

	local i = 1;
	if title and title:len() > 0 then
		local r, g, b = TRP3_API.Ellyb.ColorManager.WHITE:GetRGB();
		TRP3_ItemTooltip:AddLine(title, r, g, b,true);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetFontObject(GameFontNormalLarge);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if (left and left:len() > 0) or (right and right:len() > 0) then
		local r, g, b = TRP3_API.Ellyb.ColorManager.WHITE:GetRGB();
		TRP3_ItemTooltip:AddDoubleLine(left or "", right or "", r, g, b, r, g, b);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetFontObject(GameFontNormal);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		_G["TRP3_ItemTooltipTextRight"..i]:SetFontObject(GameFontNormal);
		_G["TRP3_ItemTooltipTextRight"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if text1 and text1:len() > 0 then
		local r, g, b = TRP3_API.Ellyb.ColorManager.ORANGE:GetRGB();	-- corresponds to color("o") = FFAA00 for the description
		TRP3_ItemTooltip:AddLine(text1, r, g, b,true);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetFontObject(GameFontNormal);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetSpacing(2);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if text1_lower and text1_lower:len() > 0 then
		local r, g, b = TRP3_API.Ellyb.ColorManager.GREEN:GetRGB();	-- corresponds to color("g") = 00FF00 for the use text
		TRP3_ItemTooltip:AddLine(text1_lower, r, g, b,true);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetFontObject(GameFontNormal);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetSpacing(2);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if (extension1 and extension1:len() > 0) or (extension2 and extension2:len() > 0) then
		local r, g, b = TRP3_API.Ellyb.ColorManager.WHITE:GetRGB();
		TRP3_ItemTooltip:AddDoubleLine(extension1 or "", extension2 or "", r, g, b, r, g, b);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetFontObject(GameFontNormal);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		_G["TRP3_ItemTooltipTextRight"..i]:SetFontObject(GameFontNormal);
		_G["TRP3_ItemTooltipTextRight"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if text2 and text2:len() > 0 then
		local r, g, b = TRP3_API.Ellyb.ColorManager.WHITE:GetRGB();
		TRP3_ItemTooltip:AddLine(text2, r, g, b,true);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetFontObject(GameFontNormalSmall);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetSpacing(2);
		_G["TRP3_ItemTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	TRP3_ItemTooltip.ref = frame;
	TRP3_ItemTooltip:Show();
end
TRP3_API.inventory.showItemTooltip = showItemTooltip;

local function containerSlotUpdate(self, elapsed)
	self.Quest:Hide();
	self.Container:Hide();
	self.Icon:Hide();
	self.Quantity:Hide();
	self.Cooldown:Hide();
	self.IconBorder:Hide();
	self.Icon:SetVertexColor(1, 1, 1);
	self.IconBorder:SetVertexColor(1, 1, 1);
	self.Icon:SetDesaturated(false);
	if self.info then
		local class = self.class;
		local icon, name = getBaseClassDataSafe(class);
		self.Icon:Show();
		self.Icon:SetTexture("Interface\\ICONS\\" .. icon);
		if class.BA and class.BA.QE then
			self.Quest:Show();
		end
		if class.BA and class.BA.QA and class.BA.QA ~= 1 then
			self.IconBorder:Show();
			local r, g, b = getQualityColorRGB(class.BA.QA);
			self.IconBorder:SetVertexColor(r, g, b);
		end
		if self.info.count and self.info.count > 1 then
			self.Quantity:Show();
			self.Quantity:SetText(self.info.count);
		end
		if GetMouseFocus() == self then
			showItemTooltip(self, self.info, self.class);
		end
		if isContainerByClass(self.class) and isContainerInstanceOpen(self.info) then
			self.Icon:SetVertexColor(0.85, 0.85, 0.85);
			self.Container:Show();
		end
		if self:IsDragging() or TRP3_API.inventory.isInTransaction(self.info) or self:GetParent().sync then
			self.Icon:SetDesaturated(true);
		end
		if self.info.cooldown then
			if time() >= self.info.cooldown then
				self.info.cooldown = nil;
			else
				self.Cooldown:Show();
				self.Cooldown:SetText(self.info.cooldown - time());
				self.Icon:SetVertexColor(1, 0, 0);
			end
		end
	end
	if self.additionalOnUpdateHandler then
		self.additionalOnUpdateHandler(self, elapsed);
	end
end
TRP3_API.inventory.containerSlotUpdate = containerSlotUpdate;

local function slotOnEnter(self)
	if self.info then
		TRP3_ItemTooltip.ref = self;
		showItemTooltip(self, self.info, self.class);
		if isContainerByClass(self.class) and isContainerInstanceOpen(self.info) then
			highlightContainerInstance(self.info);
		end
		if self.additionalOnEnterHandler then
			self.additionalOnEnterHandler(self);
		end
	end
end

local function slotOnLeave(self)
	TRP3_ItemTooltip.ref = nil;
	TRP3_ItemTooltip:Hide();
	highlightContainerInstance(nil);
	if self.additionalOnLeaveHandler then
		self.additionalOnLeaveHandler(self);
	end
end

local function slotOnDragStart(self)
	if self.info and not TRP3_API.inventory.isInTransaction(self.info) then
		StackSplitFrame:Hide();
		SetCursor("Interface\\ICONS\\" .. ((self.class and self.class.BA.IC) or "inv_misc_questionmark")) ;
		if self.additionalOnDragHandler then
			self.additionalOnDragHandler(self);
		end
		if self.class then
			TRP3_API.ui.misc.playSoundKit(self.class.BA.PS or 1186, "SFX");
		end
	end
end

local function doPickUpLoot(slotFrom, containerTo, slotIDTo, itemCount)
	assert(slotFrom.info, "No info from origin loot");
	assert(slotFrom:GetParent().info.loot, "Origin container is not a loot");
	slotFrom.info.count = slotFrom.info.count or 1;
	local containerFromFrame = slotFrom:GetParent();

	local lootInfo = {};
	Utils.table.copy(lootInfo, slotFrom.info);
	lootInfo.count = itemCount;

	local returnCode, count = TRP3_API.inventory.addItem(containerTo, lootInfo.id, lootInfo, nil, slotIDTo);

	slotFrom.info.count = slotFrom.info.count - count;

	if slotFrom.info.count <= 0 then
		slotFrom.info = nil;
		slotFrom.class = nil;
	end

	if containerFromFrame.onLootCallback then
		containerFromFrame.onLootCallback(slotFrom.info, count, slotFrom);
	end

	TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG, containerTo);

	if not containerFromFrame.info.stash then
		for index, slot in pairs(lootFrame.slots) do
			if slot.info then
				return;
			end
		end
		lootFrame.forceLoot = nil;
		TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_LOOT_ALL);
		lootFrame:Hide();
	end
end

local function pickUpLoot(slotFrom, container, slotID)
	assert(slotFrom.info, "No info from origin loot");
	assert(slotFrom:GetParent().info.loot, "Origin container is not a loot");
	slotFrom.info.count = slotFrom.info.count or 1;

	local lootInfo = slotFrom.info;
	local itemID = lootInfo.id;
	local itemCount = slotFrom.info.count;

	if itemCount == 1 then
		doPickUpLoot(slotFrom, container, slotID, itemCount);
	else
		TRP3_API.popup.showNumberInputPopup(loc.DB_ADD_COUNT:format(TRP3_API.inventory.getItemLink(TRP3_API.extended.getClass(itemID))), function(value)
			value = math.min(value or 1, itemCount);
			if slotFrom and slotFrom.info and value > 0 and value <= itemCount then
				doPickUpLoot(slotFrom, container, slotID, value or 1);
			end
		end, nil, itemCount);
	end
end

local function discardLoot(slotFrom, containerFrame)
	assert(slotFrom.info, "No info from origin loot");
	assert(slotFrom:GetParent().info.loot, "Origin container is not a loot");
	local lootInfo = slotFrom.info;

	Utils.message.displayMessage(loc.DR_DELETED:format(getItemLink(slotFrom.class), lootInfo.count or 1));

	lootInfo.count = 0;

	slotFrom.info = nil;
	slotFrom.class = nil;

	if containerFrame.onDiscardCallback then
		containerFrame.onDiscardCallback(lootInfo, slotFrom);
	end

	if containerFrame.info and not containerFrame.info.stash then
		for index, slot in pairs(containerFrame.slots) do
			if slot.info then
				return;
			end
		end
		containerFrame.forceLoot = nil;
		TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_LOOT_ALL);
		containerFrame:Hide();
	end
end

local UnitExists, CheckInteractDistance, UnitIsPlayer = UnitExists, CheckInteractDistance, UnitIsPlayer;

local function slotOnDragStop(slotFrom)
	ResetCursor();
	if slotFrom.info and not TRP3_API.inventory.isInTransaction(slotFrom.info) then
		local slotTo = GetMouseFocus();
		local container1, slot1ID;
		slot1ID = slotFrom.slotID;
		container1 = slotFrom:GetParent().info;

		local class = getClass(slotFrom.info.id);
		if class then
			TRP3_API.ui.misc.playSoundKit(class.BA.DS or 1203, "SFX");
		end
		if slotTo:GetName() == "WorldFrame" then
			if not slotFrom.loot then
				if UnitExists("mouseover") and UnitIsPlayer("mouseover") and CheckInteractDistance("mouseover", 2) then
					if class and not class.BA.SB then
						TRP3_API.inventory.addToExchange(container1, slot1ID);
					else
						Utils.message.displayMessage(ERR_TRADE_BOUND_ITEM, Utils.message.type.ALERT_MESSAGE);
					end
				else
					local itemClass = getClass(slotFrom.info.id);
					local itemLink = getItemLink(itemClass);

					TRP3_API.inventory.dropOrDestroy(itemClass, function()
						TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_ON_SLOT_REMOVE, container1, slot1ID, slotFrom.info, true);
					end, function()
						TRP3_API.inventory.dropItem(container1, slot1ID, slotFrom.info);
					end);
				end
			else
				if slotFrom.deletable then
					TRP3_API.popup.showConfirmPopup(loc.DR_POPUP_REMOVE_TEXT, function()
						discardLoot(slotFrom, slotFrom:GetParent());
					end);
				else
					Utils.message.displayMessage(loc.IT_INV_ERROR_CANT_DESTROY_LOOT, Utils.message.type.ALERT_MESSAGE);
				end
			end
		elseif slotTo:GetName() and slotTo:GetName():sub(1, ("TRP3_ExchangeFrame"):len()) == "TRP3_ExchangeFrame" then
			if not container1.loot then
				TRP3_API.inventory.addToExchange(container1, slot1ID);
			end
		elseif slotTo:GetName() and slotTo:GetName():sub(1, 14) == "TRP3_Container" and slotTo.slotID then
			if TRP3_API.inventory.isInTransaction(slotTo.info or EMPTY) then
				return;
			end
			local container2, slot2ID;
			slot2ID = slotTo.slotID;
			container2 = slotTo:GetParent().info;
			if not container1.loot then
				TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_ON_SLOT_SWAP, container1, slot1ID, container2, slot2ID);
			elseif slotFrom:GetParent() == TRP3_StashContainer and TRP3_StashContainer.sharedData then
				if not slotFrom:GetParent().sync then
					TRP3_API.inventory.unstashSlot(slotFrom, container2, slot2ID);
				else
					Utils.message.displayMessage(loc.DR_STASHES_ERROR_SYNC, 4);
				end
			elseif not container2.loot then
				pickUpLoot(slotFrom, container2, slot2ID);
			end
		elseif slotTo:GetName() and slotTo:GetName():sub(1, 19) == "TRP3_StashContainer" then
			if not container1.loot then
				TRP3_API.inventory.stashSlot(slotFrom, container1, slot1ID);
			end
		else
			Utils.message.displayMessage(loc.IT_INV_ERROR_CANT_HERE, Utils.message.type.ALERT_MESSAGE);
		end
	end
end

local function slotOnDragReceive(self)

end

local function splitStack(slot, quantity)
	if slot and slot.info and slot:GetParent().info then
		TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_SPLIT_SLOT, slot.info, slot:GetParent().info, quantity);
	end
end

local IsShiftKeyDown, IsControlKeyDown = IsShiftKeyDown, IsControlKeyDown;
local COLUMN_SPACING = 43;
local ROW_SPACING = 42;
local CONTAINER_SLOT_UPDATE_FREQUENCY = 0.15;
TRP3_API.inventory.CONTAINER_SLOT_UPDATE_FREQUENCY = CONTAINER_SLOT_UPDATE_FREQUENCY;

local function initContainerSlot(slot, simpleLeftClick, lootBuilder)
	createRefreshOnFrame(slot, CONTAINER_SLOT_UPDATE_FREQUENCY, containerSlotUpdate);
	slot:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	slot:SetScript("OnEnter", slotOnEnter);
	slot:SetScript("OnLeave", slotOnLeave);

	if not lootBuilder then
		slot:RegisterForDrag("LeftButton");
		slot:SetScript("OnDragStart", slotOnDragStart);
		slot:SetScript("OnDragStop", slotOnDragStop);
		slot:SetScript("OnReceiveDrag", slotOnDragReceive);

		slot:SetAttribute("type", "macro");
		-- OnMouseDown is called before the OnClick script, which gives us the opportunity to setup the macro behavior before use
		slot:SetScript("OnMouseDown", function(self, button)
			SecuredMacroCommandsEnclave:StartCollectingSecureCommands();
			slot.trp3func(self, button);
			slot:SetAttribute("macrotext", SecuredMacroCommandsEnclave:GetSecureCommands());
		end)

		-- This function is manually called from the macro environment
		slot.trp3func = function(self, button)
			if self.info and ChatEdit_GetActiveWindow() and IsModifiedClick("CHATLINK") then
				TRP3_API.ChatLinks:OpenMakeImportablePrompt(loc.CL_EXTENDED_ITEM, function(canBeImported)
					TRP3_API.extended.ItemsChatLinksModule:InsertLink(self.info.id, TRP3_API.extended.getRootClassID(self.info.id), self.info, canBeImported);
				end);
				return true;
			end
			if not self.loot and self.info and not TRP3_API.inventory.isInTransaction(self.info) then
				if button == "LeftButton" then
					if IsShiftKeyDown() and (self.info.count or 1) > 1 then
						StackSplitFrame:OpenStackSplitFrame(self.info.count - 1, self, "BOTTOMRIGHT", "TOPRIGHT");
					elseif simpleLeftClick then
						simpleLeftClick(self);
					end
				elseif button == "RightButton" then
					if IsAltKeyDown() then
						local rootClass = TRP3_API.extended.getRootClassID(self.info.id);
						if TRP3_DB.exchange[rootClass] or TRP3_DB.my[rootClass] then
							TRP3_API.security.showSecurityDetailFrame(rootClass);
						end
					else
						TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_ON_SLOT_USE, self, self:GetParent());
					end
				end
			elseif self.loot and self.info and button == "RightButton" then
				if self:GetParent() == TRP3_StashContainer and TRP3_StashContainer.sharedData then
					if not self:GetParent().sync then
						TRP3_API.inventory.unstashSlot(self);
					else
						Utils.message.displayMessage(loc.DR_STASHES_ERROR_SYNC, 4);
					end
				else
					pickUpLoot(self);
				end
			end
			if self.additionalClickHandler then
				self.additionalClickHandler(self, button);
			end
		end
		slot:SetScript("OnDoubleClick", function(self, button)
			if not self.loot and button == "LeftButton" and self.info and self.class and isContainerByClass(self.class) then
				switchContainerByRef(self.info, self:GetParent());
				slotOnEnter(self);
			end
			if self.additionalDoubleClickHandler then
				self.additionalDoubleClickHandler(self, button);
			end
		end);
		slot.SplitStack = splitStack;

		-- Listen to refresh event
		TRP3_API.events.listenToEvent(TRP3_API.inventory.EVENT_DETACH_SLOT, function(slotInfo)
			if slot.info == slotInfo then
				slot.info = nil;
				slot.class = nil;
				containerSlotUpdate(slot);
				if TRP3_ItemTooltip.ref == slot then
					TRP3_ItemTooltip.ref = nil;
					TRP3_ItemTooltip:Hide();
				end
			end
		end);
	else
		slot:SetScript("OnClick", lootBuilder);
	end
end
TRP3_API.inventory.initContainerSlot = initContainerSlot;

local function initContainerSlots(containerFrame, rowCount, colCount, loot, lootBuilder)
	local slotNum = 1;
	local rowY = -58;
	containerFrame.slots = {};
	for row = 1, rowCount do
		local colX = 22;
		for col = 1, colCount do
			local slot = CreateFrame("Button",
				containerFrame:GetName() .. "Slot" .. slotNum,
				containerFrame, "TRP3_ContainerSlotTemplate");
			tinsert(containerFrame.slots, slot);
			initContainerSlot(slot, false, lootBuilder);
			slot:SetPoint("TOPLEFT", colX, rowY);
			slot.loot = loot;
			slot.index = slotNum;
			colX = colX + COLUMN_SPACING;
			slotNum = slotNum + 1;
		end
		rowY = rowY - ROW_SPACING;
	end
end
TRP3_API.inventory.initContainerSlots = initContainerSlots;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Container
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local DEFAULT_CONTAINER_SIZE = "5x4";

function loadContainerPageSlots(containerFrame)
	assert(containerFrame.info, "Missing container info");
	local containerContent = containerFrame.info.content or EMPTY;
	local slotCounter = 1;
	for index, slot in pairs(containerFrame.slots) do
		slot.slotID = tostring(slotCounter);
		if containerContent[slot.slotID] then
			slot.info = containerContent[slot.slotID];
			slot.class = getClass(slot.info.id);
		else
			slot.info = nil;
			slot.class = nil;
		end
		containerSlotUpdate(slot);
		slotCounter = slotCounter + 1;
	end
end
TRP3_API.inventory.loadContainerPageSlots = loadContainerPageSlots;

local function containerFrameUpdate(self, elapsed)
	if not self.info or not self.info.id or not TRP3_API.extended.classExists(self.info.id) then
		self:Hide();
		return;
	end

	-- Durability
	local durability = "";
	if self.class.CO.DU and self.class.CO.DU > 0 then
		local max = self.class.CO.DU;
		local current = self.info.durability or self.class.CO.DU;
		durability = (Utils.str.texture("Interface\\GROUPFRAME\\UI-GROUP-MAINTANKICON", 15) .. "%s/%s"):format(current, max);
	end
	self.DurabilityText:SetText(durability);

	-- Weight
	local current = self.info.totalWeight or 0;
	local formatedWeight = TRP3_API.extended.formatWeight(current);
	local weight = formatedWeight .. Utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15);
	if self.class.CO.MW and self.class.CO.MW > 0 and current > self.class.CO.MW then
		self.WeightText:SetTextColor(0.95, 0, 0);
	else
		self.WeightText:SetTextColor(0.95, 0.95, 0.95);
	end
	self.WeightText:SetText(weight);

	self.LockIcon:Hide();
	if self.lockedBy then
		self.LockIcon:Show();
	end
end

local function decorateContainer(containerFrame, class, container)
	local icon, name = getBaseClassDataSafe(class);
	Utils.texture.applyRoundTexture(containerFrame.Icon, "Interface\\ICONS\\" .. icon, "Interface\\ICONS\\TEMP");
	containerFrame.Title:SetText(name);
end
TRP3_API.inventory.decorateContainer = decorateContainer;

function highlightContainerInstance(container, except)
	for _, ref in pairs(containerInstances) do
		ref.Glow:Hide();
		if ref.info == container and ref:IsVisible() then
			ref.Glow:Show();
		end
	end
end

local function lockOnContainer(self, originContainer)
	self:ClearAllPoints();
	self.lockedOn = originContainer;
	if originContainer and originContainer:IsVisible() then
		if originContainer.lockedBy then
			lockOnContainer(self, originContainer.lockedBy);
			return;
		end
		originContainer.lockedBy = self;
		if originContainer.info.id ~= "main" then
			self:SetPoint("BOTTOM", originContainer, "TOP", originContainer.lockX or 0, originContainer.lockY or 42);
			containerFrameUpdate(originContainer);
		else
			self:SetPoint("TOPLEFT", originContainer, "TOPRIGHT", originContainer.lockX or 20, originContainer.lockY or 0);
		end
	elseif self.info.point and self.info.relativePoint then
		self:SetPoint(self.info.point, nil, self.info.relativePoint, self.info.xOfs, self.info.yOfs);
	else
		self:SetPoint("CENTER", 0, 0);
	end
end

local function unlockFromContainer(self)
	if self.lockedOn then
		self.lockedOn.lockedBy = nil;
		if not self.lockedOn.info or self.lockedOn.info.id ~= "main" then
			containerFrameUpdate(self.lockedOn);
		end
	end
end

local function containerOnDragStop(self)
	self:StopMovingOrSizing();
	local anchor, _, _, x, y = self:GetPoint(1);
	local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1);
	self.info.point = point;
	self.info.relativePoint = relativePoint;
	self.info.xOfs = xOfs;
	self.info.yOfs = yOfs;
	for _, containerFrame in pairs(containerInstances) do
		containerFrame.isMoving = nil;
	end
	-- Check for anchor
	for _, containerFrame in pairs(containerInstances) do
		if containerFrame ~= self and MouseIsOver(containerFrame) then
			lockOnContainer(self, containerFrame);
			self.info.point = nil;
			self.info.relativePoint = nil;
			self.info.xOfs = nil;
			self.info.yOfs = nil;
		end
	end
	containerFrameUpdate(self);
end

local function containerOnDragStart(self)
	unlockFromContainer(self);
	self.lockedOn = nil;
	self:StartMoving();
	for _, containerFrame in pairs(containerInstances) do
		containerFrame.isMoving = self.info;
	end
end

local function onContainerShow(self)
	if not self.info then
		self:Hide();
		return;
	end
	self.IconButton.info = self.info;
	self.IconButton.class = self.class;
	lockOnContainer(self, self.originContainer);
	decorateContainer(self, self.class, self.info);
	loadContainerPageSlots(self);
	TRP3_API.ui.misc.playSoundKit(12206, "SFX");
end

local function onContainerHide(self)
	unlockFromContainer(self);
	-- Free resources for garbage collection.
	self.info = nil;
	self.class = nil;
	for index, slot in pairs(self.slots) do
		slot.info = nil;
		slot.class = nil;
	end
	self:Hide();
	TRP3_API.ui.misc.playSoundKit(12206, "SFX");
end

local CONTAINER_UPDATE_FREQUENCY = 0.15;

local function initContainerInstance(containerFrame, size)
	containerFrame.containerSize = size;
	-- Listen to refresh event
	TRP3_API.events.listenToEvent(TRP3_API.inventory.EVENT_REFRESH_BAG, function(containerInfo)
		if containerFrame:IsVisible() and (containerInfo == nil or containerFrame.info == containerInfo) then
			loadContainerPageSlots(containerFrame);
		end
	end);
end
TRP3_API.inventory.initContainerInstance = initContainerInstance;

local function getContainerInstance(container, class)
	if not class or not isContainerByClass(class) then
		return nil;
	end

	local size = class.CO.SI or DEFAULT_CONTAINER_SIZE;
	local count = 0;
	local containerFrame, available;
	for _, ref in pairs(containerInstances) do
		count = count + 1;
		if not ref:IsVisible() and ref.containerSize == size then
			available = ref;
		end
		if ref:IsVisible() and ref.info == container then
			containerFrame = ref;
			break;
		end
	end
	if containerFrame then -- If a container is already visible for this instance
		return containerFrame;
	end
	if available then -- If there is available frame in the pool
		containerFrame = available;
	else -- Else: we create a new one
		containerFrame = CreateFrame("Frame", "TRP3_Container" .. size .. "_" .. (count + 1), nil, "TRP3_Container" .. size .. "Template");
		containerFrame:SetParent("UIParent");
		createRefreshOnFrame(containerFrame, CONTAINER_UPDATE_FREQUENCY, containerFrameUpdate);
		initContainerSlots(containerFrame, class.CO.SR or 5, class.CO.SC or 4);
		containerFrame:SetScript("OnShow", onContainerShow);
		containerFrame:SetScript("OnHide", onContainerHide);
		containerFrame:RegisterForDrag("LeftButton");
		containerFrame:SetScript("OnDragStart", containerOnDragStart);
		containerFrame:SetScript("OnDragStop", containerOnDragStop);
		containerFrame.IconButton:RegisterForDrag("LeftButton");
		containerFrame.IconButton:SetScript("OnDragStart", function(self) containerOnDragStart(self:GetParent()) end);
		containerFrame.IconButton:SetScript("OnDragStop", function(self) containerOnDragStop(self:GetParent()) end);
		containerFrame.IconButton:SetScript("OnEnter", slotOnEnter);
		containerFrame.IconButton:SetScript("OnLeave", slotOnLeave);
		initContainerInstance(containerFrame, size)
		tinsert(containerInstances, containerFrame);
		tinsert(UISpecialFrames, containerFrame:GetName());
	end
	containerFrame.info = container;
	return containerFrame;
end

function isContainerInstanceOpen(container)
	for _, ref in pairs(containerInstances) do
		if ref.info == container and ref:IsVisible() then
			return true;
		end
	end
	return false;
end

function TRP3_API.inventory.closeBags()
	for _, ref in pairs(containerInstances) do
		ref:Hide();
	end
end

function switchContainerByRef(container, originContainer)
	local class = getClass(container.id);
	local containerFrame = getContainerInstance(container, class);
	assert(containerFrame, "No frame available for container: " .. tostring(container.id));

	containerFrame.class = class;
	if originContainer and originContainer.info then
		containerFrame.originContainer = originContainer;
	end
	ToggleFrame(containerFrame);
	if containerFrame:IsVisible() then
		containerFrame:Raise();
	end
end
TRP3_API.inventory.switchContainerByRef = switchContainerByRef;

function TRP3_API.inventory.switchContainerBySlotID(parentContainer, slotID)
	assert(parentContainer, "Nil parent container.");
	assert(parentContainer.content[slotID], "Empty slot.");
	assert(parentContainer.content[slotID].id, "Container without id for slot: " .. tostring(slotID));
	switchContainerByRef(parentContainer.content[slotID]);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Loot
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local lootDB = {};

local function presentLoot(loot, onLootCallback, forceLoot, checker, onDiscardCallback)
	if lootFrame:IsVisible() and lootFrame:GetParent() == TRP3_DialogFrame and lootFrame.forceLoot then
		Utils.message.displayMessage(loc.IT_LOOT_ERROR, 4);
		return;
	end
	if loot then
		Utils.texture.applyRoundTexture(lootFrame.Icon, "Interface\\ICONS\\" .. (loot.BA.IC or "Garrison_silverchest"), "Interface\\ICONS\\TEMP");
		lootFrame.Title:SetText((loot.BA.NA or loc.LOOT));

		local slotCounter = 1;
		lootFrame.info.content = loot.IT or EMPTY;
		for index, slot in pairs(lootFrame.slots) do
			slot.slotID = tostring(slotCounter);
			if lootFrame.info.content[slot.slotID] then
				slot.info = lootFrame.info.content[slot.slotID];
				slot.class = getClass(lootFrame.info.content[slot.slotID].id);
				slot.deletable = onDiscardCallback ~= nil;
			else
				slot.info = nil;
				slot.class = nil;
			end
			containerSlotUpdate(slot);
			slotCounter = slotCounter + 1;
		end

		lootFrame:ClearAllPoints();
		lootFrame.close:Enable();
		lootFrame.onDiscardCallback = onDiscardCallback;
		lootFrame.forceLoot = forceLoot;
		lootFrame.checker = checker;
		if TRP3_DialogFrame:IsVisible() then
			lootFrame:SetParent(TRP3_DialogFrame);
			lootFrame:SetPoint("TOP", 0, -75);
			lootFrame:SetFrameLevel(TRP3_DialogFrame:GetFrameLevel() + 20);
			if forceLoot then
				lootFrame.close:Disable();
			end
		else
			lootFrame:SetParent(UIParent);
			if TRP3_MainFrame:IsVisible() then
				lootFrame:SetPoint("TOPLEFT", TRP3_MainFrame, "TOPRIGHT", 0, 0);
			else
				lootFrame:SetPoint("CENTER");
			end
		end

		lootFrame:Show();
		lootFrame:Raise();
		lootFrame.onLootCallback = onLootCallback;
		return 0;
	end
end
TRP3_API.inventory.presentLoot = presentLoot;

local function presentLootID(lootID, callback, forceLoot)
	presentLoot(lootDB[lootID], callback, forceLoot);
end
TRP3_API.inventory.presentLootID = presentLootID;

function TRP3_API.inventory.getLoot(lootID)
	return lootDB[lootID];
end

function TRP3_API.inventory.storeLoot(lootID, lootData)
	local loot = {
		IT = {},
		BA = {
			IC = lootData[2],
			NA = lootData[1]
		}
	}
	for index, slot in pairs(lootData[3] or EMPTY) do
		loot.IT[tostring(index)] = {
			id = slot.classID,
			count = slot.count or 1
		}
	end
	lootDB[lootID] = loot;
end

function TRP3_API.inventory.initLootFrame()
	lootFrame = CreateFrame("Frame", "TRP3_LootFrame", UIParent, "TRP3_Container2x4Template");
	lootFrame.LockIcon:Hide();

	local lootDragStart = function(self)
		if not lootFrame.forceLoot then
			self:StartMoving();
		end
	end
	local lootDragStop = function(self)
		if not lootFrame.forceLoot then
			self:StopMovingOrSizing();
		end
	end

	lootFrame.info = {loot = true};
	lootFrame.DurabilityText:SetText(loc.LOOT_CONTAINER);
	lootFrame.WeightText:SetText("");
	lootFrame:RegisterForDrag("LeftButton");
	lootFrame:SetScript("OnDragStart", lootDragStart);
	lootFrame:SetScript("OnDragStop", lootDragStop);
	lootFrame:SetScript("OnHide", function(self) self:Hide(); end);

	lootFrame.Bottom:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Bank");
	lootFrame.Middle:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Bank");
	lootFrame.Top:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Bank");

	initContainerSlots(lootFrame, 2, 4, true);

	createRefreshOnFrame(lootFrame, CONTAINER_UPDATE_FREQUENCY, function(self)
		if self.checker and not self.checker() then
			self:Hide();
		end
	end);

	-- Tooltip
	createRefreshOnFrame(TRP3_ItemTooltip, CONTAINER_UPDATE_FREQUENCY, function(self)
		if not self.ref or not MouseIsOver(self.ref) then
			self:Hide();
		end
	end);
	TRP3_ItemTooltip:SetScript("OnHide", function(self)
		self.ref = nil;
	end);

	-- Inventory button
	local inventory = CreateFrame("Button", "TRP3_LootFrameInventory", TRP3_LootFrame, "TRP3_CommonButton");
	inventory:SetPoint("TOP", TRP3_LootFrame, "BOTTOM", 0, -25);
	inventory:SetSize(140, 20);
	inventory:SetText(loc.INV_PAGE_INV_OPEN);
	inventory:SetScript("OnClick", function()
		local playerInventory = TRP3_API.inventory.getInventory();
		local quickSlot = playerInventory.content[TRP3_API.inventory.QUICK_SLOT_ID];
		if quickSlot and quickSlot.id and TRP3_API.inventory.isContainerByClassID(quickSlot.id) then
			TRP3_API.inventory.switchContainerBySlotID(playerInventory, TRP3_API.inventory.QUICK_SLOT_ID);
			return;
		end
	end);

	local lootAll = CreateFrame("Button", "TRP3_LootFrameLootAll", TRP3_LootFrame, "TRP3_CommonButton");
	lootAll:SetPoint("TOP", TRP3_LootFrameInventory, "BOTTOM", 0, -5);
	lootAll:SetSize(140, 20);
	lootAll:SetText(loc.INV_PAGE_LOOT_ALL);
	lootAll:SetScript("OnClick", function()
		for _, slot in pairs(lootFrame.slots) do
			if slot.info then
				doPickUpLoot(slot, nil, nil, slot.info.count or 1);
			end
		end
	end);
end
