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
local pairs, _G, type, tinsert, wipe, assert = pairs, _G, type, tinsert, wipe, assert;
local tsize, EMPTY = Utils.table.size, Globals.empty;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local initList = TRP3_API.ui.list.initList;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local editor = TRP3_ConditionEditor;
local operandEditor = editor.operand.editor;

local listCondition;

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
		return "is equal to"; -- TODO: locals
	elseif comparator == "~=" then
		return "is not equal to"; -- TODO: locals
	elseif comparator == "<" then
		return "is lesser than"; -- TODO: locals
	elseif comparator == "<=" then
		return "is lesser than or equal to"; -- TODO: locals
	elseif comparator == ">" then
		return "is greater than"; -- TODO: locals
	elseif comparator == ">=" then
		return "is greater than or equal to"; -- TODO: locals
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

local function getValueString(value)
	if type(value) == "string" then
		return "\"" .. value .. "\"";
	else
		return tostring(value);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Level 2: Operands level
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function saveOperand()
	wipe(operandEditor.expression);

	operandEditor.expression[1] = {i = operandEditor.left.operandID, a = operandEditor.left.argsData};
	operandEditor.expression[2] = operandEditor.comparator:GetSelectedValue();
	if operandEditor.right.operandID == "string" then
		operandEditor.expression[3] = {v = operandEditor.right.argsData};
	else
		operandEditor.expression[3] = {i = operandEditor.right.operandID, a = operandEditor.right.argsData};
	end

	listCondition();
end

local function loadOperandEditor(operandInfo, list)
	operandEditor.left.args:Hide();
	operandEditor.left.args.currentEditor = nil;
	operandEditor.right.args:Hide();
	operandEditor.right.args.currentEditor = nil;

	if operandInfo.editor then
		list.args:Show();
		list.args.title:SetText(operandInfo.title);
		operandInfo.editor:SetParent(list.args);
		operandInfo.editor:SetAllPoints(list.args);
		operandInfo.editor.load(list.argsData);
		list.args.currentEditor = operandInfo.editor;
		operandInfo.editor:Show();
	end
end

local function onOperandSelected(operandID, list, loadEditor)
	list.operandID = operandID;
	local fullText = operandID;

	list.args:Hide();
	list.args.currentEditor = nil;
	list.edit:Disable();

	local operandInfo = getOperandEditorInfo(operandID);
	if operandInfo ~= EMPTY then
		fullText = operandInfo.getText and operandInfo.getText(list.argsData) or operandInfo.title;
		if operandInfo.editor then
			list.edit:Enable();
			if loadEditor then
				loadOperandEditor(operandInfo, list);
			end
		end
	end

	_G[list:GetName() .. "Text"]:SetText(fullText);
end

local function onOperandEditClick(button)
	local list = button:GetParent();
	local operandInfo = getOperandEditorInfo(list.operandID);
	loadOperandEditor(operandInfo, list);
end

local function onOperandConfirmClick(button)
	local argsFrame = button:GetParent();
	local list = argsFrame:GetParent();

	print(argsFrame:GetName());
	print(list:GetName());

	if argsFrame.currentEditor then
		list.argsData = argsFrame.currentEditor.save();
		onOperandSelected(list.operandID, list)
	end
end

local function openOperandEditor(expressionIndex)
	local expression = editor.scriptData[expressionIndex];
	assert(type(expression) == "table", "operand structure is not a table");
	assert(tsize(expression) == 3, "Table expression must be in 3 parts.");

	local leftOperand = expression[1];
	local comparator = expression[2];
	local rightOperand = expression[3];

	operandEditor.expression = expression;
	operandEditor.comparator:SetSelectedValue(comparator);

	operandEditor.left.argsData = leftOperand.a;
	onOperandSelected(leftOperand.i, operandEditor.left);

	if rightOperand.v then
		operandEditor.right.argsData = leftOperand.v;
		if type(rightOperand.v) == "string" then
			onOperandSelected("string", operandEditor.right, rightOperand.v);
		elseif type(rightOperand.v) == "number" then
			onOperandSelected("numeric", operandEditor.right, rightOperand.v);
		elseif type(rightOperand.v) == "boolean" and rightOperand.v then
			onOperandSelected("boolean_true", operandEditor.right);
		elseif type(rightOperand.v) == "boolean" and not rightOperand.v then
			onOperandSelected("boolean_false", operandEditor.right);
		end
	else
		operandEditor.right.argsData = leftOperand.a;
		onOperandSelected(rightOperand.i, operandEditor.right, rightOperand.a);
	end

	operandEditor.left.args:Hide();
	operandEditor.right.args:Hide();

	editor.operand:Show();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Level 1: Condition level
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function computeLogicalExpression()
	local text = "";
	local isInParenthesis = false;
	for index, element in pairs(editor.scriptData) do
		if type(element) == "string" then
			if element == "+" then
				text = text .. "|cff00ff00and" .. " "; -- TODO: locals
			elseif element == "*" then
				text = text .. "|cff00ff00or" .. " "; -- TODO: locals
			else
				text = text .. "|cff00ff00?" .. " ";
			end
		elseif type(element) == "table" then
			local realIndex = (index + 1) / 2;
			if index == #editor.scriptData and isInParenthesis then -- End of condition
			text = text .. "|cffff9900" .. realIndex .. " |cffffffff) ";
			isInParenthesis = false;
			elseif index < #editor.scriptData then
				if editor.scriptData[index + 1] == "+" and isInParenthesis then
					text = text .. "|cffff9900" .. realIndex .. " |cffffffff) ";
					isInParenthesis = false;
				elseif editor.scriptData[index + 1] == "*" and not isInParenthesis then
					text = text .. "|cffffffff( " .. "|cffff9900" .. realIndex .. " ";
					isInParenthesis = true;
				else
					text = text .. "|cffff9900" .. realIndex .. " ";
				end
			else
				text = text .. "|cffff9900" .. realIndex .. " ";
			end
		end
	end
	editor.full:SetText(text);
