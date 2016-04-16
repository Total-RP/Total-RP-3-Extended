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
local pairs, assert, tostring, strsplit, wipe, date = pairs, assert, tostring, strsplit, wipe, date;
local EMPTY = TRP3_API.globals.empty;
local Log = Utils.log;
local loc = TRP3_API.locale.getText;
local fireEvent = TRP3_API.events.fireEvent;
local after  = C_Timer.After;

local toolFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.extended.tools = {};

local BACKGROUNDS = {
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-Classic",
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-BurningCrusade",
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-WrathoftheLichKing",
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-CATACLYSM",
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-MistsofPandaria",
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-WarlordsofDraenor",
}

function TRP3_API.extended.tools.setBackground(backgroundIndex)
	assert(BACKGROUNDS[backgroundIndex], "Unknown background index:" .. tostring(backgroundIndex));
	local texture = BACKGROUNDS[backgroundIndex];
	toolFrame.BkgMain:SetTexture(texture);
	toolFrame.BkgHeader:SetTexture(texture);
	toolFrame.BkgScroll:SetTexture(texture);
end
local setBackground = TRP3_API.extended.tools.setBackground;

local PAGE_BY_TYPE = {
	[TRP3_DB.types.CAMPAIGN] = {
		frame = nil,
		tabTextGetter = function(id)
			return loc("TYPE_CAMPAIGN") .. ": " .. id;
		end,
		background = 2,
	},
	[TRP3_DB.types.QUEST] = {
		frame = nil,
		tabTextGetter = function(id)
			return loc("TYPE_QUEST") .. ": " .. id;
		end,
		background = 2,
	},
	[TRP3_DB.types.QUEST_STEP] = {
		frame = nil,
		tabTextGetter = function(id)
			return loc("TYPE_QUEST_STEP") .. ": " .. id;
		end,
		background = 2,
	},
	[TRP3_DB.types.ITEM] = {
		frame = "item",
		tabTextGetter = function(id)
			return loc("TYPE_ITEM") .. ": " .. id;
		end,
		background = 3,
	},
	[TRP3_DB.types.DOCUMENT] = {
		frame = nil,
		tabTextGetter = function(id)
			return loc("TYPE_DOCUMENT") .. ": " .. id;
		end,
		background = 4,
	},
	[TRP3_DB.types.DIALOG] = {
		frame = nil,
		tabTextGetter = function(id)
			return loc("TYPE_DIALOG") .. ": " .. id;
		end,
		background = 5,
	},
	[TRP3_DB.types.LOOT] = {
		frame = nil,
		tabTextGetter = function(id)
			return loc("TYPE_LOOT") .. ": " .. id;
		end,
		background = 6,
	},
}

local function getTypeLocale(type)
	if PAGE_BY_TYPE[type] and PAGE_BY_TYPE[type].loc then
		return PAGE_BY_TYPE[type].loc;
	end
	return UNKOWN;
end
TRP3_API.extended.tools.getTypeLocale = getTypeLocale;

local function getClassDataSafeByType(class)
	if class.TY == TRP3_DB.types.CAMPAIGN or class.TY == TRP3_DB.types.QUEST or class.TY == TRP3_DB.types.ITEM or class.TY == TRP3_DB.types.DOCUMENT then
		return TRP3_API.extended.getClassDataSafe(class);
	end
	if class.TY == TRP3_DB.types.QUEST_STEP then
		return "inv_inscription_scroll", (class.TX or ""):gsub("\n", ""):sub(1, 70) .. "...";
	end
	if class.TY == TRP3_DB.types.DIALOG then
		return "ability_warrior_rallyingcry", (class.ST[1].TX or ""):gsub("\n", ""):sub(1, 70) .. "...";
	end
	if class.TY == TRP3_DB.types.LOOT then
		return "inv_misc_coinbag_special", class.NA or "";
	end
end
TRP3_API.extended.tools.getClassDataSafeByType = getClassDataSafeByType;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Root object action
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local draftData = {};
local draftRegister = {};
local currentRootID;

local function getModeLocale(mode)
	if mode == TRP3_DB.modes.QUICK then
		return loc("MODE_QUICK");
	end
	if mode == TRP3_DB.modes.NORMAL then
		return loc("MODE_NORMAL");
	end
	if mode == TRP3_DB.modes.EXPERT then
		return loc("MODE_EXPERT");
	end
	return tostring(mode);
end
TRP3_API.extended.tools.getModeLocale = getModeLocale;

local function openObjectAndGetDraft(rootClassID, rootClass, forceDraftReload)
	for k, _ in pairs(draftRegister) do
		draftRegister[k] = nil;
	end
	if forceDraftReload or currentRootID ~= rootClassID then
		wipe(draftData);
		currentRootID = rootClassID;
		Utils.table.copy(draftData, rootClass);
	end
	TRP3_API.extended.registerDB({[rootClassID] = draftData}, 0, draftRegister);
	return draftData;
end

