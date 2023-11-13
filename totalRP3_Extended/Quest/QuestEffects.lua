-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effect structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

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
