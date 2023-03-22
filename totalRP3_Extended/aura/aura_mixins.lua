-- aura tooltip
local TOOLTIP_REFRESH_INTERVAL = 0.2;
local auraDataSource;

TRP3_AuraTooltipMixin = {};
function TRP3_AuraTooltipMixin:Init(dataSource)
	auraDataSource = dataSource;
end

function TRP3_AuraTooltipMixin:Refresh()
	local owner = self:GetOwner();
	self:Hide();
	if not owner or not owner.aura or owner.aura.persistent.invalid then return end
	
	self:SetOwner(owner, TRP3_AuraBarFrame.tooltipAnchor, 0, 0);
	local title, category, description, flavor, expiry, cancelText = auraDataSource:GetAuraTooltipLines(owner.aura);
	
	local i = 1;
	if title or category then
		local r, g, b = TRP3_API.Ellyb.ColorManager.YELLOW:GetRGB();
		self:AddDoubleLine(title or "", category or "", r, g, b, r, g, b);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetFontObject(GameFontNormalLarge);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		_G["TRP3_AuraTooltipTextRight"..i]:SetFontObject(GameFontNormalLarge);
		_G["TRP3_AuraTooltipTextRight"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if description and description:len() > 0 then
		local r, g, b = TRP3_API.Ellyb.ColorManager.WHITE:GetRGB();
		self:AddLine(description, r, g, b,true);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetFontObject(GameFontNormal);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetSpacing(2);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if flavor and flavor:len() > 0 then
		self:AddLine(flavor, 0.0, 0.667, 0.6,true); -- 00AA99
		_G["TRP3_AuraTooltipTextLeft"..i]:SetFontObject(GameFontNormal);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetSpacing(2);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if expiry and expiry:len() > 0 then
		local r, g, b = TRP3_API.Ellyb.ColorManager.GREEN:GetRGB();
		self:AddLine(expiry, r, g, b,true);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetFontObject(GameFontNormalSmall);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetSpacing(2);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if cancelText and cancelText:len() > 0 then
		local r, g, b = TRP3_API.Ellyb.ColorManager.WHITE:GetRGB();
		self:AddLine(cancelText, r, g, b,true);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetFontObject(GameFontNormalSmall);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetSpacing(2);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetNonSpaceWrap(true);
	end
	self:Show();
end

function TRP3_AuraTooltipMixin:Attach(frame)
	if self.timer then
		self.timer:Cancel();
	end
	self:SetOwner(frame, TRP3_AuraBarFrame.tooltipAnchor, 0, 0);
	self:Refresh();
	self.timer = C_Timer.NewTicker(TOOLTIP_REFRESH_INTERVAL, function()
		TRP3_AuraTooltip:Refresh();
	end);
end

function TRP3_AuraTooltipMixin:Detach(frame)
	if not self:IsOwned(frame) then return end
	if self.timer then
		self.timer:Cancel();
	end
	self:Hide();
end

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
			TRP3_AuraBarFrame:OnEnter();
		end
		TRP3_AuraTooltip:Attach(self);
	end
end

function TRP3_AuraMixin:OnLeave()
	TRP3_AuraTooltip:Detach(self);
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
