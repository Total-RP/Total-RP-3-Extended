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
local wipe, pairs, tonumber, date, strtrim = wipe, pairs, tonumber, date, strtrim;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local editor, toolFrame = TRP3_ItemQuickEditor;
local onCreatedCallback;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item creation: Container template
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getContainerItemData()
	return {
		TY = TRP3_DB.types.ITEM,
		MD = {
			MO = TRP3_DB.modes.NORMAL,
			V = 1,
			CD = date("%d/%m/%y %H:%M:%S");
			CB = Globals.player_id,
			SD = date("%d/%m/%y %H:%M:%S");
			SB = Globals.player_id,
		},
		BA = {
			NA = "Container item", -- TODO: locals
			CT = true,
			IC = "inv_misc_bag_01"
		},
	};
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item quick editor
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function injectUIData(data)
	data.BA.NA = stEtN(strtrim(editor.name:GetText()));
	data.BA.DE = stEtN(strtrim(editor.description:GetText()));
	data.BA.LE = stEtN(strtrim(editor.left:GetText()));
	data.BA.RI = stEtN(strtrim(editor.right:GetText()));
	data.BA.QA = editor.quality:GetSelectedValue() or LE_ITEM_QUALITY_COMMON;
	data.BA.VA = tonumber(editor.value:GetText());
	data.BA.WE = tonumber(editor.weight:GetText());
	data.BA.IC = editor.preview.selectedIcon;
	data.BA.CO = editor.component:GetChecked();
	return data;
end

local function onSave(toMode)
	local ID, data;
	if editor.classID then
		-- Edition
		data = getClass(editor.classID);
		injectUIData(data);
		data.MD.V = data.MD.V + 1;
		data.MD.SD = date("%d/%m/%y %H:%M:%S");
		data.MD.SB = Globals.player_id;
		data.MD.MO = toMode or TRP3_DB.modes.QUICK;
	else
		-- New item
		data = TRP3_API.extended.tools.getBlankItemData(toMode);
		ID, data = TRP3_API.extended.tools.createItem(injectUIData(data));
	end

	if onCreatedCallback then
		onCreatedCallback(ID, data);
	end
	editor:Hide();
	Events.fireEvent(Events.ON_OBJECT_UPDATED, ID, TRP3_DB.types.ITEM);
	return ID;
end

local function onConvert()
	TRP3_API.extended.tools.goToPage(onSave(TRP3_DB.modes.NORMAL));
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

function TRP3_API.extended.tools.openItemQuickEditor(anchoredFrame, callback, classID)
	onCreatedCallback = callback;
	editor.classID = classID;
	if classID then
		editor.title:SetText(loc("IT_QUICK_EDITOR_EDIT"));
		TRP3_API.ui.frame.configureHoverFrame(editor, toolFrame, "CENTER", 0, 5, false);
		loadData(getClass(classID));
	else
		editor.title:SetText(loc("IT_QUICK_EDITOR"));
		TRP3_API.ui.frame.configureHoverFrame(editor, anchoredFrame, "BOTTOM", 0, 5, false);
		loadData({
			BA = {
				NA = loc("IT_NEW_NAME"),
				QA = LE_ITEM_QUALITY_COMMON,
			}
		});
	end
end

local function onQuickCreatedFromList(classID, _)
	TRP3_API.inventory.addItem(nil, classID);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local setupListBox = TRP3_API.ui.listbox.setupListBox;
local getQualityColorText = TRP3_API.inventory.getQualityColorText;

