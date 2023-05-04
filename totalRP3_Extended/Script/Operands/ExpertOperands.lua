-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

---@type TRP3_API
local TRP3_API = TRP3_API;

---@type TotalRP3_Extended_Operand
local Operand = TRP3_API.script.Operand;
---@type TotalRP3_Extended_NumericOperand
local NumericOperand = TRP3_API.script.NumericOperand;

local getSafe = TRP3_API.getSafeValueFromTable

local checkVariableValueOperand = Operand("var_check", {
	["varCheck"] = "TRP3_API.script.varCheck"
});

function checkVariableValueOperand:CodeReplacement(args)
	local source = getSafe(args, 1, "w");
	local var = getSafe(args, 2, "");
	return ([[varCheck(args, "%s", "%s")]]):format(source, var);
end

local checkNumericVariableValueOperand = NumericOperand("var_check_n", {
	["varCheckN"] = "TRP3_API.script.varCheckN"
});

function checkNumericVariableValueOperand:CodeReplacement(args)
	local source = getSafe(args, 1, "w");
	local var = getSafe(args, 2, "");
	return ([[varCheckN(args, "%s", "%s")]]):format(source, var);
end

local checkEventVariableValueOperand = Operand("check_event_var", {
	["eventVarCheck"] = "TRP3_API.script.eventVarCheck"
});

function checkEventVariableValueOperand:CodeReplacement(args)
	local var = getSafe(args, 1, 1);
	return ([[eventVarCheck(args, %s)]]):format(var);
end

local checkEventNumericVariableValueOperand = NumericOperand("check_event_var_n", {
	["eventVarCheckN"] = "TRP3_API.script.eventVarCheckN"
});

function checkEventNumericVariableValueOperand:CodeReplacement(args)
	local var = getSafe(args, 1, 1);
	return ([[eventVarCheckN(args, %s)]]):format(var);
end

local randomOperand = NumericOperand("random", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["random"] = "math.random",
	["tonumber"] = "tonumber"
});

function randomOperand:CodeReplacement(args)
	local from = getSafe(args, 1, 1);
	local to = getSafe(args, 2, 100)
	return ([[random(tonumber(parseArgs("%s", args)) or 1, tonumber(parseArgs("%s", args)) or 100)]]):format(from, to);
end
