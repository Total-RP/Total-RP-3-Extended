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
local IsControlKeyDown = IsControlKeyDown;
local tostring, tremove, tinsert, strtrim, pairs, assert, wipe = tostring, tremove, tinsert, strtrim, pairs, assert, wipe;
local tsize = Utils.table.size;
local getFullID, getClass = TRP3_API.extended.getFullID, TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;
local color = Utils.str.color;
local toolFrame;

local editor = TRP3_ActionsEditorFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LOGIC
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function decorateActionLine(line, actionIndex)
	local data = toolFrame.specificDraft;
	local actionData = data.AC[actionIndex];

	TRP3_API.ui.frame.setupIconButton(line.Icon, TRP3_API.quest.getActionTypeIcon(actionData.TY) or Globals.icons.default);
	line.Name:SetText(TRP3_API.quest.getActionTypeLocale(actionData.TY or UNKNOWN));
	if actionData.CO then
		line.Description:SetText("|cff00ff00" .. loc.CA_ACTIONS_COND_ON);
	else
		line.Description:SetText("|cffffff00" .. loc.CA_ACTIONS_COND_OFF);
	end
	line.ID:SetText("|cff00ff00" .. (stEtN(actionData.SC) or "|cffff9900" .. loc.WO_LINKS_NO_LINKS));
	line.click.actionIndex = actionIndex;
end

local function refreshList()
	local data = toolFrame.specificDraft;
	TRP3_API.ui.list.initList(editor.list, data.AC, editor.list.slider);
	editor.list.empty:Hide();
	if tsize(data.AC) == 0 then
		editor.list.empty:Show();
	end
end

function editor.load()
	local data = toolFrame.specificDraft;
	if not data.AC then
		data.AC = {};
	end

	refreshList();
end

local function removeAction(index)
	TRP3_API.popup.showConfirmPopup(loc.CA_ACTION_REMOVE, function()
		if toolFrame.specificDraft.AC[index] then
			wipe(toolFrame.specificDraft.AC[index]);
			tremove(toolFrame.specificDraft.AC, index);
		end
		refreshList();
		editor.editor:Hide();
	end);
end

local ACTION_LIST_WIDTH = 250;

local function reloadWorkflowlist()
	editor.editor.workflowIDs = {};
	TRP3_API.ui.listbox.setupListBox(editor.editor.workflow,
		TRP3_ScriptEditorNormal.reloadWorkflowlist(editor.editor.workflowIDs),
		nil, nil, ACTION_LIST_WIDTH, true);
end

local function newAction()
	editor.editor.index = nil;
	TRP3_API.ui.frame.configureHoverFrame(editor.editor, editor.list.add, "TOP", 0, 5, false);
	reloadWorkflowlist();
	TRP3_ScriptEditorNormal.safeLoadList(editor.editor.workflow, editor.editor.workflowIDs, "");
	editor.editor.type:SetSelectedValue(TRP3_API.quest.ACTION_TYPES.LOOK);
end

local function openAction(actionIndex, frame)
	if not actionIndex then
		newAction();
	else
		local actionData = toolFrame.specificDraft.AC[actionIndex];
		if actionData then
			editor.editor.index = actionIndex;
			TRP3_API.ui.frame.configureHoverFrame(editor.editor, frame, "TOP", 0, 0, false);
			reloadWorkflowlist();
			TRP3_ScriptEditorNormal.safeLoadList(editor.editor.workflow, editor.editor.workflowIDs, actionData.SC or "");
			editor.editor.type:SetSelectedValue(actionData.TY or TRP3_API.quest.ACTION_TYPES.LOOK);
		else
			newAction();
		end
	end
end

local function onActionSaved()
	local index = editor.editor.index or #toolFrame.specificDraft.AC + 1;
	local data = {
		TY = editor.editor.type:GetSelectedValue(),
		SC = editor.editor.workflow:GetSelectedValue(),
	}

	local structure = toolFrame.specificDraft.AC;
	if structure[index] then
		data.CO = structure[index].CO;
		structure[index] = nil;
	end
	structure[index] = data;

	refreshList();
	editor.editor:Hide();
end

local function openActionCondition(actionIndex)
	local scriptData = toolFrame.specificDraft.AC[actionIndex].CO;
	if not scriptData then
		scriptData = {
			{ { i = "unit_name", a = {"target"} }, "==", { v = "Elsa" } }
		};
	end

	editor.overlay:Show();
	editor.overlay:SetFrameLevel(editor:GetFrameLevel() + 20);
	TRP3_ConditionEditor:SetParent(editor.overlay);
	TRP3_ConditionEditor:ClearAllPoints();
	TRP3_ConditionEditor:SetPoint("CENTER", 0, 0);
	TRP3_ConditionEditor:SetFrameLevel(editor.overlay:GetFrameLevel() + 20);
	TRP3_ConditionEditor:Show();
	TRP3_ConditionEditor.load(scriptData);
	TRP3_ConditionEditor:SetScript("OnHide", function()
		TRP3_ConditionEditor:Hide();
		editor.overlay:Hide()
	end);
	TRP3_ConditionEditor.confirm:SetScript("OnClick", function()
		TRP3_ConditionEditor.save(scriptData);
		toolFrame.specificDraft.AC[actionIndex].CO = scriptData;
		TRP3_ConditionEditor:Hide();
		refreshList();
	end);
	TRP3_ConditionEditor.close:SetScript("OnClick", function()
		TRP3_ConditionEditor:Hide();
	end);
	TRP3_ConditionEditor.confirm:SetText(loc.EDITOR_CONFIRM);
	TRP3_ConditionEditor.title:SetText(loc.CA_ACTION_CONDI);
