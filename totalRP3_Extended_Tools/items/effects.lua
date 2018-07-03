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

local Globals, Events, Utils, EMPTY = TRP3_API.globals, TRP3_API.events, TRP3_API.utils, TRP3_API.globals.empty;
local tonumber, pairs, tostring, strtrim, assert = tonumber, pairs, tostring, strtrim, assert;
local tinsert = tinsert;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local registerEffectEditor = TRP3_API.extended.tools.registerEffectEditor;

local inventorySources, inventorySourcesLocals;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effects
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function item_sheath_init()
	registerEffectEditor("item_sheath", {
		title = loc.EFFECT_SHEATH,
		icon = "garrison_blueweapon",
		description = loc.EFFECT_SHEATH_TT,
	});
end

local function item_bag_durability_init()
	local editor = TRP3_EffectEditorItemBagDurability;

	registerEffectEditor("item_bag_durability", {
		title = loc.EFFECT_ITEM_BAG_DURABILITY,
		icon = "ability_repair",
		description = loc.EFFECT_ITEM_BAG_DURABILITY_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			if args[1] == "HEAL" then
				scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_ITEM_BAG_DURABILITY_PREVIEW_1:format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00") .. "|r");
			else
				scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_ITEM_BAG_DURABILITY_PREVIEW_2:format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00") .. "|r");
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
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_BAG_DURABILITY_METHOD, loc.EFFECT_ITEM_BAG_DURABILITY_METHOD_HEAL), "HEAL", loc.EFFECT_ITEM_BAG_DURABILITY_METHOD_HEAL_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_BAG_DURABILITY_METHOD, loc.EFFECT_ITEM_BAG_DURABILITY_METHOD_DAMAGE), "DAMAGE", loc.EFFECT_ITEM_BAG_DURABILITY_METHOD_DAMAGE_TT},
	}
	TRP3_API.ui.listbox.setupListBox(editor.method, outputs, nil, nil, 250, true);

	-- Amount
	editor.amount.title:SetText(loc.EFFECT_ITEM_BAG_DURABILITY_VALUE);
	setTooltipForSameFrame(editor.amount.help, "RIGHT", 0, 5, loc.EFFECT_ITEM_BAG_DURABILITY_VALUE, loc.EFFECT_ITEM_BAG_DURABILITY_VALUE_TT);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.method:SetSelectedValue(data[1] or "HEAL");
		editor.amount:SetText(data[2]);
	end

	function editor.save(scriptData)
		scriptData.args[1] = editor.method:GetSelectedValue() or "HEAL";
		scriptData.args[2] = strtrim(editor.amount:GetText());
	end
end

local function item_consume_init()
	registerEffectEditor("item_consume", {
		title = loc.EFFECT_ITEM_CONSUME,
		icon = "inv_misc_potionseta",
		description = loc.EFFECT_ITEM_CONSUME_TT,
		context = {TRP3_DB.types.ITEM},
	});
end

local function document_show_init()
	local editor = TRP3_EffectEditorDocumentShow;

	registerEffectEditor("document_show", {
		title = loc.EFFECT_DOC_DISPLAY,
		icon = "inv_icon_mission_complete_order",
		description = loc.EFFECT_DOC_DISPLAY_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local class = getClass(tostring(args[1]));
			local link;
			if class ~= TRP3_DB.missing then
				link = TRP3_API.inventory.getItemLink(class, args[1], true);
			end
			scriptStepFrame.description:SetText("|cffffff00" .. loc.EFFECT_DOC_ID .. ":|r " .. (link or tostring(args[1])));
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
	editor.id.title:SetText(loc.EFFECT_DOC_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.EFFECT_DOC_ID, loc.EFFECT_DOC_ID_TT);

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
		title = loc.EFFECT_DOC_CLOSE,
		icon = "trade_archaeology_silverscrollcase",
		description = loc.EFFECT_DOC_CLOSE_TT,
	});

end

