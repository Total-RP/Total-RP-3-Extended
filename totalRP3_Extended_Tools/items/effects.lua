----------------------------------------------------------------------------------
-- Total RP 3
-- Scripts : Campaign/Quest Effects editors
--	---------------------------------------------------------------------------
--	Copyright 2016 Sylvain Cossement (telkostrasz@telkostrasz.be)
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
local registerEffectEditor = TRP3_API.extended.tools.registerEffectEditor;


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effects
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
		context = {TRP3_DB.types.ITEM},
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
		context = {TRP3_DB.types.ITEM},
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

local function document_close_init()
	local editor = TRP3_EffectEditorDocumentShow;

	registerEffectEditor("document_close", {
		title = loc("EFFECT_DOC_CLOSE"),
		icon = "trade_archaeology_silverscrollcase",
		description = loc("EFFECT_DOC_CLOSE_TT"),
	});

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
		context = {TRP3_DB.types.ITEM},
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
-- Operands
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local registerOperandEditor = TRP3_API.extended.tools.registerOperandEditor;
local itemSelectionEditor = TRP3_OperandEditorItemSelection;

local function initItemSelectionEditor()

	itemSelectionEditor.browse:SetText(BROWSE);
	itemSelectionEditor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = itemSelectionEditor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			itemSelectionEditor.id:SetText(id);
		end, TRP3_DB.types.ITEM});
	end);

	-- Text
	itemSelectionEditor.id.title:SetText(loc("ITEM_ID"));

	function itemSelectionEditor.load(args)
		itemSelectionEditor.id:SetText((args or EMPTY)[1] or "");
	end

	function itemSelectionEditor.save()
		return {strtrim(itemSelectionEditor.id:GetText()) or ""};
	end
end

local function inv_item_count_init()
	registerOperandEditor("inv_item_count", {
		title = loc("OP_OP_INV_COUNT"),
		description = loc("OP_OP_INV_COUNT_TT"),
		returnType = 0,
		getText = function(args)
			local id = (args or EMPTY)[1] or "";
			return loc("OP_OP_INV_COUNT_PREVIEW"):format(TRP3_API.inventory.getItemLink(getClass(id)) .. "|cffffff00");
		end,
		editor = itemSelectionEditor,
	});
end

local function inv_item_count_con_init()
	registerOperandEditor("inv_item_count_con", {
		title = loc("OP_OP_INV_COUNT_CON"),
		description = loc("OP_OP_INV_COUNT_CON_TT"),
		returnType = 0,
		getText = function(args)
			local id = (args or EMPTY)[1] or "";
			return loc("OP_OP_INV_COUNT_CON_PREVIEW"):format(TRP3_API.inventory.getItemLink(getClass(id)) .. "|cffffff00");
		end,
		editor = itemSelectionEditor,
	});
end


function TRP3_API.extended.tools.initItemEffects()

	-- Effects
	item_sheath_init();
	item_bag_durability_init();
	item_consume_init();
	item_add_init();
	item_remove_init();
	item_cooldown_init();

	document_show_init();
	document_close_init();

	-- Operands
	initItemSelectionEditor();

	inv_item_count_init();
	inv_item_count_con_init();
end