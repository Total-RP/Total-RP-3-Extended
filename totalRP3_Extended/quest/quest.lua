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
local _G, assert, tostring, tinsert, wipe, pairs, tonumber = _G, assert, tostring, tinsert, wipe, pairs, tonumber;
local loc = TRP3_API.locale.getText;
local EMPTY = TRP3_API.globals.empty;
local Log = Utils.log;
local getClass, getClassDataSafe, getClassesByType = TRP3_API.extended.getClass, TRP3_API.extended.getClassDataSafe, TRP3_API.extended.getClassesByType;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- QUEST API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local questHandlers = {};

local function onQuestCallback(campaignID, questID, scriptID, condition, ...)
	local fullID = TRP3_API.extended.getFullID(campaignID, questID);
	local class = getClass(fullID);
	if class.SC and class.SC[scriptID] then
		local playerQuestLog = TRP3_API.quest.getQuestLog();
		local args = { object = playerQuestLog[campaignID], event = {...} };
		if TRP3_API.script.generateAndRunCondition(condition, args) then
			local retCode = TRP3_API.script.executeClassScript(scriptID, class.SC, args, fullID);
		end
	end
end

local function clearQuestHandlers(questFullID)
	Log.log("clearQuestHandlers: " .. questFullID, Log.level.DEBUG);

	if questHandlers[questFullID] then
		for handlerID, _ in pairs(questHandlers[questFullID]) do
			Utils.event.unregisterHandler(handlerID);
		end
		wipe(questHandlers[questFullID]);
		questHandlers[questFullID] = nil;
		TRP3_API.quest.clearStepHandlersForQuest(questFullID);
	end
end
TRP3_API.quest.clearQuestHandlers = clearQuestHandlers;

local function clearAllQuestHandlers()
	for questFullID, _ in pairs(questHandlers) do
		clearQuestHandlers(questFullID);
	end
end
TRP3_API.quest.clearAllQuestHandlers = clearAllQuestHandlers;

local function activateQuestHandlers(campaignID, questID, questClass)
	local fullID = TRP3_API.extended.getFullID(campaignID, questID);
	Log.log("activateQuestHandlers: " .. fullID, Log.level.DEBUG);

	for _, event in pairs(questClass.HA or EMPTY) do
		local handlerID = Utils.event.registerHandler(event.EV, function(...)
			onQuestCallback(campaignID, questID, event.SC, event.CO, ...);
		end);
		if not questHandlers[fullID] then
			questHandlers[fullID] = {};
		end
		questHandlers[fullID][handlerID] = event.EV;
	end

	-- Active handlers for known step
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	if playerQuestLog[campaignID] and playerQuestLog[campaignID].QUEST[questID] then
		local questLog = playerQuestLog[campaignID].QUEST[questID];
		for stepID, stepClass in pairs(questClass.ST or EMPTY) do
			if questLog.CS == stepID then
				TRP3_API.quest.activateStepHandlers(campaignID, questID, stepID, stepClass);
			end
		end
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

	Log.log("Start quest: " .. questID, Log.level.DEBUG);

	if not campaignLog.QUEST[questID] then
		Log.log("Starting quest " .. campaignID .. " " .. questID);

		local campaignClass = getClass(campaignID);
		local questClass = getClass(campaignID, questID);

		if not campaignClass or not questClass then
			Log.log("Unknown campaign or quest class (" .. campaignID .. ") (" .. questID .. ")");
			return;
		end

		campaignLog.QUEST[questID] = {
			OB = {},
		};

		local questIcon, questName, questDescription = getClassDataSafe(questClass);
		Utils.message.displayMessage(loc("QE_QUEST_START"):format(questName), Utils.message.type.CHAT_FRAME);

		activateQuestHandlers(campaignID, questID, questClass);

		-- Initial script
		if questClass.LI and questClass.LI.OS then
			local retCode = TRP3_API.script.executeClassScript(questClass.LI.OS, questClass.SC,
				{object = campaignLog}, TRP3_API.extended.getFullID(campaignID, questID));
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

		TRP3_API.ui.frame.setupIconButton(TRP3_QuestToast, questIcon);
		TRP3_QuestToast.name:SetText(questName);
		TRP3_QuestToast.campaignID = campaignID;
		TRP3_QuestToast.questID = questID;
		TRP3_QuestToast.questName = questName;
		TRP3_QuestToast.campaignName = campaignClass.BA.NA;
		TRP3_QuestToast:Show();

		Events.fireEvent(Events.CAMPAIGN_REFRESH_LOG);
		return 1;
	else
		Log.log("Can't start quest because already starterd " .. campaignID .. " " .. questID);
	end

	return 0;
