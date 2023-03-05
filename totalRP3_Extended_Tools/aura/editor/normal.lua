
local Utils = TRP3_API.utils;
local pairs, max, tonumber, tremove, strtrim, assert, wipe = pairs, math.max, tonumber, tremove, strtrim, assert, wipe;
local stEtN = Utils.str.emptyToNil;
local L = TRP3_API.loc;
local setTooltipForSameFrame, setTooltipAll = TRP3_API.ui.tooltip.setTooltipForSameFrame, TRP3_API.ui.tooltip.setTooltipAll;
local toolFrame, main, pages, params, manager, linksStructure, display, gameplay, notes;

local TABS = {
	MAIN = 1,
	WORKFLOWS = 2,
	INNER = 3,
	EXPERT = 4,
}

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
	elseif currentTab == TABS.EXPERT then
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
			{ L.EDITOR_MAIN, TABS.MAIN, 150 },
			{ L.WO_WORKFLOW, TABS.WORKFLOWS, 150 },
			{ L.IN_INNER, TABS.INNER, 150 },
			{ L.WO_LINKS, TABS.EXPERT, 150 },
		},
		onTabChanged
	);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Load ans save
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDataInner()
	-- Load inners
	if not toolFrame.specificDraft.IN then
		toolFrame.specificDraft.IN = {};
	end
	TRP3_InnerObjectEditor.refresh();
end

local function onIconSelected(icon)
	display.preview.Icon:SetTexture("Interface\\ICONS\\" .. (icon or "TEMP"));
	display.preview.selectedIcon = icon;
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
	
	display.name:SetText(data.BA.NA or "")
	display.description.scroll.text:SetText(data.BA.DE or "")
	display.flavor.scroll.text:SetText(data.BA.FL or "")
	display.overlay:SetText(data.BA.OV or "")
	display.helpful:SetChecked(data.BA.HE or false)
	onIconSelected(data.BA.IC)
	
	local hasDuration = (data.BA.DU or math.huge) < math.huge
	gameplay.hasDuration:SetChecked(hasDuration)
	gameplay.duration:SetShown(hasDuration)
	gameplay.duration:SetText(data.BA.DU or "300")
	
	gameplay.alwaysActive:SetChecked(data.BA.AA or false)
	gameplay.ensureExpiry:SetChecked(data.BA.EE or false)
	gameplay.ensureExpiry:SetShown(data.BA.AA)
	
	gameplay.boundToCampaign:SetChecked(data.BA.BC or false)
	
	gameplay.cancellable:SetChecked(data.BA.CC or false)
	
	local hasInterval = (data.BA.IV or math.huge) < math.huge
	gameplay.hasInterval:SetChecked(hasInterval)
	gameplay.interval:SetShown(hasInterval)
	gameplay.interval:SetText(data.BA.IV or "10")
	gameplay.inspectable:SetChecked(data.BA.WE or false)
	
	notes.frame.scroll.text:SetText(data.NT or "");

	loadDataInner();

	loadDataScript();
	TRP3_LinksEditor.load(linksStructure);

	tabGroup:SelectTab(TRP3_API.extended.tools.getSaveTab(toolFrame.fullClassID, tabGroup:Size()));
end

