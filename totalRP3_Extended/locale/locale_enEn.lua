----------------------------------------------------------------------------------
-- Total RP 3
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

TRP3_EXTENDED_LOCALE = {};

TRP3_EXTENDED_LOCALE["enUS"] = {

	-- MISC
	EX_SOUND_HISTORY = "Sounds history",
	EX_SOUND_HISTORY_EMPTY = "No sound has been played.",
	EX_SOUND_HISTORY_LINE = "%s played soundID %s in channel %s.",
	EX_SOUND_HISTORY_STOP = "Stop",
	EX_SOUND_HISTORY_REPLAY = "Replay",
	EX_SOUND_HISTORY_CLEAR = "Clear",
	EX_SOUND_HISTORY_STOP_ALL = "Stop all",
	EX_SOUND_HISTORY_TT = "See what sounds have been played, see where they're from and stop them if they still are playing.",

	-- INVENTORY
	IT_CON = "Container",
	IT_CON_OPEN = "Open/Close container",
	IT_CON_CAN_INNER = "Can't place a container inside itself!",
	IT_INV_SHOW_ALL = "Show all inventory",
	IT_INV_SHOW_CONTENT = "Click: Show content",
	IT_INV_ERROR_MAX = "You can't carry any more of %s.",
	IT_INV_ERROR_FULL = "%s is full.",
	IT_INV_ERROR_CANT_HERE = "You can't place items here.",
	IT_INV_ERROR_CANT_DESTROY_LOOT = "You can't destroy loot items.",
	IT_CON_TT_MISSING_CLASS = "Missing item class ID",

	-- INVENTORY PAGE
	INV_PAGE_CAMERA_CONFIG = "Camera parameters:\nRotation: %.2f\nZoom: %.2f\nPosition: %.2f, %.2f",
	INV_PAGE_MARKER = "Marker position",
	INV_PAGE_PLAYER_INV = "%s's inventory",
	INV_PAGE_CHARACTER_INV = "Inventory",
	INV_PAGE_QUICK_SLOT = "Quick slot",
	INV_PAGE_QUICK_SLOT_TT = "This slot will be used as primary container.",
	INV_PAGE_ITEM_LOCATION = "Item location on character",

	-- LOOT
	LOOT = "Loot",
	LOOT_CONTAINER = "Loot container",

	-- Campaign
	QE_CAMPAIGN = "Campaign",
	QE_CAMPAIGNS = "Campaigns",
	QE_CAMPAIGN_LIST = "Available campaigns",
	QE_CAMPAIGN_START = "Starting campaign |cff00ff00[%s]|r.",
	QE_CAMPAIGN_START_BUTTON = "Start or resume campaign",
	QE_CAMPAIGN_RESUME = "Resuming campaign |cff00ff00[%s]|r.",
	QE_CAMPAIGN_RESET = "Reset campaign",
	QE_CAMPAIGN_PAUSE = "Pausing current campaign.",
	QE_CAMPAIGN_CURRENT = "Current campaign",
	QE_CAMPAIGN_CURRENT_NO = "No active campaign.",
	QE_CAMPAIGN_UNSTARTED = "You haven't started this campaign yet.\nClick on the campaign button to start it.",
	QE_CAMPAIGN_NOQUEST = "No quest revealed yet for this campaign.\nTake a look at the campaign description to unlock your first quest.",
	QE_QUEST_START = "Starting quest |cff00ff00[%s]|r.",
	QE_QUEST_TT_STEP = "|cffffff00Currently:|r\n\"%s\"",
	QE_QUEST_OBJ_AND_HIST = "Objectives and history",
	QE_QUEST = "Quest",
	QE_QUEST_OBJ_REVEALED = "|cffffff00New objective: |cff00ff00%s",
	QE_QUEST_OBJ_FINISHED = "|cffffff00Objective complete: |cff00ff00%s",
	QE_QUEST_LIST = "Quests for this campaign",
	QE_STEP = "Step",
	QE_STEP_LIST = "Steps for this quest",
	QE_STEP_LIST_CURRENT = "Current quests",
	QE_STEP_LIST_FINISHED = "Finished quests",
	QE_STEP_MISSING = "Missing step information.",

	-- COMMANDS
	COM_NPC_ID = " get targeted npc id",

	-- SETTINGS
	UNIT_FRIES = "fries",
	UNIT_POTATOES = "potatoes",
	CONF_MAIN = "Extended settings",
	CONF_UNIT = "Units",
	CONF_UNIT_WEIGHT = "Weight unit",
	CONF_UNIT_WEIGHT_TT = "Defines how weight values are displayed.",
	CONF_SOUNDS = "Local sounds / musics",
	CONF_SOUNDS_ACTIVE = "Play local sounds",
	CONF_SOUNDS_ACTIVE_TT = "Local sounds are sounds played by other players (for example through an item) to a certain range in yards.\n\nTurn this off if you don't want to hear these sounds at all.\n\n|cff00ff00Note that you will never hear sounds from ignored players.\n\n|cff00ff00Note that all sounds are interruptible via the Sound History in the TRP3 shortcuts bar.",
	CONF_SOUNDS_METHOD = "Local sound playback method",
	CONF_SOUNDS_METHOD_TT = "Determine how you will hear a local sound when you are in range.",
	CONF_SOUNDS_METHOD_1 = "Play automatically",
	CONF_SOUNDS_METHOD_1_TT = "If you are in range, it will play the sound/music without asking your permission.",
	CONF_SOUNDS_METHOD_2 = "Ask permission",
	CONF_SOUNDS_METHOD_2_TT = "If you are in range, a link will be placed in the chat frame to ask you confirmation to play the sound/music.",
	CONF_MUSIC_ACTIVE = "Play local musics",
	CONF_MUSIC_ACTIVE_TT = "Local musics are musics played by other players (for example through an item) to a certain range in yards.\n\nTurn this off if you don't want to hear these musics at all.\n\n|cff00ff00Note that you will never hear musics from ignored players.\n\n|cff00ff00Note that all musics are interruptible via the Sound History in the TRP3 shortcuts bar.",
	CONF_MUSIC_METHOD = "Local music playback method",
	CONF_MUSIC_METHOD_TT = "Determine how you will hear a local music when you are in range.",
	CONF_SOUNDS_MAXRANGE = "Playback maximum range",
	CONF_SOUNDS_MAXRANGE_TT = "Set the maximum range within which you will hear local sounds/musics.\n\n|cff00ff00Usefull to avoid people playing sounds through the whole contient.\n\n|cffff9900Zero means no limit!",
};