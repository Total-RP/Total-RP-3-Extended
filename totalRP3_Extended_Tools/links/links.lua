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
local tostring, strtrim, tinsert, table, tremove, assert, wipe = tostring, strtrim, tinsert, table, tremove, assert, wipe;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local stEtN = Utils.str.emptyToNil;

local editor = TRP3_LinksEditor;
local gameLinksEditor = TRP3_EventsEditorFrame;
local toolFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- OBJECT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local LINK_LIST_WIDTH = 300;

local function decorateLinkElement(frame, index)
	local structureInfo = editor.structure[index];

	frame.Name:SetText(structureInfo.text);
	frame.Icon:SetTexture(structureInfo.icon);
	setTooltipForSameFrame(frame, "TOP", 0, -5, structureInfo.text, structureInfo.tt);

	TRP3_API.ui.listbox.setupListBox(frame.select, editor.workflowListStructure, function(value)
		toolFrame.specificDraft.LI[structureInfo.field] = stEtN(value);
	end, nil, LINK_LIST_WIDTH, true);
	TRP3_ScriptEditorNormal.safeLoadList(frame.select, editor.workflowIDs, toolFrame.specificDraft.LI[structureInfo.field] or "");
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- GAME
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tsize = Utils.table.size;

local function decorateEventLine(line, actionIndex)
	local data = toolFrame.specificDraft;
	local actionData = data.HA[actionIndex];

	line.Name:SetText(actionData.EV or UNKNOWN);
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
	TRP3_API.ui.list.initList(gameLinksEditor.list, data.HA, gameLinksEditor.list.slider);
	gameLinksEditor.list.empty:Hide();
	if tsize(data.HA) == 0 then
		gameLinksEditor.list.empty:Show();
	end
end

local function removeEvent(index)
	TRP3_API.popup.showConfirmPopup(loc.CA_ACTION_REMOVE, function()
		if toolFrame.specificDraft.HA[index] then
			wipe(toolFrame.specificDraft.HA[index]);
			tremove(toolFrame.specificDraft.HA, index);
		end
		refreshList();
		gameLinksEditor.editor:Hide();
	end);
end

local ACTION_LIST_WIDTH = 250;

local function reloadWorkflowlist()
	gameLinksEditor.editor.workflowIDs = {};
	TRP3_API.ui.listbox.setupListBox(gameLinksEditor.editor.workflow,
		TRP3_ScriptEditorNormal.reloadWorkflowlist(gameLinksEditor.editor.workflowIDs),
		nil, nil, ACTION_LIST_WIDTH, true);
end

local function newEvent()
	gameLinksEditor.editor.index = nil;
	TRP3_API.ui.frame.configureHoverFrame(gameLinksEditor.editor, gameLinksEditor.list.add, "TOP", 0, 5, false);
	gameLinksEditor.editor.event:SetText("PLAYER_REGEN_DISABLED");
	reloadWorkflowlist();
	TRP3_ScriptEditorNormal.safeLoadList(gameLinksEditor.editor.workflow, gameLinksEditor.editor.workflowIDs, "");
end

local function openEvent(actionIndex, frame)
	if not actionIndex then
		newEvent();
	else
		local actionData = toolFrame.specificDraft.HA[actionIndex];
		if actionData then
			gameLinksEditor.editor.index = actionIndex;
			TRP3_API.ui.frame.configureHoverFrame(gameLinksEditor.editor, frame, "RIGHT", 0, 5, false);
			gameLinksEditor.editor.event:SetText(actionData.EV or "");
			reloadWorkflowlist();
			TRP3_ScriptEditorNormal.safeLoadList(gameLinksEditor.editor.workflow, gameLinksEditor.editor.workflowIDs, actionData.SC or "");
		else
			newEvent();
		end
	end
end

local function onEventSaved()
	local index = gameLinksEditor.editor.index or #toolFrame.specificDraft.HA + 1;
	local data = {
		SC = gameLinksEditor.editor.workflow:GetSelectedValue(),
		EV = stEtN(strtrim(gameLinksEditor.editor.event:GetText())),
	}

	local structure = toolFrame.specificDraft.HA;
	if structure[index] then
		data.CO = structure[index].CO;
		structure[index] = nil;
	end
	structure[index] = data;

	refreshList();
	gameLinksEditor.editor:Hide();
end

local function openEventCondition(eventLink)
	local scriptData = toolFrame.specificDraft.HA[eventLink].CO or {
		{ { i = "unit_name", a = {"target"} }, "==", { v = "Elsa" } }
	};

	editor.overlay:Show();
	editor.overlay:SetFrameLevel(editor:GetFrameLevel() + 20);
	TRP3_ConditionEditor:SetParent(editor.overlay);
	TRP3_ConditionEditor:ClearAllPoints();
	TRP3_ConditionEditor:SetPoint("CENTER", 0, 0);
	TRP3_ConditionEditor:SetFrameLevel(editor.overlay:GetFrameLevel() + 20);
	TRP3_ConditionEditor:Show();
	TRP3_ConditionEditor.load(scriptData);
	TRP3_ConditionEditor:SetScript("OnHide", function() editor.overlay:Hide() end);
	TRP3_ConditionEditor.confirm:SetScript("OnClick", function()
		TRP3_ConditionEditor.save(scriptData);
		toolFrame.specificDraft.HA[eventLink].CO = scriptData;
		TRP3_ConditionEditor:Hide();
		refreshList();
	end);
	TRP3_ConditionEditor.close:SetScript("OnClick", function()
		TRP3_ConditionEditor:Hide();
	end);
	TRP3_ConditionEditor.confirm:SetText(loc.EDITOR_CONFIRM);
	TRP3_ConditionEditor.title:SetText(loc.WO_EVENT_EX_CONDI);
