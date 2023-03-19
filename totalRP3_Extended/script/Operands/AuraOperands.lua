---@type TotalRP3_Extended_Operand
local Operand = TRP3_API.script.Operand;
---@type TotalRP3_Extended_NumericOperand
local NumericOperand = TRP3_API.script.NumericOperand;
local getSafe = TRP3_API.getSafeValueFromTable;

local hasAuraOperand = Operand("aura_active", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["isAuraActive"] = "TRP3_API.extended.auras.isActive"
});
function hasAuraOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[isAuraActive(parseArgs("%s", args))]]):format(id);
end

local AuraCountOperand = NumericOperand("aura_count", {
	["getAuraCount"] = "TRP3_API.extended.auras.getCount"
});
function AuraCountOperand:CodeReplacement(args)
	return [[getAuraCount()]];
end

local AuraDurationOperand = NumericOperand("aura_duration", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["getAuraDuration"] = "TRP3_API.extended.auras.getDuration"
});
function AuraDurationOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[getAuraDuration(parseArgs("%s", args))]]):format(id);
end

local AuraHelpfulOperand = Operand("aura_helpful", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["isAuraHelpful"] = "TRP3_API.extended.auras.isHelpful"
});
function AuraHelpfulOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[isAuraHelpful(parseArgs("%s", args))]]):format(id);
end

local AuraCancellableOperand = Operand("aura_cancellable", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["isAuraCancellable"] = "TRP3_API.extended.auras.isCancellable"
});
function AuraCancellableOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[isAuraCancellable(parseArgs("%s", args))]]):format(id);
end

local AuraNameOperand = Operand("aura_name", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["getAuraStringProperty"] = "TRP3_API.extended.auras.getStringProperty"
});
function AuraNameOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[getAuraStringProperty(parseArgs("%s", args), "NA")]]):format(id);
end

local AuraIconOperand = Operand("aura_icon", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["getAuraStringProperty"] = "TRP3_API.extended.auras.getStringProperty"
});
function AuraIconOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[getAuraStringProperty(parseArgs("%s", args), "IC")]]):format(id);
end

local AuraColorOperand = Operand("aura_color", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["getAuraStringProperty"] = "TRP3_API.extended.auras.getStringProperty"
});
function AuraColorOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[getAuraStringProperty(parseArgs("%s", args), "CO")]]):format(id);
end

local checkAuraVariableValueOperand = Operand("aura_var_check", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["auraVarCheck"] = "TRP3_API.extended.auras.auraVarCheck"
});
function checkAuraVariableValueOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	local var = getSafe(args, 2, "");
	return ([[auraVarCheck(parseArgs("%s", args), "%s")]]):format(id, var);
end

local checkNumericAuraVariableValueOperand = NumericOperand("aura_var_check_n", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["auraVarCheckN"] = "TRP3_API.extended.auras.auraVarCheckN"
});
function checkNumericAuraVariableValueOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	local var = getSafe(args, 2, "");
	return ([[auraVarCheckN(parseArgs("%s", args), "%s")]]):format(id, var);
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
