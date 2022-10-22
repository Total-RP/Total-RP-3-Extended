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
local pairs, strjoin, tostring, strtrim, wipe, assert, strsplit = pairs, strjoin, tostring, strtrim, wipe, assert, strsplit;
local EMPTY = TRP3_API.globals.empty;
local loc = TRP3_API.loc;
local registerConfigKey = TRP3_API.configuration.registerConfigKey;
local Log = Utils.log;

TRP3_API.extended = {
	document = {},
	dialog = {},
};
TRP3_API.inventory = {};
TRP3_API.quest = {};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- GLOBAL DB
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_DB = {
	global = {},
	inner = {},
	types = {
		CAMPAIGN = "CA",
		QUEST = "QU",
		QUEST_STEP = "ST",
		ITEM = "IT",
		DOCUMENT = "DO",
		DIALOG = "DI",
	},
	modes = {
		QUICK = "QU",
		NORMAL = "NO",
		EXPERT = "EX",
	},
	elementTypes = {
		EFFECT = "list",
		CONDITION = "branch",
		DELAY = "delay"
	}
};



local missing = {
	missing = true,
	BA = {
		IC = "inv_misc_questionmark",
		NA = "|cffff0000MISSING CLASS",
		DE = "The information relative to this object are missing. It's possible the class was deleted or that it relies on a missing module.",
	}
}
TRP3_DB.missing = missing;

local DB = TRP3_DB.global;
local ID_SEPARATOR = " ";
TRP3_API.extended.ID_SEPARATOR = ID_SEPARATOR;
TRP3_API.extended.ID_EXCLUSION_PATTERN = "[^%w%_]";
TRP3_API.extended.ID_EXCLUSION_REPLACEMENT = "_";

function TRP3_API.extended.checkID(ID)
	return ID:lower():gsub(TRP3_API.extended.ID_EXCLUSION_PATTERN, TRP3_API.extended.ID_EXCLUSION_REPLACEMENT);
end

local function getFullID(...)
	return strtrim(strjoin(ID_SEPARATOR, ...));
end
TRP3_API.extended.getFullID = getFullID;

local function splitID(fullID)
	return strsplit(TRP3_API.extended.ID_SEPARATOR, fullID);
end
TRP3_API.extended.splitID = splitID;

local function getClass(...)
	local id = getFullID(...);
	local class = DB[id];
	if not class then
		Log.log("Unknown classID: " .. tostring(id));
	end
	return class or missing;
end
TRP3_API.extended.getClass = getClass;

function TRP3_API.extended.getRootTypeByID(id)
	local class = getClass(TRP3_API.extended.getRootClassID(id));
	return class.TY;
end

local function classExists(...)
	local id = getFullID(...);
	local class = DB[id];
	return class ~= nil;
end
TRP3_API.extended.classExists = classExists;

local function getRootClassID(classID)
	classID = classID or "";
	local find  = classID:find(ID_SEPARATOR);
	if find then
		return classID:sub(1, find - 1);
	end
	return classID;
end
TRP3_API.extended.getRootClassID = getRootClassID;

local function objectsAreRelated(classID1, classID2)
	local rootClassID1 = ({strsplit(TRP3_API.extended.ID_SEPARATOR, classID1)})[1];
	local rootClassID2 = ({strsplit(TRP3_API.extended.ID_SEPARATOR, classID2)})[1];
	return rootClassID1 == rootClassID2;
end
TRP3_API.extended.objectsAreRelated = objectsAreRelated;

local function getClassesByType(classType)
	local classes = {};
	for objectID, objectClass in pairs(DB) do
		if objectClass.TY == classType then
			classes[objectID] = objectClass;
		end
	end
	return classes;
end
TRP3_API.extended.getClassesByType = getClassesByType;

local function getClassDataSafe(class)
	local icon = "TEMP";
	local name = UNKNOWN;
	local description = "";
	if class and class.BA then
		if class.BA.IC then
			icon = class.BA.IC;
		end
		if class.BA.NA then
			name = class.BA.NA;
		end
		if class.BA.DE then
			description = class.BA.DE;
		elseif class.BA.TX then
			description = class.BA.TX;
		end
	end
	return icon, name, description;
end
TRP3_API.extended.getClassDataSafe = getClassDataSafe;

