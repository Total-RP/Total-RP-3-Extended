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
	DB_ADD_ITEM = "Add to inventory",
	DB_CREATE_CAMPAIGN = "Create campaign",
	DB_CREATE_CAMPAIGN_TT = "Start creating a campaign",

	-- Creation
	ROOT_TITLE = "Root object",
	ROOT_ID = "ID",
	ROOT_VERSION = "Version",
	ROOT_CREATED = "Created by %s on %s",
	ROOT_CREATED_BY = "Created by",
	ROOT_CREATED_ON = "Created on",
	ROOT_SAVED = "Last modification by %s on %s",
	SPECIFIC_INNER_ID = "Inner ID",
	SPECIFIC_PATH = "Root path",
	SPECIFIC_MODE = "Mode",
	SPECIFIC = "Specific object",

	-- Editor common
	EDITOR_PREVIEW = "preview",
	EDITOR_ICON_SELECT = "Click to select an icon.",
	EDITOR_NOTES = "Free notes",
	EDITOR_MAIN = "Main",
	EDITOR_CONFIRM = "Confirm",

	-- Item creation
	IT_NEW_NAME = "New item",
	IT_QUICK_EDITOR = "Quick item creation",
	IT_QUICK_EDITOR_EDIT = "Quick item edition",
	IT_CONVERT_TO_NORMAL = "Convert to normal mode",
	IT_CONVERT_TO_NORMAL_TT = "You are in quick mode, an easy first approach to create a simple item.\n\nYou can go further and edit this item in normal mode. This will bring you more possibilities but it's also more complex to learn and use.\n\n|cffff9900Warning: if you convert this item to normal mode, you can't revert it back to quick mode.",
	IT_DISPLAY_ATT = "Display attributes",
	IT_GAMEPLAY_ATT = "Gameplay attributes",
	IT_FIELD_QUALITY = "Item quality",
	IT_FIELD_NAME = "Item name",
	IT_FIELD_NAME_TT = "It's your item name, as it will appear on the tooltip or in item links in the chat frame.",
	IT_TT_LEFT = "Tooltip left custom text",
	IT_TT_LEFT_TT = "It's a free text that will be in the tooltip, bellow the item name.\n\n|cff00ff00A good example of information to put there is the item type (Armor, clothe, weapon, potion ...).",
	IT_TT_RIGHT = "Tooltip right custom text",
	IT_TT_RIGHT_TT = "It's a free text that will be in the tooltip, right to the left custom text.\n\n|cff00ff00A good example of information to put there would be a precision of the item type you put in the left custom text.\n\nFor example if you put Armor as left custom text you could precise here Helmet or Gloves.",
	IT_TT_DESCRIPTION = "Tooltip description",
	IT_TT_DESCRIPTION_TT = "It's your item description.\n\n|cff00ff00It shouldn't be a wall of text here, try to stay concise.\n\nIf your item is usable, try to give hints here to how it should be used.",
	IT_TT_REAGENT = "Crafting reagent flag",
	IT_TT_REAGENT_TT = "Shows the \"Crafting reagent\" line in the tooltip.\n\n|cffff7700Like others display attributes, it's just a visual flag and it's not required for your item to really be a crafting reagent.",
	IT_QUEST = "Quest flag",
	IT_QUEST_TT = "Adds a marker to the item icon to indicates that using this item should start a quest.\n\n|cffff7700Like others display attributes, it's just a visual flag and it's not required for your item to really be able to start a quest.",
	IT_TT_VALUE = "Item value",
	IT_TT_VALUE_FORMAT = "Item value (in %s)",
	IT_TT_VALUE_TT = "This value will be informed on the tooltip extension (hold alt) or during transactions.\n\n|cffff7700If you think that this item is invaluable, please leave 0. Zero doesn't mean that is has no value, it means that the value is undefined.",
	IT_TT_WEIGHT = "Item weight",
	IT_TT_WEIGHT_FORMAT = "Item weight (in grams)",
	IT_TT_WEIGHT_TT = "The weight influence the total weight of the container.\n\n|cffff7700Please enter the value in GRAMS, as it will be converted to the user selected unit on display.",
	IT_SOULBOUND_TT = "This item will be bound to the player when put on his inventory and cannot be exchanged or dropped on the ground.",
	IT_UNIQUE_TT = "When active, the maximum item units that can be possessed by a character will be limited.",
	IT_UNIQUE_COUNT = "Max units",
	IT_UNIQUE_COUNT_TT = "Sets the maximum units that a character can possessed. Should be greater than 0.",
	IT_CRAFTED = "Crafted",
	IT_CRAFTED_TT = "When a unit of this item will be added to your bag or created by another item, it will indicates you as creator in the tooltip.",
	IT_STACK = "Stackable",
	IT_STACK_TT = "Allow units for this item to be stacked in a same container slot.",
	IT_STACK_COUNT = "Max units per stack",
	IT_STACK_COUNT_TT = "Sets the maximum units that can be stacked in a same container slot. Should be greated than 1.",
	IT_USE = "Usable",
	IT_ON_USE = "On use",
	IT_ON_USE_TT = "This workflow will be triggered when the player uses this item.",
	IT_USE_TT = "Allow this item to be usable.\n\n|cff00ff00You can configure the item use effect in the 'On use' tab of this editor.",
	IT_USE_TEXT = "Usage text",
	IT_USE_TEXT_TT = "This text, explaining the effect for using this item, will appears in the tooltip.",
	IT_WEARABLE = "Wearable",
	IT_WEARABLE_TT = "Allow this item to be placed on your character.",
	IT_CONTAINER_TT = "Sets this item to be a container. Container can hold other items.\n\n|cff00ff00The container can be configured in the 'Container' tab of this editor.",
	IT_CO_DURABILITY = "Durability",
	IT_CO_DURABILITY_TT = "Determine the overall max health for your container. A container can lose health over time or can be damaged. But it can also be repaired with the proper items.\n\n|cff00ff00Zero means invulnerable.",
	IT_CO_MAX = "Max weight (in grams)",
	IT_CO_MAX_TT = "This sets the limit of weight from where your container will start losing helth over time due to overweight.\n\n|cff00ff00Zero means no limit.\n\n|cffff9900Please enter the max weight in GRAMS.",

	-- Workflows
	WO_WORKFLOW = "Workflows",
	WO_EXECUTION = "Workflow execution",
	WO_EMPTY = "You can start by adding an element to your workflow.\nThis can be an effect, a condition or a delay.",
	WO_ADD = "Add element to workflow",
	WO_END = "End of workflow",
	WO_ELEMENT = "Element edition",
	WO_ELEMENT_EDIT = "Click to edit element",
	WO_EFFECT = "Effect",
	WO_EFFECT_TT = "Plays an effect.\nIt can be playind sounds, displaying text ...etc",
	WO_EFFECT_SELECT = "Select an effect",
	WO_EFFECT_CAT_COMMON = "Common",
	WO_EFFECT_NO_EDITOR = "This effect can't be configured.",
	WO_CONDITION = "Condition",
	WO_CONDITION_TT = "Evaluates a condition.\nStops the workflow if the condition fails.",
	WO_DELAY = "Delay",
	WO_DELAY_TT = "Pauses the workflow.\nCan also be used as a cast and can be interrupt.",
	WO_DELAY_WAIT = "Waits for",
	WO_DELAY_SECONDS = "second(s)",
	WO_ELEMENT_TYPE = "Select the element type",
	WO_SECURITY = "Security level",
	WO_SECURITY_HIGH = "High",
	WO_SECURITY_HIGH_DETAILS = "This effect is secured and will not prompt security warning.",
	WO_SECURITY_NORMAL = "Normal",
	WO_SECURITY_NORMAL_DETAILS = "This effect is not secured and could be malicious. It will prompt security warning, based on the user security settings.",
	WO_SECURITY_LOW = "Low",
	WO_SECURITY_LOW_DETAILS = "This effect is not secured and could be malicious. It will prompt security warning, based on a more severe user security settings.",

	-- Delay editor
	WO_DELAY_DURATION = "Duration",
	WO_DELAY_DURATION_TT = "The duration for this delay, in seconds.",
	WO_DELAY_TYPE = "Delay type",
	WO_DELAY_TYPE_1 = "Regular delay",
	WO_DELAY_INTERRUPT = "Interruption",
	WO_DELAY_INTERRUPT_1 = "No interruption",

	-- Effects editors
	EFFECT_TEXT = "Display text",
	EFFECT_TEXT_TT = "Displays a text.\nDifferent outputs are possible.",
	EFFECT_TEXT_PREVIEW = "Will display",
	EFFECT_TEXT_TEXT = "Text",
	EFFECT_TEXT_TEXT_DEFAULT = "Your text",
	EFFECT_TEXT_TEXT_TT = "The text to display.",
	EFFECT_TEXT_TYPE = "Text type",
	EFFECT_TEXT_TYPE_1 = "Chat frame text",
	EFFECT_TEXT_TYPE_2 = "Alert popup",
	EFFECT_TEXT_TYPE_3 = "Raid alert text",
	EFFECT_TEXT_TYPE_4 = "Alert message",
};