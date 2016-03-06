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
local pairs, strjoin, tostring, strtrim = pairs, strjoin, tostring, strtrim;
local EMPTY = TRP3_API.globals.empty;
local getConfigValue, registerConfigKey, registerHandler = TRP3_API.configuration.getValue, TRP3_API.configuration.registerConfigKey, TRP3_API.configuration.registerHandler;
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
		LOOT = "LO",
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

local DB = TRP3_DB.global;
local ID_SEPARATOR = " ";
TRP3_API.extended.ID_SEPARATOR = ID_SEPARATOR;

local function getFullID(...)
	return strtrim(strjoin(ID_SEPARATOR, ...));
end
TRP3_API.extended.getFullID = getFullID;

local function getClass(...)
	local id = getFullID(...);
	local class = DB[id];
	if not class then
		Log.log("Unknown classID: " .. tostring(id));
	end
	return class or missing;
end
TRP3_API.extended.getClass = getClass;

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
		end
	end
	return icon, name, description;
end
TRP3_API.extended.getClassDataSafe = getClassDataSafe;

local function registerObject(objectFullID, object, count)
	TRP3_DB.global[objectFullID] = object;

	-- Inner object
	for childID, childClass in pairs(object.IN or EMPTY) do
		count = registerObject(getFullID(objectFullID, childID), childClass, count);
	end

	return count + 1;
end
TRP3_API.extended.registerObject = registerObject;

local function registerDB(db, count)
	-- Register object
	for id, object in pairs(db or EMPTY) do
		count = registerObject(id, object, count);
		-- Quests
		for questID, quest in pairs(object.QE or EMPTY) do
			count = registerObject(getFullID(id, questID), quest, count);
			-- Steps
			for stepID, step in pairs(quest.ST or EMPTY) do
				count = registerObject(getFullID(id, questID, stepID), step, count);
			end
		end
	end
	return count;
end

local function unregisterObject(objectFullID)
	for id, _ in pairs(TRP3_DB.global) do
		if id == objectFullID or id:sub(1, objectFullID:len()) == objectFullID then
			TRP3_DB.global[id] = nil;
		end
	end
	TRP3_DB.exchange[objectFullID] = nil;
	TRP3_Exchange_DB[objectFullID] = nil;
	(TRP3_DB.my or EMPTY)[objectFullID] = nil;
	(TRP3_Tools_DB or EMPTY)[objectFullID] = nil;
end
TRP3_API.extended.unregisterObject = unregisterObject;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onInit()
	if not TRP3_Exchange_DB then
		TRP3_Exchange_DB = {};
	end
	TRP3_DB.exchange = TRP3_Exchange_DB;
end

local function onStart()

	-- Register locales
	for localeID, localeStructure in pairs(TRP3_EXTENDED_LOCALE) do
		local locale = TRP3_API.locale.getLocale(localeID);
		for localeKey, text in pairs(localeStructure) do
			locale.localeContent[localeKey] = text;
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
	TRP3_API.inventory.onStart();
	TRP3_API.quest.onStart();
	TRP3_API.extended.document.onStart();
	TRP3_API.extended.dialog.onStart();

	-- Config
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_FINISH, function()

		local CONFIG_WEIGHT_UNIT = "extended_weight_unit";
		local WEIGHT_UNITS = {
			GRAMS = "g",
			POUNDS = "p",
		};
		local WEIGHT_UNIT_TAB = {
			{"Grams", WEIGHT_UNITS.GRAMS},
			{"Pounds", WEIGHT_UNITS.POUNDS}
		}

		-- Config default value
		registerConfigKey(CONFIG_WEIGHT_UNIT, WEIGHT_UNITS.GRAMS);

		-- Build configuration page
		local CONFIG_STRUCTURE = {
			id = "main_config_extended",
			menuText = "Extended settings",
			pageText = "Extended settings",
			elements = {
				{
					inherit = "TRP3_ConfigH1",
					title = "Units",
				},
				{
					inherit = "TRP3_ConfigDropDown",
					widgetName = "TRP3_ConfigurationExtended_Units_Weight",
					title = "Weight units",
					listContent = WEIGHT_UNIT_TAB,
					configKey = CONFIG_WEIGHT_UNIT,
					listCancel = true,
					help = "Defines how weight values are displayed. It will be converted from grams."
				}
			}
		};
		TRP3_API.configuration.registerConfigurationPage(CONFIG_STRUCTURE);
	end);
end

local MODULE_STRUCTURE = {
	["name"] = "Extended",
	["description"] = "Total RP 3 extended features: inventory, quest log, document and more !",
	["version"] = 1.000,
	["id"] = "trp3_extended",
	["onInit"] = onInit,
	["onStart"] = onStart,
	["minVersion"] = 12,
};

TRP3_API.module.registerModule(MODULE_STRUCTURE);