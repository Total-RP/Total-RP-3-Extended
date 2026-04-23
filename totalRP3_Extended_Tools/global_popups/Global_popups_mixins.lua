local _, addon = ...
local loc = TRP3_API.loc;

local modalLayerPool = CreateFramePool("Frame", nil, "TRP3_Tools_ModalLayer");
local textControlsPool;

TRP3_Tools_ModalOverlayMixin = {};

function TRP3_Tools_ModalOverlayMixin:Initialize()
	self.layers = {};
end

function TRP3_Tools_ModalOverlayMixin:ShowModal(popupId, popupArgs)
	local layer = self:AcquireLayer();
	local popupFrame = TRP3_API.popup.POPUPS[popupId].frame;
	popupFrame.OriginalOnHide = popupFrame:GetScript("OnHide");
	popupFrame:SetScript("OnHide", function()
		if popupFrame.OriginalOnHide then
			popupFrame:OriginalOnHide();
		end
		self:HideLayer(layer);
	end); -- TODO adding OnHide is suboptimal, it could overwrite any existing handler
	TRP3_API.popup.showPopup(popupId, {parent = layer}, popupArgs);
end

function TRP3_Tools_ModalOverlayMixin:HideLayer(layer)
	local doHide = false;
	for _, l in ipairs(self.layers) do
		if doHide or l == layer then
			l:Hide();
			for _, child in pairs({l:GetChildren()}) do
				child:SetScript("OnHide", child.OriginalOnHide);
				child:Hide();
			end
			doHide = true;
		end
	end
end

