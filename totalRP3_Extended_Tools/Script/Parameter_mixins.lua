local _, addon = ...
local loc = TRP3_API.loc;

TRP3_Tools_ScriptParameterMixin = {};

function TRP3_Tools_ScriptParameterMixin:Setup(widgetContext, parameter)
	-- NOP
end

function TRP3_Tools_ScriptParameterMixin:GetScriptContext()
	return nil, nil;
end

function TRP3_Tools_ScriptParameterMixin:SetScriptContext(contextFunction)
	self.GetScriptContext = contextFunction;
end

function TRP3_Tools_ScriptParameterMixin:GetGridDimensions()
	return 1, 1; -- gridWidth, gridHeight
end

TRP3_Tools_ScriptParameterEditBoxMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterEditBoxMixin:Setup(widgetContext, parameter)
	self.editBox.titleText = parameter.title;
	self.editBox.helpText = parameter.description;
	addon.main.localize(self.editBox);
	if parameter.onChange then
		self.editBox:SetScript("OnTextChanged", function()
			parameter.onChange(self, widgetContext);
		end);
	else
		self.editBox:SetScript("OnTextChanged", nil);
	end
	if parameter.taggable then
		self.editBox:SetupSuggestions("Tag", function(menu, onAccept) 
			addon.editor.populateObjectTagMenu(menu, onAccept, self.GetScriptContext());
		end);
	else
		self.editBox:SetupSuggestions(nil);
	end
end

function TRP3_Tools_ScriptParameterEditBoxMixin:SetValue(value)
	self.editBox:SetText(tostring(value or ""));
end

function TRP3_Tools_ScriptParameterEditBoxMixin:GetValue()
	return self.editBox:GetText();
end

TRP3_Tools_ScriptParameterObjectiveMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterObjectiveMixin:Setup(widgetContext, parameter)
	self.objectiveId.titleText = parameter.title;
	self.objectiveId.helpText = parameter.description;
	addon.main.localize(self.objectiveId);
	if parameter.onChange then
		self.objectiveId:SetScript("OnTextChanged", function()
			parameter.onChange(self, widgetContext);
		end);
	else
		self.objectiveId:SetScript("OnTextChanged", nil);
	end
	self:SetQuestContext(nil);
end

function TRP3_Tools_ScriptParameterObjectiveMixin:SetQuestContext(questId)
	self.questId = strtrim(questId or "");
	if self.questId == "" then
		self.questId = nil;
	end
	if self.questId then
		self.objectiveId:SetupSuggestions("Objective", function(menu, onAccept) 
			local OB;
			if addon.editor.getCurrentObjectAbsoluteId() == self.questId then
				OB = addon.editor.getCurrentPropertiesEditor():ListObjectives();
			elseif addon.editor.getCurrentDraftClass(self.questId) then
				local questClass = addon.editor.getCurrentDraftClass(self.questId);
				if questClass.TY == TRP3_DB.types.QUEST then
					OB = questClass.OB;
				end
			else
				local questClass = TRP3_API.extended.getClass(self.questId);
				if questClass ~= TRP3_DB.missing and questClass.TY == TRP3_DB.types.QUEST then
					OB = questClass.OB;
				end
			end
			if OB and TableHasAnyEntries(OB) then
				menu:SetScrollMode(400);
				local objectives = {};
				for id, objective in pairs(OB) do
					table.insert(objectives, {ID = id, TX = objective.TX});
				end
				table.sort(objectives, function(a, b) return a.ID < b.ID; end)
				for _, objective in ipairs(objectives) do
					local objectiveButton = menu:CreateButton(objective.ID, onAccept, objective.ID);
					TRP3_MenuUtil.SetElementTooltip(objectiveButton, objective.TX);
				end
			else
				local dummyOption = menu:CreateButton("(no objectives available)", onAccept);
				dummyOption:SetEnabled(false);
			end
		end, true);
	else
		self.objectiveId:SetupSuggestions(nil);
	end
end

function TRP3_Tools_ScriptParameterObjectiveMixin:SetValue(value)
	self.objectiveId:SetText(tostring(value or ""));
end

function TRP3_Tools_ScriptParameterObjectiveMixin:GetValue()
	return self.objectiveId:GetText();
end

