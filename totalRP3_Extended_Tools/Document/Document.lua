-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local assert = assert;
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