local function item_add_init()
	local editor = TRP3_EffectEditorItemAdd;

	registerEffectEditor("item_add", {
		title = loc.EFFECT_ITEM_ADD,
		icon = "garrison_weaponupgrade",
		description = loc.EFFECT_ITEM_ADD_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local class = getClass(tostring(args[1]));
			local link;
			if class ~= TRP3_DB.missing then
				link = TRP3_API.inventory.getItemLink(class);
			end
			scriptStepFrame.description:SetText(loc.EFFECT_ITEM_ADD_PREVIEW:format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. (link or tostring(args[1])) .. "|cffffff00"));
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
	editor.id.title:SetText(loc.EFFECT_ITEM_ADD_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.EFFECT_ITEM_ADD_ID, loc.EFFECT_ITEM_ADD_ID_TT);

	-- Count
	editor.count.title:SetText(loc.EFFECT_ITEM_ADD_QT);
	setTooltipForSameFrame(editor.count.help, "RIGHT", 0, 5, loc.EFFECT_ITEM_ADD_QT, loc.EFFECT_ITEM_ADD_QT_TT);

	-- Crafted
	editor.crafted.Text:SetText(loc.EFFECT_ITEM_ADD_CRAFTED);
	setTooltipForSameFrame(editor.crafted, "RIGHT", 0, 5, loc.EFFECT_ITEM_ADD_CRAFTED, loc.EFFECT_ITEM_ADD_CRAFTED_TT);

	inventorySources = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_ADD, loc.EFFECT_ITEM_SOURCE_1), "inventory", loc.EFFECT_ITEM_SOURCE_1_ADD_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_ADD, loc.EFFECT_ITEM_SOURCE_2), "parent", loc.EFFECT_ITEM_SOURCE_2_ADD_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_ADD, loc.EFFECT_ITEM_SOURCE_3), "self", loc.EFFECT_ITEM_SOURCE_3_ADD_TT},
	}

	-- Source
	TRP3_API.ui.listbox.setupListBox(editor.source, inventorySources, nil, nil, 250, true);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id:SetText(data[1] or "");
		editor.count:SetText(data[2] or "1");
		editor.crafted:SetChecked(data[3] or false);
		editor.source:SetSelectedValue(data[4] or "parent");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
		scriptData.args[2] = strtrim(editor.count:GetText()) or 1;
		scriptData.args[3] = editor.crafted:GetChecked();
		scriptData.args[4] = editor.source:GetSelectedValue() or "parent";
	end
end

local function item_remove_init()
	local editor = TRP3_EffectEditorItemRemove;

	registerEffectEditor("item_remove", {
		title = loc.EFFECT_ITEM_REMOVE,
		icon = "spell_sandexplosion",
		description = loc.EFFECT_ITEM_REMOVE_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local class = getClass(tostring(args[1]));
			local link;
			if class ~= TRP3_DB.missing then
				link = TRP3_API.inventory.getItemLink(class);
			end
			scriptStepFrame.description:SetText(loc.EFFECT_ITEM_REMOVE_PREVIEW:format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. (link or tostring(args[1])) .. "|cffffff00"));
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
	editor.id.title:SetText(loc.EFFECT_ITEM_ADD_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.EFFECT_ITEM_ADD_ID, loc.EFFECT_ITEM_REMOVE_ID_TT);

	-- Count
	editor.count.title:SetText(loc.EFFECT_ITEM_ADD_QT);
	setTooltipForSameFrame(editor.count.help, "RIGHT", 0, 5, loc.EFFECT_ITEM_ADD_QT, loc.EFFECT_ITEM_REMOVE_QT_TT);

	inventorySources = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_SEARCH, loc.EFFECT_ITEM_SOURCE_1), "inventory", loc.EFFECT_ITEM_SOURCE_1_SEARCH_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_SEARCH, loc.EFFECT_ITEM_SOURCE_2), "parent", loc.EFFECT_ITEM_SOURCE_2_SEARCH_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_SEARCH, loc.EFFECT_ITEM_SOURCE_3), "self", loc.EFFECT_ITEM_SOURCE_3_SEARCH_TT},
	}

	-- Source
	TRP3_API.ui.listbox.setupListBox(editor.source, inventorySources, nil, nil, 250, true);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id:SetText(data[1] or "");
		editor.count:SetText(data[2] or "1");
		editor.source:SetSelectedValue(data[3] or "inventory");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
		scriptData.args[2] = strtrim(editor.count:GetText()) or 1;
		scriptData.args[3] = editor.source:GetSelectedValue() or "inventory";
	end
