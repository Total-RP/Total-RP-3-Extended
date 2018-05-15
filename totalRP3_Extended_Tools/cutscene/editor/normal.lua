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

local Globals, Events, Utils, EMPTY = TRP3_API.globals, TRP3_API.events, TRP3_API.utils, TRP3_API.globals.empty;
local tostring, tonumber, tinsert, strtrim, pairs, assert, wipe = tostring, tonumber, tinsert, strtrim, pairs, assert, wipe;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;
local TUTORIAL;
local toolFrame, step, editor, refreshStepList, main;

local TABS = {
	MAIN = 1,
	WORKFLOWS = 2,
	EXPERT = 3,
}

local tabGroup, currentTab, linksStructure;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local DEFAULT_BG = "Interface\\DRESSUPFRAME\\DressUpBackground-NightElf1";

local stageAttributeDependecies;

local function onStageAttributesChanged()
	for attr, check in pairs(stageAttributeDependecies) do
		attr:Hide();
		if check:GetChecked() then
			attr:Show()
		end
	end
end

local function refreshConditions()
	for i=1, 5 do
		local line = editor.choicesEditor["line" .. i];
		line.condition:SetText(loc.WO_CONDITION);
		if line.scriptData then
			line.condition:SetText(loc.WO_CONDITION .. " " .. Utils.str.texture("Interface\\GossipFrame\\DailyQuestIcon"));
		end
	end
end

local function editStep(stepID)
	editor.imageEditor:Hide();
	editor.title:SetText(("%s: %s"):format(loc.DI_STEP_EDIT, stepID));
	local data = toolFrame.specificDraft.DS[stepID];

	-- Load
	editor.text.scroll.text:SetText(data.TX or "");
	editor.next:SetText(data.N or "");
	editor.loot:SetChecked(data.LO or false);
	editor.endpoint:SetChecked(data.EP or false);

	editor.direction:SetChecked(data.ND ~= nil);
	editor.directionValue:SetSelectedValue(data.ND or "NONE");
	editor.name:SetChecked(data.NA ~= nil);
	editor.nameValue:SetText(data.NA or "${trp:player:full}");
	editor.leftUnit:SetChecked(data.LU ~= nil);
	editor.leftUnitValue:SetText(data.LU or "player");
	editor.rightUnit:SetChecked(data.RU ~= nil);
	editor.rightUnitValue:SetText(data.RU or "target");
	editor.background:SetChecked(data.BG ~= nil);
	editor.backgroundValue:SetText(data.BG or DEFAULT_BG);
	editor.image:SetChecked(data.IM ~= nil);
	editor.imageValue:SetText(data.IM and data.IM.UR or "");
	editor.imageEditor.width:SetText(data.IM and data.IM.WI or "256");
	editor.imageEditor.height:SetText(data.IM and data.IM.HE or "256");
	editor.imageEditor.top:SetText(data.IM and data.IM.TO or "0");
	editor.imageEditor.bottom:SetText(data.IM and data.IM.BO or "1");
	editor.imageEditor.left:SetText(data.IM and data.IM.LE or "0");
	editor.imageEditor.right:SetText(data.IM and data.IM.RI or "1");

	for i=1, 5 do
		local line = editor.choicesEditor["line" .. i];
		line.text:SetText("");
		line.step:SetText("");
		line.scriptData = nil;
	end

	for index, choice in pairs(data.CH or EMPTY) do
		local line = editor.choicesEditor["line" .. index];
		line.text:SetText(choice.TX or "");
		line.step:SetText(choice.N or "");
		line.scriptData = choice.C;
	end

	TRP3_ScriptEditorNormal.safeLoadList(editor.workflow, editor.workflowIDs, data.WO or "");

	editor.stepID = stepID;

	refreshStepList();
	refreshConditions();
	onStageAttributesChanged();
end