local function registerObject(objectFullID, object, count, registerTo)
	(registerTo or TRP3_DB.global)[objectFullID] = object;

	-- Inner object
	for childID, childClass in pairs(object.IN or EMPTY) do
		count = registerObject(getFullID(objectFullID, childID), childClass, count, registerTo);
	end

	-- Quest
	for childID, childClass in pairs(object.QE or EMPTY) do
		count = registerObject(getFullID(objectFullID, childID), childClass, count, registerTo);
	end

	-- Quest step
	for childID, childClass in pairs(object.ST or EMPTY) do
		count = registerObject(getFullID(objectFullID, childID), childClass, count, registerTo);
	end

	return count + 1;
end
TRP3_API.extended.registerObject = registerObject;

---
-- Unregister all objects and inner objects under the @objectFullID ID.
--
local function unregisterObject(objectFullID)
	assert(not objectFullID:find(ID_SEPARATOR), "Can only unregister a root id: " .. tostring(objectFullID));
	for id, _ in pairs(TRP3_DB.global) do
		if id == objectFullID or id:sub(1, objectFullID:len()) == objectFullID then
			TRP3_DB.global[id] = nil;
			Log.log("Unregistered: " .. id);
		end
	end
end
TRP3_API.extended.unregisterObject = unregisterObject;

local function removeObject(objectFullID)
	unregisterObject(objectFullID);
	if TRP3_DB.exchange[objectFullID] then
		wipe(TRP3_DB.exchange[objectFullID]);
		TRP3_DB.exchange[objectFullID] = nil;
		TRP3_Exchange_DB[objectFullID] = nil;
	elseif TRP3_Tools_DB[objectFullID] then
		wipe(TRP3_Tools_DB[objectFullID]);
		TRP3_DB.my[objectFullID] = nil;
		TRP3_Tools_DB[objectFullID] = nil;
	end
	Log.log("Removed object: " .. objectFullID);
	TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG);
	TRP3_API.events.fireEvent(TRP3_API.quest.EVENT_REFRESH_CAMPAIGN);
end
TRP3_API.extended.removeObject = removeObject;

local function iterateObject(objectID, object, callback)
	callback(objectID, object);

	-- Inner object
	for childID, childClass in pairs(object.IN or EMPTY) do
		iterateObject(childID, childClass, callback)
	end
	-- Quest
	for questID, quest in pairs(object.QE or EMPTY) do
		iterateObject(questID, quest, callback)
	end
	-- Steps
	for stepID, step in pairs(object.ST or EMPTY) do
		iterateObject(stepID, step, callback)
	end
end
TRP3_API.extended.iterateObject = iterateObject;

local function registerDB(db, count, registerTo)
	-- Register object
	for id, object in pairs(db or EMPTY) do
		count = registerObject(id, object, count, registerTo);
	end
	return count;
end
TRP3_API.extended.registerDB = registerDB;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CONFIG
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.extended.CONFIG_WEIGHT_UNIT = "extended_weight_unit";
TRP3_API.extended.WEIGHT_UNITS = {
	GRAMS = "g",
	POUNDS = "lb",
	POTATOES = "po",
};
TRP3_API.extended.CONFIG_SOUNDS_ACTIVE = "extended_sounds_active";
TRP3_API.extended.CONFIG_MUSIC_ACTIVE = "extended_music_active";
TRP3_API.extended.CONFIG_SOUNDS_METHOD = "extended_sounds_method";
TRP3_API.extended.CONFIG_MUSIC_METHOD = "extended_music_method";
TRP3_API.extended.CONFIG_SOUNDS_METHODS = {
	PLAY = "p",
	ASK_FOR_PERMISSION = "a",
};
TRP3_API.extended.CONFIG_SOUNDS_MAXRANGE = "extended_sounds_maxrange";

TRP3_API.extended.CONFIG_NPC_HIDE_ORIGINAL = "extended_tooltip_npc_hide_original";
TRP3_API.extended.CONFIG_NPC_EMBED_ORIGINAL = "extended_tooltip_npc_embed_original";

