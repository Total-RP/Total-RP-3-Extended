local _, addon = ...
local loc = TRP3_API.loc;

TRP3_Tools_EditorItemMixin = CreateFromMixins(TRP3_Tools_EditorObjectMixin);

function TRP3_Tools_EditorItemMixin:UpdatePreview()
	self:InterfaceToClass(self.preview);
	addon.editor.object:SetItemPreview(self.preview);
end

function TRP3_Tools_EditorItemMixin:Initialize()
	local s = self;
	
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- DISPLAY
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Display
	local display = self.display;

	display.left:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);
	display.right:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);
	display.description:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);

	-- Quality
	local qualityList = {
		{TRP3_API.inventory.getQualityColorText(Enum.ItemQuality.Poor) .. ITEM_QUALITY0_DESC, Enum.ItemQuality.Poor},
		{TRP3_API.inventory.getQualityColorText(Enum.ItemQuality.Common) .. ITEM_QUALITY1_DESC, Enum.ItemQuality.Common},
		{TRP3_API.inventory.getQualityColorText(Enum.ItemQuality.Uncommon) .. ITEM_QUALITY2_DESC, Enum.ItemQuality.Uncommon},
		{TRP3_API.inventory.getQualityColorText(Enum.ItemQuality.Rare) .. ITEM_QUALITY3_DESC, Enum.ItemQuality.Rare},
		{TRP3_API.inventory.getQualityColorText(Enum.ItemQuality.Epic) .. ITEM_QUALITY4_DESC, Enum.ItemQuality.Epic},
		{TRP3_API.inventory.getQualityColorText(Enum.ItemQuality.Legendary) .. ITEM_QUALITY5_DESC, Enum.ItemQuality.Legendary},
		{TRP3_API.inventory.getQualityColorText(Enum.ItemQuality.Artifact) .. ITEM_QUALITY6_DESC, Enum.ItemQuality.Artifact},
		{TRP3_API.inventory.getQualityColorText(Enum.ItemQuality.Heirloom) .. ITEM_QUALITY7_DESC, Enum.ItemQuality.Heirloom},
	};
	TRP3_API.ui.listbox.setupListBox(display.quality, qualityList, function() self:UpdatePreview(); end);

	local containerTypes = {
		{loc.IT_CO_SIZE_COLROW:format(5, 4), "5x4"},
		{loc.IT_CO_SIZE_COLROW:format(2, 4), "2x4"},
		{loc.IT_CO_SIZE_COLROW:format(1, 4), "1x4"},
	};
	-- Container Size
	TRP3_API.ui.listbox.setupListBox(display.containerType, containerTypes);

	TRP3_API.ui.tooltip.setTooltipForSameFrame(display.icon, "RIGHT", 0, 5, loc.OP_OP_INV_ICON, "select an item icon");
	display.icon:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.ICONS, {
			function(icon) 
				display.icon.Icon:SetTexture("Interface\\ICONS\\" .. icon);
				display.icon.selectedIcon = icon;
				self:UpdatePreview();
			end, 
			nil, 
			nil, 
			display.icon.selectedIcon});
	end);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Gameplay
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	local gameplay = self.gameplay;
	
	-- Value edit box title != tooltip title
	gameplay.value.title:SetText(loc.IT_TT_VALUE_FORMAT:format(TRP3_API.utils.str.texture("Interface\\MONEYFRAME\\UI-CopperIcon", 15)));
	
	-- Weight edit box title != tooltip title
	gameplay.weight.title:SetText(loc.IT_TT_WEIGHT_FORMAT);

	gameplay.usetext:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);

	-- Pick up sound
	local pickUpList = {};
	for i = 1183, 1199 do
		tinsert(pickUpList, {loc["IT_PU_SOUND_" .. i], i});
	end
	tinsert(pickUpList, {loc["IT_PU_SOUND_".. 1221], 1221});
	TRP3_API.ui.listbox.setupListBox(gameplay.pickSound, pickUpList, function(value)
		if not gameplay.mute then
			TRP3_API.ui.misc.playSoundKit(value, "SFX");
		end
	end);

	-- Drop sound
	local dropList = {};
	for i = 1200, 1217 do
		tinsert(dropList, {loc["IT_DR_SOUND_" .. i], i});
	end
	TRP3_API.ui.listbox.setupListBox(gameplay.dropSound, dropList, function(value)
		if not gameplay.mute then
			TRP3_API.ui.misc.playSoundKit(value, "SFX");
		end
	end);

	local onCheckClicked = function()
		self:UpdateElementVisibility();
	end
	gameplay.unique:SetScript("OnClick", onCheckClicked);
	gameplay.stack:SetScript("OnClick", onCheckClicked);
	gameplay.use:SetScript("OnClick", onCheckClicked);
	display.container:SetScript("OnClick", onCheckClicked);
	
	display.quest:SetScript("OnClick", function() self:UpdatePreview(); end);

	self.preview = {};

