----------------------------------------------------------------------------------
--- Total RP 3
--- Scripts : Unit Operands
---	---------------------------------------------------------------------------
--- Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
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

---@type TRP3_API
local TRP3_API = TRP3_API

---@type TotalRP3_Extended_Operand
local Operand = TRP3_API.script.Operand;
---@type TotalRP3_Extended_NumericOperand
local NumericOperand = TRP3_API.script.NumericOperand;
local getSafe = TRP3_API.getSafeValueFromTable;

local function getUnitId(args)
	return getSafe(args, 1, "target");
end

--region String operands

local unitNameOperand = Operand("unit_name", {
	["UnitName"] = "UnitName"
});

function unitNameOperand:CodeReplacement(args)
	return ([[UnitName("%s")]]):format(getUnitId(args))
end

local unitIdOperand = Operand("unit_id", {
	["UnitID"] = "TRP3_API.utils.str.getUnitID"
})

function unitIdOperand:CodeReplacement(args)
	return ([[UnitID("%s")]]):format(getUnitId(args))
end

local unitNpcIdOperand = Operand("unit_npc_id", {
	["getUnitNPCID"] = "TRP3_API.utils.str.getUnitNPCID",
});

function unitNpcIdOperand:CodeReplacement(args)
	return ([[getUnitNPCID("%s")]]):format(getUnitId(args));
end

local unitGuildOperand = Operand("unit_guild", {
	["GetGuildName"] = "TRP3_API.utils.str.GetGuildName",
})

function unitGuildOperand:CodeReplacement(args)
	return ([[GetGuildName("%s")]]):format(getUnitId(args));
end

local unitGuildRankOperand = Operand("unit_guild_rank", {
	["GetGuildRank"] = "TRP3_API.utils.str.GetGuildRank"
});

function unitGuildRankOperand:CodeReplacement(args)
	return ([[GetGuildRank("%s")]]):format(getUnitId(args));
end

local unitClassOperand = Operand("unit_class", {
	["GetClass"] = "TRP3_API.utils.str.GetClass"
});

function unitClassOperand:CodeReplacement(args)
	return ([[(GetClass("%s") or ""):lower()]]):format(getUnitId(args));
end

local unitRaceOperand = Operand("unit_race", {
	["GetRace"] = "TRP3_API.utils.str.GetRace"
});

function unitRaceOperand:CodeReplacement(args)
	return ([[(GetRace("%s") or ""):lower()]]):format(getUnitId(args));
end

local unitSexOperand = Operand("unit_sex", {
	["UnitSex"] = "UnitSex"
});

function unitSexOperand:CodeReplacement(args)
	return ([[(UnitSex("%s") or 1)]]):format(getUnitId(args));
end

local unitFactionOperand = Operand("unit_faction", {
	["GetFaction"] = "TRP3_API.utils.str.GetFaction"
});

function unitFactionOperand:CodeReplacement(args)
	return ([[(GetFaction("%s") or ""):lower()]]):format(getUnitId(args));
end

local unitCreatureTypeOperand = Operand("unit_creature_type", {
	["UnitCreatureType"] = "UnitCreatureType"
})

function unitCreatureTypeOperand:CodeReplacement(args)
	return ([[UnitCreatureType("%s")]]):format(getUnitId(args));
end

local unitCreatureFamilyOperand = Operand("unit_creature_family", {
	["UnitCreatureFamily"] = "UnitCreatureFamily"
})

function unitCreatureFamilyOperand:CodeReplacement(args)
	return ([[UnitCreatureFamily("%s")]]):format(getUnitId(args));
end

local unitClassificationOperand = Operand("unit_classification", {
	["UnitClassification"] = "UnitClassification"
})

function unitClassificationOperand:CodeReplacement(args)
	return ([[UnitClassification("%s")]]):format(getUnitId(args));
end

--endregion

--region Numeric operands

local unitHealthOperand = NumericOperand("unit_health", {
	["UnitHealth"] = "UnitHealth"
});

function unitHealthOperand:CodeReplacement(args)
	return ([[UnitHealth("%s")]]):format(getUnitId(args));
end

local unitLevelOperand = NumericOperand("unit_level", {
	["UnitLevel"] = "UnitLevel"
});

function unitLevelOperand:CodeReplacement(args)
	return ([[UnitLevel("%s")]]):format(getUnitId(args));
end

local unitSpeedOperand = NumericOperand("unit_speed", {
	["GetUnitSpeed"] = "GetUnitSpeed"
});

function unitSpeedOperand:CodeReplacement(args)
	return ([[GetUnitSpeed("%s")]]):format(getUnitId(args));
end

local unitPositionXOperand = NumericOperand("unit_position_x", {
	["UnitPosition"] = "UnitPosition"
});

function unitPositionXOperand:CodeReplacement(args)
	return ("({UnitPosition(\"%s\")})[2]"):format(getUnitId(args));
end

local unitPositionYOperand = NumericOperand("unit_position_y", {
	["UnitPosition"] = "UnitPosition"
});

function unitPositionYOperand:CodeReplacement(args)
	return ("({UnitPosition(\"%s\")})[1]"):format(getUnitId(args));
end

--endregion

--region Unit checks

local unitExistsOperand = Operand("unit_exists", {
	["UnitExists"] = "UnitExists"
});

function unitExistsOperand:CodeReplacement(args)
	return ([[UnitExists("%s")]]):format(getUnitId(args));
end

local unitIsPlayerOperand = Operand("unit_is_player", {
	["UnitIsPlayer"] = "UnitIsPlayer"
});

function unitIsPlayerOperand:CodeReplacement(args)
	return ([[UnitIsPlayer("%s")]]):format(getUnitId(args));
end

local unitIsDeadOperand = Operand("unit_is_dead", {
	["UnitIsDeadOrGhost"] = "UnitIsDeadOrGhost"
});

function unitIsDeadOperand:CodeReplacement(args)
	return ([[UnitIsDeadOrGhost("%s")]]):format(getUnitId(args));
end

local unitIsInTradingDistanceOperand = Operand("unit_distance_trade", {
	["CheckInteractDistance"] = "CheckInteractDistance"
});

function unitIsInTradingDistanceOperand:CodeReplacement(args)
	return ([[CheckInteractDistance("%s", 2)]]):format(getUnitId(args));
end

local unitIsInInspectingDistanceOperand = Operand("unit_distance_inspect", {
	["CheckInteractDistance"] = "CheckInteractDistance"
});

function unitIsInInspectingDistanceOperand:CodeReplacement(args)
	return ([[CheckInteractDistance("%s", 1)]]):format(getUnitId(args));
end

local unitDistanceToPointOperand = NumericOperand("unit_distance_point", {
	["unitDistancePoint"] = "TRP3_API.extended.unitDistancePoint"
});

function unitDistanceToPointOperand:CodeReplacement(args)
	local x = getSafe(args, 3, 0)
	local y = getSafe(args, 2, 0)
	return ([[unitDistancePoint("%s", %s, %s)]]):format(getUnitId(args), x, y);
end

local unitDistanceFromPlayerOperand = NumericOperand("unit_distance_me", {
	["unitDistanceMe"] = "TRP3_API.extended.unitDistanceMe"
});

function unitDistanceFromPlayerOperand:CodeReplacement(args)
	return ([[unitDistanceMe("%s")]]):format(getUnitId(args));
end
