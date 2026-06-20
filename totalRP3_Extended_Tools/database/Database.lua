-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local _, addon = ...
local loc = TRP3_API.loc;

---@type Ellyb;
local LibDeflate = LibStub:GetLibrary("LibDeflate");

addon.database = {};

local databaseFrame;
local creationsList;
local filterTabs;

local currentView = {
	filter       = function() return false; end,
	filterResult = {},
	totalCount   = 0,
	searchTerm   = nil,
};

local hasImportExportModule = false;

local SUPPOSED_SERIAL_SIZE_LIMIT = 500000; -- We suppose the text field can only handle 500k pastes
local AUTO_SEARCH_RESULT_SIZE    = 1000; -- The search function will run as the users type their search term if there are not too many (filtered) objects

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- List management: util methods
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function addon.database.formatVersion(version)
	if not version then
		return TRP3_API.utils.str.sanitizeVersion(TRP3_API.globals.extended_display_version);
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
TRP3_API.extended.tools.formatVersion = addon.database.formatVersion;

function addon.database.getClassVersion(creationClass)
	if not creationClass.MD.tV and not creationClass.MD.dV then
		return "?"
	end

	if creationClass.MD.dV then	-- Display version in the creation data (after 1.1.1)
		return creationClass.MD.dV
	elseif (creationClass.MD.tV <= 1012) then	-- No display version (1.1.1 and before)
		return addon.database.formatVersion(creationClass.MD.tV);
	else	-- Shouldn't happen
		return creationClass.MD.tV
	end
