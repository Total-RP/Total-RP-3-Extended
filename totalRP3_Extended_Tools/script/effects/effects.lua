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
local wipe, pairs, tostring, strtrim, assert = wipe, pairs, tostring, strtrim, assert;
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
			scriptStepFrame.description:SetText("|cffffff00" ..loc("EFFECT_TEXT_PREVIEW") .. ":|r " .. args[1]);
		end,
		getDefaultArgs = function()
			return {loc("EFFECT_TEXT_TEXT_DEFAULT"), 1};
		end,
		editor = text_editor,
	});
end

function text_editor.load(scriptData)
	local data = scriptData.args or Globals.empty;
	text_editor.text:SetText(data[1] or "");
	text_editor.type:SetSelectedValue(data[2] or Utils.message.type.CHAT_FRAME);
end

function text_editor.save(scriptData)
	scriptData.args[1] = stEtN(strtrim(text_editor.text:GetText()));
	scriptData.args[2] = text_editor.type:GetSelectedValue() or Utils.message.type.CHAT_FRAME;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- dismissMount - dismissCritter: Simple companion effects
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function companion_dismiss_mount_init()
	registerEffectEditor("companion_dismiss_mount", {
		title = "Dismiss mount", -- TODO: locals
		icon = "ability_skyreach_dismount",
		description = "Dismount the player from his current mount.", -- TODO: locals
	});
end

local function companion_dismiss_critter_init()
	registerEffectEditor("companion_dismiss_critter", {
		title = "Dismiss battle pet", -- TODO: locals
		icon = "inv_pet_pettrap01",
		description = "Dismiss the currently invoked battle pet.", -- TODO: locals
	});
end

