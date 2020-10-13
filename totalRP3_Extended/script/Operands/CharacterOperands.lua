----------------------------------------------------------------------------------
--- Total RP 3
--- Scripts : Character Operands
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

local facingOperand = NumericOperand("char_facing", {
	["GetPlayerFacing"] = "GetPlayerFacing"
});

function facingOperand:CodeReplacement()
	return "GetPlayerFacing()";
end

local isFallingOperand = Operand("char_falling", {
	["IsFalling"] = "IsFalling"
});

function isFallingOperand:CodeReplacement()
	return "IsFalling()";
end

local isStealthedOperand = Operand("char_stealth", {
	["IsStealthed"] = "IsStealthed"
});

function isStealthedOperand:CodeReplacement()
	return "IsStealthed()";
end

local isFlyingOperand = Operand("char_flying", {
	["IsFlying"] = "IsFlying"
});

function isFlyingOperand:CodeReplacement()
	return "IsFlying()";
end

local isMountedOperand = Operand("char_mounted", {
	["IsMounted"] = "IsMounted"
});

function isMountedOperand:CodeReplacement()
	return "IsMounted()";
end

local isRestingOperand = Operand("char_resting", {
	["IsResting"] = "IsResting"
});

function isRestingOperand:CodeReplacement()
	return "IsResting()";
end

local isSwimmingOperand = Operand("char_swimming", {
	["IsSwimming"] = "IsSwimming"
});

function isSwimmingOperand:CodeReplacement()
	return "IsSwimming()";
end

local isIndoorsOperand = Operand("char_indoors", {
	["IsIndoors"] = "IsIndoors"
});

function isIndoorsOperand:CodeReplacement()
	return "IsIndoors()";
end

local zoneTextOperand = Operand("char_zone", {
	["GetZoneText"] = "GetZoneText"
});

function zoneTextOperand:CodeReplacement()
	return "GetZoneText()";
end

local subZoneTextOperand = Operand("char_subzone", {
	["GetSubZoneText"] = "GetSubZoneText"
});

function subZoneTextOperand:CodeReplacement()
	return "GetSubZoneText()";
end

local minimapZoneTextOperand = Operand("char_minimap", {
	["GetMinimapZoneText"] = "GetMinimapZoneText"
});

function minimapZoneTextOperand:CodeReplacement()
	return "GetMinimapZoneText()";
end

local cameraDistanceOperand = NumericOperand("char_cam_distance", {
	["GetCameraZoom"] = "GetCameraZoom"
});

function cameraDistanceOperand:CodeReplacement()
	return "GetCameraZoom()";
end

local achievementCompletedOperand = Operand("char_achievement", {
	["GetAchievementInfo"] = "GetAchievementInfo"
});

function achievementCompletedOperand:CodeReplacement(args)
	local completedBy = getSafe(args, 1, "account");
	local completedByIndex = completedBy == "account" and 4 or 13;
	local achievementId = getSafe(args, 2, "");
	return ("({GetAchievementInfo(%s)})[%s]"):format(achievementId, completedByIndex);
end
