local L = TRP3_API.loc;

TRP3_InventoryItemConfigPanelMixin = {};

function TRP3_InventoryItemConfigPanelMixin:OnLoad()
    self.Backdrop.NineSlice.LeftEdge:Hide(); -- TODO: hack - pls fix art it's bad

    self.TitleText:SetText("Item Configuration");
    self.MarkerSectionHeader:SetText("Marker Position");
    self:SetEditBoxTitles();
    self.SaveButton:SetText(L.SAVE);

    self.Active = false;
end

function TRP3_InventoryItemConfigPanelMixin:OnUpdate()
    if self:ShouldUpdateEditBoxes() then
        self:UpdateEditBoxes();
    end
end

function TRP3_InventoryItemConfigPanelMixin:SetEditBoxTitles()
    self.CameraRotationEditBox.title:SetText("Camera Rotation");
    self.MarkerXEditBox.title:SetText(L.X);
    self.MarkerYEditBox.title:SetText(L.Y);
    self.AnimEditBox.title:SetText("Animation ID");
end

function TRP3_InventoryItemConfigPanelMixin:ShouldUpdateEditBoxes()
    return self.Active and self:IsVisible();
end

function TRP3_InventoryItemConfigPanelMixin:UpdateEditBoxes()
    local model = TRP3_InventoryPage.Model;
    local marker = model.Marker;
    local slot = TRP3_InventoryPage:GetActiveSlot();

    if not slot or not self:IsVisible() then
        return;
    end

    if marker.IsMoving then
        return;
    end

    local _, _, _, x, y = marker:GetPoint(1);
    self.MarkerXEditBox:SetText(format("%.1f", x));
    self.MarkerYEditBox:SetText(format("%.1f", y));

    local rotation = model:GetRotation();
    self.CameraRotationEditBox:SetText(format("%.1f", rotation or 0));
end

function TRP3_InventoryItemConfigPanelMixin:Enable()
    local slot = TRP3_InventoryPage:GetActiveSlot();
    if not slot then
        return;
    end

    local info = slot.info;
    local pos = info.pos;

    -- animation
    local animID, animTime = pos.sequence, pos.sequenceTime;
    self.AnimEditBox:SetText(animID);

    self.Active = true;
    self:Show();
end

function TRP3_InventoryItemConfigPanelMixin:Disable()
    self.Active = false;
    self:Hide();
end