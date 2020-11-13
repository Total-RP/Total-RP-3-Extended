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

---@type TRP3_API
local TRP3_API = TRP3_API;
local Ellyb = TRP3_API.Ellyb;

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local tonumber, pairs, tostring, strtrim, assert = tonumber, pairs, tostring, strtrim, assert;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;

local LAST_EMOTE_ID = 522;

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



local function text_init()

	local editor = TRP3_EffectEditorText;

	-- Text
	setTooltipAll(editor.text.dummy, "RIGHT", 0, 5, loc.EFFECT_TEXT_TEXT, loc.EFFECT_TEXT_TEXT_TT);


	-- Type
	local outputs = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_TEXT_TYPE, loc.EFFECT_TEXT_TYPE_1), Utils.message.type.CHAT_FRAME},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_TEXT_TYPE, loc.EFFECT_TEXT_TYPE_2), Utils.message.type.ALERT_POPUP},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_TEXT_TYPE, loc.EFFECT_TEXT_TYPE_3), Utils.message.type.RAID_ALERT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_TEXT_TYPE, loc.EFFECT_TEXT_TYPE_4), Utils.message.type.ALERT_MESSAGE}
	}
	TRP3_API.ui.listbox.setupListBox(editor.type, outputs, nil, nil, 250, true);

	registerEffectEditor("text", {
		title = loc.EFFECT_TEXT,
		icon = "inv_inscription_scrollofwisdom_01",
		description = loc.EFFECT_TEXT_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" ..loc.EFFECT_TEXT_PREVIEW .. ":|r " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {loc.EFFECT_TEXT_TEXT_DEFAULT, 1};
		end,
		editor = editor,
	});

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.text.scroll.text:SetText(data[1] or "");
		editor.type:SetSelectedValue(data[2] or Utils.message.type.CHAT_FRAME);
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.text.scroll.text:GetText()));
		scriptData.args[2] = editor.type:GetSelectedValue() or Utils.message.type.CHAT_FRAME;
	end
end

local function macro_init()

	local editor = TRP3_EffectEditorMacro;
	---@type EditBox
	local textbox = editor.macroText.scroll.text

	registerEffectEditor("secure_macro",{
		title = loc.EFFECT_SECURE_MACRO_ACTION_NAME,
		icon = "inv_eng_gizmo3",
		description = loc.EFFECT_SECURE_MACRO_DESCRIPTION,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(Ellyb.ColorManager.YELLOW(loc.EFFECT_SECURE_MACRO_ACTION_NAME .. ": ") .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {""};
		end,
		editor = editor,
	})

	-- Text
	setTooltipAll(editor.macroText.dummy, "RIGHT", 0, 5, loc.EFFECT_SECURE_MACRO_HELP_TITLE, loc.EFFECT_SECURE_MACRO_HELP);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		textbox:SetText(data[1] or "");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(textbox:GetText()));
	end

	local function hookLinkInsert(functionName, hook)
		hooksecurefunc(functionName, function(self)
			if IsModifiedClick("CHATLINK")and editor.macroText.scroll.text:HasFocus() then
				textbox:Insert(hook(self))
			end
		end)
	end

	hookLinkInsert("SpellButton_OnModifiedClick", function(self)
		return GetSpellBookItemName(SpellBook_GetSpellBookSlot(self), SpellBookFrame.bookType);
	end)
	hookLinkInsert("SpellFlyoutButton_OnClick", function(self)
		return self.spellName
	end)
	hookLinkInsert("HandleModifiedItemClick", function(link)
		return GetItemInfo(link)
	end)

	Ellyb.GameEvents.registerCallback("ADDON_LOADED", function(name)
		if name == "Blizzard_TalentUI" then
			hookLinkInsert("HandleGeneralTalentFrameChatLink", function(self)
				return self.name:GetText();
			end)
		elseif name == "Blizzard_Collections" then
			hookLinkInsert("MountListDragButton_OnClick", function(self)
				return GetSpellInfo(self:GetParent().spellID)
			end)
			hookLinkInsert("MountListItem_OnClick", function(self)
				return GetSpellInfo(self:GetParent().spellID)
			end)
			hookLinkInsert("ToySpellButton_OnModifiedClick", function(self)
				return GetItemInfo(C_ToyBox.GetToyLink(self.itemID))
			end)
		end
	end)
end

local function script_init()

	local editor = TRP3_EffectEditorScript;

	-- Text
	setTooltipAll(editor.script.dummy, "RIGHT", 0, 5, loc.EFFECT_SCRIPT_SCRIPT, loc.EFFECT_SCRIPT_SCRIPT_TT);
	editor.script.scroll.text:SetFontObject(GameFontNormalLarge);

	-- Insert effect function
	editor.script.insertEffect:SetText(loc.EFFECT_SCRIPT_I_EFFECT);
	setTooltipAll(editor.script.insertEffect, "RIGHT", 0, 5, loc.EFFECT_SCRIPT_I_EFFECT, loc.EFFECT_SCRIPT_I_EFFECT_TT);
	editor.script.insertEffect:SetScript("OnClick", function()
		local index = editor.script.scroll.text:GetCursorPosition();
		local text = editor.script.scroll.text:GetText();
		local pre = text:sub(1, index);
		local post = text:sub(index + 1);
		text = strconcat(pre, "effect(\"text\", args, \"hello\", 2);", post);
		editor.script.scroll.text:SetText(text);
	end);

	registerEffectEditor("script", {
		title = loc.EFFECT_SCRIPT,
		icon = "inv_inscription_scroll_fortitude",
		description = loc.EFFECT_SCRIPT_TT,
		getDefaultArgs = function()
			return {"-- Your script here"};
		end,
		editor = editor,
	});

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.script.scroll.text:SetText(data[1] or "");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.script.scroll.text:GetText()));
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Companions
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function companion_dismiss_mount_init()
	registerEffectEditor("companion_dismiss_mount", {
		title = loc.EFFECT_DISMOUNT,
		icon = "ability_skyreach_dismount",
		description = loc.EFFECT_DISMOUNT_TT,
	});