local function displayRootInfo(rootClassID, rootClass, classFullID, classID, specificDraft)
	assert(rootClass.MD, "No metadata MD in root class.");
	assert(specificDraft.MD, "No metadata MD in specific class.");
	local color = "|cffffff00";
	local fieldFormat = "%s: " .. color .. "%s";
	toolFrame.root.id:SetText(fieldFormat:format(loc("ROOT_ID"), rootClassID));
	toolFrame.root.version:SetText(fieldFormat:format(loc("ROOT_VERSION"), rootClass.MD.V or 0));
	toolFrame.root.created:SetText(loc("ROOT_CREATED"):format(color .. (rootClass.MD.CB or "?") .. "|r", color .. (rootClass.MD.CD or "?") .. "|r"));
	toolFrame.root.saved:SetText(loc("ROOT_SAVED"):format(color .. (rootClass.MD.SB or "?") .. "|r", color .. (rootClass.MD.SD or "?") .. "|r"));
	toolFrame.specific.id:SetText(fieldFormat:format(loc("SPECIFIC_INNER_ID"), classID));
	toolFrame.specific.fullid:SetText(fieldFormat:format(loc("SPECIFIC_PATH"), classFullID));
	toolFrame.specific.mode:SetText(fieldFormat:format(loc("SPECIFIC_MODE"), getModeLocale(specificDraft.MD.MO)));
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Editor save delegate
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local getClass = TRP3_API.extended.getClass;
local goToPage;

local function onSave(editor)
	assert(editor, "No editor.");
	assert(editor.onSave, "No save method in editor.");
	assert(toolFrame.rootClassID, "No rootClassID in editor.");
	assert(toolFrame.fullClassID, "No fullClassID in editor.");
	local rootClassID, fullClassID = toolFrame.rootClassID, toolFrame.fullClassID;

	-- Force save the current view in draft
	editor.onSave();

	local rootDraft = toolFrame.rootDraft;

	-- TODO: Optimize data

	local object = getClass(rootClassID);
	wipe(object);
	Utils.table.copy(object, rootDraft);
	object.MD.V = object.MD.V + 1;
	object.MD.SD = date("%d/%m/%y %H:%M:%S");
	object.MD.SB = Globals.player_id;

	TRP3_API.extended.registerObject(rootClassID, object, 0);

	goToPage(fullClassID, true);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Pages
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local getFullID, getClass = TRP3_API.extended.getFullID, TRP3_API.extended.getClass;

local function goToListPage(skipButton)
	if not skipButton then
		NavBar_Reset(toolFrame.navBar);
	end
	setBackground(1);
	toolFrame.actions:Hide();
	toolFrame.specific:Hide();
	toolFrame.root:Hide();
	for _, pageData in pairs(PAGE_BY_TYPE) do
		local frame = toolFrame[pageData.frame or ""];
		if frame then
			frame:Hide();
		end
	end
	TRP3_API.extended.tools.toList();
end