local function decorateStepLine(line, stepID)
	local data = toolFrame.specificDraft;
	local stepData = data.DS[stepID];

	line.lock = false;
	line.Highlight:Hide();
	if stepID == editor.stepID then
		line.lock = true;
		line.Highlight:Show();
	end

	line.moveup:Show();
	line.movedown:Show();
	if stepID == 1 then
		line.moveup:Hide();
	end
	if stepID == #data.DS then
		line.movedown:Hide();
	end

	local tooltip = "\"" .. (stepData.TX or "") .. "\"";
	local icon = "Interface\\GossipFrame\\PetitionGossipIcon";
	if stepData.EP then
		icon = "Interface\\GossipFrame\\AvailableLegendaryQuestIcon";
		tooltip = tooltip .. "\n\n" .. Utils.str.texture(icon) .. "|cff00ff00 " .. loc.DI_END;
	elseif stepData.CH then
		icon = "Interface\\GossipFrame\\ActiveLegendaryQuestIcon";
		tooltip = tooltip .. "\n\n" .. Utils.str.texture(icon) .. "|cff00ff00 " .. loc.DI_CHOICES;
	end

	setTooltipForSameFrame(line.click, "RIGHT", 0, 5, loc.DI_STEP .. " " .. stepID,
		tooltip .. ("\n\n|cffffff00%s: |cff00ff00%s\n"):format(loc.CM_CLICK, loc.CM_EDIT) .. ("|cffffff00%s: |cff00ff00%s"):format(loc.CM_R_CLICK, REMOVE));

	line.text:SetText(Utils.str.texture(icon) .. " |cff00ff00" .. stepID .. ")|r " .. (stepData.TX or ""));
	line.click.stepID = stepID;
end

function refreshStepList()
	local data = toolFrame.specificDraft;
	TRP3_API.ui.list.initList(step.list, data.DS, step.list.slider);
end

