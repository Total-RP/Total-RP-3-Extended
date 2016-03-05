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
local wipe, pairs, strsplit, tinsert, table = wipe, pairs, strsplit, tinsert, table;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local editor = TRP3_ItemQuickEditor;
local onCreatedCallback;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item quick editor
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onSave()
	local ID, data = TRP3_API.extended.tools.createItem(
		{
			TY = TRP3_DB.types.ITEM,
			BA = {
				NA = editor.name:GetText(),
			}
		}
	);

	if onCreatedCallback then
		onCreatedCallback();
	end
	editor:Hide();
end

function TRP3_API.extended.tools.openItemQuickEditor(anchoredFrame, callback)
	onCreatedCallback = callback;
	TRP3_API.ui.frame.configureHoverFrame(editor, anchoredFrame, "BOTTOM", 0, 5, true);
	editor.name:SetText("New item"); -- TODO: locals
	editor.description:SetText("");
	editor.quality:SetSelectedValue(LE_ITEM_QUALITY_COMMON);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local setupListBox = TRP3_API.ui.listbox.setupListBox;
local colorCodeFloatTab = Utils.color.colorCodeFloatTab;

function TRP3_API.extended.tools.initItemQuickEditor()
	-- Name
	editor.name.title:SetText("Item name"); -- TODO: locals
	setTooltipForSameFrame(editor.name.help, "RIGHT", 0, 5, "Item name", "It's your item name."); -- TODO: locals

	-- Quality
	local neutral = {r = 0.95, g = 0.95, b = 0.95};
	local qualityList = {
		{loc("IT_FIELD_QUALITY") .. ": " .. colorCodeFloatTab(BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_COMMON] or neutral) .. ITEM_QUALITY0_DESC, LE_ITEM_QUALITY_POOR},
		{loc("IT_FIELD_QUALITY") .. ": " .. colorCodeFloatTab(BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_POOR] or neutral) .. ITEM_QUALITY1_DESC, LE_ITEM_QUALITY_COMMON},
		{loc("IT_FIELD_QUALITY") .. ": " .. colorCodeFloatTab(BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_UNCOMMON] or neutral) .. ITEM_QUALITY2_DESC, LE_ITEM_QUALITY_UNCOMMON},
		{loc("IT_FIELD_QUALITY") .. ": " .. colorCodeFloatTab(BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_RARE] or neutral) .. ITEM_QUALITY3_DESC, LE_ITEM_QUALITY_RARE},
		{loc("IT_FIELD_QUALITY") .. ": " .. colorCodeFloatTab(BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_EPIC] or neutral) .. ITEM_QUALITY4_DESC, LE_ITEM_QUALITY_EPIC},
		{loc("IT_FIELD_QUALITY") .. ": " .. colorCodeFloatTab(BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_LEGENDARY] or neutral) .. ITEM_QUALITY5_DESC, LE_ITEM_QUALITY_LEGENDARY},
		{loc("IT_FIELD_QUALITY") .. ": " .. colorCodeFloatTab(BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_HEIRLOOM] or neutral) .. ITEM_QUALITY7_DESC, LE_ITEM_QUALITY_HEIRLOOM},
		{loc("IT_FIELD_QUALITY") .. ": " .. colorCodeFloatTab(BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_WOW_TOKEN] or neutral) .. ITEM_QUALITY8_DESC, LE_ITEM_QUALITY_WOW_TOKEN},
	};
	setupListBox(editor.quality, qualityList, nil, nil, 215, true);

	-- Left attribute
	editor.left.title:SetText("Tooltip left text"); -- TODO: locals
	setTooltipForSameFrame(editor.left.help, "RIGHT", 0, 5, "Tooltip left text", "It's a free text that will be in the tooltip"); -- TODO: locals

	-- Right attribute
	editor.right.title:SetText("Tooltip right text"); -- TODO: locals
	setTooltipForSameFrame(editor.right.help, "RIGHT", 0, 5, "Tooltip right text", "It's a free text that will be in the tooltip"); -- TODO: locals

	-- Description
	editor.description.title:SetText("Tooltip description"); -- TODO: locals
	setTooltipForSameFrame(editor.description.help, "RIGHT", 0, 5, "Tooltip description", "It's your item description."); -- TODO: locals

	-- Value
	editor.value.title:SetText("Item value"); -- TODO: locals
	setTooltipForSameFrame(editor.value.help, "RIGHT", 0, 5, "Item value", "This value will be used for transactions."); -- TODO: locals

	-- Weight
	editor.weight.title:SetText("Item weight (in grams)"); -- TODO: locals
	setTooltipForSameFrame(editor.weight.help, "RIGHT", 0, 5, "Item weight", "The weight influence the total weight of the container."); -- TODO: locals

	-- Preview
	editor.preview.Name:SetText("Preview"); -- TODO: locals
	editor.preview.InfoText:SetText("Click to select the item icon."); -- TODO: locals

	-- Save
	editor.save:SetScript("OnClick", onSave);

	-- Frame
	editor.title:SetText("Quick item creation"); -- TODO: locals
	editor.display:SetText("Display attributes"); -- TODO: locals
	editor.gameplay:SetText("Gameplay attributes"); -- TODO: locals
	editor:SetScript("OnShow", function()
		editor.name:SetFocus();
	end)
end