end

local function item_cooldown_init()
	local editor = TRP3_EffectEditorItemCooldown;

	registerEffectEditor("item_cooldown", {
		title = loc.EFFECT_ITEM_COOLDOWN,
		icon = "ability_mage_timewarp",
		description = loc.EFFECT_ITEM_COOLDOWN_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc.EFFECT_ITEM_COOLDOWN_PREVIEW:format("|cff00ff00" .. tostring(args[1]) .. "|cffffff00"));
		end,
		getDefaultArgs = function()
			return {1};
		end,
		editor = editor,
		context = {TRP3_DB.types.ITEM},
	});

	-- Time
	editor.time.title:SetText(loc.EFFECT_COOLDOWN_DURATION);
	setTooltipForSameFrame(editor.time.help, "RIGHT", 0, 5, loc.EFFECT_COOLDOWN_DURATION, loc.EFFECT_COOLDOWN_DURATION_TT);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.time:SetText(data[1] or "1");
	end

	function editor.save(scriptData)
		scriptData.args[1] = strtrim(editor.time:GetText()) or 0;
	end
end

local function item_use_init()
	local editor = TRP3_OperandEditorItemUse;

	registerEffectEditor("item_use", {
		title = loc.EFFECT_ITEM_USE,
		icon = "ability_paladin_handoflight",
		description = loc.EFFECT_ITEM_USE_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText(loc.EFFECT_ITEM_USE_PREVIEW:format("|cff00ff00" .. tostring(args[1]) .. "|cffffff00"));
		end,
		getDefaultArgs = function()
			return {"1"};
		end,
		editor = editor,
		context = {TRP3_DB.types.ITEM},
	});

	-- Time
	editor.id.title:SetText(loc.EFFECT_USE_SLOT);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.EFFECT_USE_SLOT, loc.EFFECT_USE_SLOT_TT);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id:SetText(data[1] or "1");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText())) or "1";
	end
end

local function item_roll_dice_init()
	local editor = TRP3_EffectEditorRollDice;

	-- Roll
	editor.roll.title:SetText(loc.EFFECT_ITEM_DICE_ROLL);
	setTooltipForSameFrame(editor.roll.help, "RIGHT", 0, 5, loc.EFFECT_ITEM_DICE_ROLL, loc.EFFECT_ITEM_DICE_ROLL_TT);

	editor.var.title:SetText(loc.EFFECT_ITEM_DICE_ROLL_VAR);
	setTooltipForSameFrame(editor.var.help, "RIGHT", 0, 5, loc.EFFECT_ITEM_DICE_ROLL_VAR, loc.EFFECT_ITEM_DICE_ROLL_VAR_TT);

	-- Source
	local sources = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_WORKFLOW), "w", loc.EFFECT_SOURCE_WORKFLOW_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_OBJECT), "o", loc.EFFECT_SOURCE_OBJECT_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_CAMPAIGN), "c", loc.EFFECT_SOURCE_CAMPAIGN_TT}
	}
	TRP3_API.ui.listbox.setupListBox(editor.source, sources, nil, nil, 250, true);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.roll:SetText(data[1] or "1d100");
		editor.var:SetText(data[2] or "");
		editor.source:SetSelectedValue(data[3] or "w");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.roll:GetText())) or "1d100";
		scriptData.args[2] = stEtN(strtrim(editor.var:GetText())) or "";
		scriptData.args[3] = editor.source:GetSelectedValue() or "w";
	end

	local sourcesText = {
		w = loc.EFFECT_SOURCE_WORKFLOW,
		o = loc.EFFECT_SOURCE_OBJECT,
		c = loc.EFFECT_SOURCE_CAMPAIGN
	}

	registerEffectEditor("item_roll_dice", {
		title = loc.EFFECT_ITEM_DICE,
		icon = "inv_misc_dice_02",
		description = loc.EFFECT_ITEM_DICE_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			if args[2] ~= "" then
				local source = sourcesText[args[3]] or "?";
				scriptStepFrame.description:SetText(loc.EFFECT_ITEM_DICE_PREVIEW_STORED:format(TRP3_API.Ellyb.ColorManager.GREEN(tostring(args[1])), TRP3_API.Ellyb.ColorManager.GREEN("(" .. source .. ") ") .. tostring(args[2])));
			else
				scriptStepFrame.description:SetText(loc.EFFECT_ITEM_DICE_PREVIEW:format(TRP3_API.Ellyb.ColorManager.GREEN(tostring(args[1]))));
			end
		end,
		getDefaultArgs = function()
			return {"1d100", "", "w"};
		end,
		editor = editor,
	});