end
TRP3_API.quest.startQuest = startQuest;

function TRP3_API.quest.getQuestCurrentStep(campaignID, questID)
	assert(campaignID and questID, "Illegal args");
	local campaignLog = TRP3_API.quest.getQuestLog()[campaignID];
	if campaignLog then
		local questLog = campaignLog.QUEST[questID];
		if questLog then
			return questLog.CS;
		end
	end
	return "nil";
end

function TRP3_API.quest.isQuestObjectiveDone(campaignID, questID, objectiveID)
	assert(campaignID and questID and objectiveID, "Illegal args");
	local campaignLog = TRP3_API.quest.getQuestLog()[campaignID];
	if campaignLog then
		local questLog = campaignLog.QUEST[questID];
		if questLog and (questLog.OB or EMPTY)[objectiveID] ~= nil then
			return (questLog.OB or EMPTY)[objectiveID];
		end
	end
	return false;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- STEP API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local stepHandlers = {};

local function onStepCallback(campaignID, questID, stepID, scriptID, condition, ...)
	local fullID = TRP3_API.extended.getFullID(campaignID, questID, stepID);
	local class = getClass(fullID);
	if class.SC and class.SC[scriptID] then
		local playerQuestLog = TRP3_API.quest.getQuestLog();
		local args = {object = playerQuestLog[campaignID], event = {...}};
		if TRP3_API.script.generateAndRunCondition(condition, args) then
			local retCode = TRP3_API.script.executeClassScript(scriptID, class.SC, args, fullID);
		end
	end
end

local function clearStepHandlers(stepFullID)
	Log.log("clearStepHandlers: " .. stepFullID, Log.level.DEBUG);

	if stepHandlers[stepFullID] then
		for handlerID, _ in pairs(stepHandlers[stepFullID]) do
			Utils.event.unregisterHandler(handlerID);
		end
		wipe(stepHandlers[stepFullID]);
		stepHandlers[stepFullID] = nil;
	end
end
TRP3_API.quest.clearStepHandlers = clearStepHandlers;

local function clearAllStepHandlers()
	for stepFullID, _ in pairs(stepHandlers) do
		clearStepHandlers(stepFullID);
	end
end
TRP3_API.quest.clearAllStepHandlers = clearAllStepHandlers;

function TRP3_API.quest.clearStepHandlersForQuest(questFullID)
	Log.log("clearStepHandlersForQuest: " .. questFullID, Log.level.DEBUG);

	for stepFullID, _ in pairs(stepHandlers) do
		if stepFullID:sub(1, questFullID:len()) == questFullID then
			clearStepHandlers(stepFullID);
		end
	end
end

local function activateStepHandlers(campaignID, questID, stepID, stepClass)
	local fullID = TRP3_API.extended.getFullID(campaignID, questID, stepID);
	Log.log("activateStepHandlers: " .. fullID, Log.level.DEBUG);

	for _, event in pairs(stepClass.HA or EMPTY) do
		local handlerID = Utils.event.registerHandler(event.EV, function(...)
			onStepCallback(campaignID, questID, stepID, event.SC, event.CO, ...);
		end);
		if not stepHandlers[fullID] then
			stepHandlers[fullID] = {};
		end
		stepHandlers[fullID][handlerID] = event.EV;
	end
end
TRP3_API.quest.activateStepHandlers = activateStepHandlers;

