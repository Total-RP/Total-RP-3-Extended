----------------------------------------------------------------------------------
--- Total RP 3
--- Operands Tests
---	---------------------------------------------------------------------------
--- Copyright 2019 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
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

--[[
	These tests will check that all operands can properly handle all kind of arguments passed to the code generation,
	including nil, an empty table, empty string or a numeric value

	/run __TRP3ExtendedTests__operands()
]]

---@type TRP3_API
local TRP3_API = TRP3_API;

local checkMark = TRP3_API.Ellyb.Texture.CreateFromAtlas("orderhalltalents-done-checkmark")
checkMark:SetWidth(15)
local TEST_PASSED = "Operand test %s passed " .. tostring(checkMark)

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

function __TRP3ExtendedTests__operands()
	for _, operandId in ipairs(operandsToTest) do
		local operand = TRP3_API.script.getOperand(operandId);
		if not operand then
			error(("Could not get operand %s"):format(operandId))
		end

		loadstring(operand:CodeReplacement(nil))
		loadstring(operand:CodeReplacement(""))
		loadstring(operand:CodeReplacement({}))
		loadstring(operand:CodeReplacement(0))
		loadstring(operand:CodeReplacement(true))

		print(TRP3_API.Ellyb.ColorManager.GREEN((TEST_PASSED):format(operandId)))
	end
end
