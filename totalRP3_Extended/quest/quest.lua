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
local loc = TRP3_API.loc;
local EMPTY = TRP3_API.globals.empty;
local Log = Utils.log;
local getClass, getClassDataSafe, getClassesByType = TRP3_API.extended.getClass, TRP3_API.extended.getClassDataSafe, TRP3_API.extended.getClassesByType;

-- Ellyb imports
local Ellyb = TRP3_API.Ellyb;

-- List of custom events for Extended
local CUSTOM_EVENTS = {
	TRP3_KILL = "TRP3_KILL",
	TRP3_ROLL = "TRP3_ROLL",
	TRP3_SIGNAL = "TRP3_SIGNAL",
	TRP3_ITEM_USED = "TRP3_ITEM_USED"
};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- QUEST API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local questHandlers = {};

local function onQuestCallback(campaignID, questID, scriptID, condition, eventID, ...)
	local fullID = TRP3_API.extended.getFullID(campaignID, questID);
	local class = getClass(fullID);
	if class.SC and class.SC[scriptID] then
		local payload = {...};
		if (eventID == "COMBAT_LOG_EVENT" or eventID == "COMBAT_LOG_EVENT_UNFILTERED") then
			payload = {CombatLogGetCurrentEventInfo()};	-- No payload for combat log events in 8.0
		end
		local playerQuestLog = TRP3_API.quest.getQuestLog();
		local args = { object = playerQuestLog[campaignID], event = payload };
		if TRP3_API.script.generateAndRunCondition(condition, args) then
			local retCode = TRP3_API.script.executeClassScript(scriptID, class.SC, args, fullID);
		end
	end
end

local function clearQuestHandlers(questFullID)
	Log.log("clearQuestHandlers: " .. questFullID, Log.level.DEBUG);

	if questHandlers[questFullID] then
		for handlerID, eventID in pairs(questHandlers[questFullID]) do
			if (CUSTOM_EVENTS[eventID] ~= nil) then
				Events.unregisterCallback(handlerID);
			else
				Utils.event.unregisterHandler(handlerID);
			end
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
	TRP3_API.quest.clearAllStepHandlers();
end
TRP3_API.quest.clearAllQuestHandlers = clearAllQuestHandlers;

local function registerQuestHandler(campaignID, questID, fullID, event)
	local handlerID;
	if (CUSTOM_EVENTS[event.EV] ~= nil) then
		handlerID = Events.registerCallback(event.EV, function(...)
			onQuestCallback(campaignID, questID, event.SC, event.CO, event.EV, ...);
		end);
	else
		handlerID = Utils.event.registerHandler(event.EV, function(...)
			onQuestCallback(campaignID, questID, event.SC, event.CO, event.EV, ...);
		end);
	end
	if not questHandlers[fullID] then
		questHandlers[fullID] = {};
	end
	questHandlers[fullID][handlerID] = event.EV;
end

local function activateQuestHandlers(campaignID, questID, questClass)
	local fullID = TRP3_API.extended.getFullID(campaignID, questID);
	Log.log("activateQuestHandlers: " .. fullID, Log.level.DEBUG);

	for _, event in pairs(questClass.HA or EMPTY) do
		if event.EV and not pcall(registerQuestHandler, campaignID, questID, fullID, event) then
			Utils.message.displayMessage(Ellyb.ColorManager.RED(loc.WO_EVENT_EX_UNKNOWN_ERROR:format(event.EV, fullID)));
		end
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
	assert(campaignID, loc.ERROR_MISSING_ARG:format("campaignID", "startQuest(campaignID, questID)"));
	assert(questID, loc.ERROR_MISSING_ARG:format("questID", "startQuest(campaignID, questID)"));

	if not TRP3_API.extended.classExists(campaignID, questID) then
		Utils.message.displayMessage("|cffff0000[Error] 'start quest': Unknown quest: " .. campaignID .. " " .. questID);
		return 2;
	end

	local playerQuestLog = TRP3_API.quest.getQuestLog();
	local campaignLog = playerQuestLog[campaignID];

	if playerQuestLog.currentCampaign ~= campaignID or not campaignLog then
		local campaignClass = getClass(campaignID);
		local _, campaignName = getClassDataSafe(campaignClass);
		local autoResumeWarning = loc.QE_AUTORESUME_CONFIRM:format(campaignName);
		TRP3_API.popup.showConfirmPopup(autoResumeWarning, function()
			TRP3_API.quest.activateCampaign(campaignID, false);
			TRP3_API.quest.startQuestForReal(campaignID, questID);
		end);
	else
		TRP3_API.quest.startQuestForReal(campaignID, questID);
	end

	return 1;
