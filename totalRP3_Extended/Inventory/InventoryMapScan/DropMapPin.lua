-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local Ellyb = TRP3_API.Ellyb;
---@type AddOn_TotalRP3
local AddOn_TotalRP3 = AddOn_TotalRP3;

--{{{ Total RP 3 imports
local loc = TRP3_API.loc;
local getClass, getItemLink = TRP3_API.extended.getClass, TRP3_API.inventory.getItemLink;
--}}}

--{{{ Ellyb imports
local ORANGE = TRP3_API.Colors.Orange;
---}}}

-- Create the pin template, above group members
---@type BaseMapPoiPinMixin|MapCanvasPinMixin|{Texture: Texture, GetMap: fun():MapCanvasMixin}
TRP3_DropMapPinMixin = AddOn_TotalRP3.MapPoiMixins.createPinTemplate(
	AddOn_TotalRP3.MapPoiMixins.GroupedCoalescedMapPinMixin, -- Use coalesced grouped tooltips (show multiple player names)
	AddOn_TotalRP3.MapPoiMixins.AnimatedPinMixin -- Use animated icons (bounce in)
);

-- Expose template name, so the scan can use it for the MapDataProvider
TRP3_DropMapPinMixin.TEMPLATE_NAME = "TRP3_DropMapPinTemplate";

--- This is called when the data provider acquire a pin, to transform poiInfo received from the scan
--- into display info to be used to decorate the pin.
---@param poiInfo {position:Vector2DMixin, sender:string}
function TRP3_DropMapPinMixin:GetDisplayDataFromPoiInfo(poiInfo)
	local displayData = {};

	local item = getClass(poiInfo.item.id);
	displayData.scanLine = getItemLink(item) .. " x" .. (poiInfo.item.count or 1);

	return displayData
end

--- This is called by the data provider to decorate the pin after the base pin mixin has done its job.
---@param displayData {scanLine:string}
function TRP3_DropMapPinMixin:Decorate(displayData)
	self.Texture:SetSize(24, 24);
	self:SetSize(24, 24);

	self.Texture:SetAtlas("VignetteLoot");
	self.tooltipLine = displayData.scanLine;

	Ellyb.Tooltips.getTooltip(self):SetTitle(ORANGE(loc.TYPE_ITEMS)):ClearLines();
end
