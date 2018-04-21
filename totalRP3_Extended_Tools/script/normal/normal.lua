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
local wipe, pairs, tostring, tinsert, assert, tonumber, sort = wipe, pairs, tostring, tinsert, assert, tonumber, table.sort;
local tContains, strjoin, unpack = tContains, strjoin, unpack;
local tsize, EMPTY = Utils.table.size, Globals.empty;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;
local getEffectSecurity = TRP3_API.security.getEffectSecurity;
local editor = TRP3_ScriptEditorNormal;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local securityLevel = TRP3_API.security.SECURITY_LEVEL;

local refreshElementList, toolFrame, unlockElements, onElementConfirm, openLastEffect;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- New element
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local ELEMENT_TYPE = TRP3_DB.elementTypes;

local function setCurrentElementFrame(frame, title, noConfirm)
	assert(frame, "Editor is null.")
	unlockElements();
	if editor.element.current then
		editor.element.current:Hide();
	end
	editor.element.current = frame;
	editor.element.current:SetParent(editor.element);
	editor.element.current:ClearAllPoints();
	editor.element.current:SetPoint("CENTER", 0, 0);
	editor.element.current:Show();

	if frame.title then
		frame.title:SetText(title);
	end

	if frame.close then
		frame.close:SetScript("OnClick", function()
			editor.element:Hide();
			unlockElements();
		end);
	end

	if frame.confirm then
		if noConfirm then
			frame.confirm:Hide();
		else
			frame.confirm:Show();
			frame.confirm:SetScript("OnClick", function()
				onElementConfirm();
			end);
			frame.confirm:SetText(loc.EDITOR_CONFIRM);
		end
	end

	editor.element:Show();
	editor.element.current:SetFrameLevel(editor.element:GetFrameLevel() + 20);
end

local function addDelayElement()
	local data = toolFrame.specificDraft.SC[editor.workflowID].ST;
	data[tostring(editor.list.size + 1)] =  {
		t = ELEMENT_TYPE.DELAY,
		d = 1,
	};
	refreshElementList();
	openLastEffect();
end

local function addConditionElement()
	local data = toolFrame.specificDraft.SC[editor.workflowID].ST;
	data[tostring(editor.list.size + 1)] =  {
		t = ELEMENT_TYPE.CONDITION,
		b = {
			{
				cond = { { { i = "unit_name", a = {"target"} }, "==", { v = "Elsa" } } }
			}
		},
	};
	refreshElementList();
	openLastEffect();
end

local function addEffectElement(effectID)
	local effectInfo = TRP3_API.extended.tools.getEffectEditorInfo(effectID);
	local data = toolFrame.specificDraft.SC[editor.workflowID].ST;
	data[tostring(editor.list.size + 1)] =  {
		t = ELEMENT_TYPE.EFFECT,
		e = {
			{
				id = effectID,
				args = effectInfo.getDefaultArgs and effectInfo.getDefaultArgs()
			},
		}
	};
	refreshElementList();
	openLastEffect();
end

local menuData;
local contextTemplate = "|cff00ff00%s: %s|r\n\n";

local function getContext(context)
	if not context then
		return contextTemplate:format(loc.WO_CONTEXT, loc.ALL);
	else
		local contexts = {};
		for _, c in pairs(context) do
			tinsert(contexts, getTypeLocale(c));
		end
		return contextTemplate:format(loc.WO_CONTEXT, strjoin(", ", unpack(contexts)));
	end
end

local function displayEffectDropdown(self)
	local values = {};
	tinsert(values, {loc.WO_COMMON_EFFECT, nil});
	for _, sectionID in pairs(menuData.order) do
		if sectionID == "" then
			tinsert(values, {loc.WO_EXPERT_EFFECT});
		else
			local section = menuData[sectionID];
			local sectionTab = {};
			for _, effectID in pairs(section) do
				local effectInfo = TRP3_API.extended.tools.getEffectEditorInfo(effectID);
				if not effectInfo.context or tContains(effectInfo.context, editor.currentContext) then
					tinsert(sectionTab, {effectInfo.title or effectID, effectID, getContext(effectInfo.context) .. effectInfo.description});
				end
			end
			tinsert(values, {sectionID, sectionTab});
		end
	end

	TRP3_API.ui.listbox.displayDropDown(self, values, addEffectElement, 0, true);