function TRP3_Tools_ModalOverlayMixin:AcquireLayer()
	for _, layer in ipairs(self.layers) do
		if not layer:IsShown() then
			layer:Show();
			return layer;
		end
	end
	local newLayer = modalLayerPool:Acquire();
	newLayer:SetParent(self);
	newLayer:SetAllPoints();
	if TableHasAnyEntries(self.layers) then
		newLayer:SetFrameLevel(self.layers[#self.layers]:GetFrameLevel() + 1000);
	else
		newLayer:SetFrameLevel(self:GetFrameLevel() + 1000);
	end
	newLayer:Show();
	table.insert(self.layers, newLayer);
	return newLayer;
end

TRP3_Tools_ObjectsBrowserListElementMixin = {};

function TRP3_Tools_ObjectsBrowserListElementMixin:Initialize(data)
	self.data = data;
	self.title:SetText(data.title);
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, data.title, data.tooltip);
end

function TRP3_Tools_ObjectsBrowserListElementMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_ObjectsBrowserListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end

function TRP3_Tools_ObjectsBrowserListElementMixin:OnClick(button)
	if button == "LeftButton" then
		TRP3_Tools_ObjectsBrowser:Select(self.data.absoluteId);
	end
end

TRP3_Tools_ObjectsBrowserMixin = {};

function TRP3_Tools_ObjectsBrowserMixin:Initialize()
	self.filter.box.title:SetText(loc.UI_FILTER);
	TRP3_API.popup.OBJECTS = "objects";
	TRP3_API.popup.POPUPS[TRP3_API.popup.OBJECTS] = {
		frame = self,
		showMethod = function(onSelectCallback, objectType, inventoryMode)
			self.onSelectCallback = onSelectCallback;
			self.title:SetText(loc.DB_BROWSER .. " (" .. addon.main.getTypeLocale(objectType) .. ")")
			self.objectType = objectType;
			self.inventoryMode = inventoryMode;
			self.filter.box:SetText("");
			self.filter.box:SetFocus();
			if not self.inventoryMode then
				addon.editor.updateCurrentObjectDraft(); -- make sure any name/quality changes are reflected properly when opening the browser
			end
			self.filter.restrictToCreation:SetShown(not self.inventoryMode);
			self:Filter();
		end,
	};
	self.filter.box:SetScript("OnTextChanged", function() 
		self:Filter();
	end);
	self.filter.restrictToCreation:SetScript("OnClick", function() 
		self:Filter();
	end);
	addon.main.localize(self.filter.restrictToCreation);
end

function TRP3_Tools_ObjectsBrowserMixin:Select(token)
	self:Close();
	if self.onSelectCallback then
		self.onSelectCallback(token);
	end
end

local function generateObjectsBrowserLineData(absoluteId, classSource, classExists)
	
	local rootClass;
	local class = classSource(absoluteId);

	local partialId = "";
	local title = "";
	for relativeId in absoluteId:gmatch("[^%" .. TRP3_API.extended.ID_SEPARATOR .. "]+") do
		partialId = partialId .. relativeId;
		if classExists(partialId) then
			local _, link = addon.utils.getObjectIconAndLink(classSource(partialId), relativeId);
			if title == "" then
				title = link;
				rootClass = classSource(partialId);
			else
				title = title .. " |TInterface\\\MONEYFRAME\\Arrow-Right-Down:16:16|t" .. link;
			end
		end
		partialId = partialId .. TRP3_API.extended.ID_SEPARATOR;
	end

	local tooltip = "";
	local fieldFormat = "%s: " .. TRP3_API.Colors.Yellow("%s|r");
	tooltip = tooltip .. fieldFormat:format(loc.TYPE, addon.main.getTypeLocale(class.TY));
	tooltip = tooltip .. "|n" .. fieldFormat:format(loc.ROOT_CREATED_BY, (rootClass.MD or TRP3_API.globals.empty).CB or "?");
	tooltip = tooltip .. "|n" .. fieldFormat:format(loc.SEC_LEVEL, TRP3_API.security.getSecurityText(rootClass.securityLevel or SECURITY_LEVEL.LOW));
	if class.TY == TRP3_DB.types.ITEM then
		local base = class.BA or TRP3_API.globals.empty;
		local _, link = addon.utils.getObjectIconAndLink(classSource(absoluteId));
		tooltip = tooltip .. "|n";
		tooltip = tooltip .. "|n" .. TRP3_API.utils.str.icon(base.IC or "temp", 25) .. " " .. link;
		if base.LE or base.RI then
			if base.LE and not base.RI then
				tooltip = tooltip .. "|n" .. TRP3_API.Colors.White(base.LE);
			elseif base.RI and not base.LE then
				tooltip = tooltip .. "|n" .. TRP3_API.Colors.White(base.RI);
			else
				tooltip = tooltip .. "|n" .. TRP3_API.Colors.White(base.LE .. " - " .. base.RI);
			end
		end
		if base.DE then
			local argsStructure = {object = {id = objectID}};
			tooltip = tooltip .. "|n" .. TRP3_API.Colors.Yellow("\"" .. TRP3_API.script.parseArgs(base.DE .. "\"", argsStructure));
		end
		tooltip = tooltip .. "|n" .. TRP3_API.Colors.White(TRP3_API.extended.formatWeight(base.WE or 0) .. " - " .. C_CurrencyInfo.GetCoinTextureString(base.VA or 0));
	end
	tooltip = tooltip .. "|n|n" .. TRP3_API.FormatShortcutWithInstruction("LCLICK", "Select object");	

	return {
		absoluteId = absoluteId,
		title      = title,
		tooltip    = tooltip
	};
end

function TRP3_Tools_ObjectsBrowserMixin:Filter()
	local filterText = strtrim(self.filter.box:GetText():lower());
	local filter;
	if filterText == "" then
		filter = function(value)
			return true;
		end
	else
		filter = function(value)
			return string.find(value:lower(), filterText, 1, true);
		end
	end

	local model = {};
	local total, count = 0, 0;

	local currentCreationId = (not self.inventoryMode and addon.editor.getCurrentDraftCreationId()) or nil;

	if self.inventoryMode or not self.filter.restrictToCreation:GetChecked() then
		for absoluteId, class in pairs(TRP3_DB.global) do
			if not class.hideFromList and class.TY == self.objectType and not addon.utils.isInnerIdOrEqual(currentCreationId, absoluteId) then
				if 
					not self.inventoryMode 
					or class.TY ~= TRP3_DB.types.ITEM 
					or TRP3_API.extended.isObjectMine(absoluteId)
					or not class.BA or not class.BA.PA
				then
					local _, name = addon.main.getClassDataSafeByType(class);
					if filter(absoluteId) or filter(name) then
						table.insert(model, generateObjectsBrowserLineData(absoluteId, TRP3_API.extended.getClass, TRP3_API.extended.classExists));
						count = count + 1;
					end
					total = total + 1;
				end
			end
		end
	end

	if currentCreationId then
		addon.editor.forEachObjectInCurrentDraft(function(absoluteId, relativeId, class)
			if class.TY == self.objectType then
				local _, name = addon.main.getClassDataSafeByType(class);
				if filter(absoluteId) or filter(name) then
					table.insert(model, generateObjectsBrowserLineData(absoluteId, addon.editor.getCurrentDraftClass, addon.editor.currentDraftClassExists));
					count = count + 1;
				end
				total = total + 1;
			end
		end);
	end

	self.filter.total:SetText(count .. " / " .. total);

	table.sort(model, function(a, b) 
		return a.absoluteId < b.absoluteId;
	end);

	self.content.list.model:Flush();
	self.content.list.model:InsertTable(model);
end

function TRP3_Tools_ObjectsBrowserMixin:Close()
	self:Hide();
end

TRP3_Tools_EmotesBrowserListElementMixin = {};

function TRP3_Tools_EmotesBrowserListElementMixin:Initialize(data)
	self.data = data;
	self.token:SetText(data.token);
	self.command:SetText(strjoin(", ", unpack(data.slashCommands)));
	local tooltiptext = strjoin("|n", unpack(data.slashCommands)) .. "|n|n" ..
		TRP3_API.FormatShortcutWithInstruction("LCLICK", "Select emote");
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, data.token, tooltiptext);
end