end

local function inv_loot_init()
	local editor = TRP3_EffectEditorLoot;

	registerEffectEditor("item_loot", {
		title = loc.EFFECT_ITEM_LOOT,
		icon = "inv_box_02",
		description = loc.EFFECT_ITEM_LOOT_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local isDrop = args[1][4] or false;
			local itemCount = #(args[1][3] or EMPTY);
			if isDrop then
				scriptStepFrame.description:SetText(loc.EFFECT_ITEM_LOOT_PREVIEW_1:format(itemCount));
			else
				scriptStepFrame.description:SetText(loc.EFFECT_ITEM_LOOT_PREVIEW_2:format(itemCount));
			end
		end,
		getDefaultArgs = function()
			return {{loc.LOOT, "inv_misc_bag_07", {}, false}};
		end,
		editor = editor;
	});

	-- Name
	editor.name.title:SetText(loc.EFFECT_ITEM_LOOT_NAME);
	setTooltipForSameFrame(editor.name.help, "RIGHT", 0, 5, loc.EFFECT_ITEM_LOOT_NAME, loc.EFFECT_ITEM_LOOT_NAME_TT);
	editor.bag.help:SetText(loc.EFFECT_ITEM_LOOT_SLOT)

	-- Crafted
	editor.drop.Text:SetText(loc.EFFECT_ITEM_LOOT_DROP);
	setTooltipForSameFrame(editor.drop, "RIGHT", 0, 5, loc.EFFECT_ITEM_LOOT_DROP, loc.EFFECT_ITEM_LOOT_DROP_TT);


	-- Icon
	setTooltipForSameFrame(editor.icon, "RIGHT", 0, 5, loc.EDITOR_ICON);
	local iconHandler = function(icon)
		editor.icon.Icon:SetTexture("Interface\\ICONS\\" .. icon);
		editor.bag.Icon:SetTexture("Interface\\ICONS\\" .. icon);
		editor.icon.selectedIcon = icon;
	end
	editor.icon:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.ICONS,
			{parent = editor.icon, point = "LEFT", parentPoint = "RIGHT", x = 15},
			{iconHandler});
	end);

	-- Loot
	editor.bag.close:Disable();
	editor.bag.LockIcon:Hide();
	editor.bag.DurabilityText:Hide();
	editor.bag.WeightText:Hide();
	editor.bag.Bottom:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Bank");
	editor.bag.Middle:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Bank");
	editor.bag.Top:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components-Bank");
	local onSlotClicked = function(slot, button)
		if button == "LeftButton" then
			if editor.bag.editor:IsVisible() and editor.bag.editor.current == slot then
				editor.bag.editor:Hide();
			else
				TRP3_API.ui.frame.configureHoverFrame(editor.bag.editor, slot, "RIGHT", -10, 0);
				editor.bag.editor:SetFrameLevel(slot:GetFrameLevel() + 20);
				editor.bag.editor.current = slot;
				local data = slot.info or EMPTY;
				editor.bag.editor.id:SetText(data.classID or "");
				editor.bag.editor.count:SetText(data.count or "1");
			end
		else
			slot.info = nil;
			editor.bag.editor:Hide();
		end
	end;
	TRP3_API.inventory.initContainerSlots(editor.bag, 2, 4, true, onSlotClicked);
	editor.bag.editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor.bag.editor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			editor.bag.editor.id:SetText(id);
		end, TRP3_DB.types.ITEM});
	end);
	editor.bag.editor.save:SetScript("OnClick", function()
		local classID = stEtN(strtrim(editor.bag.editor.id:GetText()));
		if classID and TRP3_API.extended.classExists(classID) then
			editor.bag.editor.current.info = {
				classID = classID,
				count = tonumber(editor.bag.editor.count:GetText()) or 1,
			};
			editor.bag.editor.current.class = getClass(classID);
			editor.bag.editor:Hide();
		else
			Utils.message.displayMessage("Unknown item", 4);
		end
	end);

	TRP3_API.ui.frame.createRefreshOnFrame(editor.bag, 0.25, function(self)
		local text = stEtN(strtrim(editor.name:GetText())) or loc.LOOT;
		editor.bag.Title:SetText(text);
	end);

	function editor.load(scriptData)
		local data = (scriptData.args or Globals.empty)[1] or Globals.empty;
		editor.name:SetText(data[1] or loc.LOOT);
		editor.drop:SetChecked(data[4] or false);
		iconHandler(data[2] or "inv_misc_bag_07");
		editor.bag.editor:Hide();
		for index, slot in pairs(editor.bag.slots) do
			slot.info = nil;
			slot.class = nil;
			if data[3] and data[3][index] then
				slot.info = {
					classID = data[3][index].classID,
					count = tonumber(data[3][index].count or 1) or 1,
				};
				slot.class = getClass(data[3][index].classID);
			end
		end
	end

	function editor.save(scriptData)
		scriptData.args[1] = {
			stEtN(strtrim(editor.name:GetText())),
			editor.icon.selectedIcon,
			{},
			editor.drop:GetChecked()
		};
		local saveData = scriptData.args[1][3];
		for _, slot in pairs(editor.bag.slots) do
			if slot.info then
				tinsert(saveData, {
					classID = slot.info.classID,
					count = slot.info.count,
				});
			end
		end
	end
