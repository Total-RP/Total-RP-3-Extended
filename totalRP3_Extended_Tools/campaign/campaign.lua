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

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local wipe, tostring, error, assert, date = wipe, tostring, error, assert, date;
local loc = TRP3_API.loc;
local toolFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Campaign management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function createCampaign(data, ID)
	ID = ID or Utils.str.id();

	if TRP3_DB.global[ID] then
		error("This ID already exists. This shoudn't happen: " .. ID);
	end

	TRP3_DB.my[ID] = data;
	TRP3_API.security.computeSecurity(ID, data);
	TRP3_API.extended.registerObject(ID, data, 0);

	return ID, data;
end
TRP3_API.extended.tools.createCampaign = createCampaign;


function TRP3_API.extended.tools.getQuestStepData(id)
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

function TRP3_API.extended.tools.getCampaignData(campaignID)
	local data = {
		TY = TRP3_DB.types.CAMPAIGN,
		MD = {
			MO = TRP3_DB.modes.NORMAL,
			V = 1,
			CD = date("%d/%m/%y %H:%M:%S");
			CB = Globals.player_id,
			SD = date("%d/%m/%y %H:%M:%S");
			SB = Globals.player_id,
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

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Campaign base frame
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onLoad()
	assert(toolFrame.rootClassID, "rootClassID is nil");
	assert(toolFrame.fullClassID, "fullClassID is nil");
	assert(toolFrame.rootDraft, "rootDraft is nil");
	assert(toolFrame.specificDraft, "specificDraft is nil");

	toolFrame.campaign.normal:Show();
	toolFrame.campaign.normal.load();
end

local function onSave()
	assert(toolFrame.specificDraft, "specificDraft is nil");
	toolFrame.campaign.normal.saveToDraft();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initCampaign(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.campaign.onLoad = onLoad;
	toolFrame.campaign.onSave = onSave;

	TRP3_API.extended.tools.initCampaignEditorNormal(toolFrame);
	TRP3_ActionsEditorFrame.init(toolFrame);
end