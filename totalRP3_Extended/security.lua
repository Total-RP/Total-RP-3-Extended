----------------------------------------------------------------------------------
-- Total RP 3
--	---------------------------------------------------------------------------
--	Copyright 2016 Sylvain Cossement (telkostrasz@totalrp3.info)
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

local assert, pairs = assert, pairs;
local iterateObject = TRP3_API.extended.iterateObject;
local loc = TRP3_API.locale.getText;
local ELEMENT_TYPE = TRP3_DB.elementTypes;
local EMPTY = TRP3_API.globals.empty;

TRP3_API.security = {};

local SECURITY_LEVEL = {
	LOW = 1,
	MEDIUM = 2,
	HIGH = 3,
};
TRP3_API.security.SECURITY_LEVEL = SECURITY_LEVEL;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LOGIC
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getEffectSecurity(effectID)
	local effect = TRP3_API.script.getEffect(effectID);
	if effect then
		return effect.secured or SECURITY_LEVEL.LOW;
	end
	return SECURITY_LEVEL.LOW;
end
TRP3_API.security.getEffectSecurity = getEffectSecurity;

local function computeSecurity(rootObjectID, rootObject)
	assert(rootObject, "Nil argument");
	assert(rootObject.TY, "Object has no type.");
	assert(rootObject.TY == TRP3_DB.types.ITEM or rootObject.TY == TRP3_DB.types.CAMPAIGN, "Object is not an item or a campaign.");

	local minSecurity = SECURITY_LEVEL.HIGH;
	iterateObject(rootObjectID, rootObject, function(childID, childClass)
		for workflowID, workflow in pairs(childClass.SC or EMPTY) do
			for stepID, step in pairs(workflow.ST or EMPTY) do
				if step.t == ELEMENT_TYPE.EFFECT then
					for effectIndex, effect in pairs(step.e or EMPTY) do
						local effectID = effect.id;
						local securityLevel = getEffectSecurity(effectID);
						minSecurity = math.min(minSecurity, securityLevel);
					end
				end
			end
		end
	end);

	rootObject.securityLevel = minSecurity;
end
TRP3_API.security.computeSecurity = computeSecurity;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local securityLevelText, securityLevelDetailText = {}, {};

local function getSecurityText(level)
	return securityLevelText[level or SECURITY_LEVEL.LOW] or "?";
end
TRP3_API.security.getSecurityText = getSecurityText;

local function getSecurityDetailText(level)
	return securityLevelDetailText[level or SECURITY_LEVEL.LOW] or "?";
end
TRP3_API.security.getSecurityDetailText = getSecurityDetailText;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.inventory.initSecurity()
	securityLevelText[SECURITY_LEVEL.LOW] = "|cffff0000" .. loc("SEC_LOW") .. "|r";
	securityLevelText[SECURITY_LEVEL.MEDIUM] = "|cffff9900" .. loc("SEC_MEDIUM") .. "|r";
	securityLevelText[SECURITY_LEVEL.HIGH] = "|cff00ff00" .. loc("SEC_HIGH") .. "|r";
	securityLevelDetailText[SECURITY_LEVEL.LOW] = loc("SEC_LOW_TT");
	securityLevelDetailText[SECURITY_LEVEL.MEDIUM] = loc("SEC_MEDIUM_TT");
	securityLevelDetailText[SECURITY_LEVEL.HIGH] = loc("SEC_HIGH_TT");
end