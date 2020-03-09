----------------------------------------------------------------------------------
-- Total RP 3: Extended new database
--	---------------------------------------------------------------------------
--	Copyright 2020 Solanya (solanya@totalrp3.info)
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
local tinsert, strsplit = tinsert, strsplit;

local loc = TRP3_API.loc;
local tsize = TRP3_API.utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local ID_SEPARATOR = TRP3_API.extended.ID_SEPARATOR;

local ToolFrame;
local idData = {};
local idList = {};
local refreshList;

local DATABASE_LINE_SIZE = 30;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- List management: util methods
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local TABS = {
	MY_DB = "MY_DB",
	OTHERS_DB = "OTHERS_DB",
	BACKERS_DB = "BACKERS_DB",
}

local tabGroup;
local currentTab;

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
	refreshList(ToolFrame.list.scroll);
end

local function removeChildrenFromPool(parentID)
	for objectID, _ in pairs(TRP3_DB.global) do
		if objectID ~= parentID and objectID:sub(1, parentID:len() + 1) == parentID .. " " then
			TRP3_API.utils.table.remove(idList, objectID);
		end
	end
	refreshList(ToolFrame.list.scroll);
end

local function onLineExpandClick(self)
	if not self.isOpen then
		addChildrenToPool(self:GetParent().idData.fullID, IsAltKeyDown());
	else
		removeChildrenFromPool(self:GetParent().idData.fullID);
	end
end

---

function refreshList(self)
	local offset = HybridScrollFrame_GetOffset(self);
	local buttons = self.buttons;

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
		}
	end
	-- end TODO

	for i, lineWidget in ipairs(buttons) do
		local creationIndex = i + offset;
		if ( creationIndex <= #idData ) then
			local creationObject = idData[creationIndex];

			-- TODO: Find how to properly offset children
			lineWidget.lineContainer:ClearAllPoints();
			lineWidget.lineContainer:SetPoint("BOTTOMRIGHT", 0, 0);
			lineWidget.lineContainer:SetPoint("TOPLEFT", 30 * (creationObject.depth - 1), 0);
			--xOfs1 = 30 * (creationObject.depth - 1) + 10;

			local typeText = ("|cff00ff00%s"):format(getTypeLocale(creationObject.type) or UNKNOWN);
			lineWidget.lineContainer.Type:SetText(typeText);

			local tt = ("%s"):format(creationObject.text or UNKNOWN);
			lineWidget.lineContainer.Text:SetText(tt);

			-- TODO: Move button creation and scripts in a separate function
			lineWidget.lineContainer.Expand:SetScript("OnClick", onLineExpandClick);

			lineWidget.lineContainer.Expand:Hide();
			if creationObject.hasChildren and not ToolFrame.list.hasSearch then
				lineWidget.lineContainer.Expand:Show();
				lineWidget.lineContainer.Expand.isOpen = creationObject.isOpen;
				if creationObject.isOpen then
					lineWidget.lineContainer.Expand:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
					lineWidget.lineContainer.Expand:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-DOWN");
				else
					lineWidget.lineContainer.Expand:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
					lineWidget.lineContainer.Expand:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN");
				end
			end

			Ellyb.Icon(creationObject.icon):Apply(lineWidget.lineContainer.Icon);

			lineWidget.lineContainer.idData = creationObject;
			lineWidget:Show();
		else
			lineWidget:Hide();
		end
	end

	local totalHeight = #idData * DATABASE_LINE_SIZE;
	HybridScrollFrame_Update(self, totalHeight, self:GetHeight());
end

local function onTabChanged(tabWidget, tab)
	tabGroup.tabs[1]:SetText(loc.DB_MY:format(getDBSize(TABS.MY_DB)));
	tabGroup.tabs[2]:SetText(loc.DB_OTHERS:format(getDBSize(TABS.OTHERS_DB)));
	tabGroup.tabs[3]:SetText(loc.DB_BACKERS:format(getDBSize(TABS.BACKERS_DB)));
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameListTabPanel", ToolFrame.list);
	frame:SetSize(663, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
			{
				{ "", TABS.MY_DB, 201 },
				{ "", TABS.OTHERS_DB, 241 },
				{ "", TABS.BACKERS_DB, 221 },
			},
			onTabChanged
	);
end

function TRP3_API.extended.tools.toList()
	ToolFrame.rootClassID = nil;
	TRP3_ExtendedTutorial.loadStructure();
	refreshList(ToolFrame.list.scroll);
	tabGroup:SelectTab(1);
end

function TRP3_API.extended.tools.initList(toolFrame)
	ToolFrame = toolFrame;

	createTabBar();

	ToolFrame.list.scroll.update = refreshList;
	HybridScrollFrame_CreateButtons(ToolFrame.list.scroll, "TRP3_Tools_ListLineTemplate", DATABASE_LINE_SIZE, 0);

	TRP3_API.events.listenToEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, function(containerWidth, containerHeight)
		HybridScrollFrame_CreateButtons(ToolFrame.list.scroll, "TRP3_Tools_ListLineTemplate", DATABASE_LINE_SIZE, 0);
		refreshList(ToolFrame.list.scroll);
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

		-- Events
		TRP3_API.events.listenToEvent(TRP3_API.events.ON_OBJECT_UPDATED, function(objectID, objectType)
			onTabChanged(nil, currentTab);
		end);

		-- TODO: sort and filter
		for objectID, object in pairs(TRP3_DB.global) do
			-- Only take the first level objects
			if not objectID:find("%s") and not object.hideFromList then
				tinsert(idList, objectID);
			end
		end
	end);


end