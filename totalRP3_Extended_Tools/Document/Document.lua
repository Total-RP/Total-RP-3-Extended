-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local loc = TRP3_API.loc;

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