TRP3_Tools_ScriptParameterDropdownMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterDropdownMixin:Setup(widgetContext, parameter)
	self.dropdown.titleText = parameter.title;
	self.dropdown.helpText = parameter.description;
	addon.main.localize(self.dropdown);
	local onChangeCallback;
	if parameter.onChange then
		onChangeCallback = function()
			parameter.onChange(self, widgetContext);
		end
	end
	TRP3_API.ui.listbox.setupListBox(self.dropdown, parameter.dropdownValues, onChangeCallback);
end

function TRP3_Tools_ScriptParameterDropdownMixin:SetValue(value)
	self.dropdown:SetSelectedValue(value);
end

function TRP3_Tools_ScriptParameterDropdownMixin:GetValue()
	return self.dropdown:GetSelectedValue();
end

TRP3_Tools_ScriptParameterVariableMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterVariableMixin:Setup(widgetContext, nameParameter, scopeParameter)
	self.name.titleText = nameParameter.title;
	self.name.helpText = nameParameter.description;
	addon.main.localize(self.name);
	self.name:SetupSuggestions("Variable", function(menu, onAccept) 
		local variables = addon.editor.gatherVariables(select(1, self:GetScriptContext()), nameParameter.scope or self.scope:GetSelectedValue());
		if variables and TableHasAnyEntries(variables) then
			menu:SetScrollMode(400);
			local varsSorted = {};
			for name, objective in pairs(variables) do
				table.insert(varsSorted, name);
			end
			table.sort(varsSorted)
			for _, name in ipairs(varsSorted) do
				menu:CreateButton(name, onAccept, name);
			end
		else
			local dummyOption = menu:CreateButton("(no suggestions available)", onAccept);
			dummyOption:SetEnabled(false);
		end
	end, true);
	if scopeParameter then
		self.scope.titleText = scopeParameter.title;
		self.scope.helpText = scopeParameter.description;
		addon.main.localize(self.scope);
		self.scope:Show();
		self.name:SetPoint("LEFT", self, "CENTER", 5, 0);
		local onChangeCallback;
		if scopeParameter.onChange then
			onChangeCallback = function()
				scopeParameter.onChange(self, widgetContext);
			end
		end
		TRP3_API.ui.listbox.setupListBox(self.scope, scopeParameter.dropdownValues, onChangeCallback);
	else
		self.scope:Hide();
		TRP3_API.ui.listbox.setupListBox(self.scope, TRP3_API.globals.empty);
		self.name:SetPoint("LEFT");
	end
end

function TRP3_Tools_ScriptParameterVariableMixin:SetValue(name, scope)
	self.name:SetText(tostring(name or ""));
	self.scope:SetSelectedValue(scope);
end

function TRP3_Tools_ScriptParameterVariableMixin:GetValue()
	return self.name:GetText(), self.scope:GetSelectedValue();
end

TRP3_Tools_ScriptParameterCoordinateMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterCoordinateMixin:Setup(widgetContext, parameterX, parameterY)
	self.x.titleText = parameterX.title;
	self.x.helpText = parameterX.description;
	addon.main.localize(self.x);
	self.y.titleText = parameterY.title;
	self.y.helpText = parameterY.description;
	addon.main.localize(self.y);
	self.here.titleText = loc.OP_OP_DISTANCE_CURRENT;
	addon.main.localize(self.here);
end

function TRP3_Tools_ScriptParameterCoordinateMixin:SetValue(x, y)
	self.x:SetText(x);
	self.y:SetText(y);
end

function TRP3_Tools_ScriptParameterCoordinateMixin:GetValue()
	return self.x:GetText(), self.y:GetText();
end

function TRP3_Tools_ScriptParameterCoordinateMixin:Here()
	local uY, uX = UnitPosition("player");
	self.x:SetText(string.format("%.2f", uX or 0));
	self.y:SetText(string.format("%.2f", uY or 0));
end

function TRP3_Tools_ScriptParameterCoordinateMixin:OnSizeChanged()
	local w = math.floor((self:GetWidth() - self.here:GetWidth() - 10) / 2);
	self.x:SetWidth(w);
	self.y:SetWidth(w);
	self.y:SetPoint("TOPLEFT", w + 5, 0);
end