end

local function companion_dismiss_critter_init()
	registerEffectEditor("companion_dismiss_critter", {
		title = loc.EFFECT_DISPET,
		icon = "inv_pet_pettrap01",
		description = loc.EFFECT_DISPET_TT,
	});
end

local function companion_random_critter_init()
	local editor = TRP3_EffectEditorSummonPet;

	registerEffectEditor("companion_random_critter", {
		title = loc.EFFECT_RANDSUM,
		icon = "ability_hunter_beastcall",
		description = loc.EFFECT_RANDSUM_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			if args and args[1] then
				scriptStepFrame.description:SetText(loc.EFFECT_RANDSUM_PREVIEW_FAV);
			else
				scriptStepFrame.description:SetText(loc.EFFECT_RANDSUM_PREVIEW_FULL);
			end
		end,
		getDefaultArgs = function()
			return {false};
		end,
		editor = editor
	});

	editor.favourite.Text:SetText(loc.EFFECT_RANDSUM_SUMMON_FAV);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.favourite:SetChecked(data[1] or false);
	end

	function editor.save(scriptData)
		scriptData.args[1] = editor.favourite:GetChecked();
	end
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
		companionSelected({creatureName or loc.EFFECT_SUMMOUNT_RANDOMMOUNT, icon or "Interface\\ICONS\\inv_misc_questionmark", description or "", loc.PR_CO_MOUNT, spellID, editor.id});
	end

	editor.save = function(scriptData)
		scriptData.args[1] = editor.id or 0;
	end

	editor.select:SetScript("OnClick", function(self, button)
		if button == "RightButton" then
			companionSelected({loc.EFFECT_SUMMOUNT_RANDOMMOUNT, "Interface\\ICONS\\inv_misc_questionmark", "", loc.PR_CO_MOUNT, 0, 0});
		else
			TRP3_API.popup.showPopup(TRP3_API.popup.COMPANIONS, {parent = self, point = "RIGHT", parentPoint = "LEFT"}, {companionSelected, nil, editor.type});
		end
	end);
	editor.type = TRP3_API.ui.misc.TYPE_MOUNT;

	editor.select:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	---@type Tooltip
	local tooltip = TRP3_API.Ellyb.Tooltips.getTooltip(editor.select)
	tooltip:SetTitle(loc.EFFECT_SUMMOUNT)
		:AddLine(Ellyb.Strings.clickInstruction(Ellyb.System.CLICKS.LEFT_CLICK, loc.EFFECT_SUMMOUNT_ACTION_TT))
		:AddLine(Ellyb.Strings.clickInstruction(Ellyb.System.CLICKS.RIGHT_CLICK, RESET))

	registerEffectEditor("companion_summon_mount", {
		title = loc.EFFECT_SUMMOUNT,
		icon = "ability_hunter_beastcall",
		description = loc.EFFECT_SUMMOUNT_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local creatureName = GetMountInfoByID(args[1] or 0);
			scriptStepFrame.description:SetText("|cffffff00" ..loc.EFFECT_SUMMOUNT .. ":|r " .. tostring(creatureName or loc.EFFECT_SUMMOUNT_RANDOMMOUNT));
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
	editor.var.title:SetText(loc.EFFECT_VAR)
	setTooltipForSameFrame(editor.var.help, "RIGHT", 0, 5, loc.EFFECT_VAR, "");

	-- Source
	local sources = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_WORKFLOW), "w", loc.EFFECT_SOURCE_WORKFLOW_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_OBJECT), "o", loc.EFFECT_SOURCE_OBJECT_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_CAMPAIGN), "c", loc.EFFECT_SOURCE_CAMPAIGN_TT}
	}
	TRP3_API.ui.listbox.setupListBox(editor.source, sources, nil, nil, 250, true);

	local function onOperandSelected(operandID, listbox)
		local operand = getOperandEditorInfo(operandID) or Globals.empty;
		_G[listbox:GetName() .. "Text"]:SetText(operand.title or UNKNOWN);

		-- Show the editor, if any
		if editor.currentEditor then
			editor.currentEditor:Hide();
		end
		listbox.config:SetText(loc.EFFECT_VAR_OPERAND_CONFIG_NO);
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
			listbox.config:SetText(loc.EFFECT_VAR_OPERAND_CONFIG);
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
		w = loc.EFFECT_SOURCE_WORKFLOW,
		o = loc.EFFECT_SOURCE_OBJECT,
		c = loc.EFFECT_SOURCE_CAMPAIGN
	}

	registerEffectEditor("var_operand", {
		title = loc.EFFECT_VAR_OPERAND,
		icon = "inv_inscription_minorglyph04",
		description = loc.EFFECT_VAR_OPERAND_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local varName = tostring(args[1]);
			local source = sourcesText[args[2]] or "?";
			local operandID = tostring(args[3]);
			local operand = getOperandEditorInfo(operandID) or Globals.empty;
			local text = operand.title or UNKNOWN;
			if operand.getText then
				text = operand.getText(args[4]);
			end
			scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_VAR_OPERAND .. ": |cff00ff00(" .. source .. ")|r " .. varName .. " = |cff00ff00" .. text);
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
	changeVarEditor.var.title:SetText(loc.EFFECT_VAR)
	setTooltipForSameFrame(changeVarEditor.var.help, "RIGHT", 0, 5, loc.EFFECT_VAR, "");

	-- Var value
	changeVarEditor.value.title:SetText(loc.EFFECT_OPERATION_VALUE);
	setTooltipForSameFrame(changeVarEditor.value.help, "RIGHT", 0, 5, loc.EFFECT_OPERATION_VALUE, "");

	-- Type
	local types = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_INIT), "[=]", loc.EFFECT_OPERATION_TYPE_INIT_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_SET), "=", loc.EFFECT_OPERATION_TYPE_SET_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_ADD), "+"},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_SUB), "-"},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_MULTIPLY), "x"},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_DIV), "/"}
	}
	TRP3_API.ui.listbox.setupListBox(changeVarEditor.type, types, nil, nil, 250, true);

	-- Source
	local sources = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_WORKFLOW), "w", loc.EFFECT_SOURCE_WORKFLOW_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_OBJECT), "o", loc.EFFECT_SOURCE_OBJECT_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_CAMPAIGN), "c", loc.EFFECT_SOURCE_CAMPAIGN_TT}
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
		w = loc.EFFECT_SOURCE_WORKFLOW,
		o = loc.EFFECT_SOURCE_OBJECT,
		c = loc.EFFECT_SOURCE_CAMPAIGN
	}

	registerEffectEditor("var_object", {
		title = loc.EFFECT_VAR_OBJECT_CHANGE,
		icon = "inv_inscription_minorglyph01",
		description = loc.EFFECT_VAR_OBJECT_CHANGE_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local source = sourcesText[args[1]] or "?";
			local varName = tostring(args[3]);
			scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_OPERATION .. ": |cff00ff00(" .. source .. ")|r " .. varName .. " |cff00ff00=|r " .. varName .. " |cff00ff00" .. tostring(args[2]) .. "|r " .. tostring(args[4]));
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
		title = loc.EFFECT_SIGNAL,
		icon = "Inv_gizmo_goblingtonkcontroller",
		description = loc.EFFECT_SIGNAL_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc.EFFECT_SIGNAL_PREVIEW:format(tostring(args[1]), tostring(args[2])));
		end,
		getDefaultArgs = function()
			return {"id", "value"};
		end,
		editor = editor
	});

	-- Var name
	editor.id.title:SetText(loc.EFFECT_SIGNAL_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.EFFECT_SIGNAL_ID, loc.EFFECT_SIGNAL_ID_TT);

	-- Var value
	editor.value.title:SetText(loc.EFFECT_SIGNAL_VALUE);
	setTooltipForSameFrame(editor.value.help, "RIGHT", 0, 5, loc.EFFECT_SIGNAL_VALUE, loc.EFFECT_SIGNAL_VALUE_TT);

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
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_OBJECT), "o", loc.EFFECT_W_OBJECT_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_CAMPAIGN), "c", loc.EFFECT_W_CAMPAIGN_TT}
	}
	TRP3_API.ui.listbox.setupListBox(editor.source, sources, nil, nil, 250, true);

	-- ID
	editor.id.title:SetText(loc.EFFECT_RUN_WORKFLOW_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.EFFECT_RUN_WORKFLOW_ID, loc.EFFECT_RUN_WORKFLOW_ID_TT);


	local sourcesText = {
		o = loc.EFFECT_SOURCE_OBJECT,
		c = loc.EFFECT_SOURCE_CAMPAIGN
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
		title = loc.EFFECT_RUN_WORKFLOW,
		icon = "inv_gizmo_electrifiedether",
		description = loc.EFFECT_RUN_WORKFLOW_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local source = sourcesText[args[1]] or "?";
			local id = tostring(args[2]);
			scriptStepFrame.description:SetText(loc.EFFECT_RUN_WORKFLOW_PREVIEW:format("|cff00ff00".. id .."|r", "|cff00ff00".. source .."|r"));
		end,
		getDefaultArgs = function()
			return {"o", "id"};
		end,
		editor = editor
	});
