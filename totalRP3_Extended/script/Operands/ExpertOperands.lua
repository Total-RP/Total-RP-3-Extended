----------------------------------------------------------------------------------
--- Total RP 3
--- Scripts : Expert Operands
---	---------------------------------------------------------------------------
--- Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
--- Copyright 2019 Morgane "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---
--- Licensed under the Apache License, Version 2.0 (the "License");
--- you may not use this file except in compliance with the License.
--- You may obtain a copy of the License at
---
---  http://www.apache.org/licenses/LICENSE-2.0
---
--- Unless required by applicable law or agreed to in writing, software
--- distributed under the License is distributed on an "AS IS" BASIS,
--- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--- See the License for the specific language governing permissions and
--- limitations under the License.
----------------------------------------------------------------------------------

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
	["random"] = "math.random"
});

function randomOperand:CodeReplacement(args)
	local from = getSafe(args, 1, 1);
	local to = getSafe(args, 2, 100)
	return ("random(%s, %s)"):format(from, to);
end
