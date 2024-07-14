
local Utils = TRP3_API.utils;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame, setTooltipAll = TRP3_API.ui.tooltip.setTooltipForSameFrame, TRP3_API.ui.tooltip.setTooltipAll;
local toolFrame, linksStructure, display, gameplay, notes;

local TABS = {
	MAIN = 1,
	WORKFLOWS = 2,
	INNER = 3,
	EVENTS = 4,
};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Script tab
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDataScript()
	-- Load workflows
	if not toolFrame.specificDraft.SC then
		toolFrame.specificDraft.SC = {};
	end
	TRP3_ScriptEditorNormal.loadList("AU");
end

local function storeDataScript()
	-- TODO: compute all workflow order
	for _, workflow in pairs(toolFrame.specificDraft.SC) do
		TRP3_ScriptEditorNormal.linkElements(workflow);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TABS
-- Tabs in the list section are just pre-filters
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local currentTab, tabGroup;

local function onTabChanged(tabWidget, tab) -- luacheck: ignore 212
	assert(toolFrame.fullClassID, "fullClassID is nil");

	-- Hide all
	currentTab = tab or TABS.MAIN;
	display:Hide();
	gameplay:Hide();
	notes:Hide();
	TRP3_ScriptEditorNormal:Hide();
	TRP3_LinksEditor:Hide();
	TRP3_InnerObjectEditor:Hide();
	TRP3_ExtendedTutorial.loadStructure(nil);

	-- Show tab
	if currentTab == TABS.MAIN then
		display:Show();
		gameplay:Show();
		notes:Show();
	elseif currentTab == TABS.WORKFLOWS then
		TRP3_ScriptEditorNormal:SetParent(toolFrame.aura.normal);
		TRP3_ScriptEditorNormal:SetAllPoints();
		TRP3_ScriptEditorNormal:Show();
	elseif currentTab == TABS.INNER then
		TRP3_InnerObjectEditor:SetParent(toolFrame.aura.normal);
		TRP3_InnerObjectEditor:SetAllPoints();
		TRP3_InnerObjectEditor:Show();
	elseif currentTab == TABS.EVENTS then
		TRP3_LinksEditor:SetParent(toolFrame.aura.normal);
		TRP3_LinksEditor:SetAllPoints();
		TRP3_LinksEditor:Show();
		TRP3_LinksEditor.load(linksStructure);
	end

	TRP3_API.extended.tools.saveTab(toolFrame.fullClassID, currentTab);
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameAuraNormalTabPanel", toolFrame.aura.normal);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ loc.EDITOR_MAIN, TABS.MAIN, 150 },
			{ loc.WO_WORKFLOW, TABS.WORKFLOWS, 150 },
			{ loc.IN_INNER, TABS.INNER, 150 },
			{ loc.WO_LINKS, TABS.EVENTS, 150 },
		},
		onTabChanged
	);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Load and save
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDataInner()
	-- Load inners
	if not toolFrame.specificDraft.IN then
		toolFrame.specificDraft.IN = {};
	end
	TRP3_InnerObjectEditor.refresh();
end

local function onIconSelected(icon)
	display.preview.aura.class.BA.IC = icon;
	display.preview:SetAuraAndShow(display.preview.aura);
end

local function load()
	assert(toolFrame.rootClassID, "rootClassID is nil");
	assert(toolFrame.fullClassID, "fullClassID is nil");
	assert(toolFrame.rootDraft, "rootDraft is nil");
	assert(toolFrame.specificDraft, "specificDraft is nil");

	local data = toolFrame.specificDraft;
	if not data.BA then
		data.BA = {};
	end

	display.name:SetText(data.BA.NA or "");
	display.category:SetText(data.BA.CA or "");
	if data.BA.CO then
		display.borderPicker.setColor(TRP3_API.CreateColorFromHexString(data.BA.CO):GetRGBAsBytes());
	else
		display.borderPicker.setColor(nil);
	end

	display.description.scroll.text:SetText(data.BA.DE or "");
	display.flavor.scroll.text:SetText(data.BA.FL or "");
	display.overlay:SetText(data.BA.OV or "");
	display.helpful:SetChecked(data.BA.HE or false);
	onIconSelected(data.BA.IC);

	local hasDuration = (data.BA.DU or math.huge) < math.huge;
	gameplay.hasDuration:SetChecked(hasDuration);
	gameplay.duration:SetShown(hasDuration);
	gameplay.duration:SetText(data.BA.DU or "300");

	gameplay.alwaysActive:SetChecked(data.BA.AA or false);
	gameplay.ensureExpiry:SetChecked(data.BA.EE or false);
	gameplay.ensureExpiry:SetShown(data.BA.AA);

	local isRootCampaign = toolFrame.rootDraft.TY == TRP3_DB.types.CAMPAIGN;
	if isRootCampaign then
		gameplay.boundToCampaign:Show();
	else
		gameplay.boundToCampaign:Hide();
	end
	gameplay.boundToCampaign:SetChecked(data.BA.BC or false);

	gameplay.cancellable:SetChecked(data.BA.CC or false);

	local hasInterval = (data.BA.IV or math.huge) < math.huge;
	gameplay.hasInterval:SetChecked(hasInterval);
	gameplay.interval:SetShown(hasInterval);
	gameplay.interval:SetText(data.BA.IV or "10");
	gameplay.inspectable:SetChecked(data.BA.WE or false);

	notes.frame.scroll.text:SetText(data.NT or "");

	loadDataInner();

	loadDataScript();
	TRP3_LinksEditor.load(linksStructure);

	tabGroup:SelectTab(TRP3_API.extended.tools.getSaveTab(toolFrame.fullClassID, tabGroup:Size()));