function goToPage(fullClassID, forceDraftReload)
	-- Ensure buttons up to the target
	NavBar_Reset(toolFrame.navBar);
	local parts = {strsplit(TRP3_API.extended.ID_SEPARATOR, fullClassID)};
	local fullId = "";
	for _, part in pairs(parts) do
		fullId = getFullID(fullId, part);
		local reconstruct = fullId;
		local class = getClass(reconstruct);
		local text = PAGE_BY_TYPE[class.TY].tabTextGetter(part);
		NavBar_AddButton(toolFrame.navBar, {id = reconstruct, name = text, OnClick = function()
			goToPage(reconstruct);
		end});
	end

	-- Go to page
	toolFrame.list:Hide();
	toolFrame.actions:Show();
	toolFrame.specific:Show();
	toolFrame.root:Show();
	local class = getClass(fullClassID);

	local selectedPageData, selectedPageFrame;
	-- Hide all
	for classType, pageData in pairs(PAGE_BY_TYPE) do
		local frame = toolFrame[pageData.frame or ""];
		if class.TY ~= classType then
			if frame then
				frame:Hide();
			end
		else
			selectedPageFrame = frame;
			selectedPageData = pageData;
		end
	end

	setBackground(selectedPageData.background or 1);

	-- Load data
	local rootClassID = parts[1];
	local specificClassID = parts[#parts];
	local rootClass = getClass(rootClassID);
	local rootDraft = openObjectAndGetDraft(rootClassID, rootClass, forceDraftReload);
	local specificDraft = draftRegister[fullClassID];
	displayRootInfo(rootClassID, rootClass, fullClassID, specificClassID, specificDraft);

	-- Show selected
	assert(selectedPageFrame, "No editor for type " .. class.TY);
	assert(selectedPageFrame.onLoad, "No load entry for type " .. class.TY);
	toolFrame.rootClassID = rootClassID;
	toolFrame.fullClassID = fullClassID;
	toolFrame.specificClassID = specificClassID;
	toolFrame.rootDraft = rootDraft;
	toolFrame.specificDraft = specificDraft;
	selectedPageFrame.onLoad();
	selectedPageFrame:Show();

	toolFrame.actions.save:SetScript("OnClick", function()
		onSave(selectedPageFrame);
	end);
end
TRP3_API.extended.tools.goToPage = goToPage;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.showFrame(reset)
	toolFrame:Show();
	if reset then
		goToListPage();
	end
end

local function onStart()

	-- Events
	Events.ON_OBJECT_UPDATED = "ON_OBJECT_UPDATED";
	Events.registerEvent(Events.ON_OBJECT_UPDATED);

	-- Register locales
	for localeID, localeStructure in pairs(TRP3_EXTENDED_TOOL_LOCALE) do
		local locale = TRP3_API.locale.getLocale(localeID);
		for localeKey, text in pairs(localeStructure) do
			locale.localeContent[localeKey] = text;
		end
	end

	TRP3_API.ui.frame.setupFieldPanel(toolFrame.root, loc("ROOT_TITLE"), 150);
	TRP3_API.ui.frame.setupFieldPanel(toolFrame.specific, loc("SPECIFIC"), 150);
	TRP3_API.ui.frame.setupFieldPanel(toolFrame.actions, loc("DB_ACTIONS"), 100);
	PAGE_BY_TYPE[TRP3_DB.types.CAMPAIGN].loc = loc("TYPE_CAMPAIGN");
	PAGE_BY_TYPE[TRP3_DB.types.QUEST].loc = loc("TYPE_QUEST");
	PAGE_BY_TYPE[TRP3_DB.types.QUEST_STEP].loc = loc("TYPE_QUEST_STEP");
	PAGE_BY_TYPE[TRP3_DB.types.ITEM].loc = loc("TYPE_ITEM");
	PAGE_BY_TYPE[TRP3_DB.types.DOCUMENT].loc = loc("TYPE_DOCUMENT");
	PAGE_BY_TYPE[TRP3_DB.types.DIALOG].loc = loc("TYPE_DIALOG");
	PAGE_BY_TYPE[TRP3_DB.types.LOOT].loc = loc("TYPE_LOOT");

	toolFrame.Close:SetScript("OnClick", function(self) self:GetParent():Hide(); end);

	TRP3_API.events.NAVIGATION_EXTENDED_RESIZED = "NAVIGATION_EXTENDED_RESIZED";
	TRP3_API.events.registerEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED);

	toolFrame.Resize.minWidth = 1150;
	toolFrame.Resize.minHeight = 730;
	toolFrame:SetSize(toolFrame.Resize.minWidth, toolFrame.Resize.minHeight);
	toolFrame.Resize.resizableFrame = toolFrame;
	toolFrame.Resize.onResizeStop = function()
		toolFrame.Minimize:Hide();
		toolFrame.Maximize:Show();
		fireEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, toolFrame:GetWidth(), toolFrame:GetHeight());
	end;

	toolFrame.Maximize:SetScript("OnClick", function()
		toolFrame.Maximize:Hide();
		toolFrame.Minimize:Show();
		toolFrame:SetSize(UIParent:GetWidth(), UIParent:GetHeight());
		after(0.1, function()
			fireEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, toolFrame:GetWidth(), toolFrame:GetHeight());
		end);
	end);

	toolFrame.Minimize:SetScript("OnClick", function()
		toolFrame:SetSize(toolFrame.Resize.minWidth, toolFrame.Resize.minHeight);
		after(0.1, function()
			toolFrame.Resize.onResizeStop();
		end);
	end);

	-- Tab bar init
	local homeData = {
		name = loc("DB"),
		OnClick = function()
			goToListPage();
		end
	}
	toolFrame.navBar.home:SetWidth(110);
	NavBar_Initialize(toolFrame.navBar, "NavButtonTemplate", homeData, toolFrame.navBar.home, toolFrame.navBar.overflow);

	-- Init tabs
	TRP3_API.extended.tools.initBaseEffects();
	TRP3_API.extended.tools.initScript(toolFrame);
	TRP3_InnerObjectEditor.init(toolFrame);
	TRP3_API.extended.tools.initItems(toolFrame);
	TRP3_API.extended.tools.initList(toolFrame);

	goToListPage();

	TRP3_API.events.fireEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, toolFrame:GetWidth(), toolFrame:GetHeight());
end

local function onInit()
	toolFrame = TRP3_ToolFrame;

	if not TRP3_Tools_DB then
		TRP3_Tools_DB = {};
	end
	TRP3_DB.my = TRP3_Tools_DB;
end

local MODULE_STRUCTURE = {
	["name"] = "Extended Tools",
	["description"] = "Total RP 3 extended tools: item, document and campaign creation.",
	["version"] = 0.11,
	["id"] = "trp3_extended_tools",
	["onStart"] = onStart,
	["onInit"] = onInit,
	["minVersion"] = 13,
	["requiredDeps"] = {
		{"trp3_extended", 0.11},
	}
};

TRP3_API.module.registerModule(MODULE_STRUCTURE);