function TRP3_Tools_EmotesBrowserListElementMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_EmotesBrowserListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end

function TRP3_Tools_EmotesBrowserListElementMixin:OnClick(button)
	if button == "LeftButton" then
		TRP3_Tools_EmotesBrowser:Select(self.data.token);
	end
end

TRP3_Tools_EmotesBrowserMixin = {};

function TRP3_Tools_EmotesBrowserMixin:Initialize()
	self.filter.box.title:SetText(loc.UI_FILTER);

	TRP3_API.popup.EMOTES = "emotes";
	TRP3_API.popup.POPUPS[TRP3_API.popup.EMOTES] = {
		frame = self,
		showMethod = function(onSelectCallback)
			self.onSelectCallback = onSelectCallback;
			self.filter.box:SetText("");
			self.filter.box:SetFocus();
			self:Filter();
		end,
	};
	self.filter.box:SetScript("OnTextChanged", function() 
		self:Filter();
	end);
end

function TRP3_Tools_EmotesBrowserMixin:Select(token)
	self:Close();
	if self.onSelectCallback then
		self.onSelectCallback(token);
	end
end

function TRP3_Tools_EmotesBrowserMixin:Filter()
	local emoteList = addon.utils.getEmoteList();
	local model = {};
	local distance = {};
	local filterStr = strtrim(self.filter.box:GetText()):lower();
	if strlen(filterStr) > 0 then
		for index, emote in ipairs(emoteList) do
			local d = addon.utils.editDistance(emote.token:lower(), filterStr, 0.5);
			for cIndex, command in ipairs(emote.slashCommands) do
				d = math.min(d, addon.utils.editDistance(command:lower(), filterStr, 0.5));
			end
			distance[emote.token] = d;
		end
	end
	for index, emote in ipairs(emoteList) do
		if (distance[emote.token] or 0) < 0.5 then
			table.insert(model, emote);
		end
	end
	table.sort(model, function(emote1, emote2) 
		local delta = (distance[emote1.token] or 0) - (distance[emote2.token] or 0);
		if delta ~= 0 then
			return delta < 0;
		end
		return emote1.token < emote2.token;
	end);
	self.filter.total:SetText(CountTable(model) .. "/" .. CountTable(emoteList));
	self.content.list.model:Flush();
	self.content.list.model:InsertTable(model);
