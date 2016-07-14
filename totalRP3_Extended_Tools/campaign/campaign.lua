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
local loc = TRP3_API.locale.getText;
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
	TRP3_API.extended.registerObject(ID, data, 0);

	return ID, data;
end
TRP3_API.extended.tools.createCampaign = createCampaign;

function TRP3_API.extended.tools.getQuestData()
	local data = {
		TY = TRP3_DB.types.QUEST,
		BA = {
			NA = loc("QE_NAME_NEW"),
			IC = "achievement_quests_completed_07"
		},
		ST = {},
		OB = {}
	}
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
			NA = loc("CA_NAME_NEW"),
			RA = "1 - 100",
			IC = "achievement_quests_completed_06"
		},
		QE = {
			first_quest = TRP3_API.extended.tools.getQuestData(),
		},
		LI = {
			OS = "on_start"
		},
		SC = {
			on_start = {
				ST = {
					["1"] = {
						t = "list",
						e = {
							{
								id = "quest_start",
								args = { campaignID, "first_quest" }
							},
						}
					},
				},
			}
		}
	}
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
end