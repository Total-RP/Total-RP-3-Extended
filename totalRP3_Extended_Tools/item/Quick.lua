-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local _, addon = ...;

local Globals, Utils = TRP3_API.globals, TRP3_API.utils;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local editor, toolFrame = TRP3_ItemQuickEditor;
local onCreatedCallback;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item quick editor
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function injectUIData(data)
	data.BA.NA = stEtN(strtrim(editor.name:GetText()));
	data.BA.DE = stEtN(strtrim(editor.description:GetText()));
	data.BA.LE = stEtN(strtrim(editor.left:GetText()));
	data.BA.RI = stEtN(strtrim(editor.right:GetText()));
	data.BA.QA = editor.quality:GetSelectedValue() or Enum.ItemQuality.Common;
	data.BA.VA = tonumber(editor.value:GetText());
	data.BA.WE = tonumber(editor.weight:GetText());
	data.BA.IC = editor.preview.selectedIcon;
	data.BA.WA = editor.wearable:GetChecked();
	return data;
end

local function onSave(toMode)
	local ID, data;
	if editor.classID then
		ID = editor.classID;
		-- Edition
		data = getClass(editor.classID);
		injectUIData(data);
		data.MD.V = data.MD.V + 1;
		data.MD.SD = date("%d/%m/%y %H:%M:%S");
		data.MD.SB = Globals.player_id;
		data.MD.MO = toMode or TRP3_DB.modes.QUICK;
		TRP3_API.extended.unregisterObject(ID);
	else
		-- New item
		data = TRP3_API.extended.tools.getBlankItemData(toMode);
		ID, data = TRP3_API.extended.tools.createItem(injectUIData(data));
	end

	if onCreatedCallback then
		onCreatedCallback(ID, data);
	end
	editor:Hide();

	TRP3_API.security.computeSecurity(ID, data);
	TRP3_API.extended.registerObject(ID, data, 0);

	TRP3_Extended:TriggerEvent(TRP3_Extended.Events.ON_OBJECT_UPDATED, ID, TRP3_DB.types.ITEM);
	return ID;
end

local function onConvert()
	addon.main.openDraft(onSave(TRP3_DB.modes.NORMAL));
end

local function onIconSelected(icon)
	editor.preview.Icon:SetTexture("Interface\\ICONS\\" .. (icon or "TEMP"));
	editor.preview.selectedIcon = icon;
end

local function loadData(data)
	editor.name:SetText(data.BA.NA or "");
	editor.description:SetText(data.BA.DE or "");
	editor.quality:SetSelectedValue(data.BA.QA or Enum.ItemQuality.Common);
	editor.left:SetText(data.BA.LE or "");
	editor.right:SetText(data.BA.RI or "");
	editor.value:SetText(data.BA.VA or "0");
	editor.weight:SetText(data.BA.WE or "0");
	editor.wearable:SetChecked(data.BA.WA or false);
	onIconSelected(data.BA.IC);
end

function TRP3_API.extended.tools.openItemQuickEditor(anchoredFrame, callback, classID, fromInv, noSave)
	onCreatedCallback = callback;
	editor.classID = classID;
	editor.convert:Hide();
	editor.save:Disable();
	if not fromInv and not noSave then
		editor.convert:Show();
	end
	if not noSave then
		editor.save:Enable();
	end

	if classID then
		editor.title:SetText(loc.IT_QUICK_EDITOR_EDIT);
		if not fromInv then
			TRP3_API.ui.frame.configureHoverFrame(editor, toolFrame, "CENTER", 0, 5, false);
		else
			TRP3_API.ui.frame.configureHoverFrame(editor, anchoredFrame, "CENTER", 0, 0, false);
		end
		loadData(getClass(classID));
	else
		editor.title:SetText(loc.IT_QUICK_EDITOR);
		if not fromInv then
			TRP3_API.ui.frame.configureHoverFrame(editor, anchoredFrame, "BOTTOM", 0, 5, false);
		else
			TRP3_API.ui.frame.configureHoverFrame(editor, anchoredFrame, "CENTER", 0, 0, false);
		end
		loadData({
			BA = {
				NA = loc.IT_NEW_NAME,
				QA = Enum.ItemQuality.Common,
			}
		});
	end
end

local function onQuickCreatedFromList(classID, _)
	TRP3_API.popup.showNumberInputPopup(loc.DB_ADD_COUNT:format(TRP3_API.inventory.getItemLink(TRP3_API.extended.getClass(classID))), function(value)
		TRP3_API.inventory.addItem(nil, classID, {count = value or 1});
	end, nil, 1);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local setupListBox = TRP3_API.ui.listbox.setupListBox;
local getQualityColorText = TRP3_API.inventory.getQualityColorText;