end

local function removeCondition(actionIndex)
	if toolFrame.specificDraft.AC[actionIndex].CO then
		wipe(toolFrame.specificDraft.AC[actionIndex].CO);
	end
	toolFrame.specificDraft.AC[actionIndex].CO = nil;
	refreshList();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function editor.place(parent)
	editor:SetParent(parent);
	editor:SetAllPoints();
	editor:Show();
end

function editor.init(ToolFrame)
	toolFrame = ToolFrame;

	editor.title:SetText(loc.WO_ACTIONS_LINKS);
	editor.help:SetText(loc.WO_ACTIONS_LINKS_TT);

	-- List
	editor.list.widgetTab = {};
	for i=1, 4 do
		local line = editor.list["line" .. i];
		tinsert(editor.list.widgetTab, line);
		line.click:SetScript("OnClick", function(self, button)
			if button == "RightButton" then
				if IsControlKeyDown() then
					removeCondition(self.actionIndex);
				else
					removeAction(self.actionIndex);
				end
			else
				if IsControlKeyDown() then
					openActionCondition(self.actionIndex);
				else
					openAction(self.actionIndex, self);
				end
			end
		end);
		line.click:SetScript("OnEnter", function(self)
			TRP3_RefreshTooltipForFrame(self);
			self:GetParent().Highlight:Show();
		end);
		line.click:SetScript("OnLeave", function(self)
			TRP3_MainTooltip:Hide();
			self:GetParent().Highlight:Hide();
		end);
		line.click:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		setTooltipForSameFrame(line.click, "RIGHT", 0, 5, loc.CA_ACTIONS,
			("|cffffff00%s: |cff00ff00%s\n"):format(loc.CM_CLICK, loc.CM_EDIT)
					.. ("|cffffff00%s + %s: |cff00ff00%s\n"):format(loc.CM_CTRL, loc.CM_CLICK, loc.CA_ACTIONS_COND)
					.. ("|cffffff00%s + %s: |cff00ff00%s\n"):format(loc.CM_CTRL, loc.CM_R_CLICK, loc.CA_ACTIONS_COND_REMOVE)
					.. ("|cffffff00%s: |cff00ff00%s"):format(loc.CM_R_CLICK, REMOVE));
	end
	editor.list.decorate = decorateActionLine;
	TRP3_API.ui.list.handleMouseWheel(editor.list, editor.list.slider);
	editor.list.slider:SetValue(0);
	editor.list.add:SetText(loc.CA_ACTIONS_ADD);
	editor.list.add:SetScript("OnClick", function() openAction() end);
	editor.list.empty:SetText(loc.CA_ACTIONS_NO);

	-- Editor
	editor.editor.title:SetText(loc.CA_ACTIONS_EDITOR);
	editor.editor.save:SetScript("OnClick", function(self)
		onActionSaved();
	end);
	TRP3_API.ui.listbox.setupListBox(editor.editor.type,
		{
			{loc.CA_ACTIONS_SELECT},
			{TRP3_API.formats.dropDownElements:format(loc.CA_ACTIONS, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.LOOK)), TRP3_API.quest.ACTION_TYPES.LOOK},
			{TRP3_API.formats.dropDownElements:format(loc.CA_ACTIONS, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.TALK)), TRP3_API.quest.ACTION_TYPES.TALK},
			{TRP3_API.formats.dropDownElements:format(loc.CA_ACTIONS, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.LISTEN)), TRP3_API.quest.ACTION_TYPES.LISTEN},
			{TRP3_API.formats.dropDownElements:format(loc.CA_ACTIONS, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.ACTION)), TRP3_API.quest.ACTION_TYPES.ACTION},
		},
		nil, nil, ACTION_LIST_WIDTH, true);

	editor:SetScript("OnHide", function() editor.editor:Hide() end);

	-- Tutorial
	local TUTORIAL = {
		{
			box = toolFrame, title = "WO_ACTIONS_LINKS", text = "TU_AC_1_TEXT",
			arrow = "DOWN", x = 0, y = 100, anchor = "CENTER", textWidth = 400,
		},
		{
			box = editor.list, title = "TU_AC_2", text = "TU_AC_2_TEXT",
			arrow = "DOWN", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
		}
	}
	editor:SetScript("OnShow", function()
		TRP3_ExtendedTutorial.loadStructure(TUTORIAL);
	end);
end