end

local function removeElement(elementID)
	local data = toolFrame.specificDraft.SC[editor.workflowID].ST;
	if data[elementID] then
		wipe(data[elementID]);
		data[elementID] = nil;
		local i = tonumber(elementID) + 1;
		while data[tostring(i)] do
			data[tostring(i - 1)] = data[tostring(i)];
			data[tostring(i)] = nil;
			i = i + 1;
		end
	end
	refreshElementList();
end

local function moveUpElement(elementID)
	local data = toolFrame.specificDraft.SC[editor.workflowID].ST;
	local index = tonumber(elementID);
	if data[tostring(index)] and data[tostring(index - 1)] then
		local previous = data[tostring(index - 1)];
		data[tostring(index - 1)] = data[tostring(index)];
		data[tostring(index)] = previous;
	end
	refreshElementList();
end

local function moveDownElement(elementID)
	local data = toolFrame.specificDraft.SC[editor.workflowID].ST;
	local index = tonumber(elementID);
	if data[tostring(index)] and data[tostring(index + 1)] then
		local next = data[tostring(index + 1)];
		data[tostring(index + 1)] = data[tostring(index)];
		data[tostring(index)] = next;
	end
	refreshElementList();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Workflow
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local IsControlKeyDown = IsControlKeyDown;

local function openEffectCondition(scriptStep)
	local conditionData = scriptStep.cond;
	if not conditionData then
		conditionData = {
			{ { i = "unit_name", a = {"target"} }, "==", { v = "Elsa" } }
		};
	end
	editor.overlay:Show();
	editor.overlay:SetFrameLevel(editor:GetFrameLevel() + 20);
	TRP3_ConditionEditor:SetParent(editor);
	TRP3_ConditionEditor:ClearAllPoints();
	TRP3_ConditionEditor:SetPoint("CENTER", 0, 0);
	TRP3_ConditionEditor:SetFrameLevel(editor.list:GetFrameLevel() + 20);
	TRP3_ConditionEditor:Show();
	TRP3_ConditionEditor.load(conditionData);
	TRP3_ConditionEditor:SetScript("OnHide", function()
		TRP3_ConditionEditor:Hide();
		editor.overlay:Hide();
		refreshElementList();
	end);
	TRP3_ConditionEditor.confirm:SetScript("OnClick", function()
		TRP3_ConditionEditor.save(conditionData);
		scriptStep.cond = conditionData;
		TRP3_ConditionEditor:Hide();
	end);
	TRP3_ConditionEditor.close:SetScript("OnClick", function()
		TRP3_ConditionEditor:Hide();
	end);
	TRP3_ConditionEditor.confirm:SetText(loc.EDITOR_CONFIRM);
	TRP3_ConditionEditor.title:SetText(loc.COND_EDITOR_EFFECT);
end

local function removeEffectCondition(scriptStep)
	wipe(scriptStep.cond or EMPTY);
	scriptStep.cond = nil;
	refreshElementList();
end

editor.list.listElement = {};
local ELEMENT_DELAY_ICON = "spell_mage_altertime";
local ELEMENT_EFFECT_ICON = "inv_misc_enggizmos_37";
local ELEMENT_CONDITION_ICON = "Ability_druid_balanceofpower";
local ELEMENT_LINE_ACTION_COPY = "ELEMENT_LINE_ACTION_COPY";
local ELEMENT_LINE_ACTION_PASTE = "ELEMENT_LINE_ACTION_PASTE";
local ELEMENT_LINE_ACTION_COND = "ELEMENT_LINE_ACTION_COND";
local ELEMENT_LINE_ACTION_COND_NO = "ELEMENT_LINE_ACTION_COND_NO";

local function onElementLineAction(action, self)
	assert(self.scriptStepData, "No stepData in frame");

	local scriptStep = self.scriptStepData;

	if action == ELEMENT_LINE_ACTION_COPY then
		if not editor.elemCopy then
			editor.elemCopy = {};
		end
		wipe(editor.elemCopy);
		Utils.table.copy(editor.elemCopy, scriptStep);
	elseif action == ELEMENT_LINE_ACTION_PASTE then
		if editor.elemCopy then
			wipe(self.scriptStepData);
			Utils.table.copy(self.scriptStepData, editor.elemCopy);
			refreshElementList();
		end
	elseif action == ELEMENT_LINE_ACTION_COND then
		openEffectCondition(scriptStep.e[1]);
	elseif action == ELEMENT_LINE_ACTION_COND_NO then
		removeEffectCondition(scriptStep.e[1]);
	end
