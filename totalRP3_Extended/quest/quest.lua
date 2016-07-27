----------------------------------------------------------------------------------
-- Total RP 3: Quest system
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
local _G, assert, tostring, tinsert, wipe, pairs = _G, assert, tostring, tinsert, wipe, pairs;
local loc = TRP3_API.locale.getText;
local EMPTY = TRP3_API.globals.empty;
local Log = Utils.log;
local getClass = TRP3_API.extended.getClass;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- QUEST API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local questHandlers = {};

local function onQuestCallback(campaignID, campaignClass, questID, questClass, scriptID, ...)
	if questClass and questClass.SC and questClass.SC[scriptID] then
		local playerQuestLog = TRP3_API.quest.getQuestLog();
		local retCode = TRP3_API.script.executeClassScript(scriptID, questClass.SC,
			{
				campaignID = campaignID, campaignClass = campaignClass, campaignLog = playerQuestLog[campaignID],
				questID = questID, questClass = questClass, questLog = playerQuestLog[campaignID].QUEST[questID],
			});
	end
end

local function clearAllQuestHandlers()
	for _, struct in pairs(questHandlers) do
		for handlerID, _ in pairs(struct) do
			Utils.event.unregisterHandler(handlerID);
		end
	end
	wipe(questHandlers);
end
TRP3_API.quest.clearAllQuestHandlers = clearAllQuestHandlers;

local function clearQuestHandlers(questID)
	if questHandlers[questID] then
		for handlerID, _ in pairs(questHandlers[questID]) do
			Utils.event.unregisterHandler(handlerID);
		end
		wipe(questHandlers[questID]);
		questHandlers[questID] = nil;
	end
end
TRP3_API.quest.clearQuestHandlers = clearQuestHandlers;

local function activateQuestHandlers(campaignID, campaignClass, questID, questClass)
	for eventID, scriptID in pairs(questClass.HA or EMPTY) do
		local handlerID = Utils.event.registerHandler(eventID, function(...)
			onQuestCallback(campaignID, campaignClass, questID, questClass, scriptID, ...);
		end);
		if not questHandlers[questID] then
			questHandlers[questID] = {};
		end
		questHandlers[questID][handlerID] = eventID;
	end
end
TRP3_API.quest.activateQuestHandlers = activateQuestHandlers;

local function startQuest(campaignID, questID)
	-- Checks
	assert(campaignID and questID, "Illegal args");
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	assert(playerQuestLog.currentCampaign == campaignID, ("Can't start quest because current campaign (%s) is not %s."):format(tostring(playerQuestLog.currentCampaign), campaignID));
	local campaignLog = playerQuestLog[campaignID];
	assert(campaignLog, "Trying to start quest from an unstarted campaign.");

	if not campaignLog.QUEST[questID] then
		Log.log("Starting quest " .. campaignID .. " " .. questID);

		local campaignClass = getClass(campaignID);
		local questClass = getClass(campaignID, questID);

		if not campaignClass or not questClass then
			Log.log("Unknown campaign class (" .. campaignID .. ") (" .. questID .. ")");
			return;
		end

		campaignLog.QUEST[questID] = {
			OB = {},
		};

		local questName = (questClass.BA or EMPTY).NA or UNKNOWN;
		Utils.message.displayMessage(loc("QE_QUEST_START"):format(questName), Utils.message.type.CHAT_FRAME);

		activateQuestHandlers(campaignID, campaignClass, questID, questClass);

		-- Initial script
		if questClass.LI and questClass.LI.OS then
			local retCode = TRP3_API.script.executeClassScript(questClass.LI.OS, questClass.SC,
				{classID = questID, class = questClass, object = campaignLog.QUEST[questID]}, TRP3_API.extended.getFullID(campaignID, questID));
		end

		for stepID, step in pairs(questClass.ST or EMPTY) do
			if step.BA.IN then
				TRP3_API.quest.goToStep(campaignID, questID, stepID);
				break;
			end
		end

		for objectiveID, objective in pairs(questClass.OB or EMPTY) do
			if objective.AA then
				TRP3_API.quest.revealObjective(campaignID, questID, objectiveID);
			end
		end

		Events.fireEvent(Events.CAMPAIGN_REFRESH_LOG);
		return 1;
	else
		Log.log("Can't start quest because already starterd " .. campaignID .. " " .. questID);
	end

	return 0;
