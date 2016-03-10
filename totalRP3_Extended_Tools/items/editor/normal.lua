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
local wipe, pairs, tonumber, tinsert, strtrim = wipe, pairs, tonumber, tinsert, strtrim;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local toolFrame, currentTab;

local TABS = {
	GENERAL = "GENERAL",
	EFFECTS = "EFFECTS",
	DOCUMENT = "DOCUMENT",
	CONTAINER = "CONTAINER",
}

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item quick editor
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TABS
-- Tabs in the list section are just pre-filters
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tabGroup;

local function onTabChanged(tabWidget, tab)
	-- Hide all
	currentTab = tab or TABS.GENERAL;

	-- Show tab
	if currentTab == TABS.MAIN then

	elseif currentTab == TABS.EFFECTS then

	elseif currentTab == TABS.DOCUMENT then

	elseif currentTab == TABS.CONTAINER then

	end
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameItemNormalTabPanel", toolFrame.item.normal);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ "Main", TABS.MAIN, 150 }, -- TODO locals
			{ "Effects", TABS.EFFECTS, 150 }, -- TODO locals
			{ "Document", TABS.DOCUMENT, 150 }, -- TODO locals
			{ "Container", TABS.CONTAINER, 150 }, -- TODO locals
		},
		onTabChanged
	);
end

local function loadItem(classID, class)

end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initItemEditorNormal(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.item.normal.loadItem = loadItem;
	createTabBar();

	-- General
	toolFrame.item.normal.display.title:SetText("Display information");
end