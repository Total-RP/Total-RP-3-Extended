-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

---@type TRP3_API
local TRP3_API = TRP3_API;
local Ellyb = TRP3_API.Ellyb;


---@type TotalRP3_Extended_Operand[]
local OPERANDS= {}

---@param operand TotalRP3_Extended_Operand
function TRP3_API.script.registerOperand(operand)
	assert(Ellyb.Assertions.isInstanceOf(operand, TRP3_API.script.Operand, "operand"));
	assert(not OPERANDS[operand.id], "Already registered operand id: " .. operand.id);
	OPERANDS[operand.id] = operand;
end

function TRP3_API.script.getOperand(operandID)
	return OPERANDS[operandID];
end
