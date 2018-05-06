----------------------------------------------------------------------------------
--- Total RP 3: Extended
---
--- Items chat link module
---    ------------------------------------------------------------------------------
---    Copyright 2018 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---
---    Licensed under the Apache License, Version 2.0 (the "License");
---    you may not use this file except in compliance with the License.
---    You may obtain a copy of the License at
---
---        http://www.apache.org/licenses/LICENSE-2.0
---
---    Unless required by applicable law or agreed to in writing, software
---    distributed under the License is distributed on an "AS IS" BASIS,
---    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
---    See the License for the specific language governing permissions and
---    limitations under the License.
----------------------------------------------------------------------------------

---@type TRP3_API
local TRP3_API = TRP3_API;

---@type Ellyb
local Ellyb = TRP3_API.Ellyb;

-- Lua imports
local tcopy = Ellyb.Tables.copy;
local date = date;

-- Total RP 3 imports
local iconToString = TRP3_API.utils.str.icon;
local loc = TRP3_API.loc;
local parseArgs = TRP3_API.script.parseArgs;

local Colors = Ellyb.ColorManager;

local DatabaseCampaignsChatLinksModule = TRP3_API.ChatLinks:InstantiateModule(loc.CL_EXTENDED_DATABASE_CAMPAIGN, "EXTENDED_DB_CAMPAIGN_LINK");

function DatabaseCampaignsChatLinksModule:GetLinkData(fullID, rootID, canBeImported)
	local itemData = TRP3_API.extended.getClass(fullID);
	local tooltipData = {
		class = {}
	};
	local _, itemName = TRP3_API.extended.getClassDataSafe(itemData);

	tcopy(tooltipData.class, itemData);
	tooltipData.fullID = fullID;
	tooltipData.rootID = rootID;
	tooltipData.canBeImported = canBeImported;

	return itemName, tooltipData
end

function DatabaseCampaignsChatLinksModule:GetTooltipLines(tooltipData)
	local class = tooltipData.class;

	-- Get a new tooltipLines object that we will fill
	local tooltipLines = TRP3_API.ChatLinkTooltipLines();

	local icon, name, description = TRP3_API.extended.getClassDataSafe(class)

	-- Get the quality and quality color of the tiem
	local itemQuality = class.BA.QA or LE_ITEM_QUALITY_COMMON;
	---@type Color
	local itemQualityColor = TRP3_API.inventory.getQualityColor(itemQuality);

	tooltipLines:SetTitle(iconToString(icon) .. " " .. itemQualityColor:WrapTextInColorCode(name));

	-- Description
	if description and description:len() > 0 then
		tooltipLines:AddLine(parseArgs(description), Colors.ORANGE)
	end

	return tooltipLines;
end

local DatabaseCampaignImportButton = DatabaseCampaignsChatLinksModule:NewActionButton("EXTENDED_IMPORT_DB_CAMPAIGN", loc.CL_IMPORT_ITEM, "EXT_DB_C_Q", "EXT_DB_C_A");

function DatabaseCampaignImportButton:IsVisible(data)
	return data.canBeImported and data.rootID and TRP3_DB.global[data.rootID] == nil;
end

function DatabaseCampaignImportButton:OnAnswerCommandReceived(data, sender)
	local itemID = data.rootID;
	local fromClass = data.class;
	local copiedData = {};
	TRP3_API.utils.table.copy(copiedData, fromClass);

	copiedData.MD.SD = date("%d/%m/%y %H:%M:%S");
	copiedData.MD.SB = TRP3_API.globals.player_id;
	TRP3_API.extended.tools.createItem(copiedData, itemID);

	TRP3_API.extended.tools.showFrame();
	TRP3_API.extended.tools.goToPage(itemID);
end

local DatabaseCampaignUpdateButton = DatabaseCampaignsChatLinksModule:NewActionButton("EXTENDED_UPDATE_DB_CAMPAIGN", loc.CL_UPDATE_CAMPAIGN, "EXT_DB_U_C_Q", "EXT_DB_U_C_A");

function DatabaseCampaignUpdateButton:IsVisible(data)
	return data.canBeImported and data.rootID and TRP3_DB.global[data.rootID] ~= nil;
end

function DatabaseCampaignUpdateButton:OnAnswerCommandReceived(data, sender)
	local itemID = data.rootID;
	local fromClass = data.class;
	local copiedData = {};
	TRP3_API.utils.table.copy(copiedData, fromClass);

	copiedData.MD.SD = date("%d/%m/%y %H:%M:%S");
	copiedData.MD.SB = TRP3_API.globals.player_id;

	TRP3_DB.global[data.rootID] = copiedData;

	TRP3_API.extended.tools.showFrame();
	TRP3_API.extended.tools.goToPage(itemID);
end

TRP3_API.extended.DatabaseCampaignsChatLinksModule = DatabaseCampaignsChatLinksModule;