local function initConfig()
	local WEIGHT_UNIT_TAB = {
		{loc.CONF_UNIT_WEIGHT_1, TRP3_API.extended.WEIGHT_UNITS.GRAMS},
		{loc.CONF_UNIT_WEIGHT_2, TRP3_API.extended.WEIGHT_UNITS.POUNDS},
		{loc.CONF_UNIT_WEIGHT_3, TRP3_API.extended.WEIGHT_UNITS.POTATOES}
	}

	local SOUND_METHOD_TAB = {
		{loc.CONF_SOUNDS_METHOD_1, TRP3_API.extended.CONFIG_SOUNDS_METHODS.PLAY, loc.CONF_SOUNDS_METHOD_1_TT},
		{loc.CONF_SOUNDS_METHOD_2, TRP3_API.extended.CONFIG_SOUNDS_METHODS.ASK_FOR_PERMISSION, loc.CONF_SOUNDS_METHOD_2_TT},
	}

	-- Config default value
	registerConfigKey(TRP3_API.extended.CONFIG_WEIGHT_UNIT, TRP3_API.extended.WEIGHT_UNITS.GRAMS);

	registerConfigKey(TRP3_API.extended.CONFIG_SOUNDS_ACTIVE, true);
	registerConfigKey(TRP3_API.extended.CONFIG_SOUNDS_METHOD, TRP3_API.extended.CONFIG_SOUNDS_METHODS.PLAY);
	registerConfigKey(TRP3_API.extended.CONFIG_MUSIC_ACTIVE, true);
	registerConfigKey(TRP3_API.extended.CONFIG_MUSIC_METHOD, TRP3_API.extended.CONFIG_SOUNDS_METHODS.ASK_FOR_PERMISSION);
	registerConfigKey(TRP3_API.extended.CONFIG_SOUNDS_MAXRANGE, 100);

	registerConfigKey(TRP3_API.extended.CONFIG_NPC_HIDE_ORIGINAL, true);
	registerConfigKey(TRP3_API.extended.CONFIG_NPC_EMBED_ORIGINAL, false);


	-- Build configuration page
	local CONFIG_STRUCTURE = {
		id = "main_config_extended",
		menuText = loc.CONF_MAIN,
		pageText = loc.CONF_MAIN,
		elements = {
			{
				inherit = "TRP3_ConfigH1",
				title = loc.CONF_UNIT,
			},
			{
				inherit = "TRP3_ConfigDropDown",
				widgetName = "TRP3_ConfigurationExtended_Units_Weight",
				title = loc.CONF_UNIT_WEIGHT,
				listContent = WEIGHT_UNIT_TAB,
				configKey = TRP3_API.extended.CONFIG_WEIGHT_UNIT,
				listCancel = true,
				help = loc.CONF_UNIT_WEIGHT_TT
			},
			{
				inherit = "TRP3_ConfigH1",
				title = loc.CONF_SOUNDS,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc.CONF_SOUNDS_ACTIVE,
				configKey = TRP3_API.extended.CONFIG_SOUNDS_ACTIVE,
				help = loc.CONF_SOUNDS_ACTIVE_TT,
			},
			{
				inherit = "TRP3_ConfigDropDown",
				widgetName = "TRP3_ConfigurationExtended_Sounds_Methods",
				title = loc.CONF_SOUNDS_METHOD,
				listContent = SOUND_METHOD_TAB,
				configKey = TRP3_API.extended.CONFIG_SOUNDS_METHOD,
				listCancel = true,
				help = loc.CONF_SOUNDS_METHOD_TT
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc.CONF_MUSIC_ACTIVE,
				configKey = TRP3_API.extended.CONFIG_MUSIC_ACTIVE,
				help = loc.CONF_MUSIC_ACTIVE_TT,
			},
			{
				inherit = "TRP3_ConfigDropDown",
				widgetName = "TRP3_ConfigurationExtended_MUSIC_Methods",
				title = loc.CONF_MUSIC_METHOD,
				listContent = SOUND_METHOD_TAB,
				configKey = TRP3_API.extended.CONFIG_MUSIC_METHOD,
				listCancel = true,
				help = loc.CONF_MUSIC_METHOD_TT
			},
			{
				inherit = "TRP3_ConfigSlider",
				title = loc.CONF_SOUNDS_MAXRANGE,
				help = loc.CONF_SOUNDS_MAXRANGE_TT,
				configKey = TRP3_API.extended.CONFIG_SOUNDS_MAXRANGE,
				min = 0,
				max = 200,
				step = 10,
				integer = true,
			},
			{
				inherit = "TRP3_ConfigH1",
				title = loc.CONF_NPC_TOOLTIP,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc.CONF_NPC_HIDE_ORIGINAL,
				configKey = TRP3_API.extended.CONFIG_NPC_HIDE_ORIGINAL,
			},
			{
				inherit = "TRP3_ConfigCheck",
				title = loc.CONF_NPC_EMBED_ORIGINAL,
				configKey = TRP3_API.extended.CONFIG_NPC_EMBED_ORIGINAL,
				help = loc.CONF_NPC_EMBED_ORIGINAL_TT,
				dependentOnOptions = { TRP3_API.extended.CONFIG_NPC_HIDE_ORIGINAL },
			},
		}
	};
	TRP3_API.configuration.registerConfigurationPage(CONFIG_STRUCTURE);
