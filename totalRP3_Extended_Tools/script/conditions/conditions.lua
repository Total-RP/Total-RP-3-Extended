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
local pairs, _G, type, tinsert, wipe, assert, tostring, strtrim = pairs, _G, type, tinsert, wipe, assert, tostring, strtrim;
local tsize, EMPTY = Utils.table.size, Globals.empty;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local initList = TRP3_API.ui.list.initList;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;
local getTTAction = TRP3_API.extended.getTTAction;

local editor = TRP3_ConditionEditor;
local operandEditor = editor.operand.editor;

local listCondition;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Operands structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local OPERANDS = {}
local leftListStructure, rightListStructure = {}, {};

local function registerOperandEditor(operandID, operandStructure)
	assert(not OPERANDS[operandID], "Already have an operand editor for " .. operandID);
	OPERANDS[operandID] = operandStructure;
end
TRP3_API.extended.tools.registerOperandEditor = registerOperandEditor;

local defaultInfo = {
	getText = function() return "?" end
}
local function getOperandEditorInfo(operandID)
	return OPERANDS[operandID] or defaultInfo;
end
TRP3_API.extended.tools.getOperandEditorInfo = getOperandEditorInfo;

local function getComparatorText(comparator)
	if comparator == "==" then
		return loc.OP_COMP_EQUALS;
	elseif comparator == "~=" then
		return loc.OP_COMP_NEQUALS;
	elseif comparator == "<" then
		return loc.OP_COMP_LESSER;
	elseif comparator == "<=" then
		return loc.OP_COMP_LESSER_OR_EQUALS;
	elseif comparator == ">" then
		return loc.OP_COMP_GREATER;
	elseif comparator == ">=" then
		return loc.OP_COMP_GREATER_OR_EQUALS;
	end
	return comparator;
end
TRP3_API.extended.tools.getComparatorText = getComparatorText;

local function getUnitText(unit)
	if unit == "player" then
		return loc.OP_UNIT_PLAYER;
	elseif unit == "target" then
		return loc.OP_UNIT_TARGET;
	elseif unit == "npc" then
		return loc.OP_UNIT_NPC;
	end
	return unit;
end
TRP3_API.extended.tools.getUnitText = getUnitText;

local function getValueString(value)
	if type(value) == "string" then
		return "\"" .. value .. "\"";
	elseif type(value) == "boolean" then
		return tostring(value):upper();
	else
		return tostring(value);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Level 2: Operands level
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function fillExpression(tab)
	wipe(tab);

	tab[1] = {i = operandEditor.left.operandID, a = operandEditor.left.argsData};
	tab[2] = operandEditor.comparator:GetSelectedValue();
	if operandEditor.right.operandID == "string" or operandEditor.right.operandID == "numeric" then
		tab[3] = {v = operandEditor.right.argsData};
	elseif operandEditor.right.operandID == "boolean_true" then
		tab[3] = {v = true};
	elseif operandEditor.right.operandID == "boolean_false" then
		tab[3] = {v = false};
	else
		tab[3] = {i = operandEditor.right.operandID, a = operandEditor.right.argsData};
	end
	return tab;
end

local function saveOperand()
	fillExpression(operandEditor.expression);
	listCondition();
end

local function loadOperandEditor(operandInfo, list)
	operandEditor.left.args:Hide();
	operandEditor.left.args.currentEditor = nil;
	operandEditor.right.args:Hide();
	operandEditor.right.args.currentEditor = nil;

	if operandInfo.editor then
		list.args:Show();
		list.args:SetFrameLevel(operandEditor:GetFrameLevel() + 20);
		list.args.title:SetText(operandInfo.title);
		operandInfo.editor:SetParent(list.args);
		operandInfo.editor:SetAllPoints(list.args);
		operandInfo.editor.load(list.argsData);
		list.args.currentEditor = operandInfo.editor;
		operandInfo.editor:Show();
	end
end

local function checkNumeric(value)
	---@type TotalRP3_Extended_Operand
	local leftOperand = TRP3_API.script.getOperand(operandEditor.left.operandID or "") or EMPTY;
	---@type TotalRP3_Extended_Operand
	local rightOperand = TRP3_API.script.getOperand(operandEditor.right.operandID or "") or EMPTY;
	local compa = value or operandEditor.comparator:GetSelectedValue();
	operandEditor.confirm:Enable();
	operandEditor.preview:Enable();
	operandEditor.numeric:Hide();
	if compa ~= "==" and compa ~= "~=" then
		if not leftOperand.numeric or (not rightOperand.numeric and operandEditor.right.operandID ~= "numeric") then
			operandEditor.confirm:Disable();
			operandEditor.preview:Disable();
			operandEditor.numeric:Show();
		end
	end
