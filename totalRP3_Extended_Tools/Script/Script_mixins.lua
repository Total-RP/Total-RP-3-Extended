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
	for index, trigger in ipairs(triggers) do
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
	self.scriptControls.rename:SetScript("OnClick", function()
		self:RenameSelectedScript();
	end);
	self.scriptControls.delete:SetScript("OnClick", function()
		self:DeleteSelectedScript();
	end);
	addon.utils.prepareForMultiSelectionMode(self.effectList);
end

function TRP3_Tools_EditorScriptMixin:RenameSelectedScript()
	local oldScriptId = self.scriptList:GetSelectedValue();
	if oldScriptId and self.scripts[oldScriptId] then
		TRP3_API.popup.showTextInputPopup(loc.WO_ADD_ID, function(newScriptId)
			newScriptId = strtrim(newScriptId or "");
			if oldScriptId == newScriptId then
				-- nothing to do
			elseif newScriptId:len() == 0 or self.scripts[newScriptId] then
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
				self.scriptList:SetSelectedValue(newScriptId);
			end
		end, nil, oldScriptId);
	end
end

function TRP3_Tools_EditorScriptMixin:ConvertSelectedScriptEffects(filterFunc)
	local scriptId = self.scriptList:GetSelectedValue();
	local script = self.scripts[scriptId];

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

function TRP3_Tools_EditorScriptMixin:DeleteSelectedScript()
	local scriptId = self.scriptList:GetSelectedValue();
	if scriptId and self.scripts[scriptId] then
		if self:CountScriptReferences(scriptId) <= 0 then
			self:DeleteScripts(scriptId);
		else
			TRP3_API.popup.showConfirmPopup("This workflow might still be used.|n|nAre you sure you want to delete it?", function()
				self:DeleteScripts(scriptId);
			end);
		end
	end
end

function TRP3_Tools_EditorScriptMixin:DeleteScripts(...)
	local selectedScript = self.scriptList:GetSelectedValue();
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
	if deletions[selectedScript or ""] then
		self.scriptList:SetSelectedValue(nil);
	else
		self.scriptList:SetSelectedValue(selectedScript);
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
	self.scriptList:SetSelectedValue(newTrigger.script);
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
	if trigger.script == self.scriptList:GetSelectedValue() then
		self.scriptList:SetSelectedValue(nil);
	end
end

function TRP3_Tools_EditorScriptMixin:OnScriptSelected(scriptId)
	if scriptId == "" then
		self.scriptList:SetSelectedValue(nil);
		TRP3_API.popup.showTextInputPopup(loc.WO_ADD_ID, function(newScriptId)
			newScriptId = strtrim(newScriptId or "");
			if newScriptId:len() == 0 or self.scripts[newScriptId] then
				TRP3_API.popup.showAlertPopup(loc.WO_ADD_ID_NO_AVAILABLE);
			else
				self.scripts[newScriptId] = {};
				self:OnScriptsChanged(nil, {[newScriptId] = newScriptId}, nil);
				self.scriptList:SetSelectedValue(newScriptId);
			end
		end, nil, "");
	else
		local effects = {};
		self.currentScriptSecurity = TRP3_API.security.SECURITY_LEVEL.HIGH;
		if scriptId and self.scripts[scriptId] then
			for index, effect in ipairs(self.scripts[scriptId]) do
				local effectSecurity = addon.script.getEffectSecurity(effect);
				table.insert(effects, {
					title   = addon.script.getEffectTitle(effect),
					preview = addon.script.getEffectPreview(effect),
					icon    = "Interface\\Icons\\" .. addon.script.getEffectIcon(effect),
					constraint = self:ConstraintToPreview(effect.constraint, "IF"),
					security = effectSecurity
				});
				self.currentScriptSecurity = math.min(self.currentScriptSecurity, effectSecurity);
			end
			table.insert(effects, {isAddButton = true}); -- add button
			self.scriptControls:Show();
		else
			self.scriptControls:Hide();
		end
		self.effectList.model:Flush();
		self.effectList.model:InsertTable(effects);

		for index, trigger in self.triggerList.model:EnumerateEntireRange() do
			trigger.active = trigger.index and self.triggers[trigger.index].script == scriptId;
		end
		self.triggerList:Refresh();
	end
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
	triggerPreview.active = trigger.script and trigger.script == self.scriptList:GetSelectedValue();
	return triggerPreview;
end

function TRP3_Tools_EditorScriptMixin:ClassToInterface(class, creationClass, cursor)
	
	local s = self;

	wipe(self.triggers);
	wipe(self.scripts);

	for scriptId, scriptData in pairs(class.SC or TRP3_API.globals.empty) do
		self.scripts[scriptId] = addon.script.getNormalizedEffectListData(scriptData or TRP3_API.globals.empty);
	end

	self.triggers = addon.script.getNormalizedTriggerData(class, self.scripts);
	self:OnScriptsChanged(nil, nil, nil);

	self:UpdateTriggerList();

	self.scriptList:SetSelectedValue(cursor and cursor.scriptId);

end

function TRP3_Tools_EditorScriptMixin:UpdateScriptList()
	local scriptList = {};
	for scriptId, _ in pairs(self.scripts) do
		table.insert(scriptList, {scriptId, scriptId});
	end
	table.sort(scriptList, function(a, b) 
		return a[1] < b[1];
	end);
	table.insert(scriptList, {"|TInterface\\PaperDollInfoFrame\\Character-Plus:16:16|t " .. loc.WO_ADD, ""});
	TRP3_API.ui.listbox.setupListBox(self.scriptList, scriptList, function(scriptId) self:OnScriptSelected(scriptId); end, "(no workflow selected)");
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
		targetCursor.scriptId = self.scriptList:GetSelectedValue();
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
	for index, widget in ipairs(self.constraintWidgets) do
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
			addon.editor.script.scriptList:SetSelectedValue(trigger.script);
		elseif button == "RightButton" then
			TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
				local editOption = contextMenu:CreateButton("Edit trigger...", function()
					addon.modal:ShowModal(TRP3_API.popup.TRIGGER, {trigger});
					addon.editor.script.scriptList:SetSelectedValue(trigger.script);
				end);
				TRP3_MenuUtil.SetElementTooltip(editOption, "Edit trigger...");

				if trigger.script then
					local openOption = contextMenu:CreateButton("Edit workflow...", function()
						addon.editor.script.scriptList:SetSelectedValue(trigger.script);
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
			"Workflow security: " .. TRP3_API.security.getSecurityText(addon.editor.script.currentScriptSecurity or TRP3_API.security.SECURITY_LEVEL.LOW)  .. "|n|n" ..
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
	for index, widget in ipairs(self.constraintWidgets) do
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
	local scriptId = addon.editor.script.scriptList:GetSelectedValue();
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
					local convertOption = contextMenu:CreateButton("Convert selected to Lua effect", function()
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
					TRP3_MenuUtil.SetElementTooltip(convertOption, "Converts selected effects to their equivalent Lua script");
				end

				local convertAllOption = contextMenu:CreateButton("Convert workflow to Lua", function()
					local success, message = addon.editor.script:ConvertSelectedScriptEffects(function(index) 
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
	local scriptId = addon.editor.script.scriptList:GetSelectedValue();
	local effectIndex = addon.editor.script.effectList.model:FindIndex(self.data);
	addon.editor.script:DeleteEffect(scriptId, effectIndex);
end
