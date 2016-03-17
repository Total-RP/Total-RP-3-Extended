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
local wipe, pairs, tostring, tinsert, assert = wipe, pairs, tostring, tinsert, assert;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effect structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local EFFECTS = {}

local function registerEffectEditor(effectID, effectStructure)
	assert(not EFFECTS[effectID], "Already have an effect editor for " .. effectID);
	EFFECTS[effectID] = effectStructure;
end
TRP3_API.extended.tools.registerEffectEditor = registerEffectEditor;

function TRP3_API.extended.tools.getEffectEditorInfo(effectID)
	return EFFECTS[effectID] or Globals.empty;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initBaseEffects()
	registerEffectEditor("text", {
		title = "Display text", -- TODO: locals
		icon = "inv_inscription_scrollofwisdom_01",
		description = "Displays a text.\nDifferent outputs are possible.", -- TODO: locals
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .."Will display" .. ":|r " .. args[1]); -- TODO: locals
		end,
		getDefaultArgs = function()
			return {"Your text", 1}; -- TODO: locals
		end
	});

	registerEffectEditor("document_show", {
		title = "Open document", -- TODO: locals
		icon = "inv_icon_mission_complete_order",
		description = "Opens a document to the player.", -- TODO: locals
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetText("|cffffff00" .."Document" .. ":|r " .. args[1]); -- TODO: locals
		end,
		getDefaultArgs = function()
			return {""};
		end
	});
end