end

local function var_prompt_init()
	local editor = TRP3_EffectEditorPrompt;

	-- Text
	editor.text.title:SetText(loc.EFFECT_PROMPT_TEXT);
	setTooltipForSameFrame(editor.text.help, "RIGHT", 0, 5, loc.EFFECT_PROMPT_TEXT, loc.EFFECT_PROMPT_TEXT_TT);

	-- Variable
	editor.var.title:SetText(loc.EFFECT_PROMPT_VAR);
	setTooltipForSameFrame(editor.var.help, "RIGHT", 0, 5, loc.EFFECT_PROMPT_VAR, loc.EFFECT_PROMPT_VAR_TT);

	-- Source var
	local sourcesVar = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE_V, loc.EFFECT_SOURCE_OBJECT), "o", loc.EFFECT_SOURCE_OBJECT_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE_V, loc.EFFECT_SOURCE_CAMPAIGN), "c", loc.EFFECT_SOURCE_CAMPAIGN_TT}
	}
	TRP3_API.ui.listbox.setupListBox(editor.source, sourcesVar, nil, nil, 250, true);

	-- Workflow callback
	editor.workflow.title:SetText(loc.EFFECT_PROMPT_CALLBACK);
	setTooltipForSameFrame(editor.workflow.help, "RIGHT", 0, 5, loc.EFFECT_PROMPT_CALLBACK, loc.EFFECT_PROMPT_CALLBACK_TT);

	-- Source workflow
	local workflowSource = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE_W, loc.EFFECT_SOURCE_OBJECT), "o", loc.EFFECT_W_OBJECT_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE_W, loc.EFFECT_SOURCE_CAMPAIGN), "c", loc.EFFECT_W_CAMPAIGN_TT}
	}
	TRP3_API.ui.listbox.setupListBox(editor.w_source, workflowSource, nil, nil, 250, true);

	registerEffectEditor("var_prompt", {
		title = loc.EFFECT_PROMPT,
		icon = "inv_gizmo_hardenedadamantitetube",
		description = loc.EFFECT_PROMPT_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc.EFFECT_PROMPT_PREVIEW:format(args[2] or ""));
		end,
		getDefaultArgs = function()
			return {"Please enter some input", "input", "o", "", "o"};
		end,
		editor = editor
	});

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.text:SetText(data[1] or "");
		editor.var:SetText(data[2] or "var");
		editor.source:SetSelectedValue(data[3] or "o");
		editor.workflow:SetText(data[4] or "");
		editor.w_source:SetSelectedValue(data[5] or "o");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.text:GetText())) or "";
		scriptData.args[2] = stEtN(strtrim(editor.var:GetText())) or "var";
		scriptData.args[3] = editor.source:GetSelectedValue() or "o";
		scriptData.args[4] = stEtN(strtrim(editor.workflow:GetText())) or "";
		scriptData.args[5] = editor.w_source:GetSelectedValue() or "o";
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Speechs
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local speechEnvEditor = TRP3_EffectEditorSpeechEnv;
local speechNPCEditor = TRP3_EffectEditorSpeechNPC;