end

local function onOperandSelected(operandID, list, loadEditor)
	list.operandID = operandID;
	local fullText = operandID;

	list.args:Hide();
	if list.args.currentEditor then
		list.args.currentEditor:Hide();
	end
	list.args.currentEditor = nil;
	list.edit:Disable();
	list.preview:Disable();

	setTooltipForSameFrame(list, "TOP", 0, 0);

	local hasPreview = false;
	local operandInfo = getOperandEditorInfo(operandID);
	if operandInfo ~= EMPTY then
		fullText = operandInfo.getText and operandInfo.getText(list.argsData) or operandInfo.title;
		if operandInfo.editor then
			list.edit:Enable();
			if loadEditor then
				loadOperandEditor(operandInfo, list);
			end
		end
		if not operandInfo.noPreview then
			list.preview:Enable();
			hasPreview = true;
		end
		local returnType = type(operandInfo.returnType);
		local returnTypeText;
		if returnType == "boolean" then
			returnTypeText = "|cffffff00" .. loc.OP_BOOL .. "|r\n";
		elseif returnType == "string" then
			returnTypeText = "|cffffff00" .. loc.OP_STRING .. "|r\n";
		elseif returnType == "number" then
			returnTypeText = "|cffffff00" .. loc.OP_NUMERIC .. "|r\n";
		end
		if operandInfo.description and returnTypeText then
			setTooltipForSameFrame(list, "TOP", 0, 0, operandInfo.title, returnTypeText .. operandInfo.description);
		else
			setTooltipForSameFrame(list, "TOP", 0, 0, operandInfo.title);
		end
	end

	_G[list:GetName() .. "Text"]:SetText(fullText);
	checkNumeric();

	return hasPreview;
end

local function onOperandEditClick(button)
	local list = button:GetParent();
	local operandInfo = getOperandEditorInfo(list.operandID);
	loadOperandEditor(operandInfo, list);
end

local previewEnv = {
	["displayMessage"] = "TRP3_API.utils.message.displayMessage",
	tostring = "tostring",
	tonumber = "tonumber",
}

local function onPreviewClick(button)
	local list = button:GetParent();
	---@type TotalRP3_Extended_Operand
	local operandInfo = TRP3_API.script.getOperand(list.operandID);
	if operandInfo then
		local code = ("displayMessage(\"|cffff9900" .. loc.OP_PREVIEW .. ":|cffffffff \" .. tostring(%s));"):format(operandInfo:CodeReplacement(list.argsData or EMPTY));
		local env = {};
		Utils.table.copy(env, previewEnv);
		Utils.table.copy(env, operandInfo.env);
		TRP3_API.script.generateAndRun(code, nil, env);
	end
end

local function onTestPreview()
	local env = {};
	local code = TRP3_API.script.getTestCode(fillExpression({}), env);
	code = ("displayMessage(\"|cffff9900" .. loc.COND_PREVIEW_TEST .. ":|cffffffff \" .. tostring(%s));"):format(code);
	Utils.table.copy(env, previewEnv);
	TRP3_API.script.generateAndRun(code, nil, env);
end

local function onOperandConfirmClick(button)
	local argsFrame = button:GetParent();
	local list = argsFrame:GetParent();

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
	local hasPreview = onOperandSelected(leftOperand.i, operandEditor.left);

	if rightOperand.v ~= nil then
		operandEditor.right.argsData = rightOperand.v;
		if type(rightOperand.v) == "string" then
			onOperandSelected("string", operandEditor.right);
		elseif type(rightOperand.v) == "number" then
			onOperandSelected("numeric", operandEditor.right);
		elseif type(rightOperand.v) == "boolean" and rightOperand.v then
			onOperandSelected("boolean_true", operandEditor.right);
		elseif type(rightOperand.v) == "boolean" and not rightOperand.v then
			onOperandSelected("boolean_false", operandEditor.right);
		end
	else
		operandEditor.right.argsData = rightOperand.a;
		onOperandSelected(rightOperand.i, operandEditor.right, rightOperand.a);
	end

	operandEditor.left.args:Hide();
	operandEditor.right.args:Hide();

	editor.operand:Show();
	editor.operand:SetFrameLevel(editor:GetFrameLevel() + 10);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Level 1: Condition level
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function computeLogicalExpression(scriptData)
	local text = "";
	local isInParenthesis = false;
	for index, element in pairs(scriptData) do
		if type(element) == "string" then
			if element == "+" then
				text = text .. "|cff00ff00" .. loc.OP_AND .. " ";
			elseif element == "*" then
				text = text .. "|cff00ff00" .. loc.OP_OR .. " ";
			end
		elseif type(element) == "table" then
			local realIndex = (index + 1) / 2;
			if index == #scriptData and isInParenthesis then -- End of condition
			text = text .. "|cffff9900" .. realIndex .. " |cffffffff) ";
			isInParenthesis = false;
			elseif index < #scriptData then
				if scriptData[index + 1] == "+" and isInParenthesis then
					text = text .. "|cffff9900" .. realIndex .. " |cffffffff) ";
					isInParenthesis = false;
				elseif scriptData[index + 1] == "*" and not isInParenthesis then
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
	return text;