TRP3_Tools_ScriptParameterObjectMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterObjectMixin:Setup(widgetContext, parameter)
	self.id.titleText = parameter.title;
	self.id.helpText = parameter.description;
	addon.main.localize(self.id);
	local s = self;
	self.browse:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.OBJECTS, {function(id)
			s.id:SetText(id);
		end, addon.script.parameter.objectMap[parameter.type]});
	end);
	if parameter.onChange then
		self.id:SetScript("OnTextChanged", function()
			parameter.onChange(self, widgetContext);
		end);
	else
		self.id:SetScript("OnTextChanged", nil);
	end
	if parameter.taggable then
		self.id:SetupSuggestions("Tag", function(menu, onAccept) 
			addon.editor.populateObjectTagMenu(menu, onAccept, self.GetScriptContext());
		end);
	else
		self.id:SetupSuggestions(nil);
	end
end

function TRP3_Tools_ScriptParameterObjectMixin:SetValue(value)
	self.id:SetText(tostring(value or ""));
end

function TRP3_Tools_ScriptParameterObjectMixin:GetValue()
	return strtrim(self.id:GetText());
end

TRP3_Tools_ScriptParameterSoundMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterSoundMixin:Setup(widgetContext, soundParameter, soundFileParameter)
	self.id.titleText = soundParameter.title;
	self.id.helpText = soundParameter.description;
	addon.main.localize(self.id);
	if soundFileParameter then
		self.soundFileId.titleText = soundFileParameter.title;
		self.soundFileId.helpText = soundFileParameter.description;
		addon.main.localize(self.soundFileId);
		self.soundFileId:Show();
	else
		self.soundFileId:Hide();
	end
	self.play:SetText(loc.EFFECT_SOUND_PLAY);
	self.play:SetScript("OnClick", function()
		local soundID = tonumber(strtrim(self.id:GetText()));
		if soundID then
			if self.soundFileId:GetChecked() then
				TRP3_API.utils.music.playSoundFileID(soundID, self.channel or "SFX");
			else
				TRP3_API.utils.music.playSoundID(soundID, self.channel or "SFX");
			end
		end
	end);
end

function TRP3_Tools_ScriptParameterSoundMixin:SetValue(soundValue, soundFileValue)
	self.id:SetText(tostring(soundValue or ""));
	self.soundFileId:SetChecked(soundFileValue == true);
end

function TRP3_Tools_ScriptParameterSoundMixin:GetValue()
	return tonumber(strtrim(self.id:GetText())), self.soundFileId:GetChecked();
end

TRP3_Tools_ScriptParameterBooleanMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterBooleanMixin:Setup(widgetContext, parameter)
	self.value.titleText = parameter.title;
	self.value.helpText = parameter.description;
	addon.main.localize(self.value);
end

function TRP3_Tools_ScriptParameterBooleanMixin:SetValue(value)
	self.value:SetChecked(value == true);
end

function TRP3_Tools_ScriptParameterBooleanMixin:GetValue()
	return self.value:GetChecked();
end

TRP3_Tools_ScriptParameterMultilineMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterMultilineMixin:Setup(widgetContext, parameter)
	self.text.titleText = parameter.title;
	self.text.helpText = parameter.description;
	addon.main.localize(self.text);
	if parameter.taggable then
		self.text:SetupSuggestions("Tag", function(menu, onAccept) 
			addon.editor.populateObjectTagMenu(menu, onAccept, self.GetScriptContext());
		end);
	else
		self.text:SetupSuggestions(nil);
	end
end

function TRP3_Tools_ScriptParameterMultilineMixin:SetValue(value)
	self.text:SetText(value);
end

function TRP3_Tools_ScriptParameterMultilineMixin:GetValue()
	return self.text:GetText();
end

function TRP3_Tools_ScriptParameterMultilineMixin:GetGridDimensions()
	return 2, 3; -- gridWidth, gridHeight
end

TRP3_Tools_ScriptParameterMusicMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterMusicMixin:Setup(widgetContext, parameter)
	self.id.titleText = parameter.title;
	self.id.helpText = parameter.description;
	addon.main.localize(self.id);
	self.browse:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.MUSICS, {function(id) self.id:SetText(id); end});
	end);
	self.play:SetText(loc.EFFECT_SOUND_PLAY);
	self.play:SetScript("OnClick", function()
		TRP3_API.utils.music.playMusic(self.id:GetText());
	end);
end

function TRP3_Tools_ScriptParameterMusicMixin:SetValue(value)
	self.id:SetText(tostring(value or ""));