end

function TRP3_Tools_EditorItemMixin:ClassToInterface(class, _, cursor)
	local BA = class.BA or TRP3_API.globals.empty;
	local US = class.US or TRP3_API.globals.empty;
	
	self.display.name:SetText(BA.NA or "");
	self.display.description:SetText(BA.DE or "");
	self.display.quality:SetSelectedValue(BA.QA or Enum.ItemQuality.Common);
	self.display.left:SetText(BA.LE or "");
	self.display.right:SetText(BA.RI or "");
	self.gameplay.component:SetChecked(BA.CO or false);
	self.gameplay.crafted:SetChecked(BA.CR or false);
	self.display.quest:SetChecked(BA.QE or false);
	
	self.gameplay.value:SetText(BA.VA or "0");
	self.gameplay.weight:SetText(BA.WE or "0");
	self.gameplay.soulbound:SetChecked(BA.SB or false);
	self.gameplay.unique:SetChecked((BA.UN or 0) > 0);
	self.gameplay.uniquecount:SetText(BA.UN or "1");
	self.gameplay.stack:SetChecked((BA.ST or 0) > 0);
	self.gameplay.stackcount:SetText(BA.ST or "20");
	self.gameplay.use:SetChecked(BA.US or false);
	self.gameplay.usetext:SetText(US.AC or "");
	self.gameplay.wearable:SetChecked(BA.WA or false);
	self.display.container:SetChecked(BA.CT or false);
	self.gameplay.noAdd:SetChecked(BA.PA or false);
	self.gameplay.mute = true;
	self.gameplay.pickSound:SetSelectedValue(BA.PS or 1186);
	self.gameplay.dropSound:SetSelectedValue(BA.DS or 1203);
	self.gameplay.mute = nil;
	
	local containerData = BA.CT and BA.CO or TRP3_API.globals.empty;
	self.display.containerType:SetSelectedValue(containerData.SI or "5x4");
	self.display.containerDurability:SetText(containerData.DU or "0");
	self.display.containerMaxweight:SetText(containerData.MW or "0");
	self.display.containerOnlyinner:SetChecked(containerData.OI or false);
	
	self.display.icon.Icon:SetTexture("Interface\\ICONS\\" .. (BA.IC or "TEMP"));
	self.display.icon.selectedIcon = BA.IC;

	self:UpdatePreview();
	self:UpdateElementVisibility();
	
end