end

listCondition = function()
	editor.operand:Hide();
	initList(editor, editor.scriptData, editor.slider);
	editor.full:SetText(computeLogicalExpression(editor.scriptData));
end

local function addExpression()
	tinsert(editor.scriptData, "+");
	tinsert(editor.scriptData, { { i = "unit_name", a = {"target"} }, "==", { v = "Elsa" } });
	listCondition();
end

local TEST_ACTION_REMOVE = 1;
local TEST_ACTION_DUPLICATE = 2;

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
	elseif value == TEST_ACTION_DUPLICATE then
		local origin = editor.scriptData[index];
		tinsert(editor.scriptData, "+");
		tinsert(editor.scriptData, {});
		Utils.table.copy(editor.scriptData[#editor.scriptData], origin);
		listCondition();
	end
end

local function switchComparator(line)
	local index = line:GetParent().index;
	if editor.scriptData[index] == "*" then
		editor.scriptData[index] = "+";
	else
		editor.scriptData[index] = "*";
	end
	listCondition();
end

local function onTestLineClick(line, button)
	local index = line:GetParent().index;
	local expression = editor.scriptData[index];

	if type(expression) == "string" then
		switchComparator(line);
	elseif type(expression) == "table" then
		if button == "LeftButton" then
			if IsControlKeyDown() then
				onTestAction(TEST_ACTION_DUPLICATE, line);
			else
				openOperandEditor(index);
			end
		elseif button == "MiddleButton" then
			if #editor.scriptData > 1 then
				onTestAction(TEST_ACTION_REMOVE, line);
			end
		elseif button == "RightButton" then
			local context = {};
			tinsert(context, {loc.COND_TEST_EDITOR});
			tinsert(context, {loc.CA_NPC_AS, TEST_ACTION_DUPLICATE});
			if #editor.scriptData > 1 then
				tinsert(context, {loc.CM_REMOVE, TEST_ACTION_REMOVE});
			end
			TRP3_API.ui.listbox.displayDropDown(line, context, onTestAction, 0, true);
		end
	end
end

local function getExpressionText(expression)
	assert(tsize(expression) == 3, "Table expression must be in 3 parts.");
	local leftOperand = expression[1];
	local comparator = getComparatorText(expression[2]);
	local rightOperand = expression[3];
	local leftInfo = getOperandEditorInfo(leftOperand.i);
	local rightInfo = getOperandEditorInfo(rightOperand.i);

	local leftText = leftOperand.i and leftInfo.getText(leftOperand.a) or getValueString(leftOperand.v);
	local rightText = rightOperand.i and rightInfo.getText(rightOperand.a) or getValueString(rightOperand.v);
	return "|cffffff00" .. leftText .. "  |cff00ff00" .. comparator .. "  |cffffff00" .. rightText;
end

local function decorateConditionLine(line, index)
	local expression = editor.scriptData[index];
	line.index = index;

	if type(expression) == "string" then
		line.text:SetText("?");
		if expression == "+" then
			line.text:SetText(loc.OP_AND);
			setTooltipForSameFrame(line.click, "RIGHT", 0, 5, loc.OP_AND, getTTAction(loc.CM_CLICK, loc.OP_OR_SWITCH));
		elseif expression == "*" then
			line.text:SetText(loc.OP_OR);
			setTooltipForSameFrame(line.click, "RIGHT", 0, 5, loc.OP_OR, getTTAction(loc.CM_CLICK, loc.OP_AND_SWITCH));
		end
	elseif type(expression) == "table" then
		line.text:SetText("|cffff9900" .. ((index + 1) / 2) .. ".  " .. getExpressionText(expression));
		local tooltip = getTTAction(loc.CM_CLICK, loc.CM_EDIT) .. getTTAction(loc.CM_CTRL .. " + " .. loc.CM_CLICK, loc.CA_NPC_AS, true);
		if #editor.scriptData > 1 then
			tooltip = tooltip .. getTTAction(loc.CM_M_CLICK, loc.CM_REMOVE, true);
		end
		setTooltipForSameFrame(line.click, "RIGHT", 0, 5, loc.COND_TEST_EDITOR, tooltip);
	end
end

function editor.getConditionPreview(scriptData)
	local size = tsize(scriptData);
	if size == 1 then
		return getExpressionText(scriptData[1]);
	else
		return computeLogicalExpression(scriptData);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Load and save
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function editor.save(scriptData, branchingStepData)
	wipe(scriptData);
	Utils.table.copy(scriptData, editor.scriptData);
	if branchingStepData then
		branchingStepData.failMessage = stEtN(strtrim(editor.failMessage:GetText()));
		branchingStepData.failWorkflow = stEtN(strtrim(editor.failWorkflow:GetText()));
	end
end

function editor.load(scriptData, branchingStepData)
	wipe(editor.scriptData);
	Utils.table.copy(editor.scriptData, scriptData);
	editor.failMessage:Hide();
	editor.failWorkflow:Hide();
	if branchingStepData then
		editor.failMessage:Show();
		editor.failMessage:SetText(branchingStepData.failMessage or "");
		editor.failWorkflow:Show();
		editor.failWorkflow:SetText(branchingStepData.failWorkflow or "");
	end
	listCondition();
end

local getEvaluatedOperands = function(structure)
	local evaluatedOperands = {
		[loc.OP_UNIT_VALUE] = {
			"unit_name",
			"unit_id",
			"unit_npc_id",
			"unit_guild",
			"unit_guild_rank",
			"unit_creature_type",
			"unit_creature_family",
			"unit_classification",
			"unit_sex",
			"unit_class",
			"unit_race",
			"unit_faction",
			"unit_health",
			"unit_level",
			"unit_speed",
			"unit_position_x",
			"unit_position_y",
			"unit_distance_point",
			"unit_distance_me",
		},
		[loc.OP_UNIT_TEST] = {
			"unit_is_player",
			"unit_exists",
			"unit_is_dead",
			"unit_distance_trade",
			"unit_distance_inspect",
		},
		[CHARACTER] = {
			"char_falling",
			"char_stealth",
			"char_flying",
			"char_mounted",
			"char_resting",
			"char_swimming",
			"char_indoors",
			"char_facing",
			"char_zone",
			"char_subzone",
			"char_minimap",
			"char_cam_distance",
			"char_achievement",
		},
		--		["Pets and companions"] = { -- TODO: locals
		--			"pet_battle_name",
		--			"pet_pet_name",
		--			"pet_mount_name",
		--		},
		[loc.INV_PAGE_CHARACTER_INV] = {
			"inv_item_count",
			"inv_item_weight"
			--			"inv_durability",
			--			"inv_empty_slot",
		},
		[loc.EFFECT_CAT_CAMPAIGN] = {
			"quest_is_step",
			"quest_obj",
			"quest_obj_current",
			"quest_obj_all",
			"quest_is_npc",
		},
		["Expert"] = {-- TODO: locals
			"var_check",
			"var_check_n",
			"check_event_var",
			"check_event_var_n",
		},
		["Others"] = {-- TODO: locals
			"random",
			"time_hour",
			"time_minute",
		},
	}

	local evaluatedOrder = {
		loc.OP_UNIT_VALUE,
		loc.OP_UNIT_TEST,
		CHARACTER,
		--		"Pets and companions", -- TODO: locals
		loc.INV_PAGE_CHARACTER_INV,
		loc.EFFECT_CAT_CAMPAIGN,
		"Others", -- TODO: locals
		"",
		"Expert", -- TODO: locals
	}

	wipe(structure);
	tinsert(structure, {loc.OP_EVAL_VALUE});
	for _, group in pairs(evaluatedOrder) do
		local subStructure = {};
		tinsert(subStructure, {group});

		for _, operandID in pairs(evaluatedOperands[group] or EMPTY) do
			local operandInfo = getOperandEditorInfo(operandID);
			tinsert(subStructure, {operandInfo.title or operandID, operandID, operandInfo.description});
		end

		tinsert(structure, {group, subStructure});
	end
	return structure;
end
TRP3_API.extended.tools.getEvaluatedOperands = getEvaluatedOperands;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function editor.init()
	editor.scriptData = {};

	editor.listheader:SetText(loc.COND_TESTS);
	editor.fullheader:SetText(loc.COND_COMPLETE);
	editor.add:SetText(loc.OP_ADD_TEST);
	editor.add:SetScript("OnClick", addExpression);

	editor.failMessage.title:SetText(loc.OP_FAIL);
	setTooltipForSameFrame(editor.failMessage.help, "TOP", 0, 0, loc.OP_FAIL, loc.OP_FAIL_TT);

	editor.failWorkflow.title:SetText(loc.OP_FAIL_W);
	setTooltipForSameFrame(editor.failWorkflow.help, "TOP", 0, 0, loc.OP_FAIL_W, loc.OP_FAIL_W_TT);

	editor.widgetTab = {};
	for i=1, 6 do
		local line = editor["line" .. i];
		tinsert(editor.widgetTab, line);
		line.click:SetScript("OnClick", onTestLineClick);
		line.click:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp");
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
	operandEditor.confirm:SetText(loc.EDITOR_CONFIRM);
	operandEditor.title:SetText(loc.COND_TEST_EDITOR);
	operandEditor.numeric:SetText(loc.COND_NUM_FAIL);
	operandEditor.preview:SetText(loc.COND_PREVIEW_TEST);
	setTooltipForSameFrame(operandEditor.preview, "TOP", 0, 0, loc.COND_PREVIEW_TEST, loc.COND_PREVIEW_TEST_TT);
	operandEditor.preview:SetScript("OnClick", onTestPreview);

	local comparatorStructure = {
		{loc.COND_LITT_COMP},
		{getComparatorText("=="), "=="},
		{getComparatorText("~="), "~="},
		{loc.COND_NUM_COMP},
		{getComparatorText("<"), "<"},
		{getComparatorText("<="), "<="},
		{getComparatorText(">"), ">"},
		{getComparatorText(">="), ">="},
	}
	TRP3_API.ui.listbox.setupListBox(operandEditor.comparator, comparatorStructure, checkNumeric, nil, 175, true);

	TRP3_API.ui.listbox.setupListBox(operandEditor.left, getEvaluatedOperands(leftListStructure), function(operandID, list)
		list.argsData = nil;
		onOperandSelected(operandID, list, true);
	end, nil, 220, true);
	TRP3_API.ui.frame.configureHoverFrame(operandEditor.left.args, operandEditor.left, "TOP", 0, 5, true, operandEditor.left);
	operandEditor.left.preview:SetText(loc.OP_PREVIEW);
	operandEditor.left.edit:SetText(loc.OP_CONFIGURE);
	operandEditor.left.args.confirm:SetText(loc.EDITOR_CONFIRM);
	operandEditor.left.args.confirm:SetScript("OnClick", onOperandConfirmClick);
	operandEditor.left.edit:SetScript("OnClick", onOperandEditClick);
	operandEditor.left.preview:SetScript("OnClick", onPreviewClick);
	setTooltipForSameFrame(operandEditor.left.preview, "TOP", 0, 0, loc.OP_PREVIEW, loc.OP_CURRENT_TT);
	setTooltipAll(operandEditor.left, "TOP", 0, 0);

	local rightStructure = {
		{loc.OP_EVAL_VALUE, getEvaluatedOperands({})},
		{loc.OP_DIRECT_VALUE, {
			{loc.OP_DIRECT_VALUE},
			{loc.OP_STRING, "string"},
			{loc.OP_NUMERIC, "numeric"},
			{loc.OP_BOOL, {
				{loc.OP_BOOL_TRUE, "boolean_true"},
				{loc.OP_BOOL_FALSE, "boolean_false"},
			}},
		}},
	}
	TRP3_API.ui.listbox.setupListBox(operandEditor.right, rightStructure, function(operandID, list)
		list.argsData = nil;
		onOperandSelected(operandID, list, true);
	end, nil, 220, true);
	TRP3_API.ui.frame.configureHoverFrame(operandEditor.right.args, operandEditor.right, "TOP", 0, 5, true, operandEditor.right);
	operandEditor.right.preview:SetText(loc.OP_PREVIEW);
	operandEditor.right.edit:SetText(loc.OP_CONFIGURE);
	operandEditor.right.args.confirm:SetText(loc.EDITOR_CONFIRM);
	operandEditor.right.args.confirm:SetScript("OnClick", onOperandConfirmClick);
	operandEditor.right.edit:SetScript("OnClick", onOperandEditClick);
	operandEditor.right.preview:SetScript("OnClick", onPreviewClick);
	setTooltipForSameFrame(operandEditor.right.preview, "TOP", 0, 0, loc.OP_PREVIEW, loc.OP_CURRENT_TT);
	setTooltipAll(operandEditor.right, "TOP", 0, 0);

end