end

local function onElementClick(self, button)
	assert(self.scriptStepData, "No stepData in frame");

	local scriptStep = self.scriptStepData;

	if button == "LeftButton" then
		editor.element.scriptStep = scriptStep;
		if scriptStep.t == ELEMENT_TYPE.EFFECT then
			if IsControlKeyDown() then
				openEffectCondition(scriptStep.e[1]);
			else
				local scriptData = scriptStep.e[1];
				local effectInfo = TRP3_API.extended.tools.getEffectEditorInfo(scriptData.id);
				if effectInfo.editor then
					setCurrentElementFrame(effectInfo.editor, effectInfo.title);
					effectInfo.editor.load(scriptData);
				else
					return; -- No editor => No selection
				end
			end
		elseif scriptStep.t == ELEMENT_TYPE.DELAY then
			setCurrentElementFrame(TRP3_ScriptEditorDelay, loc.WO_DELAY);
			TRP3_ScriptEditorDelay.load(scriptStep);
		elseif scriptStep.t == ELEMENT_TYPE.CONDITION then
			local scriptData = scriptStep.b[1];
			setCurrentElementFrame(TRP3_ConditionEditor, loc.COND_EDITOR);
			TRP3_ConditionEditor.load(scriptData.cond, scriptData);
		end

		self.highlight:Show();
		self.lock = true;
	else
		if scriptStep.t == ELEMENT_TYPE.EFFECT and IsControlKeyDown() then
			-- Remove condition
			removeEffectCondition(scriptStep.e[1]);
		else
			-- Show menu
			local values = {};
			tinsert(values, {self.title:GetText(), nil});
			tinsert(values, {loc.WO_ELEMENT_COPY, ELEMENT_LINE_ACTION_COPY});
			if editor.elemCopy and editor.elemCopy.t == scriptStep.t then
				tinsert(values, {loc.WO_ELEMENT_PASTE, ELEMENT_LINE_ACTION_PASTE});
			end
			if scriptStep.t == ELEMENT_TYPE.EFFECT then
				tinsert(values, {loc.WO_ELEMENT_COND, ELEMENT_LINE_ACTION_COND, loc.WO_ELEMENT_COND_TT});
				tinsert(values, {loc.WO_ELEMENT_COND_NO, ELEMENT_LINE_ACTION_COND_NO});
			end
			TRP3_API.ui.listbox.displayDropDown(self, values, onElementLineAction, 0, true);
		end
	end
end

local function onRemoveClick(self)
	assert(self:GetParent().scriptStepID, "No stepID in frame");
	removeElement(self:GetParent().scriptStepID);
end

local function onMoveUpClick(self)
	assert(self:GetParent().scriptStepID, "No stepID in frame");
	moveUpElement(self:GetParent().scriptStepID);
end

local function onMoveDownClick(self)
	assert(self:GetParent().scriptStepID, "No stepID in frame");
	moveDownElement(self:GetParent().scriptStepID);
end

function onElementConfirm(self)
	assert(editor.element.scriptStep, "No stepData in editor.element");
	if editor.element.current and editor.element.current.save then
		if editor.element.scriptStep.t == ELEMENT_TYPE.EFFECT then
			local scriptData = editor.element.scriptStep.e[1];
			if not scriptData.args then scriptData.args = {} end
			editor.element.current.save(scriptData);
		elseif editor.element.scriptStep.t == ELEMENT_TYPE.CONDITION then
			local scriptData = editor.element.scriptStep.b[1];
			editor.element.current.save(scriptData.cond, scriptData);
		else
			editor.element.current.save(editor.element.scriptStep);
		end
		refreshElementList();
	end
end

