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
local wipe, pairs, tostring, tinsert, assert, tonumber = wipe, pairs, tostring, tinsert, assert, tonumber;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;

local editor = TRP3_ScriptEditorNormal;
local refreshList, toolFrame, unlockElements;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- New element
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local ELEMENT_TYPE = {
	EFFECT = "list",
	CONDITION = "branch",
	DELAY = "delay"
}

local function setCurrentElementFrame(frame, title, noConfirm)
	assert(frame, "Editor is null.")
	unlockElements();
	editor.element.title:SetText(title);
	if editor.element.current then
		editor.element.current:Hide();
	end
	editor.element.current = frame;
	editor.element.current:SetParent(editor.element);
	editor.element.current:SetAllPoints(editor.element);
	editor.element.current:Show();
	editor.element.confirm:Show();
	if noConfirm then
		editor.element.confirm:Hide();
	end
	editor.element:Show();
end

local function addDelayElement()
	local data = toolFrame.specificDraft.SC[editor.scriptID].ST;
	data[tostring(editor.list.size + 1)] =  {
		t = ELEMENT_TYPE.DELAY,
		d = 1,
	};
	refreshList();
end

local function addConditionElement()
	local data = toolFrame.specificDraft.SC[editor.scriptID].ST;
	data[tostring(editor.list.size + 1)] =  {
		t = ELEMENT_TYPE.CONDITION,
		b = {
--			{
--				cond = { { { i = "tar_name" }, "==", { v = "Kyle Radue" } } },
--				n = "2"
--			}
		},
	};
	refreshList();
end

local function addEffectElement(effectID)
	local effectInfo = TRP3_API.extended.tools.getEffectEditorInfo(effectID);
	local data = toolFrame.specificDraft.SC[editor.scriptID].ST;
	data[tostring(editor.list.size + 1)] =  {
		t = ELEMENT_TYPE.EFFECT,
		e = {
			{
				id = effectID,
				args = effectInfo.getDefaultArgs and effectInfo.getDefaultArgs()
			},
		}
	};
	refreshList();
end

local menuData;

local function displayEffectDropdown(self)
	local values = {};
	tinsert(values, {loc("WO_EFFECT_SELECT"), nil});
	for _, sectionID in pairs(menuData.order) do
		local section = menuData[sectionID];
		local sectionTab = {};
		for _, effectID in pairs(section) do
			local effectInfo = TRP3_API.extended.tools.getEffectEditorInfo(effectID);
			tinsert(sectionTab, {effectInfo.title or effectID, effectID, effectInfo.description});
		end
		tinsert(values, {sectionID, sectionTab});
	end

	TRP3_API.ui.listbox.displayDropDown(self, values, addEffectElement, 0, true);
end

local function removeElement(elementID)
	local data = toolFrame.specificDraft.SC[editor.scriptID].ST;
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
	refreshList();
end

local function moveUpElement(elementID)
	local data = toolFrame.specificDraft.SC[editor.scriptID].ST;
	local index = tonumber(elementID);
	if data[tostring(index)] and data[tostring(index - 1)] then
		local previous = data[tostring(index - 1)];
		data[tostring(index - 1)] = data[tostring(index)];
		data[tostring(index)] = previous;
	end
	refreshList();
end

local function moveDownElement(elementID)
	local data = toolFrame.specificDraft.SC[editor.scriptID].ST;
	local index = tonumber(elementID);
	if data[tostring(index)] and data[tostring(index + 1)] then
		local next = data[tostring(index + 1)];
		data[tostring(index + 1)] = data[tostring(index)];
		data[tostring(index)] = next;
	end
	refreshList();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Workflow
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

editor.list.listElement = {};
local ELEMENT_DELAY_ICON = "spell_mage_altertime";
local ELEMENT_EFFECT_ICON = "inv_misc_enggizmos_37";
local ELEMENT_CONDITION_ICON = "Ability_druid_balanceofpower";

