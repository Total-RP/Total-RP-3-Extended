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
    self:ShowModelItemPosition();
end

function TRP3_InventoryPageSlotMixin:OnSlotLeave()
    TRP3_InventoryPage:ResetModel();
end

function TRP3_InventoryPageSlotMixin:OnSlotUpdate(deltaTime)
    if self.info and self.class and self.class.BA.WA then
		self.Locator:Show();
	else
		self.Locator:Hide();
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
    if self.info and self.class then
        local model = TRP3_InventoryPage.Model;
        local pos = self.info.pos or EMPTY;
		if self:ShouldShowItemLocation() and (pos or force) then
            local quality = self.class.BA and self.class.BA.QA;
			model.sequence = pos.sequence or DEFAULT_SEQUENCE;
			model.sequenceTime = pos.sequenceTime or DEFAULT_TIME;
			model:FreezeAnimation(model.sequence, 0, model.sequenceTime);
            model.Marker:Show();
            self:DrawItemLocationLine(quality);
		else
			TRP3_InventoryPage:ResetModel();
		end
	end
end

function TRP3_InventoryPageSlotMixin:OnLocatorClick(button)
    if button == "LeftButton" then
        local position, x, y = "RIGHT", -10, 0;
		if button.Side == INVENTORY_PAGE_SIDE.RIGHT then
			position, x, y = "LEFT", 10, 0;
		end
		TRP3_API.ui.frame.configureHoverFrame(TRP3_InventoryPage, self.Locator, position, x, y);
		TRP3_InventoryPage.ActiveSlot = self.Locator;

        local force = true;
		self:ShowModelItemPosition(force);
	else
        TRP3_InventoryPage:ResetModel();
	end
end