local function saveToDraft()
	assert(toolFrame.specificDraft, "specificDraft is nil");

	local data = toolFrame.specificDraft
	data.BA.NA = stEtN(strtrim(display.name:GetText()))
	data.BA.DE = stEtN(strtrim(display.description.scroll.text:GetText()))
	data.BA.FL = stEtN(strtrim(display.flavor.scroll.text:GetText()))
	data.BA.OV = stEtN(strtrim(display.overlay:GetText()))
	data.BA.HE = display.helpful:GetChecked()
	data.BA.IC = display.preview.selectedIcon;
	
	if gameplay.hasDuration:GetChecked() then
		data.BA.DU = gameplay.duration:GetNumber()
		if data.BA.DU <= 0 then
			data.BA.DU = nil
		end
	else
		data.BA.DU = nil
	end
	
	data.BA.AA = gameplay.alwaysActive:GetChecked()
	data.BA.EE = gameplay.ensureExpiry:GetChecked()
	data.BA.BC = gameplay.boundToCampaign:GetChecked()
	data.BA.CC = gameplay.cancellable:GetChecked()
	data.BA.WE = gameplay.inspectable:GetChecked()
	
	if gameplay.hasInterval:GetChecked() then
		data.BA.IV = math.max(gameplay.interval:GetNumber(), 0.1) -- because I say so
	else
		data.BA.IV = nil
	end
	
	data.NT = stEtN(strtrim(notes.frame.scroll.text:GetText()));

	storeDataScript();
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

	display.title:SetText(L.AU_DISPLAY_ATT);
	
	display.name.title:SetText(L.AU_FIELD_NAME);
	setTooltipForSameFrame(display.name.help, "RIGHT", 0, 5, L.AU_FIELD_NAME, L.AU_FIELD_NAME_TT);

	display.description.title:SetText(L.AU_FIELD_DESCRIPTION);
	setTooltipAll(display.description.dummy, "RIGHT", 0, 5, L.AU_FIELD_DESCRIPTION, L.AU_FIELD_DESCRIPTION_TT);

	display.flavor.title:SetText(L.AU_FIELD_FLAVOR);
	setTooltipAll(display.flavor.dummy, "RIGHT", 0, 5, L.AU_FIELD_FLAVOR, L.AU_FIELD_FLAVOR_TT);

	display.overlay.title:SetText(L.AU_FIELD_OVERLAY);
	setTooltipForSameFrame(display.overlay.help, "RIGHT", 0, 5, L.AU_FIELD_OVERLAY, L.AU_FIELD_OVERLAY_TT);
	
	display.helpful.Text:SetText(L.AU_FIELD_HELPFUL);
	setTooltipForSameFrame(display.helpful, "RIGHT", 0, 5, L.AU_FIELD_HELPFUL, L.AU_FIELD_HELPFUL_TT);

	display.preview.Name:SetText(L.EDITOR_PREVIEW);
	display.preview.InfoText:SetText(L.EDITOR_ICON_SELECT);
	display.preview:SetScript("OnEnter", function(self)
		if display.preview.aura then
			wipe(display.preview.aura)
		end
		display.preview.aura = {
			persistent = {
				expiry = time() + (gameplay.hasDuration:GetChecked() and tonumber(gameplay.duration:GetText()) or math.huge)
			},
			class = {
				BA = {
					DE = TRP3_API.script.parseArgs(stEtN(strtrim(display.description.scroll.text:GetText())), {}),
					NA = stEtN(strtrim(display.name:GetText())),
					FL = stEtN(strtrim(display.flavor.scroll.text:GetText())),
					CC = gameplay.cancellable:GetChecked()
				}
			}
		}
		TRP3_API.extended.auras.showTooltip(display.preview)
	end);
	display.preview:SetScript("OnLeave", function(self)
		TRP3_API.extended.auras.hideTooltip()
	end);
	display.preview:SetScript("OnClick", function(self)
		TRP3_API.popup.showPopup(TRP3_API.popup.ICONS, {parent = self, point = "RIGHT", parentPoint = "LEFT"}, {onIconSelected});
	end);


	gameplay.title:SetText(L.AU_GAMEPLAY_ATT);

	gameplay.hasDuration.Text:SetText(L.AU_FIELD_HAS_DURATION);
	setTooltipForSameFrame(gameplay.hasDuration, "RIGHT", 0, 5, L.AU_FIELD_HAS_DURATION, L.AU_FIELD_HAS_DURATION_TT);
	gameplay.hasDuration:SetScript("OnClick", function()
		if gameplay.hasDuration:GetChecked() then
			local currDuration = tonumber(gameplay.duration:GetText())
			if not currDuration or currDuration >= math.huge or currDuration <= 0 then
				gameplay.duration:SetText("300")
			end
			gameplay.duration:Show()
		else
			gameplay.duration:Hide()
		end
	end)

	gameplay.duration.title:SetText(L.AU_FIELD_DURATION);
	setTooltipForSameFrame(gameplay.duration.help, "RIGHT", 0, 5, L.AU_FIELD_DURATION, L.AU_FIELD_DURATION_TT);

	gameplay.alwaysActive.Text:SetText(L.AU_FIELD_ALWAYS_ACTIVE);
	setTooltipForSameFrame(gameplay.alwaysActive, "RIGHT", 0, 5, L.AU_FIELD_ALWAYS_ACTIVE, L.AU_FIELD_ALWAYS_ACTIVE_TT);
	gameplay.alwaysActive:SetScript("OnClick", function()
		gameplay.ensureExpiry:SetShown(gameplay.alwaysActive:GetChecked())
	end)
	
	gameplay.ensureExpiry.Text:SetText(L.AU_FIELD_ENSURE_EXPIRY);
	setTooltipForSameFrame(gameplay.ensureExpiry, "RIGHT", 0, 5, L.AU_FIELD_ENSURE_EXPIRY, L.AU_FIELD_ENSURE_EXPIRY_TT);
	
	gameplay.boundToCampaign.Text:SetText(L.AU_FIELD_BOUND_TO_CAMPAIGN);
	setTooltipForSameFrame(gameplay.boundToCampaign, "RIGHT", 0, 5, L.AU_FIELD_BOUND_TO_CAMPAIGN, L.AU_FIELD_BOUND_TO_CAMPAIGN_TT);
	
	gameplay.cancellable.Text:SetText(L.AU_FIELD_CANCELLABLE);
	setTooltipForSameFrame(gameplay.cancellable, "RIGHT", 0, 5, L.AU_FIELD_CANCELLABLE, L.AU_FIELD_CANCELLABLE_TT);

	gameplay.hasInterval.Text:SetText(L.AU_FIELD_HAS_INTERVAL);
	setTooltipForSameFrame(gameplay.hasInterval, "RIGHT", 0, 5, L.AU_FIELD_HAS_INTERVAL, L.AU_FIELD_HAS_INTERVAL_TT);
	gameplay.hasInterval:SetScript("OnClick", function()
		if gameplay.hasInterval:GetChecked() then
			local currInterval = tonumber(gameplay.interval:GetText())
			if not currInterval or currInterval >= math.huge or currInterval <= 0 then
				gameplay.interval:SetText("10")
			end
			gameplay.interval:Show()
		else
			gameplay.interval:Hide()
		end
	end)

	gameplay.interval.title:SetText(L.AU_FIELD_INTERVAL);
	setTooltipForSameFrame(gameplay.interval.help, "RIGHT", 0, 5, L.AU_FIELD_INTERVAL, L.AU_FIELD_INTERVAL_TT);

	gameplay.inspectable.Text:SetText(L.AU_FIELD_INSPECTABLE);
	setTooltipForSameFrame(gameplay.inspectable, "RIGHT", 0, 5, L.AU_FIELD_INSPECTABLE, L.AU_FIELD_INSPECTABLE_TT);

	gameplay.text:SetText(L.AURA_INTRO);

	notes.title:SetText(L.EDITOR_NOTES);

	-- Workflows links
	linksStructure = {
		{
			text = L.AU_LINKS_ON_APPLY,
			tt = L.AU_LINKS_ON_APPLY_TT,
			icon = "Interface\\ICONS\\ability_priest_spiritoftheredeemer",
			field = "OA",
		},
		{
			text = L.AU_LINKS_ON_TICK,
			tt = L.AU_LINKS_ON_TICK_TT,
			icon = "Interface\\ICONS\\spell_holy_borrowedtime",
			field = "OT",
		},
		{
			text = L.AU_LINKS_ON_EXPIRE,
			tt = L.AU_LINKS_ON_EXPIRE_TT,
			icon = "Interface\\ICONS\\ability_titankeeper_cleansingorb",
			field = "OE",
		},
		{
			text = L.AU_LINKS_ON_CANCEL,
			tt = L.AU_LINKS_ON_CANCEL_TT,
			icon = "Interface\\ICONS\\misc_rnrredxbutton",
			field = "OC",
		},
	}

end