end

listCondition = function()
	editor.operand:Hide();
	initList(editor, editor.scriptData, editor.slider);
	computeLogicalExpression();
end

local function addExpression()
	tinsert(editor.scriptData, "+");
	tinsert(editor.scriptData, { { i = "unit_name", a = {"target"} }, "==", { v = "Elsa" } });
	listCondition();
end

local TEST_ACTION_REMOVE = 1;

local function onTestAction(value, line)
	local index = line:GetParent().index;
	if value == TEST_ACTION_REMOVE then
		table.remove(editor.scriptData, index);
		if index > 1 then
			table.remove(editor.scriptData, index - 1);
		else
			table.remove(editor.scriptData, index);
		end
		listCondition();
	end
end

local function onComparatorAction(value, line)
	local index = line:GetParent().index;
	editor.scriptData[index] = value;
	listCondition();
end

local function onTestLineClick(line, button)
	local index = line:GetParent().index;
	local expression = editor.scriptData[index];
	local values = {};

	if type(expression) == "string" then
		tinsert(values, {"Comparator selection", nil});
		if expression == "+" then
			tinsert(values, {"Switch to OR", "*"}); -- TODO: locals
		else
			tinsert(values, {"Switch to AND", "+"}); -- TODO: locals
		end
		TRP3_API.ui.listbox.displayDropDown(line, values, onComparatorAction, 0, true);
	elseif type(expression) == "table" then
		if button == "LeftButton" then
			openOperandEditor(index);
		else
			tinsert(values, {"Test", nil});
			if #editor.scriptData > 1 then
				tinsert(values, {"Remove test", TEST_ACTION_REMOVE}); -- TODO: locals
			end
			TRP3_API.ui.listbox.displayDropDown(line, values, onTestAction, 0, true);
		end
	end
end

