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
-- Commons
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local text_editor = TRP3_EffectEditorText;

local function text_init()

	-- Text
	setTooltipForSameFrame(text_editor.text, "RIGHT", 0, 5, loc("EFFECT_TEXT_TEXT"), loc("EFFECT_TEXT_TEXT_TT"));


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
		text_editor.text.scroll.text:SetText(data[1] or "");
		text_editor.type:SetSelectedValue(data[2] or Utils.message.type.CHAT_FRAME);
	end

	function text_editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(text_editor.text.scroll.text:GetText()));
		scriptData.args[2] = text_editor.type:GetSelectedValue() or Utils.message.type.CHAT_FRAME;
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Companions
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

local function companion_summon_mount_init()
	local editor = TRP3_EffectEditorCompanion;
	local GetMountInfoExtraByID, GetMountInfoByID = C_MountJournal.GetMountInfoExtraByID, C_MountJournal.GetMountInfoByID;

	local companionSelected = function(companionInfo)
		editor.select.Icon:SetTexture(companionInfo[2]);
		editor.select.Name:SetText(companionInfo[1])
		editor.select.InfoText:SetText(companionInfo[3]);
		editor.id = companionInfo[6];
	end

	editor.load = function(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id = data[1];
		local creatureName, spellID, icon = GetMountInfoByID(editor.id or 0);
		local _, description = GetMountInfoExtraByID(editor.id or 0);
		companionSelected({creatureName or loc("EFFECT_SUMMOUNT_NOMOUNT"), icon or "Interface\\ICONS\\inv_misc_questionmark", description or "", loc("PR_CO_MOUNT"), spellID, editor.id});
	end

	editor.save = function(scriptData)
		scriptData.args[1] = editor.id or 0;
	end

	editor.select:SetScript("OnClick", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.COMPANIONS, {parent = self, point = "RIGHT", parentPoint = "LEFT"}, {companionSelected, nil, editor.type});
	end);
	editor.type = TRP3_API.ui.misc.TYPE_MOUNT;

	registerEffectEditor("companion_summon_mount", {
		title = loc("EFFECT_SUMMOUNT"),
		icon = "ability_hunter_beastcall",
		description = loc("EFFECT_SUMMOUNT_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			local creatureName = GetMountInfoByID(args[1] or 0);
			scriptStepFrame.description:SetText("|cffffff00" ..loc("EFFECT_SUMMOUNT") .. ":|r " .. tostring(creatureName or loc("EFFECT_SUMMOUNT_NOMOUNT")));
		end,
		getDefaultArgs = function()
			return {0};
		end,
		editor = editor,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Workflow expertise
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function var_set_operand_init()
	local editor = TRP3_EffectEditorStoreVar;
	local getOperandEditorInfo = TRP3_API.extended.tools.getOperandEditorInfo;

	-- Var name
	editor.var.title:SetText(loc("EFFECT_VAR"))
	setTooltipForSameFrame(editor.var.help, "RIGHT", 0, 5, loc("EFFECT_VAR"), "");

	-- Source
	local sources = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOURCE"), loc("EFFECT_SOURCE_WORKFLOW")), "w", loc("EFFECT_SOURCE_WORKFLOW_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOURCE"), loc("EFFECT_SOURCE_OBJECT")), "o", loc("EFFECT_SOURCE_OBJECT_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOURCE"), loc("EFFECT_SOURCE_CAMPAIGN")), "c", loc("EFFECT_SOURCE_CAMPAIGN_TT")}
	}
	TRP3_API.ui.listbox.setupListBox(editor.source, sources, nil, nil, 250, true);

	local function onOperandSelected(operandID, listbox)
		local operand = getOperandEditorInfo(operandID) or Globals.empty;
		_G[listbox:GetName() .. "Text"]:SetText(operand.title or UNKNOWN);

		-- Show the editor, if any
		if editor.currentEditor then
			editor.currentEditor:Hide();
		end
		listbox.config:SetText(loc("EFFECT_VAR_OPERAND_CONFIG_NO"));
		if operand.editor then
			operand.editor:SetParent(editor);
			operand.editor:ClearAllPoints();
			operand.editor:SetPoint("LEFT", 100, 0);
			operand.editor:SetPoint("RIGHT", -100, 0);
			operand.editor:SetPoint("BOTTOM", 0, 20);
			operand.editor:SetPoint("TOP", listbox, "BOTTOM", 0, -10);
			operand.editor.load();
			editor.currentEditor = operand.editor;
			operand.editor:Show();
			listbox.config:SetText(loc("EFFECT_VAR_OPERAND_CONFIG"));
		end
	end

	function editor.load(scriptData)
		local structure = {};
		TRP3_API.extended.tools.getEvaluatedOperands(structure);
		TRP3_API.ui.listbox.setupListBox(editor.type, structure, onOperandSelected, nil, 255, true);

		local data = scriptData.args or Globals.empty;
		editor.var:SetText(data[1] or "varName");
		editor.source:SetSelectedValue(data[2] or "w");
		editor.type.selectedValue = data[3] or "random";
		onOperandSelected(editor.type:GetSelectedValue(), editor.type);

		local operand = getOperandEditorInfo(editor.type:GetSelectedValue()) or Globals.empty;
		if operand.editor and operand.editor.load then
			operand.editor.load(data[4]);
		end
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.var:GetText())) or "";
		scriptData.args[2] = editor.source:GetSelectedValue() or "w";
		scriptData.args[3] = editor.type:GetSelectedValue() or "random";

		local operand = getOperandEditorInfo(scriptData.args[3]) or Globals.empty;
		if operand.editor and operand.editor.save then
			scriptData.args[4] = operand.editor.save();
		end
	end

	local sourcesText = {
		w = loc("EFFECT_SOURCE_WORKFLOW"),
		o = loc("EFFECT_SOURCE_OBJECT"),
		c = loc("EFFECT_SOURCE_CAMPAIGN")
	}

	registerEffectEditor("var_operand", {
		title = loc("EFFECT_VAR_OPERAND"),
		icon = "inv_inscription_minorglyph04",
		description = loc("EFFECT_VAR_OPERAND_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			local varName = tostring(args[1]);
			local source = sourcesText[args[2]] or "?";
			local operandID = tostring(args[3]);
			local operand = getOperandEditorInfo(operandID) or Globals.empty;
			local text = operand.title or UNKNOWN;
			if operand.getText then
				text = operand.getText(args[4]);
			end
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_VAR_OPERAND") .. ": |cff00ff00(" .. source .. ")|r " .. varName .. " = |cff00ff00" .. text);
		end,
		getDefaultArgs = function()
			return {"varName", "w", "random"};
		end,
		editor = editor,
	});
end

local function var_set_execenv_init()
	local changeVarEditor = TRP3_EffectEditorVarChange;

	-- Var name
	changeVarEditor.var.title:SetText(loc("EFFECT_VAR"))
	setTooltipForSameFrame(changeVarEditor.var.help, "RIGHT", 0, 5, loc("EFFECT_VAR"), "");

	-- Var value
	changeVarEditor.value.title:SetText(loc("EFFECT_OPERATION_VALUE"));
	setTooltipForSameFrame(changeVarEditor.value.help, "RIGHT", 0, 5, loc("EFFECT_OPERATION_VALUE"), "");

	-- Type
	local types = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_OPERATION_TYPE"), loc("EFFECT_OPERATION_TYPE_INIT")), "[=]", loc("EFFECT_OPERATION_TYPE_INIT_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_OPERATION_TYPE"), loc("EFFECT_OPERATION_TYPE_SET")), "=", loc("EFFECT_OPERATION_TYPE_SET_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_OPERATION_TYPE"), loc("EFFECT_OPERATION_TYPE_ADD")), "+"},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_OPERATION_TYPE"), loc("EFFECT_OPERATION_TYPE_SUB")), "-"},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_OPERATION_TYPE"), loc("EFFECT_OPERATION_TYPE_MULTIPLY")), "x"},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_OPERATION_TYPE"), loc("EFFECT_OPERATION_TYPE_DIV")), "/"}
	}
	TRP3_API.ui.listbox.setupListBox(changeVarEditor.type, types, nil, nil, 250, true);

	-- Source
	local sources = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOURCE"), loc("EFFECT_SOURCE_WORKFLOW")), "w", loc("EFFECT_SOURCE_WORKFLOW_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOURCE"), loc("EFFECT_SOURCE_OBJECT")), "o", loc("EFFECT_SOURCE_OBJECT_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOURCE"), loc("EFFECT_SOURCE_CAMPAIGN")), "c", loc("EFFECT_SOURCE_CAMPAIGN_TT")}
	}
	TRP3_API.ui.listbox.setupListBox(changeVarEditor.source, sources, nil, nil, 250, true);

	function changeVarEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		changeVarEditor.source:SetSelectedValue(data[1] or "w");
		changeVarEditor.type:SetSelectedValue(data[2] or "[=]");
		changeVarEditor.var:SetText(data[3] or "varName");
		changeVarEditor.value:SetText(data[4] or "0");
	end

	function changeVarEditor.save(scriptData)
		scriptData.args[1] = changeVarEditor.source:GetSelectedValue() or "w";
		scriptData.args[2] = changeVarEditor.type:GetSelectedValue() or "[=]";
		scriptData.args[3] = stEtN(strtrim(changeVarEditor.var:GetText())) or "";
		scriptData.args[4] = stEtN(strtrim(changeVarEditor.value:GetText())) or "";
	end

	local sourcesText = {
		w = loc("EFFECT_SOURCE_WORKFLOW"),
		o = loc("EFFECT_SOURCE_OBJECT"),
		c = loc("EFFECT_SOURCE_CAMPAIGN")
	}

	registerEffectEditor("var_object", {
		title = loc("EFFECT_VAR_OBJECT_CHANGE"),
		icon = "inv_inscription_minorglyph01",
		description = loc("EFFECT_VAR_OBJECT_CHANGE_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			local source = sourcesText[args[1]] or "?";
			local varName = tostring(args[3]);
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_OPERATION") .. ": |cff00ff00(" .. source .. ")|r " .. varName .. " |cff00ff00=|r " .. varName .. " |cff00ff00" .. tostring(args[2]) .. "|r " .. tostring(args[4]));
		end,
		getDefaultArgs = function()
			return {"w", "[=]", "varName", 0};
		end,
		editor = changeVarEditor,
	});

end

local function signal_send_init()

	local editor = TRP3_EffectEditorSignalSend;

	registerEffectEditor("signal_send", {
		title = loc("EFFECT_SIGNAL"),
		icon = "Inv_gizmo_goblingtonkcontroller",
		description = loc("EFFECT_SIGNAL_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc("EFFECT_SIGNAL_PREVIEW"):format(tostring(args[1]), tostring(args[2])));
		end,
		getDefaultArgs = function()
			return {"id", "value"};
		end,
		editor = editor
	});

	-- Var name
	editor.id.title:SetText(loc("EFFECT_SIGNAL_ID"));
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc("EFFECT_SIGNAL_ID"), loc("EFFECT_SIGNAL_ID_TT"));

	-- Var value
	editor.value.title:SetText(loc("EFFECT_SIGNAL_VALUE"));
	setTooltipForSameFrame(editor.value.help, "RIGHT", 0, 5, loc("EFFECT_SIGNAL_VALUE"), loc("EFFECT_SIGNAL_VALUE_TT"));

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id:SetText(data[1] or "");
		editor.value:SetText(data[2] or "");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
		scriptData.args[2] = stEtN(strtrim(editor.value:GetText()));
	end

end

local function run_workflow_init()
	local editor = TRP3_EffectEditorRunWorkflow;

	-- Source
	local sources = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOURCE"), loc("EFFECT_SOURCE_OBJECT")), "o", loc("EFFECT_W_OBJECT_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOURCE"), loc("EFFECT_SOURCE_CAMPAIGN")), "c", loc("EFFECT_W_CAMPAIGN_TT")}
	}
	TRP3_API.ui.listbox.setupListBox(editor.source, sources, nil, nil, 250, true);

	-- ID
	editor.id.title:SetText(loc("EFFECT_RUN_WORKFLOW_ID"));
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc("EFFECT_RUN_WORKFLOW_ID"), loc("EFFECT_RUN_WORKFLOW_ID_TT"));


	local sourcesText = {
		o = loc("EFFECT_SOURCE_OBJECT"),
		c = loc("EFFECT_SOURCE_CAMPAIGN")
	}

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.source:SetSelectedValue(data[1] or "o");
		editor.id:SetText(data[2] or "id");
	end

	function editor.save(scriptData)
		scriptData.args[1] = editor.source:GetSelectedValue() or "o";
		scriptData.args[2] = stEtN(strtrim(editor.id:GetText())) or "";
	end

	registerEffectEditor("run_workflow", {
		title = loc("EFFECT_RUN_WORKFLOW"),
		icon = "inv_gizmo_electrifiedether",
		description = loc("EFFECT_RUN_WORKFLOW_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			local source = sourcesText[args[1]] or "?";
			local id = tostring(args[2]);
			scriptStepFrame.description:SetText(loc("EFFECT_RUN_WORKFLOW_PREVIEW"):format("|cff00ff00".. id .."|r", "|cff00ff00".. source .."|r"));
		end,
		getDefaultArgs = function()
			return {"o", "id"};
		end,
		editor = editor
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
			scriptStepFrame.description:SetText(tostring(args[1]));
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
			scriptStepFrame.description:SetText(TRP3_API.ui.misc.getSpeechPrefixText(args[2], args[1], args[3]));
		end,
		getDefaultArgs = function()
			return {"Tish", TRP3_API.ui.misc.SPEECH_PREFIX.SAYS, loc("EFFECT_SPEECH_NPC_DEFAULT")};
		end,
		editor = speechNPCEditor,
	});

	-- Name
	speechNPCEditor.name.title:SetText(loc("EFFECT_SPEECH_NPC_NAME"));
	setTooltipForSameFrame(speechNPCEditor.name.help, "RIGHT", 0, 5, loc("EFFECT_SPEECH_NPC_NAME"), loc("EFFECT_SPEECH_NPC_NAME_TT"));

	-- Type
	local types = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SPEECH_TYPE"), loc("NPC_SAYS")), TRP3_API.ui.misc.SPEECH_PREFIX.SAYS},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SPEECH_TYPE"), loc("NPC_YELLS")), TRP3_API.ui.misc.SPEECH_PREFIX.YELLS},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SPEECH_TYPE"), loc("NPC_WHISPERS")), TRP3_API.ui.misc.SPEECH_PREFIX.WHISPERS},
	}
	TRP3_API.ui.listbox.setupListBox(speechNPCEditor.type, types, nil, nil, 250, true);

	-- Narrative text
	speechNPCEditor.text.title:SetText(loc("EFFECT_TEXT_TEXT"));
	setTooltipForSameFrame(speechNPCEditor.text.help, "RIGHT", 0, 5, loc("EFFECT_TEXT_TEXT", loc("EFFECT_SPEECH_NAR_TEXT_TT")));

	function speechNPCEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		speechNPCEditor.name:SetText(data[1] or "");
		speechNPCEditor.type:SetSelectedValue(data[2] or TRP3_API.ui.misc.SPEECH_PREFIX.SAYS);
		speechNPCEditor.text:SetText(data[3] or "");
	end

	function speechNPCEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(speechNPCEditor.name:GetText()));
		scriptData.args[2] = speechNPCEditor.type:GetSelectedValue() or TRP3_API.ui.misc.SPEECH_PREFIX.SAYS;
		scriptData.args[3] = stEtN(strtrim(speechNPCEditor.text:GetText()));
	end
