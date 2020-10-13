----------------------------------------------------------------------------------
--- Total RP 3
---
--- Inventory Operands Tests
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

local Tests = WoWUnit('TRP3:E Inventory Operands', "PLAYER_ENTERING_WORLD");

function Tests:ItemCount()
	local operand = getOperand("inv_item_count");

	--region Parent check
	WoWUnit.Replace(TRP3_API.inventory, 'getItemCount', function(id, source, ...)
		WoWUnit.AreEqual("36", id)
		WoWUnit.AreEqual("CONTAINER", source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { 36, "parent", container = "CONTAINER" }))
	--endregion

	--region Self check
	WoWUnit.Replace(TRP3_API.inventory, 'getItemCount', function(id, source)
		WoWUnit.AreEqual("36", id)
		WoWUnit.AreEqual("OBJECT", source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { 36, "self", object = "OBJECT" }))
	--endregion

	--region Nil check
	WoWUnit.Replace(TRP3_API.inventory, 'getItemCount', function(id, source)
		WoWUnit.AreEqual("36", id)
		WoWUnit.AreEqual(nil, source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { 36, nil }))
	--endregion
end

function Tests:ItemWeight()
	local operand = getOperand("inv_item_weight");

	--region Parent check
	WoWUnit.Replace(TRP3_API.inventory, 'getContainerWeight', function(source)
		WoWUnit.AreEqual("CONTAINER", source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { "parent", container = "CONTAINER" }))
	--endregion

	--region Self check
	WoWUnit.Replace(TRP3_API.inventory, 'getContainerWeight', function(source)
		WoWUnit.AreEqual("OBJECT", source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { "self", object = "OBJECT" }))
	--endregion

	--region Nil check
	WoWUnit.Replace(TRP3_API.inventory, 'getContainerWeight', function(source)
		WoWUnit.AreEqual(nil, source)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { nil }))
	--endregion
end
