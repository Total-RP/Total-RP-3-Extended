max_line_length = false

exclude_files = {
	"totalRP3_Extended/Libs",
	"Types",
};

ignore = {
	-- Ignore global writes/accesses/mutations on anything prefixed with
	-- "TRP3_". This is the standard prefix for all of our global frame names
	-- and mixins.
	"11./^TRP3_",

	-- Ignore unused self. This would popup for Mixins and Objects
	"212/self",
};

globals = {
	"AddOn_TotalRP3",
	"Ellyb",

	-- Globals
	"BINDING_NAME_TRP3_EXTENDED_TOOLS",
	"BINDING_NAME_TRP3_INVENTORY",
	"BINDING_NAME_TRP3_MAIN_CONTAINER",
	"BINDING_NAME_TRP3_QUESTLOG",
	"BINDING_NAME_TRP3_QUEST_ACTION",
	"BINDING_NAME_TRP3_QUEST_LISTEN",
	"BINDING_NAME_TRP3_QUEST_LOOK",
	"BINDING_NAME_TRP3_QUEST_TALK",
	"BINDING_NAME_TRP3_SEARCH_FOR_ITEMS",
	"BINDING_NAME_TRP3_STASHES_LOOKUP",
};

read_globals = {
	-- Libraries/AddOns
	"LibStub",
};

std = "lua51+wow";

