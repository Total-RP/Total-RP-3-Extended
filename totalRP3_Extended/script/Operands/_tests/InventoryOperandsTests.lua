----------------------------------------------------------------------------------
--- Total RP 3
---
--- Inventory Operands Tests
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

local Tests = WoWUnit('TRP3:E Inventory Operands', "PLAYER_ENTERING_WORLD");

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

function Tests:ItemCount()
	local operand = getOperand("inv_item_count");

	--region Parent check
	WoWUnit.Replace(TRP3_API.inventory, 'getItemCount', function(id, source)
		WoWUnit.AreEqual(36, id)
		WoWUnit.AreEqual("args.container", source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { 36, "parent" }))
	--endregion

	--region Parent check
	WoWUnit.Replace(TRP3_API.inventory, 'getItemCount', function(id, source)
		WoWUnit.AreEqual(36, id)
		WoWUnit.AreEqual("args.object", source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { 36, "self" }))
	--endregion

	--region Nil check
	WoWUnit.Replace(TRP3_API.inventory, 'getItemCount', function(id, source)
		WoWUnit.AreEqual(36, id)
		WoWUnit.AreEqual("nil", source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { 36, nil }))
	--endregion
end

function Test:ItemWeight()
	local operand = getOperand("inv_item_weight");

	--region Parent check
	WoWUnit.Replace(TRP3_API.inventory, 'getItemCount', function(source)
		WoWUnit.AreEqual("args.container", source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { "parent" }))
	--endregion

	--region Parent check
	WoWUnit.Replace(TRP3_API.inventory, 'getItemCount', function(source)
		WoWUnit.AreEqual("args.object", source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { "self" }))
	--endregion

	--region Nil check
	WoWUnit.Replace(TRP3_API.inventory, 'getItemCount', function(source)
		WoWUnit.AreEqual("nil", source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { nil }))
	--endregion
end
