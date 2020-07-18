----------------------------------------------------------------------------------
-- Total RP 3: Extended features
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

---@type Ellyb;
local Ellyb = Ellyb("totalRP3");
local LibDeflate = LibStub:GetLibrary("LibDeflate");

local Globals, Events, Utils, EMPTY = TRP3_API.globals, TRP3_API.events, TRP3_API.utils, TRP3_API.globals.empty;
local wipe, pairs, strsplit, tinsert, table, strtrim = wipe, pairs, strsplit, tinsert, table, strtrim;
local stEtN = Utils.str.emptyToNil;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local loc = TRP3_API.loc;
local Log = Utils.log;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local refreshTooltipForFrame = TRP3_RefreshTooltipForFrame;
local showItemTooltip = TRP3_API.inventory.showItemTooltip;
local IsAltKeyDown = IsAltKeyDown;
local tContains = tContains;
local ToolFrame, onLineActionSelected;
local ID_SEPARATOR = TRP3_API.extended.ID_SEPARATOR;
local TRP3_MainTooltip, TRP3_ItemTooltip = TRP3_MainTooltip, TRP3_ItemTooltip;

local SECURITY_LEVEL = TRP3_API.security.SECURITY_LEVEL;
local hasImportExportModule = false;

local SUPPOSED_SERIAL_SIZE_LIMIT = 500000; -- We suppose the text field can only handle 500k pastes

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- List management: util methods
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local TABS = {
	MY_DB = "MY_DB",
	OTHERS_DB = "OTHERS_DB",
	BACKERS_DB = "BACKERS_DB",
	FULL_DB = "FULL_DB",
	BACKERS_LIST = "BACKERS_LIST",
}

local currentTab, onLineRightClick;
local refresh;
local linesWidget = {};
local idData = {};
local idList = {};
local LINE_TOP_MARGIN = 25;
local LEFT_DEPTH_STEP_MARGIN = 30;

local function getDB(dbType)
	if dbType == TABS.MY_DB then
		return TRP3_DB.my;
	elseif dbType == TABS.OTHERS_DB then
		return TRP3_DB.exchange;
	elseif dbType == TABS.BACKERS_DB then
		return TRP3_DB.inner;
	end
	return TRP3_DB.global;
end

local function objectHasChildren(class)
	if class then
		if class.IN and tsize(class.IN) > 0 then
			return true;
		end
		if class.TY == TRP3_DB.types.CAMPAIGN and class.QE and tsize(class.QE) > 0 then
			return true;
		end
		if class.TY == TRP3_DB.types.QUEST and class.ST and tsize(class.ST) > 0 then
			return true;
		end
	end
	return false;
end

local function isChild(parentID, childID)
	return childID ~= parentID and childID:sub(1, parentID:len() + 1) == parentID .. " ";
end

local function isFirstLevelChild(parentID, childID)
	return isChild(parentID, childID) and not childID:sub(parentID:len() + 2):find("%s");
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- List management: lists
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function addChildrenToPool(parentID, addAll)
	for objectID, _ in pairs(TRP3_DB.global) do
		if (addAll and isChild(parentID, objectID)) or isFirstLevelChild(parentID, objectID) then
			tinsert(idList, objectID);
		end
	end
	refresh();
end

local function removeChildrenFromPool(parentID)
	for objectID, _ in pairs(TRP3_DB.global) do
		if objectID ~= parentID and objectID:sub(1, parentID:len() + 1) == parentID .. " " then
			Utils.table.remove(idList, objectID);
		end
	end
	refresh();
end

local function onLineClick(self, button)
	local data = self:GetParent().idData;
	if button == "RightButton" then
		onLineRightClick(self:GetParent(), data);
	elseif button == "MiddleButton" then
		if (TRP3_API.extended.isObjectMine(data.rootID) or TRP3_API.extended.isObjectExchanged(data.rootID)) and not data.fullID:find(TRP3_API.extended.ID_SEPARATOR) then
			onLineActionSelected("1" .. data.fullID);
		end
	else
		-- If the shift key is down we want to insert a link for this item
		if ChatEdit_GetActiveWindow() and IsModifiedClick("CHATLINK") then
			if data.type == "IT" then
				TRP3_API.ChatLinks:OpenMakeImportablePrompt(loc.CL_EXTENDED_ITEM, function(canBeImported)
					TRP3_API.extended.ItemsChatLinksModule:InsertLink(data.fullID, data.rootID, {}, canBeImported);
				end);
			elseif data.type == "CA" then
				TRP3_API.ChatLinks:OpenMakeImportablePrompt(loc.CL_EXTENDED_CAMPAIGN, function(canBeImported)
					TRP3_API.extended.CampaignsChatLinksModule:InsertLink(data.fullID, data.rootID, canBeImported);
				end);
			end
		else
			if data.type == TRP3_DB.types.ITEM and data.mode == TRP3_DB.modes.QUICK then
				TRP3_API.extended.tools.openItemQuickEditor(self, nil, data.fullID, nil, not TRP3_DB.my[data.rootID]);
			else
				TRP3_API.extended.tools.goToPage(data.fullID, true);
			end
		end
	end
end

local color = "|cffffff00";
local fieldFormat = "%s: " .. color .. "%s|r";


