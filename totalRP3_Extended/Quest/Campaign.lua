-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local Events, Utils = TRP3_Addon.Events, TRP3_API.utils;
local EMPTY = TRP3_API.globals.empty;
local tostring, pairs, wipe = tostring, pairs, wipe;
local loc = TRP3_API.loc;
local getClass, getClassDataSafe = TRP3_API.extended.getClass, TRP3_API.extended.getClassDataSafe;

local CUSTOM_EVENTS = TRP3_API.extended.CUSTOM_EVENTS;

local playerQuestLog;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UTILS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.quest.getQuestLog()
	-- Structures
	local playerProfile = TRP3_API.profile.getPlayerCurrentProfile();
	if not playerProfile.questlog then
		playerProfile.questlog = {};
	end
	return playerProfile.questlog;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- HANDLERS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local campaignHandlers = TRP3_API.CreateCallbackGroup();

local function onCampaignCallback(campaignID, scriptID, condition, eventID, ...)
	local class = getClass(campaignID);
	if class and class.SC and class.SC[scriptID] then
		local payload = {...};
		if (eventID == "COMBAT_LOG_EVENT" or eventID == "COMBAT_LOG_EVENT_UNFILTERED") then
			payload = {CombatLogGetCurrentEventInfo()};	-- No payload for combat log events in 8.0
		end
		local args = { object = playerQuestLog[campaignID], event = payload };
		if TRP3_API.script.generateAndRunCondition(condition, args) then
			TRP3_API.script.executeClassScript(scriptID, class.SC, args, campaignID);
		end
	end
end

local function clearCampaignHandlers()
	TRP3_API.Log("clearCampaignHandlers");
	campaignHandlers:Unregister();
	campaignHandlers:Clear();
	TRP3_API.quest.clearAllQuestHandlers();
end

local function registerCampaignHandler(campaignID, event)
	local source;

	if (CUSTOM_EVENTS[event.EV] ~= nil) then
		source = TRP3_Extended;
	else
		source = TRP3_API.GameEvents;
	end

	local function OnEventTriggered(_, ...)
		onCampaignCallback(campaignID, event.SC, event.CO, event.EV, ...);
	end

	campaignHandlers:RegisterCallback(source, event.EV, OnEventTriggered);
end

local function activateCampaignHandlers(campaignID, campaignClass)
	TRP3_API.Log("activateCampaignHandlers: " .. campaignID);
	for _, event in pairs(campaignClass.HA or EMPTY) do
		if event.EV and not pcall(registerCampaignHandler, campaignID, event) then
			Utils.message.displayMessage(TRP3_API.Colors.Red(loc.WO_EVENT_EX_UNKNOWN_ERROR:format(event.EV, campaignID)));
		end
	end
	-- Active handlers for known quests
	for questID, questClass in pairs(campaignClass.QE or EMPTY) do
		if playerQuestLog[campaignID].QUEST[questID] and playerQuestLog[campaignID].QUEST[questID].FI == nil then
			TRP3_API.quest.activateQuestHandlers(campaignID, questID, questClass);
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CAMPAIGN API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function deactivateCurrentCampaign(skipMessage)
	if playerQuestLog.currentCampaign then
		if not skipMessage then
			Utils.message.displayMessage(loc.QE_CAMPAIGN_PAUSE, Utils.message.type.CHAT_FRAME);
		end
		playerQuestLog.currentCampaign = nil;
		TRP3_Extended:TriggerEvent(TRP3_Extended.Events.ACTIVE_CAMPAIGN_CHANGED, nil);
	end
	-- refresh auras
	TRP3_API.extended.auras.refresh();
	clearCampaignHandlers();
end

TRP3_API.quest.deactivateCurrentCampaign = deactivateCurrentCampaign;

local function activateCampaign(campaignID, force)

	local oldCurrent = playerQuestLog.currentCampaign;

	-- First, deactivate current campaign
	deactivateCurrentCampaign(force);

	if not force and oldCurrent == campaignID then
		return;
	end

	if not TRP3_API.extended.classExists(campaignID) then
		TRP3_API.Log("Unknown campaignID, abord activateCampaign: " .. tostring(campaignID));
		return;
	end

	local campaignClass = getClass(campaignID);
	local _, campaignName = getClassDataSafe(campaignClass);

	local init = false;
	if not playerQuestLog[campaignID] then
		init = true;

		-- If not already started
		playerQuestLog[campaignID] = {
			NPC = {},
			QUEST = {}
		};
		Utils.message.displayMessage(loc.QE_CAMPAIGN_START:format(campaignName), Utils.message.type.CHAT_FRAME);
	else
		-- If already started, just resuming
		Utils.message.displayMessage(loc.QE_CAMPAIGN_RESUME:format(campaignName), Utils.message.type.CHAT_FRAME);
	end

	TRP3_API.Log("Activated campaign: " .. campaignID .. " with init at " .. tostring(init));
	activateCampaignHandlers(campaignID, campaignClass);

	playerQuestLog.currentCampaign = campaignID;

	-- refresh auras
	TRP3_API.extended.auras.refresh();

	if init then

		-- Initial script
		if campaignClass.LI and campaignClass.LI.OS then
			TRP3_API.script.executeClassScript(campaignClass.LI.OS, campaignClass.SC, { object = playerQuestLog[campaignID] }, campaignID);
		end

		for questID, quest in pairs(campaignClass.QE or EMPTY) do
			if quest.BA.IN then
				TRP3_API.quest.startQuest(campaignID, questID, init);
			end
		end

	end

	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.ACTIVE_CAMPAIGN_CHANGED, playerQuestLog.currentCampaign);