end

function TRP3_Tools_EmotesBrowserMixin:Close()
	self:Hide();
end


TRP3_Tools_VariableInspectorListElementMixin = {};

function TRP3_Tools_VariableInspectorListElementMixin:Initialize(data)
	self.data = data;
	local tooltipTitle;
	local tooltipText;
	if data.keyType == "pop" then
		self.key:SetWidth(self:GetWidth()-10);
		self.key:SetText(TRP3_API.Colors.Grey("Up from: ") .. data.keyText);
		self.value:SetText("");
		self.delete:Hide();

		tooltipTitle = "Current position";
		tooltipText = 
			data.keyText .. "|n|n" ..
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "go one level up")
		;
	elseif data.keyType == "add" then
		self.key:SetWidth(self:GetWidth()-10);
		self.key:SetText(data.keyText);
		self.value:SetText("");
		self.delete:Hide();

		tooltipTitle = "Add variable";
		tooltipText = 
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "add a new variable")
		;
	else
		self.key:SetWidth(200);
		self.key:SetText(data.keyText);
		self.value:SetText(data.valueText);
		self.delete:Show();

		tooltipTitle = "Variable";
		tooltipText = 
			"Identifier: " .. data.keyText .. " (" .. data.keyType .. ")|n" ..
			"Value: " .. data.valueText .. " (" .. data.valueType .. ")|n|n" ..
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "edit value")
		;
	end
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, tooltipTitle, tooltipText);
end

function TRP3_Tools_VariableInspectorListElementMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_VariableInspectorListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end

function TRP3_Tools_VariableInspectorListElementMixin:OnClick(button)
	if button == "LeftButton" then
		if self.data.keyType == "pop" then
			self.data.inspector:StackPop();
		elseif self.data.keyType == "add" then
			self.data.inspector:EditKey(nil);
		elseif self.data.valueType == "table" then
			self.data.inspector:StackPush(self.data.key);
		else
			self.data.inspector:EditKey(self.data.key);
		end
	end
end

function TRP3_Tools_VariableInspectorListElementMixin:OnDelete()
	self.data.inspector:DeleteKey(self.data.key);
end

TRP3_Tools_VariableInspectorMixin = {};

-- will sort numbers before numeric strings before non-numeric strings before rest
-- if you use functions or tables as keys, it's your own fault :-)
local function mixedTypeSort(tableToSort, sortKey)
	table.sort(tableToSort, function(a, b) 
		local va = sortKey and a[sortKey] or a;
		local vb = sortKey and b[sortKey] or b;
		local ta = type(va);
		local tb = type(vb);
		if ta ~= tb then
			return ta < tb;
		elseif ta == "number" then
			return va < vb;
		elseif ta == "string" and tonumber(va) and tonumber(vb) then
			return tonumber(va) < tonumber(vb);
		else
			return tostring(va) < tostring(vb);
		end
	end);
end

