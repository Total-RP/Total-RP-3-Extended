local _, addon = ...
local loc = TRP3_API.loc;

local SECURITY_COLORS = {
	[TRP3_API.security.SECURITY_LEVEL.LOW]    = TRP3_API.Colors.Red,
	[TRP3_API.security.SECURITY_LEVEL.MEDIUM] = TRP3_API.Colors.Orange,
	[TRP3_API.security.SECURITY_LEVEL.HIGH]   = TRP3_API.Colors.Green
};
local function applySecurityColorToTexture(securityLevel, texture)
	local color = SECURITY_COLORS[securityLevel] or TRP3_API.Colors.Grey;
	texture:SetColorTexture(color.r, color.g, color.b, color.a);
end

local TRIGGER_SORT_MAP = {
	[addon.script.triggerType.OBJECT] = 1,
	[addon.script.triggerType.ACTION] = 2,
	[addon.script.triggerType.EVENT] = 3
};
local function sortTriggers(triggers)
	local actionSortIndex = 0;
	local eventSortIndex = 0;
	for _, trigger in ipairs(triggers) do
		if trigger.type == addon.script.triggerType.OBJECT then
			_, trigger.sortIndex = addon.script.getObjectTrigger(addon.editor.getCurrentDraftClass().TY, trigger.id);
		elseif trigger.type == addon.script.triggerType.ACTION then
			actionSortIndex = actionSortIndex + 1;
			trigger.sortIndex = actionSortIndex;
		elseif trigger.type == addon.script.triggerType.EVENT then
			eventSortIndex = eventSortIndex + 1;
			trigger.sortIndex = eventSortIndex;
		else
			trigger.sortIndex = 0;
		end
	end
	table.sort(triggers, function(t1, t2)
		if t1.type ~= t2.type then
			return (TRIGGER_SORT_MAP[t1.type] or 0) < (TRIGGER_SORT_MAP[t2.type] or 0);
		end
		return t1.sortIndex < t2.sortIndex;
	end);
end

TRP3_Tools_EditorScriptMixin = {};

local conditionPreviewTermFramePool = CreateFramePool("Frame", nil, "TRP3_Tools_ScriptConditionTermPreviewTemplate");

function TRP3_Tools_EditorScriptMixin:Initialize()
	addon.script:Initialize();
	self.triggers = {};
	self.scripts = {};
	addon.utils.prepareForMultiSelectionMode(self.effectList);
	addon.utils.prepareForMultiSelectionMode(self.scriptList);
end

function TRP3_Tools_EditorScriptMixin:RenameScript(oldScriptId)
	TRP3_API.popup.showTextInputPopup(loc.WO_ADD_ID, function(newScriptId)
		newScriptId = strtrim(newScriptId or "");
		if oldScriptId ~= newScriptId then
			if newScriptId:len() == 0 or self.scripts[newScriptId] then
				TRP3_API.popup.showAlertPopup(loc.WO_ADD_ID_NO_AVAILABLE);
			else
				self.scripts[newScriptId] = self.scripts[oldScriptId];
				self.scripts[oldScriptId] = nil;
				for _, trigger in ipairs(self.triggers) do
					if trigger.script == oldScriptId then
						trigger.script = newScriptId;
					end
				end
				self:OnScriptsChanged(nil, nil, {[oldScriptId] = newScriptId});
				self:UpdateTriggerList();
				if oldScriptId == self.selectedScriptId then
					self.selectedScriptId = newScriptId;
				end
				self:OnScriptSelected(self.selectedScriptId);
			end
		end
	end, nil, oldScriptId);
end

function TRP3_Tools_EditorScriptMixin:ConvertSelectedScriptEffects(filterFunc)
	local script = self.scripts[self.selectedScriptId];

	local prevIndex;
	local targetIndex;
	local hasCondition = false;
	for index, effect in ipairs(script) do
		if filterFunc(index) then
			targetIndex = targetIndex or index;
			if prevIndex and prevIndex ~= index-1 then
				return false, "Please select effects consecutively.";
			else
				prevIndex = index;
			end
			if effect.id == TRP3_DB.elementTypes.DELAY then
				return false, "Cannot convert delays into Lua.";
			end
			if effect.id == TRP3_DB.elementTypes.CONDITION then
				hasCondition = true;
			end
		elseif hasCondition then
			return false, "Cannot convert a condition unless all following effects are converted as well.";
		end
	end
	local lua = "";
	local else_end = "";

	for index, effect in ipairs(script) do
		if filterFunc(index) then
			local hasConstraint = TableHasAnyEntries(effect.constraint) and effect.id ~= TRP3_DB.elementTypes.CONDITION;
			if hasConstraint then
				lua = lua .. "if " .. addon.script.getConstraintLua(effect.constraint) .. " then\n";
			end
			if effect.id == "script" then
				lua = lua .. effect.parameters[1] .. "\n";
			elseif effect.id == TRP3_DB.elementTypes.CONDITION then
				lua = lua .. "if " .. addon.script.getConstraintLua(effect.constraint) .. " then\n";
				if effect.parameters[1] or effect.parameters[2] then
					else_end = else_end .. "else\n";
					if effect.parameters[1] then
						else_end = else_end .. addon.script.getEffectLua("text", {effect.parameters[1], TRP3_API.utils.message.type.ALERT_MESSAGE}) .. ";\n";
					end
					if effect.parameters[2] then
						else_end = else_end .. addon.script.getEffectLua("run_workflow", {"o", effect.parameters[2]}) .. ";\n";
					end
				end
				else_end = else_end .. "\nend\n";
			else
				lua = lua .. addon.script.getEffectLua(effect.id, effect.parameters) .. ";\n";
			end
			if hasConstraint then
				lua = lua .. "\nend\n";
			end
		end
	end
	lua = lua .. else_end;

	for index, effect in ipairs_reverse(script) do
		if filterFunc(index) then
			if index == targetIndex then
				effect.id = "script";
				wipe(effect.constraint);
				wipe(effect.parameters);
				table.insert(effect.parameters, lua);
			else
				table.remove(script, index);
			end
		end
	end

	return true;
