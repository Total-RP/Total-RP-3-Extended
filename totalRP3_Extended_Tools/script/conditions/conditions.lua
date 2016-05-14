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
local tonumber, tostring, type, tinsert, wipe, assert = tonumber, tostring, type, tinsert, wipe, assert;
local tsize, EMPTY = Utils.table.size, Globals.empty;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local initList = TRP3_API.ui.list.initList;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local editor = TRP3_ConditionEditor;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Operands structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local OPERANDS = {}

local function registerOperandEditor(operandID, operandStructure)
	assert(not OPERANDS[operandID], "Already have an operand editor for " .. operandID);
	OPERANDS[operandID] = operandStructure;
end
TRP3_API.extended.tools.registerOperandEditor = registerOperandEditor;

local function getOperandEditorInfo(operandID)
	return OPERANDS[operandID] or Globals.empty;
end
TRP3_API.extended.tools.getOperandEditorInfo = getOperandEditorInfo;

local function getComparatorText(comparator)
	if comparator == "==" then
		return "equals"; -- TODO: locals
	elseif comparator == "~=" then
		return "not equals"; -- TODO: locals
	elseif comparator == "<" then
		return "lesser than"; -- TODO: locals
	elseif comparator == "<=" then
		return "lesser than or equals"; -- TODO: locals
	elseif comparator == ">" then
		return "greater than"; -- TODO: locals
	elseif comparator == ">=" then
		return "greater than or equals"; -- TODO: locals
	end
	return comparator;
end
TRP3_API.extended.tools.getComparatorText = getComparatorText;

local function getUnitText(unit)
	if unit == "player" then
		return "Player"; -- TODO: locals
	elseif unit == "target" then
		return "Target"; -- TODO: locals
	end
	return unit;
end
TRP3_API.extended.tools.getUnitText = getUnitText;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Level 2: Operands level
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Level 1: Condition level
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function listCondition()
	initList(editor, editor.scriptData, editor.slider);
end

local function addExpression()
	tinsert(editor.scriptData, "+");
	tinsert(editor.scriptData, { { i = "unit_name", args = {"target"} }, "==", { v = "Elsa" } });
	listCondition();
end

local function getValueString(value)
	if type(value) == "string" then
		return "\"" .. value .. "\"";
	else
		return tostring(value);
	end
end

local function decorateConditionLine(line, index)
	local expression = editor.scriptData[index];

	if type(expression) == "string" then
		line.text:SetText("?");
		if expression == "+" then
			line.text:SetText("And"); -- TODO: locals
		elseif expression == "*" then
			line.text:SetText("Or"); -- TODO: locals
		end
	elseif type(expression) == "table" then
		assert(tsize(expression) == 3, "Table expression must be in 3 parts.");
		local leftOperand = expression[1];
		local comparator = getComparatorText(expression[2]);
		local rightOperand = expression[3];

		local leftText = leftOperand.i and getOperandEditorInfo(leftOperand.i).getText(leftOperand.args or EMPTY) or getValueString(leftOperand.v);
		local rightText = rightOperand.i and getOperandEditorInfo(rightOperand.i).getText(rightOperand.args or EMPTY) or getValueString(rightOperand.v);
		line.text:SetText("|cffff9900" .. index .. ".  |cffffff00" .. leftText .. "  |cff00ff00" .. comparator .. "  |cffffff00" .. rightText);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Load and save
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function editor.save(scriptData)
	-- TODO: make a copy to work on
end

function editor.load(scriptData)
	wipe(editor.scriptData);
	Utils.table.copy(editor.scriptData, scriptData);
	listCondition();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function editor.init()
	editor.scriptData = {};

	editor.listheader:SetText("Condition expressions:"); -- TODO: locals
	editor.fullheader:SetText("Complete logical expression:"); -- TODO: locals
	editor.add:SetText("Add expression");

	editor.add:SetScript("OnClick", addExpression);

	editor.widgetTab = {};
	for i=1, 8 do
		local line = editor["line" .. i];
		tinsert(editor.widgetTab, line);
	end
	editor.decorate = decorateConditionLine;
	handleMouseWheel(editor, editor.slider);
	editor.slider:SetValue(0);
end