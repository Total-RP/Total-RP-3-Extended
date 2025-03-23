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

local Tests = WoWUnit('TRP3:E Unit Operands', "PLAYER_ENTERING_WORLD");

function Tests:UnitName()
	WoWUnit.Replace('UnitName', function(arg)
		WoWUnit.AreEqual("player", arg)
		return 'Ellypse'
	end)
	local operand = getOperand("unit_name");
	WoWUnit.AreEqual("Ellypse", execute(operand, { "player" }))
end

function Tests:UnitID()
	WoWUnit.Replace(TRP3_API.utils.str, "getUnitID", function(arg)
		WoWUnit.AreEqual("player", arg)
		return "Ellypse-KirinTor"
	end)
	local operand = getOperand("unit_id");
	WoWUnit.AreEqual("Ellypse-KirinTor", execute(operand, { "player" }))
end

function Tests:UnitClass()
	WoWUnit.Replace(TRP3_UnitOperandFunctions, "GetClass", function(arg)
		WoWUnit.AreEqual("player", arg)
		return "PRIEST"
	end)
	local operand = getOperand("unit_class");
	WoWUnit.AreEqual("priest", execute(operand, { "player" }))
end

function Tests:UnitRace()
	WoWUnit.Replace(TRP3_UnitOperandFunctions, "GetRace", function(arg)
		WoWUnit.AreEqual("player", arg)
		return "HIGHELF"
	end)
	local operand = getOperand("unit_race");
	WoWUnit.AreEqual("highelf", execute(operand, { "player" }))
end

function Tests:UnitGuild()
	WoWUnit.Replace(TRP3_UnitOperandFunctions, "GetGuildName", function(arg)
		WoWUnit.AreEqual("player", arg)
		return "Sons of Anarchy"
	end)
	local operand = getOperand("unit_guild");
	WoWUnit.AreEqual("Sons of Anarchy", execute(operand, { "player" }))
end

function Tests:UnitGuildRank()
	WoWUnit.Replace(TRP3_UnitOperandFunctions, "GetGuildRank", function(arg)
		WoWUnit.AreEqual("player", arg)
		return "Traitor"
	end)
	local operand = getOperand("unit_guild_rank");
	WoWUnit.AreEqual("Traitor", execute(operand, { "player" }));
end

function Tests:UnitNpcId()
	WoWUnit.Replace(TRP3_API.utils.str, "getUnitNPCID", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return "42"
	end)
	local operand = getOperand(("unit_npc_id"));
	WoWUnit.AreEqual("42", execute(operand, { "focus" }));
end

function Tests:UnitSex()
	WoWUnit.Replace("UnitSex", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return 2
	end)
	local operand = getOperand(("unit_sex"));
	WoWUnit.AreEqual(2, execute(operand, { "focus" }));
end

function Tests:UnitFaction()
	WoWUnit.Replace(TRP3_UnitOperandFunctions, "GetFaction", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return "Alliance"
	end)
	local operand = getOperand(("unit_faction"));
	WoWUnit.AreEqual("alliance", execute(operand, { "focus" }));
end

function Tests:UnitClassification()
	WoWUnit.Replace("UnitClassification", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return "worldboss"
	end)
	local operand = getOperand(("unit_classification"));
	WoWUnit.AreEqual("worldboss", execute(operand, { "focus" }));
end

function Tests:UnitHealth()
	WoWUnit.Replace("UnitHealth", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return 42
	end)
	local operand = getOperand(("unit_health"));
	WoWUnit.AreEqual(42, execute(operand, { "focus" }));
end

function Tests:UnitLevel()
	WoWUnit.Replace("UnitLevel", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return 42
	end)
	local operand = getOperand(("unit_level"));
	WoWUnit.AreEqual(42, execute(operand, { "focus" }));
end

function Tests:UnitSpeed()
	WoWUnit.Replace("GetUnitSpeed", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return 42
	end)
	local operand = getOperand(("unit_speed"));
	WoWUnit.AreEqual(42, execute(operand, { "focus" }));
end

function Tests:UnitPositionX()
	WoWUnit.Replace("UnitPosition", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return 24, 42, 36, 37
	end)
	local operand = getOperand(("unit_position_x"));
	WoWUnit.AreEqual(42, execute(operand, { "focus" }));
end

function Tests:UnitPositionY()
	WoWUnit.Replace("UnitPosition", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return 24, 42, 36, 37
	end)
	local operand = getOperand(("unit_position_y"));
	WoWUnit.AreEqual(24, execute(operand, { "focus" }));
end

function Tests:UnitExists()
	WoWUnit.Replace("UnitExists", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return true
	end)
	local operand = getOperand(("unit_exists"));
	WoWUnit.IsTrue(execute(operand, { "focus" }));
end

function Tests:UnitIsPlayer()
	WoWUnit.Replace("UnitIsPlayer", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return true
	end)
	local operand = getOperand(("unit_is_player"));
	WoWUnit.IsTrue(execute(operand, { "focus" }));
end

function Tests:UnitIsDead()
	WoWUnit.Replace("UnitIsDeadOrGhost", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return true
	end)
	local operand = getOperand(("unit_is_dead"));
	WoWUnit.IsTrue(execute(operand, { "focus" }));
end

function Tests:UnitIsInTradingDistance()
	WoWUnit.Replace("CheckInteractDistance", function(arg, distanceFlag)
		WoWUnit.AreEqual("focus", arg)
		WoWUnit.AreEqual(2, distanceFlag)
		return true
	end)
	local operand = getOperand(("unit_distance_trade"));
	WoWUnit.IsTrue(execute(operand, { "focus" }));
end

function Tests:UnitIsInInspectDistance()
	WoWUnit.Replace("CheckInteractDistance", function(arg, distanceFlag)
		WoWUnit.AreEqual("focus", arg)
		WoWUnit.AreEqual(1, distanceFlag)
		return true
	end)
	local operand = getOperand(("unit_distance_inspect"));
	WoWUnit.IsTrue(execute(operand, { "focus" }));
end

function Tests:UnitDistanceToPoint()
	WoWUnit.Replace(TRP3_API.extended, "unitDistancePoint", function(arg, x, y)
		WoWUnit.AreEqual("focus", arg)
		WoWUnit.AreEqual(42, x)
		WoWUnit.AreEqual(24, y)
		return true
	end)
	local operand = getOperand(("unit_distance_point"));
	WoWUnit.IsTrue(execute(operand, { "focus", 24, 42 }));
end

function Tests:UnitDistanceToPoint()
	WoWUnit.Replace(TRP3_API.extended, "unitDistanceMe", function(arg)
		WoWUnit.AreEqual("focus", arg)
		return true
	end)
	local operand = getOperand(("unit_distance_me"));
	WoWUnit.IsTrue(execute(operand, { "focus" }));
end