end

function TRP3_Tools_EditorScriptMixin:CountScriptReferences(scriptId)
	local count = addon.editor.getCurrentPropertiesEditor():CountScriptReferences(scriptId);
	for _, trigger in ipairs(self.triggers) do
		if trigger.script == scriptId then
			count = count + 1;
		end
	end
	return count;
end

function TRP3_Tools_EditorScriptMixin:DeleteScript(scriptId)
	if self:CountScriptReferences(scriptId) <= 0 then
		self:DeleteScripts(scriptId);
	else
		TRP3_API.popup.showConfirmPopup("This workflow might still be used.|n|nAre you sure you want to delete it?", function()
			self:DeleteScripts(scriptId);
		end);
	end
end

function TRP3_Tools_EditorScriptMixin:PasteScriptsFromClipboard()
	if not addon.clipboard.isPasteCompatible(addon.clipboard.types.SCRIPT) then
		return;
	end
	for index = 1, addon.clipboard.count() do
		local scriptId = addon.clipboard.retrieveSubId(index);
		if self.scripts[scriptId] then
			TRP3_API.utils.message.displayMessage("A workflow named \"".. scriptId .."\" already exists.", 4);
			return;
		end
	end
	local insertions = {};
	for index = 1, addon.clipboard.count() do
		local scriptId = addon.clipboard.retrieveSubId(index);
		self.scripts[scriptId] = addon.clipboard.retrieve(index);
		insertions[scriptId] = scriptId;
	end
	self:OnScriptsChanged(nil, insertions, nil);
end

function TRP3_Tools_EditorScriptMixin:DeleteScripts(...)
	local deletions = {};
	for _, scriptId in ipairs({...}) do
		if self.scripts[scriptId] then
			self.scripts[scriptId] = nil;
			deletions[scriptId] = scriptId;
		end
	end
	for _, trigger in ipairs(self.triggers) do
		if trigger.script and deletions[trigger.script] then
			trigger.script = nil;
		end
	end
	self:OnScriptsChanged(deletions, nil, nil);
	self:UpdateTriggerList();
	if self.selectedScript and deletions[self.selectedScript] then
		self:OnScriptSelected(nil);
	else
		self:OnScriptSelected(self.selectedScript);
	end
end

function TRP3_Tools_EditorScriptMixin:OnScriptsChanged(deletions, insertions, renamings)
	local changes = {};
	for scriptId, _ in pairs(self.scripts) do
		local change = {
			oldId = scriptId,
			newId = scriptId
		};
		if insertions and insertions[scriptId] then
			change.oldId = nil;
		end
		for oldId, newId in pairs(renamings or TRP3_API.globals.empty) do
			if change.newId == newId then
				change.oldId = oldId;
			end
		end
		table.insert(changes, change);
	end
	for scriptId, _ in pairs(deletions or TRP3_API.globals.empty) do
		table.insert(changes, {
			oldId = scriptId,
			newId = nil
		});
	end
	table.sort(changes, function(a, b) return (a.newId or a.oldId) < (b.newId or b.oldId); end);
	addon.editor.getCurrentPropertiesEditor():OnScriptsChanged(changes);
	self:UpdateScriptList();
end

function TRP3_Tools_EditorScriptMixin:OnTriggerChanged(originalTrigger, newTrigger)
	if originalTrigger then
		wipe(originalTrigger);
		TRP3_API.utils.table.copy(originalTrigger, newTrigger);
	else
		local newTriggerCopy = {};
		TRP3_API.utils.table.copy(newTriggerCopy, newTrigger);
		table.insert(self.triggers, newTriggerCopy);
	end
	if newTrigger.script and not self.scripts[newTrigger.script] then
		self.scripts[newTrigger.script] = {};
		self:OnScriptsChanged(nil, {[newTrigger.script] = newTrigger.script}, nil);
	end
	self:UpdateTriggerList();
	self:OnScriptSelected(newTrigger.script);
end

function TRP3_Tools_EditorScriptMixin:OnEffectApplied(effectData)
	local newEffectData = {};
	TRP3_API.utils.table.copy(newEffectData, effectData);
	if self.effectEditorTarget.replace then
		self.scripts[self.effectEditorTarget.scriptId][self.effectEditorTarget.effectIndex] = newEffectData;
	else
		table.insert(self.scripts[self.effectEditorTarget.scriptId], self.effectEditorTarget.effectIndex, newEffectData);
	end
	self:OnScriptSelected(self.effectEditorTarget.scriptId);
end

function TRP3_Tools_EditorScriptMixin:DeleteEffect(scriptId, effectIndex)
	table.remove(self.scripts[scriptId], effectIndex);
	self:OnScriptSelected(scriptId);
end

function TRP3_Tools_EditorScriptMixin:DeleteTrigger(trigger)
	for index, t in ipairs(self.triggers) do
		if t == trigger then
			table.remove(self.triggers, index);
			break;
		end
	end
	self:UpdateTriggerList();
end

function TRP3_Tools_EditorScriptMixin:GetScriptSecurity(scriptId)
	local security = TRP3_API.security.SECURITY_LEVEL.HIGH;
	for _, effect in ipairs(self.scripts[scriptId]) do
		security = math.min(security, addon.script.getEffectSecurity(effect));
	end
	return security;
