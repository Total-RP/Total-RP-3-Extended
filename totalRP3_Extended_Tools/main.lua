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
local loc = TRP3_API.loc;
local fireEvent = TRP3_API.events.fireEvent;
local after  = C_Timer.After;
local getFullID, getClass = TRP3_API.extended.getFullID, TRP3_API.extended.getClass;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local refreshTooltipForFrame = TRP3_RefreshTooltipForFrame;

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
		frame = "campaign",
		tabTextGetter = function(id, class)
			return ("%s: %s"):format(loc.TYPE_CAMPAIGN,  TRP3_API.inventory.getItemLink(class));
		end,
		background = 2,
	},
	[TRP3_DB.types.QUEST] = {
		frame = "quest",
		tabTextGetter = function(id, class)
			return ("%s: %s"):format(loc.TYPE_QUEST,  TRP3_API.inventory.getItemLink(class));
		end,
		background = 2,
	},
	[TRP3_DB.types.QUEST_STEP] = {
		frame = "step",
		tabTextGetter = function(id, class)
			return ("%s: %s"):format(loc.TYPE_QUEST_STEP,  TRP3_API.inventory.getItemLink(class, id));
		end,
		background = 2,
	},
	[TRP3_DB.types.ITEM] = {
		frame = "item",
		tabTextGetter = function(id, class)
			return ("%s: %s"):format(loc.TYPE_ITEM,  TRP3_API.inventory.getItemLink(class));
		end,
		tutorial = true,
		background = 3,
	},
	[TRP3_DB.types.DOCUMENT] = {
		frame = "document",
		tabTextGetter = function(id, class)
			return ("%s: %s"):format(loc.TYPE_DOCUMENT,  TRP3_API.inventory.getItemLink(class, id));
		end,
		background = 4,
	},
	[TRP3_DB.types.DIALOG] = {
		frame = "cutscene",
		tabTextGetter = function(id, class)
			return ("%s: %s"):format(loc.TYPE_DIALOG,  TRP3_API.inventory.getItemLink(class, id));
		end,
		background = 5,
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
	if class.TY == TRP3_DB.types.CAMPAIGN or class.TY == TRP3_DB.types.QUEST or class.TY == TRP3_DB.types.ITEM then
		return TRP3_API.extended.getClassDataSafe(class);
	end
	if class.TY == TRP3_DB.types.DOCUMENT then
		if class.PA and class.PA[1] and class.PA[1].TX then
			return "inv_scroll_12", class.PA[1].TX:gsub("\n", ""):sub(1, 70) .. "...";
		else
			return "inv_scroll_12", loc.DO_EMPTY;
		end
	end
	if class.TY == TRP3_DB.types.QUEST_STEP then
		return "inv_inscription_scroll", (class.BA.TX or ""):gsub("\n", ""):sub(1, 70) .. "...";
	end
	if class.TY == TRP3_DB.types.DIALOG then
		return "ability_warrior_rallyingcry", (class.DS[1].TX or ""):gsub("\n", ""):sub(1, 70) .. "...";
	end
end
TRP3_API.extended.tools.getClassDataSafeByType = getClassDataSafeByType;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Root object action
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local draftData = {};
local draftRegister = {};

local function getObjectLocale(class)
	return (class.MD or EMPTY).LO or "en";
end
TRP3_API.extended.tools.getObjectLocale = getObjectLocale;

local LOCALE_FLAGS = {
	en = "Interface\\AddOns\\totalRP3_Extended\\libs\\en.tga",
	es = "Interface\\AddOns\\totalRP3_Extended\\libs\\es.tga",
	de = "Interface\\AddOns\\totalRP3_Extended\\libs\\de.tga",
	fr = "Interface\\AddOns\\totalRP3_Extended\\libs\\fr.tga",
}

local function getObjectLocaleImage(locale)
	return LOCALE_FLAGS[locale] or LOCALE_FLAGS.en;
end
TRP3_API.extended.tools.getObjectLocaleImage = getObjectLocaleImage;

local function getModeLocale(mode)
	if mode == TRP3_DB.modes.QUICK then
		return loc.MODE_QUICK;
	end
	if mode == TRP3_DB.modes.NORMAL then
		return loc.MODE_NORMAL;
	end
	if mode == TRP3_DB.modes.EXPERT then
		return loc.MODE_EXPERT;
	end
	return tostring(mode);
end
TRP3_API.extended.tools.getModeLocale = getModeLocale;

local function openObjectAndGetDraft(rootClassID, forceDraftReload)
	for k, _ in pairs(draftRegister) do
		draftRegister[k] = nil;
	end
	if forceDraftReload or toolFrame.rootClassID ~= rootClassID then
		Log.log(("Refreshing root draft.\nPrevious: %s\nNex: %s"):format(tostring(toolFrame.rootClassID), tostring(rootClassID)));
		wipe(TRP3_Tools_Parameters.editortabs);
		wipe(draftData);
		toolFrame.rootClassID = rootClassID;
		Utils.table.copy(draftData, getClass(rootClassID));
	end
	TRP3_API.extended.registerDB({[rootClassID] = draftData}, 0, draftRegister);
	return draftData;
end

local function displayRootInfo(rootClassID, rootClass, classFullID, classID, specificDraft)
	assert(rootClass.MD, "No metadata MD in root class.");
	assert(specificDraft.MD, "No metadata MD in specific class.");
	local color = "|cffffff00";
	local fieldFormat = "|cffff9900%s: " .. color .. "%s";

	local objectText = ("%s (%s: |cff00ffff%s|r)"):format(TRP3_API.inventory.getItemLink(rootClass, rootClassID), loc.ROOT_GEN_ID, rootClassID);
	objectText = objectText .. "\n\n" .. fieldFormat:format(loc.ROOT_VERSION, rootClass.MD.V or 0);
	objectText = objectText .. "\n\n|cffff9900" .. loc.ROOT_CREATED:format(color .. (rootClass.MD.CB or "?") .. "|cffff9900", color .. (rootClass.MD.CD or "?"));
	objectText = objectText .. "\n\n|cffff9900" .. loc.ROOT_SAVED:format(color .. (rootClass.MD.SB or "?") .. "|cffff9900", color .. (rootClass.MD.SD or "?"));
	toolFrame.root.text:SetText(objectText);

	TRP3_API.ui.frame.setupFieldPanel(toolFrame.specific, getTypeLocale(specificDraft.TY), 150);
	local specificText = "";
	if rootClassID == classID then
		specificText = specificText .. fieldFormat:format(loc.ROOT_GEN_ID, "|cff00ffff" .. classID);
	else
		specificText = specificText .. fieldFormat:format(loc.SPECIFIC_INNER_ID, "|cff00ffff" .. classID);
	end
	specificText = specificText .. "\n\n" .. fieldFormat:format(loc.TYPE, getTypeLocale(specificDraft.TY));
	specificText = specificText .. "\n\n" .. fieldFormat:format(loc.SPECIFIC_MODE, getModeLocale(specificDraft.MD.MO));
	toolFrame.specific.text:SetText(specificText);

	toolFrame.root.select:SetSelectedValue(getObjectLocale(rootClass));
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Editor save delegate
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local getClass = TRP3_API.extended.getClass;
local goToPage;

local function checkCreation(classID, data)
	local warnings = {};
	TRP3_API.extended.iterateObject(classID, data, function(classID, class)
		local frame = toolFrame[PAGE_BY_TYPE[class.TY].frame or ""];
		if frame and frame.validator then
			frame.validator(classID, class, warnings);
		end
	end);
	return warnings;
end

local function doSave()
	assert(toolFrame.rootClassID, "No rootClassID in editor.");
	assert(toolFrame.fullClassID, "No fullClassID in editor.");
	local rootClassID, fullClassID = toolFrame.rootClassID, toolFrame.fullClassID;

	local rootDraft = toolFrame.rootDraft;
	local object = getClass(rootClassID);
	wipe(object);
	Utils.table.copy(object, rootDraft);
	object.MD.V = object.MD.V + 1;
	object.MD.SD = date("%d/%m/%y %H:%M:%S");
	object.MD.SB = Globals.player_id;
	object.MD.tV = Globals.extended_version;
	object.MD.dV = Globals.extended_display_version;

	TRP3_API.security.computeSecurity(rootClassID, object);
	TRP3_API.extended.unregisterObject(rootClassID);
	TRP3_API.extended.registerObject(rootClassID, object, 0);
	TRP3_API.script.clearRootCompilation(rootClassID);
	TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG);
	TRP3_API.events.fireEvent(TRP3_API.quest.EVENT_REFRESH_CAMPAIGN, rootClassID);

	goToPage(fullClassID, true);