end

local function removeCondition(actionIndex)
	if toolFrame.specificDraft.HA[actionIndex].CO then
		wipe(toolFrame.specificDraft.HA[actionIndex].CO);
	end
	toolFrame.specificDraft.HA[actionIndex].CO = nil;
	refreshList();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
local TUTORIAL, tutoAll, tutoPartial;

function editor.load(structure)
	assert(toolFrame.specificDraft, "specificDraft is nil");
	assert(toolFrame.specificDraft.SC, "specificDraft is nil");

	local data = toolFrame.specificDraft;
	if not data.LI then
		data.LI = {};
	end
	if not data.HA then
		data.HA = {};
	end

	refreshList();

	editor.workflowIDs = {};
	editor.workflowListStructure = TRP3_ScriptEditorNormal.reloadWorkflowlist(editor.workflowIDs);
	editor.structure = structure;

	TRP3_API.ui.list.initList(editor.links, editor.structure, editor.links.slider);

	gameLinksEditor:Show();
	TUTORIAL = tutoAll;
	if data.TY == TRP3_DB.types.ITEM or data.TY == TRP3_DB.types.DOCUMENT or data.TY == TRP3_DB.types.DIALOG then
		gameLinksEditor:Hide();
		TUTORIAL = tutoPartial;
	end
end

function editor.init(ToolFrame)
	toolFrame = ToolFrame;

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- OBJECT
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	editor.links.title:SetText(loc.WO_EVENT_LINKS);
	editor.links.triggers:SetText(loc.WO_LINKS_TRIGGERS);

	-- List
	editor.links.widgetTab = {};
	for i=1, 5 do
		local line = editor.links["slot" .. i];
		tinsert(editor.links.widgetTab, line);
	end
	editor.links.decorate = decorateLinkElement;
	TRP3_API.ui.list.handleMouseWheel(editor.links, editor.links.slider);
	editor.links.slider:SetValue(0);
	editor.workflowIDs = {};

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- GAME
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	gameLinksEditor.title:SetText(loc.WO_EVENT_EX_LINKS);
	gameLinksEditor.help:SetText(loc.WO_EVENT_EX_LINKS_TT);

	-- List
	gameLinksEditor.list.widgetTab = {};
	for i=1, 4 do
		local line = gameLinksEditor.list["line" .. i];
		tinsert(gameLinksEditor.list.widgetTab, line);

		if line.click then
			line.click:SetScript("OnClick", function(self, button)
				if button == "RightButton" then
					if IsControlKeyDown() then
						removeCondition(self.actionIndex);
					else
						removeEvent(self.actionIndex);
					end
				else
					if IsControlKeyDown() then
						openEventCondition(self.actionIndex);
					else
						openEvent(self.actionIndex, self);
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
			setTooltipForSameFrame(line.click, "RIGHT", 0, 5, loc.WO_EVENT_EX_LINK,
				("|cffffff00%s: |cff00ff00%s\n"):format(loc.CM_CLICK, loc.CM_EDIT)
						.. ("|cffffff00%s + %s: |cff00ff00%s\n"):format(loc.CM_CTRL, loc.CM_CLICK, loc.CA_ACTIONS_COND)
						.. ("|cffffff00%s + %s: |cff00ff00%s\n"):format(loc.CM_CTRL, loc.CM_R_CLICK, loc.CA_ACTIONS_COND_REMOVE)
						.. ("|cffffff00%s: |cff00ff00%s"):format(loc.CM_R_CLICK, REMOVE));
		end
	end
	gameLinksEditor.list.decorate = decorateEventLine;
	TRP3_API.ui.list.handleMouseWheel(gameLinksEditor.list, gameLinksEditor.list.slider);
	gameLinksEditor.list.slider:SetValue(0);
	gameLinksEditor.list.add:SetText(loc.WO_EVENT_EX_ADD);
	gameLinksEditor.list.add:SetScript("OnClick", function() openEvent() end);
	gameLinksEditor.list.empty:SetText(loc.WO_EVENT_EX_NO);

	-- Editor
	gameLinksEditor.editor.title:SetText(loc.WO_EVENT_EX_EDITOR);
	gameLinksEditor.editor.event.title:SetText(loc.WO_EVENT_ID);
	setTooltipForSameFrame(gameLinksEditor.editor.event.help, "RIGHT", 0, 5, loc.WO_EVENT_ID, loc.WO_EVENT_ID_TT);
	gameLinksEditor.editor.save:SetScript("OnClick", function(self)
		onEventSaved();
	end);

	gameLinksEditor:SetScript("OnHide", function() gameLinksEditor.editor:Hide() end);

	-- Tutorial
	tutoAll = {
		{
			box = toolFrame, title = "WO_LINKS", text = "TU_EL_1_TEXT",
			arrow = "DOWN", x = 0, y = 100, anchor = "CENTER", textWidth = 400,
		},
		{
			box = editor.links, title = "WO_EVENT_LINKS", text = "TU_EL_2_TEXT",
			arrow = "RIGHT", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
		},
		{
			box = gameLinksEditor, title = "WO_EVENT_EX_LINKS", text = "TU_EL_3_TEXT_V2",
			arrow = "LEFT", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
		}
	};
	tutoPartial = {
		tutoAll[1], tutoAll[2],
		{
			box = toolFrame, title = "WO_EVENT_EX_LINKS", text = "TU_EL_4_TEXT",
			arrow = "DOWN", x = 0, y = 0, anchor = "CENTER", textWidth = 400,
		}
	};
	editor:SetScript("OnShow", function()
		TRP3_ExtendedTutorial.loadStructure(TUTORIAL);
	end);
end