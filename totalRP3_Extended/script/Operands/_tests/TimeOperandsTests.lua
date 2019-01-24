----------------------------------------------------------------------------------
--- Total RP 3
---
--- Time Operands Tests
---	---------------------------------------------------------------------------
--- Copyright 2019 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
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

local Tests = WoWUnit('TRP3:E Time Operands', "PLAYER_ENTERING_WORLD");

--- Execute the operand in a safe environment, as close as how it would run in the addon
---@param operand TotalRP3_Extended_Operand
local function execute(operand, args)
	local generatedCode = operand:CodeReplacement(args)
	local factory = ([[
return function()
return %s
end]]):format(generatedCode)
	for k, v in pairs(operand.env) do
		factory = ([[local %s = %s]]):format(k, v) .. "\n"..factory
	end
	local func = loadstring(factory)()
	setfenv(func, {})
	return func()
end

function Tests:Time()
	WoWUnit.Replace('GetGameTime', function()
		return 09, 41
	end)
	local operand = getOperand("time_hour");
	WoWUnit.AreEqual(9, execute(operand, {}))
end

function Tests:Minute()
	WoWUnit.Replace('GetGameTime', function()
		return 09, 41
	end)
	local operand = getOperand("time_minute");
	WoWUnit.AreEqual(41, execute(operand, {}))
end