end

function TRP3_Tools_ScriptParameterMusicMixin:GetValue()
	return strtrim(self.id:GetText());
end

TRP3_Tools_ScriptParameterEmoteMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterEmoteMixin:Setup(widgetContext, parameter)
	self.id.titleText = parameter.title;
	self.id.helpText = parameter.description;
	addon.main.localize(self.id);
	self.browse:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.EMOTES, {function(id) self.id:SetText(id); end});
	end);
end

function TRP3_Tools_ScriptParameterEmoteMixin:SetValue(value)
	self.id:SetText(tostring(value or ""));
end

function TRP3_Tools_ScriptParameterEmoteMixin:GetValue()
	return strtrim(self.id:GetText());
end

TRP3_Tools_ScriptParameterIconMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterIconMixin:Setup(widgetContext, parameter)
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.icon, "RIGHT", 0, 5, parameter.description);
	self.title:SetText(parameter.title);
	if parameter.onChange then
		self.onChangeCallback = function()
			parameter.onChange(self, widgetContext);
		end
	else
		self.onChangeCallback = function() end;	
	end
	self.icon:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.ICONS, {function(icon) self:SetValue(icon); end, nil, nil, self.icon.selectedIcon});
	end);
end

function TRP3_Tools_ScriptParameterIconMixin:SetValue(value)
	self.icon.Icon:SetTexture("Interface\\ICONS\\" .. value);
	self.icon.selectedIcon = value;
	self.onChangeCallback();
end

function TRP3_Tools_ScriptParameterIconMixin:GetValue()
	return self.icon.selectedIcon;
end

function TRP3_Tools_ScriptParameterIconMixin:GetGridDimensions()
	return 1, 2; -- gridWidth, gridHeight
end

TRP3_Tools_ScriptParameterLootMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterLootMixin:Setup(widgetContext, parameter)
	self.bag.close:Disable();
	self.bag.LockIcon:Hide();
	self.bag.DurabilityText:Hide();
	self.bag.WeightText:Hide();
	self.bag.Bottom:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Bank");
	self.bag.Middle:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Bank");
	self.bag.Top:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Bank");
	self.help:SetText(loc.EFFECT_ITEM_LOOT_SLOT);
	TRP3_API.inventory.initContainerSlots(self.bag, 2, 4, true, function(slot, button, down)
		if down then
			return
		end
		if button == "LeftButton" then
			if self.bag.editor:IsVisible() and self.bag.editor.current == slot then
				self.bag.editor:Hide();
			else
				TRP3_API.ui.frame.configureHoverFrame(self.bag.editor, slot, "RIGHT", -10, 0);
				self.bag.editor:SetFrameStrata("DIALOG");
				self.bag.editor:SetFrameLevel(slot:GetFrameLevel() + 20);
				self.bag.editor.current = slot;
				local data = slot.info or TRP3_API.globals.empty;
				self.bag.editor.id:SetText(data.classID or "");
				self.bag.editor.count:SetText(data.count or "1");
				self.bag.editor:Show();
			end
		else
			slot.info = nil;
			self.bag.editor:Hide();
		end
	end);
	self.bag.editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = self.bag.editor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			self.bag.editor.id:SetText(id);
		end, TRP3_DB.types.ITEM}); -- TODO revisit this, probably beneficial to streamline this part
		-- addon.modal:ShowModal(TRP3_API.popup.OBJECTS, {function(id)
		-- 	self.bag.editor.id:SetText(id);
		-- end, TRP3_DB.types.ITEM});
	end);
	self.bag.editor.save:SetScript("OnClick", function()
		local classID = strtrim(self.bag.editor.id:GetText());
		local class;
		if addon.editor.getCurrentDraftCreationId() == addon.utils.getCreationId(classID) then
			class = addon.editor.getCurrentDraftClass(classID);
		else
			class = TRP3_API.extended.getClass(classID);
			if class.missing then
				class = nil;
			end
		end
		if class then
			self.bag.editor.current.info = {
				classID = classID,
				count = tonumber(self.bag.editor.count:GetText()) or 1,
			};
			self.bag.editor.current.class = class;
			self.bag.editor:Hide();
		else
			TRP3_API.utils.message.displayMessage("Unknown item", 4);
		end
	end);
	addon.main.localize(self.bag.editor.id);
	addon.main.localize(self.bag.editor.count);