end

local function saveToDraft()
	assert(toolFrame.specificDraft, "specificDraft is nil");

	local data = toolFrame.specificDraft;
	data.BA.NA = stEtN(strtrim(display.name:GetText()));
	data.BA.CA = stEtN(strtrim(display.category:GetText()));
	if display.borderPicker.red and display.borderPicker.green and display.borderPicker.blue then
		local r, g, b = display.borderPicker.red, display.borderPicker.green, display.borderPicker.blue;
		data.BA.CO = TRP3_API.CreateColorFromBytes(r, g, b):GenerateHexColorOpaque();
	else
		data.BA.CO = nil;
	end
	data.BA.DE = stEtN(strtrim(display.description.scroll.text:GetText()));
	data.BA.FL = stEtN(strtrim(display.flavor.scroll.text:GetText()));
	data.BA.OV = stEtN(strtrim(display.overlay:GetText()));
	data.BA.HE = display.helpful:GetChecked();
	data.BA.IC = display.preview.aura.class.BA.IC;

	if gameplay.hasDuration:GetChecked() then
		data.BA.DU = gameplay.duration:GetNumber();
		if data.BA.DU <= 0 then
			data.BA.DU = nil;
		end
	else
		data.BA.DU = nil;
	end

	data.BA.AA = gameplay.alwaysActive:GetChecked();
	data.BA.EE = gameplay.ensureExpiry:GetChecked();
	data.BA.BC = gameplay.boundToCampaign:GetChecked();
	data.BA.CC = gameplay.cancellable:GetChecked();
	data.BA.WE = gameplay.inspectable:GetChecked();

	if gameplay.hasInterval:GetChecked() then
		data.BA.IV = math.max(gameplay.interval:GetNumber(), 0.1); -- because I say so
	else
		data.BA.IV = nil;
	end

	data.NT = stEtN(strtrim(notes.frame.scroll.text:GetText()));

	storeDataScript();
end

local presetBuffs = {
	{category = ""                 , color = nil      , helpful = true},
	{category = loc.AU_PRESET_CURSE  , color = "9600ff", helpful = false},
	{category = loc.AU_PRESET_DISEASE, color = "966400", helpful = false},
	{category = loc.AU_PRESET_MAGIC  , color = "3296ff", helpful = false},
	{category = loc.AU_PRESET_POISON , color = "009600", helpful = false},
	{category = ""                 , color = "c80000", helpful = false},
};

local presetMenu = {
	{"|cffffffff" .. loc.AU_PRESET_BUFF    .. "|r", 1},
	{"|cff9600ff" .. loc.AU_PRESET_CURSE   .. "|r", 2},
	{"|cff966400" .. loc.AU_PRESET_DISEASE .. "|r", 3},
	{"|cff3296ff" .. loc.AU_PRESET_MAGIC   .. "|r", 4},
	{"|cff009600" .. loc.AU_PRESET_POISON  .. "|r", 5},
	{"|cffc80000" .. loc.AU_PRESET_OTHER   .. "|r", 6},
};