local function decorateEffect(scriptStepFrame, effectData)
	local effect = TRP3_API.script.getEffect(effectData.id) or EMPTY;
	local effectInfo = TRP3_API.extended.tools.getEffectEditorInfo(effectData.id) or EMPTY;
	local title = ("%s: |cffff9900%s"):format(loc.WO_EFFECT, effectInfo.title or UNKNOWN);

	TRP3_API.ui.frame.setupIconButton(scriptStepFrame, effectInfo.icon or ELEMENT_EFFECT_ICON);

	-- Tooltip
	local tooltip = effectInfo.description or loc.EFFECT_MISSING:format(effectData.id);
	scriptStepFrame.description:SetText(tooltip);
	if effect.secured then
		tooltip = tooltip .. "\n\n|cffffff00" .. loc.WO_SECURITY .. ":\n";
		local format = "%s:|r %s";
		if effect.secured == securityLevel.HIGH then
			tooltip = tooltip .. format:format("|cff00ff00" .. loc.WO_SECURITY_HIGH, loc.WO_SECURITY_HIGH_DETAILS);
		elseif effect.secured == securityLevel.MEDIUM then
			tooltip = tooltip .. format:format("|cffff9900" .. loc.WO_SECURITY_NORMAL, loc.WO_SECURITY_NORMAL_DETAILS);
		elseif effect.secured == securityLevel.LOW then
			tooltip = tooltip .. format:format("|cffff0000" .. loc.WO_SECURITY_LOW, loc.WO_SECURITY_LOW_DETAILS);
		end
	end
	if effectInfo.editor then
		tooltip = tooltip .. "\n\n|cffffff00" .. loc.WO_ELEMENT_EDIT;
	else
		tooltip = tooltip .. "\n\n|cffffff00" .. loc.WO_EFFECT_NO_EDITOR;
	end
	tooltip = tooltip .. "\n" .. loc.WO_ELEMENT_EDIT_RIGHT;
	tooltip = tooltip .. "\n" .. loc.WO_ELEMENT_EDIT_CTRL;

	setTooltipForSameFrame(scriptStepFrame, "TOP", 0, 5, title, tooltip);

	if effectInfo.effectFrameDecorator then
		effectInfo.effectFrameDecorator(scriptStepFrame, effectData.args);
	end

	if effectData.cond then
		scriptStepFrame.conditioned:Show();
	end
	return title;
end

local function decorateElement(scriptStepFrame)
	local scriptStep = scriptStepFrame.scriptStepData;
	local stepFormat = "%s. %s"
	scriptStepFrame.description:SetText("");
	scriptStepFrame.conditioned:Hide();
	if scriptStep.t == ELEMENT_TYPE.EFFECT then
		local title = decorateEffect(scriptStepFrame, scriptStep.e[1]);
		scriptStepFrame.title:SetText(stepFormat:format(scriptStepFrame.scriptStepID, title));
	elseif scriptStep.t == ELEMENT_TYPE.CONDITION then
		TRP3_API.ui.frame.setupIconButton(scriptStepFrame, ELEMENT_CONDITION_ICON);
		scriptStepFrame.title:SetText(stepFormat:format(scriptStepFrame.scriptStepID, loc.WO_CONDITION));
		scriptStepFrame.description:SetText(TRP3_ConditionEditor.getConditionPreview(scriptStep.b[1].cond));
		setTooltipForSameFrame(scriptStepFrame, "TOP", 0, 5, loc.WO_CONDITION, loc.WO_CONDITION_TT .. "\n\n|cffffff00" .. loc.WO_ELEMENT_EDIT);
	elseif scriptStep.t == ELEMENT_TYPE.DELAY then
		TRP3_API.ui.frame.setupIconButton(scriptStepFrame, ELEMENT_DELAY_ICON);
		scriptStepFrame.title:SetText(stepFormat:format(scriptStepFrame.scriptStepID, loc.WO_DELAY));
		scriptStepFrame.description:SetText(TRP3_ScriptEditorDelay.decorate(scriptStep));
		setTooltipForSameFrame(scriptStepFrame, "TOP", 0, 5, loc.WO_DELAY, loc.WO_DELAY_TT .. "\n\n|cffffff00" .. loc.WO_ELEMENT_EDIT);
	end
end

function unlockElements()
	for _, element in pairs(editor.list.listElement) do
		element.lock = nil;
		element.highlight:Hide();
	end
end

function openLastEffect()
	local data = toolFrame.specificDraft.SC[editor.workflowID].ST;
	local scriptStepFrame = editor.list.listElement[tsize(data)];
	if scriptStepFrame then
		onElementClick(scriptStepFrame, "LeftButton");
	end
