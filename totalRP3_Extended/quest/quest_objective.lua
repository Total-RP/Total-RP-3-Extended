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

local ACTION_FRAMES = {
	[TRP3_API.quest.ACTION_TYPES.LOOK] = frame.Actions.Look,
	[TRP3_API.quest.ACTION_TYPES.TALK] = frame.Actions.Talk,
	[TRP3_API.quest.ACTION_TYPES.LISTEN] = frame.Actions.Listen,
	[TRP3_API.quest.ACTION_TYPES.ACTION] = frame.Actions.Interact,
};

local function display()
	local HTML = "";
	frame.Actions:Hide();
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	if playerQuestLog and playerQuestLog.currentCampaign and playerQuestLog[playerQuestLog.currentCampaign] then
		frame.Actions:Show();

		local campaignID = playerQuestLog.currentCampaign;
		local campaignClass = getClass(campaignID);
		local campaignIcon, campaignName, _ = getClassDataSafe(campaignClass);
		local campaignLog = playerQuestLog[campaignID];

		local activeActions = {};
		-- Looking for campaign actions
		if campaignClass and campaignClass.AC then
			for _, action in pairs(campaignClass.AC) do
				activeActions[action.TY] = true;
			end
		end

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
				HTML = HTML .. "\n{h2}|TInterface\\ICONS\\" .. questIcon .. ":20:20|t " .. TRP3_API.Ellyb.ColorManager.YELLOW("{link*" .. completeQuestID .. "*" .. questName .. "}") .. "{/h2}";
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
							local obectiveText = TRP3_API.script.parseArgs(objectiveClass.TX or "", TRP3_API.quest.getCampaignVarStorage());
							if state == true then
								objText = "|TInterface\\Scenarios\\ScenarioIcon-Check:12:12|t " .. obectiveText;
							else
								objText = "- " .. obectiveText;
							end
						end
						HTML = HTML .. objText .. "\n";
					end
				end

				-- Looking for quest actions
				if questClass and questClass.AC then
					for _, action in pairs(questClass.AC) do
						activeActions[action.TY] = true;
					end
				end

				-- Looking for step actions
				local stepID = questLog.CS;
				if stepID then
					local stepClass = getClass(campaignID, questID, stepID);
					if stepClass and stepClass.AC then
						for _, action in pairs(stepClass.AC) do
							activeActions[action.TY] = true;
						end
					end
				end
			end
		end

		if questCount > 0 then
			HTML = "{h1}|TInterface\\ICONS\\" .. campaignIcon .. ":20:20|t " .. TRP3_API.Ellyb.ColorManager.YELLOW("{link*" .. campaignID .. "*" .. campaignName .. "}") .. "{/h1}" .. HTML;
		end

		-- Fading non-relevant actions
		for action, button in pairs(ACTION_FRAMES) do
			if activeActions[action] then
				button:GetNormalTexture():SetDesaturated(false);
				button:SetAlpha(1);
			else
				button:GetNormalTexture():SetDesaturated(true);
				button:SetAlpha(0.5);
			end
		end
	end
	frame.Tracker.html = Utils.str.toHTML(HTML, true, true);
	frame.Tracker:SetText(frame.Tracker.html);
end

function frame.init()
	local questLogFrame = TRP3_QuestLogPage;

	frame.Actions.caption:Hide()

	for action, button in pairs(ACTION_FRAMES) do
		button:SetNormalTexture("Interface\\ICONS\\"..TRP3_API.quest.getActionTypeIcon(action));
		button:SetScript("OnClick", function() TRP3_API.quest.performAction(action) end);
		button:SetScript("OnEnter", TRP3_API.ui.tooltip.refresh);
		button:SetScript("OnLeave", function() TRP3_MainTooltip:Hide() end);
		TRP3_API.ui.tooltip.setTooltipForSameFrame(button, "TOP", 0, 5, TRP3_API.quest.getActionTypeLocale(action), "");
	end

	frame.Tracker:SetFontObject("h1", GameFontNormalLarge);
	frame.Tracker:SetTextColor("h1", 0.95, 0.75, 0);

	frame.Tracker:SetFontObject("h2", GameFontNormal);
	frame.Tracker:SetTextColor("h2", 0.95, 0.75, 0);

	frame.Tracker:SetFontObject("p", GameFontNormal);
	frame.Tracker:SetTextColor("p", 0.95, 0.95, 0.95);

	frame.Tracker:SetScript("OnHyperlinkClick", function(self, link, text, button)
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

	local ticker = C_Timer.NewTicker(0.5, function()
		frame:Hide();
		if ObjectiveTrackerBlocksFrame:IsShown() then
			local top = ObjectiveTrackerBlocksFrame.contentsHeight
			if top > 0 then
				top = top + 10
			end
			frame:SetPoint("TOPRIGHT", ObjectiveTrackerBlocksFrame, "TOPRIGHT", 0, -top);
			frame:SetPoint("TOPLEFT", ObjectiveTrackerBlocksFrame, "TOPLEFT", 0, -top);
			frame:SetWidth(ObjectiveTrackerBlocksFrame:GetWidth());
			frame.Tracker:SetWidth(ObjectiveTrackerBlocksFrame:GetWidth());
			display();
			frame:Show();
		end
	end);
end