end

function TRP3_Tools_ScriptParameterLootMixin:SetValue(slotData)
	slotData = slotData or TRP3_API.globals.empty;
	self.bag.editor:Hide();
	for index, slot in pairs(self.bag.slots) do
		slot.info = nil;
		slot.class = nil;
		if slotData[index] then
			slot.info = {
				classID = slotData[index].classID,
				count = tonumber(slotData[index].count or 1) or 1,
			};
			if addon.editor.getCurrentDraftCreationId() == addon.utils.getCreationId(slot.info.classID) then
				slot.class = addon.editor.getCurrentDraftClass(slot.info.classID);
			else
				slot.class = TRP3_API.extended.getClass(slot.info.classID);
			end
		end
	end
end

function TRP3_Tools_ScriptParameterLootMixin:GetValue()
	local slotData = {};
	for _, slot in pairs(self.bag.slots) do
		if slot.info then
			table.insert(slotData, {
				classID = slot.info.classID,
				count = slot.info.count,
			});
		end
	end
	return slotData;
end

function TRP3_Tools_ScriptParameterLootMixin:GetGridDimensions()
	return 1, 4; -- gridWidth, gridHeight
end

TRP3_Tools_ScriptParameterOperandMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterOperandMixin:Setup(widgetContext, operandParameter, argumentsParameter)
	self.operandId.titleText = operandParameter.title;
	self.operandId.helpText = operandParameter.description;
	addon.main.localize(self.operandId);
	self.parameterWidgets = self.parameterWidgets or {};
	self.operandArguments = nil;
	local onChangeCallback = function(operandId)
		addon.script.parameter.releaseWidgets(self.parameterWidgets);
		local operandData = {
			id = operandId,
			parameters = self.operandArguments
		};
		if not operandData.parameters then
			operandData.parameters = {};
			addon.script.operand.getDefaultOperandEditorValues(operandData);
		end
		self.operandArguments = nil;
		local skipList = addon.script.operand.acquireOperandEditor(operandData, self.parameterWidgets, self.GetScriptContext);
		local offset = 1;
		for index, widget in ipairs(self.parameterWidgets) do
			if not skipList[index] then
				widget:SetParent(self);
				widget:SetPoint("TOPLEFT", 0, -offset*35);
				widget:SetPoint("RIGHT");
				widget:Show();
				offset = offset + 1;
			end
		end
		if operandParameter.onChange then
			operandParameter.onChange(self, widgetContext);
		end
	end
	TRP3_API.ui.listbox.setupListBox(self.operandId, addon.script.getOperandMenu(), onChangeCallback); -- TODO dynamically added operands won't show if added after this point. Shouldn't be a problem but maybe in the future
end

function TRP3_Tools_ScriptParameterOperandMixin:SetValue(operandId, arguments)
	self.operandArguments = arguments;
	self.operandId:SetSelectedValue(operandId);
end

function TRP3_Tools_ScriptParameterOperandMixin:GetValue()
	local operandData = {
		id = self.operandId:GetSelectedValue(),
		parameters = {}
	};
	addon.script.operand.getOperandEditorValues(operandData, self.parameterWidgets);
	return operandData.id, operandData.parameters;
end

function TRP3_Tools_ScriptParameterOperandMixin:GetGridDimensions()
	return 1, 3; -- gridWidth, gridHeight
end

TRP3_Tools_ScriptParameterScriptMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

local function populateEffectContextMenu(parent, callback)
	TRP3_MenuUtil.CreateContextMenu(parent, function(_, menu)
		for _, effectOrCategory in ipairs(addon.script.getEffectMenu(true)) do
			if type(effectOrCategory[2]) == "table" then
				local subMenu = menu:CreateButton(effectOrCategory[1]);
				for _, effect in ipairs(effectOrCategory[2]) do
					local button = subMenu:CreateButton(("|TInterface\\ICONS\\%s:16:16|t %s"):format(effect[4], effect[1]), callback, effect[2]);
					TRP3_MenuUtil.SetElementTooltip(button, effect[3]);
				end
			else
				local button = menu:CreateButton(("|TInterface\\ICONS\\%s:16:16|t %s"):format(effectOrCategory[4], effectOrCategory[1]), callback, effectOrCategory[2]);
				TRP3_MenuUtil.SetElementTooltip(button, effectOrCategory[3]);
			end
		end
	end);