function TRP3_API.extended.tools.initItemQuickEditor(ToolFrame)
	toolFrame = ToolFrame;

	editor:SetScript("OnHide", function(self)
		self:Hide();
	end);

	-- Name
	editor.name.title:SetText(loc.IT_FIELD_NAME);
	setTooltipForSameFrame(editor.name.help, "RIGHT", 0, 5, loc.IT_FIELD_NAME, loc.IT_FIELD_NAME_TT);

	-- Quality
	editor.qualityList = {
		{loc.IT_FIELD_QUALITY .. ": " .. getQualityColorText(Enum.ItemQuality.Poor) .. ITEM_QUALITY0_DESC, Enum.ItemQuality.Poor},
		{loc.IT_FIELD_QUALITY .. ": " .. getQualityColorText(Enum.ItemQuality.Common) .. ITEM_QUALITY1_DESC, Enum.ItemQuality.Common},
		{loc.IT_FIELD_QUALITY .. ": " .. getQualityColorText(Enum.ItemQuality.Uncommon) .. ITEM_QUALITY2_DESC, Enum.ItemQuality.Uncommon},
		{loc.IT_FIELD_QUALITY .. ": " .. getQualityColorText(Enum.ItemQuality.Rare) .. ITEM_QUALITY3_DESC, Enum.ItemQuality.Rare},
		{loc.IT_FIELD_QUALITY .. ": " .. getQualityColorText(Enum.ItemQuality.Epic) .. ITEM_QUALITY4_DESC, Enum.ItemQuality.Epic},
		{loc.IT_FIELD_QUALITY .. ": " .. getQualityColorText(Enum.ItemQuality.Legendary) .. ITEM_QUALITY5_DESC, Enum.ItemQuality.Legendary},
		{loc.IT_FIELD_QUALITY .. ": " .. getQualityColorText(Enum.ItemQuality.Artifact) .. ITEM_QUALITY6_DESC, Enum.ItemQuality.Artifact},
		{loc.IT_FIELD_QUALITY .. ": " .. getQualityColorText(Enum.ItemQuality.Heirloom) .. ITEM_QUALITY7_DESC, Enum.ItemQuality.Heirloom},
	};
	setupListBox(editor.quality, editor.qualityList, nil, nil, 165, true);
	editor.quality:SetWidth(165);

	-- Left attribute
	editor.left.title:SetText(loc.IT_TT_LEFT);
	setTooltipForSameFrame(editor.left.help, "RIGHT", 0, 5, loc.IT_TT_LEFT, loc.IT_TT_LEFT_TT);

	-- Right attribute
	editor.right.title:SetText(loc.IT_TT_RIGHT);
	setTooltipForSameFrame(editor.right.help, "RIGHT", 0, 5, loc.IT_TT_RIGHT, loc.IT_TT_RIGHT_TT);

	-- Description
	editor.description.title:SetText(loc.IT_TT_DESCRIPTION);
	setTooltipForSameFrame(editor.description.help, "RIGHT", 0, 5, loc.IT_TT_DESCRIPTION, loc.IT_TT_DESCRIPTION_TT);

	-- Wearable
	editor.wearable.Text:SetText(loc.IT_WEARABLE);
	setTooltipForSameFrame(editor.wearable, "RIGHT", 0, 5, loc.IT_WEARABLE, loc.IT_WEARABLE_TT);

	-- Value
	editor.value.title:SetText(loc.IT_TT_VALUE_FORMAT:format(Utils.str.texture("Interface\\MONEYFRAME\\UI-CopperIcon", 15)));
	setTooltipForSameFrame(editor.value.help, "RIGHT", 0, 5, loc.IT_TT_VALUE, loc.IT_TT_VALUE_TT);

	-- Weight
	editor.weight.title:SetText(loc.IT_TT_WEIGHT_FORMAT);
	setTooltipForSameFrame(editor.weight.help, "RIGHT", 0, 5, loc.IT_TT_WEIGHT, loc.IT_TT_WEIGHT_TT);

	-- Preview
	editor.preview.Name:SetText(loc.EDITOR_PREVIEW);
	editor.preview.InfoText:SetText(loc.EDITOR_ICON_SELECT);
	editor.preview:SetScript("OnEnter", function(self)
		TRP3_API.inventory.showItemTooltip(self, Globals.empty, injectUIData({BA={}}), true);
	end);
	editor.preview:SetScript("OnLeave", function(self)
		TRP3_ItemTooltip:Hide();
	end);
	editor.preview:SetScript("OnClick", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.ICONS, {parent = editor, point = "LEFT", parentPoint = "RIGHT"}, {onIconSelected, nil, nil, editor.preview.selectedIcon});
	end);

	-- Save
	editor.save:SetScript("OnClick", function() onSave() end);

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
	editor.convert:SetText(loc.IT_CONVERT_TO_NORMAL);
	editor.title:SetText(loc.IT_QUICK_EDITOR);
	editor.display:SetText(loc.IT_DISPLAY_ATT);
	editor.gameplay:SetText(loc.IT_GAMEPLAY_ATT);
	editor.convert:SetText(loc.IT_CONVERT_TO_NORMAL);
	editor:SetScript("OnShow", function()
		editor.name:SetFocus();
	end);
	setTooltipForSameFrame(editor.convert, "TOP", 0, 0, loc.IT_CONVERT_TO_NORMAL, loc.IT_CONVERT_TO_NORMAL_TT);

end