end

local function onSave(editor)
	assert(editor, "No editor.");
	assert(editor.onSave, "No save method in editor.");
	assert(toolFrame.rootClassID, "No rootClassID in editor.");
	assert(toolFrame.fullClassID, "No fullClassID in editor.");
	local rootClassID, fullClassID = toolFrame.rootClassID, toolFrame.fullClassID;

	-- Force save the current view in draft
	editor.onSave();
	local warnings = checkCreation(toolFrame.rootClassID, toolFrame.rootDraft);
	if #warnings > 0 then
		local joinedString = strjoin("\n\n", unpack(warnings));
		TRP3_API.popup.showConfirmPopup(loc.EDITOR_WARNINGS:format(#warnings, joinedString), function()
			doSave();
		end);
	else
		doSave();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Pages
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function goToListPage(skipButton)
	if not skipButton then
		NavBar_Reset(toolFrame.navBar);
	end
	setBackground(1);
	toolFrame.actions:Hide();
	toolFrame.specific:Hide();
	toolFrame.root:Hide();
	toolFrame.tutoframe:Hide();
	for _, pageData in pairs(PAGE_BY_TYPE) do
		local frame = toolFrame[pageData.frame or ""];
		if frame then
			frame:Hide();
		end
	end
	TRP3_API.extended.tools.toList();
end
TRP3_API.extended.tools.goToListPage = goToListPage;

function goToPage(fullClassID, forceDraftReload)
	local parts = {strsplit(TRP3_API.extended.ID_SEPARATOR, fullClassID)};
	local rootClassID = parts[1];
	local specificClassID = parts[#parts];

	-- First of all, save to draft if same rootID !
	if toolFrame.rootClassID == rootClassID and toolFrame.currentEditor then
		toolFrame.currentEditor.onSave();
	end

	-- Go to page
	toolFrame.list:Hide();
	toolFrame.actions:Show();
	toolFrame.specific:Show();
	toolFrame.root:Show();
	toolFrame.tutoframe:Hide();

	-- Load data
	local rootDraft = openObjectAndGetDraft(rootClassID, forceDraftReload);
	local specificDraft = draftRegister[fullClassID];
	assert(specificDraft, "Can't find specific object in draftRegister: " .. fullClassID);

	local selectedPageData, selectedPageFrame;
	-- Hide all
	for classType, pageData in pairs(PAGE_BY_TYPE) do
		local frame = toolFrame[pageData.frame or ""];
		if specificDraft.TY ~= classType then
			if frame then
				frame:Hide();
			end
		else
			selectedPageFrame = frame;
			selectedPageData = pageData;
		end
	end

	assert(selectedPageFrame, "No editor for type " .. specificDraft.TY);
	assert(selectedPageFrame.onLoad, "No load entry for type " .. specificDraft.TY);

	TRP3_ExtendedTutorial.loadStructure(nil);

	-- Show selected
	setBackground(selectedPageData.background or 1);
	displayRootInfo(rootClassID, rootDraft, fullClassID, specificClassID, specificDraft);
	toolFrame.rootClassID = rootClassID;
	toolFrame.currentEditor = selectedPageFrame;
	toolFrame.fullClassID = fullClassID;
	toolFrame.specificClassID = specificClassID;
	toolFrame.rootDraft = rootDraft;
	toolFrame.specificDraft = specificDraft;
	toolFrame.currentEditor.onLoad();
	toolFrame.currentEditor:Show();


	toolFrame.actions.save:Disable();
	if TRP3_Tools_DB[rootClassID] then
		toolFrame.actions.save:Enable();
	end
	setTooltipForSameFrame(toolFrame.actions.save, "TOP", 0, 5, SAVE, loc.EDITOR_SAVE_TT:format(TRP3_API.inventory.getItemLink(rootDraft, rootClassID)));
	setTooltipForSameFrame(toolFrame.actions.cancel, "TOP", 0, 5, CANCEL, loc.EDITOR_CANCEL_TT:format(TRP3_API.inventory.getItemLink(rootDraft, rootClassID)));

	-- Create buttons up to the target
	NavBar_Reset(toolFrame.navBar);
	local fullId = "";
	for _, part in pairs(parts) do
		fullId = getFullID(fullId, part);
		local reconstruct = fullId;
		local class = draftRegister[reconstruct];
		local text = PAGE_BY_TYPE[class.TY].tabTextGetter(part, class, part == parts[1]);
		NavBar_AddButton(toolFrame.navBar, {id = reconstruct, name = text, OnClick = function()
			goToPage(reconstruct);
		end});
		local navButton = toolFrame.navBar.navList[#toolFrame.navBar.navList];
		navButton:SetScript("OnEnter", function(self)
			NavBar_ButtonOnEnter(self);
			refreshTooltipForFrame(self);
		end);
		navButton:SetScript("OnLeave", function(self)
			NavBar_ButtonOnLeave(self);
			TRP3_MainTooltip:Hide();
		end);
		if fullId == part then
			setTooltipForSameFrame(navButton, "TOP", 0, 5, loc.ROOT_GEN_ID, "|cff00ffff" .. part);
		else
			setTooltipForSameFrame(navButton, "TOP", 0, 5, loc.SPECIFIC_INNER_ID, "|cff00ffff" .. part);
		end
	end

end
TRP3_API.extended.tools.goToPage = goToPage;

function TRP3_API.extended.tools.saveTab(fullClassID, tab)
	TRP3_Tools_Parameters.editortabs[fullClassID] = tab;
end

function TRP3_API.extended.tools.getSaveTab(fullClassID, maxTabSize)
	local savedTab = TRP3_Tools_Parameters.editortabs[fullClassID];
	if savedTab and savedTab <= maxTabSize then
		return savedTab;
	else
		return 1;
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Misc functions
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.truncateDecimals(args, decimals)
	if decimals and tonumber(args) then
		local tenpow = 10 ^ decimals;
		args = tostring( floor( tonumber(args) * tenpow + 0.5 ) / tenpow ) or "0";
	end
	return args;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.showFrame()
	toolFrame:Show();
	toolFrame:Raise();
end

local function onStart()

	-- Events
	Events.ON_OBJECT_UPDATED = "ON_OBJECT_UPDATED";

	TRP3_API.ui.frame.setupFieldPanel(toolFrame.root, loc.ROOT_TITLE, 150);
	TRP3_API.ui.frame.setupFieldPanel(toolFrame.actions, loc.DB_ACTIONS, 100);
	toolFrame.actions.cancel:SetText(CANCEL)
	toolFrame.actions.save:SetScript("OnClick", function()
		onSave(toolFrame.currentEditor);
	end);
	toolFrame.actions.cancel:SetScript("OnClick", function()
		goToListPage();
	end);
	toolFrame.root.id:SetText(loc.EDITOR_ID_COPY);
	toolFrame.root.id:SetScript("OnClick", function()
		TRP3_API.popup.showTextInputPopup(loc.EDITOR_ID_COPY_POPUP, nil, nil, toolFrame.rootClassID);
	end);
	toolFrame.specific.id:SetText(loc.EDITOR_ID_COPY);
	toolFrame.specific.id:SetScript("OnClick", function()
		TRP3_API.popup.showTextInputPopup(loc.EDITOR_ID_COPY_POPUP, nil, nil, toolFrame.fullClassID);
	end);

	PAGE_BY_TYPE[TRP3_DB.types.CAMPAIGN].loc = loc.TYPE_CAMPAIGN;
	PAGE_BY_TYPE[TRP3_DB.types.QUEST].loc = loc.TYPE_QUEST;
	PAGE_BY_TYPE[TRP3_DB.types.QUEST_STEP].loc = loc.TYPE_QUEST_STEP;
	PAGE_BY_TYPE[TRP3_DB.types.ITEM].loc = loc.TYPE_ITEM;
	PAGE_BY_TYPE[TRP3_DB.types.DOCUMENT].loc = loc.TYPE_DOCUMENT;
	PAGE_BY_TYPE[TRP3_DB.types.DIALOG].loc = loc.TYPE_DIALOG;

	toolFrame.Close:SetScript("OnClick", function(self) self:GetParent():Hide(); end);

	TRP3_API.events.NAVIGATION_EXTENDED_RESIZED = "NAVIGATION_EXTENDED_RESIZED";

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

	-- Root panel locale selection
	local template = "|T%s:11:16|t";
	local types = {
		{loc.DB_LOCALE},
		{template:format(getObjectLocaleImage("en")), "en"},
		{template:format(getObjectLocaleImage("fr")), "fr"},
		{template:format(getObjectLocaleImage("es")), "es"},
		{template:format(getObjectLocaleImage("de")), "de"},
	}
	TRP3_API.ui.listbox.setupListBox(toolFrame.root.select, types, function(value)
		if toolFrame.rootDraft and toolFrame.rootDraft.MD then
			toolFrame.rootDraft.MD.LO = value;
		end
	end, nil, 40, true);

	-- Tab bar init
	local homeData = {
		name = loc.DB,
		OnClick = function()
			goToListPage();
		end
	}
	toolFrame.navBar.home:SetWidth(110);
	toolFrame.navBar.home:SetScript("OnEnter", function(self)
		NavBar_ButtonOnEnter(self);
		refreshTooltipForFrame(self);
	end);
	toolFrame.navBar.home:SetScript("OnLeave", function(self)
		NavBar_ButtonOnLeave(self);
		TRP3_MainTooltip:Hide();
	end);

	setTooltipForSameFrame(toolFrame.navBar.home, "TOP", 0, 5, loc.DB, loc.DB_WARNING);
	NavBar_Initialize(toolFrame.navBar, "NavButtonTemplate", homeData, toolFrame.navBar.home, toolFrame.navBar.overflow);

	-- Init effects and operands
	local effectMenu = TRP3_API.extended.tools.getEffectOperandLocale();
	TRP3_API.extended.tools.initBaseEffects();
	TRP3_API.extended.tools.initCampaignEffects();
	TRP3_API.extended.tools.initItemEffects();

	-- Init editors
	TRP3_API.extended.tools.initScript(toolFrame, effectMenu);
	TRP3_InnerObjectEditor.init(toolFrame);
	TRP3_LinksEditor.init(toolFrame);
	TRP3_API.extended.tools.initDocument(toolFrame);
	TRP3_API.extended.tools.initCampaign(toolFrame);
	TRP3_API.extended.tools.initQuest(toolFrame);
	TRP3_API.extended.tools.initStep(toolFrame)
	TRP3_API.extended.tools.initItems(toolFrame);
	TRP3_API.extended.tools.initCutscene(toolFrame);
	TRP3_API.extended.tools.initList(toolFrame);
	TRP3_ExtendedTutorial.init(toolFrame);

	TRP3_API.events.fireEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, toolFrame:GetWidth(), toolFrame:GetHeight());

	-- Bindings

	BINDING_NAME_TRP3_EXTENDED_TOOLS = loc.TB_TOOLS;

	Events.listenToEvent(Events.WORKFLOW_ON_FINISH, function()
		goToListPage();
	end);

	TRP3_API.ui.frame.setupMove(toolFrame);
end

local function onInit()
	toolFrame = TRP3_ToolFrame;
	toolFrame.warnings = {};

	if not TRP3_Tools_Parameters then
		TRP3_Tools_Parameters = {};
	end
	if not TRP3_Tools_Parameters.editortabs then
		TRP3_Tools_Parameters.editortabs = {};
	end
	if not TRP3_Tools_Flags then
		TRP3_Tools_Flags = {};
	end
end

local MODULE_STRUCTURE = {
	["name"] = "Extended Tools",
	["description"] = "Total RP 3 extended tools: item, document and campaign creation.",
	["version"] = Globals.extended_version,
	["id"] = "trp3_extended_tools",
	["onStart"] = onStart,
	["onInit"] = onInit,
	["minVersion"] = Globals.required_trp3_build,
	["requiredDeps"] = {
		{"trp3_extended", Globals.extended_version},
	}
};

TRP3_API.module.registerModule(MODULE_STRUCTURE);