end

function refreshElementList()
	local data = toolFrame.specificDraft.SC[editor.workflowID].ST;

	editor.element:Hide();
	for _, element in pairs(editor.list.listElement) do
		element:Hide();
		element:ClearAllPoints();
	end
	unlockElements();

	local stepID = 1;
	local workflowSecurity = securityLevel.HIGH;
	local previous;
	while data[tostring(stepID)] do
		local scriptStep = data[tostring(stepID)];
		local scriptStepFrame = editor.list.listElement[stepID];
		if not scriptStepFrame then
			scriptStepFrame = CreateFrame("Frame", "TRP3_EditorEffectFrame" .. stepID, editor.workflow.container.scroll.list, "TRP3_EditorEffectFrame");
			scriptStepFrame.conditioned:SetText(loc.COND_CONDITIONED);
			scriptStepFrame:SetScript("OnMouseUp", onElementClick);
			scriptStepFrame.remove:SetScript("OnClick", onRemoveClick);
			setTooltipAll(scriptStepFrame.moveup, "TOP", 0, 0, loc.CM_MOVE_UP);
			setTooltipAll(scriptStepFrame.movedown, "TOP", 0, 0, loc.CM_MOVE_DOWN);
			setTooltipAll(scriptStepFrame.remove, "TOP", 0, 5, REMOVE);
			scriptStepFrame.moveup:SetScript("OnClick", onMoveUpClick);
			scriptStepFrame.movedown:SetScript("OnClick", onMoveDownClick);
			tinsert(editor.list.listElement, scriptStepFrame);
		end

		scriptStepFrame.moveup:Hide();
		scriptStepFrame.movedown:Hide();
		if stepID > 1 then
			scriptStepFrame.moveup:Show();
		end
		if data[tostring(stepID + 1)] then
			scriptStepFrame.movedown:Show();
		end

		scriptStepFrame.scriptStepData = scriptStep;
		scriptStepFrame.scriptStepID = tostring(stepID);

		decorateElement(scriptStepFrame);
		if scriptStep.t == ELEMENT_TYPE.EFFECT then
			local effectSecurity = getEffectSecurity(scriptStep.e[1].id);
			workflowSecurity = math.min(workflowSecurity, effectSecurity);
		end

		scriptStepFrame:SetPoint("LEFT", 0, 0);
		scriptStepFrame:SetPoint("RIGHT", 0, 0);
		if previous then
			scriptStepFrame:SetPoint("TOP", previous, "BOTTOM", 0, -5);
		else
			scriptStepFrame:SetPoint("TOP", 0, 0);
		end

		scriptStepFrame:Show();

		stepID = stepID + 1;
		previous = scriptStepFrame;
	end

	if workflowSecurity == securityLevel.HIGH then
		editor.workflow.security:SetText(("%s: %s"):format(loc.WO_WO_SECURITY, "|cff00ff00" .. loc.WO_SECURITY_HIGH));
	elseif workflowSecurity == securityLevel.MEDIUM then
		editor.workflow.security:SetText(("%s: %s"):format(loc.WO_WO_SECURITY, "|cffff9900" .. loc.WO_SECURITY_NORMAL));
	else
		editor.workflow.security:SetText(("%s: %s"):format(loc.WO_WO_SECURITY, "|cffff0000" .. loc.WO_SECURITY_LOW));
	end

	editor.workflow.container.scroll.list.endofworkflow:Hide();
	if stepID > 1 then
		editor.workflow.container.empty:Hide();
		editor.workflow.container.scroll.list.endofworkflow:Show();
		editor.workflow.container.scroll.list.endofworkflow:ClearAllPoints();
		if previous then
			editor.workflow.container.scroll.list.endofworkflow:SetPoint("TOP", previous, "BOTTOM", 0, -35);
		else
			editor.workflow.container.scroll.list.endofworkflow:SetPoint("TOP", 0, -15);
		end
	else
		editor.workflow.container.empty:Show();
	end

	editor.list.size = stepID - 1;
end
editor.list.refreshElementList = refreshElementList;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Workflow list
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function refreshLines()
	for _, line in pairs(editor.list.widgetTab) do
		line.click:UnlockHighlight();
		if line.workflowID == editor.workflowID then
			line.click:LockHighlight();
		end
	end