end

function TRP3_API.extended.isObjectMine(ID)
	return TRP3_DB.my[ID] ~= nil;
end

function TRP3_API.extended.isObjectExchanged(ID)
	return TRP3_DB.exchange[ID] ~= nil;
end

function TRP3_API.extended.isObjectBackers(ID)
	return TRP3_DB.inner[ID] ~= nil;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local BAG_SOUNDS_MAPPING = {
	IT_DR_SOUND_1200 = "IT_PU_SOUND_1183",
	IT_DR_SOUND_1201 = "IT_PU_SOUND_1184",
	IT_DR_SOUND_1202 = "IT_PU_SOUND_1185",
	IT_DR_SOUND_1203 = "IT_PU_SOUND_1186",
	IT_DR_SOUND_1204 = "IT_PU_SOUND_1221",
	IT_DR_SOUND_1205 = "IT_PU_SOUND_1187",
	IT_DR_SOUND_1206 = "IT_PU_SOUND_1188",
	IT_DR_SOUND_1207 = "IT_PU_SOUND_1190",
	IT_DR_SOUND_1208 = "IT_PU_SOUND_1189",
	IT_DR_SOUND_1209 = "IT_PU_SOUND_1192",
	IT_DR_SOUND_1210 = "IT_PU_SOUND_1193",
	IT_DR_SOUND_1211 = "IT_PU_SOUND_1194",
	IT_DR_SOUND_1212 = "IT_PU_SOUND_1195",
	IT_DR_SOUND_1213 = "IT_PU_SOUND_1191",
	IT_DR_SOUND_1214 = "IT_PU_SOUND_1196",
	IT_DR_SOUND_1215 = "IT_PU_SOUND_1197",
	IT_DR_SOUND_1216 = "IT_PU_SOUND_1199",
	IT_DR_SOUND_1217 = "IT_PU_SOUND_1198",
}

local function onInit()
	Globals.addon_name_me = Globals.addon_name_extended;

	if not TRP3_Tools_DB then
		TRP3_Tools_DB = {};
	end
	TRP3_DB.my = TRP3_Tools_DB;

	if not TRP3_Exchange_DB then
		TRP3_Exchange_DB = {};
	end
	TRP3_DB.exchange = TRP3_Exchange_DB;

	-- Register locales
	for _, localeStructure in pairs(TRP3_API.loc:GetLocales()) do
		for key, field in pairs(BAG_SOUNDS_MAPPING) do
			if localeStructure:GetText(field) then
				localeStructure:AddText(key, localeStructure:GetText(field))
			end
		end
	end

	if not TRP3_Security then
		TRP3_Security = {
			global = {}; -- Effect group: keys are effectgroupID, value boolean
			specific = {}; -- Specific effect for a specific classID
			sender = {}; -- keys are classID, values are senderID
			whitelist = {}; -- Keys are senderID, value boolean
		};
	end

	-- Applying patches to saved variables
	TRP3_API.extended.flyway.applyPatches();
end

