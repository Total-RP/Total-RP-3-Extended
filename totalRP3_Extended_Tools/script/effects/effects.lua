----------------------------------------------------------------------------------
-- Total RP 3: Extended features
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

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local tonumber, pairs, tostring, strtrim, assert = tonumber, pairs, tostring, strtrim, assert;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effect structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local EFFECTS = {}

local function registerEffectEditor(effectID, effectStructure)
	assert(not EFFECTS[effectID], "Already have an effect editor for " .. effectID);
	EFFECTS[effectID] = effectStructure;
end
TRP3_API.extended.tools.registerEffectEditor = registerEffectEditor;

function TRP3_API.extended.tools.getEffectEditorInfo(effectID)
	return EFFECTS[effectID] or Globals.empty;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- text: Display text
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local text_editor = TRP3_EffectEditorText;

local function text_init()

	-- Text
	text_editor.text.title:SetText(loc("EFFECT_TEXT_TEXT"));
	setTooltipForSameFrame(text_editor.text.help, "RIGHT", 0, 5, loc("EFFECT_TEXT_TEXT"), loc("EFFECT_TEXT_TEXT_TT"));

	-- Type
	local outputs = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_TEXT_TYPE"), loc("EFFECT_TEXT_TYPE_1")), Utils.message.type.CHAT_FRAME},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_TEXT_TYPE"), loc("EFFECT_TEXT_TYPE_2")), Utils.message.type.ALERT_POPUP},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_TEXT_TYPE"), loc("EFFECT_TEXT_TYPE_3")), Utils.message.type.RAID_ALERT},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_TEXT_TYPE"), loc("EFFECT_TEXT_TYPE_4")), Utils.message.type.ALERT_MESSAGE}
	}
	TRP3_API.ui.listbox.setupListBox(text_editor.type, outputs, nil, nil, 250, true);

	registerEffectEditor("text", {
		title = loc("EFFECT_TEXT"),
		icon = "inv_inscription_scrollofwisdom_01",
		description = loc("EFFECT_TEXT_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" ..loc("EFFECT_TEXT_PREVIEW") .. ":|r " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {loc("EFFECT_TEXT_TEXT_DEFAULT"), 1};
		end,
		editor = text_editor,
	});

	function text_editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		text_editor.text:SetText(data[1] or "");
		text_editor.type:SetSelectedValue(data[2] or Utils.message.type.CHAT_FRAME);
	end

	function text_editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(text_editor.text:GetText()));
		scriptData.args[2] = text_editor.type:GetSelectedValue() or Utils.message.type.CHAT_FRAME;
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- dismissMount - dismissCritter: Simple companion effects
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function companion_dismiss_mount_init()
	registerEffectEditor("companion_dismiss_mount", {
		title = loc("EFFECT_DISMOUNT"),
		icon = "ability_skyreach_dismount",
		description = loc("EFFECT_DISMOUNT_TT"),
	});
end

local function companion_dismiss_critter_init()
	registerEffectEditor("companion_dismiss_critter", {
		title = loc("EFFECT_DISPET"),
		icon = "inv_pet_pettrap01",
		description = loc("EFFECT_DISPET_TT"),
	});
end