local function companion_random_critter_init()
	registerEffectEditor("companion_random_critter", {
		title = "Summon random battle pet", -- TODO: locals
		icon = "ability_hunter_beastcall",
		description = "Summon a random battle pet, picked up in your favorite pets pool.", -- TODO: locals
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- item_sheath: Item: Toggle weapon sheath
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function item_sheath_init()
	registerEffectEditor("item_sheath", {
		title = "Toggle weapons sheath", -- TODO: locals
		icon = "garrison_blueweapon",
		description = "Draw or put up the character weapons.", -- TODO: locals
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- var_set_execenv: Variables set
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local varSetEditor = TRP3_EffectEditorVarSet;

local function var_set_execenv_init()
	registerEffectEditor("var_set_execenv", {
		title = "Workflow variable", -- TODO: locals
		icon = "inv_inscription_minorglyph00",
		description = "Sets a variable for the current workflow execution.\n\n|cff00ff00This variable exists only during a workflow execution and will be discarded afterward.", -- TODO: locals
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .."Variable" .. ":|r " .. args[1]); -- TODO: locals
		end,
		getDefaultArgs = function()
			return {"varName", "Variable value"};
		end,
		editor = varSetEditor
	});

	-- Var name
	varSetEditor.var.title:SetText("Variable name")-- TODO: locals;
	setTooltipForSameFrame(varSetEditor.var.help, "RIGHT", 0, 5, "Variable name", "");-- TODO: locals

	-- Var value
	varSetEditor.value.title:SetText("Variable value");-- TODO: locals
	setTooltipForSameFrame(varSetEditor.value.help, "RIGHT", 0, 5, "Variable value", "");-- TODO: locals
end

function varSetEditor.load(scriptData)
	local data = scriptData.args or Globals.empty;
	varSetEditor.var:SetText(data[1] or "");
	varSetEditor.value:SetText(data[2] or "");
end

function varSetEditor.save(scriptData)
	scriptData.args[1] = stEtN(strtrim(varSetEditor.var:GetText()));
	scriptData.args[2] = stEtN(strtrim(varSetEditor.value:GetText()));
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- DEBUGS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local debugDumpArgEditor = TRP3_EffectEditorDebugDumpArg;
local debugDumpTextEditor = TRP3_EffectEditorDebugDumpText;

local function debugs_init()
	registerEffectEditor("debug_dump_args", {
		title = "Debug dump args", -- TODO: locals
		icon = "temp",
		description = "Dump in chat frame the current workflow variables.", -- TODO: locals
	});

	registerEffectEditor("debug_dump_arg", {
		title = "Debug dump arg", -- TODO: locals
		icon = "temp",
		description = "Dump in chat frame a specific workflow variables.", -- TODO: locals
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .."Variable name" .. ":|r " .. args[1]); -- TODO: locals
		end,
		getDefaultArgs = function()
			return {"varName"};
		end,
		editor = debugDumpArgEditor
	});

	-- Var name
	debugDumpArgEditor.var.title:SetText("Variable name");-- TODO: locals
	setTooltipForSameFrame(debugDumpArgEditor.var.help, "RIGHT", 0, 5, "Variable name", "");-- TODO: locals

	registerEffectEditor("debug_dump_text", {
		title = "Debug dump text", -- TODO: locals
		icon = "temp",
		description = "Display a text in debug chat frame. It's simple as that.", -- TODO: locals
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .."Text" .. ":|r " .. args[1]); -- TODO: locals
		end,
		getDefaultArgs = function()
			return {"Text to dump"};
		end,
		editor = debugDumpTextEditor
	});

	-- Text
	debugDumpTextEditor.text.title:SetText("Text");-- TODO: locals
	setTooltipForSameFrame(debugDumpTextEditor.text.help, "RIGHT", 0, 5, "Text", "");-- TODO: locals

end

function debugDumpArgEditor.load(scriptData)
	local data = scriptData.args or Globals.empty;
	debugDumpArgEditor.var:SetText(data[1] or "");
end

function debugDumpArgEditor.save(scriptData)
	scriptData.args[1] = stEtN(strtrim(debugDumpArgEditor.var:GetText()));
end

function debugDumpTextEditor.load(scriptData)
	local data = scriptData.args or Globals.empty;
	debugDumpTextEditor.text:SetText(data[1] or "");
end

function debugDumpTextEditor.save(scriptData)
	scriptData.args[1] = stEtN(strtrim(debugDumpTextEditor.text:GetText()));
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- document_show: Display document
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function document_show_init()
	registerEffectEditor("document_show", {
		title = "Open document", -- TODO: locals
		icon = "inv_icon_mission_complete_order",
		description = "Opens a document to the player.", -- TODO: locals
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .."Document" .. ":|r " .. args[1]); -- TODO: locals
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
	-- Narrative text
	speechEnvEditor.text.title:SetText("Narrative text"); -- TODO: locals
	setTooltipForSameFrame(speechEnvEditor.text.help, "RIGHT", 0, 5, "Narrative text", "Please do not include the leading pipe || character."); -- TODO: locals

	registerEffectEditor("speech_env", {
		title = "Speech: Narration", -- TODO: locals
		icon = "inv_misc_book_07",
		description = "Plays a narration as a formated emote.\n\n|cff00ff00Has the same effect as playing an emote starting with a || (pipe character). It will be formated in chat for other TRP users.", -- TODO: locals
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .."Text" .. ":|r " .. args[1]); -- TODO: locals
		end,
		getDefaultArgs = function()
			return {"The snow blows white on the mountain tonight ..."}; -- TODO: locals
		end,
		editor = speechEnvEditor,
	});
end

function speechEnvEditor.load(scriptData)
	local data = scriptData.args or Globals.empty;
	speechEnvEditor.text:SetText(data[1] or "");
end

function speechEnvEditor.save(scriptData)
	scriptData.args[1] = stEtN(strtrim(speechEnvEditor.text:GetText()));
end

local function speech_npc_init()
	-- Narrative text
	speechNPCEditor.text.title:SetText("Narrative text"); -- TODO: locals
	setTooltipForSameFrame(speechNPCEditor.text.help, "RIGHT", 0, 5, "Narrative text", "Please do not include the leading pipe || character."); -- TODO: locals

	-- Name
	speechNPCEditor.name.title:SetText("NPC name"); -- TODO: locals
	setTooltipForSameFrame(speechNPCEditor.name.help, "RIGHT", 0, 5, "NPC name", "The NPC name."); -- TODO: locals

	registerEffectEditor("speech_npc", {
		title = "Speech: NPC", -- TODO: locals
		icon = "ability_warrior_rallyingcry",
		description = "Plays a npc speech as a formated emote.\n\n|cff00ff00Has the same effect as playing an emote starting with a || (pipe character) with a npc name and a text. It will be formated in chat for other TRP users.", -- TODO: locals
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .."Formated text" .. ":|r " .. TRP3_API.ui.misc.getSpeechPrefixText(args[2], args[1], args[3])); -- TODO: locals
		end,
		getDefaultArgs = function()
			return {"Tish", TRP3_API.ui.misc.SPEECH_PREFIX.SAYS, "Hello from the other side."}; -- TODO: locals
		end,
		editor = speechNPCEditor,
	});
end

function speechNPCEditor.load(scriptData)
	local data = scriptData.args or Globals.empty;
	speechNPCEditor.name:SetText(data[1] or "");
	speechNPCEditor.text:SetText(data[3] or "");
end

function speechNPCEditor.save(scriptData)
	scriptData.args[1] = stEtN(strtrim(speechNPCEditor.name:GetText()));
	scriptData.args[3] = stEtN(strtrim(speechNPCEditor.text:GetText()));
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

	item_sheath_init();

	var_set_execenv_init();

	debugs_init();

--	document_show_init();
end