end
TRP3_API.quest.startQuest = startQuest;

function TRP3_API.quest.setQuestVar(campaignID, questID, varName, varValue)
	assert(campaignID and questID, "Illegal args");
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	assert(playerQuestLog.currentCampaign == campaignID, "Can't setQuestVar because current campaign is not " .. campaignID);
	local campaignLog = playerQuestLog[campaignID];
	assert(campaignLog, "Trying to setQuestVar from an unstarted campaign: " .. campaignID);
	local questLog = campaignLog.QUEST[questID];
	assert(questLog, "Trying to setQuestVar from an unstarted quest: " .. campaignID .. " " .. questID);

	TRP3_API.script.setObjectVar(questLog, varName, varValue, false);
end

function TRP3_API.quest.incQuestVar(campaignID, questID, varName)
	assert(campaignID and questID, "Illegal args");
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	assert(playerQuestLog.currentCampaign == campaignID, "Can't setQuestVar because current campaign is not " .. campaignID);
	local campaignLog = playerQuestLog[campaignID];
	assert(campaignLog, "Trying to setQuestVar from an unstarted campaign: " .. campaignID);
	local questLog = campaignLog.QUEST[questID];
	assert(questLog, "Trying to setQuestVar from an unstarted quest: " .. campaignID .. " " .. questID);

	local current = tonumber((questLog.vars or EMPTY)[varName] or "") or 0;
	TRP3_API.script.setObjectVar(questLog, varName, current + 1, false);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- STEP API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function goToStep(campaignID, questID, stepID)
	-- Checks
	assert(campaignID and questID and stepID, "Illegal args");
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	assert(playerQuestLog.currentCampaign == campaignID, "Can't goToStep because current campaign is not " .. campaignID);
	local campaignLog = playerQuestLog[campaignID];
	assert(campaignLog, "Trying to goToStep from an unstarted campaign: " .. campaignID);
	local questLog = campaignLog.QUEST[questID];
	assert(questLog, "Trying to goToStep from an unstarted quest: " .. campaignID .. " " .. questID);

	-- Change the current step
	if questLog.CS then
		if not questLog.PS then questLog.PS = {}; end
		tinsert(questLog.PS, questLog.CS);
	end
	questLog.CS = stepID;
	Events.fireEvent(Events.CAMPAIGN_REFRESH_LOG);

	-- Only then, check if the step exists.
	local campaignClass = getClass(campaignID);
	local questClass = getClass(campaignID, questID);
	local stepClass = getClass(campaignID, questID, stepID);

	if stepClass then

		-- Initial script
		if stepClass.LI and stepClass.LI.OS then
			local retCode = TRP3_API.script.executeClassScript(stepClass.LI.OS, stepClass.SC,
				{
					object = questLog, classID = stepID, class = stepClass,
				}, TRP3_API.extended.getFullID(campaignID, questID, stepID));
		end

	else
		Log.log("Unknown step class (" .. campaignID .. ") (" .. questID .. ") (" .. stepID .. ")");
	end

	return 1;