end

local function speech_player_init()
	local editor = TRP3_EffectEditorSpeechPlayer;

	registerEffectEditor("speech_player", {
		title = loc("EFFECT_SPEECH_PLAYER"),
		icon = "ability_warrior_warcry",
		description = loc("EFFECT_SPEECH_PLAYER_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(TRP3_API.ui.misc.getSpeech(args[2], args[1]));
		end,
		getDefaultArgs = function()
			return {TRP3_API.ui.misc.SPEECH_PREFIX.SAYS, loc("EFFECT_SPEECH_PLAYER_DEFAULT")};
		end,
		editor = editor,
	});

	-- Type
	local types = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SPEECH_TYPE"), loc("NPC_SAYS")), TRP3_API.ui.misc.SPEECH_PREFIX.SAYS},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SPEECH_TYPE"), loc("NPC_YELLS")), TRP3_API.ui.misc.SPEECH_PREFIX.YELLS},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SPEECH_TYPE"), loc("NPC_EMOTES")), TRP3_API.ui.misc.SPEECH_PREFIX.EMOTES},
	}
	TRP3_API.ui.listbox.setupListBox(editor.type, types, nil, nil, 250, true);

	-- Narrative text
	editor.text.title:SetText(loc("EFFECT_TEXT_TEXT"));
	setTooltipForSameFrame(editor.text.help, "RIGHT", 0, 5, loc("EFFECT_TEXT_TEXT", loc("EFFECT_SPEECH_NAR_TEXT_TT")));

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.type:SetSelectedValue(data[1] or TRP3_API.ui.misc.SPEECH_PREFIX.SAYS);
		editor.text:SetText(data[2] or "");
	end

	function editor.save(scriptData)
		scriptData.args[1] = editor.type:GetSelectedValue() or TRP3_API.ui.misc.SPEECH_PREFIX.SAYS;
		scriptData.args[2] = stEtN(strtrim(editor.text:GetText()));
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Sounds
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function sound_id_self_init()
	local SoundIDSelfEditor = TRP3_EffectEditorSoundIDSelf;

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

	SoundIDSelfEditor.play:SetText(loc("EFFECT_SOUND_PLAY"));
	SoundIDSelfEditor.play:SetScript("OnClick", function(self)
		Utils.music.playSoundID(tonumber(strtrim(SoundIDSelfEditor.id:GetText())), SoundIDSelfEditor.channel:GetSelectedValue() or "SFX");
	end);

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

