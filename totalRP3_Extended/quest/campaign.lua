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
local loc = TRP3_API.locale.getText;
local Log = Utils.log;
local getClass, getClassDataSafe = TRP3_API.extended.getClass, TRP3_API.extended.getClassDataSafe;

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

local function onCampaignCallback(campaignID, scriptID, condition, ...)
	local class = getClass(campaignID);
	if class and class.SC and class.SC[scriptID] then
		local args = { object = playerQuestLog[campaignID], event = {...} };
		if TRP3_API.script.generateAndRunCondition(condition, args) then
			local retCode = TRP3_API.script.executeClassScript(scriptID, class.SC, args, campaignID);
		end
	end
end

local function clearCampaignHandlers()
	Log.log("clearCampaignHandlers", Log.level.DEBUG);

	for handlerID, _ in pairs(campaignHandlers) do
		Utils.event.unregisterHandler(handlerID);
	end
	wipe(campaignHandlers);
	TRP3_API.quest.clearAllQuestHandlers();
end

local function activateCampaignHandlers(campaignID, campaignClass)
	Log.log("activateCampaignHandlers: " .. campaignID, Log.level.DEBUG);
	for _, event in pairs(campaignClass.HA or EMPTY) do
		local handlerID = Utils.event.registerHandler(event.EV, function(...)
			onCampaignCallback(campaignID, event.SC, event.CO, ...);
		end);
		campaignHandlers[handlerID] = event.EV;
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
			Utils.message.displayMessage(loc("QE_CAMPAIGN_PAUSE"), Utils.message.type.CHAT_FRAME);
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
		Utils.message.displayMessage(loc("QE_CAMPAIGN_START"):format(campaignName), Utils.message.type.CHAT_FRAME);
	else
		-- If already started, just resuming
		Utils.message.displayMessage(loc("QE_CAMPAIGN_RESUME"):format(campaignName), Utils.message.type.CHAT_FRAME);
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

local function getCurrentCampaignClass()
	if playerQuestLog and playerQuestLog.currentCampaign then
		return getClass(playerQuestLog.currentCampaign);
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
	Events.registerEvent(TRP3_API.quest.EVENT_REFRESH_CAMPAIGN);
	Events.listenToEvent(TRP3_API.quest.EVENT_REFRESH_CAMPAIGN, function()
		if getActiveCampaignLog() and not TRP3_API.extended.classExists(playerQuestLog.currentCampaign) then
			deactivateCurrentCampaign();
		end
		clearCampaignHandlers();
		if getCurrentCampaignClass() then
			activateCampaignHandlers(playerQuestLog.currentCampaign, getCurrentCampaignClass());
		end
	end);
end