end

local function populateOperandContextMenu(parent, callback)
	TRP3_MenuUtil.CreateContextMenu(parent, function(_, menu)
		for _, operandOrCategory in ipairs(addon.script.getOperandMenu(false)) do
			if type(operandOrCategory[2]) == "table" then
				local subMenu = menu:CreateButton(operandOrCategory[1]);
				for _, operand in ipairs(operandOrCategory[2]) do
					local button = subMenu:CreateButton(operand[1], callback, operand[2]);
					TRP3_MenuUtil.SetElementTooltip(button, operand[3]);
				end
			else
				local button = menu:CreateButton(operandOrCategory[1], callback, operandOrCategory[2]);
				TRP3_MenuUtil.SetElementTooltip(button, operandOrCategory[3]);
			end
		end
	end);
end

local function populateCodeContextMenu(parent, callback)
	TRP3_MenuUtil.CreateContextMenu(parent, function(_, menu)
		menu:CreateButton("getVar", callback, "getVar(args, \"w\", \"varName\")");
		menu:CreateButton("setVar", callback, "setVar(args, \"w\", \"varName\", \"value\")");
		for _, globalVarName in pairs{"string", "table", "math", "pairs", "ipairs", "next", "select", "unpack", "type", "tonumber", "tostring", "date"} do
			local g = _G[globalVarName];
			if type(g) == "table" then
				local category = menu:CreateButton(globalVarName);
				category:SetScrollMode(400);
				for key, _ in pairs(g) do
					category:CreateButton(globalVarName .. "." .. key, callback, globalVarName .. "." .. key);
				end
			elseif type(g) == "function" then
				menu:CreateButton(globalVarName, callback, globalVarName);
			end
		end
	end);
end

function TRP3_Tools_ScriptParameterScriptMixin:Setup(widgetContext, parameter)
	self.script.titleText = parameter.title;
	self.script.helpText = parameter.description;
	addon.main.localize(self.script);
	self.effect:SetText(loc.EFFECT_SCRIPT_I_EFFECT);
	self.effect:SetScript("OnClick", function() 
		populateEffectContextMenu(self.effect, function(effectId) 
			self:InsertEffectById(effectId);
		end);
	end);
	self.operand:SetText("Insert operand");
	self.operand:SetScript("OnClick", function() 
		populateOperandContextMenu(self.operand, function(operandId)
			self:InsertOperandById(operandId);
		end)
	end);
	self.other:SetText("Insert term");
	self.other:SetScript("OnClick", function() 
		populateCodeContextMenu(self.other, function(code)
			self:InsertCode(code);
		end)
	end);
	self.script:AddTextControl(loc.EFFECT_SCRIPT_I_EFFECT, function(button, widget) 
		populateEffectContextMenu(button, function(effectId) 
			widget:Insert(addon.script.getEffectLua(effectId) .. ";");
		end);
	end);
	self.script:AddTextControl("Insert operand", function(button, widget) 
		populateOperandContextMenu(button, function(operandId) 
			widget:Insert(addon.script.getOperandLua(operandId));
		end);
	end);
	self.script:AddTextControl("Insert term", function(button, widget) 
		populateCodeContextMenu(button, function(code) 
			widget:Insert(code);
		end);
	end);
end

function TRP3_Tools_ScriptParameterScriptMixin:InsertEffectById(effectId)
	self.script:Insert(addon.script.getEffectLua(effectId) .. ";");
end

function TRP3_Tools_ScriptParameterScriptMixin:InsertOperandById(operandId)
	self.script:Insert(addon.script.getOperandLua(operandId));
end

function TRP3_Tools_ScriptParameterScriptMixin:InsertCode(code)
	self.script:Insert(code);
end

function TRP3_Tools_ScriptParameterScriptMixin:SetValue(value)
	self.script:SetText(value);
end

function TRP3_Tools_ScriptParameterScriptMixin:GetValue()
	return self.script:GetText();
end

function TRP3_Tools_ScriptParameterScriptMixin:GetGridDimensions()
	return 2, 4; -- gridWidth, gridHeight
end

TRP3_Tools_ScriptParameterMacroMixin = CreateFromMixins(TRP3_Tools_ScriptParameterMixin);