local function goToStep(campaignID, questID, stepID)
	-- Checks
	assert(campaignID and questID and stepID, "Illegal args");
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	if playerQuestLog.currentCampaign ~= campaignID then
		Utils.message.displayMessage("|cffff0000[Error] Can't 'go to step' because current campaign is not " .. campaignID);
		return 2;
	end
	local campaignLog = playerQuestLog[campaignID];
	if not campaignLog then
		Utils.message.displayMessage("|cffff0000[Error] Trying to 'go to step' from an unstarted campaign: " .. campaignID);
		return 2;
	end
	local questLog = campaignLog.QUEST[questID];
	if not questLog then
		Utils.message.displayMessage("|cffff0000[Error] Trying to 'go to step' from an unstarted quest: " .. campaignID .. " " .. questID);
		return 2;
	end
	if not TRP3_API.extended.classExists(campaignID, questID, stepID) then
		Utils.message.displayMessage("|cffff0000[Error] 'go to step': Unknown quest step: " .. campaignID .. " " .. questID .. " " .. stepID);
		return 2;
	end

	-- Change the current step
	if questLog.CS then
		if not questLog.PS then questLog.PS = {}; end
		tinsert(questLog.PS, questLog.CS);
		-- Remove previous step handlers
		clearStepHandlers(TRP3_API.extended.getFullID(campaignID, questID, questLog.CS));
	end
	questLog.CS = stepID;

	-- Only then, check if the step exists.
	local campaignClass = getClass(campaignID);
	local questClass = getClass(campaignID, questID);
	local stepClass = getClass(campaignID, questID, stepID);

	activateStepHandlers(campaignID, questID, stepID, stepClass);

	-- Initial script
	if stepClass.LI and stepClass.LI.OS then
		local retCode = TRP3_API.script.executeClassScript(stepClass.LI.OS, stepClass.SC,
			{object = campaignLog, classID = stepID}, TRP3_API.extended.getFullID(campaignID, questID, stepID));
	end

	if stepClass.BA.FI then
		questLog.FI = true;
		clearQuestHandlers(TRP3_API.extended.getFullID(campaignID, questID));
	end

	Events.fireEvent(Events.CAMPAIGN_REFRESH_LOG);

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
		local obectiveText = TRP3_API.script.parseArgs(objectiveClass.TX or "", TRP3_API.quest.getCampaignVarStorage());
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
				local obectiveText = TRP3_API.script.parseArgs(objectiveClass.TX or "", TRP3_API.quest.getCampaignVarStorage());
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

local function performAction(actionType)
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	if playerQuestLog.currentCampaign and playerQuestLog[playerQuestLog.currentCampaign] then

		local campaignID = playerQuestLog.currentCampaign;
		local campaignLog = playerQuestLog[campaignID];
		local campaignClass = getClass(campaignID);

		-- Campaign level
		if campaignClass then

			local args = { object = playerQuestLog[campaignID] };

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
										if TRP3_API.script.generateAndRunCondition(action.CO, args) then
											local retCode = TRP3_API.script.executeClassScript(action.SC, stepClass.SC,
												{object = campaignLog}, TRP3_API.extended.getFullID(campaignID, questID, stepID));
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
									if TRP3_API.script.generateAndRunCondition(action.CO, args) then
										local retCode = TRP3_API.script.executeClassScript(action.SC, questClass.SC,
											{object = campaignLog}, TRP3_API.extended.getFullID(campaignID, questID));
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
						if TRP3_API.script.generateAndRunCondition(action.CO, args) then
							local retCode = TRP3_API.script.executeClassScript(action.SC, campaignClass.SC,
								{object = campaignLog}, campaignID);
							return;
						end
					end
				end
			end
		end
	else
		Utils.message.displayMessage("|cffff0000" .. loc("QE_ACTION_NO_CURRENT"), 1);
		Utils.message.displayMessage("|cffff0000" .. loc("QE_ACTION_NO_CURRENT"), 4);
		return;
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

	TRP3_QuestToast.title:SetText(loc("QE_NEW"));

	TRP3_API.quest.npcInit();
	TRP3_API.quest.campaignInit();
	TRP3_API.quest.questLogInit();
	TRP3_QuestObjectives.init();

	-- Button on toolbar
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		if TRP3_API.target then
			for _, action in pairs({ACTION_TYPES.LOOK, ACTION_TYPES.LISTEN, ACTION_TYPES.ACTION, ACTION_TYPES.TALK}) do
				TRP3_API.target.registerButton({
					id = "quest_action_" .. action,
					onlyForType = TRP3_API.ui.misc.TYPE_NPC,
					configText = TRP3_API.quest.getActionTypeLocale(action),
					condition = function(_, unitID)
						return true;
					end,
					onClick = function(_, _, buttonType, _)
						performAction(action);
					end,
					tooltip = TRP3_API.quest.getActionTypeLocale(action),
					tooltipSub = "",
					icon = TRP3_API.quest.getActionTypeIcon(action)
				});
			end
		end
	end);
end