local function getMetadataTooltipText(rootID, rootClass, isRoot, innerID, type)
	local metadata = rootClass.MD or EMPTY;
	local text = "";

	if isRoot then
		text = text .. fieldFormat:format(loc.ROOT_GEN_ID, "|cff00ffff" .. rootID .. "|r");
		text = text .. "\n" .. fieldFormat:format(loc.ROOT_VERSION, metadata.V or 1);
		text = text .. "\n" .. fieldFormat:format(loc.ROOT_CREATED_BY, metadata.CB or "?");
		text = text .. "\n" .. fieldFormat:format(loc.ROOT_CREATED_ON, metadata.CD or "?");
		text = text .. "\n" .. fieldFormat:format(loc.SEC_LEVEL, TRP3_API.security.getSecurityText(rootClass.securityLevel or SECURITY_LEVEL.LOW));
	else
		text = text .. fieldFormat:format(loc.SPECIFIC_INNER_ID, "|cff00ffff" .. innerID .. "|r");
	end

	text = text .. "\n" .. fieldFormat:format(loc.SPECIFIC_MODE, TRP3_API.extended.tools.getModeLocale(metadata.MO) or "?");
	text = text .. "\n\n" .. Ellyb.Strings.clickInstruction(Ellyb.System.CLICKS.LEFT_CLICK, loc.CM_OPEN);
	text = text .. "\n" .. Ellyb.Strings.clickInstruction(Ellyb.System.CLICKS.RIGHT_CLICK, loc.DB_ACTIONS);
	if type == "CA" or type == "IT" then
		text = text .. "\n" .. Ellyb.Strings.clickInstruction(Ellyb.System:FormatKeyboardShortcut(Ellyb.System.MODIFIERS.SHIFT, Ellyb.System.CLICKS.CLICK),  loc.CL_TOOLTIP);
	end
	return text;
end

local LINE_SLOT = {};
local function onLineEnter(self)
	refreshTooltipForFrame(self);
	if self:GetParent().idData.type == TRP3_DB.types.ITEM then
		local class = getClass(self:GetParent().idData.fullID);
		LINE_SLOT.id = self:GetParent().idData.fullID;
		showItemTooltip(self:GetParent(), LINE_SLOT, class, true, "ANCHOR_RIGHT");
	end
end

local function onLineLeave(self)
	TRP3_MainTooltip:Hide();
	TRP3_ItemTooltip:Hide();
end

local function onLineExpandClick(self)
	if not self.isOpen then
		addChildrenToPool(self:GetParent().idData.fullID, IsAltKeyDown());
	else
		removeChildrenFromPool(self:GetParent().idData.fullID);
	end
end