local function applyPreset(presetId)
	display.category:SetText(presetBuffs[presetId].category);
	display.helpful:SetChecked(presetBuffs[presetId].helpful);
	if presetBuffs[presetId].color then
		display.borderPicker.setColor(TRP3_API.CreateColorFromHexString(presetBuffs[presetId].color):GetRGBAsBytes());
	else
		display.borderPicker.setColor(nil);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initAuraEditorNormal(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.aura.normal.load = load;
	toolFrame.aura.normal.saveToDraft = saveToDraft;

	createTabBar();

	display = toolFrame.aura.normal.display;
	gameplay = toolFrame.aura.normal.gameplay;
	notes = toolFrame.aura.normal.notes;

	display.title:SetText(loc.AU_DISPLAY_ATT);

	display.name.title:SetText(loc.AU_FIELD_NAME);
	setTooltipForSameFrame(display.name.help, "RIGHT", 0, 5, loc.AU_FIELD_NAME, loc.AU_FIELD_NAME_TT);

	display.category.title:SetText(loc.AU_FIELD_CATEGORY);
	setTooltipForSameFrame(display.category.help, "RIGHT", 0, 5, loc.AU_FIELD_CATEGORY, loc.AU_FIELD_CATEGORY_TT);

	display.preset:SetText(loc.AU_PRESET);
	display.preset:SetScript("OnClick", function(self)
		TRP3_MenuUtil.CreateContextMenu(self, function(_, description)
			for _, preset in pairs(presetMenu) do
				description:CreateButton(preset[1], applyPreset, preset[2]);
			end
		end);
	end);

	display.description.title:SetText(loc.AU_FIELD_DESCRIPTION);
	setTooltipAll(display.description.dummy, "RIGHT", 0, 5, loc.AU_FIELD_DESCRIPTION, loc.AU_FIELD_DESCRIPTION_TT);

	display.flavor.title:SetText(loc.AU_FIELD_FLAVOR);
	setTooltipAll(display.flavor.dummy, "RIGHT", 0, 5, loc.AU_FIELD_FLAVOR, loc.AU_FIELD_FLAVOR_TT);

	display.overlay.title:SetText(loc.AU_FIELD_OVERLAY);
	setTooltipForSameFrame(display.overlay.help, "RIGHT", 0, 5, loc.AU_FIELD_OVERLAY, loc.AU_FIELD_OVERLAY_TT);

	display.helpful.Text:SetText(loc.AU_FIELD_HELPFUL);
	setTooltipForSameFrame(display.helpful, "RIGHT", 0, 5, loc.AU_FIELD_HELPFUL, loc.AU_FIELD_HELPFUL_TT);

	display.borderPicker.onSelection = function(red, green, blue)
		if red and green and blue then
			display.preview.aura.color = {
				h = TRP3_API.CreateColorFromBytes(red, green, blue):GenerateHexColorOpaque(),
				r = red/255,
				g = green/255,
				b = blue/255,
			};
		else
			display.preview.aura.color = nil;
		end
		display.preview:SetAuraAndShow(display.preview.aura);
	end
	display.borderPicker:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			if IsShiftKeyDown() or (TRP3_API.configuration.getValue("default_color_picker")) then
				TRP3_API.popup.showDefaultColorPicker({self.setColor, self.red, self.green, self.blue});
			else
				TRP3_API.popup.showPopup(TRP3_API.popup.COLORS, {parent = TRP3_ToolFrame}, {self.setColor, self.red, self.green, self.blue});
			end
		elseif button == "RightButton" then
			self.setColor(nil, nil, nil);
		end
	end);
	setTooltipForSameFrame(display.borderPicker, "RIGHT", 0, 5, loc.AU_FIELD_COLOR, loc.AU_FIELD_COLOR_TT .. loc.REG_PLAYER_COLOR_TT);

	display.previewText:SetText(loc.EDITOR_PREVIEW);
	display.previewInfo:SetText(loc.EDITOR_ICON_SELECT);
	display.preview.aura = {
		persistent = {
			expiry = math.huge,
		},
		class = {
			BA = {
			}
		},
	};
	display.preview:SetScript("OnEnter", function(self)
		display.preview.aura.persistent.expiry = time() + (gameplay.hasDuration:GetChecked() and tonumber(gameplay.duration:GetText()) or math.huge);
		display.preview.aura.class.BA.DE = TRP3_API.script.parseArgs(stEtN(strtrim(display.description.scroll.text:GetText())), {});
		display.preview.aura.class.BA.NA = stEtN(strtrim(display.name:GetText()));
		display.preview.aura.class.BA.CA = stEtN(strtrim(display.category:GetText()));
		display.preview.aura.class.BA.FL = stEtN(strtrim(display.flavor.scroll.text:GetText()));
		display.preview.aura.class.BA.CC = gameplay.cancellable:GetChecked();
		TRP3_AuraTooltip:Attach(display.preview);
	end);
	display.preview:SetScript("OnMouseUp", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.ICONS, {parent = self, point = "RIGHT", parentPoint = "LEFT"}, {onIconSelected, nil, nil, display.preview.aura.class.BA.IC});
	end);

	gameplay.title:SetText(loc.AU_GAMEPLAY_ATT);

	gameplay.hasDuration.Text:SetText(loc.AU_FIELD_HAS_DURATION);
	setTooltipForSameFrame(gameplay.hasDuration, "RIGHT", 0, 5, loc.AU_FIELD_HAS_DURATION, loc.AU_FIELD_HAS_DURATION_TT);
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
	end)

	gameplay.duration.title:SetText(loc.AU_FIELD_DURATION);
	setTooltipForSameFrame(gameplay.duration.help, "RIGHT", 0, 5, loc.AU_FIELD_DURATION, loc.AU_FIELD_DURATION_TT);

	gameplay.alwaysActive.Text:SetText(loc.AU_FIELD_ALWAYS_ACTIVE);
	setTooltipForSameFrame(gameplay.alwaysActive, "RIGHT", 0, 5, loc.AU_FIELD_ALWAYS_ACTIVE, loc.AU_FIELD_ALWAYS_ACTIVE_TT);
	gameplay.alwaysActive:SetScript("OnClick", function()
		gameplay.ensureExpiry:SetShown(gameplay.alwaysActive:GetChecked());
	end)

	gameplay.ensureExpiry.Text:SetText(loc.AU_FIELD_ENSURE_EXPIRY);
	setTooltipForSameFrame(gameplay.ensureExpiry, "RIGHT", 0, 5, loc.AU_FIELD_ENSURE_EXPIRY, loc.AU_FIELD_ENSURE_EXPIRY_TT);

	gameplay.boundToCampaign.Text:SetText(loc.AU_FIELD_BOUND_TO_CAMPAIGN);
	setTooltipForSameFrame(gameplay.boundToCampaign, "RIGHT", 0, 5, loc.AU_FIELD_BOUND_TO_CAMPAIGN, loc.AU_FIELD_BOUND_TO_CAMPAIGN_TT);

	gameplay.cancellable.Text:SetText(loc.AU_FIELD_CANCELLABLE);
	setTooltipForSameFrame(gameplay.cancellable, "RIGHT", 0, 5, loc.AU_FIELD_CANCELLABLE, loc.AU_FIELD_CANCELLABLE_TT);

	gameplay.hasInterval.Text:SetText(loc.AU_FIELD_HAS_INTERVAL);
	setTooltipForSameFrame(gameplay.hasInterval, "RIGHT", 0, 5, loc.AU_FIELD_HAS_INTERVAL, loc.AU_FIELD_HAS_INTERVAL_TT);
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
	end)

	gameplay.interval.title:SetText(loc.AU_FIELD_INTERVAL);
	setTooltipForSameFrame(gameplay.interval.help, "RIGHT", 0, 5, loc.AU_FIELD_INTERVAL, loc.AU_FIELD_INTERVAL_TT);

	gameplay.inspectable.Text:SetText(loc.AU_FIELD_INSPECTABLE);
	setTooltipForSameFrame(gameplay.inspectable, "RIGHT", 0, 5, loc.AU_FIELD_INSPECTABLE, loc.AU_FIELD_INSPECTABLE_TT);

	gameplay.text:SetText(loc.AURA_INTRO);

	notes.title:SetText(loc.EDITOR_NOTES);

	-- Workflows links
	linksStructure = {
		{
			text = loc.AU_LINKS_ON_APPLY,
			tt = loc.AU_LINKS_ON_APPLY_TT,
			icon = "Interface\\ICONS\\ability_priest_spiritoftheredeemer",
			field = "OA",
		},
		{
			text = loc.AU_LINKS_ON_TICK,
			tt = loc.AU_LINKS_ON_TICK_TT,
			icon = "Interface\\ICONS\\spell_holy_borrowedtime",
			field = "OT",
		},
		{
			text = loc.AU_LINKS_ON_EXPIRE,
			tt = loc.AU_LINKS_ON_EXPIRE_TT,
			icon = "Interface\\ICONS\\ability_titankeeper_cleansingorb",
			field = "OE",
		},
		{
			text = loc.AU_LINKS_ON_CANCEL,
			tt = loc.AU_LINKS_ON_CANCEL_TT,
			icon = "Interface\\ICONS\\misc_rnrredxbutton",
			field = "OC",
		},
	};

end