end
TRP3_API.extended.tools.getClassVersion = addon.database.getClassVersion;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function addon.database.initialize(frame)
	databaseFrame = frame;
	creationsList = databaseFrame.split.creations.list;
	filterTabs    = databaseFrame.split.creations.filterTabs;

	addon.database.filters.initialize();
	TRP3_Tools_FilterBuilder:Initialize();

	-- search box
	local searchBox = databaseFrame.split.creations.searchBox;
	searchBox.Left:Hide();
	searchBox.Middle:Hide();
	searchBox.Right:Hide();
	searchBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus();
		currentView.searchTerm = TRP3_API.utils.str.emptyToNil(strtrim(self:GetText()));
		addon.database.runSearch(true);
	end);
	searchBox:SetScript("OnTextChanged", function(self, isUserInput)
		self.Instructions:SetShown(self:GetText() == "");
		if (isUserInput and #currentView.filterResult <= AUTO_SEARCH_RESULT_SIZE) or self:GetText() == "" then
			currentView.searchTerm = TRP3_API.utils.str.emptyToNil(strtrim(self:GetText()));
			addon.database.runSearch(true);
		end
	end);

	-- Events
	TRP3_API.RegisterCallback(TRP3_Extended, TRP3_Extended.Events.ON_OBJECT_UPDATED, function(_, objectID, objectType) -- luacheck: ignore 212
		addon.database.refreshView();
	end);

	creationsList.model:SetSortComparator(function(a, b)
		return a.name < b.name;
	end, true);

	databaseFrame.export.title:SetText(loc.DB_EXPORT);
	databaseFrame.export.wagoInfo:SetText(HTML_START .. loc.DB_WAGO_INFO .. HTML_END);
	databaseFrame.export.wagoInfo:SetScript("OnHyperlinkClick", function(self, url)
		TRP3_API.popup.showTextInputPopup(loc.UI_LINK_WARNING, nil, nil, url);
	end);

	databaseFrame.import.wagoInfo:SetText(HTML_START .. loc.DB_IMPORT_TT_WAGO .. HTML_END);
	databaseFrame.import.wagoInfo:SetScript("OnHyperlinkClick", function(self, url)
		TRP3_API.popup.showTextInputPopup(loc.UI_LINK_WARNING, nil, nil, url);
	end);

	databaseFrame.import.title:SetText(loc.DB_IMPORT);
	databaseFrame.import.content.title:SetText(loc.DB_IMPORT_TT);

	databaseFrame.import.save:SetText(loc.DB_IMPORT_WORD);
	databaseFrame.import.save:SetScript("OnClick", function()
		local code = databaseFrame.import.content.scroll.text:GetText();
		local encoded, usesLibDeflate = code:gsub("^%!", "");
		if usesLibDeflate == 1 then
			code = LibDeflate:DecodeForPrint(encoded);
			code = AddOn_TotalRP3.Compression.decompress(code, false);
		end
		code = code:gsub("||", "|");
		local object = TRP3_API.utils.serial.safeDeserialize(code);
		if object and type(object) == "table" and (#object == 3 or #object == 4) then
			local version = object[1];
			local ID = object[2];
			local data = object[3];
			local displayVersion = TRP3_API.utils.str.sanitizeVersion(object[4]);
			local link = TRP3_API.inventory.getItemLink(data);
			local by = data.MD.CB;
			local objectVersion = data.MD.V or 0;
			local type = addon.main.getTypeLocale(data.TY);
			TRP3_API.popup.showConfirmPopup(loc.DB_IMPORT_FULL_CONFIRM:format(type, link, by, objectVersion), function()
				C_Timer.After(0.25, function()
					addon.database.importCreation(version, ID, data, displayVersion);
					addon.database.refreshView(); -- After importing go to full database, so we see what we have imported
					-- TODO make sure the imported object is visible
				end);
			end);
		else
			TRP3_API.utils.message.displayMessage(loc.DB_IMPORT_ERROR1, 2);
		end
	end);

	-- Detect import/export module
	hasImportExportModule = C_AddOns.IsAddOnLoaded("totalRP3_Extended_ImpExport");
	if hasImportExportModule then
		if not TRP3_Extended_ImpExport then
			TRP3_Extended_ImpExport = {};
		end
		if TRP3_Tools_Flags.exportAlert then
			TRP3_Tools_Flags.exportAlert = nil;
			TRP3_API.utils.message.displayMessage(loc.DB_EXPORT_DONE, 2);
		end
	end

end
TRP3_API.extended.tools.initList = addon.database.initialize; -- TODO consider removing this from the API

local function addNewFilterTab()
	filterTabs:AddTab({
		label         = "|TInterface\\PaperDollInfoFrame\\Character-Plus:16:16|t",
		tooltipHeader = "Add filter",
		tooltipBody   = TRP3_API.FormatShortcutWithInstruction("LCLICK", "add a new filter"),
		closeable     = false,
	}, {
		newFilterDummy = true,
		persistent    = false,
		editable      = false
	});
end

function addon.database.setupFilters()
	assert(TableIsEmpty(filterTabs.tabs), "database filters already set up");

	local FILTER_ALL_CREATIONS = {
		{nil, "IS_CREATION", true}
	};
	local FILTER_MY_CREATIONS = {
		{nil, "IS_CREATION", true},
		{"AND", "IS_MINE", true}
	};
	local FILTER_INNER_CREATIONS = {
		{nil, "IS_CREATION", true},
		{"AND", "IS_INNER", true}
	};

	filterTabs:AddTabAndActivate({
		label         = "All creations",
		tooltipHeader = "All creations",
		tooltipBody   = addon.database.filters.formatFilter(FILTER_ALL_CREATIONS) .. "|n|n" ..
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "apply filter"),
		closeable     = false,
	}, {
		name          = "All creations",
		filter        = addon.database.filters.compileFilter(FILTER_ALL_CREATIONS),
		persistent    = false,
		editable      = false
	});
	filterTabs:AddTab({
		label         = "My creations",
		tooltipHeader = "My creations",
		tooltipBody   = addon.database.filters.formatFilter(FILTER_MY_CREATIONS) .. "|n|n" ..
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "apply filter"),
		closeable     = false,
	}, {
		name          = "My creations",
		filter        = addon.database.filters.compileFilter(FILTER_MY_CREATIONS),
		persistent    = false,
		editable      = false
	});
	filterTabs:AddTab({
		label         = "Backer's creations",
		tooltipHeader = "Backer's creations",
		tooltipBody   = addon.database.filters.formatFilter(FILTER_INNER_CREATIONS) .. "|n|n" ..
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "apply filter"),
		closeable     = false,
	}, {
		name          = "Backer's creations",
		filter        = addon.database.filters.compileFilter(FILTER_INNER_CREATIONS),
		persistent    = false,
		editable      = false
	});

	for _, filter in ipairs(TRP3_Tools_Parameters.filters or TRP3_API.globals.empty) do
		if type(filter.name) == "string" and type(filter.conditions) == "table" then
			filterTabs:AddTab({
				label            = filter.name,
				tooltipHeader    = filter.name,
				tooltipBody      =
					addon.database.filters.formatFilter(filter.conditions) .. "|n|n" ..
					TRP3_API.FormatShortcutWithInstruction("LCLICK", "apply filter") .. "|n" ..
					TRP3_API.FormatShortcutWithInstruction("RCLICK", loc.DB_ACTIONS),
				closeable        = true,
			}, {
				name             = filter.name,
				filter           = addon.database.filters.compileFilter(filter.conditions),
				filterConditions = filter.conditions,
				persistent       = true,
				persistentData   = filter,
				editable         = true
			});
		end
	end

	addNewFilterTab();

	filterTabs:Refresh();
