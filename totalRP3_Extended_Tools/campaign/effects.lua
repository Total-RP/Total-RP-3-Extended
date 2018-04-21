----------------------------------------------------------------------------------
-- Total RP 3
-- Scripts : Campaign/Quest Effects editors
--	---------------------------------------------------------------------------
--	Copyright 2016 Sylvain Cossement (telkostrasz@telkostrasz.be)
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
local tonumber, pairs, tostring, strtrim, assert = tonumber, pairs, tostring, strtrim, assert;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local registerEffectEditor = TRP3_API.extended.tools.registerEffectEditor;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effect
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function quest_start_init()
	local editor = TRP3_EffectEditorQuestStart;

	registerEffectEditor("quest_start", {
		title = loc.EFFECT_QUEST_START,
		icon = "achievement_quests_completed_01",
		description = loc.EFFECT_QUEST_START_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local class = getClass(tostring(args[1]));
			local link;
			if class ~= TRP3_DB.missing then
				link = TRP3_API.inventory.getItemLink(class, args[1], true);
			end
			scriptStepFrame.description:SetText(loc.EFFECT_QUEST_START_PREVIEW:format("|cff00ff00" .. (link or tostring(args[1])) .. "|cffffff00"));
		end,
		getDefaultArgs = function()
			return {""};
		end,
		editor = editor;
	});

	editor.browse:SetText(BROWSE);
	editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			editor.id:SetText(id);
		end, TRP3_DB.types.QUEST});
	end);

	-- ID
	editor.id.title:SetText(loc.EFFECT_QUEST_START_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.EFFECT_QUEST_START_ID, loc.EFFECT_QUEST_START_ID_TT);


	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id:SetText(data[1] or "");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
	end
end

local function quest_goToStep_init()
	local editor = TRP3_EffectEditorGoToStep;

	registerEffectEditor("quest_goToStep", {
		title = loc.EFFECT_QUEST_GOTOSTEP,
		icon = "achievement_quests_completed_02",
		description = loc.EFFECT_QUEST_GOTOSTEP_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local class = getClass(tostring(args[1]));
			local link;
			if class ~= TRP3_DB.missing then
				link = TRP3_API.inventory.getItemLink(class, args[1], true);
			end
			scriptStepFrame.description:SetText(loc.EFFECT_QUEST_GOTOSTEP_PREVIEW:format("|cff00ff00" .. (link or tostring(args[1])) .. "|cffffff00"));
		end,
		getDefaultArgs = function()
			return {""};
		end,
		editor = editor;
	});

	editor.browse:SetText(BROWSE);
	editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			editor.id:SetText(id);
		end, TRP3_DB.types.QUEST_STEP});
	end);

	-- ID
	editor.id.title:SetText(loc.EFFECT_QUEST_GOTOSTEP_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.EFFECT_QUEST_GOTOSTEP_ID, loc.EFFECT_QUEST_GOTOSTEP_ID_TT);


	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id:SetText(data[1] or "");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
	end
end

local function quest_revealObjective_init()
	local editor = TRP3_EffectEditorQuestObjReveal;

	registerEffectEditor("quest_revealObjective", {
		title = loc.EFFECT_QUEST_REVEAL_OBJ,
		icon = "icon_treasuremap",
		description = loc.EFFECT_QUEST_REVEAL_OBJ_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local class = getClass(tostring(args[1]));
			local link;
			if class ~= TRP3_DB.missing then
				link = TRP3_API.inventory.getItemLink(class, args[1], true);
			end
			scriptStepFrame.description:SetText(loc.EFFECT_QUEST_REVEAL_OBJ_PREVIEW:format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. (link or tostring(args[1])) .. "|cffffff00"));
		end,
		getDefaultArgs = function()
			return {""};
		end,
		editor = editor;
	});

	registerEffectEditor("quest_markObjDone", {
		title = loc.EFFECT_QUEST_REVEAL_OBJ_DONE,
		icon = "inv_misc_map_01",
		description = loc.EFFECT_QUEST_REVEAL_OBJ_DONE_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local class = getClass(tostring(args[1]));
			local link;
			if class ~= TRP3_DB.missing then
				link = TRP3_API.inventory.getItemLink(class, args[1], true);
			end
			scriptStepFrame.description:SetText(loc.EFFECT_QUEST_REVEAL_OBJ_DONE_PREVIEW:format("|cff00ff00" .. tostring(args[2]) .. "|cffffff00", "|cff00ff00" .. (link or tostring(args[1])) .. "|cffffff00"));
		end,
		getDefaultArgs = function()
			return {""};
		end,
		editor = editor;
	});

	editor.browse:SetText(BROWSE);
	editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			editor.id:SetText(id);
		end, TRP3_DB.types.QUEST});
	end);

	-- ID
	editor.id.title:SetText(loc.EFFECT_QUEST_START_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.EFFECT_QUEST_START_ID, loc.EFFECT_QUEST_START_ID_TT);

	-- Obj
	editor.obj.title:SetText(loc.EFFECT_QUEST_OBJ_ID);
	setTooltipForSameFrame(editor.obj.help, "RIGHT", 0, 5, loc.EFFECT_QUEST_OBJ_ID, loc.EFFECT_QUEST_OBJ_ID_TT);


	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id:SetText(data[1] or "");
		editor.obj:SetText(data[2] or "");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
		scriptData.args[2] = stEtN(strtrim(editor.obj:GetText()));
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Operands
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local registerOperandEditor = TRP3_API.extended.tools.registerOperandEditor;

