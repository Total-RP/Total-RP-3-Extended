----------------------------------------------------------------------------------
-- Total RP 3: Quest objectives
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
local pairs, tinsert, sort = pairs, tinsert, table.sort;
local getClass, getClassDataSafe, getClassesByType = TRP3_API.extended.getClass, TRP3_API.extended.getClassDataSafe, TRP3_API.extended.getClassesByType;

local frame = TRP3_QuestObjectives;

local function display()
	local HTML = "";
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	if playerQuestLog and playerQuestLog.currentCampaign and playerQuestLog[playerQuestLog.currentCampaign] then
		local campaignID = playerQuestLog.currentCampaign;
		local campaignIcon, campaignName, _ = getClassDataSafe(getClass(campaignID));
		local campaignLog = playerQuestLog[campaignID];

		local IDs = {};
		for questID, _ in pairs(campaignLog.QUEST) do
			tinsert(IDs, questID);
		end
		sort(IDs);
		local questCount = 0;
		for _, questID in pairs(IDs) do
			local questLog = campaignLog.QUEST[questID];
			if not questLog.FI then
				questCount = questCount + 1;
				local completeQuestID = campaignID .. TRP3_API.extended.ID_SEPARATOR .. questID;
				local questClass = getClass(completeQuestID)
				local questIcon, questName, _ = getClassDataSafe(questClass);
				HTML = HTML .. "{h2:r}|TInterface\\ICONS\\" .. questIcon .. ":20:20|t {link*" .. completeQuestID .. "*" .. questName .. "}{/h2}";
				if questLog.OB then
					local objIds = {};
					for objectiveID, _ in pairs(questLog.OB) do
						tinsert(objIds, objectiveID);
					end
					sort(objIds);
					for _, objectiveID in pairs(objIds) do
						local state = questLog.OB[objectiveID];
						local objectiveClass = questClass.OB[objectiveID];
						local objText = UNKNOWN;
						if objectiveClass then
							local obectiveText = TRP3_API.script.parseObjectArgs(objectiveClass.TX or "", TRP3_API.quest.getCampaignVarStorage());
							if state == true then
								objText = "|TInterface\\Scenarios\\ScenarioIcon-Check:12:12|t " .. obectiveText;
							else
								objText = "- " .. obectiveText;
							end
						end
						HTML = HTML .. objText .. "\n";
					end
				end
			end
		end

		if questCount > 0 then
			HTML = "{h1}|TInterface\\ICONS\\" .. campaignIcon .. ":20:20|t {link*" .. campaignID .. "*" .. campaignName .. "}{/h1}" .. HTML;
		end
	end
	frame.html = Utils.str.toHTML(HTML);
	frame:SetText(frame.html);
end

function frame.init()
	local questLogFrame = TRP3_QuestLogPage;

	frame:SetFontObject("h1", GameFontNormalLarge);
	frame:SetTextColor("h1", 0.95, 0.75, 0);

	frame:SetFontObject("h2", GameFontNormal);
	frame:SetTextColor("h2", 0.95, 0.75, 0);

	frame:SetFontObject("p", GameFontNormal);
	frame:SetTextColor("p", 0.95, 0.95, 0.95);

	frame:SetScript("OnHyperlinkClick", function(self, link, text, button)
		if not link:find(TRP3_API.extended.ID_SEPARATOR) then
			local class = getClass(link);
			local _, campaignName, _ = getClassDataSafe(class);
			TRP3_API.navigation.openMainFrame();
			TRP3_API.navigation.menu.selectMenu("main_14_player_quest");
			questLogFrame.goToPage(false, questLogFrame.TAB_QUESTS, link, campaignName);
		else
			local campaignID, questID = strsplit(TRP3_API.extended.ID_SEPARATOR, link);
			local _, campaignName, _ = getClassDataSafe(getClass(campaignID));
			local _, questName, _ = getClassDataSafe(getClass(link));
			TRP3_API.navigation.openMainFrame();
			TRP3_API.navigation.menu.selectMenu("main_14_player_quest");
			questLogFrame.goToPage(false, questLogFrame.TAB_QUESTS, campaignID, campaignName);
			questLogFrame.goToPage(false, questLogFrame.TAB_STEPS, campaignID, questID, questName);
		end
	end);

	local ticker = C_Timer.NewTicker(1, function()
		frame:Hide();
		if ObjectiveTrackerBlocksFrame.QuestHeader.module.lastBlock then
			frame:SetPoint("TOPRIGHT", ObjectiveTrackerBlocksFrame.QuestHeader.module.lastBlock, "BOTTOMRIGHT", 0, -10);
			display();
			frame:Show();
		end
	end);
end