local function speech_env_init()
	registerEffectEditor("speech_env", {
		title = loc.EFFECT_SPEECH_NAR,
		icon = "inv_misc_book_07",
		description = loc.EFFECT_SPEECH_NAR_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {loc.EFFECT_SPEECH_NAR_DEFAULT};
		end,
		editor = speechEnvEditor,
	});

	-- Narrative text
	speechEnvEditor.text.title:SetText(loc.EFFECT_TEXT_TEXT);
	setTooltipForSameFrame(speechEnvEditor.text.help, "RIGHT", 0, 5, loc.EFFECT_TEXT_TEXT, loc.EFFECT_SPEECH_NAR_TEXT_TT);

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
		title = loc.EFFECT_SPEECH_NPC,
		icon = "ability_warrior_rallyingcry",
		description = loc.EFFECT_SPEECH_NPC_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(TRP3_API.ui.misc.getSpeechPrefixText(args[2], args[1], args[3]));
		end,
		getDefaultArgs = function()
			return {"Tish", TRP3_API.ui.misc.SPEECH_PREFIX.SAYS, loc.EFFECT_SPEECH_NPC_DEFAULT};
		end,
		editor = speechNPCEditor,
	});

	-- Name
	speechNPCEditor.name.title:SetText(loc.EFFECT_SPEECH_NPC_NAME);
	setTooltipForSameFrame(speechNPCEditor.name.help, "RIGHT", 0, 5, loc.EFFECT_SPEECH_NPC_NAME, loc.EFFECT_SPEECH_NPC_NAME_TT);

	-- Type
	local types = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SPEECH_TYPE, loc.NPC_SAYS), TRP3_API.ui.misc.SPEECH_PREFIX.SAYS},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SPEECH_TYPE, loc.NPC_YELLS), TRP3_API.ui.misc.SPEECH_PREFIX.YELLS},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SPEECH_TYPE, loc.NPC_WHISPERS), TRP3_API.ui.misc.SPEECH_PREFIX.WHISPERS},
	}
	TRP3_API.ui.listbox.setupListBox(speechNPCEditor.type, types, nil, nil, 250, true);

	-- Narrative text
	speechNPCEditor.text.title:SetText(loc.EFFECT_TEXT_TEXT);
	setTooltipForSameFrame(speechNPCEditor.text.help, "RIGHT", 0, 5, loc.EFFECT_TEXT_TEXT, loc.EFFECT_SPEECH_NAR_TEXT_TT);

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
		title = loc.EFFECT_SPEECH_PLAYER,
		icon = "ability_warrior_warcry",
		description = loc.EFFECT_SPEECH_PLAYER_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(TRP3_API.ui.misc.getSpeech(args[2], args[1]));
		end,
		getDefaultArgs = function()
			return {TRP3_API.ui.misc.SPEECH_PREFIX.SAYS, loc.EFFECT_SPEECH_PLAYER_DEFAULT};
		end,
		editor = editor,
	});

	-- Type
	local types = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SPEECH_TYPE, loc.NPC_SAYS), TRP3_API.ui.misc.SPEECH_PREFIX.SAYS},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SPEECH_TYPE, loc.NPC_YELLS), TRP3_API.ui.misc.SPEECH_PREFIX.YELLS},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SPEECH_TYPE, loc.NPC_EMOTES), TRP3_API.ui.misc.SPEECH_PREFIX.EMOTES},
	}
	TRP3_API.ui.listbox.setupListBox(editor.type, types, nil, nil, 250, true);

	-- Narrative text
	editor.text.title:SetText(loc.EFFECT_TEXT_TEXT);
	setTooltipForSameFrame(editor.text.help, "RIGHT", 0, 5, loc.EFFECT_TEXT_TEXT, loc.EFFECT_SPEECH_NAR_TEXT_TT);

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

