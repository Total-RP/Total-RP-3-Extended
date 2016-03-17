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
local wipe, pairs, tostring, tinsert, assert = wipe, pairs, tostring, tinsert, assert;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local editor = TRP3_ScriptEditorNormal;
local refreshList;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Workflow element
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local ELEMENT_TYPE = {
	EFFECT = "list",
	CONDITION = "branch",
	DELAY = "delay"
}

local function goToTypeSelector()
	editor.element.title:SetText("Step 1: Select the element type"); -- TODO: locals
	editor.element.selector:Show();
	editor.element:Show();
end

local function addDelayElement()
	assert(editor.list.data.ST, "No step structure.");
	editor.list.data.ST[tostring(editor.list.size + 1)] =  {
		t = ELEMENT_TYPE.DELAY,
		d = 1,
	};
	refreshList();
end

local function addConditionElement()
	assert(editor.list.data.ST, "No step structure.");
	editor.list.data.ST[tostring(editor.list.size + 1)] =  {
		t = ELEMENT_TYPE.CONDITION
	};
	refreshList();
end

local function addEffectElement(effectID)
	assert(editor.list.data.ST, "No step structure.");
	local effectInfo = TRP3_API.extended.tools.getEffectEditorInfo(effectID);
	editor.list.data.ST[tostring(editor.list.size + 1)] =  {
		t = ELEMENT_TYPE.EFFECT,
		e = {
			{
				id = effectID,
				args = effectInfo.getDefaultArgs()
			},
		}
	};
	refreshList();
end

local menuData = {
	["Common"] = {
		"text",
		"document_show"
	},
}

local function displayEffectDropdown(self)
	local values = {};
	tinsert(values, {"Select an effect", nil}); -- TODO: locals
	for sectionID, section in pairs(menuData) do
		local sectionTab = {};
		for _, effectID in pairs(section) do
			local effectInfo = TRP3_API.extended.tools.getEffectEditorInfo(effectID);
			tinsert(sectionTab, {effectInfo.title or effectID, effectID});
		end
		tinsert(values, {sectionID, sectionTab});
	end

	TRP3_API.ui.listbox.displayDropDown(self, values, addEffectElement, 0, true);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Workflow
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

editor.list.listElement = {};
local ELEMENT_DELAY_ICON = "spell_mage_altertime";
local ELEMENT_EFFECT_ICON = "inv_misc_enggizmos_37";
local ELEMENT_CONDITION_ICON = "Ability_druid_balanceofpower";

local function decorateEffect(scriptStepFrame, effectData)
	local effect = TRP3_API.script.getEffect(effectData.id);
	local effectInfo = TRP3_API.extended.tools.getEffectEditorInfo(effectData.id);
	local title = ("%s: %s"):format("Effect", effectInfo.title or UNKNOWN); -- TODO: locals

	TRP3_API.ui.frame.setupIconButton(scriptStepFrame, effectInfo.icon or ELEMENT_EFFECT_ICON);
	scriptStepFrame.title:SetText(title);

	-- Tooltip
	local tooltip = effectInfo.description or "";
	if effect.secured then
		tooltip = tooltip .. "\n\n|cffffff00" .. "Security level" .. ":\n"; -- TODO: locals
		if effect.secured == TRP3_API.script.security.HIGH then
			tooltip = tooltip .. "|cff00ff00High:|r This effect is secured and will not prompt security warning."; -- TODO: locals
		elseif effect.secured == TRP3_API.script.security.NORMAL then
			tooltip = tooltip .. "|cffffff00Normal:|r This effect is not secured and could be malicious. It will prompt security warning, based on the user security settings."; -- TODO: locals
		elseif effect.secured == TRP3_API.script.security.LOW then
			tooltip = tooltip .. "|cffff9900Low:|r This effect is not secured and could be malicious. It will prompt security warning, based on a more severe user security settings."; -- TODO: locals
		end
	end
	setTooltipForSameFrame(scriptStepFrame, "TOP", 0, 5, title, tooltip);

	if effectInfo.effectFrameDecorator then
		effectInfo.effectFrameDecorator(scriptStepFrame, effectData.args);
	end
end

