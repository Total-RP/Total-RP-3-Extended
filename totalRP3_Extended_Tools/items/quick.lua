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
local wipe, pairs, tonumber, tinsert, strtrim = wipe, pairs, tonumber, tinsert, strtrim;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local editor = TRP3_ItemQuickEditor;
local onCreatedCallback;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item quick editor
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getUIData()
	local data = {
		TY = TRP3_DB.types.ITEM,
		BA = {
			NA = stEtN(strtrim(editor.name:GetText())),
			DE = stEtN(strtrim(editor.description:GetText())),
			LE = stEtN(strtrim(editor.left:GetText())),
			RI = stEtN(strtrim(editor.right:GetText())),
			QA = editor.quality:GetSelectedValue() or LE_ITEM_QUALITY_COMMON,
			VA = tonumber(editor.value:GetText()),
			WE = tonumber(editor.weight:GetText()),
			IC = editor.preview.selectedIcon,
			CO = editor.component:GetChecked(),
		}
	};
	return data;
end

local function onSave()
	local ID, data = TRP3_API.extended.tools.createItem(getUIData());
	if onCreatedCallback then
		onCreatedCallback(ID, data);
	end
	editor:Hide();
end

local function onIconSelected(icon)
	editor.preview.Icon:SetTexture("Interface\\ICONS\\" .. (icon or "TEMP"));
	editor.preview.selectedIcon = icon;
end

local function loadData(data)
	editor.name:SetText(data.BA.NA or "");
	editor.description:SetText(data.BA.DE or "");
	editor.quality:SetSelectedValue(data.BA.QA or LE_ITEM_QUALITY_COMMON);
	editor.left:SetText(data.BA.LE or "");
	editor.right:SetText(data.BA.RI or "");
	editor.value:SetText(data.BA.VA or "0");
	editor.weight:SetText(data.BA.WE or "0");
	editor.component:SetChecked(data.BA.CO or false);
	onIconSelected(data.BA.IC);
end

function TRP3_API.extended.tools.openItemQuickEditor(anchoredFrame, callback)
	onCreatedCallback = callback;
	TRP3_API.ui.frame.configureHoverFrame(editor, anchoredFrame, "BOTTOM", 0, 5, false);
	loadData({
		BA = {
			NA = "New item", -- TODO: locals
			QA = LE_ITEM_QUALITY_COMMON,
		}
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local setupListBox = TRP3_API.ui.listbox.setupListBox;
local getQualityColorText = TRP3_API.inventory.getQualityColorText;

function TRP3_API.extended.tools.initItemQuickEditor()
	-- Name
	editor.name.title:SetText("Item name"); -- TODO: locals
	setTooltipForSameFrame(editor.name.help, "RIGHT", 0, 5, "Item name", "It's your item name."); -- TODO: locals

	-- Quality
	local neutral = {r = 0.95, g = 0.95, b = 0.95};
	local qualityList = {
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_POOR) .. ITEM_QUALITY0_DESC, LE_ITEM_QUALITY_POOR},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_COMMON) .. ITEM_QUALITY1_DESC, LE_ITEM_QUALITY_COMMON},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_UNCOMMON) .. ITEM_QUALITY2_DESC, LE_ITEM_QUALITY_UNCOMMON},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_RARE) .. ITEM_QUALITY3_DESC, LE_ITEM_QUALITY_RARE},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_EPIC) .. ITEM_QUALITY4_DESC, LE_ITEM_QUALITY_EPIC},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_LEGENDARY) .. ITEM_QUALITY5_DESC, LE_ITEM_QUALITY_LEGENDARY},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_HEIRLOOM) .. ITEM_QUALITY7_DESC, LE_ITEM_QUALITY_HEIRLOOM},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_WOW_TOKEN) .. ITEM_QUALITY8_DESC, LE_ITEM_QUALITY_WOW_TOKEN},
	};
	setupListBox(editor.quality, qualityList, nil, nil, 165, true);

	-- Left attribute
	editor.left.title:SetText("Tooltip custom left text"); -- TODO: locals
	setTooltipForSameFrame(editor.left.help, "RIGHT", 0, 5, "Tooltip custom left text", "It's a free text that will be in the tooltip"); -- TODO: locals

	-- Right attribute
	editor.right.title:SetText("Tooltip custom right text"); -- TODO: locals
	setTooltipForSameFrame(editor.right.help, "RIGHT", 0, 5, "Tooltip custom right text", "It's a free text that will be in the tooltip"); -- TODO: locals

	-- Description
	editor.description.title:SetText("Tooltip description"); -- TODO: locals
	setTooltipForSameFrame(editor.description.help, "RIGHT", 0, 5, "Tooltip description", "It's your item description."); -- TODO: locals

	-- Component
	editor.component.Text:SetText("Crafting reagent flag"); -- TODO: locals
	setTooltipForSameFrame(editor.component, "RIGHT", 0, 5, "Crafting reagent flag", "Shows the \"Crafting reagent\" line in the tooltip. Note that this is only cosmetic and haven't any influence on gameplay."); -- TODO: locals

	-- Value
	editor.value.title:SetText(("Item value (in %s)"):format(Utils.str.texture("Interface\\MONEYFRAME\\UI-CopperIcon", 15))); -- TODO: locals
	setTooltipForSameFrame(editor.value.help, "RIGHT", 0, 5, "Item value", "This value will be used for transactions."); -- TODO: locals

	-- Weight
	editor.weight.title:SetText("Item weight (in grams)"); -- TODO: locals
	setTooltipForSameFrame(editor.weight.help, "RIGHT", 0, 5, "Item weight", "The weight influence the total weight of the container."); -- TODO: locals

	-- Preview
	editor.preview.Name:SetText("Preview"); -- TODO: locals
	editor.preview.InfoText:SetText("Click to select an icon."); -- TODO: locals
	editor.preview:SetScript("OnEnter", function(self)
		TRP3_API.inventory.showItemTooltip(self, Globals.empty, getUIData(), true);
	end);
	editor.preview:SetScript("OnLeave", function(self)
		TRP3_ItemTooltip:Hide();
	end);
	editor.preview:SetScript("OnClick", function(self)
		TRP3_API.popup.showIconBrowser(onIconSelected, nil, self, 1);
	end);

	-- Save
	editor.save:SetScript("OnClick", onSave);

	-- Frame
	TRP3_API.ui.frame.setupEditBoxesNavigation({
		editor.name,
		editor.left,
		editor.right,
		editor.description,
		editor.value,
		editor.weight,
	})
	editor.title:SetText("Quick item creation"); -- TODO: locals
	editor.display:SetText("Display attributes"); -- TODO: locals
	editor.gameplay:SetText("Gameplay attributes"); -- TODO: locals
	editor:SetScript("OnShow", function()
		editor.name:SetFocus();
	end)
end