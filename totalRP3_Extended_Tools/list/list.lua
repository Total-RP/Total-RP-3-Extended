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

local Globals, Events, Utils, EMPTY = TRP3_API.globals, TRP3_API.events, TRP3_API.utils, TRP3_API.globals.empty;
local wipe, pairs, strsplit, tinsert, table = wipe, pairs, strsplit, tinsert, table;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local loc = TRP3_API.locale.getText;
local Log = Utils.log;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local refreshTooltipForFrame = TRP3_RefreshTooltipForFrame;
local showItemTooltip = TRP3_API.inventory.showItemTooltip;

local ToolFrame;
local ID_SEPARATOR = TRP3_API.extended.ID_SEPARATOR;
local TRP3_MainTooltip, TRP3_ItemTooltip = TRP3_MainTooltip, TRP3_ItemTooltip;

local SECURITY_LEVEL = TRP3_API.security.SECURITY_LEVEL;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- List management: util methods
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local TABS = {
	MY_DB = "MY_DB",
	OTHERS_DB = "OTHERS_DB",
	BACKERS_DB = "BACKERS_DB",
	FULL_DB = "FULL_DB",
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

local function isFirstLevelChild(parentID, childID)
	return childID ~= parentID and childID:sub(1, parentID:len()) == parentID and not childID:sub(parentID:len() + 2):find("%s");
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- List management: lists
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function addChildrenToPool(parentID)
	for objectID, _ in pairs(TRP3_DB.global) do
		if isFirstLevelChild(parentID, objectID) then
			tinsert(idList, objectID);
		end
	end
	refresh();
end

local function removeChildrenFromPool(parentID)
	for objectID, _ in pairs(TRP3_DB.global) do
		if objectID ~= parentID and objectID:sub(1, parentID:len()) == parentID then
			Utils.table.remove(idList, objectID);
		end
	end
	refresh();
end

local function onLineClick(self, button)
	local data = self:GetParent().idData;
	if button == "RightButton" then
		onLineRightClick(self:GetParent(), data);
	else
		if data.type == TRP3_DB.types.ITEM and data.mode == TRP3_DB.modes.QUICK then
			TRP3_API.extended.tools.openItemQuickEditor(self, nil, data.fullID);
		else
			TRP3_API.extended.tools.goToPage(data.fullID, true);
		end
	end
end

local color = "|cffffff00";
local fieldFormat = "%s: " .. color .. "%s|r";

local function getMetadataTooltipText(rootID, rootClass, isRoot, innerID)
	local metadata = rootClass.MD or EMPTY;
	local text = ""

	if isRoot then
		text = text .. fieldFormat:format(loc("ROOT_GEN_ID"), "|cff00ffff" .. rootID);
		text = text .. "\n" .. fieldFormat:format(loc("ROOT_VERSION"), metadata.V or 1);
		text = text .. "\n" .. fieldFormat:format(loc("ROOT_CREATED_BY"), metadata.CB or "?");
		text = text .. "\n" .. fieldFormat:format(loc("ROOT_CREATED_ON"), metadata.CD or "?");
		text = text .. "\n" .. fieldFormat:format(loc("SEC_LEVEL"), TRP3_API.security.getSecurityText(rootClass.securityLevel or SECURITY_LEVEL.LOW));
	else
		text = text .. fieldFormat:format(loc("SPECIFIC_INNER_ID"), "|cff00ffff" .. innerID);
	end

	text = text .. "\n" .. fieldFormat:format(loc("SPECIFIC_MODE"), TRP3_API.extended.tools.getModeLocale(metadata.MO) or "?");
	text = text .. "\n\n|cffffff00" .. loc("CM_CLICK") .. ": |cffff9900" .. loc("CM_OPEN");
	text = text .. "\n|cffffff00" .. loc("CM_R_CLICK") .. ": |cffff9900" .. loc("DB_ACTIONS");
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
		addChildrenToPool(self:GetParent().idData.fullID);
	else
		removeChildrenFromPool(self:GetParent().idData.fullID);
	end
end

function refresh()
	for _, lineWidget in pairs(linesWidget) do
		lineWidget:Hide();
	end

	table.sort(idList);
	wipe(idData);
	for index, objectID in pairs(idList) do
		local class = getClass(objectID);
		local parts = {strsplit(ID_SEPARATOR, objectID)};
		local rootClass = getClass(parts[1]);
		local depth = #parts;
		local isOpen = idList[index + 1] and idList[index + 1]:sub(1, objectID:len()) == objectID;
		local hasChildren = isOpen or objectHasChildren(class);
		local icon, name, description = TRP3_API.extended.tools.getClassDataSafeByType(class);
		local link = TRP3_API.inventory.getItemLink(class);

		-- idData is wipe frequently: DO NOT STORE PERSISTENT DATA IN IT !!!
		idData[index] = {
			type = class.TY,
			mode = (class.MD and class.MD.MO) or TRP3_DB.modes.NORMAL,
			icon = icon,
			text = link,
			text2 = description,
			depth = depth,
			ID = parts[#parts],
			fullID = objectID,
			isOpen = isOpen,
			hasChildren = hasChildren,
			metadataTooltip = getMetadataTooltipText(parts[1], rootClass, objectID == parts[#parts], parts[#parts]),
		}

	end

	for index, idData in pairs(idData) do

		local lineWidget = linesWidget[index];
		if not lineWidget then
			lineWidget = CreateFrame("Frame", "TRP3_ToolFrameListLine" .. index, ToolFrame.list.container.scroll.child, "TRP3_Tools_ListLineTemplate");
			lineWidget.Click:RegisterForClicks("LeftButtonUp", "RightButtonUp");
			lineWidget.Click:SetScript("OnClick", onLineClick);
			lineWidget.Click:SetScript("OnEnter", onLineEnter);
			lineWidget.Click:SetScript("OnLeave", onLineLeave);
			lineWidget.Expand:SetScript("OnClick", onLineExpandClick);
			tinsert(linesWidget, lineWidget);
		end

		local tt = ("|cff00ff00%s: %s|r"):format(getTypeLocale(idData.type) or UNKNOWN, idData.text or UNKNOWN);
		lineWidget.Text:SetText(tt);

		local IDType = idData.ID == idData.fullID and loc("ROOT_GEN_ID") or loc("SPECIFIC_INNER_ID");
		lineWidget.Right:SetText(("|cff00ffff%s"):format(idData.ID == idData.fullID and IDType or idData.ID));

		lineWidget.Expand:Hide();
		if idData.hasChildren then
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
		lineWidget:SetPoint("LEFT", LEFT_DEPTH_STEP_MARGIN * (idData.depth - 1), 0);
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

local function filterList()
	-- Here we will filter
	wipe(idList);

	-- Filter
	local atLeast = false;
	local typeFilter = ToolFrame.list.filters.type:GetSelectedValue();

	for objectID, object in pairs(getDB(currentTab)) do
		-- Only take the first level objects
		if not objectID:find("%s") and not object.hideFromList then
			atLeast = true;
			if typeFilter == 0 or typeFilter == object.TY then
				tinsert(idList, objectID);
			end
		end
	end

	ToolFrame.list:Show();
	refresh();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TABS
-- Tabs in the list section are just pre-filters
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tabGroup;

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
	tabGroup.tabs[1]:SetText(loc("DB_MY"):format(getDBSize(TABS.MY_DB)));
	tabGroup.tabs[2]:SetText(loc("DB_OTHERS"):format(getDBSize(TABS.OTHERS_DB)));
	tabGroup.tabs[3]:SetText(loc("DB_BACKERS"):format(getDBSize(TABS.BACKERS_DB)));
	tabGroup.tabs[4]:SetText(loc("DB_FULL"):format(getDBSize()));

	TRP3_ItemQuickEditor:Hide();
	ToolFrame.list.bottom.item:Hide();
	ToolFrame.list.bottom.campaign:Hide();
	ToolFrame.list.bottom.item.templates:Hide();

	currentTab = tab or TABS.MY_DB;

	if currentTab == TABS.MY_DB then
		ToolFrame.list.bottom.item:Show();
		ToolFrame.list.bottom.campaign:Show();
		ToolFrame.list.container.Empty:SetText(loc("DB_MY_EMPTY") .. "\n\n\n" .. Utils.str.icon("misc_arrowdown", 50));
	elseif currentTab == TABS.OTHERS_DB then
		ToolFrame.list.container.Empty:SetText(loc("DB_OTHERS_EMPTY"));
	elseif currentTab == TABS.BACKERS_DB then
	else
	end

	filterList();
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameListTabPanel", ToolFrame.list);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ "", TABS.MY_DB, 150 },
			{ "", TABS.OTHERS_DB, 150 },
			{ "", TABS.BACKERS_DB, 150 },
			{ "", TABS.FULL_DB, 150 },
		},
		onTabChanged
	);
end

function TRP3_API.extended.tools.toList()
	ToolFrame.rootClassID = nil;
	tabGroup:SelectTab(1);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- List management: Right click
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local ACTION_FLAG_DELETE = "1";
local ACTION_FLAG_ADD = "2";
local ACTION_FLAG_COPY_ID = "3";
local ACTION_FLAG_SECURITY = "4";
local ACTION_FLAG_EXPERT = "5";

local function onLineActionSelected(value, button)
	local action = value:sub(1, 1);
	local objectID = value:sub(2);
	if action == ACTION_FLAG_DELETE then
		local _, name, _ = TRP3_API.extended.tools.getClassDataSafeByType(getClass(objectID));
		TRP3_API.popup.showConfirmPopup(loc("DB_REMOVE_OBJECT_POPUP"):format(objectID, name or UNKNOWN), function()
			TRP3_API.extended.removeObject(objectID);
			onTabChanged(nil, currentTab);
		end);
	elseif action == ACTION_FLAG_ADD then
		TRP3_API.inventory.addItem(nil, objectID);
	elseif action == ACTION_FLAG_COPY_ID then
		TRP3_API.popup.showTextInputPopup(loc("EDITOR_ID_COPY_POPUP"), nil, nil, objectID);
	elseif action == ACTION_FLAG_SECURITY then
		TRP3_API.security.showSecurityDetailFrame(objectID);
	elseif action == ACTION_FLAG_EXPERT then
		local class = getClass(objectID);
		class.MD.MO = TRP3_DB.modes.EXPERT;
		local link = TRP3_API.inventory.getItemLink(class);
		Utils.message.displayMessage(loc("WO_EXPERT_DONE"):format(link));
		onTabChanged(nil, currentTab);
	end
end

function onLineRightClick(lineWidget, data)
	local values = {};
	tinsert(values, {data.text, nil});
	if currentTab == TABS.MY_DB or currentTab == TABS.OTHERS_DB then
		if not data.fullID:find(TRP3_API.extended.ID_SEPARATOR) then
			tinsert(values, {DELETE, ACTION_FLAG_DELETE .. data.fullID});
		end
		if data.mode == TRP3_DB.modes.NORMAL then
			tinsert(values, {loc("DB_TO_EXPERT"), ACTION_FLAG_EXPERT .. data.fullID});
		end
		if not data.fullID:find(TRP3_API.extended.ID_SEPARATOR) then
			tinsert(values, {loc("SEC_LEVEL_DETAILS"), ACTION_FLAG_SECURITY .. data.fullID});
		end
	end
	if data.type == TRP3_DB.types.ITEM then
		tinsert(values, {loc("DB_ADD_ITEM"), ACTION_FLAG_ADD .. data.fullID});
	end
	tinsert(values, {loc("EDITOR_ID_COPY"), ACTION_FLAG_COPY_ID .. data.fullID});

	TRP3_API.ui.listbox.displayDropDown(lineWidget, values, onLineActionSelected, 0, true);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initList(toolFrame)
	ToolFrame = toolFrame;
	TRP3_API.ui.frame.setupFieldPanel(ToolFrame.list.container, loc("DB_LIST"), 150);
	TRP3_API.ui.frame.setupFieldPanel(ToolFrame.list.filters, loc("DB_FILTERS"), 150);
	TRP3_API.ui.frame.setupFieldPanel(ToolFrame.list.bottom, loc("DB_ACTIONS"), 150);

	createTabBar();

	TRP3_API.events.listenToEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, function(containerwidth, containerHeight)
		ToolFrame.list.container.scroll.child:SetWidth(containerwidth - 100);
	end);

	-- Button on target bar
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		if TRP3_API.toolbar then
			local toolbarButton = {
				id = "bb_extended_tools",
				icon = "Inv_gizmo_01",
				configText = loc("TB_TOOLS"),
				tooltip = loc("TB_TOOLS"),
				tooltipSub = loc("TB_TOOLS_TT"),
				onClick = function()
					TRP3_API.extended.tools.showFrame(true);
				end,
				visible = 1
			};
			TRP3_API.toolbar.toolbarAddButton(toolbarButton);
		end
	end);

	-- My creation tab
	ToolFrame.list.bottom.campaign.Name:SetText(loc("DB_CREATE_CAMPAIGN"));
	ToolFrame.list.bottom.campaign.InfoText:SetText(loc("DB_CREATE_CAMPAIGN_TT"));
	TRP3_API.ui.frame.setupIconButton(ToolFrame.list.bottom.campaign, "achievement_quests_completed_07");

	-- Events
	Events.listenToEvent(Events.ON_OBJECT_UPDATED, function(objectID, objectType)
		onTabChanged(nil, currentTab);
	end);

	-- Filters
	ToolFrame.list.filters.name.title:SetText(loc("DB_FILTERS_NAME"));
	ToolFrame.list.filters.id.title:SetText(loc("ROOT_ID"));
	ToolFrame.list.filters.owner.title:SetText(loc("DB_FILTERS_OWNER"));
	local types = {
		{TRP3_API.formats.dropDownElements:format(loc("TYPE"), loc("ALL")), 0},
		{TRP3_API.formats.dropDownElements:format(loc("TYPE"), loc("TYPE_CAMPAIGN")), TRP3_DB.types.CAMPAIGN},
		{TRP3_API.formats.dropDownElements:format(loc("TYPE"), loc("TYPE_QUEST")), TRP3_DB.types.QUEST},
		{TRP3_API.formats.dropDownElements:format(loc("TYPE"), loc("TYPE_QUEST_STEP")), TRP3_DB.types.QUEST_STEP},
		{TRP3_API.formats.dropDownElements:format(loc("TYPE"), loc("TYPE_ITEM")), TRP3_DB.types.ITEM},
		{TRP3_API.formats.dropDownElements:format(loc("TYPE"), loc("TYPE_DOCUMENT")), TRP3_DB.types.DOCUMENT},
		{TRP3_API.formats.dropDownElements:format(loc("TYPE"), loc("TYPE_LOOT")), TRP3_DB.types.LOOT},
		{TRP3_API.formats.dropDownElements:format(loc("TYPE"), loc("TYPE_DIALOG")), TRP3_DB.types.DIALOG},
	}
	TRP3_API.ui.listbox.setupListBox(ToolFrame.list.filters.type, types, nil, nil, 255, true);
	ToolFrame.list.filters.type:SetSelectedValue(0);
	ToolFrame.list.filters.search:Disable(); -- TODO: :)
	ToolFrame.list.filters.search:SetText(SEARCH);
	ToolFrame.list.filters.search:SetScript("OnClick", filterList);
	ToolFrame.list.filters.clear:SetText(loc("DB_FILTERS_CLEAR"));
	ToolFrame.list.filters.clear:SetScript("OnClick", function()
		ToolFrame.list.filters.type:SetSelectedValue(0);
		ToolFrame.list.filters.name:SetText("");
		ToolFrame.list.filters.id:SetText("");
		ToolFrame.list.filters.owner:SetText("");
		filterList();
	end);
end