function refresh()
	for _, lineWidget in pairs(linesWidget) do
		lineWidget:Hide();
	end

	if ToolFrame.list.hasSearch then
		TRP3_API.ui.frame.setupFieldPanel(ToolFrame.list.container, loc.DB_RESULTS, 200);
	else
		TRP3_API.ui.frame.setupFieldPanel(ToolFrame.list.container, loc.DB_LIST, 200);
	end

	table.sort(idList);
	wipe(idData);
	for index, objectID in pairs(idList) do
		local class = getClass(objectID);
		local parts = {strsplit(ID_SEPARATOR, objectID)};
		local rootClass = getClass(parts[1]);
		local depth = #parts;
		local isOpen = idList[index + 1] and idList[index + 1]:sub(1, objectID:len() + 1) == objectID .. " ";
		local hasChildren = isOpen or objectHasChildren(class);
		local icon, name, description = TRP3_API.extended.tools.getClassDataSafeByType(class);
		local link = TRP3_API.inventory.getItemLink(class, objectID);
		local locale = TRP3_API.extended.tools.getObjectLocale(rootClass);

		-- idData is wipe frequently: DO NOT STORE PERSISTENT DATA IN IT !!!
		idData[index] = {
			type = class.TY,
			mode = (class.MD and class.MD.MO) or TRP3_DB.modes.NORMAL,
			icon = icon,
			text = link,
			text2 = description,
			depth = depth,
			ID = parts[#parts],
			rootID = parts[1],
			fullID = objectID,
			isOpen = isOpen,
			hasChildren = hasChildren,
			locale = locale,
			metadataTooltip = getMetadataTooltipText(parts[1], rootClass, objectID == parts[#parts], parts[#parts], class.TY),
		}

	end

	for index, idData in pairs(idData) do

		local lineWidget = linesWidget[index];
		if not lineWidget then
			lineWidget = CreateFrame("Frame", "TRP3_ToolFrameListLine" .. index, ToolFrame.list.container.scroll.child, "TRP3_Tools_ListLineTemplate");
			lineWidget.Click:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp");
			lineWidget.Click:SetScript("OnClick", onLineClick);
			lineWidget.Click:SetScript("OnEnter", onLineEnter);
			lineWidget.Click:SetScript("OnLeave", onLineLeave);
			lineWidget.Expand:SetScript("OnClick", onLineExpandClick);
			tinsert(linesWidget, lineWidget);
		end

		local tt = ("|cff00ff00%s: %s|r"):format(getTypeLocale(idData.type) or UNKNOWN, idData.text or UNKNOWN);
		lineWidget.Text:SetText(tt);

		local locale = "";
		if idData.depth == 1 or ToolFrame.list.hasSearch then
			locale = "  |T" .. TRP3_API.extended.tools.getObjectLocaleImage(idData.locale) .. ":11:16|t";
		end
		if ToolFrame.list.hasSearch then
			local totalPath = TRP3_API.inventory.getItemLink(getClass(idData.fullID), idData.fullID, true);
			lineWidget.Right:SetText(totalPath .. locale);
		else
			lineWidget.Right:SetText(("|cff00ffff%s"):format(idData.ID == idData.fullID and loc.ROOT_GEN_ID .. locale or idData.ID));
		end


		lineWidget.Expand:Hide();
		if idData.hasChildren and not ToolFrame.list.hasSearch then
			lineWidget.Expand:Show();
			lineWidget.Expand.isOpen = idData.isOpen;
			if idData.isOpen then
				lineWidget.Expand:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
				lineWidget.Expand:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-DOWN");
			else
				lineWidget.Expand:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
				lineWidget.Expand:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN");
			end
		end

		setTooltipForSameFrame(lineWidget.Click, "BOTTOMRIGHT", 0, 0, tt, idData.metadataTooltip);

		lineWidget:ClearAllPoints();
		local depth = ToolFrame.list.hasSearch and 1 or idData.depth;
		lineWidget:SetPoint("LEFT", LEFT_DEPTH_STEP_MARGIN * (depth - 1), 0);
		lineWidget:SetPoint("RIGHT", -15, 0);
		lineWidget:SetPoint("TOP", 0, (-LINE_TOP_MARGIN) * (index - 1));

		lineWidget.idData = idData;
		lineWidget:Show();
	end

	if #idData == 0 then
		ToolFrame.list.container.Empty:Show();
	else
		ToolFrame.list.container.Empty:Hide();
	end
end

local function checkOwner(owner, rootClass)
	return not owner or (rootClass.MD.CB and rootClass.MD.CB:lower():find(owner:lower()));
end

local function checkName(name, class)
	return not name or (class.BA.NA and class.BA.NA:lower():find(name:lower()));
end

local function checkID(id, classFullID)
	return not id or (classFullID:lower():find(id:lower()));
end

local function checkType(type, class)
	return type == 0 or type == class.TY;
end

local function checkLocale(locale, class)
	return locale == 0 or locale == class.MD.LO;
end

local function filterList(typeSearch, localeSearch)
	-- Here we will filter
	wipe(idList);

	-- Filter
	local typeFilter = typeSearch or ToolFrame.list.filters.type:GetSelectedValue();
	local localeFilter = localeSearch or ToolFrame.list.filters.locale:GetSelectedValue();
	local createdFilter = stEtN(strtrim(ToolFrame.list.filters.owner:GetText()));
	local nameFilter = stEtN(strtrim(ToolFrame.list.filters.name:GetText()));
	local idFilter = stEtN(strtrim(ToolFrame.list.filters.id:GetText()));
	local hasSearch = createdFilter or nameFilter or idFilter or typeFilter ~= 0 or localeFilter ~= 0;

	if hasSearch then
		for objectID, object in pairs(TRP3_DB.global) do
			if not object.hideFromList then
				local rootID = TRP3_API.extended.getRootClassID(objectID);
				local rootClass = getDB(currentTab)[rootID];
				if rootClass then
					local rootClass = getDB(currentTab)[rootID]
					if checkType(typeFilter, object) and checkOwner(createdFilter, rootClass)
							and checkName(nameFilter, object) and checkID(idFilter, objectID)
						and checkLocale(localeFilter, rootClass)
					then
						tinsert(idList, objectID);
					end
				end
			end
		end
	else
		for objectID, object in pairs(getDB(currentTab)) do
			-- Only take the first level objects
			if not objectID:find("%s") and not object.hideFromList then
				tinsert(idList, objectID);
			end
		end
	end

	ToolFrame.list.hasSearch = hasSearch;
	ToolFrame.list:Show();
	refresh();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TABS
-- Tabs in the list section are just pre-filters
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tabGroup;
local TUTORIAL;

local function getDBSize(dbType)
	local DB = getDB(dbType);
	local count = 0;
	for objectID, object in pairs(DB) do
		-- Only take the first level objects
		if not objectID:find("%s") and not object.hideFromList then
			count = count + 1;
		end
	end
	return count;
end

local function onTabChanged(tabWidget, tab)
	tabGroup.tabs[1]:SetText(loc.DB_MY:format(getDBSize(TABS.MY_DB)));
	tabGroup.tabs[2]:SetText(loc.DB_OTHERS:format(getDBSize(TABS.OTHERS_DB)));
	tabGroup.tabs[3]:SetText(loc.DB_BACKERS:format(getDBSize(TABS.BACKERS_DB)));
	tabGroup.tabs[4]:SetText(loc.DB_FULL:format(getDBSize()));

	TRP3_ItemQuickEditor:Hide();
	ToolFrame.list.bottom.item.templates:Hide();
	ToolFrame.list.bottom.campaign.templates:Hide();
	ToolFrame.list.bottom:Show();
	ToolFrame.list.container:Show();
	ToolFrame.list.filters:Show();
	ToolFrame.list.backers:Hide();

	currentTab = tab or TABS.MY_DB;

	if currentTab == TABS.MY_DB then
		ToolFrame.list.bottom.item:Show();
		ToolFrame.list.bottom.campaign:Show();
		ToolFrame.list.container.Empty:SetText(loc.DB_MY_EMPTY .. "\n\n\n" .. Utils.str.icon("misc_arrowdown", 50));
	elseif currentTab == TABS.OTHERS_DB then
		ToolFrame.list.container.Empty:SetText(loc.DB_OTHERS_EMPTY);
	elseif currentTab == TABS.BACKERS_DB then

	elseif currentTab == TABS.FULL_DB then
		ToolFrame.list.bottom.import:Show();
		ToolFrame.list.bottom.importFull:Show();
	elseif currentTab == TABS.BACKERS_LIST then
		ToolFrame.list.bottom:Hide();
		ToolFrame.list.container:Hide();
		ToolFrame.list.filters:Hide();
		ToolFrame.list.backers:Show();

		ToolFrame.list.backers.child.HTML:SetText(Utils.str.toHTML(TRP3_KS_BACKERS:format(TRP3_API.extended.tools.formatVersion())));
		ToolFrame.list.backers.child.HTML:SetScript("OnHyperlinkClick", function(self, url, text, button)
			TRP3_API.Ellyb.Popups:OpenURL(url);
		end)
	end

	filterList();
end

function TRP3_API.extended.tools.formatVersion(version)
	if not version then
		return Globals.extended_display_version;
	end

	-- Fixing the mess
	if (version == 1010) then
		return "1.0.9.1"
	elseif (version == 1011) then
		return "1.1.0"
	elseif (version == 1012) then
		return "1.1.1"
	end

	-- Before the change
	local v = tostring(version);
	local inter = tostring(tonumber(v:sub(2, 3)));
	return v:sub(1, 1) .. "." .. inter .. "." .. v:sub(4, 4);
end

function TRP3_API.extended.tools.getClassVersion(rootID)
	if not rootID.MD.tV and not rootID.MD.dV then
		return "?"
	end

	if rootID.MD.dV then	-- Display version in the creation data (after 1.1.1)
		return rootID.MD.dV
	elseif (rootID.MD.tV <= 1012) then	-- No display version (1.1.1 and before)
		return TRP3_API.extended.tools.formatVersion(rootID.MD.tV);
	else	-- Shouldn't happen
		return rootID.MD.tV
	end
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameListTabPanel", ToolFrame.list);
	frame:SetSize(810, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ "", TABS.MY_DB, 201 },
			{ "", TABS.OTHERS_DB, 241 },
			{ "", TABS.BACKERS_DB, 221 },
			{ "", TABS.FULL_DB, 221 },
			{ loc.DB_BACKERS_LIST, TABS.BACKERS_LIST, 160 },
		},
		onTabChanged
	);
end

function TRP3_API.extended.tools.toList()
	ToolFrame.rootClassID = nil;
	tabGroup:SelectTab(1);
	TRP3_ExtendedTutorial.loadStructure(TUTORIAL);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- List management: Right click
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local ACTION_FLAG_DELETE = "1";
local ACTION_FLAG_ADD = "2";
local ACTION_FLAG_COPY_ID = "3";
local ACTION_FLAG_SECURITY = "4";
local ACTION_FLAG_EXPERT = "5";
local ACTION_FLAG_COPY = "6";
local ACTION_FLAG_EXPORT = "7";
local ACTION_FLAG_FULL_EXPORT = "8";

function onLineActionSelected(value, button)
	local action = value:sub(1, 1);
	local objectID = value:sub(2);
	if action == ACTION_FLAG_DELETE then
		local _, name, _ = TRP3_API.extended.tools.getClassDataSafeByType(getClass(objectID));
		TRP3_API.popup.showConfirmPopup(loc.DB_REMOVE_OBJECT_POPUP:format(objectID, name or UNKNOWN), function()
			TRP3_API.extended.removeObject(objectID);
			onTabChanged(nil, currentTab);
		end);
	elseif action == ACTION_FLAG_ADD then
		local class = TRP3_API.extended.getClass(objectID);
		TRP3_API.popup.showNumberInputPopup(loc.DB_ADD_COUNT:format(TRP3_API.inventory.getItemLink(class)), function(value)
			TRP3_API.inventory.addItem(nil, objectID, {count = value or 1, madeBy = class.BA and class.BA.CR});
		end, nil, 1);
	elseif action == ACTION_FLAG_COPY_ID then
		TRP3_API.popup.showTextInputPopup(loc.EDITOR_ID_COPY_POPUP, nil, nil, objectID);
	elseif action == ACTION_FLAG_SECURITY then
		TRP3_API.security.showSecurityDetailFrame(objectID);
	elseif action == ACTION_FLAG_EXPERT then
		local class = getClass(objectID);
		class.MD.MO = TRP3_DB.modes.EXPERT;
		if class.TY == TRP3_DB.types.ITEM then
			class.LI = {OU = "onUse"};
		end
		local link = TRP3_API.inventory.getItemLink(class, objectID);
		Utils.message.displayMessage(loc.WO_EXPERT_DONE:format(link));
		onTabChanged(nil, currentTab);
	elseif action == ACTION_FLAG_COPY then
		wipe(TRP3_InnerObjectEditor.copy);
		Utils.table.copy(TRP3_InnerObjectEditor.copy, getClass(objectID));
		TRP3_InnerObjectEditor.copy_fullClassID = objectID;
	elseif action == ACTION_FLAG_EXPORT then
		local class = getClass(objectID);
		local serial = Utils.serial.serialize({Globals.extended_version, objectID, class, Globals.extended_display_version});
		serial = serial:gsub("|", "||");
		serial = AddOn_TotalRP3.Compression.compress(serial, false);
		serial = "!" .. LibDeflate:EncodeForPrint(serial);
		if serial:len() < SUPPOSED_SERIAL_SIZE_LIMIT then
			ToolFrame.list.container.export.content.scroll.text:SetText(serial);
			ToolFrame.list.container.export.content.title:SetText(loc.DB_EXPORT_HELP:format(TRP3_API.inventory.getItemLink(class), serial:len() / 1024));
			ToolFrame.list.container.export:Show();
		else
			Utils.message.displayMessage(loc.DB_EXPORT_TOO_LARGE:format(serial:len() / 1024), 2);
		end
	elseif action == ACTION_FLAG_FULL_EXPORT then
		if hasImportExportModule then
			wipe(TRP3_Extended_ImpExport);
			TRP3_Extended_ImpExport.id = objectID;
			TRP3_Extended_ImpExport.object = {};
			TRP3_Extended_ImpExport.date = date("%d/%m/%y %H:%M:%S");
			TRP3_Extended_ImpExport.version = Globals.extended_version;
			TRP3_Extended_ImpExport.display_version = Globals.extended_display_version;
			Utils.table.copy(TRP3_Extended_ImpExport.object, getClass(objectID));
			TRP3_Tools_Flags.exportAlert = true;
			ReloadUI();
		else
			Utils.message.displayMessage(loc.DB_EXPORT_MODULE_NOT_ACTIVE, 2);
		end
	end
end

function onLineRightClick(lineWidget, data)
	local values = {};
	tinsert(values, {data.text, nil});
	if (TRP3_API.extended.isObjectMine(data.rootID) or TRP3_API.extended.isObjectExchanged(data.rootID)) and not data.fullID:find(TRP3_API.extended.ID_SEPARATOR) then
		tinsert(values, {DELETE, ACTION_FLAG_DELETE .. data.fullID, loc.DB_DELETE_TT});
		tinsert(values, {loc.SEC_LEVEL_DETAILS, ACTION_FLAG_SECURITY .. data.rootID, loc.DB_SECURITY_TT});
	end
	if data.type == TRP3_DB.types.ITEM then
		local class = getClass(data.fullID);
		if class.BA and not class.BA.PA then
			tinsert(values, {loc.DB_ADD_ITEM, ACTION_FLAG_ADD .. data.fullID, loc.DB_ADD_ITEM_TT});
		end
		if data.mode == TRP3_DB.modes.NORMAL and not TRP3_DB.inner[data.rootID] then
			tinsert(values, {loc.DB_TO_EXPERT, ACTION_FLAG_EXPERT .. data.fullID, loc.DB_EXPERT_TT});
		end
	end
	tinsert(values, {loc.EDITOR_ID_COPY, ACTION_FLAG_COPY_ID .. data.fullID, loc.DB_COPY_ID_TT});
	if data.type == TRP3_DB.types.ITEM or data.type == TRP3_DB.types.DOCUMENT or data.type == TRP3_DB.types.DIALOG then
		tinsert(values, {loc.IN_INNER_COPY_ACTION, ACTION_FLAG_COPY .. data.fullID, loc.DB_COPY_TT});
	end
	if not data.fullID:find(TRP3_API.extended.ID_SEPARATOR) then
		tinsert(values, {loc.DB_EXPORT, ACTION_FLAG_EXPORT .. data.fullID, loc.DB_EXPORT_TT_2});
		tinsert(values, {loc.DB_FULL_EXPORT, ACTION_FLAG_FULL_EXPORT .. data.fullID, loc.DB_FULL_EXPORT_TT});
	end

	TRP3_API.ui.listbox.displayDropDown(lineWidget, values, onLineActionSelected, 0, true);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function createTutorialStructure()
	TUTORIAL = {
		{
			box = ToolFrame, title = "DB", text = "TU_DB_1_TEXT",
			arrow = "DOWN", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
			callback = function()
				tabGroup:SelectTab(1);
			end
		},
		{
			box = TRP3_ToolFrameListTabPanel, title = "TU_DB_2", text = "TU_DB_2_TEXT",
			arrow = "DOWN", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
			callback = function()
				tabGroup:SelectTab(3);
			end
		},
		{
			box = ToolFrame.list.filters, title = "DB_FILTERS", text = "TU_DB_3_TEXT",
			arrow = "DOWN", x = 0, y = 0, anchor = "CENTER", textWidth = 500,
			callback = function()
				tabGroup:SelectTab(4);
				ToolFrame.list.filters.clear:GetScript("OnClick")(ToolFrame.list.filters.clear);
				ToolFrame.list.filters.type:SetSelectedValue(TRP3_DB.types.ITEM);
			end
		},
		{
			box = "TRP3_ToolFrameListLine1", title = "TU_DB_7", text = "TU_DB_7_TEXT",
			arrow = "DOWN", x = 0, y = 0, anchor = "CENTER", textWidth = 500,
			callback = function()
				tabGroup:SelectTab(4);
				ToolFrame.list.filters.clear:GetScript("OnClick")(ToolFrame.list.filters.clear);
			end
		},
		{
			box = ToolFrame.list, title = "TU_DB_4", text = "TU_DB_4_TEXT",
			arrow = "RIGHT", x = -250, y = 0, anchor = "CENTER", textWidth = 600,
			callback = function()
				tabGroup:SelectTab(4);
				ToolFrame.list.filters.clear:GetScript("OnClick")(ToolFrame.list.filters.clear);
			end
		},
		{
			box = ToolFrame.list.bottom, title = "TU_DB_5", text = "TU_DB_5_TEXT",
			arrow = "UP", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
			callback = function()
				tabGroup:SelectTab(1);
			end
		},
		{
			box = ToolFrame.list.bottom.item.templates, title = "TU_DB_6", text = "TU_DB_6_TEXT",
			arrow = "RIGHT", x = 150, y = 0, anchor = "CENTER", textWidth = 600,
			callback = function()
				tabGroup:SelectTab(1);
				ToolFrame.list.bottom.item:GetScript("OnClick")(ToolFrame.list.bottom.item);
			end
		},
	}


end

function TRP3_API.extended.tools.initList(toolFrame)
	ToolFrame = toolFrame;
	TRP3_API.ui.frame.setupFieldPanel(ToolFrame.list.filters, loc.DB_FILTERS, 150);
	TRP3_API.ui.frame.setupFieldPanel(ToolFrame.list.bottom, loc.DB_ACTIONS, 150);

	createTabBar();
	createTutorialStructure();

	TRP3_API.events.listenToEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, function(containerwidth, containerHeight)
		ToolFrame.list.container.scroll.child:SetWidth(containerwidth - 100);
	end);

	-- Button on toolbar
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		if TRP3_API.toolbar then
			local toolbarButton = {
				id = "bb_extended_tools",
				icon = "Inv_gizmo_01",
				configText = loc.TB_TOOLS,
				tooltip = loc.TB_TOOLS,
				tooltipSub = loc.TB_TOOLS_TT,
				onClick = function()
					if TRP3_ToolFrame:IsVisible() then
						TRP3_ToolFrame:Hide();
					else
						TRP3_API.extended.tools.showFrame();
					end
				end,
				visible = 1
			};
			TRP3_API.toolbar.toolbarAddButton(toolbarButton);
		end
	end);

	-- My creation tab
	ToolFrame.list.bottom.campaign.Name:SetText(loc.DB_CREATE_CAMPAIGN);
	ToolFrame.list.bottom.campaign.InfoText:SetText(loc.DB_CREATE_CAMPAIGN_TT);
	TRP3_API.ui.frame.setupIconButton(ToolFrame.list.bottom.campaign, "achievement_quests_completed_07");

	-- Events
	Events.listenToEvent(Events.ON_OBJECT_UPDATED, function(objectID, objectType)
		onTabChanged(nil, currentTab);
	end);

	-- Filters
	local goSearch = function() filterList(); end;
	ToolFrame.list.filters.name.title:SetText(loc.DB_FILTERS_NAME);
	ToolFrame.list.filters.name:SetScript("OnEnterPressed", goSearch);
	ToolFrame.list.filters.id.title:SetText(loc.ROOT_ID);
	ToolFrame.list.filters.id:SetScript("OnEnterPressed", goSearch);
	ToolFrame.list.filters.owner.title:SetText(loc.DB_FILTERS_OWNER);
	ToolFrame.list.filters.owner:SetScript("OnEnterPressed", goSearch);
	TRP3_API.ui.frame.setupEditBoxesNavigation({
		ToolFrame.list.filters.owner,
		ToolFrame.list.filters.name,
		ToolFrame.list.filters.id,
	})
	local types = {
		{TRP3_API.formats.dropDownElements:format(loc.TYPE, loc.ALL), 0},
		{TRP3_API.formats.dropDownElements:format(loc.TYPE, loc.TYPE_CAMPAIGN), TRP3_DB.types.CAMPAIGN},
		{TRP3_API.formats.dropDownElements:format(loc.TYPE, loc.TYPE_QUEST), TRP3_DB.types.QUEST},
		{TRP3_API.formats.dropDownElements:format(loc.TYPE, loc.TYPE_QUEST_STEP), TRP3_DB.types.QUEST_STEP},
		{TRP3_API.formats.dropDownElements:format(loc.TYPE, loc.TYPE_ITEM), TRP3_DB.types.ITEM},
		{TRP3_API.formats.dropDownElements:format(loc.TYPE, loc.TYPE_DOCUMENT), TRP3_DB.types.DOCUMENT},
		{TRP3_API.formats.dropDownElements:format(loc.TYPE, loc.TYPE_DIALOG), TRP3_DB.types.DIALOG},
	}
	TRP3_API.ui.listbox.setupListBox(ToolFrame.list.filters.type, types, function(value) filterList(value, nil) end, nil, 155, true);

	local template = "|T%s:11:16|t";
	local locales = {
		{loc.DB_LOCALE},
		{TRP3_API.formats.dropDownElements:format(loc.DB_LOCALE, loc.ALL), 0},
		{TRP3_API.formats.dropDownElements:format(loc.DB_LOCALE, template:format(TRP3_API.extended.tools.getObjectLocaleImage("en"))), "en"},
		{TRP3_API.formats.dropDownElements:format(loc.DB_LOCALE, template:format(TRP3_API.extended.tools.getObjectLocaleImage("fr"))), "fr"},
		{TRP3_API.formats.dropDownElements:format(loc.DB_LOCALE, template:format(TRP3_API.extended.tools.getObjectLocaleImage("es"))), "es"},
		{TRP3_API.formats.dropDownElements:format(loc.DB_LOCALE, template:format(TRP3_API.extended.tools.getObjectLocaleImage("de"))), "de"},
	}
	TRP3_API.ui.listbox.setupListBox(ToolFrame.list.filters.locale, locales, function(value) filterList(nil, value) end, nil, 155, true);
	ToolFrame.list.filters.locale:SetSelectedValue(0);
	ToolFrame.list.filters.type:SetSelectedValue(0);
	ToolFrame.list.filters.search:SetText(SEARCH);
	ToolFrame.list.filters.search:SetScript("OnClick", goSearch);
	ToolFrame.list.filters.clear:SetText(loc.DB_FILTERS_CLEAR);
	ToolFrame.list.filters.clear:SetScript("OnClick", function()
		ToolFrame.list.filters.type:SetSelectedValue(0);
		ToolFrame.list.filters.locale:SetSelectedValue(0);
		ToolFrame.list.filters.name:SetText("");
		ToolFrame.list.filters.id:SetText("");
		ToolFrame.list.filters.owner:SetText("");
		filterList();
	end);

	-- Export
	do
		ToolFrame.list.container.export.title:SetText(loc.DB_EXPORT);

		---@type SimpleHTML
		local wagoInfo = ToolFrame.list.container.export.wagoInfo;
		wagoInfo:SetText(HTML_START .. loc.DB_WAGO_INFO .. HTML_END);
		wagoInfo:SetScript("OnHyperlinkClick", function(self, url)
			TRP3_API.popup.showTextInputPopup(loc.UI_LINK_WARNING, nil, nil, url);
		end);
	end

	-- Quick import
	ToolFrame.list.bottom.import.Name:SetText(loc.DB_IMPORT);
	ToolFrame.list.bottom.import.InfoText:SetText(loc.DB_IMPORT_TT);
	TRP3_API.ui.frame.setupIconButton(ToolFrame.list.bottom.import, "INV_Inscription_ScrollOfWisdom_02");

	-- Import
	local function importFunction(version, ID, data, displayVersion)
		local type = data.TY;
		local objectVersion = data.MD.V or 0;
		local author = data.MD.CB;

		assert(type and author, "Corrupted import structure.");

		local import = function()
			if TRP3_API.extended.classExists(ID) then
				TRP3_API.extended.removeObject(ID);
			end
			local DB;
			if author == Globals.player_id then
				DB = TRP3_DB.my;
			else
				DB = TRP3_DB.exchange;
			end
			DB[ID] = {};
			Utils.table.copy(DB[ID], data);
			TRP3_API.extended.registerObject(ID, DB[ID], 0);
			TRP3_API.security.registerSender(ID, author);
			ToolFrame.list.container.import:Hide();
			onTabChanged(nil, currentTab);
			Utils.message.displayMessage(loc.DB_IMPORT_DONE, 3);
			TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG);
			TRP3_API.events.fireEvent(TRP3_API.quest.EVENT_REFRESH_CAMPAIGN);

			if DB[ID].securityLevel ~= 3 then
				TRP3_API.security.showSecurityDetailFrame(ID, ToolFrame);
			end
		end

		local checkVersion = function()
			if TRP3_API.extended.classExists(ID) and getClass(ID).MD.V > objectVersion then
				TRP3_API.popup.showConfirmPopup(loc.DB_IMPORT_VERSION:format(objectVersion, getClass(ID).MD.V), function()
					C_Timer.After(0.25, import);
				end);
			else
				import();
			end
		end

		if version ~= Globals.extended_version then
			TRP3_API.popup.showConfirmPopup(loc.DB_IMPORT_CONFIRM:format(displayVersion or TRP3_API.extended.tools.formatVersion(version), TRP3_API.extended.tools.formatVersion()), function()
				C_Timer.After(0.25, checkVersion);
			end);
		else
			checkVersion();
		end
	end

	---@type SimpleHTML
	local wagoInfo = ToolFrame.list.container.import.wagoInfo;
	wagoInfo:SetText(HTML_START .. loc.DB_IMPORT_TT_WAGO .. HTML_END);
	wagoInfo:SetScript("OnHyperlinkClick", function(self, url)
		TRP3_API.popup.showTextInputPopup(loc.UI_LINK_WARNING, nil, nil, url);
	end);

	ToolFrame.list.container.import.title:SetText(loc.DB_IMPORT);
	ToolFrame.list.container.import.content.title:SetText(loc.DB_IMPORT_TT);
	ToolFrame.list.bottom.import:SetScript("OnClick", function()
		ToolFrame.list.container.import.content.scroll.text:SetText("");
		ToolFrame.list.container.import:Show();
	end);
	ToolFrame.list.container.import.save:SetText(loc.DB_IMPORT_WORD);
	ToolFrame.list.container.import.save:SetScript("OnClick", function()
		local code = ToolFrame.list.container.import.content.scroll.text:GetText();
		local encoded, usesLibDeflate = code:gsub("^%!", "");
		if usesLibDeflate == 1 then
			code = LibDeflate:DecodeForPrint(encoded);
			code = AddOn_TotalRP3.Compression.decompress(code, false);
		end
		code = code:gsub("||", "|");
		local object = Utils.serial.safeDeserialize(code);
		if object and type(object) == "table" and (#object == 3 or #object == 4) then
			local version = object[1];
			local ID = object[2];
			local data = object[3];
			local displayVersion = object[4];
			local link = TRP3_API.inventory.getItemLink(data);
			local by = data.MD.CB;
			local objectVersion = data.MD.V or 0;
			local type = TRP3_API.extended.tools.getTypeLocale(data.TY);
			TRP3_API.popup.showConfirmPopup(loc.DB_IMPORT_FULL_CONFIRM:format(type, link, by, objectVersion), function()
				C_Timer.After(0.25, function()
					importFunction(version, ID, data, displayVersion);
					tabGroup:SelectTab(4); -- After importing go to full database, so we see what we have imported
				end);
			end);
		else
			Utils.message.displayMessage(loc.DB_IMPORT_ERROR1, 2);
		end
	end);

	-- Disclaimer
	ToolFrame.list.disclaimer.html:SetText(Utils.str.toHTML(loc.DISCLAIMER));
	ToolFrame.list.disclaimer.html.ok:SetText(loc.DISCLAIMER_OK);
	ToolFrame.list.disclaimer.html.ok:SetScript("OnClick", function()
		TRP3_Tools_Flags.has_seen_disclaimer = true;
		ToolFrame.list.disclaimer:Hide();
	end);
	ToolFrame.list.disclaimer.html:SetScript("OnHyperlinkClick", function(_, link)
		TRP3_API.popup.showTextInputPopup(loc.UI_LINK_WARNING, nil, nil, link);
	end);
	ToolFrame.list.disclaimer:Hide();
	if not TRP3_Tools_Flags.has_seen_disclaimer then
		ToolFrame.list.disclaimer:Show();
	end

	-- Detect import/export module
	hasImportExportModule = IsAddOnLoaded("totalRP3_Extended_ImpExport");
	if hasImportExportModule then
		if not TRP3_Extended_ImpExport then
			TRP3_Extended_ImpExport = {};
		end
		if TRP3_Tools_Flags.exportAlert then
			TRP3_Tools_Flags.exportAlert = nil;
			Utils.message.displayMessage(loc.DB_EXPORT_DONE, 2);
		end
	end
	ToolFrame.list.bottom.importFull.Name:SetText(loc.DB_IMPORT_FULL);
	ToolFrame.list.bottom.importFull.InfoText:SetText(loc.DB_IMPORT_FULL_TT);
	TRP3_API.ui.frame.setupIconButton(ToolFrame.list.bottom.importFull, "INV_Inscription_ScrollOfWisdom_01");
	ToolFrame.list.bottom.importFull:SetScript("OnClick", function()
		if hasImportExportModule then
			if TRP3_Extended_ImpExport.object then
				local version = TRP3_Extended_ImpExport.version;
				local ID = TRP3_Extended_ImpExport.id;
				local data = TRP3_Extended_ImpExport.object;
				local displayVersion = TRP3_Extended_ImpExport.display_version;
				local link = TRP3_API.inventory.getItemLink(data);
				local by = data.MD.CB;
				local objectVersion = data.MD.V or 0;
				local type = TRP3_API.extended.tools.getTypeLocale(data.TY);
				TRP3_API.popup.showConfirmPopup(loc.DB_IMPORT_FULL_CONFIRM:format(type, link, by, objectVersion), function()
					C_Timer.After(0.25, function()
						importFunction(version, ID, data, displayVersion);
					end);
				end);
			else
				Utils.message.displayMessage(loc.DB_IMPORT_EMPTY, 2);
			end
		else
			Utils.message.displayMessage(loc.DB_EXPORT_MODULE_NOT_ACTIVE, 2);
		end
	end);

	-- Hard save
	ToolFrame.list.container.hardsave:SetText(loc.DB_HARD_SAVE);
	ToolFrame.list.container.hardsave:SetScript("OnClick", function()
		ReloadUI();
	end);
	setTooltipForSameFrame(ToolFrame.list.container.hardsave, "TOP", 0, 0, loc.DB_HARD_SAVE, loc.DB_HARD_SAVE_TT);
end