local function splitTableIntoSmallerAlphabetizedTables(input, maxSize)
	local output = {};

	-- Retrieving the first character of the first emote in the list
	local characterTableSorted = {};
	local currentCharacter;
	for _, emote in ipairs(input) do
		local characterList = {}
		for character in string.gmatch(emote[1], "([%z\1-\127\194-\244][\128-\191]*)") do
			table.insert(characterList, Utils.str.convertSpecialChars(character));
		end

		if not currentCharacter or currentCharacter ~= characterList[2] then
			currentCharacter = characterList[2];
			table.insert(characterTableSorted, { characterList[2], { emote }});
		else
			table.insert(characterTableSorted[#characterTableSorted][2],  emote);
		end
	end

	local currentCount = 0;
	local currentTable;
	local firstCharacter;
	local previousCharacter;
	for _, characterTable in ipairs(characterTableSorted) do
		local character = characterTable[1];
		local emotes = characterTable[2];
		local characterSize = #emotes;
		if (currentCount + characterSize) > maxSize then
			-- Adding the previous table
			if currentTable then
				if firstCharacter ~= previousCharacter then
					table.insert(output, { loc.EFFECT_DO_EMOTE_OTHER .. " " .. string.upper(firstCharacter) .. "-" .. string.upper(previousCharacter), currentTable });
				else
					table.insert(output, { loc.EFFECT_DO_EMOTE_OTHER .. " " .. string.upper(firstCharacter), currentTable });
				end
			end

			if characterSize > maxSize then
				-- Split into smaller tables
				firstCharacter = nil;
				local i = 0;
				while (maxSize * i) < characterSize do
					i = i + 1;
					currentTable = {};
					local offset = (i - 1) * maxSize;
					for j = 1, min(maxSize, characterSize - offset) do
						table.insert(currentTable, emotes[offset + j]);
					end
					table.insert(output, { loc.EFFECT_DO_EMOTE_OTHER .. " " .. string.upper(character) .. i, currentTable });
				end
				currentTable = nil;
				currentCount = 0;
			else
				currentTable = {};
				for i = 1, characterSize do
					table.insert(currentTable, emotes[i]);
				end
				firstCharacter = character;
				currentCount = characterSize;
			end
			previousCharacter = character;
		else
			if not currentTable then
				currentTable = {};
			end
			for i = 1, characterSize do
				table.insert(currentTable, emotes[i]);
			end
			currentCount = currentCount + characterSize;

			if not firstCharacter then
				firstCharacter = character;
			end
			previousCharacter = character;
		end
	end

	-- Adding the previous table
	if currentTable then
		if firstCharacter ~= previousCharacter then
			table.insert(output, { loc.EFFECT_DO_EMOTE_OTHER .. " " .. string.upper(firstCharacter) .. "-" .. string.upper(previousCharacter), currentTable });
		else
			table.insert(output, { loc.EFFECT_DO_EMOTE_OTHER .. " " .. string.upper(firstCharacter), currentTable });
		end
	end

	return output;
end

local function do_emote_init()
	local editor = TRP3_EffectEditorDoEmote;

	-- Build list of emotes
	local spokenEmotes = tInvert(TextEmoteSpeechList);
	-- Those two are added dynamically
	spokenEmotes["FORTHEALLIANCE"] = true;
	spokenEmotes["FORTHEHORDE"] = true;
	local animatedEmotes = tInvert(EmoteList);
	local otherEmotes = {}
	for i = 1, LAST_EMOTE_ID do
		local emoteToken = _G["EMOTE" .. i .. "_TOKEN"]
		if emoteToken then
			if spokenEmotes[emoteToken] then
				spokenEmotes[emoteToken] = i;
			elseif animatedEmotes[emoteToken] then
				animatedEmotes[emoteToken] = i
			else
				otherEmotes[emoteToken] = i;
			end
		end
	end

	local function getEmoteNameFromToken(emoteToken)
		local emoteIndex = spokenEmotes[emoteToken] or animatedEmotes[emoteToken] or otherEmotes[emoteToken] or UNKNOWN
		return _G["EMOTE"..emoteIndex.."_CMD1"]
	end

	local function getEmotesList(emotesList)
		local list = {}
		for token, _ in pairs(emotesList) do
			table.insert(list, {getEmoteNameFromToken(token), token})
		end
		table.sort(list, function(a, b)
			return strcmputf8i(Utils.str.convertSpecialChars(a[1]), Utils.str.convertSpecialChars(b[1])) < 0;
		end)
		return list
	end

	local emotesList = {
		{loc.EFFECT_DO_EMOTE_SPOKEN, getEmotesList(spokenEmotes)},
		{loc.EFFECT_DO_EMOTE_ANIMATED, getEmotesList(animatedEmotes)}
	}

	local otherEmotesList = getEmotesList(otherEmotes)

	local splitTables = splitTableIntoSmallerAlphabetizedTables(otherEmotesList, 30);
	for i = 1, #splitTables do
		table.insert(emotesList, splitTables[i]);
	end

	TRP3_API.ui.listbox.setupListBox(editor.emoteList, emotesList, function(value, list) _G[list:GetName().."Text"]:SetText(tostring(getEmoteNameFromToken(value))); end, nil, 250, true);

	registerEffectEditor("do_emote", {
		title = loc.EFFECT_DO_EMOTE,
		icon = "Achievement_Faction_Celestials",
		description = loc.EFFECT_DO_EMOTE_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(Ellyb.ColorManager.YELLOW(loc.EFFECT_DO_EMOTE .. ": ") .. tostring(getEmoteNameFromToken(args[1])));
		end,
		getDefaultArgs = function()
			return {};
		end,
		editor = editor,
	});

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		if data[1] then
			editor.emoteList:SetSelectedValue(data[1]);
			_G[editor.emoteList:GetName().."Text"]:SetText(tostring(getEmoteNameFromToken(data[1])));
		end
	end

	function editor.save(scriptData)
		scriptData.args[1] = editor.emoteList:GetSelectedValue();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Sounds
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function sound_id_self_init()
	local SoundIDSelfEditor = TRP3_EffectEditorSoundIDSelf;

	registerEffectEditor("sound_id_self", {
		title = loc.EFFECT_SOUND_ID_SELF,
		icon = "inv_misc_ear_human_02",
		description = loc.EFFECT_SOUND_ID_SELF_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_SOUND_ID_SELF_PREVIEW:format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. tostring(args[1]) .. "|r"));
		end,
		getDefaultArgs = function()
			return {"SFX", 43569};
		end,
		editor = SoundIDSelfEditor,
	});

	-- Channel
	local outputs = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOUND_ID_SELF_CHANNEL, loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX), "SFX", loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOUND_ID_SELF_CHANNEL, loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE), "Ambience", loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE_TT},
	}
	TRP3_API.ui.listbox.setupListBox(SoundIDSelfEditor.channel, outputs, nil, nil, 250, true);

	-- ID
	SoundIDSelfEditor.id.title:SetText(loc.EFFECT_SOUND_ID_SELF_ID);
	setTooltipForSameFrame(SoundIDSelfEditor.id.help, "RIGHT", 0, 5, loc.EFFECT_SOUND_ID_SELF_ID, loc.EFFECT_SOUND_ID_SELF_ID_TT);

	SoundIDSelfEditor.play:SetText(loc.EFFECT_SOUND_PLAY);
	SoundIDSelfEditor.play:SetScript("OnClick", function(self)
		local soundID = tonumber(strtrim(SoundIDSelfEditor.id:GetText()));
		if soundID then
			Utils.music.playSoundID(soundID, SoundIDSelfEditor.channel:GetSelectedValue() or "SFX");
		end
	end);

	function SoundIDSelfEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		SoundIDSelfEditor.channel:SetSelectedValue(data[1] or "SFX");
		SoundIDSelfEditor.id:SetText(data[2] or "");
	end

	function SoundIDSelfEditor.save(scriptData)
		scriptData.args[1] = SoundIDSelfEditor.channel:GetSelectedValue() or "SFX";
		scriptData.args[2] = tonumber(strtrim(SoundIDSelfEditor.id:GetText()));
	end