local function addStep()
	local data = toolFrame.specificDraft;
	tinsert(data.DS, {
		TX = "Text."
	});
	editStep(#data.DS);
end

local function setAttribute(data, key, checked, value)
	if checked then
		data[key] = value;
	else
		data[key] = nil;
	end
end

local function saveStep(stepID)
	local data = toolFrame.specificDraft.DS[stepID];

	data.TX = stEtN(strtrim(editor.text.scroll.text:GetText()));
	data.LO = editor.loot:GetChecked();
	data.EP = editor.endpoint:GetChecked();
	data.N = tonumber(editor.next:GetText());
	setAttribute(data, "ND", editor.direction:GetChecked(), editor.directionValue:GetSelectedValue());
	setAttribute(data, "NA", editor.name:GetChecked(), editor.nameValue:GetText());
	setAttribute(data, "LU", editor.leftUnit:GetChecked(), editor.leftUnitValue:GetText());
	setAttribute(data, "RU", editor.rightUnit:GetChecked(), editor.rightUnitValue:GetText());
	setAttribute(data, "BG", editor.background:GetChecked(), editor.backgroundValue:GetText());
	if editor.image:GetChecked() then
		data.IM = {
			UR = editor.imageValue:GetText(),
			TO = tonumber(editor.imageEditor.top:GetText()),
			BO = tonumber(editor.imageEditor.bottom:GetText()),
			LE = tonumber(editor.imageEditor.left:GetText()),
			RI = tonumber(editor.imageEditor.right:GetText()),
			WI = tonumber(editor.imageEditor.width:GetText()),
			HE = tonumber(editor.imageEditor.height:GetText()),
		};
	else
		data.IM = nil;
	end
	data.WO = stEtN(editor.workflow:GetSelectedValue());

	-- Choices
	data.CH = nil;
	local choices = {};
	for i=1, 5 do
		local line = editor.choicesEditor["line" .. i];
		local text = stEtN(strtrim(line.text:GetText()));
		if text then
			tinsert(choices, {TX = text, N = tonumber(line.step:GetText()), C = line.scriptData});
		end
	end
	if #choices > 0 then
		data.CH = choices;
	end

	refreshStepList();
end

local function removeStep(index)
	local data = toolFrame.specificDraft.DS;

	if #data > 1 and data[index] then
		tremove(data, index);
		if editor.stepID == index then
			editStep(1);
		end
	end

	refreshStepList();
end

local function onMoveUpClick(self)
	assert(self:GetParent().click.stepID, "No stepID in frame");
	local data = toolFrame.specificDraft.DS;
	local index = self:GetParent().click.stepID;
	if data[index] and data[index - 1] then
		local previous = data[index - 1];
		data[index - 1] = data[index];
		data[index] = previous;
		if editor.stepID == index then
			editStep(index - 1);
		elseif editor.stepID == index - 1 then
			editStep(index);
		end
	end

	refreshStepList();
end

local function onMoveDownClick(self)
	assert(self:GetParent().click.stepID, "No stepID in frame");
	local data = toolFrame.specificDraft.DS;
	local index = self:GetParent().click.stepID;
	if data[index] and data[index + 1] then
		local previous = data[index + 1];
		data[index + 1] = data[index];
		data[index] = previous;
		if editor.stepID == index then
			editStep(index + 1);
		elseif editor.stepID == index + 1 then
			editStep(index);
		end
	end

	refreshStepList();
end

local function configureCondition(line)
	local condition = line.scriptData;
	if not condition then
		condition = {
			{ { i = "unit_name", a = {"target"} }, "==", { v = "Elsa" } }
		};
	end
	editor.choicesEditor:Hide();
	toolFrame.cutscene.normal.overlay:Show();
	toolFrame.cutscene.normal.overlay:SetFrameLevel(toolFrame.cutscene.normal:GetFrameLevel() + 20);
	TRP3_ConditionEditor:SetParent(toolFrame.cutscene.normal.overlay);
	TRP3_ConditionEditor:ClearAllPoints();
	TRP3_ConditionEditor:SetPoint("CENTER", 0, 0);
	TRP3_ConditionEditor:SetFrameLevel(toolFrame.cutscene.normal.overlay:GetFrameLevel() + 20);
	TRP3_ConditionEditor:Show();
	TRP3_ConditionEditor.load(condition);
	TRP3_ConditionEditor:SetScript("OnHide", function() toolFrame.cutscene.normal.overlay:Hide() end);
	TRP3_ConditionEditor.confirm:SetScript("OnClick", function()
		if not line.scriptData then
			line.scriptData = {};
		end
		TRP3_ConditionEditor.save(line.scriptData);
		TRP3_ConditionEditor:Hide();
		editor.choicesEditor:Show();
		refreshConditions();
	end);
	TRP3_ConditionEditor.close:SetScript("OnClick", function()
		TRP3_ConditionEditor:Hide();
		editor.choicesEditor:Show();
	end);
	TRP3_ConditionEditor.confirm:SetText(loc.EDITOR_CONFIRM);
	TRP3_ConditionEditor.title:SetText(loc.DI_CHOICE_CONDI);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Script tab
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadDataScript()
	-- Load workflows
	if not toolFrame.specificDraft.SC then
		toolFrame.specificDraft.SC = {};
	end
	TRP3_ScriptEditorNormal.loadList(TRP3_DB.types.DIALOG);
end

local function storeDataScript()
	-- TODO: compute all workflow order
	for workflowID, workflow in pairs(toolFrame.specificDraft.SC) do
		TRP3_ScriptEditorNormal.linkElements(workflow);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Load ans save
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function loadWorkflows()
	editor.workflowIDs = {};
	editor.workflowListStructure = TRP3_ScriptEditorNormal.reloadWorkflowlist(editor.workflowIDs);
	TRP3_API.ui.listbox.setupListBox(editor.workflow, editor.workflowListStructure, nil, nil, 300, true);
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
	if not data.DS then
		data.DS = {};
	end

	main.distance:SetText(data.BA.DI or "0");

	loadDataScript();
	loadWorkflows();
	TRP3_LinksEditor.load(linksStructure);
	editStep(1);
	editor.choicesEditor:Hide();

	tabGroup:SelectTab(TRP3_API.extended.tools.getSaveTab(toolFrame.fullClassID, tabGroup:Size()));
end

local function saveToDraft()
	assert(toolFrame.specificDraft, "specificDraft is nil");

	editor.choicesEditor:Hide();
	local data = toolFrame.specificDraft;
	data.BA.DI = tonumber(strtrim(main.distance:GetText())) or 0;
	saveStep(editor.stepID);

	storeDataScript();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onTabChanged(tabWidget, tab)
	assert(toolFrame.fullClassID, "fullClassID is nil");

	-- Hide all
	currentTab = tab or TABS.MAIN;
	step:Hide();
	editor:Hide();
	main:Hide();
	TRP3_ScriptEditorNormal:Hide();
	TRP3_LinksEditor:Hide();
	TRP3_ExtendedTutorial.loadStructure(nil);

	-- Show tab
	if currentTab == TABS.MAIN then
		step:Show();
		editor:Show();
		main:Show();
		loadWorkflows();
		TRP3_ExtendedTutorial.loadStructure(TUTORIAL);
	elseif currentTab == TABS.WORKFLOWS then
		TRP3_ScriptEditorNormal:SetParent(toolFrame.cutscene.normal);
		TRP3_ScriptEditorNormal:SetAllPoints();
		TRP3_ScriptEditorNormal:Show();
	elseif currentTab == TABS.EXPERT then
		TRP3_LinksEditor:SetParent(toolFrame.cutscene.normal);
		TRP3_LinksEditor:SetAllPoints();
		TRP3_LinksEditor:Show();
		TRP3_LinksEditor.load(linksStructure);
	end

	TRP3_API.extended.tools.saveTab(toolFrame.fullClassID, currentTab);
end

local function createTabBar()
	local frame = CreateFrame("Frame", "TRP3_ToolFrameCutsceneNormalTabPanel", toolFrame.cutscene.normal);
	frame:SetSize(400, 30);
	frame:SetPoint("BOTTOMLEFT", frame:GetParent(), "TOPLEFT", 15, 0);

	tabGroup = TRP3_API.ui.frame.createTabPanel(frame,
		{
			{ loc.EDITOR_MAIN, TABS.MAIN, 150 },
			{ loc.WO_WORKFLOW, TABS.WORKFLOWS, 150 },
			{ loc.WO_LINKS, TABS.EXPERT, 150 },
		},
		onTabChanged
	);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initCutsceneEditorNormal(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.cutscene.normal.load = load;
	toolFrame.cutscene.normal.saveToDraft = saveToDraft;

	createTabBar();

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Main
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	main = toolFrame.cutscene.normal.main;
	main.title:SetText(loc.TYPE_DIALOG);

	-- Name
	main.distance.title:SetText(loc.DI_DISTANCE);
	setTooltipForSameFrame(main.distance.help, "RIGHT", 0, 5, loc.DI_DISTANCE, loc.DI_DISTANCE_TT);

	main.preview:SetText(loc.EDITOR_PREVIEW);
	main.preview:SetScript("OnClick", function()
		saveToDraft();
		TRP3_API.extended.dialog.startDialog(nil, toolFrame.specificDraft);
	end);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- List
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	step = toolFrame.cutscene.normal.step;
	step.title:SetText(loc.DI_STEPS);

	-- List
	step.list.widgetTab = {};
	for i=1, 5 do
		local line = step.list["line" .. i];
		tinsert(step.list.widgetTab, line);
		line.click:SetScript("OnClick", function(self, button)
			if button == "RightButton" then
				removeStep(self.stepID);
			else
				saveStep(editor.stepID);
				editStep(self.stepID);
			end
		end);
		line.click:SetScript("OnEnter", function(self)
			TRP3_RefreshTooltipForFrame(self);
			self:GetParent().Highlight:Show();
		end);
		line.click:SetScript("OnLeave", function(self)
			TRP3_MainTooltip:Hide();
			if not self:GetParent().lock then
				self:GetParent().Highlight:Hide();
			end
		end);
		line.click:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		setTooltipForSameFrame(line.click, "RIGHT", 0, 5, loc.DI_STEP,
							   ("|cffffff00%s: |cff00ff00%s\n"):format(loc.CM_CLICK, loc.CM_EDIT) .. ("|cffffff00%s: |cff00ff00%s"):format(loc.CM_R_CLICK, REMOVE));

		-- Up/down
		line.movedown:SetFrameLevel(line.click:GetFrameLevel() + 10);
		line.moveup:SetFrameLevel(line.click:GetFrameLevel() + 10);
		setTooltipAll(line.moveup, "TOP", 0, 0, loc.CM_MOVE_UP);
		setTooltipAll(line.movedown, "TOP", 0, 0, loc.CM_MOVE_DOWN);
		line.moveup:SetScript("OnClick", onMoveUpClick);
		line.movedown:SetScript("OnClick", onMoveDownClick);
	end
	step.list.decorate = decorateStepLine;
	TRP3_API.ui.list.handleMouseWheel(step.list, step.list.slider);
	step.list.slider:SetValue(0);
	step.list.add:SetText(loc.DI_STEP_ADD);
	step.list.add:SetScript("OnClick", function() saveStep(editor.stepID); addStep(); end);

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Editor
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	editor = toolFrame.cutscene.normal.editor;

	-- Text
	editor.text.title:SetText(loc.DI_STEP_TEXT);
	editor.attributes:SetText(loc.DI_ATTRIBUTE);

	-- Force loot
	editor.loot.Text:SetText(loc.DI_LOOT);
	setTooltipForSameFrame(editor.loot, "RIGHT", 0, 5, loc.DI_LOOT, loc.DI_LOOT_TT);

	-- Direction
	editor.direction.section:SetText(loc.DI_DIALOG);
	editor.direction.Text:SetText(loc.DI_NAME_DIRECTION);
	setTooltipForSameFrame(editor.direction, "RIGHT", 0, 5, loc.DI_NAME_DIRECTION, loc.DI_NAME_DIRECTION_TT .. "\n\n|cffff9900" .. loc.DI_ATTR_TT);
	TRP3_API.ui.listbox.setupListBox(editor.directionValue, {
		{loc.DI_NAME_DIRECTION},
		{loc.CM_LEFT, "LEFT"},
		{loc.CM_RIGHT, "RIGHT"},
		{loc.REG_RELATION_NONE, "NONE"}
	}, nil, nil, 195, true);

	-- Name
	editor.name.Text:SetText(loc.DI_NAME);
	setTooltipForSameFrame(editor.name, "RIGHT", 0, 5, loc.DI_NAME, loc.DI_NAME_TT .. "\n\n|cffff9900" .. loc.DI_ATTR_TT);

	-- Background
	editor.background.section:SetText(loc.DI_FRAME);
	editor.background.Text:SetText(loc.DI_BKG);
	setTooltipForSameFrame(editor.background, "RIGHT", 0, 5, loc.DI_BKG, loc.DI_BKG_TT .. "\n\n|cffff9900" .. loc.DI_ATTR_TT);

	-- Image
	editor.image.Text:SetText(loc.DI_IMAGE);
	editor.imageMore:SetText(loc.EDITOR_MORE);
	editor.imageMore:SetScript("OnClick", function()
		if not editor.imageEditor:IsVisible() then
			TRP3_API.ui.frame.configureHoverFrame(editor.imageEditor, editor.imageMore, "RIGHT", -10, 0);
		else
			editor.imageEditor:Hide();
		end
	end);
	setTooltipForSameFrame(editor.image, "RIGHT", 0, 5, loc.DI_IMAGE, loc.DI_IMAGE_TT .. "\n\n|cffff9900" .. loc.DI_ATTR_TT);
	editor.imageEditor.width.title:SetText(loc.EDITOR_WIDTH);
	editor.imageEditor.height.title:SetText(loc.EDITOR_HEIGHT);
	editor.imageEditor.top.title:SetText(loc.EDITOR_TOP);
	editor.imageEditor.bottom.title:SetText(loc.EDITOR_BOTTOM);
	editor.imageEditor.left.title:SetText(loc.CM_LEFT);
	editor.imageEditor.right.title:SetText(loc.CM_RIGHT);

	-- Left unit
	editor.leftUnit.section:SetText(loc.DI_MODELS);
	editor.leftUnit.Text:SetText(loc.DI_LEFT_UNIT);
	setTooltipForSameFrame(editor.leftUnit, "RIGHT", 0, 5, loc.DI_LEFT_UNIT, loc.DI_UNIT_TT .. "\n\n|cffff9900" .. loc.DI_ATTR_TT);

	editor.getLeftTarget:SetText(loc.DI_GET_ID);
	editor.getLeftTarget:SetScript("OnClick", function()
		if Utils.str.getUnitNPCID("target") then
			editor.leftUnitValue:SetText(Utils.str.getUnitNPCID("target"));
		end
	end);
	setTooltipForSameFrame(editor.getLeftTarget, "RIGHT", 0, 5, loc.DI_GET_ID, loc.DI_GET_ID_TT);

	-- Right unit
	editor.rightUnit.Text:SetText(loc.DI_RIGHT_UNIT);
	setTooltipForSameFrame(editor.rightUnit, "RIGHT", 0, 5, loc.DI_RIGHT_UNIT, loc.DI_UNIT_TT .. "\n\n|cffff9900" .. loc.DI_ATTR_TT);

	editor.getRightTarget:SetText(loc.DI_GET_ID);
	editor.getRightTarget:SetScript("OnClick", function()
		if Utils.str.getUnitNPCID("target") then
			editor.rightUnitValue:SetText(Utils.str.getUnitNPCID("target"));
		end
	end);
	setTooltipForSameFrame(editor.getRightTarget, "RIGHT", 0, 5, loc.DI_GET_ID, loc.DI_GET_ID_TT);

	-- End point
	editor.endpoint.Text:SetText(loc.DI_END);
	setTooltipForSameFrame(editor.endpoint, "RIGHT", 0, 5, loc.DI_END, loc.DI_END_TT);

	-- Choices
	editor.choices:SetText(loc.DI_CHOICES);
	setTooltipForSameFrame(editor.choices, "TOP", 0, 5, loc.DI_CHOICES, loc.DI_CHOICES_TT);
	editor.choices:SetScript("OnClick", function()
		if not editor.choicesEditor:IsVisible() then
			TRP3_API.ui.frame.configureHoverFrame(editor.choicesEditor, editor.choices, "TOP", 0, 0);
		else
			editor.choicesEditor:Hide();
		end
	end);
	editor.choicesEditor.title:SetText(loc.DI_CHOICES);
	for i=1, 5 do
		local line = editor.choicesEditor["line" .. i];
		line.text.title:SetText(loc.DI_CHOICE .. " " .. i);
		setTooltipForSameFrame(line.text.help, "RIGHT", 0, 5, loc.DI_CHOICE .. " " .. i, loc.DI_CHOICE_TT);
		line.step.title:SetText(loc.DI_CHOICE_STEP);
		setTooltipForSameFrame(line.step.help, "RIGHT", 0, 5, loc.DI_CHOICE_STEP, loc.DI_CHOICE_STEP_TT);
		setTooltipForSameFrame(line.condition, "RIGHT", 0, 5, loc.WO_CONDITION, loc.DI_CONDI_TT);
		line.condition:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		line.condition:SetScript("OnClick", function(self, button)
			if button == "LeftButton" then
				configureCondition(self:GetParent());
			else
				self:GetParent().scriptData = nil;
				refreshConditions();
			end
		end);
		line.index = i;
	end

	-- Checks
	local checks = {editor.direction, editor.name, editor.background, editor.image, editor.leftUnit, editor.rightUnit};
	for _, check in pairs(checks) do
		check:SetScript("OnClick", onStageAttributesChanged);
	end
	stageAttributeDependecies = {
		[editor.directionValue] = editor.direction,
		[editor.nameValue] = editor.name,
		[editor.backgroundValue] = editor.background,
		[editor.imageValue] = editor.image,
		[editor.imageMore] = editor.image,
		[editor.leftUnitValue] = editor.leftUnit,
		[editor.rightUnitValue] = editor.rightUnit,
		[editor.getLeftTarget] = editor.leftUnit,
		[editor.getRightTarget] = editor.rightUnit
	}

	-- Next
	editor.next.title:SetText(loc.DI_NEXT);
	setTooltipForSameFrame(editor.next.help, "RIGHT", 0, 5, loc.DI_NEXT, loc.DI_NEXT_TT);

	-- tutorial
	TUTORIAL = {
		{
			box = toolFrame, title = "TYPE_DIALOG", text = "TU_CS_1_TEXT",
			arrow = "DOWN", x = 0, y = 100, anchor = "CENTER", textWidth = 400,
		},
		{
			box = step, title = "DI_STEPS", text = "TU_CS_2_TEXT",
			arrow = "RIGHT", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
		},
		{
			box = editor, title = "DI_STEP_TEXT", text = "TU_CS_3_TEXT",
			arrow = "LEFT", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
		},
		{
			box = editor.workflow, title = "TU_CS_4", text = "TU_CS_4_TEXT",
			arrow = "BOTTOM", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
		},
		{
			box = main, title = "TU_CS_5", text = "TU_CS_5_TEXT",
			arrow = "BOTTOM", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
		},
	}

	-- Workflows links
	linksStructure = {
		{
			text = loc.DI_LINKS_ONSTART,
			tt = loc.DI_LINKS_ONSTART_TT,
			icon = "Interface\\ICONS\\ability_priest_heavanlyvoice",
			field = "OS",
		},
		{
			text = loc.DI_LINKS_ONEND,
			tt = loc.DI_LINKS_ONEND_TT,
			icon = "Interface\\ICONS\\achievement_BG_captureflag_EOS",
			field = "OE",
		}
	}
end