function TRP3_Tools_ScriptParameterMacroMixin:Setup(widgetContext, parameter)
	self.macro.titleText = parameter.title;
	self.macro.helpText = parameter.description;
	addon.main.localize(self.macro);
	if parameter.taggable then
		self.macro:SetupSuggestions("Tag", function(menu, onAccept) 
			addon.editor.populateObjectTagMenu(menu, onAccept, self.GetScriptContext());
		end);
	else
		self.macro:SetupSuggestions(nil);
	end

	local MAX_CHARACTERS_IN_MACRO = 255;
	local function checkCharactersLimit()
		local macro = self.macro:GetText();
		local numberOfCharactersInMacro = strlen(macro);
		local color = WHITE_FONT_COLOR;
		if numberOfCharactersInMacro > MAX_CHARACTERS_IN_MACRO then
			color = RED_FONT_COLOR;
		end
		self.count:SetTextColor(color:GetRGB())
		self.count:SetText(("%d/%d characters used"):format(numberOfCharactersInMacro, MAX_CHARACTERS_IN_MACRO));
	end

	local textbox = self.macro.scroll.text;

	textbox:HookScript("OnTextChanged", checkCharactersLimit);
	textbox:HookScript("OnEditFocusGained", checkCharactersLimit);

	local function hookLinkInsert(functionName, hook)
		hooksecurefunc(functionName, function(self)
			if IsModifiedClick("CHATLINK") and textbox:HasFocus() then
				textbox:Insert(hook(self));
			end
		end)
	end

	EventRegistry:RegisterCallback("SpellBookItemMixin.OnModifiedClick", function(_, self)
		if IsModifiedClick("CHATLINK") and textbox:HasFocus() then
			textbox:Insert(self.spellBookItemInfo.name);
		end
	end)

	EventRegistry:RegisterCallback("SpellFlyoutPopupButtonMixin.OnClick", function(_, self)
		if IsModifiedClick("CHATLINK") and textbox:HasFocus() then
			textbox:Insert(self.spellName);
		end
	end)
	hookLinkInsert("HandleModifiedItemClick", function(link)
		return C_Item.GetItemInfo(link)
	end)

	local deferRegisterCallback = false;
	if C_AddOns.IsAddOnLoaded("Blizzard_TalentUI") then -- TODO check if this is still relevant "Blizzard_TalentUI" appears to be related to Cata talents only
		hookLinkInsert("HandleGeneralTalentFrameChatLink", function(self)
			return self.name:GetText();
		end);
	else
		deferRegisterCallback = true;
	end

	if C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
		hookLinkInsert("MountListDragButton_OnClick", function(self)
			return GetSpellInfo(self:GetParent().spellID)
		end);
		hookLinkInsert("MountListItem_OnClick", function(self)
			return GetSpellInfo(self:GetParent().spellID)
		end);
		hookLinkInsert("ToySpellButton_OnModifiedClick", function(self)
			return C_Item.GetItemInfo(C_ToyBox.GetToyLink(self.itemID))
		end);
	else
		deferRegisterCallback = true;
	end

	if deferRegisterCallback then
		TRP3_API.RegisterCallback(TRP3_API.GameEvents, "ADDON_LOADED", function(_, name)
			if name == "Blizzard_TalentUI" then
				hookLinkInsert("HandleGeneralTalentFrameChatLink", function(self)
					return self.name:GetText();
				end)
			elseif name == "Blizzard_Collections" then
				hookLinkInsert("MountListDragButton_OnClick", function(self)
					return GetSpellInfo(self:GetParent().spellID)
				end)
				hookLinkInsert("MountListItem_OnClick", function(self)
					return GetSpellInfo(self:GetParent().spellID)
				end)
				hookLinkInsert("ToySpellButton_OnModifiedClick", function(self)
					return C_Item.GetItemInfo(C_ToyBox.GetToyLink(self.itemID))
				end)
			end
		end);
	end

end

function TRP3_Tools_ScriptParameterMacroMixin:SetValue(value)
	self.macro:SetText(value);
end

function TRP3_Tools_ScriptParameterMacroMixin:GetValue()
	return self.macro:GetText();
end

function TRP3_Tools_ScriptParameterMacroMixin:GetGridDimensions()
	return 2, 4; -- gridWidth, gridHeight
end
