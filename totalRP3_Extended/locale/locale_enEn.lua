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
	IT_EX_DOWNLOAD = "Download",
	IT_EX_DOWNLOAD_TT = "|cffff9900This item is %s messages long and would take at minimum %.1f seconds to be downloaded (in the best condition).\n\n|cff00ff00Click to requests %s to send you all the data about this item.\n\n|cffff9900You can't finish a trade if you don't have all the updated information about all items you would receive.",
	IT_EX_EMPTY_DRAG = "You can drag and drop items here.",
	IT_EX_EMPTY = "Nothing to trade",
	IT_EX_SLOT_DOWNLOAD = "|rYou don't have the information about this item.\n\n|cff00ff00If the item is not too large, TRP3 will download it automatically from %s.\n\n|cffff9900If it is too large, you can manually request its information with the download button, but keep in mind that it could take some time to be downloaded.",
	IT_EX_DOWNLOADING = "Downloading: %0.1f %%",
	IT_CON_ERROR_TYPE = "This container can't contain this kind of items.",

	-- INVENTORY PAGE
	INV_PAGE_CAMERA_CONFIG = "Camera parameters:\nRotation: %.2f\nZoom: %.2f\nPosition: %.2f, %.2f",
	INV_PAGE_MARKER = "Marker position",
	INV_PAGE_PLAYER_INV = "%s's inventory",
	INV_PAGE_CHARACTER_INV = "Inventory",
	INV_PAGE_QUICK_SLOT = "Quick slot",
	INV_PAGE_QUICK_SLOT_TT = "This slot will be used as primary container.",
	INV_PAGE_ITEM_LOCATION = "Item location on character",

	-- SEC
	SEC_LEVEL = "Security level",
	SEC_LEVEL_DETAIL = "Click to see a detail of the used unsecured scripts.",
	SEC_LEVEL_DETAIL2 = "Click to see a detail of the used unsecured scripts and configure which one can be executed.",
	SEC_LOW = "Low",
	SEC_LOW_TT = "This item, or one of its related object, uses one or more unsecured scripts that can have malicious effects.",
	SEC_MEDIUM = "Medium",
	SEC_MEDIUM_TT = "This item, or one of its related object, uses one or more unsecured scripts that can have undesirable effects.",
	SEC_HIGH = "High",
	SEC_HIGH_TT = "This item and all of its related object are secured and don't use any malicious or undesirable effects.",
	SEC_LEVEL_DETAILS = "Security details",
	SEC_LEVEL_DETAILS_TT = "For %s and all its inner objects",
	SEC_LEVEL_DETAILS_SECURED = "This object and all its inner objects are secured!",
	SEC_UNSECURED_WHY = "Why is this unsecured?",
	SEC_REASON_TALK = "Character talk",
	SEC_REASON_TALK_WHY = "This object could force your character to say something (through /say, /yell or any other channel).\n\n|cffff0000It may be used in a malicious way to force you so say something reprehensible by the Blizzard terms of services that can make you banned from the game.\n\n|cff00ff00If blocked, the text will be printed only for you (and not said by your character).",
	SEC_REASON_SOUND = "Playing a sound",
	SEC_REASON_SOUND_WHY = "This object could play a sound or a music that will be heard by the TRP3:E users around you.\n\n|cffff9900It may be undesirable for them if the sound is spammed or if the sound is particulary annoying. And if it's the case, they could blame you and block you.\n\n|cff00ff00If blocked, the sound/music will be played only for you.",
	SEC_REASON_DISMOUNT = "Dismount",
	SEC_REASON_DISMOUNT_WHY = "This object could force you to unmount.\n\n|cffff9900It may be undesirable for you... Especially if you are on a flying mount!",
	SEC_LEVEL_DETAILS_REMIND = "Remember my choices for future version of this object",
	SEC_LEVEL_DETAILS_THIS = "Accept for this objects",
	SEC_LEVEL_DETAILS_THIS_TT = "Accept the execution of this effect for this object only.",
	SEC_LEVEL_DETAILS_ALL = "Accept for all objects",
	SEC_LEVEL_DETAILS_ALL_TT = "Accept the execution of this effect for all objects, now and in the future.",
	SEC_LEVEL_DETAILS_BLOCKED = "Blocked",
	SEC_LEVEL_DETAILS_ACCEPTED = "Accepted",
	SEC_LEVEL_DETAILS_FROM = "Always accept when received from %s",
	SEC_EFFECT_BLOCKED = "Effect(s) blocked",
	SEC_EFFECT_BLOCKED_TT = "Due to your corrent security settings, at least one of this item (or sub-item) effects is blocked.",
	SEC_MISSING_SCRIPT = "Cannot find script \"%s\"",

	-- LOOT
	LOOT = "Loot",
	LOOT_CONTAINER = "Loot container",

	-- DOCUMENT
	DOC_UNKNOWN_ALERT = "Can't open the document. (Missing class)",
	DO_PAGE_FIRST = "First page",
	DO_PAGE_NEXT = "Next page",
	DO_PAGE_LAST = "Last page",
	DO_PAGE_PREVIOUS = "Previous page",

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
	CONF_UNIT_WEIGHT_1 = "Grams",
	CONF_UNIT_WEIGHT_2 = "Pounds",
	CONF_UNIT_WEIGHT_3 = "Potatoes",
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
	CONF_SOUNDS_MAXRANGE_TT = "Set the maximum range (in yards) within which you will hear local sounds/musics.\n\n|cff00ff00Usefull to avoid people playing sounds through the whole contient.\n\n|cffff9900Zero means no limit!",
};