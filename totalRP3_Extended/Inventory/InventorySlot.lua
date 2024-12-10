local loc = TRP3_API.loc;

---@enum TRP3.InventoryPageSide
local INVENTORY_PAGE_SIDE = {
    LEFT = 0,
    RIGHT = 1;
};

TRP3_InventoryPageSlotMixin = {};

function TRP3_InventoryPageSlotMixin:OnLoad()
end

---@param side TRP3.InventoryPageSide
function TRP3_InventoryPageSlotMixin:Init(side)
    local wearText = loc.INV_PAGE_WEAR_TT
				.. "\n\n|cffffff00" .. loc.CM_CLICK .. ":|r " .. loc.INV_PAGE_WEAR_ACTION
				.. "\n|cffffff00" .. loc.CM_R_CLICK .. ":|r " .. loc.INV_PAGE_WEAR_ACTION_RESET;
    if side == INVENTORY_PAGE_SIDE.LEFT then
        self.Locator:SetPoint("RIGHT", self, "LEFT", -5, 0);
        TRP3_API.ui.tooltip.setTooltipForSameFrame(self.Locator, "LEFT", 0, 0, loc.INV_PAGE_ITEM_LOCATION, wearText);
    elseif side == INVENTORY_PAGE_SIDE.RIGHT then
        self.Locator:SetPoint("LEFT", self, "RIGHT", 5, 0);
        TRP3_API.ui.tooltip.setTooltipForSameFrame(self.Locator, "RIGHT", 0, 0, loc.INV_PAGE_ITEM_LOCATION, wearText);
    end
    TRP3_API.inventory.initContainerSlot(self);

    self.additionalOnEnterHandler = self.OnSlotEnter;
    self.additionalOnLeaveHandler = self.OnSlotLeave;
    self.additionalOnUpdateHandler = self.OnSlotUpdate;

    self.Side = side;
end

function TRP3_InventoryPageSlotMixin:OnSlotEnter()
    if not self:IsPopulated() or TRP3_InventoryPage:IsActiveSlot(self) then
        return;
    end

    TRP3_InventoryPage:PreviewSlot(self);
end

function TRP3_InventoryPageSlotMixin:OnSlotLeave()
    if not self:IsPopulated() or TRP3_InventoryPage:IsActiveSlot(self) then
        return;
    end

    TRP3_InventoryPage:ClearPreview();
end

function TRP3_InventoryPageSlotMixin:OnSlotUpdate()
    if self.info and self.class and self.class.BA.WA then
		self.Locator:Show();
	else
		self.Locator:Hide();
	end
end

function TRP3_InventoryPageSlotMixin:ResetLocation()
    local pos = self.info.pos;
    if pos then
        pos.x = 0;
        pos.y = 0;
    end
end

function TRP3_InventoryPageSlotMixin:IsPopulated()
    return (self.info ~= nil) and (self.class ~= nil);
end

function TRP3_InventoryPageSlotMixin:ShouldShowItemLocation()
    if not self:IsPopulated() then
        return false;
    end

    local isWearable = self.class.BA and self.class.BA.WA;
    local pos = self.info.pos;
    return (isWearable ~= nil) and (pos ~= nil);
end

------------

TRP3_InventoryPageSlotLocatorMixin = {};

function TRP3_InventoryPageSlotLocatorMixin:OnClick(button)
    if button == "LeftButton" then
        local slot = self:GetParent();
        if TRP3_InventoryPage:IsActiveSlot(slot) then
            TRP3_InventoryPage:ClearActiveSlot();
            return;
        end


		TRP3_InventoryPage:SetActiveSlot(slot);
	else
        local slot = self:GetParent();
        slot:ResetLocation();
        TRP3_InventoryPage:ClearActiveSlot();
	end
end

function TRP3_InventoryPageSlotLocatorMixin:OnEnter()
    local slot = self:GetParent();
    if TRP3_InventoryPage:IsActiveSlot(slot) then
        return;
    end

    TRP3_RefreshTooltipForFrame(self);
	TRP3_InventoryPage:PreviewSlot(slot);
end

function TRP3_InventoryPageSlotLocatorMixin:OnLeave()
    TRP3_MainTooltip:Hide();

    if TRP3_InventoryPage:IsActiveSlot(self:GetParent()) then
        return;
    end

    TRP3_InventoryPage:ClearPreview();
end