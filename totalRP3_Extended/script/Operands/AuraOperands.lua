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

local AuraCountOperand = NumericOperand("aura_count", {
	["getAuraCount"] = "TRP3_API.extended.auras.getCount"
});
function AuraCountOperand:CodeReplacement(args)
	return [[getAuraCount()]];
end

local AuraDurationOperand = NumericOperand("aura_duration", {
	["getAuraDuration"] = "TRP3_API.extended.auras.getDuration"
});
function AuraDurationOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[getAuraDuration("%s")]]):format(id);
end

local AuraHelpfulOperand = Operand("aura_helpful", {
	["isAuraHelpful"] = "TRP3_API.extended.auras.isHelpful"
});
function AuraHelpfulOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[isAuraHelpful("%s")]]):format(id);
end

local AuraCancellableOperand = Operand("aura_cancellable", {
	["isAuraCancellable"] = "TRP3_API.extended.auras.isCancellable"
});
function AuraCancellableOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[isAuraCancellable("%s")]]):format(id);
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

local AuraIdOperand = Operand("aura_id", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["getAuraId"] = "TRP3_API.extended.auras.getId",
	["tonumber"] = "tonumber"
});
function AuraIdOperand:CodeReplacement(args)
	local index = getSafe(args, 1, "");
	return ([[getAuraId(tonumber(parseArgs("%s", args)))]]):format(index);
end