local function onElementClick(self)
	assert(self.scriptStepData, "No stepData in frame");

	local scriptStep = self.scriptStepData;
	editor.element.scriptStep = scriptStep;

	if scriptStep.t == ELEMENT_TYPE.EFFECT then
		local scriptData = scriptStep.e[1];
		local effectInfo = TRP3_API.extended.tools.getEffectEditorInfo(scriptData.id);
		if effectInfo.editor then
			setCurrentElementFrame(effectInfo.editor, effectInfo.title);
			effectInfo.editor.load(scriptData);
		else
			return; -- No editor => No selection
		end
	elseif scriptStep.t == ELEMENT_TYPE.DELAY then
		setCurrentElementFrame(TRP3_ScriptEditorDelay, loc("WO_DELAY"));
		TRP3_ScriptEditorDelay.load(scriptStep);
	end

	self.highlight:Show();
	self.lock = true;
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

local function onElementConfirm(self)
	assert(editor.element.scriptStep, "No stepData in editor.element");
	if editor.element.current and editor.element.current.save then
		if editor.element.scriptStep.t == ELEMENT_TYPE.EFFECT then
			local scriptData = editor.element.scriptStep.e[1];
			if not scriptData.args then scriptData.args = {} end
			editor.element.current.save(scriptData);
		else
			editor.element.current.save(editor.element.scriptStep);
		end
		refreshList();
	end
end

local function decorateEffect(scriptStepFrame, effectData)
	local effect = TRP3_API.script.getEffect(effectData.id);
	local effectInfo = TRP3_API.extended.tools.getEffectEditorInfo(effectData.id);
	local title = ("%s: %s"):format(loc("WO_EFFECT"), effectInfo.title or UNKNOWN);

	TRP3_API.ui.frame.setupIconButton(scriptStepFrame, effectInfo.icon or ELEMENT_EFFECT_ICON);

	-- Tooltip
	local tooltip = effectInfo.description or "";
	scriptStepFrame.description:SetText(tooltip);
	if effect.secured then
		tooltip = tooltip .. "\n\n|cffffff00" .. loc("WO_SECURITY") .. ":\n";
		local format = "%s:|r %s";
		if effect.secured == TRP3_API.script.security.HIGH then
			tooltip = tooltip .. format:format("|cff00ff00" .. loc("WO_SECURITY_HIGH"), loc("WO_SECURITY_HIGH_DETAILS"));
		elseif effect.secured == TRP3_API.script.security.MEDIUM then
			tooltip = tooltip .. format:format("|cffff9900" .. loc("WO_SECURITY_NORMAL"), loc("WO_SECURITY_NORMAL_DETAILS"));
		elseif effect.secured == TRP3_API.script.security.LOW then
			tooltip = tooltip .. format:format("|cffff0000" .. loc("WO_SECURITY_LOW"), loc("WO_SECURITY_LOW_DETAILS"));
		end
	end
	if effectInfo.editor then
		tooltip = tooltip .. "\n\n|cffffff00" .. loc("WO_ELEMENT_EDIT");
	else
		tooltip = tooltip .. "\n\n|cffffff00" .. loc("WO_EFFECT_NO_EDITOR");
	end
	setTooltipForSameFrame(scriptStepFrame, "TOP", 0, 5, title, tooltip);

	if effectInfo.effectFrameDecorator then
		effectInfo.effectFrameDecorator(scriptStepFrame, effectData.args);
	end
	return title;
end

local function decorateElement(scriptStepFrame)
	local scriptStep = scriptStepFrame.scriptStepData;
	local stepFormat = "%s. %s"
	scriptStepFrame.description:SetText("");
	if scriptStep.t == ELEMENT_TYPE.EFFECT then
		local title = decorateEffect(scriptStepFrame, scriptStep.e[1]);
		scriptStepFrame.title:SetText(stepFormat:format(scriptStepFrame.scriptStepID, title));
	elseif scriptStep.t == ELEMENT_TYPE.CONDITION then
		TRP3_API.ui.frame.setupIconButton(scriptStepFrame, ELEMENT_CONDITION_ICON);
		scriptStepFrame.title:SetText(stepFormat:format(scriptStepFrame.scriptStepID, loc("WO_CONDITION")));
		scriptStepFrame.description:SetText("");
	elseif scriptStep.t == ELEMENT_TYPE.DELAY then
		TRP3_API.ui.frame.setupIconButton(scriptStepFrame, ELEMENT_DELAY_ICON);
		scriptStepFrame.title:SetText(stepFormat:format(scriptStepFrame.scriptStepID, loc("WO_DELAY")));
		scriptStepFrame.description:SetText(("%s: |cffffff00%s %s|r"):format(loc("WO_DELAY_WAIT"), scriptStep.d or 0, loc("WO_DELAY_SECONDS")));
		setTooltipForSameFrame(scriptStepFrame, "TOP", 0, 5, loc("WO_DELAY"), loc("WO_DELAY_TT") .. "\n\n|cffffff00" .. loc("WO_ELEMENT_EDIT"));
	end
