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

	NEW_EXTENDED_VERSION = "|cffff9900A new version for TRP3:Extended is available (%s). |cff00ff00Go check it out on Curse!",

	-- MISC
	EX_SOUND_HISTORY = "Sounds history",
	EX_SOUND_HISTORY_EMPTY = "No sound has been played.",
	EX_SOUND_HISTORY_LINE = "%s played soundID %s in channel %s.",
	EX_SOUND_HISTORY_STOP = "Stop",
	EX_SOUND_HISTORY_REPLAY = "Replay",
	EX_SOUND_HISTORY_CLEAR = "Clear",
	EX_SOUND_HISTORY_STOP_ALL = "Stop all",
	EX_SOUND_HISTORY_TT = "See what sounds have been played, see where they're from and stop them if they still are playing.\n\n|cffffff00Click:|r Open sound history\n|cffffff00Right-click:|r Stop all sounds/musics",
	BINDING_NAME_TRP3_INVENTORY = "Open character's inventory",
	BINDING_NAME_TRP3_MAIN_CONTAINER = "Open main container",
	BINDING_NAME_TRP3_SEARCH_FOR_ITEMS = "Search for items",
	BINDING_NAME_TRP3_QUESTLOG = "Open TRP3's quest log",
	BINDING_NAME_TRP3_QUEST_LOOK = "Quest action: inspect",
	BINDING_NAME_TRP3_QUEST_LISTEN = "Quest action: listen",
	BINDING_NAME_TRP3_QUEST_ACTION = "Quest action: interact",
	BINDING_NAME_TRP3_QUEST_TALK = "Quest action: talk",
	ERROR_MISSING_ARG = "Missing argument %1$s when trying to call function %2$s.",

	-- INVENTORY
	IT_CON = "Container",
	IT_CON_TT = "Container (%d/%d slots used)",
	IT_CON_ERROR_TYPE = "This container can't contain this kind of items.",
	IT_CON_ERROR_TRADE = "You can't drop this container if it's not empty.",
	IT_CON_OPEN = "Open/Close container",
	IT_CON_CAN_INNER = "Can't place a container inside itself!",
	IT_INV_SHOW_ALL = "Show all inventory",
	IT_INV_SHOW_CONTENT = "|cffffff00Click:|r Open main container (if exists)\n|cffffff00Right-click:|r Open inventory",
	IT_INV_ERROR_MAX = "You can't carry any more of %s.",
	IT_INV_ERROR_FULL = "%s is full.",
	IT_INV_ERROR_CANT_HERE = "You can't place items here.",
	IT_INV_ERROR_CANT_DESTROY_LOOT = "You can't destroy loot items.",
    IT_INV_SCAN_MY_ITEMS = "Scan for my items",
	IT_CON_TT_MISSING_CLASS = "Missing item class ID",
	IT_EX_DOWNLOAD = "Download",
	IT_EX_DOWNLOAD_TT = "|cffff9900This item is %s messages long and would take at minimum %.1f seconds to be downloaded (in the best condition).\n\n|cff00ff00Click to requests %s to send you all the data about this item.\n\n|cffff9900You can't finish a trade if you don't have all the updated information about all items you would receive.",
	IT_EX_EMPTY_DRAG = "You can drag and drop items here.",
	IT_EX_EMPTY = "Nothing to trade",
	IT_EX_SLOT_DOWNLOAD = "|rYou don't have the information about this item.\n\n|cff00ff00If the item is not too large, TRP3 will download it automatically from %s.\n\n|cffff9900If it is too large, you can manually request its information with the download button, but keep in mind that it could take some time to be downloaded.",
	IT_EX_DOWNLOADING = "Downloading: %0.1f %%",
	IT_LOOT_ERROR = "Can't display loot right now, another loot is currently shown.",
	IT_INV_GOT = "Received: %s x%d",

	-- INVENTORY PAGE
	INV_PAGE_CAMERA_CONFIG = "Camera parameters:\n   Rotation: %.2f",
	INV_PAGE_MARKER = "Marker position:\n   x: %.2f\n   y: %.2f",
	INV_PAGE_PLAYER_INV = "%s's inventory",
	INV_PAGE_CHARACTER_INV = "Inventory",
	INV_PAGE_INV_OPEN = "Open inventory",
	INV_PAGE_LOOT_ALL = "Loot all",
	INV_PAGE_QUICK_SLOT = "Quick slot",
	INV_PAGE_QUICK_SLOT_TT = "This slot will be used as primary container.",
	INV_PAGE_ITEM_LOCATION = "Item location on character",
	INV_PAGE_TOTAL_VALUE = "Total items value",
	INV_PAGE_TOTAL_VALUE_TT = "This is the value of your inventory.\n\nThis is not the amount of \"coins\" but the estimated total value of all items in the inventory.",
	INV_PAGE_CHARACTER_INSPECTION = "Character inspection",
	INV_PAGE_CHARACTER_INSPECTION_TT = "Inspect this character's inventory.",
	INV_PAGE_WEAR_TT = "This item is wearable.\nThe green zone indicates the item location on the character.",
	INV_PAGE_WEAR_ACTION = "Configure item location",
	INV_PAGE_WEAR_ACTION_RESET = "Reset configuration",
	INV_PAGE_SEQUENCE = "Sequence ID",
	INV_PAGE_WAIT = "Waiting for response",
	INV_PAGE_SEQUENCE_TT = "You can change the pose of your character by entering an animation ID here and select the animation frame with the slider below.\n\nWarning: If the animation flickers it's because there is a problem with the animation for your race model. If it happens, please select another animation.",
	INV_PAGE_SEQUENCE_PRESET = "You can select a sequence ID corresponding to an emote.",
	INV_PAGE_EDIT_ERROR1 = "You must be the author of this item to edit it.",
	INV_PAGE_EDIT_ERROR2 = "This item is not in Quick mode.",

	-- SEC
	SEC_LEVEL = "Security level",
	SEC_LEVEL_DETAIL = "Click to see a detail of the used unsecure scripts.",
	SEC_LEVEL_DETAIL2 = "Click to see a detail of the used unsecure scripts and configure which one can be executed.",
	SEC_LOW = "Low",
	SEC_LOW_TT = "This item, or one of its related object, uses one or more unsecure scripts that can have malicious effects.",
	SEC_MEDIUM = "Medium",
	SEC_MEDIUM_TT = "This item, or one of its related object, uses one or more unsecure scripts that can have undesirable effects.",
	SEC_HIGH = "High",
	SEC_HIGH_TT = "This item and all of its related object are secured and don't use any malicious or undesirable effects.",
	SEC_LEVEL_DETAILS = "Security details",
	SEC_LEVEL_DETAILS_TT = "For %s and all its inner objects.\n|cffff9900Made by: |cff00ff00%s\n|cffff9900Received from: |cff00ff00%s",
	SEC_LEVEL_DETAILS_SECURED = "This object and all its inner objects are secure!",
	SEC_UNSECURED_WHY = "Why is this unsecure?",
	SEC_REASON_SCRIPT = "Lua script",
	SEC_REASON_SCRIPT_WHY = "This object could trigger any of the Extended effects.\n\n|cffff0000It may be used in a malicious way to force you so say something reprehensible by the Blizzard terms of services that can make you banned from the game.\n\n|cff00ff00If blocked, the code will still be executed but in a secured environment (for instance, chat effects will be printed only for you and not said by your character).",
	SEC_REASON_TALK = "Character talk",
	SEC_REASON_TALK_WHY = "This object could force your character to say something (through /say, /yell or any other channel).\n\n|cffff0000It may be used in a malicious way to force you so say something reprehensible by the Blizzard terms of services that can make you banned from the game.\n\n|cff00ff00If blocked, the text will be printed only for you (and not said by your character).",
	SEC_REASON_SOUND = "Playing a sound",
	SEC_REASON_SOUND_WHY = "This object could play a sound or a music that will be heard by the TRP3:E users around you.\n\n|cffff9900It may be undesirable for them if the sound is spammed or if the sound is particulary annoying. And if it's the case, they could blame you and block you.\n\n|cff00ff00If blocked, the sound/music will be played only for you.",
	SEC_REASON_DISMOUNT = "Dismount",
	SEC_REASON_DISMOUNT_WHY = "This object could force you to unmount.\n\n|cffff9900It may be undesirable for you... Especially if you are on a flying mount!",
	SEC_LEVEL_DETAILS_THIS = "Switch security for this objects",
	SEC_LEVEL_DETAILS_THIS_TT = "Accept the execution of this effect for this object only.",
	SEC_LEVEL_DETAILS_ALL = "Switch security for all objects",
	SEC_LEVEL_DETAILS_ALL_TT = "Accept the execution of this effect for all objects, now and in the future.",
	SEC_LEVEL_DETAILS_BLOCKED = "Blocked",
	SEC_LEVEL_DETAILS_ACCEPTED = "Accepted",
	SEC_LEVEL_DETAILS_FROM = "Always accept when received from %s",
	SEC_EFFECT_BLOCKED = "Effect(s) blocked",
	SEC_EFFECT_BLOCKED_TT = "Due to your current security settings, at least one of this item (or sub-objects) effects has been secured.\n\n|cffff9900Click to review security for this item.\n\nYou can also Ctrl+Right-click on the item in your inventory to configure the security later.",
	SEC_MISSING_SCRIPT = "Cannot find workflow \"%s\"",
	SEC_SCRIPT_ERROR = "Error in workflow %s.",
	SEC_TT_COMBO = "Alt + Right click:|cffff9900 Configure security",
	SET_TT_SECURED = "Some potentially malicious effects have been secured for your safety.\n|cff00ff00Alt + Right click for more details.",
	SET_TT_DETAILS_1 = "Hold Alt key to show more",
	SET_TT_DETAILS_2 = "%s warning(s)",
	SET_TT_OLD = "This item has been created with an older version of Extended (v %s). Incompatibilities may occured.",

	-- LOOT
	LOOT = "Loot",
	LOOT_CONTAINER = "Loot container",
	LOOT_DISTANCE = "You moved too far from the loot point.",

	-- DOCUMENT
	DOC_UNKNOWN_ALERT = "Can't open the document. (Missing class)",
	DO_PAGE_FIRST = "First page",
	DO_PAGE_NEXT = "Next page",
	DO_PAGE_LAST = "Last page",
	DO_PAGE_PREVIOUS = "Previous page",
	DO_EMPTY = "Empty document",

	-- Campaign
	QE_CAMPAIGN = "Campaign",
	QE_CAMPAIGNS = "Campaigns",
	QE_CAMPAIGN_LIST = "%s available campaigns",
	QE_CAMPAIGN_START = "Starting campaign |cff00ff00[%s]|r.",
	QE_CAMPAIGN_START_BUTTON = "Start or resume campaign",
	QE_CAMPAIGN_RESUME = "Resuming campaign |cff00ff00[%s]|r.",
	QE_CAMPAIGN_RESET = "Reset campaign",
	QE_CAMPAIGN_PAUSE = "Pausing current campaign.",
	QE_CAMPAIGN_CURRENT = "Current campaign",
	QE_CAMPAIGN_CURRENT_NO = "No active campaign.",
	QE_CAMPAIGN_UNSTARTED = "You haven't started this campaign yet.\nClick on the top right \"Start\" button to start it.",
	QE_CAMPAIGN_NOQUEST = "No quest revealed yet for this campaign.\nTake a look at the campaign description to unlock your first quest.",
	QE_CAMPAIGN_EMPTY = "This campaign has no quest.",
	QE_QUEST_START = "Starting quest |cff00ff00[%s]|r.",
	QE_QUEST_TT_STEP = "|cffffff00Currently:|r\n\"%s\"",
	QE_QUEST_OBJ_AND_HIST = "Objectives and history",
	QE_QUEST = "Quest",
	QE_QUESTS = "Quests",
	QE_QUEST_OBJ_REVEALED = "|cffffff00New objective: |cff00ff00%s",
	QE_QUEST_OBJ_UPDATED = "|cffffff00Objective updated: |cff00ff00%s",
	QE_QUEST_OBJ_FINISHED = "|cffffff00Objective complete: |cff00ff00%s",
	QE_QUEST_LIST = "Quests for this campaign",
	QE_STEP = "Step",
	QE_STEP_LIST = "Steps for this quest",
	QE_STEP_LIST_CURRENT = "Available quests",
	QE_STEP_LIST_FINISHED = "Finished quests",
	QE_STEP_MISSING = "Missing step information.",
	QE_BUTTON = "Open quest log",
	QE_NPC = "Campaign NPC",
	QE_RESET_CONFIRM = "Reset this campaign?\n\nThis will lose all your progression for ALL the quests in this campaign.\n\nNote that you will keep all items you gained through this campaign.",
	QE_AUTORESUME_CONFIRM = "An effect was called for the campaign |cff00ff00[%s]|r.\n\nActivate this campaign ?\n(If you already have an active campaign, it will be paused and your progress will be saved.)",
	QE_ACTIONS_TYPE_LOOK = "Inspect",
	QE_ACTIONS_TYPE_TALK = "Talk",
	QE_ACTIONS_TYPE_LISTEN = "Listen",
	QE_ACTIONS_TYPE_INTERRACT = "Interact",
	QE_NOACTION_LOOK = "You don't see anything special.",
	QE_NOACTION_LISTEN = "You don't hear anything special.",
	QE_NOACTION_ACTION = "There is nothing to do.",
	QE_NOACTION_TALK = "There is nothing to say.",
	QE_PREVIOUS_STEP = "Previously",
	QE_OVERVIEW = "Quest overview",
	QE_COMPLETED = "Completed",
	QE_FAILED = "Failed",
	QE_NEW = "New quest revealed",
	QE_ACTION = "Quest action",
	QE_MACRO = "Create macro",
	QE_MACRO_TT = "Creates a macro for this action type and pickup the macro on your cursor to be placed in any action bars.",
	QE_MACRO_MAX = "You can't have more macro. Please free a macro slot before trying again.",
	QE_PROGRESS = "Campaign progression",
	DI_NEXT = "Next",
	DI_WAIT_LOOT = "Please loot all items",
	QE_ACTION_NO_CURRENT = "You don't have any active campaign. You should activate a campaign before trying to do an action..",
	QE_CAMPAIGN_NO = "No started yet",
	QE_CAMPAIGN_FULL = "Finished",

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

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- SPEECH
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	NPC_SAYS = "says",
	NPC_YELLS = "yells",
	NPC_WHISPERS = "whispers",
	NPC_EMOTES = "emotes",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- DROP SYSTEM
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	DR_SYSTEM = "Drop system",
	DR_SYSTEM_TT = "Drop / search for items and create / access your stashes.\n\nThe drop system does not work in dungeons/arenas/battlegrounds.",
	DR_POPUP = "Drop here",
	DR_POPUP_ASK = "Total RP 3\n \nSelect what to do with the item:\n%s",
	DR_POPUP_REMOVE = "Destroy",
	DR_POPUP_REMOVE_TEXT = "Destroy this item?",
	DR_SEARCH_BUTTON = "Search for |cff00ff00my|r items",
	DR_SEARCH_BUTTON_TT = "Search for your items in the area within 15 yards.",
	DR_NOTHING = "No items found in this area.",
	DR_DELETED = "Destroyed: %s x%d",
	DR_DROPED = "Droped on the ground: %s x%d",
	DR_RESULTS = "Found %s items",
	DR_STASHES = "Stashes",
	DR_STASHES_CREATE = "Create a stash here",
	DR_STASHES_CREATE_TT = "Create a stash where you stand.",
	DR_STASHES_EDIT = "Edit stash",
	DR_STASHES_REMOVE = "Remove stash",
	DR_STASHES_REMOVE_PP = "Remove this stash?\n|cffff9900All items still inside will be lost!",
	DR_STASHES_NAME = "Stash",
	DR_STASHES_MAX = "max 50 characters",
	DR_STASHES_WITHIN = "|cff00ff00Your|r stashes within 15 yards",
	DR_STASHES_SEARCH = "Search for |cff00ff00players|r stashes",
	DR_STASHES_SEARCH_TT = "Search for stashes from other players in the area within 15 yards.\n\nIt will launch a scan for 3 seconds, stand still!",
	DR_STASHES_SCAN_MY = "Scan for my stashes",
	DR_STASHES_SCAN = "Scan for players stashes",
	DR_STASHES_TOO_FAR = "You are too far from this stash.",
	DR_STASHES_REMOVED = "Stash removed.",
	DR_STASHES_FULL = "This stash is full.",
	DR_STASHED = "Stashed: %s x%d",
	DR_STASHES_FOUND = "Stashes found: %s",
	DR_STASHES_NOTHING = "No stashes found in this area.",
	DR_STASHES_SYNC = "Synchronizing...",
	DR_STASHES_RESYNC = "Resynchronize",
	DR_STASHES_ERROR_SYNC = "Stash is not synced.",
	DR_STASHES_ERROR_OUT_SYNC = "Stash out of sync, please retry.",
	DR_STASHES_DROP = "You can't drop item in someone else's stash.",
	DR_STASHES_HIDE = "Hide from scan",
	DR_STASHES_HIDE_TT = "This stash won't appear on other players map scan.\n\nNote that they will always be able to access it if they know where it is.",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- EXTENDED TOOLS
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- TOOLBAR BUTTON
	TB_TOOLS = "Extended objects database",
	TB_TOOLS_TT = "Create your own items and quests.",

	-- TYPES
	ALL = "All",
	TYPE = "Type",
	TYPE_CAMPAIGN = "Campaign",
	TYPE_QUEST = "Quest",
	TYPE_QUEST_STEP = "Quest step",
	TYPE_ITEM = "Item",
	TYPE_LOOT = "Loot",
	TYPE_DOCUMENT = "Document",
	TYPE_DIALOG = "Cutscene",
	TYPE_ITEMS = "Item(s)",

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
	DB_RESULTS = "Search results",
	DB_FILTERS = "Search filters",
	DB_FILTERS_OWNER = "Created by",
	DB_FILTERS_NAME = "Object name",
	DB_ACTIONS = "Actions",
	DB_WARNING = "\n|cffff0000!!! Warning !!!\n\n|cffff9900Don't forget to save your changes before returning to the database list!",
	DB_FILTERS_CLEAR = "Clear",
	DB_BROWSER = "Object browser",
	DB_DELETE_TT = "Removes this object and all its children objects.",
	DB_EXPERT_TT = "Switchs this object to expert mode, allowing more complex customizations.",
	DB_SECURITY_TT = "Shows all security parameters for this object. From there you can allow or prevent certain undesirable effects.",
	DB_ADD_ITEM_TT = "Adds units of this item in your primary container (or main inventory if you don't have any primary container on your character).",
	DB_COPY_ID_TT = "Display the object ID in a popup to be copy/pastable.",
	DB_COPY_TT = "Copy all this object information and child objects to be pastable as inner objects in another object.",
	DB_EXPORT = "Quick export object",
	DB_EXPORT_TT = "Serializes the object content to be exchangeable outside the game.\n\nOnly works on small objects (lesser than 20 kB once serialized). For larger object, use the full export feature.",
	DB_EXPORT_TOO_LARGE = "This object is too large once serialized to be exported this way. Please use the full export feature.\n\nSize: %0.1f kB.",
	DB_EXPORT_HELP = "Code for object %s (size: %0.1f kB)",
	DB_IMPORT = "Quick object import",
	DB_IMPORT_TT = "Paste here a previously serialized object",
	DB_IMPORT_WORD = "Import",
	DB_IMPORT_ERROR1 = "The object could not be deserialized.",
	DB_IMPORT_CONFIRM = "This object was serialized in a different version of Total RP 3 Extended than yours.\n\nImport TRP3E version: %s\nYour TRP3E version: %s\n\n|cffff9900This can lead to incompatibilities.\nContinue the import anyway?",
	DB_IMPORT_VERSION = "You are importing an older version of this object than the version you already have.\n\nImport version: %s\nYour version: %s\n\n|cffff9900Do you confirm you want to downgrade?",
	DB_LOCALE = "Object locale",
	DB_FULL_EXPORT = "Full export",
	DB_FULL_EXPORT_TT = "Make a full export for this object regardless of its size.\n\nThis will trigger a UI reload in order to force the writing of add-on save file.",
	DB_EXPORT_MODULE_NOT_ACTIVE = "Object full export/import: Please enable the totalRP3_Extended_ImpExport add-on first.",
	DB_EXPORT_DONE = "Your object has been exported in the file called |cff00ff00totalRP3_Extended_ImpExport.lua|r in this game directory:\n\nWorld of Warcraft\\WTF\\\naccount\\YOUR_ACCOUNT\\SavedVariables\n\nYou can share this file with your friends!\n\nThey can follow the import process in the |cff00ff00Full Database tab|r.",
	DB_IMPORT_FULL = "Full objects import",
	DB_IMPORT_FULL_TT = "Import the |cff00ff00totalRP3_Extended_ImpExport.lua|r file.",
	DB_IMPORT_EMPTY = "There is no object to import in your |cff00ff00totalRP3_Extended_ImpExport.lua|r file.\n\nThe file must be placed in this game directory |cffff9900prior to the game launch|r:\n\nWorld of Warcraft\\WTF\\\naccount\\YOUR_ACCOUNT\\SavedVariables",
	DB_IMPORT_DONE = "Object successfully imported!",
	DB_BACKERS_LIST = "Credits",

	DB_MY_EMPTY = "You don't have created any object yet.\nUse one of the buttons below to unleash your creativity!",
	DB_OTHERS_EMPTY = "Here will be placed all objects created by other players.",
	DB_CREATE_ITEM = "Create item",
	DB_CREATE_ITEM_TT = "Select a template for a new item",
	DB_CREATE_ITEM_TEMPLATES = "Or select a template",
	DB_CREATE_ITEM_TEMPLATES_QUICK = "Quick creation",
	DB_CREATE_ITEM_TEMPLATES_QUICK_TT = "Quickly creates a simple item without any effect.\nThen adds one unit of this item in your primary bag.",
	DB_CREATE_ITEM_TEMPLATES_DOCUMENT = "Document item",
	DB_CREATE_ITEM_TEMPLATES_DOCUMENT_TT = "An item template with an inner document object.\nUseful to quickly create a book or a scroll.",
	DB_CREATE_ITEM_TEMPLATES_BLANK = "Blank item",
	DB_CREATE_ITEM_TEMPLATES_BLANK_TT = "A blank template.\nFor those who like to start from scratch.",
	DB_CREATE_ITEM_TEMPLATES_CONTAINER = "Container item",
	DB_CREATE_ITEM_TEMPLATES_CONTAINER_TT = "A container template.\nContainer can hold other items.",
	DB_CREATE_ITEM_TEMPLATES_FROM = "Create from ...",
	DB_CREATE_ITEM_TEMPLATES_FROM_TT = "Create a copy of an existing item.",
	DB_ADD_ITEM = "Add to main inventory",
	DB_TO_EXPERT = "Convert to expert mode",
	DB_CREATE_CAMPAIGN = "Create campaign",
	DB_CREATE_CAMPAIGN_TT = "Start creating a campaign",
	DB_REMOVE_OBJECT_POPUP = "Please confirm the removal of the object:\nID: |cff00ffff\"%s\"|r\n|cff00ff00[%s]|r\n\n|cffff9900Warning: This action cannot be reverted!.",
	DB_ADD_COUNT = "How many units of %s do you want to add to your inventory?",
	DB_IMPORT_ITEM = "Import item",
	DB_HARD_SAVE = "Hard save",
	DB_HARD_SAVE_TT = "Reload the game UI in order to force saved variables to be written on the disk.",
	DB_IMPORT_FULL_CONFIRM = "Do you want to import the following object?\n\n%s\n%s\nBy |cff00ff00%s|r\nVersion %s",

	-- Creation
	ROOT_TITLE = "Root object",
	ROOT_ID = "Object ID",
	ROOT_GEN_ID = "Generated ID",
	ROOT_VERSION = "Version",
	ROOT_CREATED = "Created by %s on %s",
	ROOT_CREATED_BY = "Created by",
	ROOT_CREATED_ON = "Created on",
	ROOT_SAVED = "Last modification by %s on %s",
	SPECIFIC_INNER_ID = "Inner ID",
	SPECIFIC_PATH = "Root path",
	SPECIFIC_MODE = "Mode",
	SPECIFIC = "Specific object",
	ITEM_ID = "Item ID",
	QUEST_ID = "Quest ID",

	-- Editor common
	EDITOR_MORE = "More",
	EDITOR_PREVIEW = "Preview",
	EDITOR_ICON_SELECT = "Click to select an icon.",
	EDITOR_NOTES = "Free notes",
	EDITOR_MAIN = "Main",
	EDITOR_CONFIRM = "Confirm",
	EDITOR_SAVE_TT = "Save all changes to the whole object %s (root object and all inner objects) and automatically increments the version number.",
	EDITOR_CANCEL_TT = "Cancel all changes to the whole object %s (root object and all inner objects).\n\n|cffff9900Unsaved changes will be lost!",
	EDITOR_ID_COPY = "Copy ID",
	EDITOR_ID_COPY_POPUP = "You can copy the object ID below if you need to paste it somewhere.",
	EDITOR_WARNINGS = "There are %s warnings.\n\n|cffff9900%s|r\n\nSave anyway?",
	EDITOR_TOP = "Top",
	EDITOR_BOTTOM = "Bottom",
	EDITOR_WIDTH = "Width",
	EDITOR_HEIGHT = "Height",
	EDITOR_ICON = "Select icon",

	-- Item creation
	IT_CAST = "Casting",
	IT_NEW_NAME = "New item",
	IT_NEW_NAME_CO = "New container",
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
	IT_TT_VALUE_TT = "This value will be informed on the tooltip extension (hold Alt) or during transactions.\n\n|cffff7700If you think that this item is invaluable, please leave 0. Zero doesn't mean that is has no value, it means that the value is undefined.",
	IT_TT_WEIGHT = "Item weight",
	IT_TT_WEIGHT_FORMAT = "Item weight (in grams)",
	IT_TT_WEIGHT_TT = "The weight influence the total weight of the container.\n\n|cffff7700Please enter the value in GRAMS, as it will be converted to the user selected unit on display.",
	IT_SOULBOUND_TT = "This item will be bound to the player when put on his inventory and cannot be exchanged or dropped on the ground.",
	IT_UNIQUE_TT = "When active, the maximum item units that can be possessed by a character will be limited.",
	IT_UNIQUE_COUNT = "Max units",
	IT_UNIQUE_COUNT_TT = "Sets the maximum units that a character can possessed. Should be greater than 0.",
	IT_CRAFTED = "Crafted",
	IT_CRAFTED_TT = "A crafted item will display in the tooltip the name of the player who crafted it. The player who craft the item is the player making the action of creating one instance of this item, manually or through a workflow.",
	IT_STACK = "Stackable",
	IT_STACK_TT = "Allow units for this item to be stacked in a same container slot.",
	IT_STACK_COUNT = "Max units per stack",
	IT_STACK_COUNT_TT = "Sets the maximum units that can be stacked in a same container slot. Should be greated than 1.",
	IT_USE = "Usable",
	IT_ON_USE = "On use",
	IT_ON_USE_TT = "This workflow will be triggered when the player uses this item.\n\n|cffff9900Note:|r If you want to have more workflows for this item, you can convert it to Expert mode through the Databases view (by right-clicking on it and select |cff00ff00Convert to Expert mode|r).",
	IT_USE_TT = "Allow this item to be usable.\n\n|cff00ff00You can configure the item use effect in the 'Workflow' tab of this editor.",
	IT_USE_TEXT = "Usage text",
	IT_USE_TEXT_TT = "This text, explaining the effect for using this item, will appears in the tooltip.",
	IT_WEARABLE = "Wearable",
	IT_WEARABLE_TT = "Enables this item for the inspection feature and allows you to precisely place it on your character.\n\n|cffff9900If this flag is checked people will be able to see this item on your inventory if they inspect you, even if you don't configure the item position.",
	IT_CONTAINER_TT = "Sets this item to be a container. Container can hold other items.\n\n|cff00ff00The container can be configured in the 'Container' tab of this editor.",
	IT_CO_DURABILITY = "Durability",
	IT_CO_DURABILITY_TT = "Determine the overall max health for your container. A container can lose health over time or can be damaged. But it can also be repaired with the proper items.\n\n|cff00ff00Zero means invulnerable.",
	IT_CO_MAX = "Max weight (in grams)",
	IT_CO_MAX_TT = "This sets the limit of weight from where your container will start losing health over time due to overweight.\n\n|cff00ff00Zero means no limit.\n\n|cffff9900Please enter the max weight in GRAMS.",
	IT_CO_SIZE = "Container size",
	IT_CO_SIZE_COLROW = "%s |1row;rows; by %s columns",
	IT_DOC_ACTION = "Read document",
	IT_WARNING_1 = "Shouldn't make an item both stackable and craftable. (%s)",
	IT_WARNING_2 = "Shouldn't make a stackable container. (%s)",
	IT_CO_ONLY_INNER = "Can only contain inner items",
	IT_CO_ONLY_INNER_TT = "Marks this container to be able to contain only children items from the same root object.\n\nAs for now, only container with this option enabled can be traded while containing items.",
	IT_TRIGGER_ON_USE = "On use",
	IT_TRIGGER_ON_USE_TT = "Triggered each time the player use this item.\n\n|cff00ff00Don't forget to make your item usable in the main tab.",
	IT_TRIGGER_ON_DESTROY = "On stack destroy",
	IT_TRIGGER_ON_DESTROY_TT = "Triggered when the player destroy a stack of this item (drags & drops it out of his inventory and confirms the destruction).|cffff9900\n\nIt is triggered once per stack, and just before the actual stack destruction (so counting the item units in inventory in this workflow will still count the stack).",
	IT_NO_ADD = "Prevent manual adding",
	IT_NO_ADD_TT = "Prevent the player to manually adding the item to his inventory. Then it can only be added or looted through workflows.",
	IT_PU_SOUND = "Pick up sound",
	IT_PU_SOUND_1183 = "Bag",
	IT_PU_SOUND_1184 = "Book",
	IT_PU_SOUND_1185 = "Cloth",
	IT_PU_SOUND_1186 = "Food",
	IT_PU_SOUND_1187 = "Herb",
	IT_PU_SOUND_1188 = "Chain",
	IT_PU_SOUND_1189 = "Meat",
	IT_PU_SOUND_1190 = "Metal large",
	IT_PU_SOUND_1191 = "Metal small",
	IT_PU_SOUND_1192 = "Paper",
	IT_PU_SOUND_1193 = "Ring",
	IT_PU_SOUND_1194 = "Rock",
	IT_PU_SOUND_1195 = "Small chain",
	IT_PU_SOUND_1196 = "Wand",
	IT_PU_SOUND_1197 = "Liquid",
	IT_PU_SOUND_1198 = "Wood small",
	IT_PU_SOUND_1199 = "Wood large",
	IT_PU_SOUND_1221 = "Gems",
	IT_DR_SOUND = "Drop sound",

	-- Documents
	DO_NEW_DOC = "Document",
	DO_PREVIEW = "Click to see a preview",
	DO_PARAMS_GLOBAL = "Default parameters",
	DO_PARAMS_GLOBAL_TT = "Change the document default parameters. These parameters will be used for all pages that does not use custom page parameters.",
	DO_PARAMS_CUSTOM = "Page custom parameters",
	DO_PAGE_MANAGER = "Pages manager",
	DO_PAGE_EDITOR = "Page editor: page %s",
	DO_PAGE_HEIGHT = "Page height",
	DO_PAGE_HEIGHT_TT = "The page height, in pixel. Please note that certain background support only a certain height/width ratio and can be deformed.",
	DO_PAGE_WIDTH = "Page width",
	DO_PAGE_WIDTH_TT = "The page width, in pixel. Please note that certain background support only a certain height/width ratio and can be deformed.",
	DO_PAGE_FONT = "%s font",
	DO_PAGE_BORDER = "Border",
	DO_PAGE_BORDER_1 = "Parchment",
	DO_PAGE_TILING = "Background tiling",
	DO_PAGE_TILING_TT = "Sets if the background will tile vertically and horizontally. If not, the texture will be stretched.",
	DO_PAGE_RESIZE = "Resizable",
	DO_PAGE_RESIZE_TT = "Allow the user to resize the frame.\n\n|cffff9900Be sure that your layout can be readable and does not depend on height/width ratio.\n\n|cff00ff00Note that the user will never be able to reduce the frame size below the default width and height.",
	DO_PAGE_REMOVE = "Remove page",
	DO_PAGE_REMOVE_POPUP = "Remove the page %s ?",
	DO_PAGE_ADD = "Add page",
	DO_PAGE_COUNT = "Page %s / %s",
	DO_LINKS_ONOPEN = "On open",
	DO_LINKS_ONOPEN_TT = "Triggered when the document is shown to the player.",
	DO_LINKS_ONCLOSE = "On close",
	DO_LINKS_ONCLOSE_TT = "Triggered when the document is closed by the player or another event (e.g. through a workflow effect)",

	-- Workflows
	WO_WORKFLOW = "Workflows",
	WO_NO = "No workflows",
	WO_EXECUTION = "Workflow execution",
	WO_EMPTY = "You can start by adding an element to your workflow.\nThis can be an effect, a condition or a delay.",
	WO_ELEMENT_ADD = "Add element to workflow",
	WO_ELEMENT_COPY = "Copy element content",
	WO_ELEMENT_PASTE = "Paste element content",
	WO_END = "End of workflow",
	WO_ELEMENT = "Element edition",
	WO_ELEMENT_EDIT = "Click to edit element",
	WO_ELEMENT_EDIT_RIGHT = "Right-click for more operations",
	WO_ELEMENT_COND = "Edit effect condition",
	WO_ELEMENT_COND_TT = "Adds a condition to this single effect.",
	WO_ELEMENT_COND_NO = "Remove effect condition",
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
	WO_DELAY_CAST = "Casts for",
	WO_DELAY_SECONDS = "second(s)",
	WO_DELAY_CAST_SOUND = "Cast sound ID",
	WO_DELAY_CAST_SOUND_TT = "A sound ID for a precast sound. You can put a loopable sound here and it will be interrupted in case of cast interruption.\n\n|cff00ff00Examples: 12273, 12361, ...etc.",
	WO_DELAY_CAST_TEXT = "Cast text",
	WO_DELAY_CAST_TEXT_TT = "The text placed on the cast bar.",
	WO_ELEMENT_TYPE = "Select the element type",
	WO_SECURITY = "Security level",
	WO_WO_SECURITY = "Workflow security",
	WO_SECURITY_HIGH = "High",
	WO_SECURITY_HIGH_DETAILS = "This effect is secured and will not prompt security warning.",
	WO_SECURITY_NORMAL = "Medium",
	WO_SECURITY_NORMAL_DETAILS = "This effect is secured but could cause inconveniences. It will prompt security warning, based on the user security settings.",
	WO_SECURITY_LOW = "Low",
	WO_SECURITY_LOW_DETAILS = "This effect is not secured and could be malicious. It will prompt security warning and will ask for confirmation, based on the user security settings.",
	WO_EXPERT = "Expert mode",
	WO_EXPERT_TT = "A workflow is a set of instructions that can make your object dynamic.\n\nHere you can define all your workflows for this object, then you can link them to an action in the event links tab.",
	WO_EXPERT_DONE = "Switched %s to expert mode. Now unleash your creativity!",
	WO_ADD = "Create workflow",
	WO_ADD_ID = "|cff00ff00Enter the workflow ID.|r\n\nIt's an internal ID to help you manage your workflows and won't be visible by the user.\n\nPlease note that you can't have two workflows with the same ID within the same object.",
	WO_ADD_ID_NO_AVAILABLE = "This workflow ID is not available.",
	WO_REMOVE_POPUP = "Delete the workflow %s?",
	WO_LINKS = "Event links",
	WO_EVENT_LINKS = "Object event links",
	WO_ACTIONS_LINKS = "Action links",
	WO_ACTIONS_LINKS_TT = "Here you can link your workflows to player quest actions.\nThese actions are: |cff00ff00Interact, listen, talk and inspect.|r\nEach link can be conditioned.",
	WO_LINKS_TRIGGERS = "Here you can link your workflows to specifics events for this object.",
	WO_LINKS_NO_LINKS = "No link",
	WO_LINKS_NO_LINKS_TT = "Does not link this action/event to a workflow.",
	WO_LINKS_SELECT = "Select a workflow to link",
	WO_LINKS_TO = "Linked to workflow",
	WO_CONTEXT = "Context",
	WO_CONTEXT_TT = "The workflow context determines which effects can be used in the workflow.",
	WO_COMMON_EFFECT = "Common effects",
	WO_EXPERT_EFFECT = "Expert effects",
	WO_COPY = "Copy workflow content",
	WO_PASTE = "Paste workflow content",
	WO_PASTE_CONFIRM = "Replace this workflow content with the one you copied earlier?",
	WO_EVENT_EX_LINKS = "Game event links",
	WO_EVENT_EX_LINKS_TT = "Here you can link your workflows to game events.\nEach link can be conditioned.",
	WO_EVENT_EX_LINK = "Game event link",
	WO_EVENT_EX_ADD = "Add event link",
	WO_EVENT_EX_NO = "No event link",
	WO_EVENT_EX_EDITOR = "Event link editor",
	WO_EVENT_EX_CONDI = "Event link condition editor",
	WO_EVENT_ID = "Event ID",
	WO_EVENT_ID_TT = "The event ID.\n\nYou can see the whole events list on websites like wowwiki of wowpedia.\n\nHere as an example, PLAYER_REGEN_DISABLED is triggered when you enter a combat.",

	-- Delay editor
	WO_DELAY_DURATION = "Duration",
	WO_DELAY_DURATION_TT = "The duration for this delay, in seconds.",
	WO_DELAY_TYPE = "Delay type",
	WO_DELAY_TYPE_1 = "Regular delay",
	WO_DELAY_TYPE_1_TT = "Simply pauses the workflow, without showing any specific information to the player.",
	WO_DELAY_TYPE_2 = "Cast",
	WO_DELAY_TYPE_2_TT = "Show a casting bar during the workflow pause.",
	WO_DELAY_INTERRUPT = "Interruption",
	WO_DELAY_INTERRUPT_1 = "No interruption",
	WO_DELAY_INTERRUPT_2 = "Interrupt on move",

	-- Effects editors
	EFFECT_SCRIPT = "Execute restricted lua script",
	EFFECT_SCRIPT_TT = "Execute a lua script in a restricted safe environment.",
	EFFECT_SCRIPT_SCRIPT = "Lua code",
	EFFECT_SCRIPT_SCRIPT_TT = [[This script will be executed in a safe environment where you can have access to all lua synthax and API (table, string, math...) and the Extended |cff00ff00effect|r function.

|cffff0000You don't have access to the game API here!|r

A custom lua script will always be less efficient than a workflow effect, as it is compiled each time, in opposition to a workflow effect being compiled once.

|cffff9900So keep the script to the minimum and only use this script effect if necessary.]],
	EFFECT_SCRIPT_I_EFFECT = "Insert effect",
	EFFECT_SCRIPT_I_EFFECT_TT = [[Insert an effect function where the cursor is in the code.

The function is in the form of:
|cff00ffffeffect( effectID, args, arg1, arg2, ...);|r
- |cff00ffffEffect ID|r: the effect ID, you can find it by looking at the addon source code.
- |cff00ffffargs|r: The execution arguments: should always be the args variable.
- |cff00ffffEffect arguments argX|r: All effects arguments can be found in the addon source code.

|cffffff00Please always keep the 'args' as second parameters, |rit is needed by the effect function and contains all workflows arguments.

|cff00ff00We won't, for now, heavily document all effect ID and arguments as we consider this effect restricted to users capable of looking at the addon source code. ;)]],
	EFFECT_CAT_SOUND = "Sound and music",
	EFFECT_CAT_SPEECH = "Speech and emotes",
	EFFECT_CAT_CAMPAIGN = "Campaign and quest",
	EFFECT_TEXT = "Display text",
	EFFECT_TEXT_TT = "Displays a text.\nDifferent outputs are possible.",
	EFFECT_TEXT_PREVIEW = "Displayed text",
	EFFECT_TEXT_TEXT = "Text",
	EFFECT_TEXT_TEXT_DEFAULT = "Hello.\nHow are you?",
	EFFECT_TEXT_TEXT_TT = "The text to display.",
	EFFECT_TEXT_TYPE = "Text type",
	EFFECT_TEXT_TYPE_1 = "Chat frame text",
	EFFECT_TEXT_TYPE_2 = "Alert popup",
	EFFECT_TEXT_TYPE_3 = "Raid alert text",
	EFFECT_TEXT_TYPE_4 = "Alert message",
	EFFECT_DISMOUNT = "Dismiss mount",
	EFFECT_DISMOUNT_TT = "Dismount the player from his current mount.",
	EFFECT_DISPET = "Dismiss battle pet",
	EFFECT_DISPET_TT = "Dismiss the currently invoked battle pet.",
	EFFECT_RANDSUM = "Summon random battle pet",
	EFFECT_RANDSUM_TT = "Summon a random battle pet, picked up in your favorite pets pool.",
	EFFECT_SUMMOUNT = "Summon a mount",
	EFFECT_SUMMOUNT_TT = "Summon a specific mount, if available.",
	EFFECT_SUMMOUNT_NOMOUNT = "No mount select yet.",
	EFFECT_SHEATH = "Toggle weapons sheath",
	EFFECT_SHEATH_TT = "Draw or put up the character weapons.",
	EFFECT_VAR_OBJECT_CHANGE = "Variable operation",
	EFFECT_VAR_OBJECT_CHANGE_TT = "Performs an operation on a variable.\n\n|cffff9900For math operations: If the variable does not exists or can't be cast as a number, it will be initialized at 0.",
	EFFECT_VAR_OPERAND = "Variable dynamic value",
	EFFECT_VAR_OPERAND_TT = "Place a dynamic value in a variable. You have access to all test values from conditions.",
	EFFECT_VAR_OPERAND_CONFIG = "Value configuration",
	EFFECT_VAR_OPERAND_CONFIG_NO = "No configuration for this value",
	EFFECT_VAR = "Variable name",
	EFFECT_SOURCE = "Source",
	EFFECT_SOURCE_V = "Variable source",
	EFFECT_SOURCE_W = "Workflow source",
	EFFECT_SOURCE_WORKFLOW = "Workflow",
	EFFECT_SOURCE_WORKFLOW_TT = "Search the variable in the workflow execution. The scope for this variable is limited to the workflow execution and will be discarded afterward.",
	EFFECT_SOURCE_OBJECT = "Object",
	EFFECT_SOURCE_OBJECT_TT = "Search the variable in the workflow source object.\n\nOnly works if the source object is an item or a campaign/quest/step.\n\nIn the case of a campaign, quest or quest step, the variable will be searched in the campaign level (global for the whole campaign).",
	EFFECT_SOURCE_CAMPAIGN = "Active campaign",
	EFFECT_SOURCE_CAMPAIGN_TT = "Search the variable in the current campaign, if there is a currently active campaign.",
	EFFECT_SOURCE_PARENT = "Parent container",
	EFFECT_SOURCE_PARENT_TT = "Search for the workflow in the parent container item.",
	EFFECT_SOURCE_SLOT = "Item in slot (child)",
	EFFECT_SOURCE_SLOT_TT = "Search the workflow in the item in a specific slot inside the container item. Only works for container item!",
	EFFECT_SOURCE_SLOT_B = "Item in slot (sibling)",
	EFFECT_SOURCE_SLOT_B_TT = "Search the workflow in the item in a specific slot of the same parent container.",
	EFFECT_OPERATION = "Operation",
	EFFECT_OPERATION_TYPE = "Operation type",
	EFFECT_OPERATION_TYPE_INIT = "Init",
	EFFECT_OPERATION_TYPE_INIT_TT = "Initializes the variable to a value, only if the variable does not exist yet.",
	EFFECT_OPERATION_TYPE_SET = "Set",
	EFFECT_OPERATION_TYPE_SET_TT = "Sets the variable to a value, even if the variable has already been initialiazed.",
	EFFECT_OPERATION_TYPE_MULTIPLY = "Multiplication",
	EFFECT_OPERATION_TYPE_ADD = "Addition",
	EFFECT_OPERATION_TYPE_DIV = "Division",
	EFFECT_OPERATION_TYPE_SUB = "Substraction",
	EFFECT_VAR_VALUE = "Variable value",
	EFFECT_OPERATION_VALUE = "Operation value",
	EFFECT_DOC_DISPLAY = "Display document",
	EFFECT_DOC_DISPLAY_TT = "Display a document to the player. If there is already a shown document, it will be replaced.",
	EFFECT_DOC_CLOSE = "Close document",
	EFFECT_DOC_CLOSE_TT = "Close the currently opened document. Do nothing if there is no shown document.",
	EFFECT_SPEECH_NAR = "Speech: Narration",
	EFFECT_SPEECH_NAR_TT = "Plays a narration as a formated emote.\n\n|cff00ff00Has the same effect as playing an emote starting with a || (pipe character). It will be formated in chat for other TRP users.",
	EFFECT_SPEECH_NAR_DEFAULT = "The snow blows white on the mountain tonight ...",
	EFFECT_SPEECH_NAR_TEXT_TT = "Please do not include the leading pipe || character.",
	EFFECT_SPEECH_TYPE = "Speech type",
	EFFECT_SPEECH_NPC = "Speech: NPC",
	EFFECT_SPEECH_NPC_TT = "Plays a npc speech as a formated emote.\n\n|cff00ff00Has the same effect as playing an emote starting with a || (pipe character) with a npc name and a text. It will be formated in chat for other TRP users.",
	EFFECT_SPEECH_NPC_DEFAULT = "Do you want to build a snowman?",
	EFFECT_SPEECH_NPC_NAME = "NPC name",
	EFFECT_SPEECH_NPC_NAME_TT = "The NPC name.",
	EFFECT_SPEECH_PLAYER = "Speech: Player",
	EFFECT_SPEECH_PLAYER_TT = "Makes the player speak, yell or do an /e emote.",
	EFFECT_SPEECH_PLAYER_DEFAULT = "Let the dragon consume you!",
	EFFECT_SOUND_PLAY = "Play",
	EFFECT_SOUND_ID_SELF = "Play sound ID",
	EFFECT_SOUND_ID_SELF_TT = "Plays a sound in a particular channel. Only the player will hear it.",
	EFFECT_SOUND_ID_SELF_PREVIEW = "Plays sound ID %s in channel %s.",
	EFFECT_SOUND_ID_SELF_ID = "Sound ID",
	EFFECT_SOUND_ID_SELF_ID_TT = "The ID is an internal identifier for sounds in the game.\n\n|cff00ff00You can easily find all ID on websites like wowhead.\n\n|cffff9900Note that if the ID points to multiple sub-sounds, a sub-sound will be chosen randomly.",
	EFFECT_SOUND_ID_SELF_CHANNEL = "Channel",
	EFFECT_SOUND_ID_SELF_CHANNEL_SFX = "SFX",
	EFFECT_SOUND_ID_SELF_CHANNEL_SFX_TT = "SFX is for effect sounds. It uses the sound volume game option.\n\nMultiple different SFX sounds can be played simultaneously.",
	EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE = "Ambience",
	EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE_TT = "Ambience is for ambiant sound. It uses the ambience volume game option\n\nMultiple different ambience sounds can be played simultaneously.\n\n|cffff9900Please do not use this effect to play music as this won't stop the current game music and you would have musics overlaping each other. If you want to play a music use the proper music effect.",
	EFFECT_SOUND_MUSIC_SELF = "Play music",
	EFFECT_SOUND_MUSIC_SELF_TT = "Plays a music. Only the player will hear it.\n\nNote that the music will loop until the game plays a music of his own (when entering a zone for example), or until a \"stop music\" effect is played. Also the player can always manually stop the music through the sound history frame.",
	EFFECT_SOUND_MUSIC_SELF_PREVIEW = "Plays music: %s",
	EFFECT_SOUND_MUSIC_SELF_PATH = "Music path",
	EFFECT_SOUND_MUSIC_SELF_PATH_TT = "The music path within the game files.\n\n|cffff9900It must not contains the Sounds\\Music\\ part of the path, nor the .mp3 at the end.",
	EFFECT_SOUND_MUSIC_STOP = "Stop music",
	EFFECT_SOUND_MUSIC_STOP_TT = "If you use the \"play music\" effect, the music will loop until the game plays another music (for example: the player enters a new zone), or if the player stop it manually or until you use this effect.\n\n|cffff9900Note that this effect will only stop music played by the addon, and will not stop a music played by the game.",
	EFFECT_SOUND_ID_LOCAL = "Play local sound",
	EFFECT_SOUND_ID_LOCAL_TT = "Plays a sound for players around you.",
	EFFECT_SOUND_ID_LOCAL_PREVIEW = "Plays sound ID %s in channel %s in a %s yards radius.",
	EFFECT_SOUND_LOCAL_DISTANCE = "Playback radius",
	EFFECT_SOUND_LOCAL_DISTANCE_TT = "Determine the radius around the player within which other players will hear this sound.",
	EFFECT_SOUND_MUSIC_LOCAL = "Play local music",
	EFFECT_SOUND_MUSIC_LOCAL_TT = "Plays a music for players around you.",
	EFFECT_SOUND_MUSIC_LOCAL_PREVIEW = "Plays music \"%s\" in a %s yards radius.",
	EFFECT_ITEM_BAG_DURABILITY = "Damage/repair container",
	EFFECT_ITEM_BAG_DURABILITY_TT = "Repair or damage the durability of the item parent container.\n\n|cff00ff00Only works on containers having durability.",
	EFFECT_ITEM_BAG_DURABILITY_PREVIEW_1 = "|cff00ff00Repair|cffffff00 parent container for %s durability points.",
	EFFECT_ITEM_BAG_DURABILITY_PREVIEW_2 = "|cffff0000Damage|cffffff00 parent container for %s durability points.",
	EFFECT_ITEM_BAG_DURABILITY_METHOD = "Type",
	EFFECT_ITEM_BAG_DURABILITY_METHOD_HEAL = "Repair",
	EFFECT_ITEM_BAG_DURABILITY_METHOD_HEAL_TT = "Repair the parent container. The parent container health can't exceed the container maximum durability.",
	EFFECT_ITEM_BAG_DURABILITY_METHOD_DAMAGE = "Damage",
	EFFECT_ITEM_BAG_DURABILITY_METHOD_DAMAGE_TT = "Damage the parent container. The parent container health can't be damage below 0.",
	EFFECT_ITEM_BAG_DURABILITY_VALUE = "Durability point",
	EFFECT_ITEM_BAG_DURABILITY_VALUE_TT = "The amount of durability points to add/substract from the parent container health.",
	EFFECT_ITEM_CONSUME = "Consume item",
	EFFECT_ITEM_CONSUME_TT = "Consumes the used item and destroys it.",
	EFFECT_DOC_ID = "Document ID",
	EFFECT_DOC_ID_TT = "The document to show.\n\n|cffffff00Please enter the full document ID (parents ID and inner ID).\n\n|cff00ff00Hint: copy/paste the full ID to be sure to avoid typos.",
	EFFECT_ITEM_ADD = "Add item",
	EFFECT_ITEM_ADD_TT = "Adds items to your bag.",
	EFFECT_ITEM_ADD_PREVIEW = "Adds %sx %s",
	EFFECT_ITEM_ADD_ID = "Item ID",
	EFFECT_ITEM_ADD_ID_TT = "The item to add.\n\n|cffffff00Please enter the full item ID (parents ID and inner ID).\n\n|cff00ff00Hint: copy/paste the full ID to be sure to avoid typos.",
	EFFECT_ITEM_ADD_QT = "Amount",
	EFFECT_ITEM_ADD_QT_TT = "The number of item to add.\n\n|cff00ff00Note that the addon will do his best to reach this amount but it is possible that not all items will be added: for example if the bag becomes full or if the item has a maximum of units the character can have ('Unique' attribute).",
	EFFECT_ITEM_ADD_CRAFTED = "Crafted",
	EFFECT_ITEM_ADD_CRAFTED_TT = "When checked, and if the added items are craftable (have the crafted flag in their display attributes), will display \"Crafted by xxx\" in the items tooltip where xxx will be the player name.",
	EFFECT_ITEM_REMOVE = "Destroy item",
	EFFECT_ITEM_REMOVE_TT = "Destroy items from your inventory.",
	EFFECT_ITEM_REMOVE_PREVIEW = "Destroys %sx %s",
	EFFECT_ITEM_REMOVE_ID_TT = "The item to remove.\n\n|cffffff00Please enter the full item ID (parents ID and inner ID).\n\n|cff00ff00Hint: copy/paste the full ID to be sure to avoid typos.",
	EFFECT_ITEM_REMOVE_QT_TT = "The number of item to remove.",
	EFFECT_ITEM_COOLDOWN = "Start cooldown",
	EFFECT_ITEM_COOLDOWN_TT = "Start a cooldown for this item.",
	EFFECT_COOLDOWN_DURATION = "Cooldown duration",
	EFFECT_ITEM_COOLDOWN_PREVIEW = "Duration: %s second(s)",
	EFFECT_COOLDOWN_DURATION_TT = "The cooldown duration, in seconds.",
	EFFECT_ITEM_SOURCE_ID = "You can select an item ID you want to search, or leave empty if you want to search for all types of items.",
	EFFECT_ITEM_SOURCE = "Search in",
	EFFECT_ITEM_SOURCE_1 = "All inventory",
	EFFECT_ITEM_SOURCE_2 = "Parent container",
	EFFECT_ITEM_SOURCE_3 = "This item",
	EFFECT_ITEM_SOURCE_1_TT = "Search for the item(s) inside the entire character inventory.",
	EFFECT_ITEM_SOURCE_2_TT = "Search for the item(s) only inside this item parent container (and any sub-container).\n\n|cffff9900Only works if this script is in an item context.",
	EFFECT_ITEM_SOURCE_3_TT = "Search for the item(s) only inside this item (and any sub-container).\n\n|cffff9900Only works if this script is in an item context and this item is a container.",
	EFFECT_ITEM_USE = "Container: item use",
	EFFECT_ITEM_USE_TT = "Use a item in a slot in the container.\n\n|cffff9900Only works if this workflow is triggered by a container.",
	EFFECT_ITEM_USE_PREVIEW = "Use item in slot %s",
	EFFECT_ITEM_WORKFLOW_PREVIEW_P = "Triggers workflow %s in parent container.",
	EFFECT_ITEM_WORKFLOW_PREVIEW_S = "Triggers workflow %s in sibling item in slot %s.",
	EFFECT_ITEM_WORKFLOW_PREVIEW_C = "Triggers workflow %s in child item in slot %s.",
	EFFECT_ITEM_WORKFLOW = "Run item workflow",
	EFFECT_ITEM_WORKFLOW_TT = "Run a workflow on the parent container or on an item in a specific child item (for container only).",
	EFFECT_ITEM_DICE = "Roll dices",
	EFFECT_ITEM_DICE_TT = "They see me rollin', they hating.",
	EFFECT_ITEM_DICE_PREVIEW = "Rollin' %s",
	EFFECT_ITEM_DICE_ROLL = "Roll",
	EFFECT_ITEM_DICE_ROLL_TT = "Enter a roll configuration similar to the /trp3 roll command.\n\n|cff00ff00Example: 1d20, 3d6 ..etc.",
	EFFECT_RUN_WORKFLOW_SLOT = "Slot ID",
	EFFECT_RUN_WORKFLOW_SLOT_TT = "The index of the container slot to trigger. Slots are indexed from top left to bottom right beginning with slot 1.",
	EFFECT_PROMPT = "Prompt for input",
	EFFECT_PROMPT_PREVIEW = "Prompt user for an input to store in variable |cff00ff00%s|r.",
	EFFECT_PROMPT_TT = "Ask the user for an input and store it in a variable. Then optionally trigger a workflow.\n\n|cffff0000WARNING, this effect execution is asynchronous.",
	EFFECT_PROMPT_TEXT = "Popup text",
	EFFECT_PROMPT_TEXT_TT = "The text that will be presented to the user in the input popup.",
	EFFECT_PROMPT_DEFAULT = "Default value",
	EFFECT_PROMPT_DEFAULT_TT = "The default value for the input.",
	EFFECT_PROMPT_VAR = "Variable name",
	EFFECT_PROMPT_VAR_TT = "The name of the variable storing the user input.",
	EFFECT_PROMPT_CALLBACK = "Workflow callback (optional)",
	EFFECT_PROMPT_CALLBACK_TT = "The workflow name to call after the user input.\n\nThis is optional. Leave empty to not use any callback.\n\nIs given, the workflow will be called with the input as workflow variable with the proper name.\n\n|cffffff00Warning: the callback is called even if the player click 'Cancel' in the prompt popup. In that case the variable will be left untouched if it exists.",
	EFFECT_USE_SLOT = "Container slot number",
	EFFECT_USE_SLOT_TT = "The container slots number are assigned from left to right and top to bottom.",
	EFFECT_QUEST_START = "Reveal quest",
	EFFECT_QUEST_START_TT = "Reveal a quest in the quest log.\n\n|cffff9900Only works if the quest is part of the current active campaign.",
	EFFECT_QUEST_START_PREVIEW = "Reveal quest %s.",
	EFFECT_QUEST_START_ID = "Quest ID",
	EFFECT_QUEST_START_ID_TT = "Use the browser to select your quest (the quest must exist before linking it to this effect).\n\nIf your quest does not appear in the browser, save your campaign and try again.",
	EFFECT_QUEST_GOTOSTEP = "Change quest step",
	EFFECT_QUEST_GOTOSTEP_TT = "Change a quest step.\n\n|cffff9900Only works if the quest is part of the current active campaign and that the quest has already been revealed in the quest log.",
	EFFECT_QUEST_GOTOSTEP_ID = "Quest step ID",
	EFFECT_QUEST_GOTOSTEP_ID_TT = "Use the browser to select your quest step (the quest and quest step must exist before linking it to this effect).\n\nIf your quest step does not appear in the browser, save your campaign and try again.",
	EFFECT_QUEST_GOTOSTEP_PREVIEW = "Go to step %s.",
	EFFECT_QUEST_REVEAL_OBJ = "Reveal quest objective",
	EFFECT_QUEST_REVEAL_OBJ_TT = "Reveal a quest objective.\n\n|cffff9900Only works if the quest is part of the current active campaign and that the quest has already been revealed in the quest log.",
	EFFECT_QUEST_REVEAL_OBJ_PREVIEW = "Reveal objective: %s for %s",
	EFFECT_QUEST_OBJ_ID = "Objective ID",
	EFFECT_QUEST_OBJ_ID_TT = "Enter the objective ID. Enter only the objective ID and not the full campaign-quest-objective ID.",
	EFFECT_QUEST_REVEAL_OBJ_DONE = "Complete objective",
	EFFECT_QUEST_REVEAL_OBJ_DONE_TT = "Marks an objective as completed.\n\n|cffff9900Only works if the quest is part of the current active campaign, if the quest has already been revealed in the quest log and if the objective has already been revealed.",
	EFFECT_QUEST_REVEAL_OBJ_DONE_PREVIEW = "Complete objective: %s for %s",
	EFFECT_DIALOG_START = "Start cutscene",
	EFFECT_DIALOG_START_TT = "Start a cutscene. If a cutscene is already played, it will be interrupted and replace by this one.",
	EFFECT_DIALOG_START_PREVIEW = "Start cutscene %s.",
	EFFECT_DIALOG_ID = "Cutscene ID",
	EFFECT_DIALOG_QUICK = "Quick cutscene",
	EFFECT_DIALOG_QUICK_TT = "Generate a quick cutscene with only one step. It will automatically takes the player's target as speaker.",
	EFFECT_ITEM_LOOT = "Show/drop loot",
	EFFECT_ITEM_LOOT_TT = "Displays a loot container to the player or drop loot on the ground where the player is.",
	EFFECT_ITEM_LOOT_PREVIEW_1 = "Drop %s item(s) on the ground.",
	EFFECT_ITEM_LOOT_PREVIEW_2 = "Display loot with %s item(s).",
	EFFECT_ITEM_LOOT_DROP = "Drop items",
	EFFECT_ITEM_LOOT_DROP_TT = "Drops items on the ground instead of presenting a loot frame to the player. The player can then loot the items he wants with the 'search for items' feature.",
	EFFECT_ITEM_LOOT_NAME = "Source name",
	EFFECT_ITEM_LOOT_NAME_TT = "This will be the loot container name.",
	EFFECT_ITEM_LOOT_SLOT = "Click on a slot to configure it.",
	EFFECT_MISSING = "This effect (%s) is unknown and you should remove it.",
	EFFECT_SIGNAL = "Send signal",
	EFFECT_SIGNAL_TT = "Send a signal with an ID and a value to the player's target.\n\nThis signal can be handle by campaign/quest/step game event links through the event |cff00ff00TRP3_SIGNAL|r.",
	EFFECT_SIGNAL_PREVIEW = "|cffffff00Send signal ID:|r %s|cffffff00 with value:|r %s",
	EFFECT_SIGNAL_ID = "Signal ID",
	EFFECT_SIGNAL_ID_TT = "It's the ID of your signal. It can be tested if conditions and workflows triggered by the game event |cff00ff00TRP3_SIGNAL|r.",
	EFFECT_SIGNAL_VALUE = "Signal value",
	EFFECT_SIGNAL_VALUE_TT = "It's the value of your signal. It can be tested if conditions and workflows triggered by the game event |cff00ff00TRP3_SIGNAL|r and inserted as text tags like |cff00ff00${event.2}|r.",
	EFFECT_RUN_WORKFLOW = "Run workflow",
	EFFECT_RUN_WORKFLOW_TT = "Run another workflow. All workflow variables will be passed through the next.",
	EFFECT_RUN_WORKFLOW_PREVIEW = "Run workflow %s in %s.",
	EFFECT_W_OBJECT_TT = "Search for the workflow in the same object.",
	EFFECT_W_CAMPAIGN_TT = "Search for the workflow in the current active campaign.",
	EFFECT_RUN_WORKFLOW_ID = "Workflow ID",
	EFFECT_RUN_WORKFLOW_ID_TT = "The workflow ID you want to run.",
	EFFECT_CAT_CAMERA = "Camera",
	EFFECT_CAT_CAMERA_ZOOM_IN = "Camera zoom in",
	EFFECT_CAT_CAMERA_ZOOM_IN_TT = "Zooms the camera in by a specified distance.",
	EFFECT_CAT_CAMERA_ZOOM_OUT = "Camera zoom out",
	EFFECT_CAT_CAMERA_ZOOM_OUT_TT = "Zooms the camera out by a specified distance.",
	EFFECT_CAT_CAMERA_ZOOM_DISTANCE = "Zoom distance",
	EFFECT_CAT_CAMERA_SAVE = "Save camera",
	EFFECT_CAT_CAMERA_SAVE_TT = "Saves the player's current camera position in one of the 5 save slots available.",
	EFFECT_CAT_CAMERA_LOAD = "Load camera",
	EFFECT_CAT_CAMERA_LOAD_TT = "Sets the player's camera position based on a previously saved position.",
	EFFECT_CAT_CAMERA_SLOT = "Slot number",
	EFFECT_CAT_CAMERA_SLOT_TT = "The index of one of the slots available, 1 to 5.",

	-- Inner objects
	IN_INNER = "Inner objects",
	IN_INNER_S = "Inner object",
	IN_INNER_LIST = "Inner object list",
	IN_INNER_HELP_TITLE = "What are inner objects?",
	IN_INNER_ADD = "Add inner object",
	IN_INNER_ADD_NEW = "Create new object",
	IN_INNER_ADD_COPY = "Add copy of existing object",
	IN_INNER_ENTER_ID = "Enter new inner object ID",
	IN_INNER_ENTER_ID_TT = "Inner object ID must be unique within the parent object.\n\n|cffff9900Please only use lower case characters and underscores. Any other character will be converted to underscores.",
	IN_INNER_EMPTY = "No inner objects\n\nYou can add one by using the add button below.",
	IN_INNER_HELP =
[[Inner objects are objects stored in a parent object.

We should begin with some examples:
|cffff9900
- You want to create a rifle item with bullets item to charge it. Typically the rifle would be the main object, in which the bullet object would be an inner object for the rifle.

- A mail item opening a document. The document would be an inner object for the mail item.

- Creating quests: any item/document/cutscenes you use in a quest could be inner objects for this quest.

|rThe advantages of using inner objects are multiple:
|cff00ff00
- Inner objects data are really stored inside the parent object data. That mean they share the same version number, and their data are exchanged in the same time as the parent object data.

- You can freely determine the inner object ID, as it will use the parent object ID as prefix. You just can't have two inner objects having the same ID inside the same parent object.

- Using inner objects brings better performances.

- It's easier to manage and navigate through your objects if they are stored in parent objects. You can really see a parent object as a folder in which you store files.

|rSo it's simple: when you want to create an object, always ask yourself if it wouldn't be better to have it as an inner object for another item or a quest.

|cff00ff00Also: document and cutscenes can only be inner objects!]],
	IN_INNER_DELETE_CONFIRM = "Remove the inner object |cff00ffff\"%s\"|r |cff00ff00[%s]|r from the parent object |cff00ff00[%s]|r?\n\n|cffff9900The inner object will be lost.",
	IN_INNER_DELETE_TT = "Remove this inner object from the parent object.",
	IN_INNER_ID_ACTION = "Change ID",
	IN_INNER_ID_COPY = "Copy",
	IN_INNER_ID_COPY_TT = "You can copy your inner object to paste it in any other parent object.",
	IN_INNER_ID = "Please enter a new ID for the inner object |cff00ff00[%s]|r.\n\nOld ID: |cff00ffff\"%s\"|r",
	IN_INNER_NO_AVAILABLE = "This inner ID is not available!",
	IN_INNER_COPY_ACTION = "Copy object content",
	IN_INNER_PASTE_ACTION = "Paste object content",
	IN_INNER_PASTE_CONFIRM = "Replace the content of this inner object with the one you copied earlier?",

	-- Operands
	OP_COMP_EQUALS = "is equal to",
	OP_COMP_NEQUALS = "is not equal to",
	OP_COMP_GREATER = "is greater than",
	OP_COMP_GREATER_OR_EQUALS = "is greater than or equal to",
	OP_COMP_LESSER = "is lesser than",
	OP_COMP_LESSER_OR_EQUALS = "is lesser than or equal to",
	OP_UNIT = "Unit type",
	OP_UNIT_PLAYER = "Player",
	OP_UNIT_TARGET = "Target",
	OP_UNIT_NPC = "NPC",
	OP_AND = "AND",
	OP_AND_SWITCH = "Switch to AND",
	OP_OR = "OR",
	OP_OR_SWITCH = "Switch to OR",
	OP_COMPA_SEL = "Comparator selection",
	OP_REMOVE_TEST = "Remove test",
	OP_ADD_TEST = "Add test",
	OP_FAIL = "Failure message",
	OP_FAIL_TT = "This message will be displayed if the condition fails. Leave empty if you don't want to show any message.",
	OP_FAIL_W = "Failure workflow (Expert)",
	OP_FAIL_W_TT = "If this condition fails, this workflow will be called. That's a way for making an 'else' in a condition.\n\n|cffff9900Please note that this feature is performance heavy and should be used with caution. The called workflow must exist in the same object.\n\n|cffff0000Do NEVER, ever, create a cycle in called workflow (e.g. a workflow A calling a workflow B calling again the workflow A), even using delays!",
	OP_UNIT_VALUE = "Unit value",
	OP_UNIT_TEST = "Unit test",
	OP_EVAL_VALUE = "Evaluated value",
	OP_PREVIEW = "Preview value",
	OP_CONFIGURE = "Configure",
	OP_DIRECT_VALUE = "Direct value",
	OP_STRING = "String value",
	OP_NUMERIC = "Numeric value",
	OP_BOOL = "Boolean value",
	OP_BOOL_TRUE = "TRUE",
	OP_BOOL_FALSE = "FALSE",
	OP_CURRENT = "Current value",
	OP_CURRENT_TT = "Prints in the chat frame the evaluation of this operand based on the current situation.",
	OP_OP_UNIT_NAME = "Unit name",
	OP_OP_UNIT_NAME_TT = "|cff00ff00The unit name, as returned by the first parameters of UnitName.\n\n|rWhen used on a player, it could equals |cff00ff00'player'|r or |cff00ff00'player-realm'|r. So if you want to be sure to have the form |cff00ff00'player-realm'|r use the |cff00ff00'Unit ID'|r operand.",
	OP_OP_UNIT_ID = "Unit ID",
	OP_OP_UNIT_ID_TT = "|cff00ff00The unit id in the form |cff00ff00'player-realm'|r, as returned by UnitFullName. Ensure that there is always a realm part.",
	OP_OP_UNIT_NPC_ID = "Unit NPC ID",
	OP_OP_UNIT_NPC_ID_TT = "|cff00ff00The NPC ID, as determined by UnitGUID. Only works with NPC.",
	OP_OP_UNIT_HEALTH = "Unit health",
	OP_OP_UNIT_HEALTH_TT = "|cff00ff00The unit's current amount of health (hit points).",
	OP_OP_UNIT_EXISTS = "Unit exists",
	OP_OP_UNIT_EXISTS_TT = "|cff00ff00Returns whether a unit exists.\n\n|rA unit 'exists' if it can be referenced by the player; e.g. target exists if the player has a target, npc exists if the player is currently interacting with an NPC, etc.",
	OP_OP_UNIT_GUILD = "Unit guild name",
	OP_OP_UNIT_GUILD_TT = "|cff00ff00The unit guild name (if any).",
	OP_OP_UNIT_GUILD_RANK = "Unit guild rank",
	OP_OP_UNIT_GUILD_RANK_TT = "|cff00ff00The guild rank of the unit (if the unit has a guild).",
	OP_OP_UNIT_RACE = "Unit race",
	OP_OP_UNIT_RACE_TT = "|cff00ff00The unit race IN ENGLISH LOWER CASE, as returned by the second arguments of UnitRace.\n\nSo it's Scourge for Undead.",
	OP_OP_UNIT_CLASS = "Unit class",
	OP_OP_UNIT_CLASS_TT = "|cff00ff00The unit class IN ENGLISH LOWER CASE, as returned by the second arguments of UnitClass.",
	OP_OP_UNIT_SEX = "Unit sex",
	OP_OP_UNIT_SEX_TT = "|cff00ff00The unit sex index. 2 = Male, 3 = Female. 1 is for neutral or unknown.\n\n|cffffff00Returned as a STRING.",
	OP_OP_UNIT_FACTION = "Unit faction",
	OP_OP_UNIT_FACTION_TT = "|cff00ff00The unit faction IN ENGLISH LOWER CASE.",
	OP_OP_UNIT_LEVEL = "Unit level",
	OP_OP_UNIT_LEVEL_TT = "|cff00ff00The level of the unit.",
	OP_OP_UNIT_SPEED = "Unit speed",
	OP_OP_UNIT_SPEED_TT = "|cff00ff00The current unit speed in yard per seconds. Walking is 2.5 and running without buff is 7.",
	OP_OP_UNIT_CLASSIFICATION = "Unit classification",
	OP_OP_UNIT_CLASSIFICATION_TT = "|cff00ff00The unit classification IN ENGLISH LOWER CASE. Example: normal, elite, rare, worldboss, minus...\n\nAlways returns normal for players.",
	OP_OP_UNIT_ISPLAYER = "Unit is player",
	OP_OP_UNIT_ISPLAYER_TT = "|cff00ff00Returns whether the unit is a player.",
	OP_OP_UNIT_DEAD = "Unit is dead",
	OP_OP_UNIT_DEAD_TT = "|cff00ff00Returns whether a unit is either dead or a ghost.",
	OP_OP_INV_WEIGHT = "Container total weight",
	OP_OP_INV_WEIGHT_PREVIEW = "Total weight of |cffff9900%s",
	OP_OP_INV_WEIGHT_TT = "|cff00ff00The current total weight of a container (its own weight plus the content).",
	OP_OP_INV_COUNT = "Item units count",
	OP_OP_INV_COUNT_TT = "|cff00ff00The number of units of an item the player possesses in his inventory.\n\nLeave the ID empty to count for all items.",
	OP_OP_INV_COUNT_PREVIEW = "%s units in |cffff9900%s",
	OP_OP_INV_COUNT_ANY = "Any item",
	OP_OP_QUEST_STEP = "Quest current step",
	OP_OP_QUEST_STEP_TT = "Return the current quest step ID. If the quest is not revealed or has no current step, returns nil.",
	OP_OP_QUEST_STEP_PREVIEW = "%s current step",
	OP_OP_QUEST_OBJ = "Quest objective",
	OP_OP_QUEST_OBJ_TT = "Return the completion (true or false) for a quest objective. If the campaign, quest or the objective is not yet revealed, returns false.",
	OP_OP_QUEST_OBJ_PREVIEW = "Objective %s from %s",
	OP_OP_QUEST_NPC = "Unit is campaign NPC",
	OP_OP_QUEST_NPC_TT = "|cff00ff00Returns whether a unit is a customized NPC in the currently active campaign.",
	OP_OP_QUEST_OBJ_ALL = "Quest all objectives",
	OP_OP_QUEST_OBJ_ALL_TT = "Returns whether all possible quest objectives are completed. So all objectives also has to be revealed.",
	OP_OP_QUEST_OBJ_ALL_PREVIEW = "%s all obj. done",
	OP_OP_QUEST_OBJ_CURRENT = "Quest current objectives",
	OP_OP_QUEST_OBJ_CURRENT_TT = "Returns whether all currently revealed quest objectives are completed.",
	OP_OP_QUEST_OBJ_CURRENT_PREVIEW = "%s current obj. done",
	OP_OP_UNIT_DISTANCE_TRADE = "Unit is near (trade)",
	OP_OP_UNIT_DISTANCE_TRADE_TT = "|cff00ff00Returns whether a unit is close enough for trading (11.11 yards).",
	OP_OP_UNIT_DISTANCE_INSPECT = "Unit is near (inspection)",
	OP_OP_UNIT_DISTANCE_INSPECT_TT = "|cff00ff00Returns whether a unit is close enough for inspection (28 yards).",
	OP_OP_CHAR_FACING = "Character facing",
	OP_OP_CHAR_FACING_TT = "Returns the player's orientation (in radians, 0 = north, values increasing counterclockwise).\n\n|cffff9900Indicates the direction the player model is (normally) facing and in which the player will move if he begins walking forward, not the camera orientation.",
	OP_OP_CHECK_VAR = "Variable string value",
	OP_OP_CHECK_VAR_TT = "Returns the value of a variable, |cff00ff00interpreted as a string|r.\n\nIf the variable does not exists or can't be reached, returns the string 'nil'.\n\n|cffff9900As the value depends on runtime, it cannot be previewed.",
	OP_OP_CHECK_VAR_PREVIEW = "|cff00ffff%s:|r %s",
	OP_OP_CHECK_VAR_N_PREVIEW = "|cff00ffff%s: |cffff9900(n)|r %s",
	OP_OP_CHECK_VAR_N = "Variable numeric value",
	OP_OP_CHECK_VAR_N_TT = "Returns the value of a variable, |cff00ff00interpreted as a number|r.\n\nIf the variable does not exists, can't be reached or can't be interpreted as a number, returns 0.\n\n|cffff9900As the value depends on runtime, it cannot be previewed.",
	OP_OP_CHAR_FALLING = "Character is falling",
	OP_OP_CHAR_FALLING_TT = "Returns whether the player's character is currently plummeting to their doom.",
	OP_OP_CHAR_STEALTH = "Character is stealthed",
	OP_OP_CHAR_STEALTH_TT = "Checks if the character is stealthed.",
	OP_OP_CHAR_FLYING = "Character is flying",
	OP_OP_CHAR_FLYING_TT = "Checks if the character is flying.",
	OP_OP_CHAR_MOUNTED = "Character is mounted",
	OP_OP_CHAR_MOUNTED_TT = "Checks if the character is on a mount.",
	OP_OP_CHAR_RESTING = "Character is resting",
	OP_OP_CHAR_RESTING_TT = "Checks if the character is resting. You are resting if you are in an Inn or a Major City like Ironforge or Orgrimmar.",
	OP_OP_CHAR_SWIMMING = "Character is swimming",
	OP_OP_CHAR_SWIMMING_TT = "Checks if the character is swimming. They do not need to be underwater.",
	OP_OP_UNIT_POSITION_X = "Unit x position",
	OP_OP_UNIT_POSITION_X_TT = "Returns the X coordinate of a unit.\n\nOnly works with players.\n\n|cffff9900Does not work in instance/battleground/arena since patch 7.1.",
	OP_OP_UNIT_POSITION_Y = "Unit y position",
	OP_OP_UNIT_POSITION_Y_TT = "Returns the Y coordinate of a unit.\n\nOnly works with players.\n\n|cffff9900Does not work in instance/battleground/arena since patch 7.1.",
	OP_OP_DISTANCE_POINT = "Unit point distance",
	OP_OP_DISTANCE_POINT_TT = "Returns the distance (in yards) between a unit and a point coordinates.\n\nOnly works with players.\n\nReturns 0 if unit doesn't exist.\n\n|cffff9900Does not work in instance/battleground/arena since patch 7.1.",
	OP_OP_DISTANCE_POINT_PREVIEW = "|cff00ff00%s|r distance from |cff00ff00(%s, %s)",
	OP_OP_DISTANCE_X = "X coordinate",
	OP_OP_DISTANCE_Y = "Y coordinate",
	OP_OP_DISTANCE_ME = "Unit distance to player",
	OP_OP_DISTANCE_ME_TT = "Returns the distance (in yards) between a unit and the player.\n\nOnly works with players.\n\nReturns 0 if unit doesn't exist.\n\n|cffff9900Does not work in instance/battleground/arena since patch 7.1.",
	OP_OP_DISTANCE_CURRENT = "Use current position",
	EFFECT_VAR_INDEX = "Argument index",
	EFFECT_VAR_INDEX_TT = "The index of the argument.\n\nSo if you want to check the third argument of an event, enter 3.",
	OP_OP_CHECK_EVENT_VAR = "Event argument string value",
	OP_OP_CHECK_EVENT_VAR_TT = "Checks the n-th argument of the event triggering this condition (if any).\n\nInterpreted as a string.\n\nIf does not exists or can't be interpreted, returns 'nil'.",
	OP_OP_CHECK_EVENT_VAR_N = "Event argument number value",
	OP_OP_CHECK_EVENT_VAR_N_TT = "Checks the n-th argument of the event triggering this condition (if any).\n\nInterpreted as a number.\n\nIf does not exists or can't be interpreted, returns 0.",
	OP_OP_CHECK_EVENT_VAR_PREVIEW = "%s-th event argument |cff00ff00(string)",
	OP_OP_CHECK_EVENT_VAR_N_PREVIEW = "%s-th event argument |cff00ff00(number)",
	OP_OP_RANDOM = "Random",
	OP_OP_RANDOM_TT = "Random number (integer) between two bounds.",
	OP_OP_RANDOM_PREVIEW = "Random number between |cff00ff00%s|r and |cff00ff00%s|r.",
	OP_OP_RANDOM_FROM = "From",
	OP_OP_RANDOM_TO = "To",
	OP_OP_CHAR_ZONE = "Zone name",
	OP_OP_CHAR_ZONE_TT = "The zone name where the character currently is.\n\n|cffff9900Warning: The text depends on the client locale.",
	OP_OP_CHAR_SUBZONE = "Sub-zone name",
	OP_OP_CHAR_SUBZONE_TT = "The sub-zone name where the character currently is.\n\n|cffff9900Warning: The text depends on the client locale.",
	OP_OP_CHAR_MINIMAP = "Minimap text",
	OP_OP_CHAR_MINIMAP_TT = "Returns the minimap zone text.\n\nThe game event \"MINIMAP_ZONE_CHANGED\" is triggered, when the text changes. So you can test it in a game event link in a campaign or a quest.",
	OP_OP_CHAR_CAM_DISTANCE = "Camera distance",
	OP_OP_CHAR_CAM_DISTANCE_TT = "The camera distance from the player. 0 if in first person view.",
	OP_OP_CHAR_ACHIEVEMENT = "Achievement",
	OP_OP_CHAR_ACHIEVEMENT_TT = "Checks if the account has completed the specified achievement.",
	OP_OP_CHAR_ACHIEVEMENT_ID = "Achievement ID",
	OP_OP_CHAR_ACHIEVEMENT_ID_TT = "The numeric ID of the achievement you want to check.",
	OP_OP_CHAR_ACHIEVEMENT_WHO = "Completed by",
	OP_OP_CHAR_ACHIEVEMENT_ACC = "Account",
	OP_OP_CHAR_ACHIEVEMENT_ACC_TT = "Checks if any character from this account has completed the achievement",
	OP_OP_CHAR_ACHIEVEMENT_CHAR = "Character",
	OP_OP_CHAR_ACHIEVEMENT_CHAR_TT = "Checks if the current character has completed the achievement",
	OP_OP_CHAR_ACHIEVEMENT_PREVIEW = "%s completed by |cffff9900%s",
	OP_OP_TIME_HOUR = "Time: Hour",
	OP_OP_TIME_HOUR_TT = "The current hour of the day, server time.",
	OP_OP_TIME_MINUTE = "Time: Minute",
	OP_OP_TIME_MINUTE_TT = "The current minute of the hour, server time.",

	-- Test
	COND_EDITOR = "Condition editor",
	COND_EDITOR_EFFECT = "Effect condition editor",
	COND_CONDITIONED = "Conditioned",
	COND_PREVIEW_TEST = "Preview test",
	COND_PREVIEW_TEST_TT = "Prints in the chat frame the evaluation of this test based on the current situation.",
	COND_TESTS = "Condition tests",
	COND_COMPLETE = "Complete logical expression",
	COND_TEST_EDITOR = "Test editor",
	COND_LITT_COMP = "All comparison types",
	COND_NUM_COMP = "Numeric comparison only",
	COND_NUM_FAIL = "You must have two numeric operands if you uses a numeric comparator.",

	-- Campaign and quests
	CA_NPC = "Campaign NPC list",
	CA_NPC_TT = "You can customize NPCs to give them a name, an icon and a description.\nThis customization will be visible when the player has your campaign as active.",
	CA_NPC_ADD = "Add customized NPC",
	CA_NPC_UNIT = "Customized NPC",
	CA_NPC_ID = "NPC ID",
	CA_NPC_AS = "Duplicate",
	CA_NPC_NAME = "Default NPC name",
	CA_NPC_REMOVE = "Remove customization for this NPC?",
	CA_NPC_ID_TT = "Please enter the ID of the NPC to customize.\n\n|cff00ff00To get the ID of an NPC you targeted, type this command in the chat: /trp3 getID",
	CA_NPC_EDITOR = "NPC editor",
	CA_NPC_EDITOR_NAME = "NPC name",
	CA_NPC_EDITOR_DESC = "NPC description",
	CA_NO_NPC = "No customized NPC",
	CA_NAME_NEW = "New campaign",
	CA_NAME = "Campaign name",
	CA_NAME_TT = "This is the name of your campaign. It appears on the quest log.",
	CA_ICON = "Campaign icon",
	CA_ICON_TT = "Select campaign icon",
	CA_DESCRIPTION = "Campaign summary",
	CA_DESCRIPTION_TT = "This brief summary will be visible on the campaign page, in the quest log.",
	QE_QUESTS_HELP = "You can add quests to your campaign here. Please note that a quest is not automatically added to the player's quests log when he starts your campaign. You have to start the quests through workflows.\n|cffff9900Quests are sorted by ID in the quest log, not by name nor by reveal order.",
	CA_QUEST_ADD = "Add quest",
	CA_QUEST_REMOVE = "Remove this quest?",
	CA_QUEST_NO = "No quest",
	CA_QUEST_EXIST = "There is already a quest with the ID %s.",
	QE_NAME_NEW = "New quest",
	CA_QE_ID = "Change quest ID",
	CA_QUEST_CREATE = "Please enter the quest ID. You can't have two quests with the same ID within the same campaign.\n\n|cffff9900Please note that the quests will be listed in alphabetical order of IDs in the quest log.\n\n|cff00ff00So it's a good practice to always start your ID by quest_# where # is the quest number in the campaign.",
	CA_LINKS_ON_START = "On campaign start",
	CA_LINKS_ON_START_TT = "Triggered |cff00ff00once|r when the player start your campaign, so activating your campaign for the first time, or reset it in the quest log.\n\n|cff00ff00This is a good place to activate your first quest.",
	CA_IMAGE = "Campaign portrait",
	CA_IMAGE_TT = "Select campaign portrait",
	QE_STEPS = "Quest steps",
	QE_NAME = "Quest name",
	QE_NAME_TT = "It's your quest name, as it will appear on the quest log.",
	QE_DESCRIPTION = "Quest summary",
	QE_DESCRIPTION_TT = "This brief summary will be visible on the quest page, in the quest log.",
	QE_LINKS_ON_START = "On quest start",
	QE_LINKS_ON_START_TT = "Triggered |cff00ff00once|r when the player start your quest, by unlocking it in the quest log.\n\n|cff00ff00This is a good place to go to the first quest step.",
	QE_LINKS_ON_OBJECTIVE = "On objective completed",
	QE_LINKS_ON_OBJECTIVE_TT = "Triggered each time the player complete an objective for this quest.\n\n|cff00ff00It's a good place to check if all objectives has been completed and reveal the next quest.",
	CA_ACTIONS_ADD = "Add action",
	CA_ACTIONS_NO = "No action",
	CA_ACTIONS = "Actions",
	CA_ACTIONS_EDITOR = "Action editor",
	CA_ACTION_CONDI = "Action condition editor",
	CA_ACTION_REMOVE = "Remove this action?",
	CA_ACTIONS_SELECT = "Select action type",
	CA_ACTIONS_COND = "Edit condition",
	CA_ACTIONS_COND_REMOVE = "Remove condition",
	CA_ACTIONS_COND_ON = "This action is conditioned.",
	CA_ACTIONS_COND_OFF = "This action is not conditioned.",
	QE_AUTO_REVEAL = "Auto reveal",
	QE_AUTO_REVEAL_TT = "Reveal the quest in the quest log when the campaign is started.",
	QE_OBJ = "Quest objectives",
	QE_OBJ_SINGULAR = "Quest objective",
	QE_OBJ_TT = "Quest objectives are hints for the player. Accomplishing all objectives does not automatically complete the quest. You decide when objectives are shown so you can have secret objective in your quest.\n|cffff9900Objectives are always ordered by ID in the quest log, and not following their reveal order.",
	QE_OBJ_ADD = "Add objective",
	QE_OBJ_REMOVE = "Remove this quest objective?",
	QE_OBJ_NO = "No quest objective",
	QE_OBJ_ID = "Objective ID",
	QE_OBJ_ID_TT = "This is your objective ID. You can't have two objectives with the same ID in a same quest.",
	QE_OBJ_TEXT = "Objective text",
	QE_OBJ_AUTO = "Auto reveal",
	QE_OBJ_AUTO_TT = "Automatically reveal this objective when the quest is unlocked in the quest log.",
	QE_STEP = "Quest steps",
	QE_STEP_TT = "Quest are cut down into a list of steps.\nEach step can add a text entry to the quest log once reached and another history text once completed.",
	QE_STEP_ADD = "Add quest step",
	QE_STEP_NO = "No quest step",
	QE_STEP_REMOVE = "Remove this step?",
	QE_STEP_CREATE = "Please enter the step ID. You can't have two steps with the same ID within the same quest.\n\n|cffff9900Please note that the steps will be listed in alphabetical order of IDs here and on the database.\n\n|cff00ff00So it's a good practice to always start your ID by step_# where # is the step number in the quest.",
	CA_QE_ST_ID = "Change quest step ID",
	QE_STEP_EXIST = "There is already a step with the ID %s.",
	QE_STEP_NAME_NEW = "New quest step",
	QE_ST_PRE = "Quest log entry",
	QE_ST_POST = "Quest log history",
	QE_ST_AUTO_REVEAL = "Initial step",
	QE_ST_AUTO_REVEAL_TT = "Marks this step as the initial step when unlocking the quest in the quest log.",
	QE_ST_LINKS_ON_START = "On quest step start",
	QE_ST_LINKS_ON_START_TT = "Triggered |cff00ff00everytime|r the player reachs this step.",
	QE_ST_LINKS_ON_LEAVE = "On quest step leave",
	QE_ST_LINKS_ON_LEAVE_TT = "Triggered |cff00ff00everytime|r the player leave this step for another one. This will be triggered before the next step \"On quest step start\" trigger occurs.",
	QE_ST_END = "Final step",
	QE_ST_END_TT = "Marks this step as the final step for this quest. When the step is reached, the quest will automatically be marked as completed in the quest log.",
	QE_PROGRESS = "Progression",
	QE_PROGRESS_TT = "This parameter flags this quest as part of the campaign progression (even if the quest is not revealed).\n\nThe campaign progression is a % indicator in the quest log showing the global campaign progression (% of completed quests / total quests).\n\n|cff00ff00Typically this should be checked, except for side/secondary quests.",

	-- Cutscene
	DI_STEPS = "Cutscene steps",
	DI_STEP = "Cutscene step",
	DI_STEP_ADD = "Add step",
	DI_STEP_EDIT = "Cutscene step edition",
	DI_STEP_TEXT = "Step text",
	DI_ATTR_TT = "Only check this if you want to change this attribute relative to the previous cutscene step.",
	DI_NAME_DIRECTION = "Change dialog direction",
	DI_NAME_DIRECTION_TT = "Determines where to place the chat bubble and name and which model to animate. Select none to completely hide the chat bubble and name.",
	DI_NAME = "Change speaker name",
	DI_NAME_TT = "The name of the talking character.\n\nOnly necessary if the dialog direction above is not NONE.",
	DI_LEFT_UNIT = "Change left model",
	DI_RIGHT_UNIT = "Change right model",
	DI_UNIT_TT = "Sets the model to display:\n\n- Leave empty to hide the model\n- \"player\" to use the player's model\n- \"target\" to use the target's model\n- Any number to load as NPC ID",
	DI_ATTRIBUTE = "Stage modification",
	DI_BKG = "Change background image",
	DI_BKG_TT = "Will be used as background for the cutscene step. Please enter the full texture path.\n\nIf you change the background during a cutscene there will be a fade between the two different backgrounds.",
	DI_DIALOG = "Dialog",
	DI_FRAME = "Decoration",
	DI_MODELS = "Models",
	DI_IMAGE = "Change image",
	DI_IMAGE_TT = "Displays an image in the center of the cutscene frame. The image will fade in. Please enter the full texture path.\n\nTo hide the image afterward, just leave the box empty.",
	DI_LOOT = "Wait for loot",
	DI_LOOT_TT = "If the workflow selected on the left will display a loot to the player, you can check this parameter to prevent the player to go to the next cutscene step until he looted all the items.",
	DI_DISTANCE = "Distance max (yards)",
	DI_DISTANCE_TT = "Defines the max distance (in yards) the player can move away once the cutscene started before auto closing it (and trigger the 'On Cancel' object event).\n\n|cff00ff00Zero means no limit.\n\n|cffff9900Does not work in instance/battleground/arena since patch 7.1.",
	DI_END = "End point",
	DI_END_TT = "Marks this step as end point. When reached it will finish the cutscene (and triggers the On finish object event).\n\n|cff00ff00Handy if you use player choices in this cutscene.",
	DI_CHOICES = "Player choices",
	DI_CHOICES_TT = "Configure player choices for this step.",
	DI_CHOICE = "Option",
	DI_CHOICE_TT = "Enter the text for this option.\n\n|cff00ff00Leave empty to disable this option.",
	DI_CHOICE_STEP = "Go to step",
	DI_CHOICE_STEP_TT = "Enter the cutscene step number to play if the player selects this option.\n\n|cff00ff00If empty or invalid step index, it will end the cutscene if selected (and trigger the On finish object event).",
	DI_HISTORY = "Cutscenes history",
	DI_HISTORY_TT = "Click to see/hide the history panel, showing the previous cutscene lines.",
	DI_NEXT = "Next step index",
	DI_CHOICE_CONDI = "Option condition",
	DI_NEXT_TT = "You can indicate which step will be played after this one.\n\n|cff00ff00Leave empty to play the next index in sequential order, only use this field if you need to 'jump' to another index. Useful when using choices.",
	DI_CONDI_TT = "Sets a condition for this option. If the condition is not checked when showing the options, the associated option will not be visible.\n\n|cff00ff00Click: Configure condition\nRight-click: Clear condition",
	DI_LINKS_ONSTART = "On cutscene start",
	DI_LINKS_ONSTART_TT = "Triggered when the cutscene is played.\n\n|cffff9900Note that this workflow will be played BEFORE showing the first step.",
	DI_LINKS_ONEND = "On cutscene end",
	DI_LINKS_ONEND_TT = "Triggered when the cutscene is ended.\n\n|cff00ff00This can be done by reaching the end of last step or by allowing the player to select a choice with an empty or unknown 'go to step'.\n\n|cffff0000This is NOT triggered if the player cancels the cutscene by manually closing the frame.",
	DI_GET_ID = "Target ID",
	DI_GET_ID_TT = "Copy the target's NPC ID. Only works if your current target is an NPC.",


	DEBUG_QUEST_STEP = "Go to a quest step.",
	DEBUG_QUEST_STEP_USAGE = "Usage: /trp3 debug_quest_step questID stepID",
	DEBUG_QUEST_START = "Start quest",
	DEBUG_QUEST_START_USAGE = "Usage: /trp3 debug_quest_start questID",

	DISCLAIMER_OK = "I hereby sign this contract with my blood",
	DISCLAIMER =
[[{h1:c}Please read{/h1}

Creating items and quests takes time and energy and it's always terrible when you lose all the hard work you have done.

All add-ons in World of Warcraft can store data but there are limitations:

• There is an unknown data size limit for add-on data (depending on the fact that you are running a 32 or 64 bits client, among other things).
• Reaching this limit can wipe all the add-on saved data.
• Kill the process, force-closing the game client (Alt+F4) or crashing can corrupt the add-on saved data.
• Even if you exit the game correctly, there is always a chance that the game doesn't succeed to save the add-on data and corrupt it.

In regards to all of that, we STRONGLY recommand to regularely backup your add-on saved data.

You can find here a tutorial about finding all saved data:
{link*https://totalrp3.info/documentation/how_to/saved_variables*Where are my information stored?}

You can find here a tutorial about syncing your data to a cloud service:
{link*https://totalrp3.info/documentation/how_to/backup_and_sync_profiles*How to backup and synchronize your add-ons settings using a cloud service}

Please understand that we won't reply anymore to comment or ticket relative to a data wipe.
It's not because we don't want to help but because we can't do anything to restore wiped data.

Thank you, and enjoy Total RP 3 Extended!

{p:r}The TRP3 Team{/p}]],

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- TUTORIAL: Databases
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	TU_TITLE = "Tutorial",
	TU_DB_1_TEXT = [[|cff00ff00Welcome to the database tutorial.|r

This is the database, where all the objects are stored.

An object contains all information about an item, a document, a campaign/quest/step or a cutscene.]],
	TU_DB_2 = "Database types",
	TU_DB_2_TEXT = [[There are four tabs, filtering the entire database.

|cff00ff00My database:|r it contains all the objects you created.

|cff00ff00Players database:|r it contains all objects you received (or imported) from other players.

|cff00ff00Backers database:|r it contains the objects created by the Kickstarter backers and the TRP3 team.

|cff00ff00Full database:|r it contains all the previous databases content.]],
	TU_DB_3_TEXT = [[You can filter more each database to find a specific object by changing the search filters and select |cff00ff00Search|r.

Without filters, the objects list follows a hierarchical presentation.

But if you filter the list, the results are shown with a flat presentation.
Here we just filtered the list by object type to show only the |cffff9900items|r.

To exit the search mode, click on the |cff00ff00Clear|r button in the filters panel.]],
	TU_DB_4 = "Root and inner objects",
	TU_DB_4_TEXT = [[There are two kind of objects: |cff00ff00root objects and inner objects|r.

|cff00ff00Inner objects|r are always stored in a |cff00ff00root object|r (even if they can be inside another inner object all the way to the root).

When you exchange an item with someone, all the root object information is actually exchanged, even if the item is only an inner object.

So for now, just remember that using inner objects is a good way to link objects that always should be exchange together.

Examples:
- An item showing a document: the document would be an inner object of the root item object.
- A campaign with 4 quests: each quest is actually an inner object of the root campaign object.
- A gun item firing bullet item: the bullet object would be an inner object of the root gun object.

But don't worry, it will comes naturally !]],
	TU_DB_5 = "Root objects",
	TU_DB_5_TEXT = "Only items and campaigns can be root objects.\n\nYou can use these two buttons to create an new item or campaign.",
	TU_DB_6 = "Create an item",
	TU_DB_6_TEXT = [[When creating a new item, you can select a template or use the quick creation mode.

The |cff00ff00quick creation|r mode allows you to easily create a first item, but the possibilities are limited. Now that you can always go to normal creation mode afterward.

Use the |cff00ff00blank item|r template if you want to start from scratch without any example.

The |cff00ff00document item|r template will actually create two objects: an item object and its document inner object. It will also configure the item to show the document when used.

The |cff00ff00container item|r template will create a configure an item object to be used as a container.

Finally, the |cff00ff00create from|r allows you to duplicate an existing item.]],
	TU_DB_7 = "Object line",
	TU_DB_7_TEXT = "Each line represents an object. You can click on it to edit it or right click to perform various actions.",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- TUTORIAL: Items
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	TU_IT_1_TEXT = [[|cff00ff00Welcome to the item creation tutorial.|r

An item is an object that you can store in your character's inventory (or drop it on the ground).

You are here on the Main tab where you can define all the basic attributes for your item.]],

	TU_IT_2 = "Display attributes",
	TU_IT_2_TEXT = [[The display attributes are purely cosmetic and don't have any "gameplay" effect.

It's all about the attributes needed for the item tooltip and the item icon.]],

	TU_IT_4 = "Gameplay attributes",
	TU_IT_4_TEXT = [[The gameplay attributes have some effects on the gameplay.

Two attributes are important: |cff00ff00Usable|r and |cff00ff00Container|r as checking them will display the |cff00ff00Workflow|r and |cff00ff00Container|r tabs.]],

	TU_IT_3 = "Free notes",
	TU_IT_3_TEXT = [[You can write down notes to help you remember what do you want to do with your item.

These notes can also help others that would want to start an item based on yours.]],

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- TUTORIAL: Workflow
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	TU_WO_1_TEXT = [[|cff00ff00Welcome to the workflow creation tutorial.|r

A workflow is the mechanism that can bring life to your creation. It's here that you will be able to play effects like showing a text, playing a sound or looting an item to the player.]],

	TU_WO_2 = "Workflow list",
	TU_WO_2_TEXT = [[On the left you have the |cff00ff00workflows list|r.

You can remove, rename or copy/paste a workflow by right-clicking on it.

|cffff9900Note: If you are here when editing an item in "normal mode", you won't see a list of workflows but only a single "On use" workflow for the item. If you want to be able to use multiple workflows for an item, you can convert this item to "Expert mode" by right-clicking on it in the databases view.]],

	TU_WO_3_TEXT = [[Here is a list of all the workflow elements.

An element can be an effect, a delay or a condition.

The element order is important because they will be executed sequentially during the workflow execution.

You can change the element order by using the arrows at the top right of each elements.]],

	TU_WO_4 = "Add an effect",
	TU_WO_4_TEXT = [[Effects are things like "playing a sound", "displaying a text" or "start a cutscene".

There are a LOT of effects, each are explained in their own tooltip!]],

	TU_WO_5 = "Add a condition",
	TU_WO_5_TEXT = [[Conditions allow you to |cff00ff00test values in order to stop the workflow execution.|r

|cffff9900If the condition is not met, the workflow execution won't continue further.|r

A condition is composed of a series of tests linked together by the OR or AND operator.

Each test is a values comparision. For example: "The target's health is lesser than 500", "The player is not dead" or "The player has more than 3 units of item [xxx] in his inventory".]],

	TU_WO_6 = "Add a delay",
	TU_WO_6_TEXT = [[Delays can pause the execution of the workflow for a given time, but they can also act as a cast and interrupt the workflow if the player moves.]],

	TU_WO_ERROR_1 = "Please create a workflow before resuming this tutorial.",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- TUTORIAL: container
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	TU_CO_1_TEXT = [[A container is an item that can contain other items.

To open a container, you can |cff00ff00double-click|r on it in the inventory.

It is possible to have a container that is also usable (by right-click). It isn't two exclusive concepts.

|cffff9900Please note that for now, you can only trade with players containers that are empty, or that contains only items that are inner objects of the container. Please see the inner object tab for more information.]],

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- TUTORIAL: Links
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	TU_EL_1_TEXT = [[The event links tab is the place where you can |cff00ff00link your workflows to events|r.

|cffff9900Indeed, workflows aren't executed automatically by default!|r So you have to link them to an event in order to have them executed when that event occurs.

We have here two type of events: |cff00ff00Object events and Game events|r.]],

	TU_EL_2_TEXT = [[|cff00ff00Object events|r are event proper to how Total RP 3 works.

The list of possible events is fixed and depends on the type of the object (item, quest ..etc).

You can link one event to only one workflow. But the same workflow can be linked to multiple events.]],

	TU_EL_3_TEXT = [[|cff00ff00Game events|r are events triggered by the game when something happens.

Each link you add will link a game event to a workflow. Each time the event occurs, the workflow will be executed.

|cff00ff00You can add a condition to the link by Ctrl+click on it.|r The condition will have access to the event arguments to be tested.
For example if you listen to the event of casting a spell, you will be able in the condition to test which spell is casted.

|cffff9900There is a large list of game event, thus it wouldn't be for us to list them all in the add-on. We suggest you to consult webwite like wowwiki.
http://wowwiki.wikia.com/wiki/Event_API]],

	TU_EL_4_TEXT = [[|cff00ff00Game events|r are only available for campaigns, quests and quest steps.]],

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- TUTORIAL: actions
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	TU_AC_1_TEXT = [[|cff00ff00Action links|r is where you can link a workflow to a quest action.

There are four types of quest actions that a player can perform: |cff00ff00listen, look, talk and interact|r.

You can define action links in the campaign, quest or quest step level.]],

	TU_AC_2 = "Actions evaluation",

	TU_AC_2_TEXT = [[Each action can be conditionned by |cff00ff00Ctrl+click on it|r.

When the player performs an action, |cff00ff00all action links will be evaluated in a certain order|r beginning at the quest step level, then the quest and finally the campaign.

If a link can be used (if it's from the good action type and has no condition or the condition is met), then the associated workflow will be executed and |cffff9900the add-on will stop searching for another link|r.]],

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- TUTORIAL: Cutscene
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	TU_CS_1_TEXT = [[With |cff00ff00cutscenes|r you will be able to create a real narative experience for the player.

Cutscenes uses the layout already used in the Storyline add-on.]],

	TU_CS_2_TEXT = [[A cutscene is a list of step that will be played one after another.

The cutscene takes place in a scene with two characters talking to each other.

In each step you will be able to completely reconfigure the scene.]],

	TU_CS_3_TEXT = [[The step text will be cut down into sub-steps when you enter a double line break. But these sub-steps will share the same step configuration.

So you will typically change step when you want to change which character is speaking (with the "dialog direction" attribute).

When you want to change a step attribute, |cff00ff00be sure to have activated the parameter.]],

	TU_CS_4 = "Cutscenes and workflows",
	TU_CS_4_TEXT = [[You can link a workflow to a step. It will be executed a the start of the step (or first sub-step).

If this workflow contains a Loot effect, you can check the "Wait for loot" option to force the player to loot before the cutscene can continue.]],

	TU_CS_5 = "Preview",
	TU_CS_5_TEXT = [[You can preview your cutscene at any moment.

|cffff9900Linked workflows won't be executed in preview mode.]],

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- TUTORIAL: Inventory
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	INV_TU_1 = [[You can place an item (or a stack of items) in each slot of the inventory.

|cff00ff00You are not limited in capacity as you can have an unlimited amount of bags and containers. You can also have containers in containers.

|cffff9900The only thing you should be careful with is the carry weight of each container.|r

If a container has a maximum weight capacity and you overpass this capacity, it will slowly be damaged over time and could randomly drop items on the ground!]],

	INV_TU_2 = [[Any bag you place here will act as primary container.

|cffff9900It's very important to always have a primary container with free space as it will be the container used when exchanging items with other players.

|cff00ff00Also, the primary container can easily be opened with the inventory button on the TRP toolbar.]],

	INV_TU_3 = [[For items that are directly on the character (not in a bag), if they are wearable (which is a choice from the item author), |cff00ff00you can indicates where they are in your character.

|cffff9900For that click on the dot near the item and place the marker on your character. You can also rotate your character and select his pose.

|cff00ff00When someone uses the inspection feature on you, they will see the markers with the proper character pose!

|rYou can inspect someone's inventory by selecting the character and click on the target bar button |cff00ff00"Character inspection"|r.

|cffff9900Note that the two players must use TRP Extended to be able to inspect each other.]],

	INV_TU_4 = [[When drag & droping an item outside the inventory, |cffff9900you will be asked to choose between destroying it or droping it on the ground.|r

You can drop items (almost) everywhere in the world. |cff00ff00You can then go loot them back later by using the "Search for items" button on the toolbar.

You can also see all droped items on the map by using the "Scan for my items" button.

|cffff9900Note that sometimes items can be droped automatically: if you receive items but your inventory is full, or if one of your bags is damaged.]],

	INV_TU_5 = [[You can exchange an item (or a stack of items) with another player by drag & drop the stack on the player (just like the game does).

|cffff9900When someone give you an item, the exchange frame will tell you if the item could possibly have annoying effects (nobody want their character to shout horrible things).

|rWhen that's the case, TRP will convert these effects into a less damaging form (for instance, the shouting will be converted to a personal text) until you decide to unblock them.

|cff00ff00You can block/unblock effects and white-list effects or players by Alt + Right-click on an item on your inventory.]],

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- TUTORIAL: Quest log
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	QUEST_TU_1 = [[Quests will often require that |cff00ff00you interact with NPCs or with your environment through actions|r.

There are four types of action: |cff00ff00Listen, look, talk and interact|r.

You can perform an action by |cff00ff00right-clicking on the quest log button on the TRP3 toolbar|r.

But another easier way to do actions is to |cff00ff00create macro for it|r. To help you create the action macros you can use this button.]],

	QUEST_TU_2 = [[|cff00ff00You can find here a list of all available campaigns.|r

A campaign is a collection of one or more quests.

|cffff9900You can only progress in one campaign at a time|r. For this you must mark this campaign as the active campaign. |cff00ff00You can use the "Start or resume" button to activate or pause a campaign.|r

You won't lose your progression if you switch from one campaign to another.

|cffff9900You can reset your progression in a campaign by right-clicking on it and select Reset campaign. Note that all looted items won't be lost on campaign reset.]],

	QUEST_TU_3 = [[|cff00ff00You can find here the list of all currently available quests and all finished quests.|r

You can easily see each quest current situation and what are the current objectives.]],

	QUEST_TU_4 = [[|cff00ff00You can find here the current progression of this quest and all current objectives.|r

You can also see the history of previous steps, in case you forget something.]],

};

TRP3_KS_BACKERS =
[[#Total RP 3: Extended (version %s)

Created by |cff00ff00Sylvain "Telkostrasz" Cossement|r and |cff00ff00Renaud "Ellypse" Parize|r.

## To all our Kickstarter backers: many thanks for the support!

- Abyssaloth
- Alex Stromboli (Strom)
- Alex Villescas
- Alexander Salminen
- Andrew P. Thayer
- Andy Austin Polycarp Tymczyszyn
- Antonio Campos jr from McAllen Texas
- Arranax
- Ashley Ann
- Austin Lang
- Brendan Steward
- Caleb Peyton
- Cave
- Charles Gingras
- Cheezedogg
- Chris Magalee
- Christine Brandon
- Colin Stent
- Dave
- Dwargoth 
- Dylan Garrett
- Edward Ryan
- Ella
- Erzan
- Fannar Vilhelmsson
- GreenGrass
- Herman Duyker
- James Lofshult ((Solav))
- James Turner
- Juan
- Kaeril
- Kerry PMack
- Keti
- Kevin Kerrigan
- krinklebearcat
- Kristin Aurora Brayman
- Laerith
- Laleila
- Lilithsahl from Moon Guard US
- Linreia 
- Lium Alxcen
- Lodjay
- Maethi
- Managan Southpaw
- Manuel Robador Merino
- Max Juchheim
- Meg Karper
- Miajensen 
- Michael Bell
- MisticTiger
- Nat
- Nicolo Dresp
- Nimsy
- Orion Cain
- Patrick D Fletcher
- Paul Corlay
- Phahi
- Rob G
- Robinson Gracely
- Rocky Aldridge
- Ryan McGilloway
- Ryldor
- Sachiel
- Saelora
- Samaramon
- Sean "Pommie" K
- Selendis
- Simon Abadei
- Sindaru
- Soraptor
- Sunkara
- Taurii from House of Crows of Wyrmrest Accord
- TeegeeUK
- thedreameater
- Thêmys
- Thomas
- Thomas Laurberg Sørensen
- Valnoressa
- Victor Nilsson
- Vinayack 
- W. Kristoph "Calmorlayne" Nolen
- Weston R. Haring
- Yann
- Ydara
- Zach Platzer
- Zack Wannemacher
- Zencore

##  You are the best!]];