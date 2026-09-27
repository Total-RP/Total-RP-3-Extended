local _, addon = ...

-- TODO: various constants are collected here for now.
-- Some may be better placed in totalRP3_Extended or even totalRP3

addon.constants = {
	AURA_DURATION_DEFAULT            = 300,    -- initial and fallback value for aura duration
	AURA_INTERVAL_DEFAULT            = 10,     -- initial and fallback value for aura tick frequency
	AURA_INTERVAL_MIN                = 0.1,    -- minimum permissible aura tick frequency
	ITEM_PICK_SOUND_DEFAULT          = 1186,   -- "food"
	ITEM_DROP_SOUND_DEFAULT          = 1203,   -- "food"
	ITEM_STACK_COUNT_DEFAULT         = 20,     -- initial and fallback value for max item stack size
	ITEM_UNIQUE_COUNT_DEFAULT        = 1,      -- initial and fallback value for max item count
	ITEM_BAG_SIZE_DEFAULT            = "5x4",
	DOCUMENT_HEIGHT_DEFAULT          = 600,
	DOCUMENT_WIDTH_DEFAULT           = 450,
	DOCUMENT_FONT_H1_DEFAULT         = "DestinyFontHuge",
	DOCUMENT_FONT_H2_DEFAULT         = "QuestFont_Huge",
	DOCUMENT_FONT_H3_DEFAULT         = "GameFontNormalLarge",
	DOCUMENT_FONT_P_DEFAULT          = "GameTooltipHeader",
	DOCUMENT_PAGE_BG_DEFAULT         = 8,      -- background id
	OBJECT_ICON_DEFAULT              = "TEMP", -- general default for various user-defined icons, TODO: revisit this when switching to icon ids
	UI_POPUP_MENU_MAX_HEIGHT         = 400,
	UI_EDITOR_AUTO_EXPAND_ALL_LIMIT  = 20,     -- maximum object threshold in a creation to show the entire tree
	MAX_CHARACTERS_IN_MACRO          = 255,
	SUPPOSED_SERIAL_SIZE_LIMIT       = 500000, -- We suppose the text field can only handle 500k pastes
	DATABASE_AUTO_SEARCH_MAX_COUNT   = 1000,   -- Maximum result set size for "filter as you type" function to avoid lag. If the result set gets too large, the user need to hit enter
};