end

function TRP3_Tools_EditorScriptMixin:AddScript()
	TRP3_API.popup.showTextInputPopup(loc.WO_ADD_ID, function(newScriptId)
		newScriptId = strtrim(newScriptId or "");
		if newScriptId:len() == 0 or self.scripts[newScriptId] then
			TRP3_API.popup.showAlertPopup(loc.WO_ADD_ID_NO_AVAILABLE);
		else
			self.scripts[newScriptId] = {};
			self:OnScriptsChanged(nil, {[newScriptId] = newScriptId}, nil);
			self:OnScriptSelected(newScriptId);
		end
	end, nil, "");
end

function TRP3_Tools_EditorScriptMixin:OnScriptSelected(scriptId)
	self.selectedScriptId = scriptId;
	if scriptId then
		local effects = {};
		for _, effect in ipairs(self.scripts[scriptId]) do
			table.insert(effects, {
				title   = addon.script.getEffectTitle(effect),
				preview = addon.script.getEffectPreview(effect),
				icon    = "Interface\\Icons\\" .. addon.script.getEffectIcon(effect),
				constraint = self:ConstraintToPreview(effect.constraint, "IF"),
				security = addon.script.getEffectSecurity(effect)
			});
		end
		table.insert(effects, {isAddButton = true});

		self.effectList.model:Flush();
		self.effectList.model:InsertTable(effects);
		self.scriptHeader:Initialize({scriptId = scriptId});
	else
		self.scriptList:Refresh();
	end
	for _, trigger in self.triggerList.model:EnumerateEntireRange() do
		trigger.active = trigger.index and self.triggers[trigger.index].script == scriptId;
	end
	self.triggerList:Refresh();

	self.scriptList:SetShown(scriptId == nil);
	self.effectList:SetShown(scriptId ~= nil);
	self.scriptHeader:SetShown(scriptId ~= nil);
end

