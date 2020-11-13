----------------------------------------------------------------------------------
-- Total RP 3: Extended features
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--	Copyright 2018 Morgane "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
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
local wipe, pairs, tinsert, sort, date = wipe, pairs, tinsert, table.sort, date;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local loc = TRP3_API.loc;
local toolFrame;

function TRP3_API.extended.tools.getEffectOperandLocale()
	local effectMenu = {
		[loc.WO_EFFECT_CAT_COMMON] = {
			"text",
		},
		[loc.EFFECT_CAT_SOUND] = {
			"sound_id_self",
			"sound_id_stop",
			"sound_music_self",
			"sound_music_stop",
			"sound_id_local",
			"sound_id_local_stop",
			"sound_music_local",
			"sound_music_local_stop",
		},
		[loc.EFFECT_CAT_SPEECH] = {
			"speech_env",
			"speech_npc",
			"speech_player",
			"do_emote",
		},
		[loc.REG_COMPANIONS] = {
			"companion_dismiss_mount",
			"companion_dismiss_critter",
			"companion_random_critter",
			"companion_summon_mount",
		},
		[loc.INV_PAGE_CHARACTER_INV] = {
			"item_add",
			"item_remove",
			"item_sheath",
			"item_bag_durability",
			"item_consume",
			"item_cooldown",
			"item_use",
			"item_loot",
			"item_roll_dice",
		},
		[loc.TYPE_DOCUMENT] = {
			"document_show",
			"document_close",
		},
		[loc.EFFECT_CAT_CAMPAIGN] = {
			"quest_start",
			"quest_goToStep",
			"quest_revealObjective",
			"quest_markObjDone",
			"dialog_start",
			"dialog_quick",
		},
		[loc.EFFECT_CAT_CAMERA] = {
			"cam_zoom_in",
			"cam_zoom_out",
			"cam_save",
			"cam_load",
		},
		[loc.MODE_EXPERT] = {
			"var_object",
			"var_operand",
			"var_prompt",
			"signal_send",
			"run_workflow",
			"run_item_workflow",
			"secure_macro",
			"script"
		},
		order = {
			loc.WO_EFFECT_CAT_COMMON,
			loc.EFFECT_CAT_SPEECH,
			loc.INV_PAGE_CHARACTER_INV,
			loc.TYPE_DOCUMENT,
			loc.EFFECT_CAT_CAMPAIGN,
			loc.EFFECT_CAT_SOUND,
			loc.REG_COMPANIONS,
			loc.EFFECT_CAT_CAMERA,
			"",
			loc.MODE_EXPERT,
		}
	}
	return effectMenu;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initScript(ToolFrame, effectMenu)
	TRP3_ScriptEditorNormal.init(ToolFrame, effectMenu);
	TRP3_ScriptEditorDelay.init(ToolFrame);
	TRP3_ConditionEditor.initOperands(ToolFrame);
	TRP3_ConditionEditor.init(ToolFrame);
	TRP3_ObjectBrowser.init();
end
