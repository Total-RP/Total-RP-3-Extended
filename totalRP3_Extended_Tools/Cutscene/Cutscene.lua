-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local function createCutscene(data, ID)
	ID = ID or TRP3_API.utils.str.id();

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
			CB = TRP3_API.globals.player_id,
			SD = date("%d/%m/%y %H:%M:%S");
			SB = TRP3_API.globals.player_id,
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
