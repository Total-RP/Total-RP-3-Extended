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
local tonumber, tostring, type, tinsert, wipe, assert = tonumber, tostring, type, tinsert, wipe, assert;
local tsize, EMPTY = Utils.table.size, Globals.empty;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local initList = TRP3_API.ui.list.initList;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local registerOperandEditor = TRP3_API.extended.tools.registerOperandEditor;
local getUnitText = TRP3_API.extended.tools.getUnitText;

local unitTypeEditor = TRP3_OperandEditorUnitType;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Shared editors
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function initEnitTypeEditor()
	local unitType = {
		{TRP3_API.formats.dropDownElements:format("Unit type", "Player"), "player"}, -- TODO: locals
		{TRP3_API.formats.dropDownElements:format("Unit type", "Target"), "target"}, -- TODO: locals
	}
	TRP3_API.ui.listbox.setupListBox(unitTypeEditor.type, unitType, nil, nil, 180, true);

	function unitTypeEditor.load(args)
		unitTypeEditor.type:SetSelectedValue((args or EMPTY)[1] or "target");
	end

	function unitTypeEditor.save()
		return {unitTypeEditor.type:GetSelectedValue() or "target"};
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Operands structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function string_init()
	registerOperandEditor("string", {
		title = "String value", -- TODO: loc
		description = "A litteral value.", -- TODO: loc
		getText = function(args)
			local value = tostring(args or "");
			return "String value: \"" .. value .. "\""; -- TODO: locals
		end,
	});
end

local function unit_name_init()
	registerOperandEditor("unit_name", {
		title = "Unit name", -- TODO: loc
		description = "The name of the unit, as returned by the first argument of UnitName.", -- TODO: loc
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return "Unit name (" .. getUnitText(unitID) .. ")"; -- TODO: locals
		end,
		editor = unitTypeEditor,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_ConditionEditor.initOperands()

	initEnitTypeEditor();

	string_init();

	unit_name_init();

end