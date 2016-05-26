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

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Inventory
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function item_sheath_init()
	registerEffectEditor("item_sheath", {
		title = loc("EFFECT_SHEATH"),
		icon = "garrison_blueweapon",
		description = loc("EFFECT_SHEATH_TT"),
	});
end

local function item_bag_durability_init()
	local editor = TRP3_EffectEditorItemBagDurability;

	registerEffectEditor("item_bag_durability", {
		title = loc("EFFECT_ITEM_BAG_DURABILITY"),
		icon = "ability_repair",
		description = loc("EFFECT_ITEM_BAG_DURABILITY_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			if args[1] == "HEAL" then
				scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_ITEM_BAG_DURABILITY_PREVIEW_1"):format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00") .. "|r");
			else
				scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_ITEM_BAG_DURABILITY_PREVIEW_2"):format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00") .. "|r");
			end
		end,
		getDefaultArgs = function()
			return {"HEAL", 10};
		end,
		editor = editor,
	});

	-- Method
	local outputs = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_ITEM_BAG_DURABILITY_METHOD"), loc("EFFECT_ITEM_BAG_DURABILITY_METHOD_HEAL")), "HEAL", loc("EFFECT_ITEM_BAG_DURABILITY_METHOD_HEAL_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_ITEM_BAG_DURABILITY_METHOD"), loc("EFFECT_ITEM_BAG_DURABILITY_METHOD_DAMAGE")), "DAMAGE", loc("EFFECT_ITEM_BAG_DURABILITY_METHOD_DAMAGE_TT")},
	}
	TRP3_API.ui.listbox.setupListBox(editor.method, outputs, nil, nil, 250, true);

	-- Amount
	editor.amount.title:SetText(loc("EFFECT_ITEM_BAG_DURABILITY_VALUE"));
	setTooltipForSameFrame(editor.amount.help, "RIGHT", 0, 5, loc("EFFECT_ITEM_BAG_DURABILITY_VALUE"), loc("EFFECT_ITEM_BAG_DURABILITY_VALUE_TT"));

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.method:SetSelectedValue(data[1] or "HEAL");
		editor.amount:SetText(data[2]);
	end

	function editor.save(scriptData)
		scriptData.args[1] = editor.method:GetSelectedValue() or "HEAL";
		scriptData.args[2] = tonumber(strtrim(editor.amount:GetText()));
	end
end

local function item_consume_init()
	registerEffectEditor("item_consume", {
		title = loc("EFFECT_ITEM_CONSUME"),
		icon = "inv_misc_potionseta",
		description = loc("EFFECT_ITEM_CONSUME_TT"),
	});
end

local function document_show_init()
	local editor = TRP3_EffectEditorDocumentShow;

	registerEffectEditor("document_show", {
		title = loc("EFFECT_DOC_DISPLAY"),
		icon = "inv_icon_mission_complete_order",
		description = loc("EFFECT_DOC_DISPLAY_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			local class = getClass(tostring(args[1]));
			local link;
			if class ~= TRP3_DB.missing then
				link = TRP3_API.inventory.getItemLink(class);
			end
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_DOC_ID") .. ":|r " .. (link or tostring(args[1])));
		end,
		getDefaultArgs = function()
			return {""};
		end,
		editor = editor;
	});

	editor.browse:SetText(BROWSE);
	editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor, point = "RIGHT", parentPoint = "LEFT"}, {function(music)
			editor.id:SetText(music);
		end, TRP3_DB.types.DOCUMENT});
	end);

	-- ID
	editor.id.title:SetText(loc("EFFECT_DOC_ID"));
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc("EFFECT_DOC_ID"), loc("EFFECT_DOC_ID_TT"));

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id:SetText((data[1] or ""));
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
	end
end

