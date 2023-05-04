-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local Globals, Utils = TRP3_API.globals, TRP3_API.utils;
local tostring, strtrim = tostring, strtrim;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;

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

local registerOperandEditor = TRP3_API.extended.tools.registerOperandEditor; -- luacheck: ignore 211

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Init
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initCutsceneEffects()

	-- Effect
	dialog_start_init();
	dialog_quick_init();

	-- Operands

end
