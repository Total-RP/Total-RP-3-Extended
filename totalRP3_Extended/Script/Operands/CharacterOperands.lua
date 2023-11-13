-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

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
