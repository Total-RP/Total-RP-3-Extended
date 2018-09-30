----------------------------------------------------------------------------------
--- Total RP 3
---    ---------------------------------------------------------------------------
---    Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
--- Copyright 2018 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---                Solanya <solanya@totalrp3.info> @Solanya_
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

local Ellyb = TRP3_API.Ellyb;
---@type AddOn_TotalRP3
local AddOn_TotalRP3 = AddOn_TotalRP3;

--region Lua imports
local huge = math.huge;
--endregion

--region Total RP 3 imports
local Utils = TRP3_API.utils;
local loc = TRP3_API.loc;
local getItemLink = TRP3_API.inventory.getItemLink;
--endregion

--region Ellyb imports
local ORANGE = Ellyb.ColorManager.ORANGE;
---endregion

-- Create the pin template, above group members
TRP3_StashMapPinMixin = AddOn_TotalRP3.MapPoiMixins.createPinTemplate(
	AddOn_TotalRP3.MapPoiMixins.GroupedCoalescedMapPinMixin, -- Use coalesced grouped tooltips (show multiple player names)
	AddOn_TotalRP3.MapPoiMixins.AnimatedPinMixin -- Use animated icons (bounce in)
);

-- Expose template name, so the scan can use it for the MapDataProvider
TRP3_StashMapPinMixin.TEMPLATE_NAME = "TRP3_StashMapPinTemplate";

--- This is called when the data provider acquire a pin, to transform poiInfo received from the scan
--- into display info to be used to decorate the pin.
---@param poiInfo {position:Vector2DMixin, sender:string}
function TRP3_StashMapPinMixin:GetDisplayDataFromPoiInfo(poiInfo)
	local characterID = poiInfo.CR or poiInfo.sender;
	local displayData = {};
	local isSelf = characterID == TRP3_API.globals.player_id;

	if not isSelf and (not TRP3_API.register.isUnitIDKnown(characterID) or not TRP3_API.register.hasProfile(characterID)) then
		-- Only remove the server name from the sender ID
		displayData.playerName = characterID:gsub("%-.*$", "");
		displayData.categoryPriority = displayData.playerName;
	else
		local profile = TRP3_API.profile.getPlayerCurrentProfile().player;

		--region Player name
		displayData.playerName = TRP3_API.register.getCompleteName(profile.characteristics, characterID, true);
		displayData.categoryPriority = displayData.playerName;

		if profile.characteristics then
			if profile.characteristics.CH then
				local color = Ellyb.Color.CreateFromHexa(profile.characteristics.CH);
				displayData.playerName = color(displayData.playerName);
			end
			if profile.characteristics.IC then
				displayData.playerName = Utils.str.icon(profile.characteristics.IC, 15) .. " " .. displayData.playerName;
			end
		end
		--endregion
	end

	local total = poiInfo.total;
	if not total then
		total = 0;
		for index, slot in pairs(poiInfo.item) do
			total = total + 1;
		end
	end

	local line = Utils.str.icon(poiInfo.BA.IC) .. " " .. getItemLink(poiInfo);
	displayData.scanLine = line .. " - |cffff9900" .. total .. "/8";

	return displayData
end

--- This is called by the data provider to decorate the pin after the base pin mixin has done its job.
function TRP3_StashMapPinMixin:Decorate(displayData)
	self.Texture:SetSize(24, 24);
	self:SetSize(24, 24);

	self.categoryName = loc.DR_STASHES_OWNER .. ": " .. displayData.playerName;
	self.categoryPriority = displayData.categoryPriority;
	self.Texture:SetAtlas("VignetteLoot");
	self.tooltipLine = displayData.scanLine;

	Ellyb.Tooltips.getTooltip(self):SetTitle(ORANGE(loc.DR_STASHES)):ClearLines();
end