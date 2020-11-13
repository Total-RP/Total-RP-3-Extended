----------------------------------------------------------------------------------
--- Total RP 3
---
--- Expert Operands Tests
---	---------------------------------------------------------------------------
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


if not WoWUnit then
	return
end

---@type TRP3_API
local TRP3_API = TRP3_API;

---@type fun(id: string):TotalRP3_Extended_Operand
local getOperand = TRP3_API.script.getOperand;
local execute = TRP3_API.extended.executeOperandInSafeEnv;

local Tests = WoWUnit('TRP3:E Expert Operands', "PLAYER_ENTERING_WORLD");

function Tests:CheckVar()
	WoWUnit.Replace(TRP3_API.script, 'varCheck', function(args, source, var)
		WoWUnit.AreEqual({ "o", "myVar", object = { 1 }}, args)
		WoWUnit.AreEqual("o", source)
		WoWUnit.AreEqual("myVar", var)
		return "42"
	end)
	local operand = getOperand("var_check");
	WoWUnit.AreEqual("42", execute(operand, { "o", "myVar", object = { 1 }}))
end

function Tests:CheckVarN()
	WoWUnit.Replace(TRP3_API.script, 'varCheckN', function(args, source, var)
		WoWUnit.AreEqual({ "o", "myVar", object = { 1 }}, args)
		WoWUnit.AreEqual("o", source)
		WoWUnit.AreEqual("myVar", var)
		return 42
	end)
	local operand = getOperand("var_check_n");
	WoWUnit.AreEqual(42, execute(operand, { "o", "myVar", object = { 1 }}))
end

function Tests:CheckEventVar()
	WoWUnit.Replace(TRP3_API.script, 'eventVarCheck', function(args, index)
		WoWUnit.AreEqual({ 1 }, args)
		WoWUnit.AreEqual(1, index)
		return "42"
	end)
	local operand = getOperand("check_event_var");
	WoWUnit.AreEqual("42", execute(operand, { 1 }))
end

function Tests:CheckEventVarN()
	WoWUnit.Replace(TRP3_API.script, 'eventVarCheckN', function(args, index)
		WoWUnit.AreEqual({ 1 }, args)
		WoWUnit.AreEqual(1, index)
		return 42
	end)
	local operand = getOperand("check_event_var_n");
	WoWUnit.AreEqual(42, execute(operand, { 1 }))
end

function Tests:Random()
	WoWUnit.Replace(math, 'random', function(from, to)
		WoWUnit.AreEqual(5, from)
		WoWUnit.AreEqual(10, to)
		return 42
	end)
	local operand = getOperand("random");
	WoWUnit.AreEqual(42, execute(operand, { 5, 10 }))
end