local function quest_obj_init()
	local editor = TRP3_OperandEditorQuestObj;

	registerOperandEditor("quest_obj", {
		title = loc.OP_OP_QUEST_OBJ,
		description = loc.OP_OP_QUEST_OBJ_TT,
		returnType = true,
		getText = function(args)
			local id = (args or EMPTY)[1] or "";
			local obj = (args or EMPTY)[2] or "";
			return loc.OP_OP_QUEST_OBJ_PREVIEW:format("|cffff9900" .. obj .. "|cffffff00", TRP3_API.inventory.getItemLink(getClass(id), id));
		end,
		editor = editor,
	});

	editor.browse:SetText(BROWSE);
	editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			editor.id:SetText(id);
		end, TRP3_DB.types.QUEST});
	end);

	-- Text & obj
	editor.id.title:SetText(loc.QUEST_ID);
	editor.obj.title:SetText(loc.QE_OBJ_ID)
	setTooltipForSameFrame(editor.obj.help, "RIGHT", 0, 5, loc.QE_OBJ_ID, "");

	function editor.load(args)
		editor.id:SetText((args or EMPTY)[1] or "");
		editor.obj:SetText((args or EMPTY)[2] or "");
	end

	function editor.save()
		return {strtrim(editor.id:GetText()) or "", strtrim(editor.obj:GetText()) or ""};
	end
end

local function quest_is_step_init()
	local editor = TRP3_OperandEditorQuestSelection;

	registerOperandEditor("quest_is_step", {
		title = loc.OP_OP_QUEST_STEP,
		description = loc.OP_OP_QUEST_STEP_TT,
		returnType = "",
		getText = function(args)
			local id = (args or EMPTY)[1] or "";
			return loc.OP_OP_QUEST_STEP_PREVIEW:format(TRP3_API.inventory.getItemLink(getClass(id), id));
		end,
		editor = editor,
	});

	editor.browse:SetText(BROWSE);
	editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			editor.id:SetText(id);
		end, TRP3_DB.types.QUEST});
	end);

	-- Text & var
	editor.id.title:SetText(loc.QUEST_ID);

	function editor.load(args)
		editor.id:SetText((args or EMPTY)[1] or "");
	end

	function editor.save()
		return {strtrim(editor.id:GetText()) or ""};
	end
end

local function quest_obj_all_init()
	local editor = TRP3_OperandEditorQuestSelection;

	registerOperandEditor("quest_obj_all", {
		title = loc.OP_OP_QUEST_OBJ_ALL,
		description = loc.OP_OP_QUEST_OBJ_ALL_TT,
		returnType = "",
		getText = function(args)
			local id = (args or EMPTY)[1] or "";
			return loc.OP_OP_QUEST_OBJ_ALL_PREVIEW:format(TRP3_API.inventory.getItemLink(getClass(id), id));
		end,
		editor = editor,
	});

	registerOperandEditor("quest_obj_current", {
		title = loc.OP_OP_QUEST_OBJ_CURRENT,
		description = loc.OP_OP_QUEST_OBJ_CURRENT_TT,
		returnType = "",
		getText = function(args)
			local id = (args or EMPTY)[1] or "";
			return loc.OP_OP_QUEST_OBJ_CURRENT_PREVIEW:format(TRP3_API.inventory.getItemLink(getClass(id), id));
		end,
		editor = editor,
	});

end

local function quest_is_npc_init()
	registerOperandEditor("quest_is_npc", {
		title = loc.OP_OP_QUEST_NPC,
		description = loc.OP_OP_QUEST_NPC_TT,
		returnType = true,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_QUEST_NPC .. " (" .. TRP3_API.extended.tools.getUnitText(unitID) .. ")";
		end,
		editor = TRP3_OperandEditorUnitType,
	});
end

function TRP3_API.extended.tools.initCampaignEffects()

	-- Effect
	quest_start_init();
	quest_goToStep_init();
	quest_revealObjective_init();

	-- Operands
	quest_is_step_init();
	quest_obj_init();
	quest_is_npc_init();
	quest_obj_all_init();
end