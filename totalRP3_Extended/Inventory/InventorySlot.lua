local EMPTY = TRP3_API.globals.empty;
local loc = TRP3_API.loc;

local DEFAULT_SEQUENCE = 193;
local DEFAULT_TIME = 1;

---@enum TRP3.InventoryPageSide
local INVENTORY_PAGE_SIDE = {
    LEFT = 0,
    RIGHT = 1;
}

TRP3_InventoryPageSlotMixin = {};

function TRP3_InventoryPageSlotMixin:OnLoad()
    self.Locator = self.ItemLocator;
end

---@param side TRP3.InventoryPageSide
function TRP3_InventoryPageSlotMixin:Init(side)
    local wearText = loc.INV_PAGE_WEAR_TT
				.. "\n\n|cffffff00" .. loc.CM_CLICK .. ":|r " .. loc.INV_PAGE_WEAR_ACTION
				.. "\n|cffffff00" .. loc.CM_R_CLICK .. ":|r " .. loc.INV_PAGE_WEAR_ACTION_RESET;
    if side == INVENTORY_PAGE_SIDE.LEFT then
        self.ItemLocator:SetPoint("RIGHT", self, "LEFT", -5, 0);
        TRP3_API.ui.tooltip.setTooltipForSameFrame(self.ItemLocator, "LEFT", 0, 0, loc.INV_PAGE_ITEM_LOCATION, wearText);
    elseif side == INVENTORY_PAGE_SIDE.RIGHT then
        self.ItemLocator:SetPoint("LEFT", self, "RIGHT", 5, 0);
        TRP3_API.ui.tooltip.setTooltipForSameFrame(self.ItemLocator, "RIGHT", 0, 0, loc.INV_PAGE_ITEM_LOCATION, wearText);
    end
    TRP3_API.inventory.initContainerSlot(self);
end

function TRP3_InventoryPageSlotMixin:OnSlotEnter()
    self:ShowModelItemPosition();
end

function TRP3_InventoryPageSlotMixin:OnSlotLeave()
    TRP3_InventoryPage:ResetModel();
end

function TRP3_InventoryPageSlotMixin:DrawItemLocationLine(quality)
    local model = TRP3_InventoryPage.Model;
    local line = model.Line;
    line:SetStartPoint("CENTER", self);
    line:SetEndPoint("CENTER", model.Marker);
    self:SetFrameLevel(model:GetFrameLevel() + 5); -- TODO: investigate
    local r, g, b = TRP3_API.inventory.getQualityColorRGB(quality);
    line:SetVertexColor(r, g, b, 1);
    line:Show();
end

function TRP3_InventoryPageSlotMixin:ShowModelItemPosition(force)
    if self.CurrentInventory and self.class then
        local model = TRP3_InventoryPage.Model;
		local isWearable = self.class.BA and self.class.BA.WA;
		local quality = self.class.BA and self.class.BA.QA;
		local pos = self.CurrentInventory.pos;
		if isWearable and (pos or force) then
			pos = pos or EMPTY;
			model.sequence = pos.sequence or DEFAULT_SEQUENCE;
			model.sequenceTime = pos.sequenceTime or DEFAULT_TIME;
			model:setAnimation(model.sequence, model.sequenceTime);
            model.Marker:Show();
            self:DrawItemLocationLine(quality);
			--moveMarker(model.Marker, pos.x or 0, pos.y or 0, 0, 0, quality, model);
			--if main.Equip then
			--	main.Equip.sequence:SetText(model.sequence);
			--	main.Equip.time:SetValue(model.sequenceTime);
			--end
		else
			TRP3_InventoryPage:ResetModel();
		end
	end
end