local function item_add_init()
	local editor = TRP3_EffectEditorItemAdd;

	registerEffectEditor("item_add", {
		title = loc("EFFECT_ITEM_ADD"),
		icon = "garrison_weaponupgrade",
		description = loc("EFFECT_ITEM_ADD_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			local class = getClass(tostring(args[1]));
			local link;
			if class ~= TRP3_DB.missing then
				link = TRP3_API.inventory.getItemLink(class);
			end
			scriptStepFrame.description:SetText(loc("EFFECT_ITEM_ADD_PREVIEW"):format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. (link or tostring(args[1])) .. "|cffffff00"));
		end,
		getDefaultArgs = function()
			return {"", 1, false, "parent"};
		end,
		editor = editor;
	});

	editor.browse:SetText(BROWSE);
	editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			editor.id:SetText(id);
		end, TRP3_DB.types.ITEM});
	end);

	-- ID
	editor.id.title:SetText(loc("EFFECT_ITEM_ADD_ID"));
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc("EFFECT_ITEM_ADD_ID"), loc("EFFECT_ITEM_ADD_ID_TT"));

	-- Count
	editor.count.title:SetText(loc("EFFECT_ITEM_ADD_QT"));
	setTooltipForSameFrame(editor.count.help, "RIGHT", 0, 5, loc("EFFECT_ITEM_ADD_QT"), loc("EFFECT_ITEM_ADD_QT_TT"));

	-- Crafted
	editor.crafted.Text:SetText(loc("EFFECT_ITEM_ADD_CRAFTED"));
	setTooltipForSameFrame(editor.crafted, "RIGHT", 0, 5, loc("EFFECT_ITEM_ADD_CRAFTED"), loc("EFFECT_ITEM_ADD_CRAFTED_TT"));

	-- Source
	local sources = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_ITEM_TO"), loc("EFFECT_ITEM_TO_1")), "inventory", loc("EFFECT_ITEM_TO_1_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_ITEM_TO"), loc("EFFECT_ITEM_TO_2")), "parent", loc("EFFECT_ITEM_TO_2_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_ITEM_TO"), loc("EFFECT_ITEM_TO_3")), "self", loc("EFFECT_ITEM_TO_3_TT")},
	}
	TRP3_API.ui.listbox.setupListBox(editor.source, sources, nil, nil, 250, true);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id:SetText(data[1] or "");
		editor.count:SetText(data[2] or "1");
		editor.crafted:SetChecked(data[3] or false);
		editor.source:SetSelectedValue(data[4] or "parent");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
		scriptData.args[2] = tonumber(strtrim(editor.count:GetText())) or 1;
		scriptData.args[3] = editor.crafted:GetChecked();
		scriptData.args[4] = editor.source:GetSelectedValue() or "parent";
	end
end

local function item_remove_init()
	local editor = TRP3_EffectEditorItemRemove;

	registerEffectEditor("item_remove", {
		title = loc("EFFECT_ITEM_REMOVE"),
		icon = "spell_sandexplosion",
		description = loc("EFFECT_ITEM_REMOVE_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			local class = getClass(tostring(args[1]));
			local link;
			if class ~= TRP3_DB.missing then
				link = TRP3_API.inventory.getItemLink(class);
			end
			scriptStepFrame.description:SetText(loc("EFFECT_ITEM_REMOVE_PREVIEW"):format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. (link or tostring(args[1])) .. "|cffffff00"));
		end,
		getDefaultArgs = function()
			return {"", 1, "inventory"};
		end,
		editor = editor;
	});

	editor.browse:SetText(BROWSE);
	editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			editor.id:SetText(id);
		end, TRP3_DB.types.ITEM});
	end);

	-- ID
	editor.id.title:SetText(loc("EFFECT_ITEM_ADD_ID"));
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc("EFFECT_ITEM_ADD_ID"), loc("EFFECT_ITEM_REMOVE_ID_TT"));

	-- Count
	editor.count.title:SetText(loc("EFFECT_ITEM_ADD_QT"));
	setTooltipForSameFrame(editor.count.help, "RIGHT", 0, 5, loc("EFFECT_ITEM_ADD_QT"), loc("EFFECT_ITEM_REMOVE_QT_TT"));

	-- Source
	local sources = {
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_ITEM_SOURCE"), loc("EFFECT_ITEM_SOURCE_1")), "inventory", loc("EFFECT_ITEM_SOURCE_1_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_ITEM_SOURCE"), loc("EFFECT_ITEM_SOURCE_2")), "parent", loc("EFFECT_ITEM_SOURCE_2_TT")},
		{TRP3_API.formats.dropDownElements:format(loc("EFFECT_ITEM_SOURCE"), loc("EFFECT_ITEM_SOURCE_3")), "self", loc("EFFECT_ITEM_SOURCE_3_TT")},
	}
	TRP3_API.ui.listbox.setupListBox(editor.source, sources, nil, nil, 250, true);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id:SetText(data[1] or "");
		editor.count:SetText(data[2] or "1");
		editor.source:SetSelectedValue(data[3] or "inventory");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
		scriptData.args[2] = tonumber(strtrim(editor.count:GetText())) or 1;
		scriptData.args[3] = editor.source:GetSelectedValue() or "inventory";
	end
