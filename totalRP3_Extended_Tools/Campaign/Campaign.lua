-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local loc = TRP3_API.loc;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Campaign management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function createCampaign(data, ID)
	ID = ID or TRP3_API.utils.str.id();

	if TRP3_DB.global[ID] then
		error("This ID already exists. This shoudn't happen: " .. ID);
	end

	TRP3_DB.my[ID] = data;
	TRP3_API.security.computeSecurity(ID, data);
	TRP3_API.extended.registerObject(ID, data, 0);

	return ID, data;
end
TRP3_API.extended.tools.createCampaign = createCampaign;


function TRP3_API.extended.tools.getQuestStepData()
	local data = {
		TY = TRP3_DB.types.QUEST_STEP,
		BA = {
			TX = loc.QE_STEP_NAME_NEW,
		},
		MD = {
			MO = TRP3_DB.modes.NORMAL,
		}
	}
	return data;
end

function TRP3_API.extended.tools.getQuestData()
	local data = {
		TY = TRP3_DB.types.QUEST,
		BA = {
			NA = loc.QE_NAME_NEW,
			IC = "achievement_quests_completed_07",
			DE = loc.QE_DESCRIPTION_TT,
			PR = true,
		},
		ST = {
			step_1_first = TRP3_API.extended.tools.getQuestStepData()
		},
		OB = {},
		MD = {
			MO = TRP3_DB.modes.NORMAL,
		}
	}
	data.ST.step_1_first.BA.IN = true;
	return data;
end

function TRP3_API.extended.tools.getCampaignData()
	local data = {
		TY = TRP3_DB.types.CAMPAIGN,
		MD = {
			MO = TRP3_DB.modes.NORMAL,
			V = 1,
			CD = date("%d/%m/%y %H:%M:%S");
			CB = TRP3_API.globals.player_id,
			SD = date("%d/%m/%y %H:%M:%S");
			SB = TRP3_API.globals.player_id,
		},
		BA = {
			NA = loc.CA_NAME_NEW,
			RA = "1 - 100",
			DE = loc.CA_DESCRIPTION_TT,
			IC = "achievement_quests_completed_06"
		},
		QE = {
			quest_1_first = TRP3_API.extended.tools.getQuestData(),
		},
	}
	data.QE.quest_1_first.BA.IN = true;
	return data;
end
