local _, addon = ...
local loc = TRP3_API.loc;

TRP3_Tools_EditorAuraMixin = CreateFromMixins(TRP3_Tools_EditorObjectMixin);

function TRP3_Tools_EditorAuraMixin:UpdatePreview(doFullUpdate)
	self.preview.class.BA.IC = self.display.icon.selectedIcon;
	self.preview.class.BA.OV = TRP3_API.utils.str.emptyToNil(strtrim(self.display.overlay:GetText()));
	
	local r, g, b = self.display.borderPicker.red, self.display.borderPicker.green, self.display.borderPicker.blue;
	if r and g and b then
		self.preview.class.BA.CO = TRP3_API.CreateColorFromBytes(r, g, b):GenerateHexColorOpaque();
		self.preview.color = {
			h = TRP3_API.CreateColorFromBytes(r, g, b):GenerateHexColorOpaque(),
			r = r/255,
			g = g/255,
			b = b/255,
		};
	else
		self.preview.class.BA.CO = nil;
		self.preview.color = nil;
	end

	if doFullUpdate then
		self.preview.persistent.expiry = time() + (self.gameplay.hasDuration:GetChecked() and tonumber(self.gameplay.duration:GetText()) or math.huge);
		self.preview.class.BA.DE = TRP3_API.script.parseArgs(TRP3_API.utils.str.emptyToNil(strtrim(self.display.description.scroll.text:GetText())), TRP3_API.globals.empty);
		self.preview.class.BA.NA = TRP3_API.utils.str.emptyToNil(strtrim(self.display.name:GetText()));
		self.preview.class.BA.CA = TRP3_API.utils.str.emptyToNil(strtrim(self.display.category:GetText()));
		self.preview.class.BA.FL = TRP3_API.utils.str.emptyToNil(strtrim(self.display.flavor.scroll.text:GetText()));
		self.preview.class.BA.CC = self.gameplay.cancellable:GetChecked();
	end

	addon.editor.object:SetAuraPreview(self.preview);
end

function TRP3_Tools_EditorAuraMixin:Initialize()
	local s = self;

	local display = self.display;
	local gameplay = self.gameplay;

	local presetBuffs = {
		{category = ""                   , color = nil     , helpful = true},
		{category = loc.AU_PRESET_CURSE  , color = "9600ff", helpful = false},
		{category = loc.AU_PRESET_DISEASE, color = "966400", helpful = false},
		{category = loc.AU_PRESET_MAGIC  , color = "3296ff", helpful = false},
		{category = loc.AU_PRESET_POISON , color = "009600", helpful = false},
		{category = ""                   , color = "c80000", helpful = false},
	};
	local presetMenu = {
		{"|cffffffff" .. loc.AU_PRESET_BUFF    .. "|r", 1},
		{"|cff9600ff" .. loc.AU_PRESET_CURSE   .. "|r", 2},
		{"|cff966400" .. loc.AU_PRESET_DISEASE .. "|r", 3},
		{"|cff3296ff" .. loc.AU_PRESET_MAGIC   .. "|r", 4},
		{"|cff009600" .. loc.AU_PRESET_POISON  .. "|r", 5},
		{"|cffc80000" .. loc.AU_PRESET_OTHER   .. "|r", 6},
	};
	local applyPreset = function(presetId)
		display.category:SetText(presetBuffs[presetId].category);
		display.helpful:SetChecked(presetBuffs[presetId].helpful);
		if presetBuffs[presetId].color then
			display.borderPicker.setColor(TRP3_API.CreateColorFromHexString(presetBuffs[presetId].color):GetRGBAsBytes());
		else
			display.borderPicker.setColor(nil);
		end
	end
	
	display.overlay:SetScript("OnTextChanged", function()
		self:UpdatePreview();
	end);
	display.overlay:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);

	display.description:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);

	display.preset:SetScript("OnClick", function(self)
		TRP3_MenuUtil.CreateContextMenu(self, function(_, description)
			for _, preset in pairs(presetMenu) do
				description:CreateButton(preset[1], applyPreset, preset[2]);
			end
		end);
	end);

	display.borderPicker.onSelection = function(red, green, blue)
		self:UpdatePreview();
	end
	display.borderPicker:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			if IsShiftKeyDown() or (TRP3_API.configuration.getValue("default_color_picker")) then
				TRP3_API.popup.showDefaultColorPicker({self.setColor, self.red, self.green, self.blue});
			else
				addon.modal:ShowModal(TRP3_API.popup.COLORS, {self.setColor, self.red, self.green, self.blue});
			end
		elseif button == "RightButton" then
			self.setColor(nil, nil, nil);
		end
	end);
	TRP3_API.ui.tooltip.setTooltipForSameFrame(display.borderPicker, "RIGHT", 0, 5, loc.AU_FIELD_COLOR, loc.AU_FIELD_COLOR_TT
	.. "|n|n" .. TRP3_API.FormatShortcutWithInstruction("LCLICK", loc.REG_PLAYER_COLOR_TT_SELECT)
	.. "|n" .. TRP3_API.FormatShortcutWithInstruction("RCLICK", loc.REG_PLAYER_COLOR_TT_DISCARD)
	.. "|n" .. TRP3_API.FormatShortcutWithInstruction("SHIFT-CLICK", loc.REG_PLAYER_COLOR_TT_DEFAULTPICKER));

	TRP3_API.ui.tooltip.setTooltipForSameFrame(display.icon, "RIGHT", 0, 5, "Aura icon", "select an aura icon");
	display.icon:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.ICONS, {function(icon) 
				display.icon.Icon:SetTexture("Interface\\ICONS\\" .. icon);
				display.icon.selectedIcon = icon;
				self:UpdatePreview();
			end, 
			nil, 
			nil, 
			display.icon.selectedIcon});
	end);

	self.preview = {
		persistent = {
			expiry = math.huge,
		},
		class = {
			BA = {
			}
		},
	};

	gameplay.hasDuration:SetScript("OnClick", function()
		if gameplay.hasDuration:GetChecked() then
			local currDuration = tonumber(gameplay.duration:GetText());
			if not currDuration or currDuration >= math.huge or currDuration <= 0 then
				gameplay.duration:SetText("300");
			end
			gameplay.duration:Show();
		else
			gameplay.duration:Hide();
		end
	end);

	gameplay.alwaysActive:SetScript("OnClick", function()
		gameplay.ensureExpiry:SetShown(gameplay.alwaysActive:GetChecked());
	end);

	gameplay.hasInterval:SetScript("OnClick", function()
		if gameplay.hasInterval:GetChecked() then
			local currInterval = tonumber(gameplay.interval:GetText());
			if not currInterval or currInterval >= math.huge or currInterval <= 0 then
				gameplay.interval:SetText("10");
			end
			gameplay.interval:Show();
		else
			gameplay.interval:Hide();
		end
	end);

	-- text might be longer in some localizations, let's ensure it doesn't clip out of frame
	gameplay.ensureExpiry.Text:SetPoint("RIGHT", gameplay, "RIGHT", -20, 0);
	gameplay.ensureExpiry.Text:SetJustifyH("LEFT");