function TRP3_Tools_EditorScriptMixin:ConstraintToPreview(constraint, qualifier)
	local constraintPreview = {};
	local orStart;
	local hasAnd = false;
	for index, equation in ipairs(constraint) do
		local equationPreview = {
			expression = addon.script.getOperandPreview(equation.leftTerm) .. " " .. addon.script.getComparatorText(equation.comparator) .. " " .. addon.script.getOperandPreview(equation.rightTerm),
			close = ""
		};
		if index == 1 then
			equationPreview.open = qualifier or "";
		else
			if equation.logicalOperation == addon.script.logicalOperation.OR then
				equationPreview.open = loc.OP_OR;
				orStart = orStart or index - 1;
			elseif equation.logicalOperation == addon.script.logicalOperation.AND then
				equationPreview.open = loc.OP_AND;
				hasAnd = true;
				if orStart then
					constraintPreview[orStart].open = strtrim(constraintPreview[orStart].open .. " (");
					constraintPreview[index-1].close = ")";
					orStart = nil;
				end
			end
		end
		table.insert(constraintPreview, equationPreview);
	end
	if hasAnd and orStart then
		constraintPreview[orStart].open = strtrim(constraintPreview[orStart].open .. " (");
		constraintPreview[#constraintPreview].close = ")";
	end
	return constraintPreview;
end

function TRP3_Tools_EditorScriptMixin:TriggerToPreview(class, trigger, index)
	local triggerPreview = {};
	triggerPreview.index = index;

	triggerPreview.icon, triggerPreview.whenText, triggerPreview.tooltipTitle, triggerPreview.tooltipText = addon.script.getTriggerPreview(class.TY, trigger.id, trigger.type);

	if trigger.script then
		triggerPreview.thenText = ("then start workflow %s"):format(addon.script.formatters.constant(trigger.script));
	else
		triggerPreview.thenText = ("then start workflow %s"):format(addon.script.formatters.unknown(""));
	end
	triggerPreview.constraint = self:ConstraintToPreview(trigger.constraint, "WHILE"); -- TODO
	triggerPreview.active = trigger.script and trigger.script == self.selectedScriptId;
	return triggerPreview;
end

function TRP3_Tools_EditorScriptMixin:ClassToInterface(class, _creationClass, cursor)
	wipe(self.triggers);
	wipe(self.scripts);

	for scriptId, scriptData in pairs(class.SC or TRP3_API.globals.empty) do
		self.scripts[scriptId] = addon.script.getNormalizedEffectListData(scriptData or TRP3_API.globals.empty);
	end

	self.triggers = addon.script.getNormalizedTriggerData(class, self.scripts);
	self:OnScriptsChanged(nil, nil, nil);

	self:UpdateTriggerList();

	if cursor and cursor.scriptId and self.scripts[cursor.scriptId] then
		self:OnScriptSelected(cursor.scriptId);
	else
		self:OnScriptSelected(nil);
	end
end

function TRP3_Tools_EditorScriptMixin:UpdateScriptList()
	local scriptList = {};
	for scriptId, _ in pairs(self.scripts) do
		table.insert(scriptList, {scriptId = scriptId});
	end
	table.sort(scriptList, function(a, b)
		return a.scriptId < b.scriptId;
	end);
	table.insert(scriptList, {isAddButton = true});

	self.scriptList.model:Flush();
	self.scriptList.model:InsertTable(scriptList);
end

function TRP3_Tools_EditorScriptMixin:UpdateTriggerList()
	local triggerList = {};
	local class = addon.editor.getCurrentDraftClass();
	local usedObjectTriggerCount = 0;
	for index, trigger in ipairs(self.triggers) do
		if trigger.type == addon.script.triggerType.OBJECT then
			usedObjectTriggerCount = usedObjectTriggerCount + 1;
		end
		table.insert(triggerList, self:TriggerToPreview(class, trigger, index));
	end
	sortTriggers(triggerList);

	if addon.script.supportsTriggerType(class.TY, addon.script.triggerType.ACTION)
		or addon.script.supportsTriggerType(class.TY, addon.script.triggerType.EVENT)
		or usedObjectTriggerCount < CountTable(addon.script.objectTriggers[class.TY] or TRP3_API.globals.empty)
	then
		table.insert(triggerList, {isAddButton = true});
	end

	self.triggerList.model:Flush();
	self.triggerList.model:InsertTable(triggerList);
end

function TRP3_Tools_EditorScriptMixin:InterfaceToClass(targetClass, targetCursor)
	targetClass.SC = nil;
	for scriptId, script in pairs(self.scripts) do
		targetClass.SC = targetClass.SC or {};
		targetClass.SC[scriptId] = addon.script.getSaveFormatEffectListData(script);
	end

	targetClass.LI = nil;
	targetClass.AC = nil;
	targetClass.HA = nil;

	if targetClass.US then
		targetClass.US.SC = nil;
	end

	for _, trigger in ipairs(self.triggers) do
		if trigger.type == addon.script.triggerType.OBJECT then
			targetClass.LI = targetClass.LI or {};
			targetClass.LI[trigger.id] = trigger.script;
			if targetClass.TY == TRP3_DB.types.ITEM and trigger.id == "OU" then
				targetClass.US = targetClass.US or {};
				targetClass.US.SC = trigger.script;
			end
		elseif trigger.type == addon.script.triggerType.ACTION then
			targetClass.AC = targetClass.AC or {};
			table.insert(targetClass.AC, {
				TY = trigger.id,
				SC = trigger.script,
				CO = addon.script.getSaveFormatConstraintData(trigger.constraint);
			});
		elseif trigger.type == addon.script.triggerType.EVENT then
			targetClass.HA = targetClass.HA or {};
			table.insert(targetClass.HA, {
				EV = trigger.id,
				SC = trigger.script,
				CO = addon.script.getSaveFormatConstraintData(trigger.constraint);
			});
		end
	end

	if targetCursor then
		targetCursor.scriptId = self.selectedScriptId;
	end
end

function TRP3_Tools_EditorScriptMixin:GetVariablesByScope(scope)
	local result = {};
	local variableManipulationEffects = addon.script.getVariableManipulationEffects();
	for _, script in pairs(self.scripts) do
		for _, effect in ipairs(script) do
			if variableManipulationEffects[effect.id] then
				local effectVarSpec = variableManipulationEffects[effect.id];
				for _, variable in pairs(effectVarSpec) do
					if (variable.scopeIndex and effect.parameters[variable.scopeIndex] or variable.scope) == scope then
						if (effect.parameters[variable.nameIndex] or "") ~= "" then
							result[effect.parameters[variable.nameIndex]] = true;
						end
					end
				end
			end
		end
	end
	return result;
end

function TRP3_Tools_EditorScriptMixin:GetWorkflowVariablesFromScript(scriptId)
	local result = {};
	local variableManipulationEffects = addon.script.getVariableManipulationEffects();
	for _, effect in ipairs(self.scripts[scriptId] or TRP3_API.globals.empty) do
		if variableManipulationEffects[effect.id] then
			local effectVarSpec = variableManipulationEffects[effect.id];
			for _, variable in pairs(effectVarSpec) do
				if (variable.scopeIndex and effect.parameters[variable.scopeIndex] or variable.scope) == "w" then
					if (effect.parameters[variable.nameIndex] or "") ~= "" then
						result[effect.parameters[variable.nameIndex]] = true;
					end
				end
			end
		end
	end
	return result;
end

function TRP3_Tools_EditorScriptMixin:GetAuraVariablesSet(auraAbsoluteId)
	local result = {};
	for _, script in pairs(self.scripts) do
		for _, effect in ipairs(script) do
			if effect.id == "aura_var_set" and effect.parameters[1] == auraAbsoluteId and (effect.parameters[1] or "") ~= "" then
				result[effect.parameters[3]] = true;
			end
		end
	end
	return result;
end

function TRP3_Tools_EditorScriptMixin:GetTriggeringGameEventsForScript(scriptId)
	local result;
	for _, trigger in pairs(self.triggers) do
		if trigger.script == scriptId and trigger.type == addon.script.triggerType.EVENT then
			result = result or {};
			result[trigger.id] = true;
		end
	end
	return result;
end

function TRP3_Tools_EditorScriptMixin:HasScriptForTrigger(triggerId, triggerType)
	for _, trigger in pairs(self.triggers) do
		if trigger.id == triggerId and trigger.type == triggerType and trigger.script then
			return true;
		end
	end
	return false;
end

TRP3_Tools_ScriptTriggerListElementMixin = {};

function TRP3_Tools_ScriptTriggerListElementMixin:Initialize(data)
	self.data = data;
	self:Refresh();
end

function TRP3_Tools_ScriptTriggerListElementMixin:Refresh()
	self:Reset();
	self:SetActive(self.data.active);

	local tooltipTitle;
	local tooltipText;

	if self.data.isAddButton then
		self.icon.Icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus");
		self.whenText:SetText("Add trigger");
		self.thenText:SetText("");
		tooltipTitle = "Add trigger";
		tooltipText = TRP3_API.FormatShortcutWithInstruction("LCLICK", "Add trigger");
	else
		self.icon.Icon:SetTexture(self.data.icon);
		self.whenText:SetText(self.data.whenText);
		self.thenText:SetText(self.data.thenText);

		for index, constraint in ipairs(self.data.constraint) do
			local widget = conditionPreviewTermFramePool:Acquire();
			widget:SetParent(self);
			widget:ClearAllPoints();
			widget:SetPoint("TOP", 0, -(12 + index*20));
			widget:SetPoint("LEFT");
			widget:SetPoint("RIGHT");
			widget.open:SetText(constraint.open);
			widget.expression:SetText(constraint.expression);
			widget.close:SetText(constraint.close);
			widget:Show();
			table.insert(self.constraintWidgets, widget);
		end

		tooltipTitle = self.data.whenText;
		tooltipText =
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "edit trigger") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("RCLICK", "more options")
		;
	end
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, tooltipTitle, tooltipText);
end