local function sound_music_self_init()
	local soundMusicEditor = TRP3_EffectEditorSoundMusicSelf;

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

	-- Browse and play
	soundMusicEditor.browse:SetText(BROWSE);
	soundMusicEditor.browse:SetScript("OnClick", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.MUSICS, {parent = soundMusicEditor, point = "RIGHT", parentPoint = "LEFT"}, {function(music)
			soundMusicEditor.path:SetText(music);
		end});
	end);
	soundMusicEditor.play:SetText(loc("EFFECT_SOUND_PLAY"));
	soundMusicEditor.play:SetScript("OnClick", function(self)
		Utils.music.playMusic(soundMusicEditor.path:GetText());
	end);

	function soundMusicEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		soundMusicEditor.path:SetText(data[1]);
	end

	function soundMusicEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(soundMusicEditor.path:GetText()));
	end
end

local function sound_music_stop_init()
	registerEffectEditor("sound_music_stop", {
		title = loc("EFFECT_SOUND_MUSIC_STOP"),
		icon = "spell_holy_silence",
		description = loc("EFFECT_SOUND_MUSIC_STOP_TT"),
	});
end

local function sound_id_local_init()
	local soundLocalEditor = TRP3_EffectEditorSoundIDLocal;

	registerEffectEditor("sound_id_local", {
		title = loc("EFFECT_SOUND_ID_LOCAL"),
		icon = "inv_misc_ear_human_01",
		description = loc("EFFECT_SOUND_ID_LOCAL_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_SOUND_ID_LOCAL_PREVIEW"):format(
				"|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. tostring(args[1]) .. "|cffffff00", "|cff00ff00" .. tostring(args[3]) .. "|r"
			));
		end,
		getDefaultArgs = function()
			return {"SFX", 43569, 20};
		end,
		editor = soundLocalEditor,
	});

	-- Channel
	local outputs = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOUND_ID_SELF_CHANNEL"), loc("EFFECT_SOUND_ID_SELF_CHANNEL_SFX")), "SFX", loc("EFFECT_SOUND_ID_SELF_CHANNEL_SFX_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_SOUND_ID_SELF_CHANNEL"), loc("EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE")), "Ambience", loc("EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE_TT")},
	}
	TRP3_API.ui.listbox.setupListBox(soundLocalEditor.channel, outputs, nil, nil, 250, true);

	-- ID
	soundLocalEditor.id.title:SetText(loc("EFFECT_SOUND_ID_SELF_ID"));
	setTooltipForSameFrame(soundLocalEditor.id.help, "RIGHT", 0, 5, loc("EFFECT_SOUND_ID_SELF_ID"), loc("EFFECT_SOUND_ID_SELF_ID_TT"));
	soundLocalEditor.play:SetText(loc("EFFECT_SOUND_PLAY"));
	soundLocalEditor.play:SetScript("OnClick", function(self)
		Utils.music.playSoundID(tonumber(strtrim(soundLocalEditor.id:GetText())), soundLocalEditor.channel:GetSelectedValue() or "SFX");
	end);

	-- Distance
	soundLocalEditor.distance.title:SetText(loc("EFFECT_SOUND_LOCAL_DISTANCE"));
	setTooltipForSameFrame(soundLocalEditor.distance.help, "RIGHT", 0, 5, loc("EFFECT_SOUND_LOCAL_DISTANCE"), loc("EFFECT_SOUND_LOCAL_DISTANCE_TT"));

	function soundLocalEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		soundLocalEditor.channel:SetSelectedValue(data[1] or "SFX");
		soundLocalEditor.id:SetText(data[2]);
		soundLocalEditor.distance:SetText(data[3]);
	end

	function soundLocalEditor.save(scriptData)
		scriptData.args[1] = soundLocalEditor.channel:GetSelectedValue() or "SFX";
		scriptData.args[2] = tonumber(strtrim(soundLocalEditor.id:GetText()));
		scriptData.args[3] = tonumber(strtrim(soundLocalEditor.distance:GetText()));
	end
