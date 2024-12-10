TRP3_InventoryItemConfigPanelMixin = {};

function TRP3_InventoryItemConfigPanelMixin:OnLoad()
    self.Backdrop.NineSlice.LeftEdge:Hide(); -- TODO: hack - pls fix art it's bad

    self.AnimEditBox.title:SetText("TITLE HERE");
end