function TRP3_Tools_ScriptTriggerListElementMixin:SetActive(active)
	self:SetHighlight(active);
	self.highlightArrow:SetShown(active);
	self.whenText:SetPoint("RIGHT", active and -24 or -8, -12);
end

function TRP3_Tools_ScriptTriggerListElementMixin:GetElementExtent(data)
	return data.isAddButton and 40 or (60 + 20*#data.constraint);
end

function TRP3_Tools_ScriptTriggerListElementMixin:Reset()
	self.constraintWidgets = self.constraintWidgets or {};
	for _, widget in ipairs(self.constraintWidgets) do
		conditionPreviewTermFramePool:Release(widget);
	end
	wipe(self.constraintWidgets);
end

function TRP3_Tools_ScriptTriggerListElementMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_ScriptTriggerListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end

function TRP3_Tools_ScriptTriggerListElementMixin:OnClick(button)
	if self.data.isAddButton then
		addon.modal:ShowModal(TRP3_API.popup.TRIGGER, {});
	else
		local trigger = addon.editor.script.triggers[self.data.index];
		if button == "LeftButton" then
			if self.data.active or not trigger.script then
				addon.modal:ShowModal(TRP3_API.popup.TRIGGER, {trigger});
			end
			addon.editor.script:OnScriptSelected(trigger.script);
		elseif button == "RightButton" then
			TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
				local editOption = contextMenu:CreateButton("Edit trigger...", function()
					addon.modal:ShowModal(TRP3_API.popup.TRIGGER, {trigger});
					addon.editor.script:OnScriptSelected(trigger.script);
				end);
				TRP3_MenuUtil.SetElementTooltip(editOption, "Edit trigger...");

				if trigger.script then
					local openOption = contextMenu:CreateButton("Edit workflow...", function()
						addon.editor.script:OnScriptSelected(trigger.script);
					end);
					TRP3_MenuUtil.SetElementTooltip(openOption, "Edit workflow...");
				end

				contextMenu:CreateDivider();
				local deleteTriggerOption = contextMenu:CreateButton("Delete trigger", function()
					addon.editor.script:DeleteTrigger(trigger);
				end);
				TRP3_MenuUtil.SetElementTooltip(deleteTriggerOption, "Delete trigger");

				if trigger.script then
					local deleteTriggerAndScriptOption = contextMenu:CreateButton("Delete trigger and workflow", function()
						if addon.editor.script:CountScriptReferences(trigger.script) <= 1 then
							addon.editor.script:DeleteScripts(trigger.script);
							addon.editor.script:DeleteTrigger(trigger);
						else
							TRP3_API.popup.showConfirmPopup("This workflow might still be used.|n|nAre you sure you want to delete it?", function()
								addon.editor.script:DeleteScripts(trigger.script);
								addon.editor.script:DeleteTrigger(trigger);
							end);
						end
					end);
					TRP3_MenuUtil.SetElementTooltip(deleteTriggerAndScriptOption, "Delete trigger and workflow");
				end
			end);
		end
	end
end

TRP3_Tools_ScriptEffectListElementMixin = {};

function TRP3_Tools_ScriptEffectListElementMixin:Initialize(data)
	self.data = data;
	self:Refresh();
end

function TRP3_Tools_ScriptEffectListElementMixin:Refresh()
	self:Reset();
	local tooltipTitle;
	local tooltipText;
	if not self.data.isAddButton then
		self.icon.Icon:SetTexture(self.data.icon);
		self.title:SetText(self:GetElementDataIndex() .. ". " .. self.data.title);
		self.preview:SetText(self.data.preview);
		applySecurityColorToTexture(self.data.security, self.securityIndicator);
		for index, constraint in ipairs(self.data.constraint) do
			local widget = conditionPreviewTermFramePool:Acquire();
			widget:SetParent(self);
			widget:ClearAllPoints();
			widget:SetPoint("TOP", 0, -(12 + index*20));
			widget:SetPoint("LEFT");
			widget:SetPoint("RIGHT");
			widget.open:SetText(constraint.open);
			widget.expression:SetText(constraint.expression);
			widget.close:SetText(constraint.close);
			widget:Show();
			table.insert(self.constraintWidgets, widget);
		end
		tooltipTitle = self:GetElementDataIndex() .. ". " .. self.data.title;

		tooltipText =
			"Effect security: " .. TRP3_API.security.getSecurityText(self.data.security or TRP3_API.security.SECURITY_LEVEL.LOW)  .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "edit effect") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("RCLICK", "more options") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("SHIFT-CLICK", "select range") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("CTRL-CLICK", "select this effect")
		;
	else
		self.icon.Icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus");
		self.title:SetText("Add effect");
		self.preview:SetText("");
		applySecurityColorToTexture(0, self.securityIndicator);
		tooltipTitle = "Add effect";
		tooltipText = TRP3_API.FormatShortcutWithInstruction("LCLICK", "Add effect");
	end
	self.delete:SetShown(not self.data.isAddButton);
	self:SetSelected(self.data.selected);
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, tooltipTitle, tooltipText);
end

