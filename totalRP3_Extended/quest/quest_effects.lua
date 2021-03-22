----------------------------------------------------------------------------------
-- Total RP 3
-- Scripts : Campaign/Quest Effects
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@telkostrasz.be)
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

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effetc structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tostring, strtrim = tostring, strtrim;
local security = TRP3_API.security.SECURITY_LEVEL;

TRP3_API.quest.EFFECTS = {

	["quest_start"] = {
		secured = security.HIGH,
		getCArgs = function(args)
			local campaignID, questID = TRP3_API.extended.splitID(args[1] or "");
			return campaignID, questID;
		end,
		method = function(structure, cArgs, eArgs)
			local campaignID, questID = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.quest.startQuest(campaignID, questID);
		end,
	},

	["quest_goToStep"] = {
		secured = security.HIGH,
		getCArgs = function(args)
			local campaignID, questID, stepID = TRP3_API.extended.splitID(args[1] or "");
			return campaignID, questID, stepID;
		end,
		method = function(structure, cArgs, eArgs)
			local campaignID, questID, stepID = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.quest.goToStep(campaignID, questID, stepID);
		end,
	},

	["quest_revealObjective"] = {
		secured = security.HIGH,
		getCArgs = function(args)
			local campaignID, questID = TRP3_API.extended.splitID(args[1] or "");
			local objectiveID = args[2];
			return campaignID, questID, objectiveID;
		end,
		method = function(structure, cArgs, eArgs)
			local campaignID, questID, objectiveID = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.quest.revealObjective(campaignID, questID, objectiveID);
		end,
	},

	["quest_markObjDone"] = {
		secured = security.HIGH,
		getCArgs = function(args)
			local campaignID, questID = TRP3_API.extended.splitID(args[1] or "");
			local objectiveID = args[2];
			return campaignID, questID, objectiveID;
		end,
		method = function(structure, cArgs, eArgs)
			local campaignID, questID, objectiveID = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.quest.markObjectiveDone(campaignID, questID, objectiveID);
		end,
	},

}