end

local function item_cooldown_init()
	local editor = TRP3_EffectEditorItemCooldown;

	registerEffectEditor("item_cooldown", {
		title = loc("EFFECT_ITEM_COOLDOWN"),
		icon = "ability_mage_timewarp",
		description = loc("EFFECT_ITEM_COOLDOWN_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc("EFFECT_ITEM_COOLDOWN_PREVIEW"):format("|cff00ff00" .. tostring(args[1]) .. "|cffffff00"));
		end,
		getDefaultArgs = function()
			return {1};
		end,
		editor = editor;
	});

	-- Time
	editor.time.title:SetText(loc("EFFECT_COOLDOWN_DURATION"));
	setTooltipForSameFrame(editor.time.help, "RIGHT", 0, 5, loc("EFFECT_COOLDOWN_DURATION"), loc("EFFECT_COOLDOWN_DURATION_TT"));

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.time:SetText(data[1] or "1");
	end

	function editor.save(scriptData)
		scriptData.args[1] = tonumber(strtrim(editor.time:GetText())) or 0;
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Workflow expertise
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

	-- Init only
	varSetEditor.initOnly.Text:SetText(loc("EFFECT_VAR_INIT_ONLY"));
	setTooltipForSameFrame(varSetEditor.initOnly, "RIGHT", 0, 5, loc("EFFECT_VAR_INIT_ONLY"), loc("EFFECT_VAR_INIT_ONLY_TT"));

	function varSetEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		varSetEditor.var:SetText(data[1] or "");
		varSetEditor.value:SetText(data[2] or "");
		varSetEditor.initOnly:SetChecked(data[3] or false);
	end

	function varSetEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(varSetEditor.var:GetText()));
		scriptData.args[2] = stEtN(strtrim(varSetEditor.value:GetText()));
		scriptData.args[3] = varSetEditor.initOnly:GetChecked();
	end

	registerEffectEditor("var_set_object", {
		title = loc("EFFECT_VAR_OBJECT"),
		icon = "inv_inscription_minorglyph01",
		description = loc("EFFECT_VAR_OBJECT_TT"),
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc("EFFECT_VAR") .. ":|r " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {"varName", loc("EFFECT_VAR_VALUE")};
		end,
		editor = varSetEditor
	});

end

local function signal_send_init()

	local editor = TRP3_EffectEditorSignalSend;

	registerEffectEditor("signal_send", {
		title = "Send signal (WIP)", -- TODO: locals
		icon = "Inv_gizmo_goblingtonkcontroller",
		description = "Send a signal with an ID and a value to the player target.", -- TODO: locals
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. "Send signal ID" .. ":|r " .. tostring(args[1]) .. "|cffffff00" .. " with value" .. ":|r " .. tostring(args[2]));
		end,
		getDefaultArgs = function()
			return {"id", "value"};
		end,
		editor = editor
	});

	-- Var name
	editor.id.title:SetText("Signal ID"); -- TODO: locals
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, "Signal ID", ""); -- TODO: locals

	-- Var value
	editor.value.title:SetText("Signal value"); -- TODO: locals
	setTooltipForSameFrame(editor.value.help, "RIGHT", 0, 5, "Signal value", ""); -- TODO: locals

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
	sound_music_stop_init();
	sound_id_local_init();
	sound_music_local_init();

	item_sheath_init();
	item_bag_durability_init();
	item_consume_init();
	document_show_init();
	item_add_init();
	item_remove_init();
	item_cooldown_init();

	var_set_execenv_init();
	signal_send_init();

	debugs_init();
end