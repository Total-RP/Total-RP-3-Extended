-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local loc = TRP3_API.loc;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item management
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


local function createItem(data, ID)
	ID = ID or TRP3_API.utils.str.id();

	if TRP3_DB.global[ID] then
		error("This ID already exists. This shoudn't happen: " .. ID);
	end

	TRP3_DB.my[ID] = data;
	TRP3_API.security.computeSecurity(ID, data);
	TRP3_API.extended.registerObject(ID, data, 0);

	return ID, data;
end
TRP3_API.extended.tools.createItem = createItem;

function TRP3_API.extended.tools.getBlankItemData(toMode)
	return {
		TY = TRP3_DB.types.ITEM,
		MD = {
			MO = toMode or TRP3_DB.modes.QUICK,
			V = 1,
			CD = date("%d/%m/%y %H:%M:%S");
			CB = TRP3_API.globals.player_id,
			SD = date("%d/%m/%y %H:%M:%S");
			SB = TRP3_API.globals.player_id,
		},
		BA = {
			NA = loc.IT_NEW_NAME,
		},
	};
end

function TRP3_API.extended.tools.getContainerItemData()
	local data = TRP3_API.extended.tools.getBlankItemData(TRP3_DB.modes.NORMAL);
	data.BA.CT = true;
	data.BA.NA = loc.IT_NEW_NAME_CO;
	data.BA.IC = "inv_misc_bag_36";
	data.CO = {SR = 5, SC = 4};
	return data;
end
