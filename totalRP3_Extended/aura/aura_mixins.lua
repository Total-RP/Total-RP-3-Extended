-- a frame showing a single aura
TRP3_AuraMixin = {};

function TRP3_AuraMixin:OnMouseUp(button)
	if self.aura and button == "RightButton" then
		TRP3_API.extended.auras.cancel(self.aura.persistent.id);
	end
end

function TRP3_AuraMixin:OnEnter()
	if self.aura then
		if self:GetParent() == TRP3_AuraBarFrame then
			TRP3_AuraBarFrame:GetScript("OnEnter")(TRP3_AuraBarFrame);
		end
		TRP3_API.extended.auras.showTooltip(self);
	end
end

function TRP3_AuraMixin:OnLeave()
	TRP3_API.extended.auras.hideTooltip();
end

function TRP3_AuraMixin:Reset()
	self:Hide();
	self:ClearAllPoints();
	self.overlay:SetText();
	self.duration:SetText();
	self.aura = nil;
end

function TRP3_AuraMixin:SetAuraAndShow(aura)
	self.icon:SetTexture("Interface\\ICONS\\" .. (aura.class.BA.IC or "TEMP"));
	if aura.color then
		self.border:SetVertexColor(aura.color.r, aura.color.g, aura.color.b);
		self.border:Show();
	else
		self.border:Hide();
	end
	self.aura = aura;
	self:Show();
end

function TRP3_AuraMixin:SetAuraTexts(duration, overlay)
	self.duration:SetText(duration);
	self.overlay:SetText(overlay);
end

-- container frame for auras
TRP3_AuraBarMixin = {};

function TRP3_AuraBarMixin:OnEnter()
	for _, region in ipairs(self.backgroundRegions) do
		region:Show();
	end
end

function TRP3_AuraBarMixin:OnLeave()
	for _, region in ipairs(self.backgroundRegions) do
		region:Hide();
	end
end

function TRP3_AuraBarMixin:UpdatePosition()
	if self:GetNumPoints() >= 1 then
		self.positionKey = self:GetPoint();
	else
		self.positionKey = "TOPRIGHT";
	end
	if self.positionKey == "TOPRIGHT" or self.positionKey == "TOP" or self.positionKey == "RIGHT" or self.positionKey == "CENTER" then
		self.tooltipAnchor = "ANCHOR_BOTTOMLEFT";
	elseif self.positionKey == "TOPLEFT" or self.positionKey == "LEFT" then
		self.tooltipAnchor = "ANCHOR_BOTTOMRIGHT";
	elseif self.positionKey == "BOTTOMLEFT" then
		self.tooltipAnchor = "ANCHOR_TOPRIGHT";
	else
		self.tooltipAnchor = "ANCHOR_TOPLEFT";
	end
end

function TRP3_AuraBarMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

function TRP3_AuraBarMixin:OnDragStart()
	self:StartMoving();
end

function TRP3_AuraBarMixin:OnDragStop()
	self:StopMovingOrSizing();
	self:UpdatePosition();
	TRP3_AuraFrameCollapseAndExpandButton:UpdatePosition();
end

-- button to toggle the aura bar
TRP3_AuraFrameCollapseAndExpandButtonMixin = {};

function TRP3_AuraFrameCollapseAndExpandButtonMixin:UpdatePosition()
	self:ClearAllPoints();
	local p = TRP3_AuraBarFrame.positionKey;
	if p == "TOPRIGHT" or p == "RIGHT" or p == "CENTER" then
		self:SetPoint("LEFT", TRP3_AuraBarFrame, "RIGHT");
		self.orientation = 0;
		self.expandDirection = 0;
	elseif p == "TOPLEFT" or p == "LEFT" or p == "BOTTOMLEFT" then
		self:SetPoint("RIGHT", TRP3_AuraBarFrame, "LEFT");
		self.orientation = 0;
		self.expandDirection = 1;
	elseif p == "TOP" then
		self:SetPoint("BOTTOM", TRP3_AuraBarFrame, "TOP");
		self.orientation = 1;
		self.expandDirection = 0;
	else
		self:SetPoint("TOP", TRP3_AuraBarFrame, "BOTTOM");
		self.orientation = 1;
		self.expandDirection = 1;
	end
	self:UpdateOrientation();
end

function TRP3_AuraFrameCollapseAndExpandButtonMixin:OnLoad()
	self:SetChecked(true);
end

function TRP3_AuraFrameCollapseAndExpandButtonMixin:OnClick()
	TRP3_AuraBarFrame:SetShown(self:GetChecked());
	self:UpdateOrientation();
end
