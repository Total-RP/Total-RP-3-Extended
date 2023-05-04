-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local Globals, Utils = TRP3_API.globals, TRP3_API.utils;
local error, assert, date = error, assert, date;
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