local function decorateElement(scriptStepFrame)
	local scriptStep = scriptStepFrame.scriptStepData;
	scriptStepFrame.description:SetText("");
	if scriptStep.t == ELEMENT_TYPE.EFFECT then
		decorateEffect(scriptStepFrame, scriptStep.e[1]);
	elseif scriptStep.t == ELEMENT_TYPE.CONDITION then
		TRP3_API.ui.frame.setupIconButton(scriptStepFrame, ELEMENT_CONDITION_ICON);
		scriptStepFrame.title:SetText("Condition"); -- TODO: locals
		scriptStepFrame.description:SetText("Checks if: ..."); -- TODO: locals
	elseif scriptStep.t == ELEMENT_TYPE.DELAY then
		TRP3_API.ui.frame.setupIconButton(scriptStepFrame, ELEMENT_DELAY_ICON);
		scriptStepFrame.title:SetText("Delay"); -- TODO: locals
		scriptStepFrame.description:SetText(("Waits for |cffffff00%s seconds|r"):format(scriptStep.d)); -- TODO: locals
	end
end

function refreshList()
	assert(editor.list.data, "No data for effect list.");
	assert(editor.list.data.ST, "No step structure.");

	editor.element:Hide();
	for _, element in pairs(editor.list.listElement) do
		element:Hide();
		element:ClearAllPoints();
	end

	local scriptData = editor.list.data.ST;
	local stepID = 1;
	local previous;
	while scriptData[tostring(stepID)] do
		local scriptStep = scriptData[tostring(stepID)];
		local scriptStepFrame = editor.list.listElement[stepID];
		if not scriptStepFrame then
			scriptStepFrame = CreateFrame("Frame", "TRP3_EditorEffectFrame" .. stepID, editor.workflow.container.scroll.list, "TRP3_EditorEffectFrame");
			tinsert(editor.list.listElement, scriptStepFrame);
		end

		scriptStepFrame.scriptStepData = scriptStep;
		scriptStepFrame.scriptStepID = tostring(stepID);

		decorateElement(scriptStepFrame);

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
	assert(editor.data, "No data for refresh.");
	assert(editor.scriptID, "No scriptID for refresh.");

	if editor.mode == TRP3_DB.modes.NORMAL then
		editor.list.script:SetText(editor.scriptTitle or "");
		editor.list.description:SetText(editor.scriptDescription or "");

		if not editor.data[editor.scriptID] then
			editor.data[editor.scriptID] = {ST = {}};
		end
		editor.list.data = editor.data[editor.scriptID];
		refreshList();
	end

end
editor.refresh = refresh;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

editor.init = function(ToolFrame)

	-- Resize
	TRP3_API.events.listenToEvent(TRP3_API.events.NAVIGATION_EXTENDED_RESIZED, function(containerwidth, containerHeight)
		editor.workflow.container.scroll.list:SetWidth( (containerwidth/2) - 135 );
	end);

	-- List
	editor.list.title:SetText("Workflows"); -- TODO: locals

	-- Workflow edition
	editor.workflow.title:SetText("Workflow execution"); -- TODO: locals
	editor.workflow.container.empty:SetText("You can start by adding an element to your workflow.\nThis can be an effect, a condition or a delay."); -- TODO: locals
	editor.workflow.container.add:SetText("Add element to workflow"); -- TODO: locals
	editor.workflow.container.add:SetScript("OnClick", function(self)
		goToTypeSelector();
	end);
	editor.workflow.container.scroll.list.endofworkflow:SetText("End of workflow"); -- TODO: locals

	-- Element edition
	editor.element.title:SetText("Element edition"); -- TODO: locals
	editor.element.selector.effect.Name:SetText("Effect"); -- TODO: locals
	editor.element.selector.effect.InfoText:SetText("Plays an effect.\nIt can be playind sounds, displaying text ...etc"); -- TODO: locals
	TRP3_API.ui.frame.setupIconButton(editor.element.selector.effect, ELEMENT_EFFECT_ICON);
	editor.element.selector.condition.Name:SetText("Condition"); -- TODO: locals
	editor.element.selector.condition.InfoText:SetText("Evaluates a condition.\nStops the workflow if the condition fails."); -- TODO: locals
	TRP3_API.ui.frame.setupIconButton(editor.element.selector.condition, ELEMENT_CONDITION_ICON);
	editor.element.selector.delay.Name:SetText("Delay"); -- TODO: locals
	editor.element.selector.delay.InfoText:SetText("Pauses the workflow.\nCan also be used as cast duration and can be interrupt."); -- TODO: locals
	TRP3_API.ui.frame.setupIconButton(editor.element.selector.delay, ELEMENT_DELAY_ICON);
	editor.element.selector.condition:SetScript("OnClick", addConditionElement);
	editor.element.selector.delay:SetScript("OnClick", addDelayElement);
	editor.element.selector.effect:SetScript("OnClick", displayEffectDropdown);
end