end

local function openWorkflow(workflowID)
	assert(toolFrame.specificDraft.SC, "No toolFrame.specificDraft.SC for refresh.");

	local data = toolFrame.specificDraft.SC;

	if not data[workflowID] then
		data[workflowID] = {};
	end

	if not data[workflowID].ST then
		data[workflowID].ST = {};
	end

	editor.workflowID = workflowID;
	editor.workflow:Show();
	editor.list.arrow:Show();
	refreshElementList();
	refreshLines();

	if toolFrame.specificDraft.TY == TRP3_DB.types.ITEM and toolFrame.specificDraft.MD.MO == TRP3_DB.modes.NORMAL then
		editor.workflow.title:SetText(loc.WO_EXECUTION);
	else
		editor.workflow.title:SetText(loc.WO_EXECUTION .. ": |cff00ff00" .. editor.workflowID);
	end
end

local WORKFLOW_LINE_ACTION_DELETE = 1;
local WORKFLOW_LINE_ACTION_ID = 2;
local WORKFLOW_LINE_ACTION_COPY = 3;
local WORKFLOW_LINE_ACTION_PASTE = 4;

local function onWorkflowLineAction(action, line)
	assert(toolFrame.specificDraft.SC[line.workflowID]);
	local workflowID = line.workflowID;
	local workflow = toolFrame.specificDraft.SC[workflowID];

	if action == WORKFLOW_LINE_ACTION_DELETE then
		TRP3_API.popup.showConfirmPopup(loc.WO_REMOVE_POPUP:format(workflowID), function()
			wipe(toolFrame.specificDraft.SC[workflowID]);
			toolFrame.specificDraft.SC[workflowID] = nil;
			editor.refreshWorkflowList();
		end);
	elseif action == WORKFLOW_LINE_ACTION_ID then
		TRP3_API.popup.showTextInputPopup(loc.WO_ADD_ID:format(workflowID), function(newID)
			if toolFrame.specificDraft.SC[newID] then
				Utils.message.displayMessage(loc.WO_ADD_ID_NO_AVAILABLE, 4);
			elseif newID and newID:len() > 0 then
				toolFrame.specificDraft.SC[newID] = toolFrame.specificDraft.SC[workflowID];
				toolFrame.specificDraft.SC[workflowID] = nil;
				editor.refreshWorkflowList();
			end
		end, nil, workflowID);
	elseif action == WORKFLOW_LINE_ACTION_COPY then
		if not editor.copy then
			editor.copy = {};
		end
		wipe(editor.copy);
		Utils.table.copy(editor.copy, workflow);
	elseif action == WORKFLOW_LINE_ACTION_PASTE then
		if editor.copy then
			TRP3_API.popup.showConfirmPopup(loc.WO_PASTE_CONFIRM, function()
				wipe(workflow);
				Utils.table.copy(workflow, editor.copy);
				editor.refreshWorkflowList();
				openWorkflow(workflowID);
			end);
		end
	end
end

local function onWorkflowLineClick(lineClick, button)
	local line = lineClick:GetParent();
	if button == "LeftButton" then
		openWorkflow(line.workflowID);
	else
		local values = {};
		tinsert(values, {line.text:GetText(), nil});
		tinsert(values, {DELETE, WORKFLOW_LINE_ACTION_DELETE});
		tinsert(values, {loc.IN_INNER_ID_ACTION, WORKFLOW_LINE_ACTION_ID});
		tinsert(values, {loc.WO_COPY, WORKFLOW_LINE_ACTION_COPY});
		if editor.copy then
			tinsert(values, {loc.WO_PASTE, WORKFLOW_LINE_ACTION_PASTE});
		end
		TRP3_API.ui.listbox.displayDropDown(line, values, onWorkflowLineAction, 0, true);
	end
end

local function decorateWorkflowLine(line, workflowID)
	line.text:SetText(workflowID);
	line.workflowID = workflowID;
end

