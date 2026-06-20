local _, addon = ...
local loc = TRP3_API.loc;

function addon.script.registerBuiltinEffects()

	local fmt = addon.script.formatParameter;

	addon.script.registerEffect({
		id          = TRP3_DB.elementTypes.DELAY,
		title       = loc.WO_DELAY,
		description = loc.WO_DELAY_TT,
		GetPreview  = function(self, _effect, duration, interrupt, type, soundId, isSoundFileId, castText)
			if type == 1 then
				return ("Delay %s s, %s"):format(
					fmt(self.parameters[1], duration),
					fmt(self.parameters[2], interrupt)
				);
			else
				return ("Cast \"%s\" for %s s, %s, playing %s"):format(
					fmt(self.parameters[6], castText),
					fmt(self.parameters[1], duration),
					fmt(self.parameters[2], interrupt),
					fmt(self.parameters[4], soundId, isSoundFileId)
				);
			end
		end,
		icon        = "spell_mage_altertime",
		type        = TRP3_DB.elementTypes.DELAY,
		canHaveConstraint = false,
		parameters  = {
			{ -- "d"
				title       = loc.WO_DELAY_DURATION,
				description = loc.WO_DELAY_DURATION_TT,
				type        = "number",
				default     = 1
			},
			{ -- "i"
				title       = loc.WO_DELAY_INTERRUPT,
				description = loc.WO_DELAY_INTERRUPT,
				type        = "number",
				default     = 1,
				values      = {
					{1, loc.WO_DELAY_INTERRUPT_1},
					{2, loc.WO_DELAY_INTERRUPT_2}
				}
			},
			{ -- "c"
				title       = loc.WO_DELAY_TYPE,
				description = loc.WO_DELAY_TYPE,
				type        = "number",
				default     = 1,
				values      = {
					{1, loc.WO_DELAY_TYPE_1, loc.WO_DELAY_TYPE_1_TT},
					{2, loc.WO_DELAY_TYPE_2, loc.WO_DELAY_TYPE_2_TT}
				},
				onChange    = function(widget, widgets)
					local isCast = widget:GetValue() == 2;
					widgets[4]:SetShown(isCast);
					widgets[5]:SetShown(isCast);
					widgets[6]:SetShown(isCast);
				end
			},
			{ -- "s"
				title       = loc.WO_DELAY_CAST_SOUND,
				description = loc.WO_DELAY_CAST_SOUND_TT,
				type        = "sound",
				default     = 0,
				groupId     = "sound",
				memberIndex = 1
			},
			{ -- "f"
				title       = loc.EFFECT_SOUND_ID_SELF_SOUNDFILE,
				description = loc.EFFECT_SOUND_ID_SELF_SOUNDFILE_TT,
				type        = "boolean",
				default     = false,
				groupId     = "sound",
				memberIndex = 2
			},
			{ -- "x"
				title       = loc.WO_DELAY_CAST_TEXT,
				description = loc.WO_DELAY_CAST_TEXT_TT,
				type        = "string",
				default     = "",
				nillable    = true,
				taggable    = true
			},
		},
		category = loc.WO_EFFECT_CAT_COMMON
	});

	addon.script.registerEffect({
		id          = TRP3_DB.elementTypes.CONDITION,
		title       = "Condition",
		description = "Continue if the condition is met",
		GetPreview  = function(self, _effect, failMessage, failWorkflow)
			if failMessage and failWorkflow then
				return ("Continue if the condition is met, otherwise show message %s and run workflow %s."):format(
					fmt(self.parameters[1], failMessage),
					fmt(self.parameters[2], failWorkflow)
				);
			elseif failMessage then
				return ("Continue if the condition is met, otherwise show message %s."):format(
					fmt(self.parameters[1], failMessage)
				);
			elseif failWorkflow then
				return ("Continue if the condition is met, otherwise run workflow %s."):format(
					fmt(self.parameters[2], failWorkflow)
				);
			else
				return "Continue if the condition is met.";
			end
		end,
		icon        = "Ability_druid_balanceofpower",
		type        = TRP3_DB.elementTypes.CONDITION,
		parameters  = {
			{ -- "failMessage"
				title       = loc.OP_FAIL,
				description = loc.OP_FAIL_TT,
				type        = "string",
				default     = "",
				nillable    = true
			},
			{ -- "failWorkflow"
				title       = loc.OP_FAIL_W,
				description = loc.OP_FAIL_W_TT,
				type        = "string",
				default     = "",
				nillable    = true
			},
		},
		category = loc.WO_EFFECT_CAT_COMMON
	});

	-- COMMON
	addon.script.registerEffect({
		id          = "text",
		title       = loc.EFFECT_TEXT,
		description = loc.EFFECT_TEXT_TT,
		GetPreview  = function(self, _effect, text, type)
			return ("Show the text %s in %s."):format(
				fmt(self.parameters[1], text),
				fmt(self.parameters[2], type)
			);
		end,
		icon        = "inv_inscription_scrollofwisdom_01",
		parameters  = {
			{
				title       = loc.EFFECT_TEXT_TEXT,
				description = loc.EFFECT_TEXT_TEXT_TT,
				type        = "multiline",
				taggable    = true,
				default     = loc.EFFECT_TEXT_TEXT_DEFAULT,
				nillable    = true
			},
			{
				title       = loc.EFFECT_TEXT_TYPE,
				description = loc.EFFECT_TEXT_TYPE, -- TODO add proper tooltip text
				type        = "number",
				default     = TRP3_API.utils.message.type.CHAT_FRAME,
				values = {
					{TRP3_API.utils.message.type.CHAT_FRAME   , loc.EFFECT_TEXT_TYPE_1},
					{TRP3_API.utils.message.type.ALERT_POPUP  , loc.EFFECT_TEXT_TYPE_2},
					{TRP3_API.utils.message.type.RAID_ALERT   , loc.EFFECT_TEXT_TYPE_3},
					{TRP3_API.utils.message.type.ALERT_MESSAGE, loc.EFFECT_TEXT_TYPE_4}
				}
			},
		},
		category = loc.WO_EFFECT_CAT_COMMON
	});

	-- SOUND
	addon.script.registerEffect({
		id          = "sound_id_self",
		title       = loc.EFFECT_SOUND_ID_SELF,
		description = loc.EFFECT_SOUND_ID_SELF_TT,
		GetPreview  = function(self, _effect, channel, soundId, isSoundFileId)
			return loc.EFFECT_SOUND_ID_SELF_PREVIEW:format(
				fmt(self.parameters[2], soundId, isSoundFileId),
				fmt(self.parameters[1], channel)
			);
		end,
		icon        = "inv_misc_ear_human_02",
		parameters  = {
			{
				title       = loc.EFFECT_SOUND_ID_SELF_CHANNEL,
				description = loc.EFFECT_SOUND_ID_SELF_CHANNEL, -- TODO add proper tooltip text
				type        = "string",
				default     = "SFX",
				values = {
					{"SFX"      , loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX     , loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX_TT},
					{"Ambience" , loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE, loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE_TT}
				},
				onChange    = function(widget, widgets)
					widgets[2].channel = widget:GetValue();
				end
			},
			{
				title       = loc.EFFECT_SOUND_ID_SELF_ID,
				description = loc.EFFECT_SOUND_ID_SELF_ID_TT,
				type        = "sound",
				default     = 43569,
				groupId     = "sound",
				memberIndex = 1
			},
			{
				title       = loc.EFFECT_SOUND_ID_SELF_SOUNDFILE,
				description = loc.EFFECT_SOUND_ID_SELF_SOUNDFILE_TT,
				type        = "boolean",
				default     = false,
				groupId     = "sound",
				memberIndex = 2
			},
		},
		category = loc.EFFECT_CAT_SOUND
	});

	addon.script.registerEffect({
		id          = "sound_id_stop",
		title       = loc.EFFECT_SOUND_ID_STOP,
		description = loc.EFFECT_SOUND_ID_STOP_TT,
		GetPreview  = function(self, _effect, channel, soundId, fadeout)
			return loc.EFFECT_SOUND_ID_STOP_FADEOUT_PREVIEW:format( -- TODO if no fadeout, probably remove the fadeout part
				fmt(self.parameters[2], soundId),
				fmt(self.parameters[1], channel),
				fmt(self.parameters[3], fadeout)
			);
		end,
		icon        = "inv_misc_ear_nightelf_02",
		parameters  = {
			{
				title       = loc.EFFECT_SOUND_ID_SELF_CHANNEL,
				description = loc.EFFECT_SOUND_ID_SELF_CHANNEL, -- TODO add proper tooltip text
				type        = "string",
				default     = "SFX",
				values = {
					{"SFX"      , loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX     , loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX_TT},
					{"Ambience" , loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE, loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE_TT}
				},
				onChange    = function(widget, widgets)
					widgets[2].channel = widget:GetValue();
				end
			},
			{
				title       = loc.EFFECT_SOUND_ID_SELF_ID,
				description = loc.EFFECT_SOUND_ID_STOP_ID_TT, -- TODO cannot specify sound file flag here. why?
				type        = "sound",
				default     = nil,
				groupId     = "sound",
				memberIndex = 1
			},
			{
				title       = loc.EFFECT_SOUND_ID_FADEOUT,
				description = loc.EFFECT_SOUND_ID_FADEOUT_TT,
				type        = "number",
				default     = 0
			}
		},
		category = loc.EFFECT_CAT_SOUND
	});

	addon.script.registerEffect({
		id          = "sound_music_self",
		title       = loc.EFFECT_SOUND_MUSIC_SELF,
		description = loc.EFFECT_SOUND_MUSIC_SELF_TT,
		GetPreview  = function(self, _effect, musicId)
			return loc.EFFECT_SOUND_MUSIC_SELF_PREVIEW:format(fmt(self.parameters[1], musicId));
		end,
		icon        = "inv_misc_drum_07",
		parameters  = {
			{
				title       = loc.EFFECT_SOUND_MUSIC_SELF_PATH,
				description = loc.EFFECT_SOUND_MUSIC_SELF_PATH_TT,
				type        = "music",
				default     = "228575",
				nillable    = true
			}
		},
		category = loc.EFFECT_CAT_SOUND
	});

	addon.script.registerEffect({
		id          = "sound_music_stop",
		title       = loc.EFFECT_SOUND_MUSIC_STOP,
		description = loc.EFFECT_SOUND_MUSIC_STOP_TT,
		GetPreview  = function(self, _effect)
			return loc.EFFECT_SOUND_MUSIC_STOP;
		end,
		icon        = "spell_holy_silence",
		category = loc.EFFECT_CAT_SOUND
	});

	addon.script.registerEffect({
		id          = "sound_id_local",
		title       = loc.EFFECT_SOUND_ID_LOCAL,
		description = loc.EFFECT_SOUND_ID_LOCAL_TT,
		GetPreview  = function(self, _effect, channel, soundId, distance, isSoundFileId)
			return loc.EFFECT_SOUND_ID_LOCAL_PREVIEW:format(
				fmt(self.parameters[2], soundId, isSoundFileId),
				fmt(self.parameters[1], channel),
				fmt(self.parameters[3], distance)
			);
		end,
		icon        = "inv_misc_ear_human_01",
		parameters  = {
			{
				title       = loc.EFFECT_SOUND_ID_SELF_CHANNEL,
				description = loc.EFFECT_SOUND_ID_SELF_CHANNEL, -- TODO add proper tooltip text
				type        = "string",
				default     = "SFX",
				values = {
					{"SFX"      , loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX     , loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX_TT},
					{"Ambience" , loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE, loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE_TT}
				},
				onChange    = function(widget, widgets)
					widgets[2].channel = widget:GetValue();
				end
			},
			{
				title       = loc.EFFECT_SOUND_ID_SELF_ID,
				description = loc.EFFECT_SOUND_ID_SELF_ID_TT,
				type        = "sound",
				default     = 43569,
				groupId     = "sound",
				memberIndex = 1
			},
			{
				title       = loc.EFFECT_SOUND_LOCAL_DISTANCE,
				description = loc.EFFECT_SOUND_LOCAL_DISTANCE_TT,
				type        = "number",
				default     = 20
			},
			{
				title       = loc.EFFECT_SOUND_ID_SELF_SOUNDFILE,
				description = loc.EFFECT_SOUND_ID_SELF_SOUNDFILE_TT,
				type        = "boolean",
				default     = false,
				groupId     = "sound",
				memberIndex = 2
			},
		},
		category = loc.EFFECT_CAT_SOUND
	});

	addon.script.registerEffect({
		id          = "sound_id_local_stop",
		title       = loc.EFFECT_SOUND_ID_LOCAL_STOP,
		description = loc.EFFECT_SOUND_ID_LOCAL_STOP_TT,
		GetPreview  = function(self, _effect, channel, soundId, fadeout)
			return loc.EFFECT_SOUND_ID_STOP_PREVIEW:format( -- TODO if no fadeout, probably remove the fadeout part
				fmt(self.parameters[2], soundId), -- TODO EFFECT_SOUND_ID_STOP_FADEOUT_PREVIEW EFFECT_SOUND_ID_STOP_PREVIEW
				fmt(self.parameters[1], channel),
				fmt(self.parameters[3], fadeout)
			);
		end,
		icon        = "spell_shadow_coneofsilence",
		parameters  = {
			{
				title       = loc.EFFECT_SOUND_ID_SELF_CHANNEL,
				description = loc.EFFECT_SOUND_ID_SELF_CHANNEL, -- TODO add proper tooltip text
				type        = "string",
				default     = "SFX",
				values = {
					{"SFX"      , loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX     , loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX_TT},
					{"Ambience" , loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE, loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE_TT}
				},
				onChange    = function(widget, widgets)
					widgets[2].channel = widget:GetValue();
				end
			},
			{
				title       = loc.EFFECT_SOUND_ID_SELF_ID,
				description = loc.EFFECT_SOUND_ID_STOP_ID_TT, -- TODO cannot specify sound file flag here. why?
				type        = "sound",
				default     = nil,
				groupId     = "sound",
				memberIndex = 1
			},
			{
				title       = loc.EFFECT_SOUND_ID_FADEOUT,
				description = loc.EFFECT_SOUND_ID_FADEOUT_TT,
				type        = "boolean",
				default     = nil
			}
		},
		category = loc.EFFECT_CAT_SOUND
	});

	addon.script.registerEffect({
		id          = "sound_music_local",
		title       = loc.EFFECT_SOUND_MUSIC_LOCAL,
		description = loc.EFFECT_SOUND_MUSIC_LOCAL_TT,
		GetPreview  = function(self, _effect, musicId, distance)
			return loc.EFFECT_SOUND_MUSIC_LOCAL_PREVIEW:format(fmt(self.parameters[1], musicId), fmt(self.parameters[1], distance));
		end,
		icon        = "inv_misc_drum_04",
		parameters  = {
			{
				title       = loc.EFFECT_SOUND_MUSIC_SELF_PATH,
				description = loc.EFFECT_SOUND_MUSIC_SELF_PATH_TT,
				type        = "music",
				default     = "228575",
				nillable    = true
			},
			{
				title       = loc.EFFECT_SOUND_LOCAL_DISTANCE,
				description = loc.EFFECT_SOUND_LOCAL_DISTANCE_TT,
				type        = "number",
				default     = 20
			},
		},
		category = loc.EFFECT_CAT_SOUND
	});

	addon.script.registerEffect({
		id          = "sound_music_local_stop",
		title       = loc.EFFECT_SOUND_MUSIC_LOCAL_STOP,
		description = loc.EFFECT_SOUND_MUSIC_LOCAL_STOP_TT,
		GetPreview  = function(self, _effect)
			return loc.EFFECT_SOUND_MUSIC_LOCAL_STOP;
		end,
		icon        = "ability_priest_silence",
		category = loc.EFFECT_CAT_SOUND
	});

	-- SPEECH
	addon.script.registerEffect({
		id          = "speech_env",
		title       = loc.EFFECT_SPEECH_NAR,
		description = loc.EFFECT_SPEECH_NAR_TT,
		GetPreview  = function(self, _effect, text)
			return ("%s"):format(fmt(self.parameters[1], text));
		end,
		icon        = "inv_misc_book_07",
		parameters  = {
			{
				title       = loc.EFFECT_TEXT_TEXT,
				description = loc.EFFECT_SPEECH_NAR_TEXT_TT,
				type        = "string",
				default     = loc.EFFECT_SPEECH_NAR_DEFAULT,
				taggable    = true,
				nillable    = true
			}
		},
		category = loc.EFFECT_CAT_SPEECH
	});

	addon.script.registerEffect({
		id          = "speech_npc",
		title       = loc.EFFECT_SPEECH_NPC,
		description = loc.EFFECT_SPEECH_NPC_TT,
		GetPreview  = function(self, _effect, name, type, text)
			return TRP3_API.ui.misc.getSpeechPrefixText(
				type,
				fmt(self.parameters[1], name),
				fmt(self.parameters[3], text)
			);
		end,
		icon        = "ability_warrior_rallyingcry",
		parameters  = {
			{
				title       = loc.EFFECT_SPEECH_NPC_NAME,
				description = loc.EFFECT_SPEECH_NPC_NAME_TT,
				type        = "string",
				default     = "Tish",
				taggable    = true,
				nillable    = true
			},
			{
				title       = loc.EFFECT_SPEECH_TYPE,
				description = loc.EFFECT_SPEECH_TYPE, -- TODO
				type        = "string",
				default     = TRP3_API.ui.misc.SPEECH_PREFIX.SAYS,
				values      = {
					{TRP3_API.ui.misc.SPEECH_PREFIX.SAYS, loc.NPC_SAYS},
					{TRP3_API.ui.misc.SPEECH_PREFIX.YELLS, loc.NPC_YELLS},
					{TRP3_API.ui.misc.SPEECH_PREFIX.WHISPERS, loc.NPC_WHISPERS},
				}
			},
			{
				title       = loc.EFFECT_TEXT_TEXT,
				description = loc.EFFECT_SPEECH_NAR_TEXT_TT,
				type        = "string",
				default     = loc.EFFECT_SPEECH_NPC_DEFAULT,
				taggable    = true,
				nillable    = true
			},
		},
		category = loc.EFFECT_CAT_SPEECH
	});

	addon.script.registerEffect({
		id          = "speech_player",
		title       = loc.EFFECT_SPEECH_PLAYER,
		description = loc.EFFECT_SPEECH_PLAYER_TT,
		GetPreview  = function(self, _effect, type, text)
			return TRP3_API.ui.misc.getSpeech(
				fmt(self.parameters[2], text),
				type
			);
		end,
		icon        = "ability_warrior_warcry",
		parameters  = {
			{
				title       = loc.EFFECT_SPEECH_TYPE,
				description = loc.EFFECT_SPEECH_TYPE, -- TODO
				type        = "string",
				default     = TRP3_API.ui.misc.SPEECH_PREFIX.SAYS,
				values      = {
					{TRP3_API.ui.misc.SPEECH_PREFIX.SAYS, loc.NPC_SAYS},
					{TRP3_API.ui.misc.SPEECH_PREFIX.YELLS, loc.NPC_YELLS},
					{TRP3_API.ui.misc.SPEECH_PREFIX.EMOTES, loc.NPC_EMOTES},
				}
			},
			{
				title       = loc.EFFECT_TEXT_TEXT,
				description = loc.EFFECT_SPEECH_NAR_TEXT_TT,
				type        = "string",
				default     = loc.EFFECT_SPEECH_PLAYER_DEFAULT,
				taggable    = true,
				nillable    = true
			},
		},
		category = loc.EFFECT_CAT_SPEECH
	});

	addon.script.registerEffect({
		id          = "do_emote",
		title       = loc.EFFECT_DO_EMOTE,
		description = loc.EFFECT_DO_EMOTE_TT,
		GetPreview  = function(self, _effect, token)
			return ("%s"):format(
				fmt(self.parameters[1], token)
			);
		end,
		icon        = "Achievement_Faction_Celestials",
		parameters  = {
			{
				title       = "Emote token",
				description = "Emote token tooltip TODO", -- TODO
				type        = "emote",
				default     = nil
			}
		},
		category = loc.EFFECT_CAT_SPEECH
	});

	-- COMPANION
	addon.script.registerEffect({
		id          = "companion_dismiss_mount",
		title       = loc.EFFECT_DISMOUNT,
		description = loc.EFFECT_DISMOUNT_TT,
		GetPreview  = function(self, _effect)
			return loc.EFFECT_DISMOUNT;
		end,
		icon        = "ability_skyreach_dismount",
		category = loc.REG_COMPANIONS
	});

	addon.script.registerEffect({
		id          = "companion_dismiss_critter",
		title       = loc.EFFECT_DISPET,
		description = loc.EFFECT_DISPET_TT,
		GetPreview  = function(self, _effect)
			return loc.EFFECT_DISPET;
		end,
		icon        = "inv_pet_pettrap01",
		category = loc.REG_COMPANIONS
	});

	addon.script.registerEffect({
		id          = "companion_random_critter",
		title       = loc.EFFECT_RANDSUM,
		description = loc.EFFECT_RANDSUM_TT,
		GetPreview  = function(self, _effect, favs_only)
			if favs_only then
				return loc.EFFECT_RANDSUM_PREVIEW_FAV;
			else
				return loc.EFFECT_RANDSUM_PREVIEW_FULL;
			end
		end,
		icon        = "ability_hunter_beastcall",
		parameters  = {
			{
				title       = loc.EFFECT_RANDSUM_SUMMON_FAV,
				description = loc.EFFECT_RANDSUM_SUMMON_FAV,
				type        = "boolean",
				default     = nil
			}
		},
		category = loc.REG_COMPANIONS
	});

	addon.script.registerEffect({
		id          = "companion_summon_mount",
		title       = loc.EFFECT_SUMMOUNT,
		description = loc.EFFECT_SUMMOUNT_TT,
		GetPreview  = function(self, _effect, mountId)
			return (loc.EFFECT_SUMMOUNT .. ": %s"):format(fmt(self.parameters[1], mountId));
		end,
		icon        = "ability_hunter_beastcall",
		parameters  = {
			{
				title       = loc.EFFECT_SUMMOUNT, -- TODO
				description = loc.EFFECT_SUMMOUNT, -- TODO
				type        = "mount",
				default     = 0
			}
		},
		category = loc.REG_COMPANIONS
	});

	-- INVENTORY
	addon.script.registerEffect({
		id          = "item_add",
		title       = loc.EFFECT_ITEM_ADD,
		description = loc.EFFECT_ITEM_ADD_TT,
		GetPreview  = function(self, _effect, itemId, quantity, isCrafted, source)
			if isCrafted then
				return ("Adds %s x %s to %s and mark them as crafted"):format(fmt(self.parameters[2], quantity), fmt(self.parameters[1], itemId), fmt(self.parameters[4], source));
			else
				return ("Adds %s x %s to %s"):format(fmt(self.parameters[2], quantity), fmt(self.parameters[1], itemId), fmt(self.parameters[4], source));
			end
		end,
		icon        = "garrison_weaponupgrade",
		parameters  = {
			{
				title       = loc.EFFECT_ITEM_ADD_ID,
				description = loc.EFFECT_ITEM_ADD_ID_TT,
				type        = "item",
				default     = "",
				nillable    = true
			},
			{
				title       = loc.EFFECT_ITEM_ADD_QT,
				description = loc.EFFECT_ITEM_ADD_QT_TT,
				type        = "integer",
				taggable    = true,
				default     = 1
			},
			{
				title       = loc.EFFECT_ITEM_ADD_CRAFTED,
				description = loc.EFFECT_ITEM_ADD_CRAFTED_TT,
				type        = "boolean",
				default     = false
			},
			{
				title       = loc.EFFECT_ITEM_SOURCE_ADD,
				description = loc.EFFECT_ITEM_SOURCE_ADD, -- TODO
				type        = "string",
				default     = "parent",
				values      = {
					{"inventory", loc.EFFECT_ITEM_SOURCE_1, loc.EFFECT_ITEM_SOURCE_1_ADD_TT},
					{"parent"   , loc.EFFECT_ITEM_SOURCE_2, loc.EFFECT_ITEM_SOURCE_2_ADD_TT},
					{"self"     , loc.EFFECT_ITEM_SOURCE_3, loc.EFFECT_ITEM_SOURCE_3_ADD_TT},
				}
			},
		},
		category = loc.INV_PAGE_CHARACTER_INV
	});

	addon.script.registerEffect({
		id          = "item_remove",
		title       = loc.EFFECT_ITEM_REMOVE,
		description = loc.EFFECT_ITEM_REMOVE_TT,
		GetPreview  = function(self, _effect, itemId, quantity, source)
			return ("Removes %s x %s from %s"):format(fmt(self.parameters[2], quantity), fmt(self.parameters[1], itemId), fmt(self.parameters[3], source));
		end,
		icon        = "spell_sandexplosion",
		parameters  = {
			{
				title       = loc.EFFECT_ITEM_ADD_ID,
				description = loc.EFFECT_ITEM_ADD_ID_TT,
				type        = "item",
				default     = "",
				nillable    = true
			},
			{
				title       = loc.EFFECT_ITEM_ADD_QT,
				description = loc.EFFECT_ITEM_ADD_QT_TT,
				type        = "integer",
				taggable    = true,
				default     = 1
			},
			{
				title       = loc.EFFECT_ITEM_SOURCE_SEARCH,
				description = loc.EFFECT_ITEM_SOURCE_SEARCH, -- TODO
				type        = "string",
				default     = "inventory",
				values      = {
					{"inventory", loc.EFFECT_ITEM_SOURCE_1, loc.EFFECT_ITEM_SOURCE_1_SEARCH_TT},
					{"parent"   , loc.EFFECT_ITEM_SOURCE_2, loc.EFFECT_ITEM_SOURCE_2_SEARCH_TT},
					{"self"     , loc.EFFECT_ITEM_SOURCE_3, loc.EFFECT_ITEM_SOURCE_3_SEARCH_TT},
				}
			},
		},
		category = loc.INV_PAGE_CHARACTER_INV
	});

	addon.script.registerEffect({
		id          = "item_sheath",
		title       = loc.EFFECT_SHEATH,
		description = loc.EFFECT_SHEATH_TT,
		GetPreview  = function(self, _effect) return loc.EFFECT_SHEATH; end,
		icon        = "garrison_blueweapon",
		category = loc.INV_PAGE_CHARACTER_INV
	});

	addon.script.registerEffect({
		id          = "item_bag_durability",
		title       = loc.EFFECT_ITEM_BAG_DURABILITY,
		description = loc.EFFECT_ITEM_BAG_DURABILITY_TT,
		GetPreview  = function(self, _effect, method, amount)
			if method == "HEAL" then
				return loc.EFFECT_ITEM_BAG_DURABILITY_PREVIEW_1:format(fmt(self.parameters[2], amount));
			else
				return loc.EFFECT_ITEM_BAG_DURABILITY_PREVIEW_2:format(fmt(self.parameters[2], amount));
			end
		end,
		icon        = "ability_repair",
		parameters  = {
			{
				title       = loc.EFFECT_ITEM_BAG_DURABILITY_METHOD,
				description = loc.EFFECT_ITEM_BAG_DURABILITY_METHOD, -- TODO
				type        = "string",
				default     = "HEAL",
				values      = {
					{"HEAL"   , loc.EFFECT_ITEM_BAG_DURABILITY_METHOD_HEAL, loc.EFFECT_ITEM_BAG_DURABILITY_METHOD_HEAL_TT},
					{"DAMAGE" , loc.EFFECT_ITEM_BAG_DURABILITY_METHOD_DAMAGE, loc.EFFECT_ITEM_BAG_DURABILITY_METHOD_DAMAGE_TT},
				}
			},
			{
				title       = loc.EFFECT_ITEM_BAG_DURABILITY_VALUE,
				description = loc.EFFECT_ITEM_BAG_DURABILITY_VALUE_TT,
				type        = "integer",
				default     = 10
			}
		},
		context = {TRP3_DB.types.ITEM}, -- TODO!!!
		category = loc.INV_PAGE_CHARACTER_INV
	});

	addon.script.registerEffect({
		id          = "item_consume",
		title       = loc.EFFECT_ITEM_CONSUME,
		description = loc.EFFECT_ITEM_CONSUME_TT,
		GetPreview  = function(self, _effect) return loc.EFFECT_ITEM_CONSUME_TT; end,
		icon        = "inv_misc_potionseta",
		context = {TRP3_DB.types.ITEM},  -- TODO!!!
		category = loc.INV_PAGE_CHARACTER_INV
	});

	addon.script.registerEffect({
		id          = "item_cooldown",
		title       = loc.EFFECT_ITEM_COOLDOWN,
		description = loc.EFFECT_ITEM_COOLDOWN_TT,
		GetPreview  = function(self, _effect, duration)
			return loc.EFFECT_ITEM_COOLDOWN_PREVIEW:format(fmt(self.parameters[1], duration));
		end,
		icon        = "ability_mage_timewarp",
		parameters  = {
			{
				title       = loc.EFFECT_COOLDOWN_DURATION,
				description = loc.EFFECT_COOLDOWN_DURATION_TT,
				type        = "number",
				default     = 1
			}
		},
		context = {TRP3_DB.types.ITEM}, -- TODO!!!
		category = loc.INV_PAGE_CHARACTER_INV
	});

	addon.script.registerEffect({
		id          = "item_use",
		title       = loc.EFFECT_ITEM_USE,
		description = loc.EFFECT_ITEM_USE_TT,
		GetPreview  = function(self, _effect, slotId)
			return loc.EFFECT_ITEM_USE_PREVIEW:format(fmt(self.parameters[1], slotId));
		end,
		icon        = "ability_paladin_handoflight",
		parameters  = {
			{
				title       = loc.EFFECT_USE_SLOT,
				description = loc.EFFECT_USE_SLOT_TT,
				type        = "string",
				default     = "1"
			}
		},
		context = {TRP3_DB.types.ITEM}, -- TODO!!!
		category = loc.INV_PAGE_CHARACTER_INV
	});

	addon.script.registerEffect({
		id          = "item_loot",
		title       = loc.EFFECT_ITEM_LOOT,
		description = loc.EFFECT_ITEM_LOOT_TT,
		GetPreview  = function(self, _effect, title, _icon, _content, isDrop)
			if isDrop then
				return loc.EFFECT_ITEM_LOOT_PREVIEW_1:format(fmt(self.parameters[1], title)); -- TODO !!!
			else
				return loc.EFFECT_ITEM_LOOT_PREVIEW_2:format(fmt(self.parameters[1], title)); -- TODO !!!
			end
		end,
		icon        = "inv_box_02",
		boxed       = true,
		parameters  = {
			{
				title       = loc.EFFECT_ITEM_LOOT_NAME,
				description = loc.EFFECT_ITEM_LOOT_NAME_TT,
				type        = "string",
				default     = loc.LOOT,
				onChange    = function(widget, widgets)
					widgets[3].bag.Title:SetText(widget:GetValue());
				end,
				layoutLeft  = 0,
				nillable    = true
			},
			{
				title       = loc.EDITOR_ICON,
				description = loc.EDITOR_ICON,
				type        = "icon",
				default     = "inv_misc_bag_07",
				onChange    = function(widget, widgets)
					widgets[3].bag.Icon:SetTexture("Interface\\ICONS\\" .. widget:GetValue());
				end,
				layoutLeft  = 1
			},
			{
				title       = "Content",
				description = "TODO the content of the loot???",
				type        = "loot",
				default     = {},
				layoutRight = 0
			},
			{
				title       = loc.EFFECT_ITEM_LOOT_DROP,
				description = loc.EFFECT_ITEM_LOOT_DROP_TT,
				type        = "boolean",
				default     = false,
				layoutLeft  = 3
			}
		},
		category = loc.INV_PAGE_CHARACTER_INV
	});

	addon.script.registerEffect({
		id          = "item_roll_dice",
		title       = loc.EFFECT_ITEM_DICE,
		description = loc.EFFECT_ITEM_DICE_TT,
		GetPreview  = function(self, _effect, roll, var, source)
			if var ~= "" then
				return loc.EFFECT_ITEM_DICE_PREVIEW_STORED:format(
					fmt(self.parameters[1], roll),
					fmt(self.parameters[2], var) .. " (" .. fmt(self.parameters[3], source) ..")"
				);
			else
				return loc.EFFECT_ITEM_DICE_PREVIEW:format(fmt(self.parameters[1], roll));
			end
		end,
		icon        = "inv_misc_dice_02",
		parameters  = {
			{
				title       = loc.EFFECT_ITEM_DICE_ROLL,
				description = loc.EFFECT_ITEM_DICE_ROLL_TT,
				type        = "string",
				default     = "1d100"
			},
			{
				title       = loc.EFFECT_ITEM_DICE_ROLL_VAR,
				description = loc.EFFECT_ITEM_DICE_ROLL_VAR_TT,
				type        = "variable",
				default     = "",
				groupId     = "variable",
				memberIndex = 1
			},
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
			}
		},
		category = loc.INV_PAGE_CHARACTER_INV
	});

	-- DOCUMENT
	addon.script.registerEffect({
		id          = "document_show",
		title       = loc.EFFECT_DOC_DISPLAY,
		description = loc.EFFECT_DOC_DISPLAY_TT,
		GetPreview  = function(self, _effect, objectId)
			return (loc.EFFECT_DOC_ID .. ": %s"):format(fmt(self.parameters[1], objectId));
		end,
		icon        = "inv_icon_mission_complete_order",
		parameters  = {
			{
				title       = loc.EFFECT_DOC_ID,
				description = loc.EFFECT_DOC_ID_TT,
				type        = "document",
				default     = "",
				nillable    = true
			},
		},
		category = loc.TYPE_DOCUMENT
	});

	addon.script.registerEffect({
		id          = "document_close",
		title       = loc.EFFECT_DOC_CLOSE,
		description = loc.EFFECT_DOC_CLOSE_TT,
		GetPreview  = function(self, _effect)
			return loc.EFFECT_DOC_CLOSE;
		end,
		icon        = "trade_archaeology_silverscrollcase",
		category = loc.TYPE_DOCUMENT
	});

	-- AURA
	addon.script.registerEffect({
		id          = "aura_apply",
		title       = loc.EFFECT_AURA_APPLY,
		description = loc.EFFECT_AURA_APPLY_TT,
		GetPreview  = function(self, _effect, auraId, mergeMode)
			return loc.EFFECT_AURA_APPLY_PREVIEW:format(
				fmt(self.parameters[1], auraId),
				loc.EFFECT_AURA_APPLY_MERGE_MODE,
				fmt(self.parameters[2], mergeMode)
			);
		end,
		icon        = "ability_priest_spiritoftheredeemer",
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
				title       = loc.EFFECT_AURA_APPLY_MERGE_MODE,
				description = loc.EFFECT_AURA_APPLY_MERGE_MODE, -- TODO
				type        = "string",
				default     = "",
				values      = {
					{"" , loc.EFFECT_AURA_APPLY_DO_NOTHING, loc.EFFECT_AURA_APPLY_DO_NOTHING_TT},
					{"=", loc.EFFECT_AURA_APPLY_REFRESH, loc.EFFECT_AURA_APPLY_REFRESH_TT},
					{"+", loc.EFFECT_AURA_APPLY_EXTEND, loc.EFFECT_AURA_APPLY_EXTEND_TT},
				}
			}
		},
		category = loc.TYPE_AURA
	});

	addon.script.registerEffect({
		id          = "aura_duration",
		title       = loc.EFFECT_AURA_DURATION,
		description = loc.EFFECT_AURA_DURATION_TT,
		GetPreview  = function(self, _effect, auraId, duration, mode)
			return loc.EFFECT_AURA_DURATION_PREVIEW:format(
				fmt(self.parameters[1], auraId),
				fmt(self.parameters[2], duration),
				fmt(self.parameters[3], mode)
			);
		end,
		icon        = "achievement_guildperk_workingovertime",
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
				title       = loc.AU_FIELD_DURATION,
				description = loc.AU_FIELD_DURATION_TT,
				type        = "number",
				default     = 0,
				taggable    = true,
				nillable    = true
			},
			{
				title       = loc.AU_FIELD_DURATION,
				description = loc.AU_FIELD_DURATION, -- TODO
				type        = "string",
				default     = "=",
				values      = {
					{"=", loc.EFFECT_AURA_DURATION_SET, loc.EFFECT_AURA_DURATION_SET_TT},
					{"+", loc.EFFECT_AURA_DURATION_ADD, loc.EFFECT_AURA_DURATION_ADD_TT},
					{"-", loc.EFFECT_AURA_DURATION_SUBTRACT, loc.EFFECT_AURA_DURATION_SUBTRACT_TT},
				}
			}
		},
		category = loc.TYPE_AURA
	});

	addon.script.registerEffect({
		id          = "aura_remove",
		title       = loc.EFFECT_AURA_REMOVE,
		description = loc.EFFECT_AURA_REMOVE,
		GetPreview  = function(self, _effect, auraId)
			return loc.EFFECT_AURA_REMOVE_PREVIEW:format(fmt(self.parameters[1], auraId));
		end,
		icon        = "ability_titankeeper_cleansingorb",
		parameters  = {
			{
				title       = loc.AURA_ID,
				description = loc.EFFECT_AURA_ID_TT,
				type        = "aura",
				default     = "",
				taggable    = true,
				nillable    = true
			}
		},
		category = loc.TYPE_AURA
	});

	addon.script.registerEffect({
		id          = "aura_var_set",
		title       = loc.EFFECT_VAR_AURA_CHANGE,
		description = loc.EFFECT_VAR_AURA_CHANGE_TT,
		GetPreview  = function(self, _effect, auraId, op, var, value)
			return loc.EFFECT_VAR_AURA_CHANGE_PREVIEW:format(
				fmt(self.parameters[1], auraId),
				op, --fmt(self.parameters[2], op),
				fmt(self.parameters[3], var),
				fmt(self.parameters[4], value)
			);
		end,
		icon        = "inv_10_inscription2_repcontracts_scroll_02_uprez",
		parameters  = {
			{
				title       = loc.AURA_ID,
				description = loc.EFFECT_AURA_ID_TT,
				type        = "aura",
				default     = "",
				taggable    = true
			},
			{
				title       = loc.EFFECT_OPERATION_TYPE,
				description = loc.EFFECT_OPERATION_TYPE, -- TODO
				type        = "string",
				default     = "[=]",
				values      = {
					{"[=]", loc.EFFECT_OPERATION_TYPE_INIT, loc.EFFECT_OPERATION_TYPE_INIT_TT},
					{"=", loc.EFFECT_OPERATION_TYPE_SET, loc.EFFECT_OPERATION_TYPE_SET_TT},
					{"+", loc.EFFECT_OPERATION_TYPE_ADD},
					{"-", loc.EFFECT_OPERATION_TYPE_SUB},
					{"x", loc.EFFECT_OPERATION_TYPE_MULTIPLY},
					{"/", loc.EFFECT_OPERATION_TYPE_DIV},
				}
			},
			{
				title       = loc.EFFECT_VAR,
				description = loc.EFFECT_VAR,
				type        = "variable",
				default     = "varName",
				groupId     = "variable",
				memberIndex = 1,
				scope       = "o"
			},
			{
				title       = loc.EFFECT_OPERATION_VALUE,
				description = loc.EFFECT_OPERATION_VALUE,
				type        = "string",
				default     = "0",
				taggable    = true
			},
		},
		category = loc.TYPE_AURA
	});

	addon.script.registerEffect({
		id          = "aura_run_workflow",
		title       = loc.EFFECT_AURA_RUN_WORKFLOW,
		description = loc.EFFECT_AURA_RUN_WORKFLOW_TT,
		GetPreview  = function(self, _effect, auraId, scriptId)
			return loc.EFFECT_AURA_RUN_WORKFLOW_PREVIEW:format(
				fmt(self.parameters[1], auraId),
				fmt(self.parameters[2], scriptId)
			);
		end,
		icon        = "inv_engineering_90_electrifiedether",
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
				title       = loc.EFFECT_RUN_WORKFLOW_ID,
				description = loc.EFFECT_RUN_WORKFLOW_ID_TT,
				type        = "string",
				default     = "id"
			},
		},
		category = loc.TYPE_AURA
	});

	-- CAMPAIGN
	addon.script.registerEffect({
		id          = "quest_start",
		title       = loc.EFFECT_QUEST_START,
		description = loc.EFFECT_QUEST_START_TT,
		GetPreview  = function(self, _effect, questId)
			return loc.EFFECT_QUEST_START_PREVIEW:format(
				fmt(self.parameters[1], questId)
			);
		end,
		icon        = "achievement_quests_completed_01",
		parameters  = {
			{
				title       = loc.EFFECT_QUEST_START_ID,
				description = loc.EFFECT_QUEST_START_ID_TT,
				type        = "quest",
				default     = "",
				nillable    = true
			}
		},
		category = loc.EFFECT_CAT_CAMPAIGN
	});

	addon.script.registerEffect({
		id          = "quest_goToStep",
		title       = loc.EFFECT_QUEST_GOTOSTEP,
		description = loc.EFFECT_QUEST_GOTOSTEP_TT,
		GetPreview  = function(self, _effect, stepId)
			return loc.EFFECT_QUEST_GOTOSTEP_PREVIEW:format(
				fmt(self.parameters[1], stepId)
			);
		end,
		icon        = "achievement_quests_completed_02",
		parameters  = {
			{
				title       = loc.EFFECT_QUEST_GOTOSTEP_ID,
				description = loc.EFFECT_QUEST_GOTOSTEP_ID_TT,
				type        = "step",
				default     = "",
				nillable    = true
			}
		},
		category = loc.EFFECT_CAT_CAMPAIGN
	});

	addon.script.registerEffect({
		id          = "quest_revealObjective",
		title       = loc.EFFECT_QUEST_REVEAL_OBJ,
		description = loc.EFFECT_QUEST_REVEAL_OBJ_TT,
		GetPreview  = function(self, _effect, questId, objectiveId)
			return loc.EFFECT_QUEST_REVEAL_OBJ_PREVIEW:format(
				fmt(self.parameters[2], objectiveId),
				fmt(self.parameters[1], questId)
			);
		end,
		icon        = "icon_treasuremap",
		parameters  = {
			{
				title       = loc.EFFECT_QUEST_START_ID,
				description = loc.EFFECT_QUEST_START_ID_TT,
				type        = "quest",
				default     = "",
				nillable    = true,
				onChange    = function(widget, widgets)
					widgets[2]:SetQuestContext(widget:GetValue());
				end
			},
			{
				title       = loc.EFFECT_QUEST_OBJ_ID,
				description = loc.EFFECT_QUEST_OBJ_ID_TT, -- TODO
				type        = "objective",
				default     = "",
				nillable    = true
			}
		},
		category = loc.EFFECT_CAT_CAMPAIGN
	});

	addon.script.registerEffect({
		id          = "quest_markObjDone",
		title       = loc.EFFECT_QUEST_REVEAL_OBJ_DONE,
		description = loc.EFFECT_QUEST_REVEAL_OBJ_DONE_TT,
		GetPreview  = function(self, _effect, questId, objectiveId)
			return loc.EFFECT_QUEST_REVEAL_OBJ_DONE_PREVIEW:format(
				fmt(self.parameters[2], objectiveId),
				fmt(self.parameters[1], questId)
			);
		end,
		icon        = "inv_misc_map_01",
		parameters  = {
			{
				title       = loc.EFFECT_QUEST_START_ID,
				description = loc.EFFECT_QUEST_START_ID_TT,
				type        = "quest",
				default     = "",
				nillable    = true,
				onChange    = function(widget, widgets)
					widgets[2]:SetQuestContext(widget:GetValue());
				end
			},
			{
				title       = loc.EFFECT_QUEST_OBJ_ID,
				description = loc.EFFECT_QUEST_OBJ_ID_TT, -- TODO
				type        = "objective",
				default     = "",
				nillable    = true
			}
		},
		category = loc.EFFECT_CAT_CAMPAIGN
	});

	-- CUTSCENE
	addon.script.registerEffect({
		id          = "dialog_start",
		title       = loc.EFFECT_DIALOG_START,
		description = loc.EFFECT_DIALOG_START_TT,
		GetPreview  = function(self, _effect, dialogId)
			return loc.EFFECT_DIALOG_START_PREVIEW:format(
				fmt(self.parameters[1], dialogId)
			);
		end,
		icon        = "warrior_disruptingshout",
		parameters  = {
			{
				title       = loc.EFFECT_DIALOG_ID,
				description = loc.EFFECT_DIALOG_ID,
				type        = "dialog",
				default     = "",
				nillable    = true
			},
		},
		category = loc.EFFECT_CAT_CAMPAIGN
	});

	addon.script.registerEffect({
		id          = "dialog_quick",
		title       = loc.EFFECT_DIALOG_QUICK,
		description = loc.EFFECT_DIALOG_QUICK_TT,
		GetPreview  = function(self, _effect, text)
			return loc.EFFECT_TEXT_PREVIEW:format(
				fmt(self.parameters[1], text) -- TODO
			);
		end,
		icon        = "inv_inscription_scrollofwisdom_01",
		parameters  = {
			{
				title       = "Dialog text", -- TODO
				description = "Dialog text",
				type        = "multiline",
				default     = loc.EFFECT_TEXT_TEXT_DEFAULT,
				nillable    = true
			},
		},
		category = loc.EFFECT_CAT_CAMPAIGN
	});

	-- CAMERA
	addon.script.registerEffect({
		id          = "cam_zoom_in",
		title       = loc.EFFECT_CAT_CAMERA_ZOOM_IN,
		description = loc.EFFECT_CAT_CAMERA_ZOOM_IN_TT,
		GetPreview  = function(self, _effect, increment)
			return loc.EFFECT_CAT_CAMERA_ZOOM_IN:format(
				fmt(self.parameters[1], increment) -- TODO
			);
		end,
		icon        = "inv_misc_spyglass_03",
		parameters  = {
			{
				title       = loc.EFFECT_CAT_CAMERA_ZOOM_DISTANCE,
				description = loc.EFFECT_CAT_CAMERA_ZOOM_DISTANCE,
				type        = "string",
				default     = "5", -- TODO wtf
				taggable    = true
			},
		},
		category = loc.EFFECT_CAT_CAMERA
	});

	addon.script.registerEffect({
		id          = "cam_zoom_out",
		title       = loc.EFFECT_CAT_CAMERA_ZOOM_OUT,
		description = loc.EFFECT_CAT_CAMERA_ZOOM_OUT_TT,
		GetPreview  = function(self, _effect, increment)
			return loc.EFFECT_CAT_CAMERA_ZOOM_OUT:format(
				fmt(self.parameters[1], increment) -- TODO
			);
		end,
		icon        = "inv_misc_spyglass_03",
		parameters  = {
			{
				title       = loc.EFFECT_CAT_CAMERA_ZOOM_DISTANCE,
				description = loc.EFFECT_CAT_CAMERA_ZOOM_DISTANCE,
				type        = "string",
				default     = "5", -- TODO wtf
				taggable    = true
			},
		},
		category = loc.EFFECT_CAT_CAMERA
	});

	addon.script.registerEffect({
		id          = "cam_save",
		title       = loc.EFFECT_CAT_CAMERA_SAVE,
		description = loc.EFFECT_CAT_CAMERA_SAVE_TT,
		GetPreview  = function(self, _effect, slot)
			return loc.EFFECT_CAT_CAMERA_SAVE:format(
				fmt(self.parameters[1], slot) -- TODO
			);
		end,
		icon        = "inv_misc_spyglass_02",
		parameters  = {
			{
				title       = loc.EFFECT_CAT_CAMERA_SLOT,
				description = loc.EFFECT_CAT_CAMERA_SLOT_TT,
				type        = "number",
				values      = {
					{2, "Slot 2"},
					{3, "Slot 3"},
					{4, "Slot 4"},
					{5, "Slot 5"},
				},
				default     = 1 -- TODO check this one. SaveView accepts numbers 1-5, 1 is reserved for first person and cannot be saved
			},
		},
		category = loc.EFFECT_CAT_CAMERA
	});

	addon.script.registerEffect({
		id          = "cam_load",
		title       = loc.EFFECT_CAT_CAMERA_LOAD,
		description = loc.EFFECT_CAT_CAMERA_LOAD_TT,
		GetPreview  = function(self, _effect, slot)
			return loc.EFFECT_CAT_CAMERA_LOAD:format(
				fmt(self.parameters[1], slot) -- TODO
			);
		end,
		icon        = "inv_misc_spyglass_01",
		parameters  = {
			{
				title       = loc.EFFECT_CAT_CAMERA_SLOT,
				description = loc.EFFECT_CAT_CAMERA_SLOT_TT,
				type        = "number",
				values      = {
					{1, "First person"},
					{2, "Slot 2"},
					{3, "Slot 3"},
					{4, "Slot 4"},
					{5, "Slot 5"},
				},
				default     = 1
			},
		},
		category = loc.EFFECT_CAT_CAMERA
	});

	-- "EXPERT"
	addon.script.registerEffect({
		id          = "var_object",
		title       = loc.EFFECT_VAR_OBJECT_CHANGE,
		description = loc.EFFECT_VAR_OBJECT_CHANGE_TT,
		GetPreview  = function(self, _effect, source, operation, var, value)
			if operation == "=" or operation == "[=]" then
				return ("%s: (%s) %s %s %s"):format(
					fmt(self.parameters[2], operation),
					fmt(self.parameters[1], source),
					fmt(self.parameters[3], var),
					tostring(operation),
					fmt(self.parameters[3], value)
				);
			else
				local v = fmt(self.parameters[3], var);
				return ("%s: (%s) %s = %s %s %s"):format(
					fmt(self.parameters[2], operation),
					fmt(self.parameters[1], source),
					v,
					v,
					tostring(operation),
					fmt(self.parameters[3], value)
				);
			end
		end,
		icon        = "inv_inscription_minorglyph01",
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
				title       = loc.EFFECT_OPERATION_TYPE,
				description = loc.EFFECT_OPERATION_TYPE, -- TODO
				type        = "string",
				default     = "[=]",
				values      = {
					{"[=]", loc.EFFECT_OPERATION_TYPE_INIT, loc.EFFECT_OPERATION_TYPE_INIT_TT},
					{"=", loc.EFFECT_OPERATION_TYPE_SET, loc.EFFECT_OPERATION_TYPE_SET_TT},
					{"+", loc.EFFECT_OPERATION_TYPE_ADD},
					{"-", loc.EFFECT_OPERATION_TYPE_SUB},
					{"x", loc.EFFECT_OPERATION_TYPE_MULTIPLY},
					{"/", loc.EFFECT_OPERATION_TYPE_DIV},
				}
			},
			{
				title       = loc.EFFECT_VAR,
				description = loc.EFFECT_VAR,
				type        = "variable",
				default     = "varName",
				groupId     = "variable",
				memberIndex = 1
			},
			{
				title       = loc.EFFECT_OPERATION_VALUE,
				description = loc.EFFECT_OPERATION_VALUE,
				type        = "string",
				default     = "0",
				taggable    = true
			},
		},
		category = loc.MODE_EXPERT
	});

	addon.script.registerEffect({
		id          = "var_operand",
		title       = loc.EFFECT_VAR_OPERAND,
		description = loc.EFFECT_VAR_OPERAND_TT,
		GetPreview  = function(self, _effect, var, source, operandId, operandArgs)
			return ("(%s) %s = %s"):format(
				fmt(self.parameters[2], source),
				fmt(self.parameters[1], var),
				addon.script.getOperandPreview({
					id = tostring(operandId),
					parameters = operandArgs or TRP3_API.globals.empty
				})
			);
		end,
		icon        = "inv_inscription_minorglyph04",
		parameters  = {
			{
				title       = loc.EFFECT_VAR,
				description = loc.EFFECT_VAR,
				type        = "variable",
				default     = "varName",
				layoutLeft  = 0,
				groupId     = "variable",
				memberIndex = 1
			},
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
				title       = "Operand",
				description = "Operand", -- TODO
				type        = "operand",
				default     = "random",
				groupId     = "operand",
				memberIndex = 1,
				layoutRight = 0
			},
			{
				title       = "Operand Arguments",
				description = "Operand Arguments",
				type        = "operand_args",
				default     = {1, 100},
				groupId     = "operand",
				memberIndex = 2
			},
		},
		category = loc.MODE_EXPERT
	});

	addon.script.registerEffect({
		id          = "var_prompt",
		title       = loc.EFFECT_PROMPT,
		description = loc.EFFECT_PROMPT_TT,
		GetPreview  = function(self, _effect, prompt, var, source, callback, callbackSource)
			if callback == "" then
				return ("Ask the player to input (%s) %s: %s"):format(
					fmt(self.parameters[3], source),
					fmt(self.parameters[2], var),
					fmt(self.parameters[1], prompt)
				);
			else
				return ("Ask the player to input (%s) %s: %s, then run workflow %s in %s"):format(
					fmt(self.parameters[3], source),
					fmt(self.parameters[2], var),
					fmt(self.parameters[1], prompt),
					fmt(self.parameters[4], callback),
					fmt(self.parameters[5], callbackSource)
				);
			end
		end,
		icon        = "inv_gizmo_hardenedadamantitetube",
		parameters  = {
			{
				title       = loc.EFFECT_PROMPT_TEXT,
				description = loc.EFFECT_PROMPT_TEXT_TT,
				type        = "string",
				default     = "Please enter some input"
			},
			{
				title       = loc.EFFECT_PROMPT_VAR,
				description = loc.EFFECT_PROMPT_VAR_TT,
				type        = "variable",
				default     = "input",
				groupId     = "variable",
				memberIndex = 1
			},
			{
				title       = loc.EFFECT_SOURCE_V,
				description = loc.EFFECT_SOURCE_V, -- TODO
				type        = "scope",
				default     = "o",
				values      = {
					{"o", loc.EFFECT_SOURCE_OBJECT, loc.EFFECT_SOURCE_OBJECT_TT},
					{"c", loc.EFFECT_SOURCE_CAMPAIGN, loc.EFFECT_SOURCE_CAMPAIGN_TT},
				},
				groupId     = "variable",
				memberIndex = 2
			},
			{
				title       = loc.EFFECT_PROMPT_CALLBACK,
				description = loc.EFFECT_PROMPT_CALLBACK_TT,
				type        = "string",
				default     = ""
			},
			{
				title       = loc.EFFECT_SOURCE_W,
				description = loc.EFFECT_SOURCE_W, -- TODO
				type        = "string",
				default     = "o",
				values      = {
					{"o", loc.EFFECT_SOURCE_OBJECT, loc.EFFECT_W_OBJECT_TT},
					{"c", loc.EFFECT_SOURCE_CAMPAIGN, loc.EFFECT_W_CAMPAIGN_TT},
				}
			},
		},
		category = loc.MODE_EXPERT
	});

	addon.script.registerEffect({
		id          = "signal_send",
		title       = loc.EFFECT_SIGNAL,
		description = loc.EFFECT_SIGNAL_TT,
		GetPreview  = function(self, _effect, id, value)
			return loc.EFFECT_SIGNAL_PREVIEW:format(
				fmt(self.parameters[1], id),
				fmt(self.parameters[2], value)
			);
		end,
		icon        = "Inv_gizmo_goblingtonkcontroller",
		parameters  = {
			{
				title       = loc.EFFECT_SIGNAL_ID,
				description = loc.EFFECT_SIGNAL_ID_TT,
				type        = "string",
				default     = "id",
				nillable    = true
			},
			{
				title       = loc.EFFECT_SIGNAL_VALUE,
				description = loc.EFFECT_SIGNAL_VALUE_TT,
				type        = "string",
				default     = "value",
				taggable    = true,
				nillable    = true
			}
		},
		category = loc.MODE_EXPERT
	});

	addon.script.registerEffect({
		id          = "run_workflow",
		title       = loc.EFFECT_RUN_WORKFLOW,
		description = loc.EFFECT_RUN_WORKFLOW_TT,
		GetPreview  = function(self, _effect, source, scriptId)
			return loc.EFFECT_RUN_WORKFLOW_PREVIEW:format(
				fmt(self.parameters[2], scriptId),
				fmt(self.parameters[1], source)
			);
		end,
		icon        = "inv_gizmo_electrifiedether",
		parameters  = {
			{
				title       = loc.EFFECT_SOURCE,
				description = loc.EFFECT_SOURCE, -- TODO
				type        = "string",
				default     = "o",
				values      = {
					{"o", loc.EFFECT_SOURCE_OBJECT, loc.EFFECT_W_OBJECT_TT},
					{"c", loc.EFFECT_SOURCE_CAMPAIGN, loc.EFFECT_W_CAMPAIGN_TT},
				}
			},
			{
				title       = loc.EFFECT_RUN_WORKFLOW_ID,
				description = loc.EFFECT_RUN_WORKFLOW_ID_TT,
				type        = "string",
				default     = "id"
			}
		},
		category = loc.MODE_EXPERT
	});

	addon.script.registerEffect({
		id          = "run_item_workflow",
		title       = loc.EFFECT_ITEM_WORKFLOW,
		description = loc.EFFECT_ITEM_WORKFLOW_TT,
		GetPreview  = function(self, _effect, source, scriptId, slotId)
			if source == "ch" then
				return loc.EFFECT_ITEM_WORKFLOW_PREVIEW_C:format(fmt(self.parameters[2], scriptId), fmt(self.parameters[3], slotId));
			else
				return loc.EFFECT_ITEM_WORKFLOW_PREVIEW_S:format(fmt(self.parameters[2], scriptId), fmt(self.parameters[3], slotId));
			end
		end,
		icon        = "inv_gizmo_electrifiedether",
		parameters  = {
			{
				title       = loc.EFFECT_SOURCE,
				description = loc.EFFECT_SOURCE, -- TODO
				type        = "string",
				default     = "ch",
				values      = {
					{"ch", loc.EFFECT_SOURCE_SLOT, loc.EFFECT_SOURCE_SLOT_TT},
					{"si", loc.EFFECT_SOURCE_SLOT_B, loc.EFFECT_SOURCE_SLOT_B_TT},
				}
			},
			{
				title       = loc.EFFECT_RUN_WORKFLOW_ID,
				description = loc.EFFECT_RUN_WORKFLOW_ID_TT,
				type        = "string",
				default     = "id"
			},
			{
				title       = loc.EFFECT_RUN_WORKFLOW_SLOT,
				description = loc.EFFECT_RUN_WORKFLOW_SLOT_TT,
				type        = "string",
				default     = "1"
			}
		},
		context = {TRP3_DB.types.ITEM},
		category = loc.MODE_EXPERT
	});

	addon.script.registerEffect({
		id          = "secure_macro",
		title       = loc.EFFECT_SECURE_MACRO_ACTION_NAME,
		description = loc.EFFECT_SECURE_MACRO_DESCRIPTION,
		GetPreview  = function(self, _effect, macro)
			return loc.EFFECT_SECURE_MACRO_ACTION_NAME:format(fmt(self.parameters[1], macro));
		end,
		icon        = "inv_eng_gizmo3",
		parameters  = {
			{
				title       = loc.EFFECT_SECURE_MACRO_HELP_TITLE,
				description = loc.EFFECT_SECURE_MACRO_HELP,
				type        = "macro",
				default     = "",
				taggable    = true,
				nillable    = true
			},
		},
		category = loc.MODE_EXPERT
	});

	addon.script.registerEffect({
		id          = "script",
		title       = loc.EFFECT_SCRIPT,
		description = loc.EFFECT_SCRIPT_TT,
		GetPreview  = function(self, _effect, script)
			return ("Run Lua script %s"):format(fmt(self.parameters[1], script));
		end,
		icon        = "inv_inscription_scroll_fortitude",
		parameters  = {
			{
				title       = loc.EFFECT_SCRIPT_SCRIPT,
				description = loc.EFFECT_SCRIPT_SCRIPT_TT,
				type        = "script",
				default     = "-- Your script here",
				nillable    = true
			},
		},
		category = loc.MODE_EXPERT
	});
end