end
TRP3_API.quest.startQuest = startQuest;

local function startQuestForReal(campaignID, questID)
	Log.log("Starting quest " .. campaignID .. " " .. questID);

	local campaignClass = getClass(campaignID);
	local questClass = getClass(campaignID, questID);
	local playerQuestLog = TRP3_API.quest.getQuestLog();
	local campaignLog = playerQuestLog[campaignID];

	-- If the quest is already revealed, clear handlers
	if campaignLog.QUEST[questID] then
		clearQuestHandlers(TRP3_API.extended.getFullID(campaignID, questID));
		local stepID = campaignLog.QUEST[questID].CS;
		if stepID then
			TRP3_API.quest.clearStepHandlersForQuest(TRP3_API.extended.getFullID(campaignID, questID, stepID))
		end
	end

	campaignLog.QUEST[questID] = {
		OB = {},
	};

	local questIcon, questName, questDescription = getClassDataSafe(questClass);
	Utils.message.displayMessage(loc.QE_QUEST_START:format(questName), Utils.message.type.CHAT_FRAME);

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
end
TRP3_API.quest.startQuestForReal = startQuestForReal;

function TRP3_API.quest.getQuestCurrentStep(campaignID, questID)
	assert(campaignID, loc.ERROR_MISSING_ARG:format("campaignID", "TRP3_API.quest.getQuestCurrentStep(campaignID, questID)"));
	assert(questID, loc.ERROR_MISSING_ARG:format("questID", "TRP3_API.quest.getQuestCurrentStep(campaignID, questID)"));
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

function TRP3_API.quest.isAllQuestObjectiveDone(campaignID, questID, all)
	assert(campaignID, loc.ERROR_MISSING_ARG:format("campaignID", "TRP3_API.quest.isAllQuestObjectiveDone(campaignID, questID, all)"));
	assert(questID, loc.ERROR_MISSING_ARG:format("questID", "TRP3_API.quest.isAllQuestObjectiveDone(campaignID, questID, all)"));
	local campaignLog = TRP3_API.quest.getQuestLog()[campaignID];
	if campaignLog then
		local questLog = campaignLog.QUEST[questID];
		if questLog then
			if not all then
				if questLog.OB then
					for id, val in pairs(questLog.OB) do
						if not val then
							return false;
						end
					end
				end
				return true;
			else
				local fullID = TRP3_API.extended.getFullID(campaignID, questID);
				local class = getClass(fullID);
				for id, _ in pairs(class.OB) do
					if not questLog.OB or not questLog.OB[id] then
						return false;
					end
				end
				return true;
			end
		end
	end
	return false;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- STEP API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local stepHandlers = {};

local function onStepCallback(campaignID, questID, stepID, scriptID, condition, eventID, ...)
	local fullID = TRP3_API.extended.getFullID(campaignID, questID, stepID);
	local class = getClass(fullID);
	if class.SC and class.SC[scriptID] then
		local payload = {...};
		if (eventID == "COMBAT_LOG_EVENT" or eventID == "COMBAT_LOG_EVENT_UNFILTERED") then
			payload = {CombatLogGetCurrentEventInfo()};	-- No payload for combat log events in 8.0
		end
		local playerQuestLog = TRP3_API.quest.getQuestLog();
		local args = {object = playerQuestLog[campaignID], event = payload};
		if TRP3_API.script.generateAndRunCondition(condition, args) then
			local retCode = TRP3_API.script.executeClassScript(scriptID, class.SC, args, fullID);
		end
	end
end

local function clearStepHandlers(stepFullID)
	Log.log("clearStepHandlers: " .. stepFullID, Log.level.DEBUG);

	if stepHandlers[stepFullID] then
		for handlerID, eventID in pairs(stepHandlers[stepFullID]) do
			if (CUSTOM_EVENTS[eventID] ~= nil) then
				Events.unregisterCallback(handlerID);
			else
				Utils.event.unregisterHandler(handlerID);
			end
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

local function registerStepHandler(campaignID, questID, stepID, fullID, event)
	local handlerID;
	if (CUSTOM_EVENTS[event.EV] ~= nil) then
		handlerID = Events.registerCallback(event.EV, function(...)
			onStepCallback(campaignID, questID, stepID, event.SC, event.CO, event.EV, ...);
		end);
	else
		handlerID = Utils.event.registerHandler(event.EV, function(...)
			onStepCallback(campaignID, questID, stepID, event.SC, event.CO, event.EV, ...);
		end);
	end
	if not stepHandlers[fullID] then
		stepHandlers[fullID] = {};
	end
	stepHandlers[fullID][handlerID] = event.EV;