end

local function getEffectSecurity(effectID)
	local effect = TRP3_API.script.getEffect(effectID);
	if effect then
		return effect.secured or TRP3_API.script.security.HIGH;
	end
	return TRP3_API.script.security.LOW;
end

function unlockElements()
	for _, element in pairs(editor.list.listElement) do
		element.lock = nil;
		element.highlight:Hide();
	end
end

function refreshList()
	local data = toolFrame.specificDraft.SC[editor.scriptID].ST;

	editor.element:Hide();
	for _, element in pairs(editor.list.listElement) do
		element:Hide();
		element:ClearAllPoints();
	end
	unlockElements();

	local stepID = 1;
	local workflowSecurity = TRP3_API.script.security.HIGH;
	local previous;
	while data[tostring(stepID)] do
		local scriptStep = data[tostring(stepID)];
		local scriptStepFrame = editor.list.listElement[stepID];
		if not scriptStepFrame then
			scriptStepFrame = CreateFrame("Frame", "TRP3_EditorEffectFrame" .. stepID, editor.workflow.container.scroll.list, "TRP3_EditorEffectFrame");
			scriptStepFrame:SetScript("OnMouseUp", onElementClick);
			scriptStepFrame.remove:SetScript("OnClick", onRemoveClick);
			setTooltipAll(scriptStepFrame.moveup, "TOP", 0, 0, loc("CM_MOVE_UP"));
			setTooltipAll(scriptStepFrame.movedown, "TOP", 0, 0, loc("CM_MOVE_DOWN"));
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
			if effectSecurity == TRP3_API.script.security.MEDIUM and workflowSecurity == TRP3_API.script.security.HIGH then
				workflowSecurity = TRP3_API.script.security.MEDIUM;
			elseif effectSecurity == TRP3_API.script.security.LOW then
				workflowSecurity = TRP3_API.script.security.LOW;
			end
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

	if workflowSecurity == TRP3_API.script.security.HIGH then
		editor.workflow.security:SetText(("%s: %s"):format(loc("WO_WO_SECURITY"), "|cff00ff00" .. loc("WO_SECURITY_HIGH")));
	elseif workflowSecurity == TRP3_API.script.security.MEDIUM then
		editor.workflow.security:SetText(("%s: %s"):format(loc("WO_WO_SECURITY"), "|cffff9900" .. loc("WO_SECURITY_NORMAL")));
	else
		editor.workflow.security:SetText(("%s: %s"):format(loc("WO_WO_SECURITY"), "|cffff0000" .. loc("WO_SECURITY_LOW")));
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
editor.list.refreshList = refreshList;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Workflow list
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function refresh()
	assert(toolFrame.specificDraft.SC, "No toolFrame.specificDraft.SC for refresh.");
	assert(editor.scriptID, "No editor.scriptID for refresh.");

	if toolFrame.specificDraft.MD.MO == TRP3_DB.modes.NORMAL then
		editor.list.script:SetText(editor.scriptTitle or "");
		editor.list.description:SetText(editor.scriptDescription or "");

		local data = toolFrame.specificDraft.SC;

		if not data[editor.scriptID] then
			data[editor.scriptID] = {};
		end

		if not data[editor.scriptID].ST then
			data[editor.scriptID].ST = {};
		end

		refreshList();
	end

end
editor.refresh = refresh;