function TRP3_Tools_VariableInspectorMixin:Initialize()
	self.instances = {};
	self.stack     = {};
	TRP3_API.popup.VARIABLE_INSPECTOR = "variable_inspector";
	TRP3_API.popup.POPUPS[TRP3_API.popup.VARIABLE_INSPECTOR] = {
		frame = self,
		showMethod = function(absoluteId, objectType)
			self:ShowObject(absoluteId, objectType);
		end,
	};

	local valueTypes = {
		{"String" , "string"},
		{"Number" , "number"},
		{"Boolean", "boolean"},
		{"Table"  , "table"}
	};
	TRP3_API.ui.listbox.setupListBox(self.editor.valueType, valueTypes, function(valueType) 
		self.editor.numberValue:SetShown(valueType == "number");
		self.editor.stringValue:SetShown(valueType == "string");
		self.editor.booleanValue:SetShown(valueType == "boolean");
	end);
	TRP3_API.ui.listbox.setupListBox(self.editor.booleanValue, {
		{loc.OP_BOOL_TRUE,  true},
		{loc.OP_BOOL_FALSE, false}
	});
	self.editor.accept:SetScript("OnClick", function() 

		local top = self.stack[#self.stack];
		local key;

		if not self.keyToUpdate then
			local keyType = self.editor.keyType:GetSelectedValue();
			key = self.editor.key:GetText();
			if keyType == "number" then
				key = tonumber(key);
				if not key then
					TRP3_API.utils.message.displayMessage("The key you entered is not a number.", 4);
					return;
				end
			end
			if top.data and top.data[key] then
				TRP3_API.utils.message.displayMessage("This variable alredy exists.", 4);
				return;
			end
		else
			key = self.keyToUpdate;
		end

		local valueType = self.editor.valueType:GetSelectedValue();
		local value;
		if valueType == "string" then
			value = self.editor.stringValue:GetText();
		elseif valueType == "number" then
			value = tonumber(self.editor.numberValue:GetText());
			if not value then
				TRP3_API.utils.message.displayMessage("The value you entered is not a number.", 4);
				return;
			end
		elseif valueType == "boolean" then
			value = self.editor.booleanValue:GetSelectedValue();
		elseif valueType == "table" then
			value = {};
		else
			TRP3_API.utils.message.displayMessage("You cannot set this type.", 4);
			return;
		end

		if not top.data then -- in case the object has no variables yet, we need to initialize the "vars" field
			local instanceIndex = self.instanceSelection:GetSelectedValue();
			self.instances[instanceIndex].vars = self.instances[instanceIndex].vars or {};
			top.data = self.instances[instanceIndex].vars;
		end

		top.data[key] = value;

		self.editor:Hide();
		self.content:Show();
		self:StackPeek();
	end);
	self.editor.cancel:SetScript("OnClick", function() 
		self.editor:Hide();
		self.content:Show();
	end);

	addon.main.localize(self);
end

function TRP3_Tools_VariableInspectorMixin:ShowObject(absoluteId, objectType)
	wipe(self.instances);
	local locators = {};
	if objectType == TRP3_DB.types.CAMPAIGN then
		if TRP3_API.quest.getQuestLog() and TRP3_API.quest.getQuestLog()[absoluteId] then
			local class = TRP3_API.extended.getClass(absoluteId);
			local link = TRP3_API.inventory.getItemLink(class, absoluteId);
			table.insert(self.instances, TRP3_API.quest.getQuestLog()[absoluteId]);
			table.insert(locators, {link, #locators+1});
		end
	elseif objectType == TRP3_DB.types.ITEM then
		local inventory = TRP3_API.inventory.getInventory();

		local stack = {{item = inventory, locator = ""}};
		while TableHasAnyEntries(stack) do
			local top = table.remove(stack);

			local class = TRP3_API.extended.getClass(top.item.id);
			local link = TRP3_API.inventory.getItemLink(class, top.item.id);

			if top.item.id == absoluteId then
				table.insert(self.instances, top.item);
				table.insert(locators, {top.locator .. " " .. link, #locators+1});
			end
			if type(top.item.content) == "table" then
				local slotsSorted = {};
				for slotKey, _ in pairs(top.item.content) do
					table.insert(slotsSorted, slotKey);
				end
				mixedTypeSort(slotsSorted);
				for _, slotKey in ipairs_reverse(slotsSorted) do
					local locator;
					if top.item == inventory and slotKey == TRP3_API.inventory.QUICK_SLOT_ID then
						locator = "Main inventory";
					elseif top.item == inventory then
						locator = "Inventory slot " .. slotKey;
					else
						locator = top.locator .. " " .. link .. " > slot " .. slotKey;
					end
					table.insert(stack, {item = top.item.content[slotKey], locator = locator});
				end
			end
		end

	elseif objectType == TRP3_DB.types.AURA then
		if TRP3_API.profile.getPlayerCurrentProfile() and TRP3_API.profile.getPlayerCurrentProfile().auras then
			local class = TRP3_API.extended.getClass(absoluteId);
			local link = TRP3_API.inventory.getItemLink(class, absoluteId);		
			for _, aura in pairs(TRP3_API.profile.getPlayerCurrentProfile().auras) do
				if aura.id == absoluteId then
					table.insert(self.instances, aura);
					table.insert(locators, {link, #locators+1});
				end
			end
		end
	end

	TRP3_API.ui.listbox.setupListBox(self.instanceSelection, locators, function(instanceIndex) 
		self:SelectInstance(instanceIndex);
	end);

	self.editor:Hide();
	if TableHasAnyEntries(self.instances) then
		self.instanceSelection:SetSelectedValue(1);
		self.errorText:Hide();
		self.instanceSelection:Show();
		self.content:Show();
	else
		self.instanceSelection:SetSelectedValue(nil);
		self.errorText:Show();
		if objectType == TRP3_DB.types.CAMPAIGN then
			self.errorText:SetText("This campaign isn't activated.");
		elseif objectType == TRP3_DB.types.ITEM then
			self.errorText:SetText("You don't have this item in your inventory.");
		elseif objectType == TRP3_DB.types.AURA then
			self.errorText:SetText("This aura isn't active.");
		else
			self.errorText:SetText("Object not found.");
		end
		self.instanceSelection:Hide();
		self.content:Hide();
	end	

end

function TRP3_Tools_VariableInspectorMixin:SelectInstance(instanceIndex)
	
	wipe(self.stack);

	if instanceIndex and self.instances[instanceIndex] then
		table.insert(self.stack, {
			data = self.instances[instanceIndex].vars,
			locator = "Variables",
			isRoot = true,
		});
	end

	self:StackPeek();

end

function TRP3_Tools_VariableInspectorMixin:StackPeek()
	self.content.list.model:Flush();
	local top = self.stack[#self.stack];
	local model = {};
	if top and top.data then
		for key, value in pairs(top.data) do
			table.insert(model, {
				key       = key,
				keyText   = addon.script.formatters.formatType(key),
				valueText = addon.script.formatters.formatType(value),
				keyType   = type(key),
				valueType = type(value),
				inspector = self
			});
		end
		mixedTypeSort(model, "key");
		if not top.isRoot then
			table.insert(model, 1, {
				keyText   = top.locator,
				keyType   = "pop",
				inspector = self
			});
		end
	end
	if top then
		table.insert(model, {
			keyText   = "|TInterface\\PaperDollInfoFrame\\Character-Plus:16:16|t Add variable",
			keyType   = "add",
			inspector = self
		});
	end
	self.content.list.model:InsertTable(model);
end

function TRP3_Tools_VariableInspectorMixin:StackPush(key)
	local top = self.stack[#self.stack];
	if top and top.data and top.data[key] then
		table.insert(self.stack, {
			data = top.data[key],
			locator = top.locator .. " > " .. addon.script.formatters.formatType(key)
		});
		self:StackPeek();
	end
end

function TRP3_Tools_VariableInspectorMixin:StackPop()
	table.remove(self.stack);
	self:StackPeek();
end

function TRP3_Tools_VariableInspectorMixin:EditKey(key)
	local keyTypes;
	local currKeyType = type(key);
	self.keyToUpdate = key;
	self.editor.keyType:SetEnabled(currKeyType == "nil");
	self.editor.key:SetEnabled(currKeyType == "nil");
	if currKeyType == "nil" then
		keyTypes = {
			{"String", "string"},
			{"Number", "number"},
		};
		currKeyType = "string";
	else
		keyTypes = {
			{"String", "string"},
			{"Number", "number"},
			{"Boolean", "boolean"},
			{"Table", "table"},
			{"Function", "function"}
		};
	end
	TRP3_API.ui.listbox.setupListBox(self.editor.keyType, keyTypes);
	self.editor.keyType:SetSelectedValue(currKeyType);
	self.editor.key:SetText(tostring(key or ""));

	if key then
		local value = self.stack[#self.stack].data[key];
		self.editor.valueType:SetSelectedValue(type(value));
		if type(value) == "string" then
			self.editor.stringValue:SetText(value);
			self.editor.numberValue:SetText(tostring(tonumber(value) or 0));
			self.editor.booleanValue:SetSelectedValue(value:lower() == "true");
		elseif type(value) == "number" then
			self.editor.stringValue:SetText(tostring(value));
			self.editor.numberValue:SetText(tostring(value));
			self.editor.booleanValue:SetSelectedValue(value ~= 0);
		elseif type(value) == "boolean" then
			self.editor.stringValue:SetText(value and "true" or "false");
			self.editor.numberValue:SetText(value and "1" or "0");
			self.editor.booleanValue:SetSelectedValue(value);
		end
	else
		self.editor.valueType:SetSelectedValue("string");
		self.editor.stringValue:SetText("");
		self.editor.numberValue:SetText("0");
		self.editor.booleanValue:SetSelectedValue(false);
	end

	self.editor:Show();
	self.content:Hide();
end

function TRP3_Tools_VariableInspectorMixin:DeleteKey(key)
	local top = self.stack[#self.stack];
	top.data[key] = nil;
	self:StackPeek();
end

function TRP3_Tools_VariableInspectorMixin:Close()
	self:Hide();
end

TRP3_Tools_TextEditorMixin = {};

function TRP3_Tools_TextEditorMixin:Initialize()
	textControlsPool = CreateFramePool("Button", self.content, "TRP3_CommonButton");
	TRP3_API.popup.TEXT_EDITOR = "text_editor";
	TRP3_API.popup.POPUPS[TRP3_API.popup.TEXT_EDITOR] = {
		frame = self,
		showMethod = function(sourceWidget, textControls)
			self:SetPoint("TOPLEFT", 25, -50);
			self:SetPoint("BOTTOMRIGHT", -25, 25);
			self.sourceWidget = sourceWidget;
			self.title:SetText(self.sourceWidget.title:GetText());
			self.content.text:SetText(self.sourceWidget:GetText());
			textControlsPool:ReleaseAll();
			if TableHasAnyEntries(textControls or TRP3_API.globals.empty) then
				self.content.text:SetPoint("TOP", 0, -33);
				for index, textControl in ipairs(textControls) do
					local button = textControlsPool:Acquire();
					button:SetText(textControl.title);
					button:SetScript("OnClick", function() 
						textControl.callback(button, self.content.text);
					end);
					button:SetSize(95, 25);
					button:SetPoint("TOPLEFT", (index-1)*100 + 5, -5);
					button:Show();
				end
			else
				self.content.text:SetPoint("TOP", 0, -5);
			end
		end,
	};
end

function TRP3_Tools_TextEditorMixin:Close()
	if self.sourceWidget then
		self.sourceWidget:SetText(self.content.text:GetText());
	end
	self:Hide();
end

TRP3_Tools_NoteEditorMixin = {};

function TRP3_Tools_NoteEditorMixin:Initialize()
	addon.main.localize(self);
	TRP3_API.popup.NOTE_EDITOR = "note_editor";
	TRP3_API.popup.POPUPS[TRP3_API.popup.NOTE_EDITOR] = {
		frame = self,
		showMethod = function(note, callback)
			self.note.scroll.text:SetText(note or "");
			self.callback = callback;
		end,
	};
end

function TRP3_Tools_NoteEditorMixin:Close()
	self.callback(strtrim(self.note.scroll.text:GetText()));
	self:Hide();
end