end

function addon.database.runFilter()
	wipe(currentView.filterResult);
	local totalCount = 0;
	for absoluteId, class in pairs(TRP3_DB.global or TRP3_API.globals.empty) do
		local creationId = addon.utils.getCreationId(absoluteId);
		if currentView.filter(creationId, absoluteId, class) then
			local isCreation    = absoluteId == creationId;
			local creationClass = isCreation and class or TRP3_API.extended.getClass(creationId);
			local link          = ("|T%s:20:20|t %s"):format(addon.utils.getObjectIconAndLink(class));
			local creationLink  = isCreation and link or ("|T%s:20:20|t %s"):format(addon.utils.getObjectIconAndLink(creationClass));
			local MD            = creationClass.MD or TRP3_API.globals.empty;
			local tooltip =
				("Object id: |cff00ffff%s|r|n"):format(absoluteId) ..
				("Type: |cffffff00%s|r|n"):format(addon.main.getTypeLocale(class.TY)) ..
				(not isCreation and ("Inner object of: %s|n"):format(creationLink) or "") ..
				(not isCreation and ("Creation id: |cff00ffff%s|r|n"):format(creationId) or "") ..
				("%s: |cffffff00%s|r|n"):format(loc.ROOT_VERSION, MD.V or 1) ..
				("%s: |cffffff00%s|r|n"):format(loc.ROOT_CREATED_BY, MD.CB or "?") ..
				("%s: |cffffff00%s|r|n"):format(loc.ROOT_CREATED_ON, MD.CD or "?") ..
				("%s: |cffffff00%s|r|n|n"):format(loc.SEC_LEVEL, TRP3_API.security.getSecurityText(creationClass.securityLevel or TRP3_API.security.SECURITY_LEVEL.LOW)) ..
				TRP3_API.FormatShortcutWithInstruction("LCLICK", loc.CM_OPEN) .. "|n" ..
				TRP3_API.FormatShortcutWithInstruction("RCLICK", loc.DB_ACTIONS)
			;
			table.insert(currentView.filterResult, {
				type         = class.TY,
				link         = link,
				creationLink = creationLink,
				creationId   = creationId,
				absoluteId   = absoluteId,
				name         = (class.BA and class.BA.NA) or addon.main.getTypeLocale(class.TY),
				creator      = (creationClass.MD and creationClass.MD.CB) or "unknown",
				isMine       = TRP3_API.extended.isObjectMine(creationId),
				tooltip      = tooltip
			});
		end
		totalCount = totalCount + 1;
	end
	currentView.totalCount = totalCount;
end