end
TRP3_API.quest.goToStep = goToStep;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- OBJECTIVES
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function revealObjective(campaignID, questID, objectiveID)
	-- Checks
	assert(campaignID and questID and objectiveID, "Illegal args");
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	assert(playerQuestLog.currentCampaign == campaignID, "Can't revealObjective because current campaign is not " .. campaignID);
	local campaignLog = playerQuestLog[campaignID];
	assert(campaignLog, "Trying to revealObjective from an unstarted campaign: " .. campaignID);
	local questLog = campaignLog.QUEST[questID];
	assert(questLog, "Trying to revealObjective from an unstarted quest: " .. campaignID .. " " .. questID);

	local questClass = getClass(campaignID, questID);
	local objectiveClass = (questClass or EMPTY).OB[objectiveID];
	if objectiveClass then
		if not questLog.OB then questLog.OB = {} end

		if questLog.OB[objectiveID] == nil then
			-- Boolean objective
			questLog.OB[objectiveID] = false;
		end

		-- Message
		local obectiveText = TRP3_API.script.parseArgs(objectiveClass.TX or "", {object = questLog});
		Utils.message.displayMessage(loc("QE_QUEST_OBJ_REVEALED"):format(obectiveText), Utils.message.type.ALERT_MESSAGE);
		Events.fireEvent(Events.CAMPAIGN_REFRESH_LOG);

		return 1;
	else
		Log.log("Unknown objectiveID (" .. campaignID .. ") (" .. questID .. ") (" .. objectiveID .. ")");
		return 0;
	end
end
TRP3_API.quest.revealObjective = revealObjective;

local function markObjectiveDone(campaignID, questID, objectiveID)
	-- Checks
	assert(campaignID and questID and objectiveID, "Illegal args");
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	assert(playerQuestLog.currentCampaign == campaignID, "Can't showObjective because current campaign is not " .. campaignID);
	local campaignLog = playerQuestLog[campaignID];
	assert(campaignLog, "Trying to showObjective from an unstarted campaign: " .. campaignID);
	local questLog = campaignLog.QUEST[questID];
	assert(questLog, "Trying to showObjective from an unstarted quest: " .. campaignID .. " " .. questID);

	local questClass = getClass(campaignID, questID);
	local objectiveClass = (questClass or EMPTY).OB[objectiveID];
	if objectiveClass then
		if questLog.OB and questLog.OB[objectiveID] ~= nil then

			if questLog.OB[objectiveID] ~= true then
				-- Message
				local obectiveText = TRP3_API.script.parseArgs(objectiveClass.TX or "", {object = questLog});
				Utils.message.displayMessage(loc("QE_QUEST_OBJ_FINISHED"):format(obectiveText), Utils.message.type.ALERT_MESSAGE);
				questLog.OB[objectiveID] = true;
				Events.fireEvent(Events.CAMPAIGN_REFRESH_LOG);
			end
			return 1;
		else
			Log.log("Objective not revealed yet (" .. campaignID .. ") (" .. questID .. ") (" .. objectiveID .. ")");
			return 0;
		end
	else
		Log.log("Unknown objectiveID (" .. campaignID .. ") (" .. questID .. ") (" .. objectiveID .. ")");
		return 0;
	end
end
TRP3_API.quest.markObjectiveDone = markObjectiveDone;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- PLAYER ACTIONS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local ACTION_TYPES = {
	LOOK = "LOOK",
	LISTEN = "LISTEN",
	TALK = "TALK",
	ACTION = "ACTION",
};
TRP3_API.quest.ACTION_TYPES = ACTION_TYPES;

function TRP3_API.quest.getActionTypeLocale(type)
	if type == ACTION_TYPES.LOOK then
		return loc("QE_ACTIONS_TYPE_LOOK");
	elseif type == ACTION_TYPES.LISTEN then
		return loc("QE_ACTIONS_TYPE_LISTEN");
	elseif type == ACTION_TYPES.ACTION then
		return loc("QE_ACTIONS_TYPE_INTERRACT");
	elseif type == ACTION_TYPES.TALK then
		return loc("QE_ACTIONS_TYPE_TALK");
	end
end

function TRP3_API.quest.getActionTypeIcon(type)
	if type == ACTION_TYPES.LOOK then
		return "ability_eyeoftheowl";
	elseif type == ACTION_TYPES.LISTEN then
		return "inv_misc_ear_human_01";
	elseif type == ACTION_TYPES.ACTION then
		return "ability_warrior_disarm";
	elseif type == ACTION_TYPES.TALK then
		return "warrior_disruptingshout";
	end
