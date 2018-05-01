----------------------------------------------------------------------------------
-- Total RP 3: Extended features
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
----------------------------------------------------------------------------------

local Globals, Comm, Utils = TRP3_API.globals, TRP3_API.communication, TRP3_API.utils;
local loc = TRP3_API.loc;
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