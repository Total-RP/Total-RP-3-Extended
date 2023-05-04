-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

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
