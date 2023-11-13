-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local UnitPosition = UnitPosition;
local sqrt, pow = math.sqrt, math.pow;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Distances
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getUnitPositionSafe(unit)
	local uY, uX, uZ, instanceID = UnitPosition(unit);	-- It's not a typo.
	return uY or 0, uX or 0, uZ or 0, instanceID or "0";
end
TRP3_API.extended.getUnitPositionSafe = getUnitPositionSafe;

function TRP3_API.extended.unitDistancePoint(unit, x, y)
	local uY, uX = getUnitPositionSafe(unit);
	return sqrt(pow(x - uX, 2) + pow(y - uY, 2));
end

function TRP3_API.extended.unitDistanceMe(unit)
	if not UnitExists(unit) then return 0; end
	local uY, uX = getUnitPositionSafe(unit);
	local mY, mX = getUnitPositionSafe("player");
	return sqrt(pow(mX - uX, 2) + pow(mY - uY, 2));
end
