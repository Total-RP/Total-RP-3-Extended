----------------------------------------------------------------------------------
--- Total RP 3
---
--- Operands Tests
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

--- Execute the operand in a safe environment, as close as how it would run in the addon
---@param operand TotalRP3_Extended_Operand
local function execute(operand, args)
	local generatedCode = operand:CodeReplacement(args)
	local factory = ([[
return function(args)
return %s
end]]):format(generatedCode)
	for k, v in pairs(operand.env) do
		factory = ([[local %s = %s]]):format(k, v) .. "\n"..factory
	end
	local func = loadstring(factory)()
	setfenv(func, {})
	return func(args)
end
TRP3_API.extended.executeOperandInSafeEnv = execute

local operandsToTest = {
	"unit_name",
	"unit_id",
	"unit_npc_id",
	"unit_guild",
	"unit_guild_rank",
	"unit_class",
	"unit_race",
	"unit_sex",
	"unit_faction",
	"unit_classification",
	"unit_health",
	"unit_level",
	"unit_speed",
	"unit_position_x",
	"unit_position_y",
	"unit_exists",
	"unit_is_player",
	"unit_is_dead",
	"unit_distance_trade",
	"unit_distance_inspect",
	"unit_distance_point",
	"unit_distance_me",
	"char_facing",
	"char_falling",
	"char_stealth",
	"char_flying",
	"char_mounted",
	"char_resting",
	"char_swimming",
	"char_zone",
	"char_subzone",
	"char_minimap",
	"char_cam_distance",
	"char_achievement",
	"inv_item_count",
	"inv_item_weight",
	"quest_is_step",
	"quest_obj",
	"quest_obj_current",
	"quest_obj_all",
	"quest_is_npc",
	"var_check",
	"var_check_n",
	"check_event_var",
	"check_event_var_n",
	"random",
	"time_hour",
	"time_minute",
};

---@param closure fun(operand: TotalRP3_Extended_Operand)
local function forEachOperand(closure)
	for _, operandId in ipairs(operandsToTest) do
		closure(TRP3_API.script.getOperand(operandId));
	end
end

local OperandTests = WoWUnit('TRP3:E Operands', "PLAYER_ENTERING_WORLD")

function OperandTests:HandleNilArgs()
	forEachOperand(function(operand)
		WoWUnit.Exists(operand)
		local _, error = loadstring("function test() result = " .. operand:CodeReplacement(nil) .. " end")
		WoWUnit.IsFalse(error)
	end)
end

function OperandTests:HandleEmptyTableArgs()
	forEachOperand(function(operand)
		WoWUnit.Exists(operand)
		local _, error = loadstring("function test() result = " .. operand:CodeReplacement({}) .. " end")
		WoWUnit.IsFalse(error)
	end)
end

function OperandTests:HandleNumericArgs()
	forEachOperand(function(operand)
		WoWUnit.Exists(operand)
		local _, error = loadstring("function test() result = " .. operand:CodeReplacement(4) .. " end")
		WoWUnit.IsFalse(error)
	end)
end

function OperandTests:HandleEmptyStringArgs()
	forEachOperand(function(operand)
		WoWUnit.Exists(operand)
		local _, error = loadstring("function test() result = " .. operand:CodeReplacement("") .. " end")
		WoWUnit.IsFalse(error)
	end)
end


WoWUnit:Show()
