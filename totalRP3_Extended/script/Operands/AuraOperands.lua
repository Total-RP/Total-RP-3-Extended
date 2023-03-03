---@type TRP3_API
local TRP3_API = TRP3_API

---@type TotalRP3_Extended_Operand
local Operand = TRP3_API.script.Operand;
---@type TotalRP3_Extended_NumericOperand
local NumericOperand = TRP3_API.script.NumericOperand;
local getSafe = TRP3_API.getSafeValueFromTable;

local hasAuraOperand = Operand("aura_active", {
	["isAuraActive"] = "TRP3_API.extended.auras.isActive"
});
function hasAuraOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[isAuraActive("%s")]]):format(id);
end

local AuraDurationOperand = NumericOperand("aura_duration", {
	["getAuraDuration"] = "TRP3_API.extended.auras.getDuration"
});
function AuraDurationOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[getAuraDuration("%s")]]):format(id);
end

local checkAuraVariableValueOperand = Operand("aura_var_check", {
	["auraVarCheck"] = "TRP3_API.extended.auras.auraVarCheck"
});
function checkAuraVariableValueOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	local var = getSafe(args, 2, "");
	return ([[auraVarCheck("%s", "%s")]]):format(id, var);
end

local checkNumericAuraVariableValueOperand = NumericOperand("aura_var_check_n", {
	["auraVarCheckN"] = "TRP3_API.extended.auras.auraVarCheckN"
});
function checkNumericAuraVariableValueOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	local var = getSafe(args, 2, "");
	return ([[auraVarCheckN("%s", "%s")]]):format(id, var);
end