end

TRP3_API.quest.activateCampaign = activateCampaign;

local function resetCampaign(campaignID)
	TRP3_API.extended.auras.resetCampaignAuras(campaignID);
	if playerQuestLog[campaignID] then
		wipe(playerQuestLog[campaignID]);
		playerQuestLog[campaignID] = nil;
	end
	if playerQuestLog.currentCampaign == campaignID then
		activateCampaign(campaignID, true);
	end
	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.REFRESH_CAMPAIGN);
end

TRP3_API.quest.resetCampaign = resetCampaign;

local function getCurrentCampaignID()
	return playerQuestLog and playerQuestLog.currentCampaign;
end
TRP3_API.quest.getCurrentCampaignID = getCurrentCampaignID;

local function getCurrentCampaignClass()
	if getCurrentCampaignID() then
		return getClass(getCurrentCampaignID());
	end
end
TRP3_API.quest.getCurrentCampaignClass = getCurrentCampaignClass;

local function getActiveCampaignLog()
	return playerQuestLog and playerQuestLog.currentCampaign and playerQuestLog[playerQuestLog.currentCampaign];
end
TRP3_API.quest.getActiveCampaignLog = getActiveCampaignLog;

local function getCampaignVarStorage()
	local storage = playerQuestLog and playerQuestLog.currentCampaign and playerQuestLog[playerQuestLog.currentCampaign];
	if storage and storage.vars then
		return {object = storage};
	end
end
TRP3_API.quest.getCampaignVarStorage = getCampaignVarStorage;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.quest.campaignInit()
	local refreshQuestLog = function()
		playerQuestLog = TRP3_API.quest.getQuestLog();
	end
	TRP3_API.RegisterCallback(TRP3_Addon, Events.REGISTER_PROFILES_LOADED, refreshQuestLog);
	refreshQuestLog();

	-- Effect and operands
	TRP3_API.script.registerEffects(TRP3_API.quest.EFFECTS);

	-- Resuming last campaign
	if playerQuestLog.currentCampaign then
		TRP3_API.Log("Init campaign on launch: " .. playerQuestLog.currentCampaign);
		activateCampaign(playerQuestLog.currentCampaign, true); -- Force reloading the current campaign
	end

	TRP3_API.RegisterCallback(TRP3_Extended, TRP3_Extended.Events.REFRESH_CAMPAIGN, function()
		if getActiveCampaignLog() and not TRP3_API.extended.classExists(playerQuestLog.currentCampaign) then
			deactivateCurrentCampaign();
		end
		clearCampaignHandlers();
		if getCurrentCampaignClass() then
			activateCampaignHandlers(playerQuestLog.currentCampaign, getCurrentCampaignClass());
		end
	end);

	hooksecurefunc(C_ChatInfo, "PerformEmote", function(emote)
		TRP3_Extended:TriggerEvent(TRP3_Extended.Events.TRP3_EMOTE, emote);
	end);

	-- Helpers
	TRP3_API.slash.registerCommand({
		id = "debug_quest_step",
		helpLine = " " .. loc.DEBUG_QUEST_STEP,
		handler = function(questID, stepID)
			if questID and stepID then
				if getCurrentCampaignID() then
					TRP3_API.quest.goToStep(getCurrentCampaignID(), questID, stepID);
				end
			else
				Utils.message.displayMessage(loc.DEBUG_QUEST_STEP_USAGE);
			end
		end
	});
	TRP3_API.slash.registerCommand({
		id = "debug_quest_start",
		helpLine = " " .. loc.DEBUG_QUEST_START,
		handler = function(questID)
			if questID then
				if getCurrentCampaignID() then
					TRP3_API.quest.startQuest(getCurrentCampaignID(), questID);
				end
			else
				Utils.message.displayMessage(loc.DEBUG_QUEST_START_USAGE);
			end
		end
	});
end