local function companion_random_critter_init()
	registerEffectEditor("companion_random_critter", {
		title = loc("EFFECT_RANDSUM"),
		icon = "ability_hunter_beastcall",
		description = loc("EFFECT_RANDSUM_TT"),
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- item_sheath: Item: Toggle weapon sheath
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function item_sheath_init()
	registerEffectEditor("item_sheath", {
		title = loc("EFFECT_SHEATH"),
		icon = "garrison_blueweapon",
		description = loc("EFFECT_SHEATH_TT"),
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- var_set_execenv: Variables set
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local varSetEditor = TRP3_EffectEditorVarSet;

local function var_set_execenv_init()
	registerEffectEditor("var_set_execenv", {
		title = loc("EFFECT_VAR_WORK"),
		icon = "inv_inscription_minorglyph00",
		description = loc("EFFECT_VAR_WORK_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_VAR") .. ":|r " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {"varName", loc("EFFECT_VAR_VALUE")};
		end,
		editor = varSetEditor
	});

	-- Var name
	varSetEditor.var.title:SetText(loc("EFFECT_VAR"))
	setTooltipForSameFrame(varSetEditor.var.help, "RIGHT", 0, 5, loc("EFFECT_VAR"), "");

	-- Var value
	varSetEditor.value.title:SetText(loc("EFFECT_VAR_VALUE"));
	setTooltipForSameFrame(varSetEditor.value.help, "RIGHT", 0, 5, loc("EFFECT_VAR_VALUE"), "");

	function varSetEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		varSetEditor.var:SetText(data[1] or "");
		varSetEditor.value:SetText(data[2] or "");
	end

	function varSetEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(varSetEditor.var:GetText()));
		scriptData.args[2] = stEtN(strtrim(varSetEditor.value:GetText()));
	end

end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- DEBUGS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local debugDumpArgEditor = TRP3_EffectEditorDebugDumpArg;
local debugDumpTextEditor = TRP3_EffectEditorDebugDumpText;

local function debugs_init()
	registerEffectEditor("debug_dump_args", {
		title = loc("EFFECT_DEBUG_DUMP_ARGS"),
		icon = "temp",
		description = loc("EFFECT_DEBUG_DUMP_ARGS_TT"),
	});

	registerEffectEditor("debug_dump_arg", {
		title = loc("EFFECT_DEBUG_DUMP_ARG"),
		icon = "temp",
		description = loc("EFFECT_DEBUG_DUMP_ARG_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_VAR") .. ":|r " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {"varName"};
		end,
		editor = debugDumpArgEditor
	});

	-- Var name
	debugDumpArgEditor.var.title:SetText(loc("EFFECT_VAR"));
	setTooltipForSameFrame(debugDumpArgEditor.var.help, "RIGHT", 0, 5, loc("EFFECT_VAR"), "");

	function debugDumpArgEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		debugDumpArgEditor.var:SetText(data[1] or "");
	end

	function debugDumpArgEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(debugDumpArgEditor.var:GetText()));
	end

	registerEffectEditor("debug_dump_text", {
		title = loc("EFFECT_DEBUG_DUMP_TEXT"),
		icon = "temp",
		description = loc("EFFECT_DEBUG_DUMP_TEXT_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_TEXT_TEXT") .. ":|r " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {loc("EFFECT_TEXT_TEXT_TT")};
		end,
		editor = debugDumpTextEditor
	});

	-- Text
	debugDumpTextEditor.text.title:SetText(loc("EFFECT_TEXT_TEXT"));
	setTooltipForSameFrame(debugDumpTextEditor.text.help, "RIGHT", 0, 5, loc("EFFECT_TEXT_TEXT_TT"), "");

	function debugDumpTextEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		debugDumpTextEditor.text:SetText(data[1] or "");
	end

	function debugDumpTextEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(debugDumpTextEditor.text:GetText()));
	end

end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- document_show: Display document
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function document_show_init()
	registerEffectEditor("document_show", {
		title = loc("EFFECT_DOC_DISPLAY"),
		icon = "inv_icon_mission_complete_order",
		description = loc("EFFECT_DOC_DISPLAY_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc("TYPE_DOCUMENT") .. ":|r " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {""};
		end
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Speechs
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local speechEnvEditor = TRP3_EffectEditorSpeechEnv;
local speechNPCEditor = TRP3_EffectEditorSpeechNPC;

local function speech_env_init()
	registerEffectEditor("speech_env", {
		title = loc("EFFECT_SPEECH_NAR"),
		icon = "inv_misc_book_07",
		description = loc("EFFECT_SPEECH_NAR_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_TEXT_TEXT") .. ":|r " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {loc("EFFECT_SPEECH_NAR_DEFAULT")};
		end,
		editor = speechEnvEditor,
	});

	-- Narrative text
	speechEnvEditor.text.title:SetText(loc("EFFECT_TEXT_TEXT"));
	setTooltipForSameFrame(speechEnvEditor.text.help, "RIGHT", 0, 5, loc("EFFECT_TEXT_TEXT"), loc("EFFECT_SPEECH_NAR_TEXT_TT"));

	function speechEnvEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		speechEnvEditor.text:SetText(data[1] or "");
	end

	function speechEnvEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(speechEnvEditor.text:GetText()));
	end
end

local function speech_npc_init()
	registerEffectEditor("speech_npc", {
		title = loc("EFFECT_SPEECH_NPC"),
		icon = "ability_warrior_rallyingcry",
		description = loc("EFFECT_SPEECH_NPC_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_TEXT_PREVIEW") .. ":|r " .. TRP3_API.ui.misc.getSpeechPrefixText(args[2], args[1], args[3]));
		end,
		getDefaultArgs = function()
			return {"Tish", TRP3_API.ui.misc.SPEECH_PREFIX.SAYS, loc("EFFECT_SPEECH_NPC_DEFAULT")};
		end,
		editor = speechNPCEditor,
	});

	-- Name
	speechNPCEditor.name.title:SetText(loc("EFFECT_SPEECH_NPC_NAME"));
	setTooltipForSameFrame(speechNPCEditor.name.help, "RIGHT", 0, 5, loc("EFFECT_SPEECH_NPC_NAME"), loc("EFFECT_SPEECH_NPC_NAME_TT"));

	-- Narrative text
	speechNPCEditor.text.title:SetText(loc("EFFECT_TEXT_TEXT"));
	setTooltipForSameFrame(speechNPCEditor.text.help, "RIGHT", 0, 5, loc("EFFECT_TEXT_TEXT", loc("EFFECT_SPEECH_NAR_TEXT_TT")));

	function speechNPCEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		speechNPCEditor.name:SetText(data[1] or "");
		speechNPCEditor.text:SetText(data[3] or "");
	end

	function speechNPCEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(speechNPCEditor.name:GetText()));
		scriptData.args[3] = stEtN(strtrim(speechNPCEditor.text:GetText()));
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Sounds
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local SoundIDSelfEditor = TRP3_EffectEditorSoundIDSelf;

local function sound_id_self_init()
	registerEffectEditor("sound_id_self", {
		title = loc("EFFECT_SOUND_ID_SELF"),
		icon = "inv_misc_ear_human_02",
		description = loc("EFFECT_SOUND_ID_SELF_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_SOUND_ID_SELF_PREVIEW"):format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. tostring(args[1]) .. "|r"));
		end,
		getDefaultArgs = function()
			return {"SFX", 43569};
		end,
		editor = SoundIDSelfEditor,
	});

	-- Channel
	local outputs = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOUND_ID_SELF_CHANNEL"), loc("EFFECT_SOUND_ID_SELF_CHANNEL_SFX")), "SFX", loc("EFFECT_SOUND_ID_SELF_CHANNEL_SFX_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOUND_ID_SELF_CHANNEL"), loc("EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE")), "Ambience", loc("EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE_TT")},
	}
	TRP3_API.ui.listbox.setupListBox(SoundIDSelfEditor.channel, outputs, nil, nil, 250, true);

	-- ID
	SoundIDSelfEditor.id.title:SetText(loc("EFFECT_SOUND_ID_SELF_ID"));
	setTooltipForSameFrame(SoundIDSelfEditor.id.help, "RIGHT", 0, 5, loc("EFFECT_SOUND_ID_SELF_ID"), loc("EFFECT_SOUND_ID_SELF_ID_TT"));

	function SoundIDSelfEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		SoundIDSelfEditor.channel:SetSelectedValue(data[1] or "SFX");
		SoundIDSelfEditor.id:SetText(data[2]);
	end

	function SoundIDSelfEditor.save(scriptData)
		scriptData.args[1] = SoundIDSelfEditor.channel:GetSelectedValue() or "SFX";
		scriptData.args[2] = tonumber(strtrim(SoundIDSelfEditor.id:GetText()));
	end
