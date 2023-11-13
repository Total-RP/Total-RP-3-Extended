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

local Tests = WoWUnit('TRP3:E Time Operands', "PLAYER_ENTERING_WORLD");

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