end

local function run_item_workflow_init()
	local editor = TRP3_EffectEditorItemWorkflow;

	-- Source
	local sources = {
--		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_PARENT), "p", loc.EFFECT_SOURCE_PARENT_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_SLOT), "ch", loc.EFFECT_SOURCE_SLOT_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_SLOT_B), "si", loc.EFFECT_SOURCE_SLOT_B_TT}
	}
	TRP3_API.ui.listbox.setupListBox(editor.source, sources, nil, nil, 250, true);

	-- ID
	editor.id.title:SetText(loc.EFFECT_RUN_WORKFLOW_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.EFFECT_RUN_WORKFLOW_ID, loc.EFFECT_RUN_WORKFLOW_ID_TT);

	-- Slot
	editor.slot.title:SetText(loc.EFFECT_RUN_WORKFLOW_SLOT);
	setTooltipForSameFrame(editor.slot.help, "RIGHT", 0, 5, loc.EFFECT_RUN_WORKFLOW_SLOT, loc.EFFECT_RUN_WORKFLOW_SLOT_TT);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.source:SetSelectedValue(data[1] or "c");
		editor.id:SetText(data[2] or "id");
		editor.slot:SetText(data[3] or "1");
	end

	function editor.save(scriptData)
		scriptData.args[1] = editor.source:GetSelectedValue() or "c";
		scriptData.args[2] = stEtN(strtrim(editor.id:GetText())) or "";
		scriptData.args[3] = stEtN(strtrim(editor.slot:GetText())) or "1";
	end

	registerEffectEditor("run_item_workflow", {
		title = loc.EFFECT_ITEM_WORKFLOW,
		icon = "inv_gizmo_electrifiedether",
		description = loc.EFFECT_ITEM_WORKFLOW_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local source = args[1];
			local id = tostring(args[2]);
			local slot = tostring(args[3]);
			if source == "ch" then
				scriptStepFrame.description:SetText(loc.EFFECT_ITEM_WORKFLOW_PREVIEW_C:format("|cff00ff00".. id .."|r", "|cff00ff00".. slot .."|r"));
			else
				scriptStepFrame.description:SetText(loc.EFFECT_ITEM_WORKFLOW_PREVIEW_S:format("|cff00ff00".. id .."|r", "|cff00ff00".. slot .."|r"));
			end
		end,
		getDefaultArgs = function()
			return {"ch", "id", "1"};
		end,
		editor = editor,
		context = {TRP3_DB.types.ITEM},
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Operands
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local registerOperandEditor = TRP3_API.extended.tools.registerOperandEditor;

local function initItemSelectionEditor(editor)

	editor.browse:SetText(BROWSE);
	editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			editor.id:SetText(id);
		end, TRP3_DB.types.ITEM});
	end);

	-- Text
	editor.id.title:SetText(loc.ITEM_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.ITEM_ID, loc.EFFECT_ITEM_SOURCE_ID);

