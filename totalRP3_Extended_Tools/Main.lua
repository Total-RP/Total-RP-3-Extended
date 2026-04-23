-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local _, addon = ...
local loc = TRP3_API.loc;

local toolFrame;
local tabBar;

local TAB_TYPE = {
	CREATION    = "CREATION",
	DATABASE    = "DATABASE",
	DISCLAIMER  = "DISCLAIMER",
	CREDITS     = "CREDITS"
};

StaticPopupDialogs["TRP3_SAVE_DISCARD_CANCEL"] = {
	button1 = SAVE,
	button2 = "Discard",
	button3 = CANCEL,
	timeout = false,
	whileDead = true,
	hideOnEscape = true,
	showAlert = true,
};

local drafts = {};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.extended.tools = {};
addon.main = {};

local BACKGROUNDS = {
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-Classic",
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-BurningCrusade",
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-WrathoftheLichKing",
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-CATACLYSM",
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-MistsofPandaria",
	"Interface\\ENCOUNTERJOURNAL\\UI-EJ-WarlordsofDraenor",
};


function addon.main.setBackground(backgroundIndex)
	assert(BACKGROUNDS[backgroundIndex], "Unknown background index:" .. tostring(backgroundIndex));
	local texture = BACKGROUNDS[backgroundIndex];
	toolFrame.BkgMain:SetTexture(texture);
	toolFrame.BkgHeader:SetTexture(texture);
end
TRP3_API.extended.tools.setBackground = addon.main.setBackground; -- TODO remove it from the API

local PAGE_BY_TYPE = {
	[TRP3_DB.types.CAMPAIGN] = {
		background = 2,
	},
	[TRP3_DB.types.QUEST] = {
		background = 2,
	},
	[TRP3_DB.types.QUEST_STEP] = {
		background = 2,
	},
	[TRP3_DB.types.ITEM] = {
		background = 3,
	},
	[TRP3_DB.types.DOCUMENT] = {
		background = 4,
	},
	[TRP3_DB.types.DIALOG] = {
		background = 5,
	},
	[TRP3_DB.types.AURA] = {
		background = 6,
	},
};

function addon.main.setTypeBackground(type)
	addon.main.setBackground(PAGE_BY_TYPE[type] and PAGE_BY_TYPE[type].background or 1);
end

function addon.main.getTypeLocale(type)
	if PAGE_BY_TYPE[type] and PAGE_BY_TYPE[type].loc then
		return PAGE_BY_TYPE[type].loc;
	end
	return UNKNOWN;
end
TRP3_API.extended.tools.getTypeLocale = addon.main.getTypeLocale;

function addon.main.getClassDataSafeByType(class)
	if class.TY == TRP3_DB.types.CAMPAIGN or class.TY == TRP3_DB.types.QUEST or class.TY == TRP3_DB.types.ITEM or class.TY == TRP3_DB.types.AURA then
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
TRP3_API.extended.tools.getClassDataSafeByType = addon.main.getClassDataSafeByType;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Root object action
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function addon.main.getObjectLocale(class)
	return (class.MD or TRP3_API.globals.empty).LO or "en";
end
TRP3_API.extended.tools.getObjectLocale = addon.main.getObjectLocale;

local LOCALE_FLAGS = {
	en = "Interface\\AddOns\\totalRP3_Extended\\libs\\en.tga",
	es = "Interface\\AddOns\\totalRP3_Extended\\libs\\es.tga",
	de = "Interface\\AddOns\\totalRP3_Extended\\libs\\de.tga",
	fr = "Interface\\AddOns\\totalRP3_Extended\\libs\\fr.tga",
};

function addon.main.getObjectLocaleImage(locale)
	return LOCALE_FLAGS[locale] or LOCALE_FLAGS.en;
end
TRP3_API.extended.tools.getObjectLocaleImage = addon.main.getObjectLocaleImage;

function addon.main.getModeLocale(mode)
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
TRP3_API.extended.tools.getModeLocale = addon.main.getModeLocale;