local function refreshWorkflowList()
	assert(toolFrame.specificDraft.SC, "No toolFrame.specificDraft.SC for refreshWorkflowList.");

	editor.workflowID = nil;
	editor.workflow:Hide();
	editor.list.arrow:Hide();
	editor.list.add:Hide();
	editor.list.sub:Hide();

	if toolFrame.specificDraft.TY == TRP3_DB.types.ITEM and toolFrame.specificDraft.MD.MO == TRP3_DB.modes.NORMAL then
		assert(editor.workflowIDToLoad, "No editor.workflowIDToLoad for refresh.");
		editor.list.script:SetText(editor.scriptTitle or "");
		editor.list.description:SetText(editor.scriptDescription or "");
		TRP3_API.ui.list.initList(editor.list, EMPTY, editor.list.sub.slider);
		openWorkflow(editor.workflowIDToLoad);
	else
		editor.list.script:SetText(loc.WO_CONTEXT .. ": " .. getTypeLocale(editor.currentContext));
		editor.list.description:SetText(loc.WO_EXPERT_TT);
		editor.list.add:Show();
		editor.list.sub:Show();
		editor.list.sub.empty:Show();
		if Utils.table.size(toolFrame.specificDraft.SC) > 0 then
			editor.list.sub.empty:Hide();
		end

		-- List
		TRP3_API.ui.list.initList(editor.list, toolFrame.specificDraft.SC, editor.list.sub.slider);
		refreshLines();
	end

end
editor.refreshWorkflowList = refreshWorkflowList;

function editor.loadList(context)
	editor.currentContext = context;
	refreshWorkflowList();
	-- Select first
	for id, _ in pairs(toolFrame.specificDraft.SC) do
		openWorkflow(id);
		break;
	end
end

function editor.linkElements(workflow)
	local size = tsize(workflow.ST);
	-- Make connection between elements
	for i = 1, size, 1 do
		local data = workflow.ST[tostring(i)];
		if i < size then
			if data.t ~= ELEMENT_TYPE.CONDITION then
				data.n = tostring(i + 1);
			else
				data.b[1].n = tostring(i + 1);
			end
		else
			data.n = nil;
		end
	end
end

local function onAddWorkflow()
	TRP3_API.popup.showTextInputPopup(loc.WO_ADD_ID, function(newID)
		if toolFrame.specificDraft.SC[newID] then
			Utils.message.displayMessage(loc.WO_ADD_ID_NO_AVAILABLE, 4);
		elseif newID and newID:len() > 0 then
			toolFrame.specificDraft.SC[newID] = {};
			refreshWorkflowList();
			openWorkflow(newID);
		end
	end, nil, "workflow" .. tsize(toolFrame.specificDraft.SC) + 1);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UTILS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function editor.safeLoadList(list, keys, key)
	if keys and key and tContains(keys, key) then
		list:SetSelectedValue(key);
	else
		list:SetSelectedValue("");
	end
end

function editor.reloadWorkflowlist(workflowIDs)
	local workflowListStructure = {
		{loc.WO_LINKS_SELECT},
		{loc.WO_LINKS_NO_LINKS, "", loc.WO_LINKS_NO_LINKS_TT},
	}

	wipe(workflowIDs);
	for workflowID, _ in pairs(toolFrame.specificDraft.SC) do
		tinsert(workflowIDs, workflowID);
	end
	sort(workflowIDs);

	for _, workflowID in pairs(workflowIDs) do
		tinsert(workflowListStructure, {TRP3_API.formats.dropDownElements:format(loc.WO_LINKS_TO, workflowID), workflowID});
	end

	return workflowListStructure;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