function addon.database.runSearch(resetScrollPercentage)
	local scrollPct = resetScrollPercentage and 0 or creationsList.widget:GetScrollPercentage();
	local searchResult;
	if currentView.searchTerm then
		searchResult = {};
		local term = currentView.searchTerm:lower();
		for _, object in ipairs(currentView.filterResult) do
			if object.absoluteId:lower():find(term) or object.name:lower():find(term) then
				table.insert(searchResult, object);
			end
		end
	else
		searchResult = currentView.filterResult;
	end
	databaseFrame.split.creations.filterText:SetText(("showing %d out of %d objects"):format(#searchResult, currentView.totalCount));
	creationsList.model:Flush();
	creationsList.model:InsertTable(searchResult);
	creationsList.widget:SetScrollPercentage(scrollPct);
end

function addon.database.setFilter(filter, filterName)
	currentView.filter = filter;
	currentView.searchTerm = nil;
	databaseFrame.split.creations.searchBox:SetText("");
	databaseFrame.split.creations.searchBox.Instructions:SetText("search in: " .. filterName);
	addon.database.refreshView(true);
end

function addon.database.refreshView(resetScrollPercentage)
	addon.database.runFilter();
	addon.database.runSearch(resetScrollPercentage);
end

function addon.database.suggestFilterName()
	local index = 1;
	local name = "Filter " .. index;
	while filterTabs:FindTab(function(tabData) return tabData.name == name; end) do
		index = index + 1;
		name = "Filter " .. index;
	end
	return name;
end

function addon.database.addFilter(filterName, filterConditions, persistent)
	local newTab = filterTabs:FindTab(function(tabData) return tabData.newFilterDummy == true; end);
	newTab:SetText(filterName);
	newTab:SetCloseable(true);
	local tooltip =
		addon.database.filters.formatFilter(filterConditions) .. "|n|n" ..
		TRP3_API.FormatShortcutWithInstruction("LCLICK", "apply filter") .. "|n" ..
		TRP3_API.FormatShortcutWithInstruction("RCLICK", loc.DB_ACTIONS)
	;
	newTab:SetTooltip(filterName, tooltip);
	newTab.data = {
		name             = filterName,
		filterConditions = filterConditions,
		filter           = addon.database.filters.compileFilter(filterConditions),
		persistent       = persistent,
		editable         = true
	};
	if persistent then
		newTab.data.persistentData = {
			name       = filterName,
			conditions = filterConditions
		};
		TRP3_Tools_Parameters.filters = TRP3_Tools_Parameters.filters or {};
		table.insert(TRP3_Tools_Parameters.filters, newTab.data.persistentData);
	end
	filterTabs:Activate(newTab); -- should be already active, but let's make sure
	addon.database.setFilter(newTab.data.filter, filterName);

	addNewFilterTab();
	filterTabs:Refresh();
end

function addon.database.updateFilter(tab, filterName, filterConditions, persistent)
	tab:SetText(filterName);
	local tooltip =
		addon.database.filters.formatFilter(filterConditions) .. "|n|n" ..
		TRP3_API.FormatShortcutWithInstruction("LCLICK", "apply filter") .. "|n" ..
		TRP3_API.FormatShortcutWithInstruction("RCLICK", loc.DB_ACTIONS)
	;
	tab:SetTooltip(filterName, tooltip);
	tab.data.name             = filterName;
	tab.data.filterConditions = filterConditions;
	tab.data.filter           = addon.database.filters.compileFilter(filterConditions);
	tab.data.persistent       = persistent;
	if persistent then
		if not tab.data.persistentData then
			tab.data.persistentData = {};
			TRP3_Tools_Parameters.filters = TRP3_Tools_Parameters.filters or {};
			table.insert(TRP3_Tools_Parameters.filters, tab.data.persistentData);
		end
		tab.data.persistentData.name = filterName;
		tab.data.persistentData.conditions = filterConditions;
	else
		if tab.data.persistentData then
			tDeleteItem(TRP3_Tools_Parameters.filters, tab.data.persistentData);
			tab.data.persistentData = nil;
		end
	end
	if tab:IsActive() then
		addon.database.setFilter(tab.data.filter, filterName);
		filterTabs:Refresh();
	else
		filterTabs:Activate(tab);
	end
end

function addon.database.removeFilter(tab, data)
	if data.persistent and TRP3_Tools_Parameters.filters then
		tDeleteItem(TRP3_Tools_Parameters.filters, data.persistentData);
	end
	filterTabs:Close(tab);
end

function addon.database.resetNewFilterTab()
	local newTab = filterTabs:FindTab(function(tabData) return tabData.newFilterDummy == true; end);
	if newTab:IsActive() then
		filterTabs:Close(newTab);
		addNewFilterTab();
		filterTabs:Refresh();
	end
end

function addon.database.removeCreation(creationId)
	addon.main.closeAllDrafts(creationId);
	TRP3_API.extended.removeObject(creationId);
	addon.database.refreshView();
end

function addon.database.serializeCreation(creationId)
	local class = TRP3_API.extended.getClass(creationId);
	local serial = TRP3_API.utils.serial.serialize({TRP3_API.globals.extended_version, creationId, class, TRP3_API.utils.str.sanitizeVersion(TRP3_API.globals.extended_display_version)});
	serial = serial:gsub("|", "||");
	serial = AddOn_TotalRP3.Compression.compress(serial, false);
	serial = "!" .. LibDeflate:EncodeForPrint(serial);
	if serial:len() < SUPPOSED_SERIAL_SIZE_LIMIT then
		databaseFrame.export.content.scroll.text:SetText(serial);
		databaseFrame.export.content.title:SetText(loc.DB_EXPORT_HELP:format(TRP3_API.inventory.getItemLink(class), serial:len() / 1024));
		databaseFrame.export:Show();
	else
		TRP3_API.utils.message.displayMessage(loc.DB_EXPORT_TOO_LARGE:format(serial:len() / 1024), 2);
	end
end

function addon.database.exportCreation(creationId)
	if hasImportExportModule then
		wipe(TRP3_Extended_ImpExport);
		TRP3_Extended_ImpExport.id = creationId;
		TRP3_Extended_ImpExport.object = {};
		TRP3_Extended_ImpExport.date = date("%d/%m/%y %H:%M:%S");
		TRP3_Extended_ImpExport.version = TRP3_API.globals.extended_version;
		TRP3_Extended_ImpExport.display_version = TRP3_API.utils.str.sanitizeVersion(TRP3_API.globals.extended_display_version);
		TRP3_API.utils.table.copy(TRP3_Extended_ImpExport.object, TRP3_API.extended.getClass(creationId));
		TRP3_Tools_Flags.exportAlert = true;
		ReloadUI();
	else
		TRP3_API.utils.message.displayMessage(loc.DB_EXPORT_MODULE_NOT_ACTIVE, 2);
	end
end

function addon.database.copyCreation(creationId)
	local fromClass = TRP3_API.extended.getClass(creationId);
	local copiedData = {};
	local generatedId = TRP3_API.utils.str.id();
	TRP3_API.utils.table.copy(copiedData, fromClass);
	copiedData.MD = {
		MO = copiedData.MD.MO,
		V = 1,
		CD = date("%d/%m/%y %H:%M:%S");
		CB = TRP3_API.globals.player_id,
		SD = date("%d/%m/%y %H:%M:%S");
		SB = TRP3_API.globals.player_id,
	};
	addon.utils.replaceId(copiedData, creationId, generatedId);
	local copyId, _ = TRP3_API.extended.tools.createItem(copiedData, generatedId);
	addon.database.refreshView();
	addon.main.openDraft(copyId);
end

function addon.database.importCreation(version, ID, data, displayVersion)
	local type = data.TY;
	local objectVersion = data.MD.V or 0;
	local author = data.MD.CB;

	displayVersion = TRP3_API.utils.str.sanitizeVersion(displayVersion)

	assert(type and author, "Corrupted import structure.");

	local import = function()
		if TRP3_API.extended.classExists(ID) then
			TRP3_API.extended.removeObject(ID);
		end
		local DB;
		if author == TRP3_API.globals.player_id then
			DB = TRP3_DB.my;
		else
			DB = TRP3_DB.exchange;
		end
		DB[ID] = {};
		TRP3_API.utils.table.copy(DB[ID], data);
		TRP3_API.extended.registerObject(ID, DB[ID], 0);
		TRP3_API.security.registerSender(ID, author);
		databaseFrame.import:Hide();
		addon.database.refreshView();
		TRP3_API.utils.message.displayMessage(loc.DB_IMPORT_DONE, 3);
		TRP3_Extended:TriggerEvent(TRP3_Extended.Events.REFRESH_BAG);
		TRP3_Extended:TriggerEvent(TRP3_Extended.Events.REFRESH_CAMPAIGN);

		if DB[ID].securityLevel ~= 3 then
			TRP3_API.security.showSecurityDetailFrame(ID, databaseFrame:GetParent());
		end
	end

	local checkVersion = function()
		if TRP3_API.extended.classExists(ID) and TRP3_API.extended.getClass(ID).MD.V > objectVersion then
			TRP3_API.popup.showConfirmPopup(loc.DB_IMPORT_VERSION:format(objectVersion, TRP3_API.extended.getClass(ID).MD.V), function()
				C_Timer.After(0.25, import);
			end);
		else
			import();
		end
	end

	if version ~= TRP3_API.globals.extended_version then
		TRP3_API.popup.showConfirmPopup(loc.DB_IMPORT_CONFIRM:format(displayVersion or addon.database.formatVersion(version), addon.database.formatVersion()), function()
			C_Timer.After(0.25, checkVersion);
		end);
	else
		checkVersion();
	end
end
