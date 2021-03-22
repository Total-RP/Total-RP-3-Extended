----------------------------------------------------------------------------------
-- Total RP 3: Campaign system
-- ---------------------------------------------------------------------------
-- Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
----------------------------------------------------------------------------------

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local CAMPAIGN_DB = TRP3_DB.campaign;
local EMPTY = TRP3_API.globals.empty;
local tostring, assert, pairs, wipe, tinsert = tostring, assert, pairs, wipe, tinsert;
local loc = TRP3_API.loc;
local Log = Utils.log;
local getClass, getClassDataSafe = TRP3_API.extended.getClass, TRP3_API.extended.getClassDataSafe;

-- Ellyb imports
local Ellyb = TRP3_API.Ellyb;

-- List of custom events for Extended
local CUSTOM_EVENTS = {
	TRP3_KILL = "TRP3_KILL",
	TRP3_ROLL = "TRP3_ROLL",
	TRP3_SIGNAL = "TRP3_SIGNAL",
	TRP3_ITEM_USED = "TRP3_ITEM_USED"
};

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

local campaignHandlers = {};

local function onCampaignCallback(campaignID, scriptID, condition, eventID, ...)
	local class = getClass(campaignID);
	if class and class.SC and class.SC[scriptID] then
		local payload = {...};
		if (eventID == "COMBAT_LOG_EVENT" or eventID == "COMBAT_LOG_EVENT_UNFILTERED") then
			payload = {CombatLogGetCurrentEventInfo()};	-- No payload for combat log events in 8.0
		end
		local args = { object = playerQuestLog[campaignID], event = payload };
		if TRP3_API.script.generateAndRunCondition(condition, args) then
			local retCode = TRP3_API.script.executeClassScript(scriptID, class.SC, args, campaignID);
		end
	end
end

local function clearCampaignHandlers()
	Log.log("clearCampaignHandlers", Log.level.DEBUG);

	for handlerID, eventID in pairs(campaignHandlers) do
		if (CUSTOM_EVENTS[eventID] ~= nil) then
			Events.unregisterCallback(handlerID);
		else
			Utils.event.unregisterHandler(handlerID);
		end
	end
	wipe(campaignHandlers);
	TRP3_API.quest.clearAllQuestHandlers();
end

local function registerCampaignHandler(campaignID, event)
	local handlerID;
	if (CUSTOM_EVENTS[event.EV] ~= nil) then
		handlerID = Events.registerCallback(event.EV, function(...)
			onCampaignCallback(campaignID, event.SC, event.CO, event.EV, ...);
		end);
	else
		handlerID = Utils.event.registerHandler(event.EV, function(...)
			onCampaignCallback(campaignID, event.SC, event.CO, event.EV, ...);
		end);
	end
	campaignHandlers[handlerID] = event.EV;
end

local function activateCampaignHandlers(campaignID, campaignClass)
	Log.log("activateCampaignHandlers: " .. campaignID, Log.level.DEBUG);
	for _, event in pairs(campaignClass.HA or EMPTY) do
		if event.EV and not pcall(registerCampaignHandler, campaignID, event) then
			Utils.message.displayMessage(Ellyb.ColorManager.RED(loc.WO_EVENT_EX_UNKNOWN_ERROR:format(event.EV, campaignID)));
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
	end
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
		Log.log("Unknown campaignID, abord activateCampaign: " .. tostring(campaignID), Log.level.WARNING);
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

	Log.log("Activated campaign: " .. campaignID .. " with init at " .. tostring(init), Log.level.DEBUG);
	activateCampaignHandlers(campaignID, campaignClass);

	playerQuestLog.currentCampaign = campaignID;

	if init then

		-- Initial script
		if campaignClass.LI and campaignClass.LI.OS then
			local retCode = TRP3_API.script.executeClassScript(campaignClass.LI.OS, campaignClass.SC, { object = playerQuestLog[campaignID] }, campaignID);
		end

		for questID, quest in pairs(campaignClass.QE or EMPTY) do
			if quest.BA.IN then
				TRP3_API.quest.startQuest(campaignID, questID, init);
			end
		end

	end
end

TRP3_API.quest.activateCampaign = activateCampaign;

local function resetCampaign(campaignID)
	if playerQuestLog[campaignID] then
		wipe(playerQuestLog[campaignID]);
		playerQuestLog[campaignID] = nil;
	end
	if playerQuestLog.currentCampaign == campaignID then
		activateCampaign(campaignID, true);
	end
	Events.fireEvent(TRP3_API.quest.EVENT_REFRESH_CAMPAIGN);
end

TRP3_API.quest.resetCampaign = resetCampaign;

local function getCurrentCampaignID()
	return playerQuestLog and playerQuestLog.currentCampaign;
end

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
	Events.listenToEvent(Events.REGISTER_PROFILES_LOADED, refreshQuestLog);
	refreshQuestLog();

	-- Effect and operands
	TRP3_API.script.registerEffects(TRP3_API.quest.EFFECTS);

	-- Resuming last campaign
	if playerQuestLog.currentCampaign then
		Log.log("Init campaign on launch: " .. playerQuestLog.currentCampaign, Log.level.DEBUG);
		activateCampaign(playerQuestLog.currentCampaign, true); -- Force reloading the current campaign
	end

	TRP3_API.quest.EVENT_REFRESH_CAMPAIGN = "EVENT_REFRESH_CAMPAIGN";
	Events.listenToEvent(TRP3_API.quest.EVENT_REFRESH_CAMPAIGN, function()
		if getActiveCampaignLog() and not TRP3_API.extended.classExists(playerQuestLog.currentCampaign) then
			deactivateCurrentCampaign();
		end
		clearCampaignHandlers();
		if getCurrentCampaignClass() then
			activateCampaignHandlers(playerQuestLog.currentCampaign, getCurrentCampaignClass());
		end
	end);

	-- Emote event (yes, I put it here because I'm the boss)
	TRP3_API.extended.EMOTE_EVENT = "TRP3_EMOTE";
	hooksecurefunc("DoEmote", function(emote, arg2, arg3)
		Events.fireEvent(TRP3_API.extended.EMOTE_EVENT, emote);
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
