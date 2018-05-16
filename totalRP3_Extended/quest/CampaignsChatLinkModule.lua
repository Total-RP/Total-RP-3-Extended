----------------------------------------------------------------------------------
--- Total RP 3: Extended
---
--- Campaigns chat link module
--- ------------------------------------------------------------------------------
--- Copyright 2018 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---
--- Licensed under the Apache License, Version 2.0 (the "License");
--- you may not use this file except in compliance with the License.
--- You may obtain a copy of the License at
---
---  http://www.apache.org/licenses/LICENSE-2.0
---
--- Unless required by applicable law or agreed to in writing, software
--- distributed under the License is distributed on an "AS IS" BASIS,
--- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--- See the License for the specific language governing permissions and
--- limitations under the License.
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

-- Ellyb imports
local Colors = Ellyb.ColorManager;

local CAMPAIGN_PROGRESSION_FORMAT = loc.CL_CAMPAIGN_PROGRESSION .. " %s%%";

local CampaignsChatLinksModule = TRP3_API.ChatLinks:InstantiateModule(loc.CL_EXTENDED_CAMPAIGN, "EXTENDED_DB_CAMPAIGN_LINK");

function CampaignsChatLinksModule:GetLinkData(campaignID, canBeImported)
	local campaignInfo = TRP3_API.extended.getClass(campaignID);

	local tooltipData = {
		campaignInfo = tcopy(campaignInfo),
		campaignID = campaignID,
		canBeImported = canBeImported,
	};

	return campaignInfo.BA.NA, tooltipData
end

function CampaignsChatLinksModule:GetTooltipLines(tooltipData)
	local campaignInfo = tooltipData.campaignInfo;

	-- Get a new tooltipLines object that we will fill
	local tooltipLines = TRP3_API.ChatLinkTooltipLines();

	local icon, name, description = TRP3_API.extended.getClassDataSafe(campaignInfo)

	-- Get the quality and quality color of the tiem
	local itemQuality = campaignInfo.BA.QA or LE_ITEM_QUALITY_COMMON;
	---@type Color
	local itemQualityColor = TRP3_API.inventory.getQualityColor(itemQuality);

	tooltipLines:SetTitle(iconToString(icon, 25) .. " " .. itemQualityColor:WrapTextInColorCode(name));

	-- Description
	if description and description:len() > 0 then
		tooltipLines:AddLine(parseArgs(description), Colors.ORANGE)
	end

	tooltipLines:AddLine(" ");
	local progress = TRP3_API.quest.getCampaignProgression(tooltipData.campaignID);
	if progress == 100 then
		tooltipLines:AddLine(loc.CL_CAMPAIGN_PROGRESSION:format(TRP3_API.r.name("player")) .. " " .. loc.QE_CAMPAIGN_FULL, Colors.GREEN);
	else
		tooltipLines:AddLine(CAMPAIGN_PROGRESSION_FORMAT:format(TRP3_API.r.name("player"), progress))
	end

	return tooltipLines;
end

local DatabaseCampaignImportButton = CampaignsChatLinksModule:NewActionButton("EXTENDED_IMPORT_DB_CAMPAIGN", loc.CL_IMPORT_ITEM, "EXT_DB_C_Q", "EXT_DB_C_A");

function DatabaseCampaignImportButton:IsVisible(data)
	return data.canBeImported and data.campaignID and TRP3_DB.global[data.campaignID] == nil;
end

function DatabaseCampaignImportButton:OnAnswerCommandReceived(data, sender)
	local campaignID = data.campaignID;
	local fromClass = data.campaignInfo;
	local copiedData = {};
	tcopy(copiedData, fromClass);

	TRP3_API.extended.tools.createItem(copiedData, campaignID);
	TRP3_API.extended.tools.showFrame();
	TRP3_API.extended.tools.goToPage(campaignID);
end

local DatabaseCampaignUpdateButton = CampaignsChatLinksModule:NewActionButton("EXTENDED_UPDATE_DB_CAMPAIGN", loc.CL_UPDATE_CAMPAIGN, "EXT_DB_U_C_Q", "EXT_DB_U_C_A");

function DatabaseCampaignUpdateButton:IsVisible(data)
	return data.canBeImported and data.campaignID and TRP3_DB.global[data.campaignID] ~= nil;
end

function DatabaseCampaignUpdateButton:OnAnswerCommandReceived(data, sender)
	local itemID = data.campaignID;
	local fromClass = data.campaignInfo;
	local copiedData = {};
	tcopy(copiedData, fromClass);

	TRP3_DB.global[data.campaignID] = copiedData;

	TRP3_API.extended.tools.showFrame();
	TRP3_API.extended.tools.goToPage(itemID);
end

TRP3_API.extended.CampaignsChatLinksModule = CampaignsChatLinksModule;