stds.wow = {
	-- Globals that we mutate.
	globals = {
		"StaticPopupDialogs",
		"UISpecialFrames",
	},

	-- Globals that we access.
	read_globals = {
		-- Lua function aliases and extensions

		string = {
			fields = {
				"join",
			},
		},

		table = {
			fields = {
				"wipe",
			},
		},

		"date",
		"floor",
		"min",
		"mod",
		"sqrt",
		"strcmputf8i",
		"strconcat",
		"strjoin",
		"strlen",
		"strsplit",
		"strtrim",
		"tContains",
		"time",
		"tinsert",
		"tInvert",
		"tremove",
		"wipe",

		-- Global Functions

		AnchorUtil = {
			fields = {
				"CreateAnchor",
				"CreateGridLayout",
				"GridLayoutFactoryByCount",
			},
		},

		ChatFrameUtil = {
			fields = {
				"GetActiveWindow",
			},
		},

		C_AddOns = {
			fields = {
				"IsAddOnLoaded",
			},
		},

		C_ChatInfo = {
			fields = {
				"PerformEmote",
				"SendChatMessage",
			},
		},

		C_CurrencyInfo = {
			fields = {
				"GetCoinTextureString",
			},
		},

		C_Housing = {
			fields = {
				"GetCurrentHouseInfo",
				"GetCurrentNeighborhoodGUID",
			},
		},

		C_Item = {
			fields = {
				"GetItemInfo",
			},
		},

		C_Map = {
			fields = {
				"GetBestMapForUnit",
			},
		},

		C_MountJournal = {
			fields = {
				"GetMountInfoByID",
				"GetMountInfoExtraByID",
				"SummonByID",
			},
		},

		C_PetJournal = {
			fields = {
				"GetSummonedPetGUID",
				"SummonPetByGUID",
				"SummonRandomPet",
			},
		},

		C_Secrets = {
			fields = {
				"ShouldUnitIdentityBeSecret",
			},
		},

		C_Timer = {
			fields = {
				"After",
				"NewTicker",
				"NewTimer",
			},
		},

		C_ToyBox = {
			fields = {
				"GetToyLink",
			},
		},

		InputUtil = {
			fields = {
				"IsMouseOver",
			},
		},

		"Ambiguate",
		"APIDocumentation_LoadUI",
		"CameraZoomIn",
		"CameraZoomOut",
		"canaccessvalue",
		"CastingBarFrame_ApplyAlpha",
		"CastingBarFrame_FinishSpell",
		"CastingBarFrame_GetEffectiveStartColor",
		"ChatEdit_GetActiveWindow",
		"CheckInteractDistance",
		"ColorManager",
		"CombatLogGetCurrentEventInfo",
		"CopyTable",
		"CountTable",
		"CreateFrame",
		"CreateFramePool",
		"CreateFromMixins",
		"CreateMacro",
		"DismissCompanion",
		"DoEmote",
		"Enum",
		"EventRegistry",
		"GetAchievementInfo",
		"GetCVar",
		"GetGuildInfo",
		"GetMacroIndexByName",
		"GetMouseFoci",
		"GetNormalizedRealmName",
		"GetNumMacros",
		"GetPlayerInfoByGUID",
		"GetSpellBookItemName",
		"GetSpellInfo",
		"GetTime",
		"GetUnitSpeed",
		"hooksecurefunc",
		"IsAltKeyDown",
		"IsControlKeyDown",
		"IsInInstance",
		"IsModifiedClick",
		"issecurevariable",
		"IsShiftKeyDown",
		"Mixin",
		"NavBar_AddButton",
		"NavBar_ButtonOnEnter",
		"NavBar_ButtonOnLeave",
		"NavBar_Initialize",
		"NavBar_Reset",
		"nop",
		"PickupMacro",
		"ReloadUI",
		"ResetCursor",
		"SaveView",
		"SetCursor",
		"SetView",
		"SpellBook_GetSpellBookSlot",
		"StackSplitFrameLeft_Click",
		"StackSplitFrameRight_Click",
		"StaticPopup_Show",
		"TableHasAnyEntries",
		"TableIsEmpty",
		"ToggleFrame",
		"ToggleSheath",
		"UIDropDownMenu_Initialize",
		"UnitClass",
		"UnitExists",
		"UnitFactionGroup",
		"UnitInParty",
		"UnitInRaid",
		"UnitIsPlayer",
		"UnitIsUnit",
		"UnitName",
		"UnitPosition",
		"UnitRace",
		"UnitSex",

		-- Global Mixins and UI Objects

		GridLayoutMixin = {
			fields = {
				Direction = {
					fields = {
						"TopLeftToBottomRightVertical",
						"TopRightToBottomLeft",
						"TopRightToBottomLeftVertical",
					},
				},
			},
		},

		SecondsFormatter = {
			fields = {
				Abbreviation = {
					fields = {
						"OneLetter",
					},
				},
			},
		},

		"APIDocumentation",
		"ChatFontNormal",
		"ChatTypeInfo",
		"DestinyFontHuge",
		"GameFontNormal",
		"GameFontNormalLarge",
		"GameFontNormalSmall",
		"GameTooltip",
		"GameTooltipHeader",
		"ModelFrameMixin",
		"ObjectiveTrackerFrame",
		"PlayerCastingBarFrame",
		"QuestFont_Huge",
		"SecondsFormatterMixin",
		"SpellBookFrame",
		"StackSplitFrame",
		"TargetFrame",
		"UIParent",
		"WorldMapFrame",

		-- Global Constants

		"BROWSE",
		"CANCEL",
		"CASTING_BAR_ALPHA_STEP",
		"CASTING_BAR_FLASH_STEP",
		"CASTING_BAR_HOLD_TIME",
		"CAST_BAR_CAST_TIME",
		"CHARACTER",
		"DELETE",
		"EmoteList",
		"ERR_BAG_FULL",
		"ERR_DROP_BOUND_ITEM",
		"ERR_ITEM_COOLDOWN",
		"ERR_TRADE_BOUND_ITEM",
		"ERR_TRADE_CANCELLED",
		"HTML_END",
		"HTML_START",
		"INTERRUPTED",
		"INVENTORY_TOOLTIP",
		"ITEM_BIND_QUEST",
		"ITEM_CREATED_BY",
		"ITEM_QUALITY0_DESC",
		"ITEM_QUALITY1_DESC",
		"ITEM_QUALITY2_DESC",
		"ITEM_QUALITY3_DESC",
		"ITEM_QUALITY4_DESC",
		"ITEM_QUALITY5_DESC",
		"ITEM_QUALITY6_DESC",
		"ITEM_QUALITY7_DESC",
		"ITEM_SOULBOUND",
		"ITEM_UNIQUE",
		"MAXEMOTEINDEX",
		"PROFESSIONS_USED_IN_COOKING",
		"QUEST_LOG",
		"QUEST_OBJECTIVES",
		"RED_FONT_COLOR",
		"REMOVE",
		"RESET",
		"SAVE",
		"SEARCH",
		"SECURITY_LEVEL",
		"SPELL_FAILED_AFFECTING_COMBAT",
		"SPELL_FAILED_BAD_IMPLICIT_TARGETS",
		"SPELL_FAILED_CASTER_AURASTATE",
		"SPELL_FAILED_MOVING",
		"TextEmoteSpeechList",
		"TRADE",
		"UNKNOWN",
		"UNKNOWNOBJECT",
		"USE",
		"WHITE_FONT_COLOR",
	},
};