local function onStart()

	-- Signal
	TRP3_API.extended.SIGNAL_PREFIX = "EXSI";
	TRP3_API.extended.SIGNAL_EVENT = "TRP3_SIGNAL";
	AddOn_TotalRP3.Communications.registerSubSystemPrefix(TRP3_API.extended.SIGNAL_PREFIX, function(arg, sender)
		if sender ~= Globals.player_id then
			Log.log(("Received signal from %s"):format(sender));
			Events.fireEvent(TRP3_API.extended.SIGNAL_EVENT, arg.i, arg.v, sender);
		end
	end);
	function TRP3_API.extended.sendSignal(id, value)
		if UnitExists("target") and UnitIsPlayer("target") then
			if UnitIsUnit("player", "target") then
				Log.log("Received signal from yourself");
				Events.fireEvent(TRP3_API.extended.SIGNAL_EVENT, id, value, Utils.str.getUnitID("player"));
			else
				TRP3_API.communication.sendObject(TRP3_API.extended.SIGNAL_PREFIX, {i = id, v = value}, Utils.str.getUnitID("target"));
			end
		end
	end

	-- Calculate global environement with all ids
	local countInner, countExchange, countMy;
	countInner = registerDB(TRP3_DB.inner, 0);
	Log.log(("Registred %s inner ceations"):format(countInner));
	countExchange = registerDB(TRP3_DB.exchange, 0);
	Log.log(("Registred %s exchange ceations"):format(countExchange));
	countMy = registerDB(TRP3_DB.my, 0);
	Log.log(("Registred %s my ceations"):format(countMy));
	Log.log(("Registred %s total ceations"):format(countInner + countExchange + countMy));

	-- Start other systems
	TRP3_API.security.initSecurity();
	TRP3_CastingBarFrame.init();
	TRP3_SoundsHistoryFrame.initSound();
	TRP3_API.inventory.onStart();
	TRP3_API.quest.onStart();
	TRP3_API.extended.document.onStart();
	TRP3_API.extended.dialog.onStart();

	-- Config
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_FINISH, initConfig);

	-- Simplier combat kill event
	TRP3_API.extended.KILL_EVENT = "TRP3_KILL";
	Utils.event.registerHandler("COMBAT_LOG_EVENT_UNFILTERED", function()
		local _, event, _, source, sourceName, _, _, dest, destName = CombatLogGetCurrentEventInfo();	-- No payload for combat log events in 8.0
		if event == "PARTY_KILL" then
			local unitType, NPC_ID = Utils.str.getUnitDataFromGUIDDirect(dest);
			if (unitType == "Player") then
				local className, classID, raceName, raceID, gender = GetPlayerInfoByGUID(dest);
				Events.fireEvent(TRP3_API.extended.KILL_EVENT, unitType, source, sourceName, dest, destName, classID, className, raceID, raceName, gender);
			else
				Events.fireEvent(TRP3_API.extended.KILL_EVENT, unitType, source, sourceName, dest, destName, NPC_ID);
			end
		end
	end);

    local dashboard = TRP3_Dashboard;
    dashboard.extendedlogo = dashboard:CreateTexture("TRP3DashboardLogoExtended", "ARTWORK");
    dashboard.extendedlogo:SetAllPoints(TRP3_DashboardLogo);
    dashboard.extendedlogo:SetTexture("Interface\\AddOns\\totalRP3_Extended\\resources\\extendedlogooverlay");
end

Globals.extended_version = 1033;
Globals.required_trp3_build = 107;

--@debug@
Globals.extended_display_version = "v-dev";
--@end-debug@

--[===[@non-debug@
Globals.extended_display_version = "@project-version@";
--@end-non-debug@]===]

if TRP3_API.globals.version < Globals.required_trp3_build then
	print(TRP3_API.Ellyb.ColorManager.RED([[

The Total RP 3: Extended version you have installed (%s) requires a newer version of the main Total RP 3 add-on.

Please download the latest version of Total RP 3 using the Twitch app or by manually downloading it on Curse at http://curse.totalrp.com.
]]):format(Utils.str.sanitizeVersion(Globals.extended_display_version)));
end

local MODULE_STRUCTURE = {
	["name"] = "Extended",
	["description"] = "Total RP 3 extended features: inventory, quest log, document and more!",
	["version"] = Globals.extended_version,
	["id"] = "trp3_extended",
	["onInit"] = onInit,
	["onStart"] = onStart,
	["minVersion"] = Globals.required_trp3_build,
};

TRP3_API.module.registerModule(MODULE_STRUCTURE);
