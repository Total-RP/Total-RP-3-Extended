----------------------------------------------------------------------------------
--- Total RP 3
---
--- Character Operands Tests
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

---@type fun(id: string):TotalRP3_Extended_Operand
local getOperand = TRP3_API.script.getOperand;
local execute = TRP3_API.extended.executeOperandInSafeEnv;

local Tests = WoWUnit('TRP3:E Character Operands', "PLAYER_ENTERING_WORLD");

function Tests:Facing()
	WoWUnit.Replace('GetPlayerFacing', function()
		return 42
	end)
	local operand = getOperand("char_facing");
	WoWUnit.AreEqual(42, execute(operand, {}))
end

function Tests:IsFalling()
	WoWUnit.Replace('IsFalling', function()
		return true
	end)
	local operand = getOperand("char_falling");
	WoWUnit.IsTrue(execute(operand, {}))
end

function Tests:IsStealthed()
	WoWUnit.Replace('IsStealthed', function()
		return true
	end)
	local operand = getOperand("char_stealth");
	WoWUnit.IsTrue(execute(operand, {}))
end

function Tests:IsFlying()
	WoWUnit.Replace('IsFlying', function()
		return true
	end)
	local operand = getOperand("char_flying");
	WoWUnit.IsTrue(execute(operand, {}))
end

function Tests:IsMounted()
	WoWUnit.Replace('IsMounted', function()
		return true
	end)
	local operand = getOperand("char_mounted");
	WoWUnit.IsTrue(execute(operand, {}))
end

function Tests:IsResting()
	WoWUnit.Replace('IsResting', function()
		return true
	end)
	local operand = getOperand("char_resting");
	WoWUnit.IsTrue(execute(operand, {}))
end

function Tests:IsMounted()
	WoWUnit.Replace('IsSwimming', function()
		return true
	end)
	local operand = getOperand("char_swimming");
	WoWUnit.IsTrue(execute(operand, {}))
end

function Tests:Zone()
	WoWUnit.Replace('GetZoneText', function()
		return "Dalaran"
	end)
	local operand = getOperand("char_zone");
	WoWUnit.AreEqual("Dalaran", execute(operand, {}))
end

function Tests:SubZone()
	WoWUnit.Replace('GetSubZoneText', function()
		return "Dalaran"
	end)
	local operand = getOperand("char_subzone");
	WoWUnit.AreEqual("Dalaran", execute(operand, {}))
end

function Tests:MinimapZone()
	WoWUnit.Replace('GetMinimapZoneText', function()
		return "Dalaran"
	end)
	local operand = getOperand("char_minimap");
	WoWUnit.AreEqual("Dalaran", execute(operand, {}))
end

function Tests:CameraDistance()
	WoWUnit.Replace('GetCameraZoom', function()
		return 0.5
	end)
	local operand = getOperand("char_cam_distance");
	WoWUnit.AreEqual(0.5, execute(operand, {}))
end

function Tests:MinimapZone()
	local operand = getOperand("char_achievement");

	--region Account achievement test
	WoWUnit.Replace('GetAchievementInfo', function(achievementId, completedByFlag)
		WoWUnit.AreEqual(achievementId, 42)
		local returnValues = {}
		for i = 1, 14 do
			returnValues[i] = i == 4 -- The 4th argument indicates if the account got the achievement
		end
		return unpack(returnValues)
	end)
	WoWUnit.IsTrue(execute(operand, {"account", 42}))
	--endregion

	--region Character achievement test
	WoWUnit.Replace('GetAchievementInfo', function(achievementId)
		WoWUnit.AreEqual(achievementId, 56)
		local returnValues = {}
		for i = 1, 14 do
			returnValues[i] = i == 13 -- The 13th argument indicates if the current character got the achievement
		end
		return unpack(returnValues)
	end)
	WoWUnit.IsTrue(execute(operand, {"character", 56}))
	--endregion
end