end

function TRP3_Tools_EditorAuraMixin:ClassToInterface(class, creationClass, cursor)
	local BA = class.BA or TRP3_API.globals.empty;

	self.display.name:SetText(BA.NA or "");
	self.display.category:SetText(BA.CA or "");
	if BA.CO then
		self.display.borderPicker.setColor(TRP3_API.CreateColorFromHexString(BA.CO):GetRGBAsBytes());
	else
		self.display.borderPicker.setColor(nil);
	end

	self.display.description:SetText(BA.DE or "");
	self.display.flavor:SetText(BA.FL or "");
	self.display.overlay:SetText(BA.OV or "");
	self.display.helpful:SetChecked(BA.HE or false);

	self.display.icon.Icon:SetTexture("Interface\\ICONS\\" .. (BA.IC or "TEMP"));
	self.display.icon.selectedIcon = BA.IC;

	local hasDuration = (BA.DU or math.huge) < math.huge;
	self.gameplay.hasDuration:SetChecked(hasDuration);
	self.gameplay.duration:SetShown(hasDuration);
	self.gameplay.duration:SetText(("%0.1f"):format(BA.DU or 300):gsub("%.0+", "")); --  getting rid of ugly floating point artifacts

	self.gameplay.alwaysActive:SetChecked(BA.AA or false);
	self.gameplay.ensureExpiry:SetChecked(BA.EE or false);
	self.gameplay.ensureExpiry:SetShown(BA.AA);

	self.gameplay.boundToCampaign:SetShown(creationClass.TY == TRP3_DB.types.CAMPAIGN);
	self.gameplay.boundToCampaign:SetChecked(BA.BC or false);

	self.gameplay.cancellable:SetChecked(BA.CC or false);

	local hasInterval = (BA.IV or math.huge) < math.huge;
	self.gameplay.hasInterval:SetChecked(hasInterval);
	self.gameplay.interval:SetShown(hasInterval);
	self.gameplay.interval:SetText(("%0.1f"):format(BA.IV or 10):gsub("%.0+", ""));
	self.gameplay.inspectable:SetChecked(BA.WE or false);

	self:UpdatePreview();
end

function TRP3_Tools_EditorAuraMixin:InterfaceToClass(targetClass, targetCursor)
	targetClass.BA = targetClass.BA or {};
	
	targetClass.BA.NA = TRP3_API.utils.str.emptyToNil(strtrim(self.display.name:GetText()));
	targetClass.BA.CA = TRP3_API.utils.str.emptyToNil(strtrim(self.display.category:GetText()));
	local r, g, b = self.display.borderPicker.red, self.display.borderPicker.green, self.display.borderPicker.blue;
	if r and g and b then
		targetClass.BA.CO = TRP3_API.CreateColorFromBytes(r, g, b):GenerateHexColorOpaque();
	else
		targetClass.BA.CO = nil;
	end
	targetClass.BA.DE = TRP3_API.utils.str.emptyToNil(strtrim(self.display.description:GetText()));
	targetClass.BA.FL = TRP3_API.utils.str.emptyToNil(strtrim(self.display.flavor:GetText()));
	targetClass.BA.OV = TRP3_API.utils.str.emptyToNil(strtrim(self.display.overlay:GetText()));
	targetClass.BA.HE = self.display.helpful:GetChecked();
	targetClass.BA.IC = self.display.icon.selectedIcon;

	if self.gameplay.hasDuration:GetChecked() then
		targetClass.BA.DU = self.gameplay.duration:GetNumber();
		if targetClass.BA.DU <= 0 then
			targetClass.BA.DU = nil;
		end
	else
		targetClass.BA.DU = nil;
	end

	targetClass.BA.AA = self.gameplay.alwaysActive:GetChecked();
	targetClass.BA.EE = self.gameplay.ensureExpiry:GetChecked();
	targetClass.BA.BC = self.gameplay.boundToCampaign:GetChecked();
	targetClass.BA.CC = self.gameplay.cancellable:GetChecked();
	targetClass.BA.WE = self.gameplay.inspectable:GetChecked();

	if self.gameplay.hasInterval:GetChecked() then
		targetClass.BA.IV = math.max(self.gameplay.interval:GetNumber(), 0.1); -- because I say so
	else
		targetClass.BA.IV = nil;
	end

end
