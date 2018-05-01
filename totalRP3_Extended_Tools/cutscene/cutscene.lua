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
local wipe, tostring, error, assert, date = wipe, tostring, error, assert, date;
local loc = TRP3_API.loc;
local toolFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Campaign management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function createCutscene(data, ID)
	ID = ID or Utils.str.id();

	if TRP3_DB.global[ID] then
		error("This ID already exists. This shoudn't happen: " .. ID);
	end

	TRP3_DB.my[ID] = data;
	TRP3_API.extended.registerObject(ID, data, 0);

	return ID, data;
end
TRP3_API.extended.tools.createCutscene = createCutscene;

function TRP3_API.extended.tools.getCutsceneData()
	local data = {
		TY = TRP3_DB.types.DIALOG,
		MD = {
			MO = TRP3_DB.modes.NORMAL,
			V = 1,
			CD = date("%d/%m/%y %H:%M:%S");
			CB = Globals.player_id,
			SD = date("%d/%m/%y %H:%M:%S");
			SB = Globals.player_id,
		},
		BA = {},
		DS = {
			{
				TX = "Text."
			}
		}
	}
	return data;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Load and save
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onLoad()
	assert(toolFrame.rootClassID, "rootClassID is nil");
	assert(toolFrame.fullClassID, "fullClassID is nil");
	assert(toolFrame.rootDraft, "rootDraft is nil");
	assert(toolFrame.specificDraft, "specificDraft is nil");

	toolFrame.cutscene.normal:Show();
	toolFrame.cutscene.normal.load();
end

local function onSave()
	assert(toolFrame.specificDraft, "specificDraft is nil");
	toolFrame.cutscene.normal.saveToDraft();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initCutscene(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.cutscene.onLoad = onLoad;
	toolFrame.cutscene.onSave = onSave;

	TRP3_API.extended.tools.initCutsceneEditorNormal(toolFrame);
	TRP3_API.extended.tools.initCutsceneEffects();
end