local function decorateConditionLine(line, index)
	local expression = editor.scriptData[index];
	line.index = index;

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

		local leftText = leftOperand.i and getOperandEditorInfo(leftOperand.i).getText(leftOperand.a or EMPTY) or getValueString(leftOperand.v);
		local rightText = rightOperand.i and getOperandEditorInfo(rightOperand.i).getText(rightOperand.a or EMPTY) or getValueString(rightOperand.v);
		line.text:SetText("|cffff9900" .. ((index + 1) / 2) .. ".  |cffffff00" .. leftText .. "  |cff00ff00" .. comparator .. "  |cffffff00" .. rightText);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Load and save
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function editor.save(scriptData)
	wipe(scriptData);
	Utils.table.copy(scriptData, editor.scriptData);
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

	editor.listheader:SetText("Condition tests:"); -- TODO: locals
	editor.fullheader:SetText("Complete logical expression:"); -- TODO: locals
	editor.add:SetText("Add test");

	editor.add:SetScript("OnClick", addExpression);

	editor.widgetTab = {};
	for i=1, 8 do
		local line = editor["line" .. i];
		tinsert(editor.widgetTab, line);
		line.click:SetScript("OnClick", onTestLineClick);
		line.click:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	end
	editor.decorate = decorateConditionLine;
	handleMouseWheel(editor, editor.slider);
	editor.slider:SetValue(0);

	operandEditor.close:SetScript("OnClick", function()
		editor.operand:Hide();
	end);
	operandEditor.confirm:SetScript("OnClick", function()
		saveOperand();
	end);
	operandEditor.confirm:SetText(loc("EDITOR_CONFIRM"));
	operandEditor.title:SetText("Test editor"); -- TODO: locals

	local comparatorStructure = {
		{"Litteral and numeric comparison"}, -- TODO: locals
		{getComparatorText("=="), "=="},
		{getComparatorText("~="), "~="},
		{"Numeric comparison only"}, -- TODO: locals
		{getComparatorText("<"), "<"},
		{getComparatorText("<="), "<="},
		{getComparatorText(">"), ">"},
		{getComparatorText(">="), ">="},
	}
	TRP3_API.ui.listbox.setupListBox(operandEditor.comparator, comparatorStructure, nil, nil, 175, true);

	local leftStructure = {
		{"Evaluated value"}, -- TODO: locals
		{"Unit value", { -- TODO: locals
			{"Unit name", "unit_name"}, -- TODO: locals
			{"Unit guild", "unit_guild"}, -- TODO: locals
			{"Unit type", "unit_type"}, -- TODO: locals
			{"Unit classification", "unit_classification"}, -- TODO: locals
			{"Unit sex", "unit_sex"}, -- TODO: locals
			{"Unit class", "unit_class"}, -- TODO: locals
			{"Unit race", "unit_race"}, -- TODO: locals
		}},
		{"Unit test", { -- TODO: locals
			{"Unit in range", "unit_range"}, -- TODO: locals
			{"Unit exists", "unit_exists"}, -- TODO: locals
			{"Unit is dead", "unit_dead"}, -- TODO: locals
			{"Unit is mounted", "unit_mounted"}, -- TODO: locals
			{"Unit is flying", "unit_flying"}, -- TODO: locals

		}},
		{"Character", { -- TODO: locals
			{"Character is falling", "char_falling"}, -- TODO: locals
			{"Character is stealth", "char_stealth"}, -- TODO: locals
			{"Character is swimming", "char_swimming"}, -- TODO: locals
			{"Character can fly", "char_can_fly"}, -- TODO: locals
			{"Character coordinates", "char_coord"}, -- TODO: locals
			{"Character zone", "char_zone"}, -- TODO: locals
			{"Character subzone", "char_subzone"}, -- TODO: locals
			{"Character facing", "char_facing"}, -- TODO: locals
		}},
		{"Pets and companions", { -- TODO: locals
			{"Summoned battle pet name", "pet_battle_name"}, -- TODO: locals
			{"Summoned pet name", "pet_pet_name"}, -- TODO: locals
			{"Summoned mount name", "pet_mount_name"}, -- TODO: locals
		}},
		{"Campaign and quests", { -- TODO: locals
			{"Campaign is started", "campaign_started"}, -- TODO: locals
			{"Quest is started", "campaign_quest_started"}, -- TODO: locals
		}},
		{"Inventory", { -- TODO: locals
			{"Container durability", "inv_durability"}, -- TODO: locals
			{"Container total weight", "inv_weight"}, -- TODO: locals
			{"Container empty slot", "inv_empty_slot"}, -- TODO: locals
		}},
		{"Random", "random"}, -- TODO: locals
	};
	TRP3_API.ui.listbox.setupListBox(operandEditor.left, leftStructure, function(operandID, list)
		list.argsData = nil;
		onOperandSelected(operandID, list, true);
	end, nil, 220, true);
	TRP3_API.ui.frame.configureHoverFrame(operandEditor.left.args, operandEditor.left, "TOP", 115, 5, false, operandEditor.left);
	operandEditor.left.preview:SetText("Preview value"); -- TODO: locals
	operandEditor.left.edit:SetText(loc("CM_EDIT"));
	operandEditor.left.args.confirm:SetText(loc("EDITOR_CONFIRM"));
	operandEditor.left.args.confirm:SetScript("OnClick", onOperandConfirmClick);
	operandEditor.left.edit:SetScript("OnClick", onOperandEditClick);

	local rightStructure = {
		{"Evaluated value", leftStructure}, -- TODO: locals
		{"Direct value", { -- TODO: locals
			{"Direct value"}, -- TODO: locals
			{"String", "string"}, -- TODO: locals
			{"Numeric", "numeric"}, -- TODO: locals
			{"Boolean", { -- TODO: locals
				{"True", "boolean_true"}, -- TODO: locals
				{"False", "boolean_false"}, -- TODO: locals
			}},
		}},
	}
	TRP3_API.ui.listbox.setupListBox(operandEditor.right, rightStructure, function(operandID, list)
		list.argsData = nil;
		onOperandSelected(operandID, list, true);
	end, nil, 220, true);
	TRP3_API.ui.frame.configureHoverFrame(operandEditor.right.args, operandEditor.right, "TOP", 115, 5, false, operandEditor.right);
	operandEditor.right.preview:SetText("Preview value"); -- TODO: locals
	operandEditor.right.edit:SetText(loc("CM_EDIT"));
	operandEditor.right.args.confirm:SetText(loc("EDITOR_CONFIRM"));
	operandEditor.right.args.confirm:SetScript("OnClick", onOperandConfirmClick);
	operandEditor.right.edit:SetScript("OnClick", onOperandEditClick);

end