end

local function sound_id_stop_init()
	local SoundIDStopEditor = TRP3_EffectEditorSoundIDStop;

	registerEffectEditor("sound_id_stop", {
		title = loc.EFFECT_SOUND_ID_STOP,
		icon = "inv_misc_ear_nightelf_02",
		description = loc.EFFECT_SOUND_ID_STOP_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			if args[2] then
				scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_SOUND_ID_STOP_PREVIEW:format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. tostring(args[1]) .. "|r"));
			else
				scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_SOUND_ID_STOP_ALL_PREVIEW:format("|cff00ff00" .. tostring(args[1]) .. "|r"));
			end
		end,
		getDefaultArgs = function()
			return {"SFX", nil};
		end,
		editor = SoundIDStopEditor,
	});

	-- Channel
	local outputs = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOUND_ID_SELF_CHANNEL, loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX), "SFX"},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOUND_ID_SELF_CHANNEL, loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE), "Ambience"},
	}
	TRP3_API.ui.listbox.setupListBox(SoundIDStopEditor.channel, outputs, nil, nil, 250, true);

	-- ID
	SoundIDStopEditor.id.title:SetText(loc.EFFECT_SOUND_ID_SELF_ID);
	setTooltipForSameFrame(SoundIDStopEditor.id.help, "RIGHT", 0, 5, loc.EFFECT_SOUND_ID_SELF_ID, loc.EFFECT_SOUND_ID_STOP_ID_TT);

	SoundIDStopEditor.play:SetText(loc.EFFECT_SOUND_PLAY);
	SoundIDStopEditor.play:SetScript("OnClick", function(self)
		local soundID = tonumber(strtrim(SoundIDStopEditor.id:GetText()));
		if soundID then
			Utils.music.playSoundID(soundID, SoundIDStopEditor.channel:GetSelectedValue() or "SFX");
		end
	end);

	function SoundIDStopEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		SoundIDStopEditor.channel:SetSelectedValue(data[1] or "SFX");
		SoundIDStopEditor.id:SetText(data[2] or "");
	end

	function SoundIDStopEditor.save(scriptData)
		scriptData.args[1] = SoundIDStopEditor.channel:GetSelectedValue() or "SFX";
		scriptData.args[2] = tonumber(strtrim(SoundIDStopEditor.id:GetText()));
	end
end

local function sound_music_self_init()
	local soundMusicEditor = TRP3_EffectEditorSoundMusicSelf;

	registerEffectEditor("sound_music_self", {
		title = loc.EFFECT_SOUND_MUSIC_SELF,
		icon = "inv_misc_drum_07",
		description = loc.EFFECT_SOUND_MUSIC_SELF_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_SOUND_MUSIC_SELF_PREVIEW:format("|cff00ff00" .. (Utils.music.getTitle(tonumber(args[1])) or tostring(args[1]))));
		end,
		getDefaultArgs = function()
			return {"228575"};
		end,
		editor = soundMusicEditor,
	});

	-- ID
	soundMusicEditor.path.title:SetText(loc.EFFECT_SOUND_MUSIC_SELF_PATH);
	setTooltipForSameFrame(soundMusicEditor.path.help, "RIGHT", 0, 5, loc.EFFECT_SOUND_MUSIC_SELF_PATH, loc.EFFECT_SOUND_MUSIC_SELF_PATH_TT);

	-- Browse and play
	soundMusicEditor.browse:SetText(BROWSE);
	soundMusicEditor.browse:SetScript("OnClick", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.MUSICS, {parent = soundMusicEditor, point = "RIGHT", parentPoint = "LEFT"}, {function(music)
			soundMusicEditor.path:SetText(music);
		end});
	end);
	soundMusicEditor.play:SetText(loc.EFFECT_SOUND_PLAY);
	soundMusicEditor.play:SetScript("OnClick", function(self)
		Utils.music.playMusic(soundMusicEditor.path:GetText());
	end);

	function soundMusicEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		soundMusicEditor.path:SetText(data[1] or "");
	end

	function soundMusicEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(soundMusicEditor.path:GetText()));
	end
