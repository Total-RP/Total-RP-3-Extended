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
-- Document management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.getDocumentItemData(id)
	local data = TRP3_API.extended.tools.getBlankItemData(TRP3_DB.modes.NORMAL);
	data.BA.IC = "inv_misc_book_16";
	data.BA.US = true;
	data.US = {
		AC = loc.IT_DOC_ACTION,
		SC = "onUse"
	};
	data.SC = {
		["onUse"] = { ["ST"] = { ["1"] = { ["e"] = {
			{
				["id"] = "document_show",
				["args"] = {
					id .. TRP3_API.extended.ID_SEPARATOR .. "doc",
				},
			},
		},
			["t"] = "list",
		}}}};
	data.IN = {
		doc = {
			TY = TRP3_DB.types.DOCUMENT,
			MD = {
				MO = TRP3_DB.modes.NORMAL,
			},
			BA = {
				NA = loc.DO_NEW_DOC,
			},
			BT = true,
		}
	};
	return data;
end


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Document base frame
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onLoad()
	assert(toolFrame.rootClassID, "rootClassID is nil");
	assert(toolFrame.fullClassID, "fullClassID is nil");
	assert(toolFrame.rootDraft, "rootDraft is nil");
	assert(toolFrame.specificDraft, "specificDraft is nil");

	toolFrame.document.normal:Show();
	toolFrame.document.normal.load();
end

local function onSave()
	assert(toolFrame.specificDraft, "specificDraft is nil");
	toolFrame.document.normal.saveToDraft();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initDocument(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.document.onLoad = onLoad;
	toolFrame.document.onSave = onSave;

	TRP3_API.extended.tools.initDocumentEditorNormal(toolFrame);
end