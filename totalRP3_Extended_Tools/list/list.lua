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

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local wipe, pairs, strsplit, tinsert, table = wipe, pairs, strsplit, tinsert, table;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local loc = TRP3_API.locale.getText;

local ToolFrame = TRP3_ToolFrame;
local ID_SEPARATOR = TRP3_API.extended.ID_SEPARATOR;

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

local function getDB()
	if currentTab == TABS.MY_DB then
		return TRP3_DB.my;
	elseif currentTab == TABS.OTHERS_DB then
		return TRP3_DB.exchange;
	elseif currentTab == TABS.BACKERS_DB then
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
	for objectID, _ in pairs(getDB()) do
		if objectID ~= parentID and objectID:sub(1, parentID:len()) == parentID then
			Utils.table.remove(idList, objectID);
		end
	end
	refresh();
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
		local depth = #parts;
		local isOpen = idList[index + 1] and idList[index + 1]:sub(1, objectID:len()) == objectID;
		local hasChildren = isOpen or objectHasChildren(class);
		local icon, name, description = TRP3_API.extended.tools.getClassDataSafeByType(class);

		idData[index] = {
			type = class.TY,
			icon = icon,
			text = name,
			text2 = description,
			depth = depth,
			ID = parts[#parts],
			fullID = objectID,
			isOpen = isOpen,
			hasChildren = hasChildren,
		}

	end

	for index, idData in pairs(idData) do

		local lineWidget = linesWidget[index];
		if not lineWidget then
			lineWidget = CreateFrame("Frame", "TRP3_ToolFrameListLine" .. index, ToolFrame.list.container.scroll.child, "TRP3_Tools_ListLineTemplate");
			lineWidget.Click:RegisterForClicks("LeftButtonUp", "RightButtonUp");
			tinsert(linesWidget, lineWidget);
		end

		lineWidget.Text:SetText(("|cff00ff00%s: |r\"%s|r\" |cff00ffff(ID: %s)"):format(getTypeLocale(idData.type) or UNKNOWN, idData.text or UNKNOWN, idData.ID));

		lineWidget.Expand:Hide();
		if idData.hasChildren then
			lineWidget.Expand:Show();
			lineWidget.Expand:SetScript("OnClick", function(self)
				if not self.isOpen then
					addChildrenToPool(idData.fullID);
				else
					removeChildrenFromPool(idData.fullID);
				end
			end);
			lineWidget.Expand.isOpen = idData.isOpen;
			if idData.isOpen then
				lineWidget.Expand:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
				lineWidget.Expand:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-DOWN");
			else
				lineWidget.Expand:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
				lineWidget.Expand:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN");
			end
		end

		lineWidget:ClearAllPoints();
		lineWidget:SetPoint("LEFT", LEFT_DEPTH_STEP_MARGIN * (idData.depth - 1), 0);
		lineWidget:SetPoint("RIGHT", -15, 0);
		lineWidget:SetPoint("TOP", 0, (-LINE_TOP_MARGIN) * (index - 1));

		local fullID = idData.fullID;
		lineWidget.Click:SetScript("OnClick", function(self, button)
			if button == "RightButton" then
				onLineRightClick(lineWidget, fullID);
			else
				TRP3_API.extended.tools.goToPage(fullID);
			end
		end);

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

	for objectID, _ in pairs(getDB()) do
		if not objectID:find("%s") then -- Only take the first level objects
			tinsert(idList, objectID);
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
local itemQuickEditor = TRP3_ItemQuickEditor;

local function onTabChanged(tabWidget, tab)
	tabGroup.tabs[1]:SetText(("My database (%s)"):format(tsize(TRP3_DB.my))); -- TODO: locals
	tabGroup.tabs[2]:SetText(("Players database (%s)"):format(tsize(TRP3_DB.exchange))); -- TODO: locals
	tabGroup.tabs[3]:SetText(("Backers database (%s)"):format(tsize(TRP3_DB.inner))); -- TODO: locals
	tabGroup.tabs[4]:SetText(("Full database (%s)"):format(tsize(TRP3_DB.global))); -- TODO: locals

	itemQuickEditor:Hide();
	ToolFrame.list.bottom.item:Hide();
	ToolFrame.list.bottom.campaign:Hide();
	ToolFrame.list.bottom.item.templates:Hide();
	ToolFrame.list.bottom.item:UnlockHighlight();

	currentTab = tab or TABS.MY_DB;

	if currentTab == TABS.MY_DB then
		ToolFrame.list.bottom.item:Show();
		ToolFrame.list.bottom.campaign:Show();
		ToolFrame.list.container.Empty:SetText("You don't have created any object yet.\nUse one of the buttons below to unleash your creativity!")
	elseif currentTab == TABS.OTHERS_DB then
		ToolFrame.list.container.Empty:SetText("Here will be placed all objects created by other players.\nExchange objects with others or import a packageg using the button below!")
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
	tabGroup:SelectTab(1);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- List management: Right click
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onLineActionSelected(value, button)
	TRP3_API.extended.unregisterObject(value);
	onTabChanged(nil, currentTab);
end

function onLineRightClick(lineWidget, fullID)
	local values = {};
	tinsert(values, {DELETE, fullID});
	TRP3_API.ui.listbox.displayDropDown(lineWidget, values, onLineActionSelected, 0, true);
end

local function onItemCreated(id, data)
	onTabChanged(nil, currentTab);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initList()
	TRP3_API.ui.frame.setupFieldPanel(ToolFrame.list.container, "Creations list", 150); -- TODO: locals
	TRP3_API.ui.frame.setupFieldPanel(ToolFrame.list.filters, "Creations filters", 150); -- TODO: locals
	TRP3_API.ui.frame.setupFieldPanel(ToolFrame.list.bottom, "Actions", 150); -- TODO: locals

	createTabBar();

	TRP3_API.events.listenToEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, function(containerwidth, containerHeight)
		ToolFrame.list.container.scroll.child:SetWidth(containerwidth - 85);
	end);

	-- Quest log button on target bar
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		if TRP3_API.toolbar then
			local toolbarButton = {
				id = "bb_extended_tools",
				icon = "Inv_gizmo_01",
				configText = "Open Extended tools", -- TODO: locals
				tooltip = "Open Extended tools", -- TODO: locals
				tooltipSub = "Create your own items and quests.", -- TODO: locals
				onClick = function()
					TRP3_API.extended.tools.showFrame(true);
				end,
				visible = 1
			};
			TRP3_API.toolbar.toolbarAddButton(toolbarButton);
		end
	end);

	-- My creation tab
	ToolFrame.list.bottom.item.Name:SetText("Create item"); -- TODO: locals
	ToolFrame.list.bottom.item.InfoText:SetText("Select a template for a new item"); -- TODO: locals
	ToolFrame.list.bottom.campaign.Name:SetText("Create campaign"); -- TODO: locals
	ToolFrame.list.bottom.campaign.InfoText:SetText("Start creating a campaign"); -- TODO: locals
	ToolFrame.list.bottom.item.templates.title:SetText("Or select a template"); -- TODO: locals
	ToolFrame.list.bottom.item.templates.quick.Name:SetText("Quick creation"); -- TODO: locals
	ToolFrame.list.bottom.item.templates.quick.InfoText:SetText("Quickly creates a simple item without any effect.\nThen adds one unit of this item in your primary bag."); -- TODO: locals
	ToolFrame.list.bottom.item.templates.document.Name:SetText("Document item"); -- TODO: locals
	ToolFrame.list.bottom.item.templates.document.InfoText:SetText("A item template with an attached document.\nUseful to quickly create a book or a scroll."); -- TODO: locals
	ToolFrame.list.bottom.item.templates.blank.Name:SetText("Blank item"); -- TODO: locals
	ToolFrame.list.bottom.item.templates.blank.InfoText:SetText("A blank template.\nFor those who like to start from scratch."); -- TODO: locals
	ToolFrame.list.bottom.item.templates.container.Name:SetText("Container item"); -- TODO: locals
	ToolFrame.list.bottom.item.templates.container.InfoText:SetText("A container template.\nContainer can hold other items."); -- TODO: locals

	TRP3_API.ui.frame.setupIconButton(ToolFrame.list.bottom.item.templates.container, "inv_misc_bag_36");
	TRP3_API.ui.frame.setupIconButton(ToolFrame.list.bottom.item.templates.blank, "inv_inscription_scroll");
	TRP3_API.ui.frame.setupIconButton(ToolFrame.list.bottom.item.templates.document, "inv_misc_book_16");
	TRP3_API.ui.frame.setupIconButton(ToolFrame.list.bottom.item.templates.quick, "petbattle_speed");
	TRP3_API.ui.frame.setupIconButton(ToolFrame.list.bottom.item, "inv_garrison_blueprints1");
	TRP3_API.ui.frame.setupIconButton(ToolFrame.list.bottom.campaign, "achievement_quests_completed_07");
	ToolFrame.list.bottom.item:SetScript("OnClick", function(self)
		if itemQuickEditor:IsVisible() then
			itemQuickEditor:Hide();
			self:UnlockHighlight();
		elseif self.templates:IsVisible() then
			self.templates:Hide();
			self:UnlockHighlight();
		else
			TRP3_API.ui.frame.configureHoverFrame(self.templates, self, "BOTTOM", 0, 5, true);
			self:LockHighlight();
		end
	end);

	ToolFrame.list.bottom.item.templates.quick:SetScript("OnClick", function(self)
		ToolFrame.list.bottom.item.templates:Hide();
		TRP3_API.extended.tools.openItemQuickEditor(ToolFrame.list.bottom.item, onItemCreated);
	end);

end