function TRP3_Tools_EditorItemMixin:InterfaceToClass(targetClass, targetCursor)
	targetClass.BA = targetClass.BA or {};
	targetClass.US = targetClass.US or {};
	
	targetClass.BA.NA = TRP3_API.utils.str.emptyToNil(strtrim(self.display.name:GetText()));
	targetClass.BA.DE = TRP3_API.utils.str.emptyToNil(strtrim(self.display.description:GetText()));
	targetClass.BA.LE = TRP3_API.utils.str.emptyToNil(strtrim(self.display.left:GetText()));
	targetClass.BA.RI = TRP3_API.utils.str.emptyToNil(strtrim(self.display.right:GetText()));
	targetClass.BA.QA = self.display.quality:GetSelectedValue() or Enum.ItemQuality.Common;
	targetClass.BA.CO = self.gameplay.component:GetChecked();
	targetClass.BA.CR = self.gameplay.crafted:GetChecked();
	targetClass.BA.QE = self.display.quest:GetChecked();
	targetClass.BA.IC = self.display.icon.selectedIcon;
	targetClass.BA.VA = tonumber(self.gameplay.value:GetText()) or 0;
	targetClass.BA.WE = tonumber(self.gameplay.weight:GetText()) or 0;
	targetClass.BA.SB = self.gameplay.soulbound:GetChecked();
	targetClass.BA.UN = self.gameplay.unique:GetChecked() and tonumber(self.gameplay.uniquecount:GetText());
	targetClass.BA.ST = self.gameplay.stack:GetChecked() and tonumber(self.gameplay.stackcount:GetText());
	targetClass.BA.WA = self.gameplay.wearable:GetChecked();
	targetClass.BA.CT = self.display.container:GetChecked();
	targetClass.BA.PA = self.gameplay.noAdd:GetChecked();
	targetClass.BA.US = self.gameplay.use:GetChecked();
	if targetClass.BA.US then
		targetClass.US.AC = TRP3_API.utils.str.emptyToNil(strtrim(self.gameplay.usetext:GetText()));
		targetClass.US.SC = "onUse";
	else
		targetClass.US.AC = nil;
		targetClass.US.SC = nil;
	end
	targetClass.BA.PS = self.gameplay.pickSound:GetSelectedValue() or 1186;
	targetClass.BA.DS = self.gameplay.dropSound:GetSelectedValue() or 1203;
	
	if targetClass.BA.CT then
		targetClass.CO = targetClass.CO or {};
		targetClass.CO.SI = self.display.containerType:GetSelectedValue() or "5x4";
		local row, column = targetClass.CO.SI:match("(%d)x(%d)");
		targetClass.CO.SR = row;
		targetClass.CO.SC = column;
		targetClass.CO.DU = tonumber(self.display.containerDurability:GetText());
		targetClass.CO.MW = tonumber(self.display.containerMaxweight:GetText());
		targetClass.CO.OI = self.display.containerOnlyinner:GetChecked() or false;
	elseif targetClass.CO then
		wipe(targetClass.CO);
		targetClass.CO = nil;
	end
	
end

function TRP3_Tools_EditorItemMixin:UpdateElementVisibility()
	self.gameplay.uniquecount:SetShown(self.gameplay.unique:GetChecked());
	self.gameplay.stackcount:SetShown(self.gameplay.stack:GetChecked());
	self.gameplay.usetext:SetShown(self.gameplay.use:GetChecked());
	
	local isContainer = self.display.container:GetChecked();
	self.display.containerType:SetShown(isContainer);
	self.display.containerDurability:SetShown(isContainer);
	self.display.containerMaxweight:SetShown(isContainer);
	self.display.containerOnlyinner:SetShown(isContainer);
end

function TRP3_Tools_EditorItemMixin:OnScriptsChanged(changes)
	-- TODO presence of an "onUse" workflow and Usable should be equivalent, so both things should be linked
	-- on the other hand, the UI should probably not auto-sync those settings.
	-- temporary solution: activate Usable when the user creates an onUse, but don't deactivate if onUse is deleted
	if not self.gameplay.use:GetChecked() and addon.editor.script:HasScriptForTrigger("OU", addon.script.triggerType.OBJECT) then
		self.gameplay.use:SetChecked(true);
		self:UpdateElementVisibility();
	end
end