end

local function sound_music_stop_init()
	registerEffectEditor("sound_music_stop", {
		title = loc.EFFECT_SOUND_MUSIC_STOP,
		icon = "spell_holy_silence",
		description = loc.EFFECT_SOUND_MUSIC_STOP_TT,
	});
end

local function sound_id_local_init()
	local soundLocalEditor = TRP3_EffectEditorSoundIDLocal;

	registerEffectEditor("sound_id_local", {
		title = loc.EFFECT_SOUND_ID_LOCAL,
		icon = "inv_misc_ear_human_01",
		description = loc.EFFECT_SOUND_ID_LOCAL_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_SOUND_ID_LOCAL_PREVIEW:format(
			"|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. tostring(args[1]) .. "|cffffff00", "|cff00ff00" .. tostring(args[3]) .. "|cffffff00"
			));
		end,
		getDefaultArgs = function()
			return {"SFX", 43569, 20};
		end,
		editor = soundLocalEditor,
	});

	-- Channel
	local outputs = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOUND_ID_SELF_CHANNEL, loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX), "SFX", loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOUND_ID_SELF_CHANNEL, loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE), "Ambience", loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE_TT},
	}
	TRP3_API.ui.listbox.setupListBox(soundLocalEditor.channel, outputs, nil, nil, 250, true);

	-- ID
	soundLocalEditor.id.title:SetText(loc.EFFECT_SOUND_ID_SELF_ID);
	setTooltipForSameFrame(soundLocalEditor.id.help, "RIGHT", 0, 5, loc.EFFECT_SOUND_ID_SELF_ID, loc.EFFECT_SOUND_ID_SELF_ID_TT);
	soundLocalEditor.play:SetText(loc.EFFECT_SOUND_PLAY);
	soundLocalEditor.play:SetScript("OnClick", function(self)
		local soundID = tonumber(strtrim(soundLocalEditor.id:GetText()));
		if soundID then
			Utils.music.playSoundID(soundID, soundLocalEditor.channel:GetSelectedValue() or "SFX");
		end
	end);

	-- Distance
	soundLocalEditor.distance.title:SetText(loc.EFFECT_SOUND_LOCAL_DISTANCE);
	setTooltipForSameFrame(soundLocalEditor.distance.help, "RIGHT", 0, 5, loc.EFFECT_SOUND_LOCAL_DISTANCE, loc.EFFECT_SOUND_LOCAL_DISTANCE_TT);

	function soundLocalEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		soundLocalEditor.channel:SetSelectedValue(data[1] or "SFX");
		soundLocalEditor.id:SetText(data[2] or "");
		soundLocalEditor.distance:SetText(data[3] or "");
	end

	function soundLocalEditor.save(scriptData)
		scriptData.args[1] = soundLocalEditor.channel:GetSelectedValue() or "SFX";
		scriptData.args[2] = tonumber(strtrim(soundLocalEditor.id:GetText()));
		scriptData.args[3] = tonumber(strtrim(soundLocalEditor.distance:GetText()));
	end
end

local function sound_id_local_stop_init()
	local SoundIDLocalStopEditor = TRP3_EffectEditorSoundIDLocalStop;

	registerEffectEditor("sound_id_local_stop", {
		title = loc.EFFECT_SOUND_ID_LOCAL_STOP,
		icon = "spell_shadow_coneofsilence",
		description = loc.EFFECT_SOUND_ID_LOCAL_STOP_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			if args[2] then
				scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_SOUND_ID_STOP_PREVIEW:format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. tostring(args[1]) .. "|r"));
			else
				scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_SOUND_ID_STOP_ALL_PREVIEW:format("|cff00ff00" .. tostring(args[1]) .. "|r"));
			end
		end,
		getDefaultArgs = function()
			return {"SFX", nil};
		end,
		editor = SoundIDLocalStopEditor,
	});

	-- Channel
	local outputs = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOUND_ID_SELF_CHANNEL, loc.EFFECT_SOUND_ID_SELF_CHANNEL_SFX), "SFX"},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOUND_ID_SELF_CHANNEL, loc.EFFECT_SOUND_ID_SELF_CHANNEL_AMBIANCE), "Ambience"},
	}
	TRP3_API.ui.listbox.setupListBox(SoundIDLocalStopEditor.channel, outputs, nil, nil, 250, true);

	-- ID
	SoundIDLocalStopEditor.id.title:SetText(loc.EFFECT_SOUND_ID_SELF_ID);
	setTooltipForSameFrame(SoundIDLocalStopEditor.id.help, "RIGHT", 0, 5, loc.EFFECT_SOUND_ID_SELF_ID, loc.EFFECT_SOUND_ID_STOP_ID_TT);

	SoundIDLocalStopEditor.play:SetText(loc.EFFECT_SOUND_PLAY);
	SoundIDLocalStopEditor.play:SetScript("OnClick", function(self)
		local soundID = tonumber(strtrim(SoundIDLocalStopEditor.id:GetText()));
		if soundID then
			Utils.music.playSoundID(soundID, SoundIDLocalStopEditor.channel:GetSelectedValue() or "SFX");
		end
	end);

	function SoundIDLocalStopEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		SoundIDLocalStopEditor.channel:SetSelectedValue(data[1] or "SFX");
		SoundIDLocalStopEditor.id:SetText(data[2] or "");
	end

	function SoundIDLocalStopEditor.save(scriptData)
		scriptData.args[1] = SoundIDLocalStopEditor.channel:GetSelectedValue() or "SFX";
		scriptData.args[2] = tonumber(strtrim(SoundIDLocalStopEditor.id:GetText()));
		if scriptData.args[2] == 0 then
			scriptData.args[2] = nil;
		end
	end