end

local soundMusicEditor = TRP3_EffectEditorSoundMusicSelf;

local function sound_music_self_init()
	registerEffectEditor("sound_music_self", {
		title = loc("EFFECT_SOUND_MUSIC_SELF"),
		icon = "inv_misc_drum_07",
		description = loc("EFFECT_SOUND_MUSIC_SELF_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_SOUND_MUSIC_SELF_PREVIEW"):format("|cff00ff00" .. tostring(args[1])));
		end,
		getDefaultArgs = function()
			return {"zonemusic\\brewfest\\BF_Goblins1"};
		end,
		editor = soundMusicEditor,
	});

	-- ID
	soundMusicEditor.path.title:SetText(loc("EFFECT_SOUND_MUSIC_SELF_PATH"));
	setTooltipForSameFrame(soundMusicEditor.path.help, "RIGHT", 0, 5, loc("EFFECT_SOUND_MUSIC_SELF_PATH"), loc("EFFECT_SOUND_MUSIC_SELF_PATH_TT"));

	function soundMusicEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		soundMusicEditor.path:SetText(data[1]);
	end

	function soundMusicEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(soundMusicEditor.path:GetText()));
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initBaseEffects()
	text_init();

	companion_dismiss_mount_init();
	companion_dismiss_critter_init();
	companion_random_critter_init();

	speech_env_init();
	speech_npc_init();

	sound_id_self_init();
	sound_music_self_init();

	item_sheath_init();

	var_set_execenv_init();

	debugs_init();

--	document_show_init();
end