TRP3_ToolFrameTabsMixin = {};
function TRP3_ToolFrameTabsMixin:CloseRequest(tabButton, data)
	if data.type == TAB_TYPE.CREATION then
		local openTabCount = 0;
		for _, tab in ipairs(tabBar.tabs) do
			if tab.data.type == TAB_TYPE.CREATION and tab.data.creationId == data.creationId then
				openTabCount = openTabCount + 1;
			end
		end
		addon.editor.updateCurrentObjectDraft();
		if openTabCount <= 1 then
			if TRP3_API.extended.isObjectMine(data.creationId) and not addon.utils.deepCompare(drafts[data.creationId].class, TRP3_API.extended.getClass(data.creationId)) then
				StaticPopupDialogs["TRP3_SAVE_DISCARD_CANCEL"].text = "Your creation " .. tabButton:GetText() .. " has unsaved changes.|nDo you want to save them?";
				StaticPopupDialogs["TRP3_SAVE_DISCARD_CANCEL"].OnAccept = function()
					addon.main.saveDraft(data.creationId);
					addon.main.deleteDraft(data.creationId);
					tabBar:Close(tabButton);
				end;
				StaticPopupDialogs["TRP3_SAVE_DISCARD_CANCEL"].OnCancel = function()
					addon.main.deleteDraft(data.creationId);
					tabBar:Close(tabButton);
				end;
				local dialog = StaticPopup_Show("TRP3_SAVE_DISCARD_CANCEL");
				if dialog then
					dialog:ClearAllPoints();
					dialog:SetPoint("CENTER", UIParent, "CENTER");
				end
			else
				addon.main.deleteDraft(data.creationId);
				self:Close(tabButton);
			end
		else
			self:Close(tabButton);
		end
	else
		self:Close(tabButton);
	end
end

