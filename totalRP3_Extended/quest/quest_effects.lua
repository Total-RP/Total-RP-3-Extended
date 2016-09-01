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
		codeReplacementFunc = function (args)
			local campaignID, questID = TRP3_API.extended.splitID(args[1] or "");
			return ("lastEffectReturn = startQuest(\"%s\", \"%s\");"):format(campaignID, questID);
		end,
		env = {
			startQuest = "TRP3_API.quest.startQuest",
		}
	},

	["quest_goToStep"] = {
		secured = security.HIGH,
		codeReplacementFunc = function (args)
			local campaignID, questID, stepID = TRP3_API.extended.splitID(args[1] or "");
			return ("lastEffectReturn = goToStep(\"%s\", \"%s\", \"%s\");"):format(campaignID, questID, stepID);
		end,
		env = {
			goToStep = "TRP3_API.quest.goToStep",
		}
	},

	["quest_revealObjective"] = {
		secured = security.HIGH,
		codeReplacementFunc = function (args)
			local campaignID, questID = TRP3_API.extended.splitID(args[1] or "");
			local objectiveID = args[2];
			return ("lastEffectReturn = revealObjective(\"%s\", \"%s\", \"%s\");"):format(campaignID, questID, objectiveID);
		end,
		env = {
			revealObjective = "TRP3_API.quest.revealObjective",
		}
	},

	["quest_markObjDone"] = {
		secured = security.HIGH,
		codeReplacementFunc = function (args)
			local campaignID, questID = TRP3_API.extended.splitID(args[1] or "");
			local objectiveID = args[2];
			return ("lastEffectReturn = markObjectiveDone(\"%s\", \"%s\", \"%s\");"):format(campaignID, questID, objectiveID);
		end,
		env = {
			markObjectiveDone = "TRP3_API.quest.markObjectiveDone",
		}
	},

}