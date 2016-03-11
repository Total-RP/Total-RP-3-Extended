----------------------------------------------------------------------------------
-- Total RP 3
--	---------------------------------------------------------------------------
--	Copyright 2015-2016 Sylvain Cossement (telkostrasz@totalrp3.info)
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

TRP3_EXTENDED_TOOL_LOCALE = {};

TRP3_EXTENDED_TOOL_LOCALE["enUS"] = {

	-- TOOLBAR BUTTON
	TB_TOOLS = "Open Extended tools",
	TB_TOOLS_TT = "Create your own items and quests.",

	-- TYPES
	TYPE_CAMPAIGN = "Campaign",
	TYPE_QUEST = "Quest",
	TYPE_QUEST_STEP = "Quest step",
	TYPE_ITEM = "Item",
	TYPE_LOOT = "Loot",
	TYPE_DOCUMENT = "Document",
	TYPE_DIALOG = "Cutscene",

	-- MODES
	MODE_QUICK = "Quick",
	MODE_NORMAL = "Normal",
	MODE_EXPERT = "Expert",

	-- DATABASE
	DB = "Database",
	DB_MY = "My database (%s)",
	DB_OTHERS = "Players database (%s)",
	DB_BACKERS = "Backers database (%s)",
	DB_FULL = "Full database (%s)",
	DB_LIST = "Creations list",
	DB_FILTERS = "Creations filters",
	DB_ACTIONS = "Actions",

	DB_MY_EMPTY = "You don't have created any object yet.\nUse one of the buttons below to unleash your creativity!",
	DB_OTHERS_EMPTY = "Here will be placed all objects created by other players.\nExchange objects with others or import a packageg using the button below!",
	DB_CREATE_ITEM = "Create item",
	DB_CREATE_ITEM_TT = "Select a template for a new item",
	DB_CREATE_ITEM_TEMPLATES = "Or select a template",
	DB_CREATE_ITEM_TEMPLATES_QUICK = "Quick creation",
	DB_CREATE_ITEM_TEMPLATES_QUICK_TT = "Quickly creates a simple item without any effect.\nThen adds one unit of this item in your primary bag.",
	DB_CREATE_ITEM_TEMPLATES_DOCUMENT = "Document item",
	DB_CREATE_ITEM_TEMPLATES_DOCUMENT_TT = "A item template with an attached document.\nUseful to quickly create a book or a scroll.",
	DB_CREATE_ITEM_TEMPLATES_BLANK = "Blank item",
	DB_CREATE_ITEM_TEMPLATES_BLANK_TT = "A blank template.\nFor those who like to start from scratch.",
	DB_CREATE_ITEM_TEMPLATES_CONTAINER = "Container item",
	DB_CREATE_ITEM_TEMPLATES_CONTAINER_TT = "A container template.\nContainer can hold other items.",

	DB_CREATE_CAMPAIGN = "Create campaign",
	DB_CREATE_CAMPAIGN_TT = "Start creating a campaign",

	-- Creation
	ROOT_TITLE = "Root object",
	ROOT_ID = "ID",
	ROOT_VERSION = "Version",
	ROOT_CREATED = "Created by %s on %s",
	ROOT_SAVED = "Last modification by %s on %s",
	SPECIFIC_INNER_ID = "Inner ID",
	SPECIFIC_PATH = "Root path",
	SPECIFIC_MODE = "Mode",
	SPECIFIC = "Specific object",

	-- Editor common
	EDITOR_PREVIEW = "preview",
	EDITOR_ICON_SELECT = "Click to select an icon.",

	-- Item creation
	IT_NEW_NAME = "New item",
	IT_QUICK_EDITOR = "Quick item creation",
	IT_QUICK_EDITOR_EDIT = "Quick item edition",
	IT_CONVERT_TO_NORMAL = "Convert to normal mode",
	IT_DISPLAY_ATT = "Display attributes",
	IT_GAMEPLAY_ATT = "Gameplay attributes",
	IT_FIELD_QUALITY = "Item quality",
	IT_FIELD_NAME = "Item name",
	IT_FIELD_NAME_TT = "It's your item name.",
	IT_TT_LEFT = "Tooltip custom left text",
	IT_TT_LEFT_TT = "It's a free text that will be in the tooltip, bellow the item name.",
	IT_TT_RIGHT = "Tooltip custom right text",
	IT_TT_RIGHT_TT = "It's a free text that will be in the tooltip, right to the left text.",
	IT_TT_DESCRIPTION = "Tooltip description",
	IT_TT_DESCRIPTION_TT = "It's your item description.",
	IT_TT_REAGENT = "Crafting reagent flag",
	IT_TT_REAGENT_TT = "Shows the \"Crafting reagent\" line in the tooltip.",
	IT_TT_VALUE = "Item value",
	IT_TT_VALUE_FORMAT = "Item value (in %s)",
	IT_TT_VALUE_TT = "This value will be informed on the tooltip extension (hold alt) or during transactions.",
	IT_TT_WEIGHT = "Item weight",
	IT_TT_WEIGHT_FORMAT = "Item weight (in grams)",
	IT_TT_WEIGHT_TT = "The weight influence the total weight of the container.",
};