function TRP3_ToolFrameTabsMixin:OnActivate(tabButton, data)
	
	addon.editor.save();
	addon.editor.reset();

	toolFrame.database:Hide();
	toolFrame.editor:Hide();
	toolFrame.backers:Hide();
	toolFrame.disclaimer:Hide();

	if data.type == TAB_TYPE.DATABASE then
		addon.main.setBackground(1);
		toolFrame.database:Show();
	elseif data.type == TAB_TYPE.CREATION then
		addon.editor.show(data);
		toolFrame.editor:Show();
	elseif data.type == TAB_TYPE.CREDITS then
		addon.main.setBackground(1);
		toolFrame.backers.scroll.child.HTML:SetText(TRP3_API.utils.str.toHTML(TRP3_KS_BACKERS:format(addon.database.formatVersion())));
		toolFrame.backers.scroll.child.HTML:SetScript("OnHyperlinkClick", function(self, url, text, button) -- luacheck: ignore 212
			TRP3_API.Ellyb.Popups:OpenURL(url);
		end)
		toolFrame.backers:Show();
	elseif data.type == TAB_TYPE.DISCLAIMER then
		addon.main.setBackground(1);
		--toolFrame.disclaimer.html:SetText(TRP3_API.utils.str.toHTML(loc.DISCLAIMER)); -- TODO uncomment
		toolFrame.disclaimer.html:SetText(TRP3_API.utils.str.toHTML([[{h1:c}Prototype - please read{/h1}

	You're using a {col:ff0000}Development Version{/col} of the Total RP 3 Extended database!

	Despite my best efforts you may encounter:

	• Missing features
	• Bugs in the user interface
	• Creations that don't work properly
	• Incompatible save files

	{h2}In order to avoid frustration, please make a {col:ff0000}Data Backup{/col} beforehand.{/h2}

	You can find here a tutorial about finding all saved data:
	{link*https://github.com/Total-RP/Total-RP-3/wiki/Saved-Variables*Where are my information stored?}

	You can find here a tutorial about syncing your data to a cloud service:
	{link*https://github.com/Total-RP/Total-RP-3/wiki/How-to-backup-and-synchronize-your-add-ons-settings-using-a-cloud-service*How to backup and synchronize your add-ons settings using a cloud service}

	The latest DEV updates are on {link*https://github.com/Seleves/Total-RP-3-Extended/tree/main*GitHub}.
	Feel free to report problems or post feedback. Please also have a look at the "known issues" section.

	Thank you for testing and your feedback.

	{p:r}Seleves{/p}]])); -- TODO remove
		toolFrame.disclaimer.html.ok:SetScript("OnClick", function()
			TRP3_Tools_Flags.has_seen_disclaimer = true;
			tabBar:Close(tabBar:FindTab(function(data) return data.type == TAB_TYPE.DISCLAIMER; end));
			addon.main.openDatabase();
		end);
		toolFrame.disclaimer.html:SetScript("OnHyperlinkClick", function(_, link)
			TRP3_API.popup.showTextInputPopup(loc.UI_LINK_WARNING, nil, nil, link);
		end);
		toolFrame.disclaimer:Show();
	end
end

function addon.main.openDraft(creationId, forceNewEditor, cursor)
	if not drafts[creationId] then
		drafts[creationId] = addon.editor.createDraft(creationId);
	end
	local existingEditor = not forceNewEditor and addon.main.findDraft(creationId);
	if forceNewEditor or not existingEditor then
		local class = TRP3_API.extended.getClass(creationId);
		local link = TRP3_API.inventory.getItemLink(class, creationId);
		tabBar:AddTabAndActivate({
			label      = link, 
			tooltipHeader = link,
			closeable  = true
		},{
			type       = TAB_TYPE.CREATION,
			creationId = creationId, 
			cursor     = cursor or {
				objectId = creationId
			}
		});
	else
		tabBar:Activate(existingEditor);
	end
end

function addon.main.getDraft(creationId)
	return drafts[creationId];
end

function addon.main.findDraft(creationId)
	return tabBar:FindTab(function(data) return data.creationId == creationId; end);
end

function addon.main.deleteDraft(creationId)
	wipe(drafts[creationId].class);
	wipe(drafts[creationId]);
	drafts[creationId] = nil;
end

function addon.main.saveDraft(creationId)
	local draftClass = drafts[creationId].class;
	draftClass.MD.V = draftClass.MD.V + 1;
	draftClass.MD.SD = date("%d/%m/%y %H:%M:%S");
	draftClass.MD.SB = TRP3_API.globals.player_id;
	draftClass.MD.tV = TRP3_API.globals.extended_version;
	draftClass.MD.dV = TRP3_API.utils.str.sanitizeVersion(TRP3_API.globals.extended_display_version);
	
	local object = TRP3_API.extended.getClass(creationId);
	wipe(object);
	TRP3_API.utils.table.copy(object, draftClass);
	
	TRP3_API.security.computeSecurity(creationId, object);

	-- TODO security level is computed on the database object, not the draft.
	-- that's why the updated security detail needs to be copied back into the draft
	-- Check if this is necessary
	draftClass.securityLevel = object.securityLevel;
	draftClass.details = draftClass.details or {};
	wipe(draftClass.details);
	TRP3_API.utils.table.copy(draftClass.details, object.details);

	TRP3_API.extended.unregisterObject(creationId);
	TRP3_API.extended.registerObject(creationId, object, 0);
	TRP3_API.script.clearRootCompilation(creationId);
	TRP3_API.extended.auras.refresh();
	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.REFRESH_BAG);
	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.REFRESH_CAMPAIGN, creationId);
	addon.database.refreshView();
end

function addon.main.closeAllDrafts(creationId)
	local tabsToClose = {};
	for _, tab in ipairs(tabBar.tabs) do
		if tab.data.type == TAB_TYPE.CREATION and tab.data.creationId == creationId then
			table.insert(tabsToClose, tab);
		end
	end
	for _, tab in pairs(tabsToClose) do
		tabBar:Close(tab);
	end
end

function addon.main.openDatabase()
	local databaseTab = tabBar:FindTab(function(data) return data.type == TAB_TYPE.DATABASE; end);
	if not databaseTab then
		tabBar:AddTabAndActivate({
			label      = loc.DB, 
			closeable  = false
		},{
			type       = TAB_TYPE.DATABASE,
		});
	else
		tabBar:Activate(databaseTab);
	end
end

function addon.main.openDisclaimer()
	local disclaimerTab = tabBar:FindTab(function(data) return data.type == TAB_TYPE.DISCLAIMER; end);
	if not disclaimerTab then
		tabBar:AddTabAndActivate({
			label      = "Before you start...", 
			closeable  = false
		}, {
			type       = TAB_TYPE.DISCLAIMER
		});
	else
		tabBar:Activate(disclaimerTab);
	end
end

function addon.main.openCredits()
	local creditsTab = tabBar:FindTab(function(data) return data.type == TAB_TYPE.CREDITS; end);
	if not creditsTab then
		tabBar:AddTabAndActivate({
			label      = "Credits", 
			closeable  = true
		}, {
			type       = TAB_TYPE.CREDITS, 
		});
	else
		tabBar:Activate(creditsTab);
	end
end

function addon.main.refreshTabs()
	tabBar:Refresh();
end

function addon.main.forEachTab(tabFun)
	for _, tab in pairs(tabBar.tabs) do
		tabFun(tab, tab.data);
	end
end

TRP3_API.extended.tools.goToListPage = addon.main.openDatabase;

-- this API must stay, it is used by the Extended main addon
TRP3_API.extended.tools.goToPage = function(absoluteId)
	addon.main.openDraft(addon.utils.getCreationId(absoluteId), false, {objectId = absoluteId});
end

-- this call was previously exposed to the API
TRP3_API.extended.tools.toList = addon.main.openDatabase;

-- interface for object editors
TRP3_Tools_EditorObjectMixin = {
	Initialize            = function(self) end,
	ClassToInterface      = function(self, class, creationClass, cursor) end,
	InterfaceToClass      = function(self, targetClass, targetCursor) end,
	OnScriptsChanged      = function(self, scripts) end,
	CountScriptReferences = function(self, scriptId) return 0; end,
};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Misc functions
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.truncateDecimals(args, decimals)
	if decimals and tonumber(args) then
		local tenpow = 10 ^ decimals;
		args = tostring( floor( tonumber(args) * tenpow + 0.5 ) / tenpow ) or "0";
	end
	return tostring(args);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function addon.main.showFrame()
	toolFrame:Show();
	toolFrame:Raise();
end
TRP3_API.extended.tools.showFrame = addon.main.showFrame;

function addon.main.toggleFrame()
	if toolFrame:IsVisible() then
		toolFrame:Hide();
	else
		addon.main.showFrame();
	end
end
TRP3_API.extended.tools.toggleFrame = addon.main.toggleFrame;

local function localizeTransformer(text)
	if text and text:match("^%$%{.*%}$") then
		return loc[text:sub(3, -2)] or text;
	end
	return text;
end
local localize;
localize = function(frame)
	local frameType = frame.GetFrameType and frame:GetFrameType();
	
	if frame.Localize then
		frame:Localize(localizeTransformer);
	elseif (frameType == "Button") and frame.GetText and frame.SetText then
		frame:SetText(localizeTransformer(frame:GetText()));
	end
	for _, region in pairs({frame:GetRegions()}) do
		if region.GetText and region.SetText then
			region:SetText(localizeTransformer(region:GetText()));
		end
	end
	
	for _, child in pairs({frame:GetChildren()}) do
		localize(child);
	end
end
addon.main.localize = localize;

local function onStart()

	localize(toolFrame);
	localize(TRP3_Tools_EditorTrigger);
	localize(TRP3_Tools_EditorEffect);

	PAGE_BY_TYPE[TRP3_DB.types.CAMPAIGN].loc   = loc.TYPE_CAMPAIGN;
	PAGE_BY_TYPE[TRP3_DB.types.QUEST].loc      = loc.TYPE_QUEST;
	PAGE_BY_TYPE[TRP3_DB.types.QUEST_STEP].loc = loc.TYPE_QUEST_STEP;
	PAGE_BY_TYPE[TRP3_DB.types.ITEM].loc       = loc.TYPE_ITEM;
	PAGE_BY_TYPE[TRP3_DB.types.DOCUMENT].loc   = loc.TYPE_DOCUMENT;
	PAGE_BY_TYPE[TRP3_DB.types.DIALOG].loc     = loc.TYPE_DIALOG;
	PAGE_BY_TYPE[TRP3_DB.types.AURA].loc       = loc.TYPE_AURA;

	local DummyDropdownFrame = CreateFrame("Frame");
	UIDropDownMenu_Initialize(DummyDropdownFrame, nop); -- Some voodoo magic to prevent taint due to Edit Mode
	-- TODO check if the voodoo is really needed

	addon.database.initialize(toolFrame.database)
	addon.editor.initialize(toolFrame.editor);
	TRP3_API.extended.tools.initItemQuickEditor(toolFrame);

	addon.global_popups.initialize();
	addon.static_analysis.initialize();
	addon.modal = toolFrame.modalOverlay;

	-- Button on toolbar
	TRP3_API.RegisterCallback(TRP3_Addon, TRP3_Addon.Events.WORKFLOW_ON_LOADED, function()
		if TRP3_API.toolbar then
			local toolbarButton = {
				id         = "bb_extended_tools",
				icon       = "Inv_engineering_90_toolbox_blue",
				configText = loc.TB_TOOLS,
				tooltip    = loc.TB_TOOLS,
				tooltipSub = TRP3_API.FormatShortcutWithInstruction("CLICK", loc.TB_TOOLS_TT),
				onClick    = addon.main.toggleFrame,
				visible    = 1
			};
			TRP3_API.toolbar.toolbarAddButton(toolbarButton);
		end
	end);

	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.NAVIGATION_EXTENDED_RESIZED, toolFrame:GetWidth(), toolFrame:GetHeight());

	-- Bindings

	BINDING_NAME_TRP3_EXTENDED_TOOLS = loc.TB_TOOLS;

	TRP3_API.RegisterCallback(TRP3_Addon, TRP3_Addon.Events.WORKFLOW_ON_FINISH, function()
		addon.database.setupFilters();
		if TRP3_Tools_Flags.has_seen_disclaimer then
			--addon.main.openDisclaimer(); -- TODO remove
			addon.main.openDatabase(); -- TODO uncomment
		else
			addon.main.openDisclaimer();
		end
		
	end);

	TRP3_API.ui.frame.setupMove(toolFrame);
end

local function onInit()
	toolFrame = TRP3_ToolFrame;
	
	tabBar = TRP3_ToolFrameTabs;

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
	["name"]         = "Extended Tools",
	["description"]  = "Total RP 3 extended tools: item, document and campaign creation.",
	["version"]      = TRP3_API.globals.extended_version,
	["id"]           = "trp3_extended_tools",
	["onStart"]      = onStart,
	["onInit"]       = onInit,
	["minVersion"]   = TRP3_API.globals.required_trp3_build,
	["requiredDeps"] = {
		{"trp3_extended", TRP3_API.globals.extended_version},
	}
};

TRP3_API.module.registerModule(MODULE_STRUCTURE);