end

local function activateStepHandlers(campaignID, questID, stepID, stepClass)
	local fullID = TRP3_API.extended.getFullID(campaignID, questID, stepID);
	Log.log("activateStepHandlers: " .. fullID, Log.level.DEBUG);

	for _, event in pairs(stepClass.HA or EMPTY) do
		if event.EV and not pcall(registerStepHandler, campaignID, questID, stepID, fullID, event) then
			Utils.message.displayMessage(Ellyb.ColorManager.RED(loc.WO_EVENT_EX_UNKNOWN_ERROR:format(event.EV, fullID)));
		end
	end
end
TRP3_API.quest.activateStepHandlers = activateStepHandlers;

local function goToStep(campaignID, questID, stepID)
	-- Checks
	assert(campaignID, loc.ERROR_MISSING_ARG:format("campaignID", "TRP3_API.quest.goToStep(campaignID, questID, stepID)"));
	assert(questID, loc.ERROR_MISSING_ARG:format("questID", "TRP3_API.quest.goToStep(campaignID, questID, stepID)"));
	assert(stepID, loc.ERROR_MISSING_ARG:format("stepID", "TRP3_API.quest.goToStep(campaignID, questID, stepID)"));

	if not TRP3_API.extended.classExists(campaignID, questID, stepID) then
		Utils.message.displayMessage("|cffff0000[Error] 'go to step': Unknown quest step: " .. campaignID .. " " .. questID .. " " .. stepID);
		return 2;
	end

	local playerQuestLog = TRP3_API.quest.getQuestLog();
	local campaignLog = playerQuestLog[campaignID];

	if not campaignLog then
		local campaignClass = getClass(campaignID);
		local _, campaignName = getClassDataSafe(campaignClass);
		local autoResumeWarning = loc.QE_AUTORESUME_CONFIRM:format(campaignName);
		TRP3_API.popup.showConfirmPopup(autoResumeWarning, function()
			TRP3_API.quest.activateCampaign(campaignID, false);
			TRP3_API.quest.goToStepForReal(campaignID, questID, stepID);
		end);
		return 3;
	else
		local questLog = campaignLog.QUEST[questID];

		if not questLog then
			Utils.message.displayMessage("|cffff0000[Error] Trying to 'go to step' from an unstarted quest: " .. campaignID .. " " .. questID);
			return 2;
		end

		if playerQuestLog.currentCampaign ~= campaignID then
			local campaignClass = getClass(campaignID);
			local _, campaignName = getClassDataSafe(campaignClass);
			local autoResumeWarning = loc.QE_AUTORESUME_CONFIRM:format(campaignName);
			TRP3_API.popup.showConfirmPopup(autoResumeWarning, function()
				TRP3_API.quest.activateCampaign(campaignID, false);
				TRP3_API.quest.goToStepForReal(campaignID, questID, stepID);
			end);
		else
			TRP3_API.quest.goToStepForReal(campaignID, questID, stepID);
		end
		return 1;
	end
end
TRP3_API.quest.goToStep = goToStep;