end

local function sound_music_local_init()
	local musicLocalEditor = TRP3_EffectEditorMusicLocal;

	registerEffectEditor("sound_music_local", {
		title = loc.EFFECT_SOUND_MUSIC_LOCAL,
		icon = "inv_misc_drum_04",
		description = loc.EFFECT_SOUND_MUSIC_LOCAL_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_SOUND_MUSIC_LOCAL_PREVIEW:format(
			"|cff00ff00" .. (Utils.music.getTitle(tonumber(args[1])) or tostring(args[1])) .. "|cffffff00", "|cff00ff00" .. tostring(args[2]) .. "|cffffff00"
			));
		end,
		getDefaultArgs = function()
			return {"228575", 20};
		end,
		editor = musicLocalEditor,
	});

	-- ID
	musicLocalEditor.path.title:SetText(loc.EFFECT_SOUND_MUSIC_SELF_PATH);
	setTooltipForSameFrame(musicLocalEditor.path.help, "RIGHT", 0, 5, loc.EFFECT_SOUND_MUSIC_SELF_PATH, loc.EFFECT_SOUND_MUSIC_SELF_PATH_TT);

	musicLocalEditor.browse:SetText(BROWSE);
	musicLocalEditor.browse:SetScript("OnClick", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.MUSICS, {parent = musicLocalEditor, point = "RIGHT", parentPoint = "LEFT"}, {function(music)
			musicLocalEditor.path:SetText(music);
		end});
	end);
	musicLocalEditor.play:SetText(loc.EFFECT_SOUND_PLAY);
	musicLocalEditor.play:SetScript("OnClick", function(self)
		Utils.music.playMusic(musicLocalEditor.path:GetText());
	end);

	-- Distance
	musicLocalEditor.distance.title:SetText(loc.EFFECT_SOUND_LOCAL_DISTANCE);
	setTooltipForSameFrame(musicLocalEditor.distance.help, "RIGHT", 0, 5, loc.EFFECT_SOUND_LOCAL_DISTANCE, loc.EFFECT_SOUND_LOCAL_DISTANCE_TT);

	function musicLocalEditor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		musicLocalEditor.path:SetText(data[1] or "");
		musicLocalEditor.distance:SetText(data[2] or "");
	end

	function musicLocalEditor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(musicLocalEditor.path:GetText()));
		scriptData.args[2] = tonumber(strtrim(musicLocalEditor.distance:GetText()));
	end
end

local function sound_music_local_stop_init()
	registerEffectEditor("sound_music_local_stop", {
		title = loc.EFFECT_SOUND_MUSIC_LOCAL_STOP,
		icon = "ability_priest_silence",
		description = loc.EFFECT_SOUND_MUSIC_LOCAL_STOP_TT,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Camera
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function cam_zoom_init()
	local editor = TRP3_EffectEditorCamera;

	registerEffectEditor("cam_zoom_in", {
		title = loc.EFFECT_CAT_CAMERA_ZOOM_IN,
		icon = "inv_misc_spyglass_03",
		description = loc.EFFECT_CAT_CAMERA_ZOOM_IN_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc.EFFECT_CAT_CAMERA_ZOOM_IN .. ":|cff00ff00 " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {"5"};
		end,
		editor = editor,
	});

	registerEffectEditor("cam_zoom_out", {
		title = loc.EFFECT_CAT_CAMERA_ZOOM_OUT,
		icon = "inv_misc_spyglass_03",
		description = loc.EFFECT_CAT_CAMERA_ZOOM_OUT_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc.EFFECT_CAT_CAMERA_ZOOM_OUT .. ":|cff00ff00 " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {"5"};
		end,
		editor = editor,
	});

	-- Distance
	editor.distance.title:SetText(loc.EFFECT_CAT_CAMERA_ZOOM_DISTANCE);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.distance:SetText(data[1] or "5");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.distance:GetText())) or "5";
	end
end

local function cam_save_init()
	local editor = TRP3_EffectEditorCameraSlot;

	registerEffectEditor("cam_save", {
		title = loc.EFFECT_CAT_CAMERA_SAVE,
		icon = "inv_misc_spyglass_02",
		description = loc.EFFECT_CAT_CAMERA_SAVE_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc.EFFECT_CAT_CAMERA_SAVE .. ":|cff00ff00 " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {1};
		end,
		editor = editor,
	});

	registerEffectEditor("cam_load", {
		title = loc.EFFECT_CAT_CAMERA_LOAD,
		icon = "inv_misc_spyglass_01",
		description = loc.EFFECT_CAT_CAMERA_LOAD_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc.EFFECT_CAT_CAMERA_LOAD .. ":|cff00ff00 " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {1};
		end,
		editor = editor,
	});

	-- Slot
	editor.slot.title:SetText(loc.EFFECT_CAT_CAMERA_SLOT);
	setTooltipForSameFrame(editor.slot.help, "RIGHT", 0, 5, loc.EFFECT_CAT_CAMERA_SLOT, loc.EFFECT_CAT_CAMERA_SLOT_TT);

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
	macro_init();
	script_init();

	companion_dismiss_mount_init();
	companion_dismiss_critter_init();
	companion_random_critter_init();
	companion_summon_mount_init();

	speech_env_init();
	speech_npc_init();
	speech_player_init();
	do_emote_init();

	sound_id_self_init();
	sound_id_stop_init();
	sound_music_self_init();
	sound_music_stop_init();
	sound_id_local_init();
	sound_id_local_stop_init();
	sound_music_local_init();
	sound_music_local_stop_init();

	var_set_execenv_init();
	var_set_operand_init();
	signal_send_init();
	run_workflow_init();
	var_prompt_init();

	cam_zoom_init();
	cam_save_init();

end
