----------------------------------------------------------------------------------
--- Total RP 3
---    ---------------------------------------------------------------------------
---    Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
---    Copyright 2018 Morgane "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---    Copyright 2018 Solanya <solanya@totalrp3.info> @Solanya_
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

--{{{ Total RP 3 imports
local Utils = TRP3_API.utils;
local loc = TRP3_API.loc;
local getItemLink = TRP3_API.inventory.getItemLink;
--}}}

--{{{ Ellyb imports
local ORANGE = Ellyb.ColorManager.ORANGE;
---}}}

-- Create the pin template, above group members
---@type BaseMapPoiPinMixin|MapCanvasPinMixin|{Texture: Texture, GetMap: fun():MapCanvasMixin}
TRP3_StashMapPinMixin = AddOn_TotalRP3.MapPoiMixins.createPinTemplate(
	AddOn_TotalRP3.MapPoiMixins.AnimatedPinMixin -- Use animated icons (bounce in)
);

-- Expose template name, so the scan can use it for the MapDataProvider
TRP3_StashMapPinMixin.TEMPLATE_NAME = "TRP3_StashMapPinTemplate";

--- This is called when the data provider acquire a pin, to transform poiInfo received from the scan
--- into display info to be used to decorate the pin.
---@param poiInfo {position:Vector2DMixin, sender:string}
function TRP3_StashMapPinMixin:GetDisplayDataFromPoiInfo(poiInfo)
	self.poiInfo = poiInfo
	local player = AddOn_TotalRP3.Player.CreateFromCharacterID(poiInfo.CR or poiInfo.sender);
	local displayData = {};

	--{{{ Player name
	local name, color, icon = player:GetRoleplayingName(), player:GetCustomColor(), player:GetCustomIcon();

	if color ~= nil then
		name = color:WrapTextInColorCode(name);
	end
	if icon ~= nil then
		name = Utils.str.icon(icon, 15) .. " " .. name;
	end
	--}}}

	displayData.playerName = name;
	displayData.categoryPriority = displayData.playerName;

	--{{{ Stash size
	local total = poiInfo.total;
	-- If no total, it's a self stash, so we compute the total.
	if not total then
		total = 0;
		for index, slot in pairs(poiInfo.item) do
			total = total + 1;
		end
	end
	--}}}

	local line = Utils.str.icon(poiInfo.BA.IC) .. " " .. getItemLink(poiInfo);
	displayData.scanLine = line .. " - " .. Ellyb.ColorManager.ORANGE(total .. "/8");

	return displayData
end

function TRP3_StashMapPinMixin:OnClick(button)
	if button == "RightButton" then
		if self.poiInfo.sender == TRP3_API.globals.player_id then
			TRP3_API.inventory.showStashDropdown(self, self.poiInfo)
		end
	end
end

--- This is called by the data provider to decorate the pin after the base pin mixin has done its job.
---@param displayData {playerName:string, categoryPriority:string, scanLine: string}
function TRP3_StashMapPinMixin:Decorate(displayData)
	self.Texture:SetSize(24, 24);
	self:SetSize(24, 24);

	self.Texture:SetAtlas("VignetteLoot");

	Ellyb.Tooltips.getTooltip(self)
			:SetTitle(ORANGE(loc.DR_STASHES))
			:ClearLines()
			:AddLine(displayData.scanLine)

	if self.poiInfo.sender == TRP3_API.globals.player_id then
		Ellyb.Tooltips.getTooltip(self):AddEmptyLine():AddLine(Ellyb.Strings.clickInstruction(loc.CM_R_CLICK, loc.DB_ACTIONS))
	end

end