local function goToStepForReal(campaignID, questID, stepID)

	local playerQuestLog = TRP3_API.quest.getQuestLog();
	local campaignLog = playerQuestLog[campaignID];
	local questLog = campaignLog.QUEST[questID];

	-- Change the current step
	if questLog.CS then
		local currentStepID = TRP3_API.extended.getFullID(campaignID, questID, questLog.CS);
		local currentStepClass = getClass(currentStepID);

		-- Triggers current step On Leave
		if currentStepClass and currentStepClass.LI and currentStepClass.LI.OL then
			local retCode = TRP3_API.script.executeClassScript(currentStepClass.LI.OL, currentStepClass.SC,
			{object = campaignLog, classID = stepID}, currentStepID);
		end

		if not questLog.PS then questLog.PS = {}; end
		tinsert(questLog.PS, questLog.CS);

		-- Remove previous step handlers
		clearStepHandlers(currentStepID);
	end
	questLog.CS = stepID;

	-- Go to new step
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
end
TRP3_API.quest.goToStepForReal = goToStepForReal;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- OBJECTIVES
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function revealObjective(campaignID, questID, objectiveID)
	-- Checks
	assert(campaignID, loc.ERROR_MISSING_ARG:format("campaignID", "TRP3_API.quest.revealObjective(campaignID, questID, objectiveID)"));
	assert(questID, loc.ERROR_MISSING_ARG:format("questID", "TRP3_API.quest.revealObjective(campaignID, questID, objectiveID)"));
	assert(objectiveID, loc.ERROR_MISSING_ARG:format("objectiveID", "TRP3_API.quest.revealObjective(campaignID, questID, objectiveID)"));

	local playerQuestLog = TRP3_API.quest.getQuestLog();
	local campaignLog = playerQuestLog[campaignID];
	local questClass = getClass(campaignID, questID);
	local objectiveClass = questClass.OB[objectiveID];

	if not TRP3_API.extended.classExists(campaignID, questID) then
		Utils.message.displayMessage("|cffff0000[Error] 'reveal objective': Unknown quest: " .. campaignID .. " " .. questID);
		return 2;
	end
	if not objectiveClass then
		Utils.message.displayMessage("|cffff0000[Error] 'reveal objective': Unknown objective: " .. campaignID .. " " .. questID .. " " .. objectiveID);
		return 2;
	end

	if not campaignLog then
		local campaignClass = getClass(campaignID);
		local _, campaignName = getClassDataSafe(campaignClass);
		local autoResumeWarning = loc.QE_AUTORESUME_CONFIRM:format(campaignName);
		TRP3_API.popup.showConfirmPopup(autoResumeWarning, function()
			TRP3_API.quest.activateCampaign(campaignID, false);
			TRP3_API.quest.revealObjective(campaignID, questID, objectiveID);
		end);
		return 3;
	else
		local questLog = campaignLog.QUEST[questID];

		if not questLog then
			Utils.message.displayMessage("|cffff0000[Error] Trying to 'reveal objective' from an unstarted quest: " .. campaignID .. " " .. questID);
			return 2;
		end

		if playerQuestLog.currentCampaign ~= campaignID then
			local campaignClass = getClass(campaignID);
			local _, campaignName = getClassDataSafe(campaignClass);
			local autoResumeWarning = loc.QE_AUTORESUME_CONFIRM:format(campaignName);
			TRP3_API.popup.showConfirmPopup(autoResumeWarning, function()
				TRP3_API.quest.activateCampaign(campaignID, false);
				TRP3_API.quest.revealObjectiveForReal(campaignID, questID, objectiveID);
			end);
		else
			TRP3_API.quest.revealObjectiveForReal(campaignID, questID, objectiveID);
		end

		return 1;
	end
end
TRP3_API.quest.revealObjective = revealObjective;

local function revealObjectiveForReal(campaignID, questID, objectiveID)

	local playerQuestLog = TRP3_API.quest.getQuestLog();
	local campaignLog = playerQuestLog[campaignID];
	local questLog = campaignLog.QUEST[questID];
	local questClass = getClass(campaignID, questID);
	local objectiveClass = questClass.OB[objectiveID];

	if not questLog.OB then questLog.OB = {} end

	local firstReveal = false;
	if questLog.OB[objectiveID] == nil then
		-- Boolean objective
		questLog.OB[objectiveID] = false;
		firstReveal = true;
	end

	-- Message
	local obectiveText = TRP3_API.script.parseArgs(objectiveClass.TX or "", TRP3_API.quest.getCampaignVarStorage());
	if firstReveal then
		Utils.message.displayMessage(loc.QE_QUEST_OBJ_REVEALED:format(obectiveText), Utils.message.type.ALERT_MESSAGE);
	else
		Utils.message.displayMessage(loc.QE_QUEST_OBJ_UPDATED:format(obectiveText), Utils.message.type.ALERT_MESSAGE);
	end
	Events.fireEvent(Events.CAMPAIGN_REFRESH_LOG);
end
TRP3_API.quest.revealObjectiveForReal = revealObjectiveForReal;