function TRP3_API.extended.tools.initItemQuickEditor(ToolFrame)
	toolFrame = ToolFrame;

	-- Name
	editor.name.title:SetText(loc("IT_FIELD_NAME"));
	setTooltipForSameFrame(editor.name.help, "RIGHT", 0, 5, loc("IT_FIELD_NAME"), loc("IT_FIELD_NAME_TT"));

	-- Quality
	editor.qualityList = {
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_POOR) .. ITEM_QUALITY0_DESC, LE_ITEM_QUALITY_POOR},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_COMMON) .. ITEM_QUALITY1_DESC, LE_ITEM_QUALITY_COMMON},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_UNCOMMON) .. ITEM_QUALITY2_DESC, LE_ITEM_QUALITY_UNCOMMON},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_RARE) .. ITEM_QUALITY3_DESC, LE_ITEM_QUALITY_RARE},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_EPIC) .. ITEM_QUALITY4_DESC, LE_ITEM_QUALITY_EPIC},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_LEGENDARY) .. ITEM_QUALITY5_DESC, LE_ITEM_QUALITY_LEGENDARY},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_HEIRLOOM) .. ITEM_QUALITY7_DESC, LE_ITEM_QUALITY_HEIRLOOM},
		{loc("IT_FIELD_QUALITY") .. ": " .. getQualityColorText(LE_ITEM_QUALITY_WOW_TOKEN) .. ITEM_QUALITY8_DESC, LE_ITEM_QUALITY_WOW_TOKEN},
	};
	setupListBox(editor.quality, editor.qualityList, nil, nil, 165, true);

	-- Left attribute
	editor.left.title:SetText(loc("IT_TT_LEFT"));
	setTooltipForSameFrame(editor.left.help, "RIGHT", 0, 5, loc("IT_TT_LEFT"), loc("IT_TT_LEFT_TT"));

	-- Right attribute
	editor.right.title:SetText(loc("IT_TT_RIGHT"));
	setTooltipForSameFrame(editor.right.help, "RIGHT", 0, 5, loc("IT_TT_RIGHT"), loc("IT_TT_RIGHT_TT"));

	-- Description
	editor.description.title:SetText(loc("IT_TT_DESCRIPTION"));
	setTooltipForSameFrame(editor.description.help, "RIGHT", 0, 5, loc("IT_TT_DESCRIPTION"), loc("IT_TT_DESCRIPTION_TT"));

	-- Component
	editor.component.Text:SetText(loc("IT_TT_REAGENT"));
	setTooltipForSameFrame(editor.component, "RIGHT", 0, 5, loc("IT_TT_REAGENT"), loc("IT_TT_REAGENT_TT"));

	-- Value
	editor.value.title:SetText(loc("IT_TT_VALUE_FORMAT"):format(Utils.str.texture("Interface\\MONEYFRAME\\UI-CopperIcon", 15)));
	setTooltipForSameFrame(editor.value.help, "RIGHT", 0, 5, loc("IT_TT_VALUE"), loc("IT_TT_VALUE_TT"));

	-- Weight
	editor.weight.title:SetText(loc("IT_TT_WEIGHT_FORMAT"));
	setTooltipForSameFrame(editor.weight.help, "RIGHT", 0, 5, loc("IT_TT_WEIGHT"), loc("IT_TT_WEIGHT_TT"));

	-- Preview
	editor.preview.Name:SetText(loc("EDITOR_PREVIEW"));
	editor.preview.InfoText:SetText(loc("EDITOR_ICON_SELECT"));
	editor.preview:SetScript("OnEnter", function(self)
		TRP3_API.inventory.showItemTooltip(self, Globals.empty, injectUIData({BA={}}), true);
	end);
	editor.preview:SetScript("OnLeave", function(self)
		TRP3_ItemTooltip:Hide();
	end);
	editor.preview:SetScript("OnClick", function(self)
		TRP3_API.popup.showIconBrowser(onIconSelected, nil, self, 1);
	end);

	-- Save
	editor.save:SetScript("OnClick", onSave);

	-- Save
	editor.convert:SetScript("OnClick", onConvert);

	-- Frame
	TRP3_API.ui.frame.setupEditBoxesNavigation({
		editor.name,
		editor.left,
		editor.right,
		editor.description,
		editor.value,
		editor.weight,
	});
	editor.convert:SetText(loc("IT_CONVERT_TO_NORMAL"));
	editor.title:SetText(loc("IT_QUICK_EDITOR"));
	editor.display:SetText(loc("IT_DISPLAY_ATT"));
	editor.gameplay:SetText(loc("IT_GAMEPLAY_ATT"));
	editor.convert:SetText(loc("IT_CONVERT_TO_NORMAL"));
	editor:SetScript("OnShow", function()
		editor.name:SetFocus();
	end);
	setTooltipForSameFrame(editor.convert, "TOP", 0, 0, loc("IT_CONVERT_TO_NORMAL"), loc("IT_CONVERT_TO_NORMAL_TT"));

	-- Templates
	toolFrame.list.bottom.item.Name:SetText(loc("DB_CREATE_ITEM"));
	toolFrame.list.bottom.item.InfoText:SetText(loc("DB_CREATE_ITEM_TT"));
	toolFrame.list.bottom.item.templates.title:SetText(loc("DB_CREATE_ITEM_TEMPLATES"));
	toolFrame.list.bottom.item.templates.quick.Name:SetText(loc("DB_CREATE_ITEM_TEMPLATES_QUICK"));
	toolFrame.list.bottom.item.templates.quick.InfoText:SetText(loc("DB_CREATE_ITEM_TEMPLATES_QUICK_TT"));
	toolFrame.list.bottom.item.templates.document.Name:SetText(loc("DB_CREATE_ITEM_TEMPLATES_DOCUMENT"));
	toolFrame.list.bottom.item.templates.document.InfoText:SetText(loc("DB_CREATE_ITEM_TEMPLATES_DOCUMENT_TT"));
	toolFrame.list.bottom.item.templates.blank.Name:SetText(loc("DB_CREATE_ITEM_TEMPLATES_BLANK"));
	toolFrame.list.bottom.item.templates.blank.InfoText:SetText(loc("DB_CREATE_ITEM_TEMPLATES_BLANK_TT"));
	toolFrame.list.bottom.item.templates.container.Name:SetText(loc("DB_CREATE_ITEM_TEMPLATES_CONTAINER"));
	toolFrame.list.bottom.item.templates.container.InfoText:SetText(loc("DB_CREATE_ITEM_TEMPLATES_CONTAINER_TT"));

	TRP3_API.ui.frame.setupIconButton(toolFrame.list.bottom.item.templates.container, "inv_misc_bag_36");
	TRP3_API.ui.frame.setupIconButton(toolFrame.list.bottom.item.templates.blank, "inv_inscription_scroll");
	TRP3_API.ui.frame.setupIconButton(toolFrame.list.bottom.item.templates.document, "inv_misc_book_16");
	TRP3_API.ui.frame.setupIconButton(toolFrame.list.bottom.item.templates.quick, "petbattle_speed");
	TRP3_API.ui.frame.setupIconButton(toolFrame.list.bottom.item, "inv_garrison_blueprints1");

	toolFrame.list.bottom.item:SetScript("OnClick", function(self)
		if TRP3_ItemQuickEditor:IsVisible() then
			TRP3_ItemQuickEditor:Hide();
		elseif self.templates:IsVisible() then
			self.templates:Hide();
		else
			TRP3_API.ui.frame.configureHoverFrame(self.templates, self, "BOTTOM", 0, 5, false);
		end
	end);

	toolFrame.list.bottom.item.templates.quick:SetScript("OnClick", function(self)
		toolFrame.list.bottom.item.templates:Hide();
		TRP3_API.extended.tools.openItemQuickEditor(toolFrame.list.bottom.item, onQuickCreatedFromList);
	end);

	toolFrame.list.bottom.item.templates.blank:SetScript("OnClick", function(self)
		toolFrame.list.bottom.item.templates:Hide();
		local ID, _ = TRP3_API.extended.tools.createItem(TRP3_API.extended.tools.getBlankItemData(TRP3_DB.modes.NORMAL));
		TRP3_API.extended.tools.goToPage(ID);
	end);

	toolFrame.list.bottom.item.templates.container:SetScript("OnClick", function(self)
		toolFrame.list.bottom.item.templates:Hide();
		local ID, _ = TRP3_API.extended.tools.createItem(getContainerItemData());
		TRP3_API.extended.tools.goToPage(ID);
	end);
end