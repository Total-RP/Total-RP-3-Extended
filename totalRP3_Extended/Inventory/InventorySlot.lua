local loc = TRP3_API.loc;

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
end

function TRP3_InventoryPageSlotMixin:OnSlotEnter()
    if not TRP3_InventoryPage.Main.Equip:IsVisible() then
        -- reset button model position?
    end
end

function TRP3_InventoryPageSlotMixin:OnSlotLeave()
    if not TRP3_InventoryPage.Main.Equip:IsVisible() then
        -- rest equipment?
    end
end

