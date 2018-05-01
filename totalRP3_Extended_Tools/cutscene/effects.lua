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

local function dialog_start_init()
	local editor = TRP3_EffectEditorDialogSelection;

	registerEffectEditor("dialog_start", {
		title = loc.EFFECT_DIALOG_START,
		icon = "warrior_disruptingshout",
		description = loc.EFFECT_DIALOG_START_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local class = getClass(tostring(args[1]));
			local link;
			if class ~= TRP3_DB.missing then
				link = TRP3_API.inventory.getItemLink(class, args[1]);
			end
			scriptStepFrame.description:SetText(loc.EFFECT_DIALOG_START_PREVIEW:format("|cff00ff00" .. (link or tostring(args[1])) .. "|cffffff00"));
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
		end, TRP3_DB.types.DIALOG});
	end);

	-- ID
	editor.id.title:SetText(loc.EFFECT_DIALOG_ID);

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.id:SetText(data[1] or "");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
	end
end


local function dialog_quick_init()
	local editor = TRP3_EffectEditorDialogSimple;

	registerEffectEditor("dialog_quick", {
		title = loc.EFFECT_DIALOG_QUICK,
		icon = "inv_inscription_scrollofwisdom_01",
		description = loc.EFFECT_DIALOG_QUICK_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" ..loc.EFFECT_TEXT_PREVIEW .. ":|r " .. tostring(args[1]));
		end,
		getDefaultArgs = function()
			return {loc.EFFECT_TEXT_TEXT_DEFAULT};
		end,
		editor = editor,
	});

	function editor.load(scriptData)
		local data = scriptData.args or Globals.empty;
		editor.text.scroll.text:SetText(data[1] or "");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.text.scroll.text:GetText()));
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Operands
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local registerOperandEditor = TRP3_API.extended.tools.registerOperandEditor;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Init
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initCutsceneEffects()

	-- Effect
	dialog_start_init();
	dialog_quick_init();

	-- Operands

end