function editor.storeData()
	assert(editor.scriptID, "No scriptID for storeData.");

	-- Remove precedent compiled script
	toolFrame.specificDraft.SC[editor.scriptID].c = nil; -- TODO: in optimization

	-- Make connection between elements
	for i = 1, editor.list.size, 1 do
		local frame = editor.list.listElement[i];
		if i < editor.list.size and frame.scriptStepData.t ~= ELEMENT_TYPE.CONDITION then
			frame.scriptStepData.n = tostring(i + 1);
		else
			frame.scriptStepData.n = nil;
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

editor.init = function(ToolFrame)
	toolFrame = ToolFrame;

	-- Resize
	TRP3_API.events.listenToEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, function(containerwidth, containerHeight)
		editor.workflow.container.scroll.list:SetWidth( (containerwidth/2) - 135 );
	end);

	-- List
	editor.list.title:SetText(loc("WO_WORKFLOW"));

	-- Effect selector
	menuData = {
		[loc("WO_EFFECT_CAT_COMMON")] = {
			"text",
			"document_show",
		},
		["Sound"] = { -- TODO: locals
			"sound_id_self",
			"sound_music_self",
			"sound_music_stop",
			"sound_id_local",
			"sound_music_local",
		},
		["Speech"] = { -- TODO: locals
			"speech_env",
			"speech_npc",
		},
		[loc("REG_COMPANIONS")] = {
			"companion_dismiss_mount",
			"companion_dismiss_critter",
			"companion_random_critter",
		},
		["Inventory"] = { -- TODO: locals
			"item_sheath",
			"item_bag_durability",
			"item_consume",
		},
		["Variables"] = { -- TODO: locals
			"var_set_execenv",
		},
		["Debug"] = { -- TODO: locals
			"debug_dump_args",
			"debug_dump_arg",
			"debug_dump_text",
		},
		order = {
			loc("WO_EFFECT_CAT_COMMON"),
			"Speech",
			"Sound",
			loc("REG_COMPANIONS"),
			"Inventory",
			"Variables",
			"Debug"
		}
	}

	-- Workflow edition
	editor.workflow.title:SetText(loc("WO_EXECUTION"));
	editor.workflow.container.empty:SetText(loc("WO_EMPTY"));
	editor.workflow.container.add:SetText(loc("WO_ADD"));
	editor.workflow.container.add:SetScript("OnClick", function(self)
		setCurrentElementFrame(editor.element.selector, loc("WO_ELEMENT_TYPE"), true);
	end);
	editor.workflow.container.scroll.list.endofworkflow:SetText(loc("WO_END"));

	-- Element edition
	editor.element.confirm:SetText(loc("EDITOR_CONFIRM"));
	editor.element.title:SetText(loc("WO_ELEMENT"));
	editor.element.selector.effect.Name:SetText(loc("WO_EFFECT"));
	editor.element.selector.effect.InfoText:SetText(loc("WO_EFFECT_TT"));
	TRP3_API.ui.frame.setupIconButton(editor.element.selector.effect, ELEMENT_EFFECT_ICON);
	editor.element.selector.condition.Name:SetText(loc("WO_CONDITION"));
	editor.element.selector.condition.InfoText:SetText(loc("WO_CONDITION_TT"));
	TRP3_API.ui.frame.setupIconButton(editor.element.selector.condition, ELEMENT_CONDITION_ICON);
	editor.element.selector.delay.Name:SetText(loc("WO_DELAY"));
	editor.element.selector.delay.InfoText:SetText(loc("WO_DELAY_TT"));
	TRP3_API.ui.frame.setupIconButton(editor.element.selector.delay, ELEMENT_DELAY_ICON);
	editor.element.selector.condition:SetScript("OnClick", addConditionElement);
	editor.element.selector.condition:Disable(); -- TODO: remove
	editor.element.selector.delay:SetScript("OnClick", addDelayElement);
	editor.element.selector.effect:SetScript("OnClick", displayEffectDropdown);
	editor.element.close:SetScript("OnClick", function()
		editor.element:Hide();
		unlockElements();
	end);
	editor.element.confirm:SetScript("OnClick", function()
		onElementConfirm();
	end);
end