end

local function isConditionChecked(conditionStructure, args)
	if not conditionStructure then
		return true;
	end
	local response = TRP3_API.script.generateAndRunCondition(conditionStructure, args);
	return response;
end

local function performAction(actionType)
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	if playerQuestLog.currentCampaign and playerQuestLog[playerQuestLog.currentCampaign] then

		local campaignID = playerQuestLog.currentCampaign;
		local campaignLog = playerQuestLog[campaignID];
		local campaignClass = getClass(campaignID);

		-- Campaign level
		if campaignClass then

			-- First check all the available quests
			for questID, questLog in pairs(campaignLog.QUEST) do
				-- If the quest is not done (DO)
				if not questLog.DO then
					local questClass = getClass(campaignID, questID);

					-- Quest level
					if questClass then

						-- First check step
						local stepID = questLog.CS;
						if stepID then
							local stepClass = getClass(campaignID, questID, stepID);
							if stepClass and stepClass.AC then
								for _, action in pairs(stepClass.AC) do
									if action.TY == actionType then
										if isConditionChecked(action.CO) then
											local retCode = TRP3_API.script.executeClassScript(action.SC, stepClass.SC,
												{
													campaignID = campaignID, campaignClass = campaignClass, campaignLog = campaignLog,
													questID = questID, questClass = questClass, object = questLog,
													stepID = stepID, stepClass = stepClass,
												}, TRP3_API.extended.getFullID(campaignID, questID, stepID));
											return;
										end
									end
								end
							end
						end

						-- Then check quest
						if questClass.AC then
							for _, action in pairs(questClass.AC) do
								if action.TY == actionType then
									if isConditionChecked(action.CO) then
										local retCode = TRP3_API.script.executeClassScript(action.SC, questClass.SC,
											{
												campaignID = campaignID, campaignClass = campaignClass, campaignLog = campaignLog,
												questID = questID, questClass = questClass, object = questLog,
											}, TRP3_API.extended.getFullID(campaignID, questID));
										return;
									end
								end
							end
						end
					end
				end
			end

			-- Then check the campaign
			if campaignClass.AC then
				for _, action in pairs(campaignClass.AC) do
					if action.TY == actionType then
						if isConditionChecked(action.CO) then
							local retCode = TRP3_API.script.executeClassScript(action.SC, campaignClass.SC,
								{campaignID = campaignID, campaignClass = campaignClass, object = campaignLog}, campaignID);
							return;
						end
					end
				end
			end
		end
	end

	-- If we get here: no action have been found
	if actionType == ACTION_TYPES.LOOK then
		Utils.message.displayMessage(loc("QE_NOACTION_LOOK"), 4);
	elseif actionType == ACTION_TYPES.LISTEN then
		Utils.message.displayMessage(loc("QE_NOACTION_LISTEN"), 4);
	elseif actionType == ACTION_TYPES.ACTION then
		Utils.message.displayMessage(loc("QE_NOACTION_ACTION"), 4);
	elseif actionType == ACTION_TYPES.TALK then
		Utils.message.displayMessage(loc("QE_NOACTION_TALK"), 4);
	end
end
TRP3_API.quest.performAction = performAction;

function TRP3_API.quest.inspect()
	performAction(ACTION_TYPES.LOOK);
end

function TRP3_API.quest.listen()
	performAction(ACTION_TYPES.LISTEN);
end

function TRP3_API.quest.interract()
	performAction(ACTION_TYPES.ACTION);
end

function TRP3_API.quest.talk()
	performAction(ACTION_TYPES.TALK);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.quest.onStart()
	Events.CAMPAIGN_REFRESH_LOG = "CAMPAIGN_REFRESH_LOG";
	Events.registerEvent(Events.CAMPAIGN_REFRESH_LOG);

	TRP3_API.quest.npcInit();
	TRP3_API.quest.campaignInit();
	TRP3_API.quest.questLogInit();
end