function TRP3_Tools_ScriptEffectListElementMixin:GetElementExtent(data)
	return not data.isAddButton and (68 + 20*#data.constraint) or 40;
end

function TRP3_Tools_ScriptEffectListElementMixin:Reset()
	self.constraintWidgets = self.constraintWidgets or {};
	for _, widget in ipairs(self.constraintWidgets) do
		conditionPreviewTermFramePool:Release(widget);
	end
	wipe(self.constraintWidgets);
end

function TRP3_Tools_ScriptEffectListElementMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_ScriptEffectListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end

function TRP3_Tools_ScriptEffectListElementMixin:OnClick(button)
	local scriptId = addon.editor.script.selectedScriptId;
	if not scriptId or not addon.editor.script.scripts[scriptId] then
		return;
	end
	local effectIndex = addon.editor.script.effectList.model:FindIndex(self.data);

	if self.data.isAddButton then
		if button == "LeftButton" then
			addon.editor.script.effectEditorTarget = {
				scriptId    = scriptId,
				effectIndex = effectIndex,
				replace     = false
			};
			addon.modal:ShowModal(TRP3_API.popup.EFFECT, {nil, scriptId});
		elseif button == "RightButton" then
			TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
				local addOption = contextMenu:CreateButton("Add effect...", function()
					addon.editor.script.effectEditorTarget = {
						scriptId    = scriptId,
						effectIndex = effectIndex,
						replace     = false
					};
					addon.modal:ShowModal(TRP3_API.popup.EFFECT, {nil, scriptId});
				end);
				TRP3_MenuUtil.SetElementTooltip(addOption, "Add effect...");

				local script = addon.editor.script.scripts[scriptId];
				if TableIsEmpty(script) and addon.clipboard.isPasteCompatible(addon.clipboard.types.EFFECT) then
					local count = addon.clipboard.count();
					local optionText;
					if count == 1 then
						optionText = "Paste effect";
					else
						optionText = "Paste " .. count .. " effects";
					end

					local pasteOption = contextMenu:CreateButton(optionText, function()
						for index = 1, count do
							table.insert(script, index, addon.clipboard.retrieve(index));
						end
						addon.editor.script:OnScriptSelected(scriptId);
					end);
					TRP3_MenuUtil.SetElementTooltip(pasteOption, optionText);
				end

			end);
		end
	else
		local effect = addon.editor.script.scripts[scriptId][effectIndex];
		if button == "LeftButton" then
			if IsControlKeyDown() then
				addon.editor.script.effectList:ToggleSingleSelect(self.data);
			elseif IsShiftKeyDown() then
				addon.editor.script.effectList:ToggleRangeSelect(self.data);
			else
				addon.editor.script.effectEditorTarget = {
					scriptId    = scriptId,
					effectIndex = effectIndex,
					replace     = true
				};
				addon.modal:ShowModal(TRP3_API.popup.EFFECT, {effect, scriptId});
			end
		elseif button == "RightButton" then
			TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
				local editOption = contextMenu:CreateButton("Edit effect...", function()
					addon.editor.script.effectEditorTarget = {
						scriptId    = scriptId,
						effectIndex = effectIndex,
						replace     = true
					};
					addon.modal:ShowModal(TRP3_API.popup.EFFECT, {effect, scriptId});
				end);
				TRP3_MenuUtil.SetElementTooltip(editOption, "Edit effect...");

				contextMenu:CreateDivider();
				local addBeforeOption = contextMenu:CreateButton("Insert effect before", function()
					addon.editor.script.effectEditorTarget = {
						scriptId    = scriptId,
						effectIndex = effectIndex,
						replace     = false
					};
					addon.modal:ShowModal(TRP3_API.popup.EFFECT, {nil, scriptId});
				end);
				TRP3_MenuUtil.SetElementTooltip(addBeforeOption, "Insert a new effect before this effect");

				local addAfterOption = contextMenu:CreateButton("Insert effect after", function()
					addon.editor.script.effectEditorTarget = {
						scriptId    = scriptId,
						effectIndex = effectIndex + 1,
						replace     = false
					};
					addon.modal:ShowModal(TRP3_API.popup.EFFECT, {nil, scriptId});
				end);
				TRP3_MenuUtil.SetElementTooltip(addAfterOption, "Insert a new effect after this effect");

				contextMenu:CreateDivider();
				local convertOption = contextMenu:CreateButton("Convert to Lua effect", function()
					local success, message = addon.editor.script:ConvertSelectedScriptEffects(function(index)
						return index == effectIndex;
					end);
					if success then
						addon.editor.script:OnScriptSelected(scriptId);
					else
						TRP3_API.utils.message.displayMessage(message, 4);
					end
				end);
				TRP3_MenuUtil.SetElementTooltip(convertOption, "Converts the effect to its equivalent in a Lua effect");

				if self.data.selected then
					local convertSelectedOption = contextMenu:CreateButton("Convert selected to Lua effect", function()
						local filter = {};
						for index, element in addon.editor.script.effectList.model:EnumerateEntireRange() do
							if element.selected then
								filter[index] = true;
							end
						end
						local success, message = addon.editor.script:ConvertSelectedScriptEffects(function(index)
							return filter[index];
						end);
						if success then
							addon.editor.script:OnScriptSelected(scriptId);
						else
							TRP3_API.utils.message.displayMessage(message, 4);
						end
					end);
					TRP3_MenuUtil.SetElementTooltip(convertSelectedOption, "Converts selected effects to their equivalent Lua script");
				end

				local convertAllOption = contextMenu:CreateButton("Convert workflow to Lua", function()
					local success, message = addon.editor.script:ConvertSelectedScriptEffects(function(_index)
						return true;
					end);
					if success then
						addon.editor.script:OnScriptSelected(scriptId);
					else
						TRP3_API.utils.message.displayMessage(message, 4);
					end
				end);
				TRP3_MenuUtil.SetElementTooltip(convertAllOption, "Converts the workflow to its equivalent Lua script");

				contextMenu:CreateDivider();
				local copyOption = contextMenu:CreateButton("Copy", function()
					addon.clipboard.clear();
					addon.clipboard.append(effect, addon.clipboard.types.EFFECT);
				end);
				TRP3_MenuUtil.SetElementTooltip(copyOption, "Copy this effect");

				if self.data.selected then
					local copySelectionOption = contextMenu:CreateButton("Copy selected effects", function()
						addon.clipboard.clear();
						for index, element in addon.editor.script.effectList.model:EnumerateEntireRange() do
							if element.selected then
								addon.clipboard.append(addon.editor.script.scripts[scriptId][index], addon.clipboard.types.EFFECT);
							end
						end
						addon.editor.script.effectList:SetAllSelected(false);
					end);
					TRP3_MenuUtil.SetElementTooltip(copySelectionOption, "Copy all selected effects");
				end

				local copyAllOption = contextMenu:CreateButton("Copy all effects", function()
					addon.clipboard.clear();
					for index, element in addon.editor.script.effectList.model:EnumerateEntireRange() do
						if not element.isAddButton then
							addon.clipboard.append(addon.editor.script.scripts[scriptId][index], addon.clipboard.types.EFFECT);
						end
					end
				end);
				TRP3_MenuUtil.SetElementTooltip(copyAllOption, "Copy all effects");

				if addon.clipboard.isPasteCompatible(addon.clipboard.types.EFFECT) then
					local count = addon.clipboard.count();
					local script = addon.editor.script.scripts[scriptId];

					local beforeText, afterText;
					if count == 1 then
						beforeText = "Paste effect before";
						afterText = "Paste effect after";
					else
						beforeText = "Paste " .. count .. " effects before";
						afterText = "Paste " .. count .. " effects after";
					end

					local pasteBeforeOption = contextMenu:CreateButton(beforeText, function()
						for index = 1, count do
							table.insert(script, effectIndex + index - 1, addon.clipboard.retrieve(index));
						end
						addon.editor.script:OnScriptSelected(scriptId);
					end);
					TRP3_MenuUtil.SetElementTooltip(pasteBeforeOption, beforeText);

					local pasteAfterOption = contextMenu:CreateButton(afterText, function()
						for index = 1, count do
							table.insert(script, effectIndex + index, addon.clipboard.retrieve(index));
						end
						addon.editor.script:OnScriptSelected(scriptId);
					end);
					TRP3_MenuUtil.SetElementTooltip(pasteAfterOption, afterText);
				end

				contextMenu:CreateDivider();

				local deleteTriggerOption = contextMenu:CreateButton("Delete effect", function()
					addon.editor.script:DeleteEffect(scriptId, effectIndex);
				end);
				TRP3_MenuUtil.SetElementTooltip(deleteTriggerOption, "Delete effect");

				if self.data.selected then
					local deleteSelectionOption = contextMenu:CreateButton("Delete selected effects", function()
						local newScript = {};
						for index, element in addon.editor.script.effectList.model:EnumerateEntireRange() do
							if not element.isAddButton and not element.selected then
								table.insert(newScript, addon.editor.script.scripts[scriptId][index]);
							end
						end
						wipe(addon.editor.script.scripts[scriptId]);
						addon.editor.script.scripts[scriptId] = newScript;
						addon.editor.script:OnScriptSelected(scriptId);
					end);
					TRP3_MenuUtil.SetElementTooltip(deleteSelectionOption, "Delete selected effects");
				end
			end);
		end
	end