end

local function inv_item_count_init()
	local editor = TRP3_OperandEditorItemCount;
	initItemSelectionEditor(editor);

	registerOperandEditor("inv_item_count", {
		title = loc.OP_OP_INV_COUNT,
		description = loc.OP_OP_INV_COUNT_TT,
		returnType = 0,
		getText = function(args)
			local data = args or EMPTY;
			local id = data[1] or "";
			if id:len() == 0 then
				id = "|cff00ff00" .. loc.OP_OP_INV_COUNT_ANY;
			else
				id = TRP3_API.inventory.getItemLink(getClass(id));
			end
			local source = data[2] or "inventory";
			return loc.OP_OP_INV_COUNT_PREVIEW:format(id .. "|cffffff00", inventorySourcesLocals[source] or "?");
		end,
		editor = editor,
		getDefaultArgs = function()
			return {"", "inventory"};
		end,
	});

	inventorySources = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_SEARCH, loc.EFFECT_ITEM_SOURCE_1), "inventory", loc.EFFECT_ITEM_SOURCE_1_SEARCH_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_SEARCH, loc.EFFECT_ITEM_SOURCE_2), "parent", loc.EFFECT_ITEM_SOURCE_2_SEARCH_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_SEARCH, loc.EFFECT_ITEM_SOURCE_3), "self", loc.EFFECT_ITEM_SOURCE_3_SEARCH_TT},
	}

	-- Source
	TRP3_API.ui.listbox.setupListBox(editor.source, inventorySources, nil, nil, 185, true);

	function editor.load(args)
		local data = args or EMPTY;
		editor.id:SetText(data[1] or "");
		editor.source:SetSelectedValue(data[2] or "inventory");
	end

	function editor.save()
		return {strtrim(editor.id:GetText()) or "", editor.source:GetSelectedValue() or "inventory"};
	end
end

local function inv_item_weight_init()
	local editor = TRP3_OperandEditorItemWeight;

	registerOperandEditor("inv_item_weight", {
		title = loc.OP_OP_INV_WEIGHT,
		description = loc.OP_OP_INV_WEIGHT_TT,
		returnType = 0,
		getText = function(args)
			local data = args or EMPTY;
			local source = data[1] or "inventory";
			return loc.OP_OP_INV_WEIGHT_PREVIEW:format(inventorySourcesLocals[source] or "?");
		end,
		editor = editor,
		getDefaultArgs = function()
			return {"inventory"};
		end,
	});

	inventorySources = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_SEARCH, loc.EFFECT_ITEM_SOURCE_1), "inventory", loc.EFFECT_ITEM_SOURCE_1_SEARCH_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_SEARCH, loc.EFFECT_ITEM_SOURCE_2), "parent", loc.EFFECT_ITEM_SOURCE_2_SEARCH_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_ITEM_SOURCE_SEARCH, loc.EFFECT_ITEM_SOURCE_3), "self", loc.EFFECT_ITEM_SOURCE_3_SEARCH_TT},
	}

	-- Source
	TRP3_API.ui.listbox.setupListBox(editor.source, inventorySources, nil, nil, 185, true);

	function editor.load(args)
		local data = args or EMPTY;
		editor.source:SetSelectedValue(data[1] or "inventory");
	end

	function editor.save()
		return {editor.source:GetSelectedValue() or "inventory"};
	end
end

function TRP3_API.extended.tools.initItemEffects()

	inventorySourcesLocals = {
		inventory = loc.EFFECT_ITEM_SOURCE_1,
		parent = loc.EFFECT_ITEM_SOURCE_2,
		self = loc.EFFECT_ITEM_SOURCE_3,
	}

	-- Effects
	item_sheath_init();
	item_bag_durability_init();
	item_consume_init();
	item_add_init();
	item_remove_init();
	item_cooldown_init();
	item_use_init();
	item_roll_dice_init();
	inv_loot_init();
	run_item_workflow_init();

	document_show_init();
	document_close_init();

	-- Operands
	inv_item_count_init();
	inv_item_weight_init();
end