editor.init = function(ToolFrame, effectMenu)
	toolFrame = ToolFrame;

	-- Resize
	TRP3_API.events.listenToEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, function(containerwidth, containerHeight)
		editor.workflow.container.scroll.list:SetWidth( containerwidth - 580 );
	end);

	-- List
	editor.list.title:SetText(loc.WO_WORKFLOW);
	editor.list.widgetTab = {};
	for i=1, 6 do
		local line = editor.list.sub["line" .. i];
		tinsert(editor.list.widgetTab, line);
		line.click:SetScript("OnClick", onWorkflowLineClick);
		line.click:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	end
	editor.list.decorate = decorateWorkflowLine;
	TRP3_API.ui.list.handleMouseWheel(editor, editor.list.sub.slider);
	editor.list.sub.slider:SetValue(0);
	editor.list.add:SetText(loc.WO_ADD);
	editor.list.sub.empty:SetText(loc.WO_NO);
	editor.list.add:SetScript("OnClick", onAddWorkflow);

	-- Effect selector
	menuData = effectMenu;

	-- Workflow edition
	editor.workflow.container.empty:SetText(loc.WO_EMPTY);
	editor.workflow.container.add:SetText(loc.WO_ELEMENT_ADD);
	editor.workflow.container.add:SetScript("OnClick", function(self)
		setCurrentElementFrame(editor.element.selector, loc.WO_ELEMENT_TYPE, true);
	end);
	editor.workflow.container.scroll.list.endofworkflow:SetText(loc.WO_END);

	-- Element edition
	editor.element.selector.effect.Name:SetText(loc.WO_EFFECT);
	editor.element.selector.effect.InfoText:SetText(loc.WO_EFFECT_TT);
	TRP3_API.ui.frame.setupIconButton(editor.element.selector.effect, ELEMENT_EFFECT_ICON);
	editor.element.selector.condition.Name:SetText(loc.WO_CONDITION);
	editor.element.selector.condition.InfoText:SetText(loc.WO_CONDITION_TT);
	TRP3_API.ui.frame.setupIconButton(editor.element.selector.condition, ELEMENT_CONDITION_ICON);
	editor.element.selector.delay.Name:SetText(loc.WO_DELAY);
	editor.element.selector.delay.InfoText:SetText(loc.WO_DELAY_TT);
	TRP3_API.ui.frame.setupIconButton(editor.element.selector.delay, ELEMENT_DELAY_ICON);
	editor.element.selector.condition:SetScript("OnClick", addConditionElement);
	editor.element.selector.delay:SetScript("OnClick", addDelayElement);
	editor.element.selector.effect:SetScript("OnClick", displayEffectDropdown);

	editor:SetScript("OnHide", function() editor.element:Hide(); unlockElements(); end);

	-- Tutorial
	local TUTORIAL = {
		{
			box = toolFrame, title = "WO_WORKFLOW", text = "TU_WO_1_TEXT",
			arrow = "DOWN", x = 0, y = 100, anchor = "CENTER", textWidth = 400
		},
		{
			box = editor.list, title = "TU_WO_2", text = "TU_WO_2_TEXT",
			arrow = "RIGHT", x = 0, y = 0, anchor = "CENTER", textWidth = 400
		},
		{
			box = editor.workflow, title = "WO_EXECUTION", text = "TU_WO_3_TEXT",
			arrow = "DOWN", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
			callback = function()
				if tsize(toolFrame.specificDraft.SC) == 0 then
					return true, loc.TU_WO_ERROR_1;
				end
				openWorkflow(next(toolFrame.specificDraft.SC));
				refreshElementList();
			end
		},
		{
			box = editor.element.selector.effect, title = "TU_WO_4", text = "TU_WO_4_TEXT",
			arrow = "RIGHT", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
			callback = function()
				if tsize(toolFrame.specificDraft.SC) == 0 then
					return true, loc.TU_WO_ERROR_1;
				end
				openWorkflow(next(toolFrame.specificDraft.SC));
				refreshElementList();
				setCurrentElementFrame(editor.element.selector, loc.WO_ELEMENT_TYPE, true);
			end
		},
		{
			box = editor.element.selector.condition, title = "TU_WO_5", text = "TU_WO_5_TEXT",
			arrow = "RIGHT", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
			callback = function()
				if tsize(toolFrame.specificDraft.SC) == 0 then
					return true, loc.TU_WO_ERROR_1;
				end
				openWorkflow(next(toolFrame.specificDraft.SC));
				refreshElementList();
				setCurrentElementFrame(editor.element.selector, loc.WO_ELEMENT_TYPE, true);
			end
		},
		{
			box = editor.element.selector.delay, title = "TU_WO_6", text = "TU_WO_6_TEXT",
			arrow = "RIGHT", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
			callback = function()
				if tsize(toolFrame.specificDraft.SC) == 0 then
					return true, loc.TU_WO_ERROR_1;
				end
				openWorkflow(next(toolFrame.specificDraft.SC));
				refreshElementList();
				setCurrentElementFrame(editor.element.selector, loc.WO_ELEMENT_TYPE, true);
			end
		},
	}
	editor:SetScript("OnShow", function()
		TRP3_ExtendedTutorial.loadStructure(TUTORIAL);
	end);
end