end

function TRP3_Tools_ScriptEffectListElementMixin:OnDelete()
	local scriptId = addon.editor.script.selectedScriptId;
	local effectIndex = addon.editor.script.effectList.model:FindIndex(self.data);
	addon.editor.script:DeleteEffect(scriptId, effectIndex);
end

TRP3_Tools_ScriptScriptListElementMixin = {};

function TRP3_Tools_ScriptScriptListElementMixin:Initialize(data)
	self.data = data;
	self:Refresh();
end

function TRP3_Tools_ScriptScriptListElementMixin:Refresh()
	local tooltipTitle;
	local tooltipText;
	if not self.data.isAddButton then
		self.title:SetText(self.data.scriptId);
		local scriptSecurity = addon.editor.script:GetScriptSecurity(self.data.scriptId);
		applySecurityColorToTexture(scriptSecurity, self.securityIndicator);
		tooltipTitle = self.data.scriptId;
		tooltipText =
			"Workflow security: " .. TRP3_API.security.getSecurityText(scriptSecurity)  .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "edit workflow") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("RCLICK", "more options") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("SHIFT-CLICK", "select range") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("CTRL-CLICK", "select this workflow")
		;
	else
		self.title:SetText("|TInterface\\PaperDollInfoFrame\\Character-Plus:16:16|t " .. loc.WO_ADD);
		applySecurityColorToTexture(0, self.securityIndicator);
		tooltipTitle = loc.WO_ADD;
		tooltipText = TRP3_API.FormatShortcutWithInstruction("LCLICK", loc.WO_ADD);
	end
	self.delete:SetShown(not self.data.isAddButton);
	self:SetSelected(self.data.selected);

	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, tooltipTitle, tooltipText);
end

function TRP3_Tools_ScriptScriptListElementMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_ScriptScriptListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end