local function markObjectiveDone(campaignID, questID, objectiveID)
	-- Checks
	assert(campaignID, loc.ERROR_MISSING_ARG:format("campaignID", "TRP3_API.quest.markObjectiveDone(campaignID, questID, objectiveID)"));
	assert(questID, loc.ERROR_MISSING_ARG:format("questID", "TRP3_API.quest.markObjectiveDone(campaignID, questID, objectiveID)"));
	assert(objectiveID, loc.ERROR_MISSING_ARG:format("objectiveID", "TRP3_API.quest.markObjectiveDone(campaignID, questID, objectiveID)"));
	local playerQuestLog = TRP3_API.quest.getQuestLog();

	local campaignLog = playerQuestLog[campaignID];

	if not TRP3_API.extended.classExists(campaignID, questID) then
		Utils.message.displayMessage("|cffff0000[Error] 'mark objective done': Unknown quest: " .. campaignID .. " " .. questID);
		return 2;
	end

	local questFullID = TRP3_API.extended.getFullID(campaignID, questID);
	local questClass = getClass(questFullID);
	local objectiveClass = questClass.OB[objectiveID];

	if not objectiveClass then
		Utils.message.displayMessage("|cffff0000[Error] 'mark objective done': Unknown objective: " .. campaignID .. " " .. questID .. " " .. objectiveID);
		return 2;
	end

	if not campaignLog then
		local campaignClass = getClass(campaignID);
		local _, campaignName = getClassDataSafe(campaignClass);
		local autoResumeWarning = loc.QE_AUTORESUME_CONFIRM:format(campaignName);
		TRP3_API.popup.showConfirmPopup(autoResumeWarning, function()
			TRP3_API.quest.activateCampaign(campaignID, false);
			TRP3_API.quest.markObjectiveDone(campaignID, questID, objectiveID);
		end);
		return 3;
	else
		local questLog = campaignLog.QUEST[questID];
		if not questLog then
			Utils.message.displayMessage("|cffff0000[Error] Trying to 'mark objective done' from an unstarted quest: " .. campaignID .. " " .. questID);
			return 2;
		end

		if playerQuestLog.currentCampaign ~= campaignID then
			local campaignClass = getClass(campaignID);
			local _, campaignName = getClassDataSafe(campaignClass);
			local autoResumeWarning = loc.QE_AUTORESUME_CONFIRM:format(campaignName);
			TRP3_API.popup.showConfirmPopup(autoResumeWarning, function()
				TRP3_API.quest.activateCampaign(campaignID, false);
				TRP3_API.quest.markObjectiveDoneForReal(campaignID, questID, objectiveID);
			end);
		else
			TRP3_API.quest.markObjectiveDoneForReal(campaignID, questID, objectiveID);
		end
		return 1;
	end
end
TRP3_API.quest.markObjectiveDone = markObjectiveDone;

local function markObjectiveDoneForReal(campaignID, questID, objectiveID)

	local playerQuestLog = TRP3_API.quest.getQuestLog();
	local campaignLog = playerQuestLog[campaignID];
	local questLog = campaignLog.QUEST[questID];
	local questFullID = TRP3_API.extended.getFullID(campaignID, questID);
	local questClass = getClass(questFullID);
	local objectiveClass = questClass.OB[objectiveID];

	if not questLog.OB then questLog.OB = {} end

	-- Message
	local obectiveText = TRP3_API.script.parseArgs(objectiveClass.TX or "", TRP3_API.quest.getCampaignVarStorage());
	Utils.message.displayMessage(loc.QE_QUEST_OBJ_FINISHED:format(obectiveText), Utils.message.type.ALERT_MESSAGE);
	questLog.OB[objectiveID] = true;
	Events.fireEvent(Events.CAMPAIGN_REFRESH_LOG);

	-- Initial script
	if questClass.LI and questClass.LI.OOC then
		local retCode = TRP3_API.script.executeClassScript(questClass.LI.OOC, questClass.SC,
			{object = campaignLog, classID = questFullID}, questFullID);
	end
end
TRP3_API.quest.markObjectiveDoneForReal = markObjectiveDoneForReal;

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
		return loc.QE_ACTIONS_TYPE_LOOK;
	elseif type == ACTION_TYPES.LISTEN then
		return loc.QE_ACTIONS_TYPE_LISTEN;
	elseif type == ACTION_TYPES.ACTION then
		return loc.QE_ACTIONS_TYPE_INTERRACT;
	elseif type == ACTION_TYPES.TALK then
		return loc.QE_ACTIONS_TYPE_TALK;
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
		Utils.message.displayMessage("|cffff0000" .. loc.QE_ACTION_NO_CURRENT, 1);
		Utils.message.displayMessage("|cffff0000" .. loc.QE_ACTION_NO_CURRENT, 4);
		return;
	end

	-- If we get here: no action have been found
	if actionType == ACTION_TYPES.LOOK then
		Utils.message.displayMessage(loc.QE_NOACTION_LOOK, 4);
	elseif actionType == ACTION_TYPES.LISTEN then
		Utils.message.displayMessage(loc.QE_NOACTION_LISTEN, 4);
	elseif actionType == ACTION_TYPES.ACTION then
		Utils.message.displayMessage(loc.QE_NOACTION_ACTION, 4);
	elseif actionType == ACTION_TYPES.TALK then
		Utils.message.displayMessage(loc.QE_NOACTION_TALK, 4);
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

	TRP3_QuestToast.title:SetText(loc.QE_NEW);

	TRP3_API.quest.npcInit();
	TRP3_API.quest.campaignInit();
	TRP3_API.quest.questLogInit();
	TRP3_QuestObjectives.init();
end