end

local function sound_music_local_init()
	local musicLocalEditor = TRP3_EffectEditorMusicLocal;

	registerEffectEditor("sound_music_local", {
		title = loc("EFFECT_SOUND_MUSIC_LOCAL"),
		icon = "inv_misc_drum_04",
		description = loc("EFFECT_SOUND_MUSIC_LOCAL_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_SOUND_MUSIC_LOCAL_PREVIEW"):format(
				"|cff00ff00" .. tostring(args[1]) .. "|cffffff00", "|cff00ff00" .. tostring(args[2]) .. "|cffffff00"
			));
		end,
		getDefaultArgs = function()
			return {"zonemusic\\brewfest\\BF_Goblins1", 20};
		end,
		editor = musicLocalEditor,
	});

	-- ID
	musicLocalEditor.path.title:SetText(loc("EFFECT_SOUND_MUSIC_SELF_PATH"));
	setTooltipForSameFrame(musicLocalEditor.path.help, "RIGHT", 0, 5, loc("EFFECT_SOUND_MUSIC_SELF_PATH"), loc("EFFECT_SOUND_MUSIC_SELF_PATH_TT"));

	musicLocalEditor.browse:SetText(BROWSE);
	musicLocalEditor.browse:SetScript("OnClick", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.MUSICS, {parent = musicLocalEditor, point = "RIGHT", parentPoint = "LEFT"}, {function(music)
			musicLocalEditor.path:SetText(music);
		end});
	end);
	musicLocalEditor.play:SetText(loc("EFFECT_SOUND_PLAY"));
	musicLocalEditor.play:SetScript("OnClick", function(self)
		Utils.music.playMusic(musicLocalEditor.path:GetText());
	end);

	-- Distance
	musicLocalEditor.distance.title:SetText(loc("EFFECT_SOUND_LOCAL_DISTANCE"));
	setTooltipForSameFrame(musicLocalEditor.distance.help, "RIGHT", 0, 5, loc("EFFECT_SOUND_LOCAL_DISTANCE"), loc("EFFECT_SOUND_LOCAL_DISTANCE_TT"));

	function musicLocalEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		musicLocalEditor.path:SetText(data[1]);
		musicLocalEditor.distance:SetText(data[2]);
	end

	function musicLocalEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(musicLocalEditor.path:GetText()));
		scriptData.args[2] = tonumber(strtrim(musicLocalEditor.distance:GetText()));
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Camera
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function cam_zoom_init()
	local editor = TRP3_EffectEditorCamera;

	registerEffectEditor("cam_zoom_in", {
		title = loc("EFFECT_CAT_CAMERA_ZOOM_IN"),
		icon = "inv_misc_spyglass_03",
		description = loc("EFFECT_CAT_CAMERA_ZOOM_IN_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc("EFFECT_CAT_CAMERA_ZOOM_IN") .. ":|cff00ff00 " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {5};
		end,
		editor = editor,
	});

	registerEffectEditor("cam_zoom_out", {
		title = loc("EFFECT_CAT_CAMERA_ZOOM_OUT"),
		icon = "inv_misc_spyglass_03",
		description = loc("EFFECT_CAT_CAMERA_ZOOM_OUT_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc("EFFECT_CAT_CAMERA_ZOOM_OUT") .. ":|cff00ff00 " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {5};
		end,
		editor = editor,
	});

	-- Distance
	editor.distance.title:SetText(loc("EFFECT_CAT_CAMERA_ZOOM_DISTANCE"));

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.distance:SetText(data[1] or 0);
	end

	function editor.save(scriptData)
		scriptData.args[1] = tonumber(strtrim(editor.distance:GetText())) or 0;
	end
end

local function cam_save_init()
	local editor = TRP3_EffectEditorCameraSlot;

	registerEffectEditor("cam_save", {
		title = loc("EFFECT_CAT_CAMERA_SAVE"),
		icon = "inv_misc_spyglass_02",
		description = loc("EFFECT_CAT_CAMERA_SAVE_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc("EFFECT_CAT_CAMERA_SAVE") .. ":|cff00ff00 " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {1};
		end,
		editor = editor,
	});

	registerEffectEditor("cam_load", {
		title = loc("EFFECT_CAT_CAMERA_LOAD"),
		icon = "inv_misc_spyglass_01",
		description = loc("EFFECT_CAT_CAMERA_LOAD_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc("EFFECT_CAT_CAMERA_LOAD") .. ":|cff00ff00 " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {1};
		end,
		editor = editor,
	});

	-- Slot
	editor.slot.title:SetText(loc("EFFECT_CAT_CAMERA_SLOT"));
	setTooltipForSameFrame(editor.slot.help, "RIGHT", 0, 5, loc("EFFECT_CAT_CAMERA_SLOT"), loc("EFFECT_CAT_CAMERA_SLOT_TT"));

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.slot:SetText(data[1] or 1);
	end

	function editor.save(scriptData)
		scriptData.args[1] = tonumber(strtrim(editor.slot:GetText())) or 1;
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
	companion_summon_mount_init();

	speech_env_init();
	speech_npc_init();
	speech_player_init();

	sound_id_self_init();
	sound_music_self_init();
	sound_music_stop_init();
	sound_id_local_init();
	sound_music_local_init();

	var_set_execenv_init();
	var_set_operand_init();
	signal_send_init();
	run_workflow_init();

	cam_zoom_init();
	cam_save_init();

end