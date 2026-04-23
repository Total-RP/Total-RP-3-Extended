local _, addon = ...
local loc = TRP3_API.loc;

function addon.script.registerBuiltinOperands()

	local fmt = addon.script.formatParameter;

	-- LITERALS -- TODO: a literal is taggable if the operand is non-numeric, that's very inconsistent
	addon.script.registerOperand({
		id          = "literal_string",
		title       = loc.OP_DIRECT_VALUE .. " " .. loc.OP_STRING,
		description = loc.OP_DIRECT_VALUE .. " " .. loc.OP_STRING,
		GetPreview  = function(self, operand, value) return fmt(self.parameters[1], value); end,
		returnType  = "string",
		literal     = true,
		parameters  = {
			{
				title       = "Value",
				description = "Value",
				type        = "string",
				default     = ""
			},
		}
	});

	addon.script.registerOperand({
		id          = "literal_number",
		title       = loc.OP_DIRECT_VALUE .. " " .. loc.OP_NUMERIC,
		description = loc.OP_DIRECT_VALUE .. " " .. loc.OP_NUMERIC,
		GetPreview  = function(self, operand, value) return fmt(self.parameters[1], value); end,
		returnType  = "number",
		literal     = true,
		parameters  = {
			{
				title       = "Value",
				description = "Value",
				type        = "number",
				default     = 0
			},
		}
	});

	addon.script.registerOperand({
		id          = "literal_boolean",
		title       = loc.OP_DIRECT_VALUE .. " " .. loc.OP_BOOL,
		description = loc.OP_DIRECT_VALUE .. " " .. loc.OP_BOOL,
		GetPreview  = function(self, operand, value) return fmt(self.parameters[1], value); end,
		returnType  = "boolean",
		literal     = true,
		parameters  = {
			{
				title       = "Value",
				description = "Value",
				type        = "boolean",
				default     = true,
				values      = {
					{true,  loc.OP_BOOL_TRUE},
					{false, loc.OP_BOOL_FALSE}
				}
			},
		}
	});

	-- UNIT
	local unaryUnitOperands = {
		{"unit_name"            , loc.OP_OP_UNIT_NAME            , loc.OP_OP_UNIT_NAME_TT            , "string" , loc.OP_UNIT_VALUE},
		{"unit_id"              , loc.OP_OP_UNIT_ID              , loc.OP_OP_UNIT_ID_TT              , "string" , loc.OP_UNIT_VALUE},
		{"unit_npc_id"          , loc.OP_OP_UNIT_NPC_ID          , loc.OP_OP_UNIT_NPC_ID_TT          , "string" , loc.OP_UNIT_VALUE},
		{"unit_guid"            , loc.OP_OP_UNIT_GUID            , loc.OP_OP_UNIT_GUID_TT            , "string" , loc.OP_UNIT_VALUE},
		{"unit_guild"           , loc.OP_OP_UNIT_GUILD           , loc.OP_OP_UNIT_GUILD_TT           , "string" , loc.OP_UNIT_VALUE},
		{"unit_guild_rank"      , loc.OP_OP_UNIT_GUILD_RANK      , loc.OP_OP_UNIT_GUILD_RANK_TT      , "string" , loc.OP_UNIT_VALUE},
		{"unit_race"            , loc.OP_OP_UNIT_RACE            , loc.OP_OP_UNIT_RACE_TT            , "string" , loc.OP_UNIT_VALUE},
		{"unit_class"           , loc.OP_OP_UNIT_CLASS           , loc.OP_OP_UNIT_CLASS_TT           , "string" , loc.OP_UNIT_VALUE},
		{"unit_sex"             , loc.OP_OP_UNIT_SEX             , loc.OP_OP_UNIT_SEX_TT             , "string" , loc.OP_UNIT_VALUE},
		{"unit_faction"         , loc.OP_OP_UNIT_FACTION         , loc.OP_OP_UNIT_FACTION_TT         , "string" , loc.OP_UNIT_VALUE},
		{"unit_creature_type"   , loc.OP_OP_UNIT_CREATURE_TYPE   , loc.OP_OP_UNIT_CREATURE_TYPE_TT   , "string" , loc.OP_UNIT_VALUE},
		{"unit_creature_family" , loc.OP_OP_UNIT_CREATURE_FAMILY , loc.OP_OP_UNIT_CREATURE_FAMILY_TT , "string" , loc.OP_UNIT_VALUE},
		{"unit_classification"  , loc.OP_OP_UNIT_CLASSIFICATION  , loc.OP_OP_UNIT_CLASSIFICATION_TT  , "string" , loc.OP_UNIT_VALUE},
		{"unit_health"          , loc.OP_OP_UNIT_HEALTH          , loc.OP_OP_UNIT_HEALTH_TT          , "number" , loc.OP_UNIT_VALUE},
		{"unit_level"           , loc.OP_OP_UNIT_LEVEL           , loc.OP_OP_UNIT_LEVEL_TT           , "number" , loc.OP_UNIT_VALUE},
		{"unit_speed"           , loc.OP_OP_UNIT_SPEED           , loc.OP_OP_UNIT_SPEED_TT           , "number" , loc.OP_UNIT_VALUE},
		{"unit_position_x"      , loc.OP_OP_UNIT_POSITION_X      , loc.OP_OP_UNIT_POSITION_X_TT      , "number" , loc.OP_UNIT_VALUE},
		{"unit_position_y"      , loc.OP_OP_UNIT_POSITION_Y      , loc.OP_OP_UNIT_POSITION_Y_TT      , "number" , loc.OP_UNIT_VALUE},
		{"unit_distance_me"     , loc.OP_OP_DISTANCE_ME          , loc.OP_OP_DISTANCE_ME_TT          , "number" , loc.OP_UNIT_VALUE},
		{"unit_exists"          , loc.OP_OP_UNIT_EXISTS          , loc.OP_OP_UNIT_EXISTS_TT          , "boolean", loc.OP_UNIT_TEST},
		{"unit_is_player"       , loc.OP_OP_UNIT_ISPLAYER        , loc.OP_OP_UNIT_ISPLAYER_TT        , "boolean", loc.OP_UNIT_TEST},
		{"unit_is_dead"         , loc.OP_OP_UNIT_DEAD            , loc.OP_OP_UNIT_DEAD_TT            , "boolean", loc.OP_UNIT_TEST},
		{"unit_distance_trade"  , loc.OP_OP_UNIT_DISTANCE_TRADE  , loc.OP_OP_UNIT_DISTANCE_TRADE_TT  , "boolean", loc.OP_UNIT_TEST},
		{"unit_distance_inspect", loc.OP_OP_UNIT_DISTANCE_INSPECT, loc.OP_OP_UNIT_DISTANCE_INSPECT_TT, "boolean", loc.OP_UNIT_TEST},
	};

	for index, template in ipairs(unaryUnitOperands) do
		addon.script.registerOperand({
			id          = template[1],
			title       = template[2],
			description = template[3],
			GetPreview  = function(self, operand, unitId) return (template[2] .. " (%s)"):format(fmt(self.parameters[1], unitId)); end,
			returnType  = template[4],
			category    = template[5],
			parameters  = {
				{
					title       = loc.OP_UNIT,
					description = loc.OP_UNIT,
					type        = "string",
					default     = "target",
					values      = {
						{"player", loc.OP_UNIT_PLAYER},
						{"target", loc.OP_UNIT_TARGET},
						{"npc"   , loc.OP_UNIT_NPC}
					}
				}
			}
		});
	end

	addon.script.registerOperand({
		id          = "unit_distance_point",
		title       = loc.OP_OP_DISTANCE_POINT,
		description = loc.OP_OP_DISTANCE_POINT_TT,
		GetPreview  = function(self, operand, unitId, y, x)
			return loc.OP_OP_DISTANCE_POINT_PREVIEW:format(
				fmt(self.parameters[1], unitId),
				fmt(self.parameters[3], x), -- sic, X and Y are flipped
				fmt(self.parameters[2], y)
			); 
		end,
		returnType  = "number",
		category    = loc.OP_UNIT_VALUE,
		parameters  = {
			{
				title       = loc.OP_UNIT,
				description = loc.OP_UNIT,
				type        = "string",
				default     = "target",
				values      = {
					{"player", loc.OP_UNIT_PLAYER},
					{"target", loc.OP_UNIT_TARGET},
					{"npc"   , loc.OP_UNIT_NPC}
				}
			},
			{
				title       = loc.OP_OP_DISTANCE_Y,
				description = loc.OP_OP_DISTANCE_Y,
				type        = "coordinate",
				default     = 0,
				groupId     = "coordinate",
				memberIndex = 2
			},
			{
				title       = loc.OP_OP_DISTANCE_X,
				description = loc.OP_OP_DISTANCE_X,
				type        = "coordinate",
				default     = 0,
				groupId     = "coordinate",
				memberIndex = 1
			},
		}
	});

	-- CHARACTER
	local nullaryCharacterOperands = {
		{"char_falling"      , loc.OP_OP_CHAR_FALLING      , loc.OP_OP_CHAR_FALLING_TT     , "boolean"},
		{"char_stealth"      , loc.OP_OP_CHAR_STEALTH      , loc.OP_OP_CHAR_STEALTH_TT     , "boolean"},
		{"char_flying"       , loc.OP_OP_CHAR_FLYING       , loc.OP_OP_CHAR_FLYING_TT      , "boolean"},
		{"char_mounted"      , loc.OP_OP_CHAR_MOUNTED      , loc.OP_OP_CHAR_MOUNTED_TT     , "boolean"},
		{"char_resting"      , loc.OP_OP_CHAR_RESTING      , loc.OP_OP_CHAR_RESTING_TT     , "boolean"},
		{"char_swimming"     , loc.OP_OP_CHAR_SWIMMING     , loc.OP_OP_CHAR_SWIMMING_TT    , "boolean"},
		{"char_indoors"      , loc.OP_OP_CHAR_INDOORS      , loc.OP_OP_CHAR_INDOORS_TT     , "boolean"},
		{"char_facing"       , loc.OP_OP_CHAR_FACING       , loc.OP_OP_CHAR_FACING_TT      , "number"},
		{"char_zone"         , loc.OP_OP_CHAR_ZONE         , loc.OP_OP_CHAR_ZONE_TT        , "string"},
		{"char_subzone"      , loc.OP_OP_CHAR_SUBZONE      , loc.OP_OP_CHAR_SUBZONE_TT     , "string"},
		{"char_minimap"      , loc.OP_OP_CHAR_MINIMAP      , loc.OP_OP_CHAR_MINIMAP_TT     , "string"},
		{"char_cam_distance" , loc.OP_OP_CHAR_CAM_DISTANCE , loc.OP_OP_CHAR_CAM_DISTANCE_TT, "number"},
	};
	
	for index, template in ipairs(nullaryCharacterOperands) do
		addon.script.registerOperand({
			id          = template[1],
			title       = template[2],
			description = template[3],
			GetPreview  = function() return template[2]; end,
			returnType  = template[4],
			category    = CHARACTER
		});
	end

	addon.script.registerOperand({
		id          = "char_achievement",
		title       = loc.OP_OP_CHAR_ACHIEVEMENT,
		description = loc.OP_OP_CHAR_ACHIEVEMENT_TT,
		GetPreview  = function(self, operand, typeId, achievementId) 
			return loc.OP_OP_CHAR_ACHIEVEMENT_PREVIEW:format(
				fmt(self.parameters[2], achievementId),
				fmt(self.parameters[1], typeId)
			); 
		end,
		returnType  = "boolean",
		category    = CHARACTER,
		parameters  = {
			{
				title       = loc.OP_OP_CHAR_ACHIEVEMENT_WHO,
				description = loc.OP_OP_CHAR_ACHIEVEMENT_WHO, -- TODO
				type        = "string",
				default     = "account",
				values      = {
					{"account"  , loc.OP_OP_CHAR_ACHIEVEMENT_ACC , loc.OP_OP_CHAR_ACHIEVEMENT_ACC_TT},
					{"character", loc.OP_OP_CHAR_ACHIEVEMENT_CHAR, loc.OP_OP_CHAR_ACHIEVEMENT_CHAR_TT},
				}
			},
			{
				title       = loc.OP_OP_CHAR_ACHIEVEMENT_ID,
				description = loc.OP_OP_CHAR_ACHIEVEMENT_ID_TT,
				type        = "achievement",
				default     = 0
			},
		}
	});

	-- INVENTORY
	addon.script.registerOperand({
		id          = "inv_item_name",
		title       = loc.OP_OP_INV_NAME,
		description = loc.OP_OP_INV_NAME_TT,
		GetPreview  = function(self, operand, itemId) return loc.OP_OP_INV_NAME_PREVIEW:format(fmt(self.parameters[1], itemId)); end,
		returnType  = "string",
		category    = loc.INV_PAGE_CHARACTER_INV,
		parameters  = {
			{
				title       = loc.ITEM_ID,
				description = loc.EFFECT_ITEM_SOURCE_ID,
				type        = "item",
				default     = "",
				taggable    = true
			},
		}
	});

	addon.script.registerOperand({
		id          = "inv_item_icon",
		title       = loc.OP_OP_INV_ICON,
		description = loc.OP_OP_INV_ICON_TT,
		GetPreview  = function(self, operand, itemId) return loc.OP_OP_INV_ICON_PREVIEW:format(fmt(self.parameters[1], itemId)); end,
		returnType  = "string",
		category    = loc.INV_PAGE_CHARACTER_INV,
		parameters  = {
			{
				title       = loc.ITEM_ID,
				description = loc.EFFECT_ITEM_SOURCE_ID,
				type        = "item",
				default     = "",
				taggable    = true
			},
		}
	});

	addon.script.registerOperand({
		id          = "inv_item_quality",
		title       = loc.OP_OP_INV_QUALITY,
		description = loc.OP_OP_INV_QUALITY_TT,
		GetPreview  = function(self, operand, itemId) return loc.OP_OP_INV_QUALITY_PREVIEW:format(fmt(self.parameters[1], itemId)); end,
		returnType  = "string",
		category    = loc.INV_PAGE_CHARACTER_INV,
		parameters  = {
			{
				title       = loc.ITEM_ID,
				description = loc.EFFECT_ITEM_SOURCE_ID,
				type        = "item",
				default     = "",
				taggable    = true
			},
		}
	});

	addon.script.registerOperand({
		id          = "inv_item_id_weight",
		title       = loc.OP_OP_INV_ITEM_WEIGHT,
		description = loc.OP_OP_INV_ITEM_WEIGHT_TT,
		GetPreview  = function(self, operand, itemId) return loc.OP_OP_INV_ITEM_WEIGHT_PREVIEW:format(fmt(self.parameters[1], itemId)); end,
		returnType  = "string",
		category    = loc.INV_PAGE_CHARACTER_INV,
		parameters  = {
			{
				title       = loc.ITEM_ID,
				description = loc.EFFECT_ITEM_SOURCE_ID,
				type        = "item",
				default     = "",
				taggable    = true
			},
		}
	});

	addon.script.registerOperand({
		id          = "inv_item_value",
		title       = loc.OP_OP_INV_VALUE,
		description = loc.OP_OP_INV_VALUE_TT,
		GetPreview  = function(self, operand, itemId) return loc.OP_OP_INV_VALUE_PREVIEW:format(fmt(self.parameters[1], itemId)); end,
		returnType  = "string",
		category    = loc.INV_PAGE_CHARACTER_INV,
		parameters  = {
			{
				title       = loc.ITEM_ID,
				description = loc.EFFECT_ITEM_SOURCE_ID,
				type        = "item",
				default     = "",
				taggable    = true
			},
		}
	});

	addon.script.registerOperand({
		id          = "inv_item_count",
		title       = loc.OP_OP_INV_COUNT,
		description = loc.OP_OP_INV_COUNT_TT,
		GetPreview  = function(self, operand, itemId, container) 
			if itemId == "" or itemId == nil then
				return loc.OP_OP_INV_COUNT_PREVIEW:format(
					"",
					fmt(self.parameters[2], container)
				); -- TODO
			else
				return loc.OP_OP_INV_COUNT_PREVIEW:format(
					fmt(self.parameters[1], itemId),
					fmt(self.parameters[2], container)
				);
			end
		end,
		returnType  = "number",
		category    = loc.INV_PAGE_CHARACTER_INV,
		parameters  = {
			{
				title       = loc.ITEM_ID,
				description = loc.EFFECT_ITEM_SOURCE_ID,
				type        = "item",
				default     = ""
			},
			{
				title       = loc.EFFECT_ITEM_SOURCE_SEARCH,
				description = loc.EFFECT_ITEM_SOURCE_SEARCH,
				type        = "string",
				default     = "inventory",
				values      = {
					{"inventory", loc.EFFECT_ITEM_SOURCE_1, loc.EFFECT_ITEM_SOURCE_1_SEARCH_TT},
					{"parent"   , loc.EFFECT_ITEM_SOURCE_2, loc.EFFECT_ITEM_SOURCE_2_SEARCH_TT},
					{"self"     , loc.EFFECT_ITEM_SOURCE_3, loc.EFFECT_ITEM_SOURCE_3_SEARCH_TT},
				}
			},
		}
	});

	addon.script.registerOperand({
		id          = "inv_item_weight",
		title       = loc.OP_OP_INV_WEIGHT,
		description = loc.OP_OP_INV_WEIGHT_TT,
		GetPreview  = function(self, operand, itemId, container) 
			return loc.OP_OP_INV_WEIGHT_PREVIEW:format(
				fmt(self.parameters[1], itemId),
				fmt(self.parameters[2], container)
			); 
		end,
		returnType  = "number",
		category    = loc.INV_PAGE_CHARACTER_INV,
		parameters  = {
			{
				title       = loc.ITEM_ID,
				description = loc.EFFECT_ITEM_SOURCE_ID,
				type        = "item",
				default     = ""
			},
			{
				title       = loc.EFFECT_ITEM_SOURCE_SEARCH,
				description = loc.EFFECT_ITEM_SOURCE_SEARCH,
				type        = "string",
				default     = "inventory",
				values      = {
					{"inventory", loc.EFFECT_ITEM_SOURCE_1, loc.EFFECT_ITEM_SOURCE_1_SEARCH_TT},
					{"parent"   , loc.EFFECT_ITEM_SOURCE_2, loc.EFFECT_ITEM_SOURCE_2_SEARCH_TT},
					{"self"     , loc.EFFECT_ITEM_SOURCE_3, loc.EFFECT_ITEM_SOURCE_3_SEARCH_TT},
				}
			},
		}
	});

	addon.script.registerOperand({
		id          = "inv_container_slot_id",
		title       = loc.OP_OP_INV_CONTAINER_SLOT_ID,
		description = loc.OP_OP_INV_CONTAINER_SLOT_ID_TT,
		GetPreview  = function(self, operand, slot) return loc.OP_OP_INV_CONTAINER_SLOT_ID_PREVIEW:format(fmt(self.parameters[1], slot)); end,
		returnType  = "string",
		category    = loc.INV_PAGE_CHARACTER_INV,
		parameters  = {
			{
				title       = loc.EFFECT_USE_SLOT,
				description = loc.EFFECT_USE_SLOT_TT,
				type        = "integer",
				default     = 1
			}
		}
	});

	-- CAMPAIGN
	addon.script.registerOperand({
		id          = "quest_active_campaign",
		title       = loc.OP_OP_QUEST_ACTIVE_CAMPAIGN,
		description = loc.OP_OP_QUEST_ACTIVE_CAMPAIGN_TT,
		GetPreview  = function(self, operand) return loc.OP_OP_QUEST_ACTIVE_CAMPAIGN; end,
		returnType  = "string",
		category    = loc.EFFECT_CAT_CAMPAIGN,
	});

	addon.script.registerOperand({
		id          = "quest_is_step",
		title       = loc.OP_OP_QUEST_STEP,
		description = loc.OP_OP_QUEST_STEP_TT,
		GetPreview  = function(self, operand, questId) return loc.OP_OP_QUEST_STEP_PREVIEW:format(fmt(self.parameters[1], questId)); end,
		returnType  = "string",
		category    = loc.EFFECT_CAT_CAMPAIGN,
		parameters  = {
			{
				title       = loc.QUEST_ID,
				description = loc.QUEST_ID,
				type        = "quest",
				default     = ""
			}
		}
	});

	addon.script.registerOperand({
		id          = "quest_obj",
		title       = loc.OP_OP_QUEST_OBJ,
		description = loc.OP_OP_QUEST_OBJ_TT,
		GetPreview  = function(self, operand, questId, objectiveId) 
			return loc.OP_OP_QUEST_OBJ_PREVIEW:format(
				fmt(self.parameters[2], objectiveId),
				fmt(self.parameters[1], questId)
			);
		end,
		returnType  = "boolean",
		category    = loc.EFFECT_CAT_CAMPAIGN,
		parameters  = {
			{
				title       = loc.QUEST_ID,
				description = loc.QUEST_ID,
				type        = "quest",
				default     = "",
				onChange    = function(widget, widgets)
					widgets[2]:SetQuestContext(widget:GetValue());
				end
			},
			{
				title       = loc.QE_OBJ_ID,
				description = loc.QE_OBJ_ID,
				type        = "objective",
				default     = ""
			}
		}
	});

	addon.script.registerOperand({
		id          = "quest_obj_current",
		title       = loc.OP_OP_QUEST_OBJ_CURRENT,
		description = loc.OP_OP_QUEST_OBJ_CURRENT_TT,
		GetPreview  = function(self, operand, questId) return loc.OP_OP_QUEST_OBJ_CURRENT_PREVIEW:format(fmt(self.parameters[1], questId)); end,
		returnType  = "string", -- TODO why tf is this string???
		category    = loc.EFFECT_CAT_CAMPAIGN,
		parameters  = {
			{
				title       = loc.QUEST_ID,
				description = loc.QUEST_ID,
				type        = "quest",
				default     = ""
			}
		}
	});

	addon.script.registerOperand({
		id          = "quest_obj_all",
		title       = loc.OP_OP_QUEST_OBJ_ALL,
		description = loc.OP_OP_QUEST_OBJ_ALL_TT,
		GetPreview  = function(self, operand, questId) return loc.OP_OP_QUEST_OBJ_ALL_PREVIEW:format(fmt(self.parameters[1], questId)); end,
		returnType  = "string", -- TODO why tf is this string???
		category    = loc.EFFECT_CAT_CAMPAIGN,
		parameters  = {
			{
				title       = loc.QUEST_ID,
				description = loc.QUEST_ID,
				type        = "quest",
				default     = ""
			}
		}
	});

	addon.script.registerOperand({
		id          = "quest_is_npc",
		title       = loc.OP_OP_QUEST_NPC,
		description = loc.OP_OP_QUEST_NPC_TT,
		GetPreview  = function(self, operand, unitId) return (loc.OP_OP_QUEST_NPC .. " (%s)"):format(fmt(self.parameters[1], unitId)); end,
		returnType  = "boolean",
		category    = loc.EFFECT_CAT_CAMPAIGN,
		parameters  = {
			{
				title       = loc.OP_UNIT,
				description = loc.OP_UNIT,
				type        = "string",
				default     = "target",
				values      = {
					{"player", loc.OP_UNIT_PLAYER},
					{"target", loc.OP_UNIT_TARGET},
					{"npc"   , loc.OP_UNIT_NPC}
				}
			}
		}
	});

	-- AURA
	local unaryAuraOperands = {
		{"aura_active"      , loc.OP_OP_AURA_ACTIVE     , loc.OP_OP_AURA_ACTIVE_TT     , loc.OP_OP_AURA_ACTIVE_PREVIEW     , "boolean"},
		{"aura_duration"    , loc.OP_OP_AURA_DURATION   , loc.OP_OP_AURA_DURATION_TT   , loc.OP_OP_AURA_DURATION_PREVIEW   , "number"},
		{"aura_helpful"     , loc.OP_OP_AURA_HELPFUL    , loc.OP_OP_AURA_HELPFUL_TT    , loc.OP_OP_AURA_HELPFUL_PREVIEW    , "boolean"},
		{"aura_cancellable" , loc.OP_OP_AURA_CANCELLABLE, loc.OP_OP_AURA_CANCELLABLE_TT, loc.OP_OP_AURA_CANCELLABLE_PREVIEW, "boolean"},
		{"aura_name"        , loc.OP_OP_AURA_NAME       , loc.OP_OP_AURA_NAME_TT       , loc.OP_OP_AURA_NAME_PREVIEW       , "string"},
		{"aura_category"    , loc.OP_OP_AURA_CATEGORY   , loc.OP_OP_AURA_CATEGORY_TT   , loc.OP_OP_AURA_CATEGORY_PREVIEW   , "string"},
		{"aura_icon"        , loc.OP_OP_AURA_ICON       , loc.OP_OP_AURA_ICON_TT       , loc.OP_OP_AURA_ICON_PREVIEW       , "string"},
		{"aura_color"       , loc.OP_OP_AURA_COLOR      , loc.OP_OP_AURA_COLOR_TT      , loc.OP_OP_AURA_COLOR_PREVIEW      , "string"},
	};
	for index, template in ipairs(unaryAuraOperands) do
		addon.script.registerOperand({
			id          = template[1],
			title       = template[2],
			description = template[3],
			GetPreview  = function(self, operand, auraId) return (template[4]):format(fmt(self.parameters[1], auraId)); end,
			returnType  = template[5],
			category    = loc.TYPE_AURA,
			parameters  = {
				{
					title       = loc.AURA_ID,
					description = loc.EFFECT_AURA_ID_TT,
					type        = "aura",
					default     = "",
					taggable    = true,
					nillable    = true
				}
			}
		});
	end

	addon.script.registerOperand({
		id          = "aura_count",
		title       = loc.OP_OP_AURA_COUNT,
		description = loc.OP_OP_AURA_COUNT_TT,
		GetPreview  = function(self, operand) return loc.OP_OP_AURA_COUNT; end,
		returnType  = "number",
		category    = loc.TYPE_AURA,
	});

	addon.script.registerOperand({
		id          = "aura_id",
		title       = loc.OP_OP_AURA_ID,
		description = loc.OP_OP_AURA_ID_TT,
		GetPreview  = function(self, operand, index) return loc.OP_OP_AURA_ID_PREVIEW:format(fmt(self.parameters[1], index)); end,
		returnType  = "string",
		category    = loc.TYPE_AURA,
		parameters  = {
			{
				title       = loc.OP_OP_AURA_ID_INDEX,
				description = loc.OP_OP_AURA_ID_INDEX_TT,
				type        = "string",
				default     = "1",
				taggable    = true
			}
		}
	});

	addon.script.registerOperand({
		id          = "aura_var_check",
		title       = loc.OP_OP_AURA_CHECK_VAR,
		description = loc.OP_OP_AURA_CHECK_VAR_TT,
		GetPreview  = function(self, operand, auraId, varName) 
			return loc.OP_OP_AURA_CHECK_VAR_PREVIEW:format(
				fmt(self.parameters[1], auraId),
				fmt(self.parameters[2], varName)
			); 
		end,
		returnType  = "string",
		category    = loc.TYPE_AURA,
		parameters  = {
			{
				title       = loc.AURA_ID,
				description = loc.EFFECT_AURA_ID_TT,
				type        = "aura",
				default     = "",
				taggable    = true,
				nillable    = true
			},
			{
				title       = loc.EFFECT_VAR,
				description = loc.EFFECT_VAR,
				type        = "variable",
				default     = "var",
				groupId     = "variable",
				memberIndex = 1,
				scope       = "o"
			}
		}
	});

	addon.script.registerOperand({
		id          = "aura_var_check_n",
		title       = loc.OP_OP_AURA_CHECK_VAR_N,
		description = loc.OP_OP_AURA_CHECK_VAR_N_TT,
		GetPreview  = function(self, operand, auraId, varName) 
			return loc.OP_OP_AURA_CHECK_VAR_N_PREVIEW:format(
				fmt(self.parameters[1], auraId),
				fmt(self.parameters[2], varName)
			); 
		end,
		returnType  = "number",
		category    = loc.TYPE_AURA,
		parameters  = {
			{
				title       = loc.AURA_ID,
				description = loc.EFFECT_AURA_ID_TT,
				type        = "aura",
				default     = "",
				taggable    = true,
				nillable    = true
			},
			{
				title       = loc.EFFECT_VAR,
				description = loc.EFFECT_VAR,
				type        = "variable",
				default     = "var",
				groupId     = "variable",
				memberIndex = 1,
				scope       = "o"
			}
		}
	});

	-- "EXPERT"
	local sourcesText = {
		w = loc.EFFECT_SOURCE_WORKFLOW,
		o = loc.EFFECT_SOURCE_OBJECT,
		c = loc.EFFECT_SOURCE_CAMPAIGN
	};
	addon.script.registerOperand({
		id          = "var_check",
		title       = loc.OP_OP_CHECK_VAR,
		description = loc.OP_OP_CHECK_VAR_TT,
		GetPreview  = function(self, operand, scope, varName) 
			return loc.OP_OP_CHECK_VAR_PREVIEW:format(
				fmt(self.parameters[1], scope),
				fmt(self.parameters[2], varName)
			); 
		end,
		returnType  = "string",
		category    = "Variables", -- TODO
		parameters  = {
			{
				title       = loc.EFFECT_SOURCE,
				description = loc.EFFECT_SOURCE, -- TODO
				type        = "scope",
				default     = "w",
				values      = {
					{"w", loc.EFFECT_SOURCE_WORKFLOW, loc.EFFECT_SOURCE_WORKFLOW_TT},
					{"o", loc.EFFECT_SOURCE_OBJECT, loc.EFFECT_SOURCE_OBJECT_TT},
					{"c", loc.EFFECT_SOURCE_CAMPAIGN, loc.EFFECT_SOURCE_CAMPAIGN_TT},
				},
				groupId     = "variable",
				memberIndex = 2
			},
			{
				title       = loc.EFFECT_VAR,
				description = loc.EFFECT_VAR,
				type        = "variable",
				default     = "var",
				groupId     = "variable",
				memberIndex = 1
			}
		}
	});

	addon.script.registerOperand({
		id          = "var_check_n",
		title       = loc.OP_OP_CHECK_VAR_N,
		description = loc.OP_OP_CHECK_VAR_N_TT,
		GetPreview  = function(self, operand, scope, varName) 
			return loc.OP_OP_CHECK_VAR_N_PREVIEW:format(
				fmt(self.parameters[1], scope),
				fmt(self.parameters[2], varName)
			); 
		end,
		returnType  = "number",
		category    = "Variables", -- TODO
		parameters  = {
			{
				title       = loc.EFFECT_SOURCE,
				description = loc.EFFECT_SOURCE, -- TODO
				type        = "scope",
				default     = "w",
				values      = {
					{"w", loc.EFFECT_SOURCE_WORKFLOW, loc.EFFECT_SOURCE_WORKFLOW_TT},
					{"o", loc.EFFECT_SOURCE_OBJECT, loc.EFFECT_SOURCE_OBJECT_TT},
					{"c", loc.EFFECT_SOURCE_CAMPAIGN, loc.EFFECT_SOURCE_CAMPAIGN_TT},
				},
				groupId     = "variable",
				memberIndex = 2
			},
			{
				title       = loc.EFFECT_VAR,
				description = loc.EFFECT_VAR,
				type        = "variable",
				default     = "var",
				groupId     = "variable",
				memberIndex = 1
			}
		}
	});

	addon.script.registerOperand({
		id          = "check_event_var",
		title       = loc.OP_OP_CHECK_EVENT_VAR,
		description = loc.OP_OP_CHECK_EVENT_VAR_TT,
		GetPreview  = function(self, operand, index) return loc.OP_OP_CHECK_EVENT_VAR_PREVIEW:format(fmt(self.parameters[1], index)); end,
		returnType  = "string",
		category    = "Variables", -- TODO
		parameters  = {
			{
				title       = loc.EFFECT_VAR_INDEX,
				description = loc.EFFECT_VAR_INDEX_TT,
				type        = "string", -- index, check if taggable
				default     = "1"
			}
		}
	});

	addon.script.registerOperand({
		id          = "check_event_var_n",
		title       = loc.OP_OP_CHECK_EVENT_VAR_N,
		description = loc.OP_OP_CHECK_EVENT_VAR_N_TT,
		GetPreview  = function(self, operand, index) return loc.OP_OP_CHECK_EVENT_VAR_N_PREVIEW:format(fmt(self.parameters[1], index)); end,
		returnType  = "string",
		category    = "Variables", -- TODO
		parameters  = {
			{
				title       = loc.EFFECT_VAR_INDEX,
				description = loc.EFFECT_VAR_INDEX_TT,
				type        = "string", -- index, check if taggable
				default     = "1"
			}
		}
	});

	-- OTHER
	addon.script.registerOperand({
		id          = "random",
		title       = loc.OP_OP_RANDOM,
		description = loc.OP_OP_RANDOM_TT,
		GetPreview  = function(self, operand, from, to) 
			return loc.OP_OP_RANDOM_PREVIEW:format(
				fmt(self.parameters[1], from),
				fmt(self.parameters[2], to)
			); 
		end,
		returnType  = "number",
		parameters  = {
			{
				title       = loc.OP_OP_RANDOM_FROM,
				description = loc.OP_OP_RANDOM_FROM,
				type        = "number",
				default     = 1,
				taggable    = true
			},
			{
				title       = loc.OP_OP_RANDOM_TO,
				description = loc.OP_OP_RANDOM_TO,
				type        = "number",
				default     = 100,
				taggable    = true
			}
		}
	});

	local nullaryDateTimeOperands = {
		{"time_hour"       , loc.OP_OP_TIME_HOUR       , loc.OP_OP_TIME_HOUR_TT},
		{"time_minute"     , loc.OP_OP_TIME_MINUTE     , loc.OP_OP_TIME_MINUTE_TT},
		{"date_day"        , loc.OP_OP_DATE_DAY        , loc.OP_OP_DATE_DAY_TT},
		{"date_month"      , loc.OP_OP_DATE_MONTH      , loc.OP_OP_DATE_MONTH_TT},
		{"date_year"       , loc.OP_OP_DATE_YEAR       , loc.OP_OP_DATE_YEAR_TT},
		{"date_day_of_week", loc.OP_OP_DATE_DAY_OF_WEEK, loc.OP_OP_DATE_DAY_OF_WEEK_TT},
	};

	for index, template in ipairs(nullaryDateTimeOperands) do
		addon.script.registerOperand({
			id          = template[1],
			title       = template[2],
			description = template[3],
			GetPreview  = function(self, operand) return template[2] end,
			returnType  = "number",
			category    = "Date and time", -- TODO
		});
	end

end