function TRP3_Tools_ScriptScriptListElementMixin:OnClick(button)

	if self.data.isAddButton then
		if button == "LeftButton" then
			addon.editor.script:AddScript();
		elseif button == "RightButton" then
			TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
				local addOption = contextMenu:CreateButton(loc.WO_ADD, function()
					addon.editor.script:AddScript();
				end);
				TRP3_MenuUtil.SetElementTooltip(addOption, loc.WO_ADD);

				if addon.clipboard.isPasteCompatible(addon.clipboard.types.SCRIPT) then
					local count = addon.clipboard.count();
					local pasteText;
					if count == 1 then
						pasteText = "Paste workflow";
					else
						pasteText = "Paste " .. count .. " workflows";
					end
					local pasteOption = contextMenu:CreateButton(pasteText, function()
						addon.editor.script:PasteScriptsFromClipboard();
					end);
					TRP3_MenuUtil.SetElementTooltip(pasteOption, pasteText);
				end
			end);
		end
	else
		if button == "LeftButton" then
			if IsControlKeyDown() then
				addon.editor.script.scriptList:ToggleSingleSelect(self.data);
			elseif IsShiftKeyDown() then
				addon.editor.script.scriptList:ToggleRangeSelect(self.data);
			else
				addon.editor.script:OnScriptSelected(self.data.scriptId);
			end
		elseif button == "RightButton" then
			TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
				local editOption = contextMenu:CreateButton("Edit workflow...", function()
					addon.editor.script:OnScriptSelected(self.data.scriptId);
				end);
				TRP3_MenuUtil.SetElementTooltip(editOption, "Edit workflow...");

				local renameOption = contextMenu:CreateButton("Rename workflow...", function()
					addon.editor.script:RenameScript(self.data.scriptId);
				end);
				TRP3_MenuUtil.SetElementTooltip(renameOption, "Rename workflow...");

				contextMenu:CreateDivider();
				local copyOption = contextMenu:CreateButton("Copy", function()
					addon.clipboard.clear();
					addon.clipboard.append(addon.editor.script.scripts[self.data.scriptId], addon.clipboard.types.SCRIPT, nil, nil, self.data.scriptId);
				end);
				TRP3_MenuUtil.SetElementTooltip(copyOption, "Copy this workflow");

				if self.data.selected then
					local copySelectionOption = contextMenu:CreateButton("Copy selected workflows", function()
						addon.clipboard.clear();
						for _, element in addon.editor.script.scriptList.model:EnumerateEntireRange() do
							if element.selected then
								addon.clipboard.append(addon.editor.script.scripts[element.scriptId], addon.clipboard.types.SCRIPT, nil, nil, element.scriptId);
							end
						end
						addon.editor.script.scriptList:SetAllSelected(false);
					end);
					TRP3_MenuUtil.SetElementTooltip(copySelectionOption, "Copy all selected workflows");
				end

				if addon.clipboard.isPasteCompatible(addon.clipboard.types.SCRIPT) then
					local count = addon.clipboard.count();
					local pasteText;
					if count == 1 then
						pasteText = "Paste workflow";
					else
						pasteText = "Paste " .. count .. " workflows";
					end
					local pasteOption = contextMenu:CreateButton(pasteText, function()
						addon.editor.script:PasteScriptsFromClipboard();
					end);
					TRP3_MenuUtil.SetElementTooltip(pasteOption, pasteText);
				end

				contextMenu:CreateDivider();
				local deleteOption = contextMenu:CreateButton(DELETE, function()
					self:OnDelete();
				end);
				TRP3_MenuUtil.SetElementTooltip(deleteOption, DELETE);

			end);
		end
	end
end

function TRP3_Tools_ScriptScriptListElementMixin:OnDelete()
	addon.editor.script:DeleteScript(self.data.scriptId);
end

TRP3_Tools_ScriptScriptHeaderMixin = CreateFromMixins(TRP3_Tools_ScriptScriptListElementMixin);

function TRP3_Tools_ScriptScriptHeaderMixin:Refresh()
	local tooltipTitle;
	local tooltipText;

	self.title:SetText("|A:common-icon-exit:20:20|a" .. self.data.scriptId);
	local scriptSecurity = addon.editor.script:GetScriptSecurity(self.data.scriptId);
	applySecurityColorToTexture(scriptSecurity, self.securityIndicator);
	tooltipTitle = self.data.scriptId;
	tooltipText =
		"Workflow security: " .. TRP3_API.security.getSecurityText(scriptSecurity)  .. "|n" ..
		TRP3_API.FormatShortcutWithInstruction("LCLICK", "back to workflows") .. "|n" ..
		TRP3_API.FormatShortcutWithInstruction("RCLICK", "more options")
	;

	self.delete:SetShown(true);
	self:SetSelected(false);

	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, tooltipTitle, tooltipText);
end

function TRP3_Tools_ScriptScriptHeaderMixin:OnClick(button)
	if button == "LeftButton" then
		addon.editor.script:OnScriptSelected(nil);
	elseif button == "RightButton" then
		TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
			local backOption = contextMenu:CreateButton("Back to workflows", function()
				addon.editor.script:OnScriptSelected(nil);
			end);
			TRP3_MenuUtil.SetElementTooltip(backOption, "Back to workflows");

			local renameOption = contextMenu:CreateButton("Rename workflow...", function()
				addon.editor.script:RenameScript(self.data.scriptId);
			end);
			TRP3_MenuUtil.SetElementTooltip(renameOption, "Rename workflow...");

			contextMenu:CreateDivider();
			local deleteOption = contextMenu:CreateButton(DELETE, function()
				self:OnDelete();
			end);
			TRP3_MenuUtil.SetElementTooltip(deleteOption, DELETE);

		end);
	end
end
