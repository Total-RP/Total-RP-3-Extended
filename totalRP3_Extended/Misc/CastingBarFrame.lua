local CastingBarType = {
	ApplyingCrafting = "applyingcrafting",
	ApplyingTalents = "applyingtalents",
	Standard = "standard",
	Empowered = "empowered",
	Channel = "channel",
	Uninterruptable = "uninterruptable",
	Interrupted = "interrupted",
};

local CastingBarTypeInfo = {
	[CastingBarType.ApplyingCrafting] = {
		filling = "ui-castingbar-filling-applyingcrafting",
		full = "ui-castingbar-full-applyingcrafting",
		glow = "ui-castingbar-full-glow-applyingcrafting",
		sparkFx = "CraftingGlow",
		finishAnim = "CraftingFinish",
	},
	[CastingBarType.ApplyingTalents] = {
		filling = "ui-castingbar-filling-standard",
		full = "ui-castingbar-full-standard",
		glow = "ui-castingbar-full-glow-standard",
		sparkFx = "StandardGlow",
	},
	[CastingBarType.Standard] = {
		filling = "ui-castingbar-filling-standard",
		full = "ui-castingbar-full-standard",
		glow = "ui-castingbar-full-glow-standard",
		sparkFx = "StandardGlow",
		finishAnim = "StandardFinish",
	},
	[CastingBarType.Empowered] = {
		filling = "",
		full = "",
		glow = "",
	},
	[CastingBarType.Channel] = {
		filling = "ui-castingbar-filling-channel",
		full = "ui-castingbar-full-channel",
		glow = "ui-castingbar-full-glow-channel",
		sparkFx = "ChannelShadow",
		finishAnim = "ChannelFinish",
	},
	[CastingBarType.Uninterruptable] = {
		filling = "ui-castingbar-uninterruptable",
		full = "ui-castingbar-uninterruptable",
		glow = "ui-castingbar-full-glow-standard",
	},
	[CastingBarType.Interrupted] = {
		filling = "ui-castingbar-interrupted",
		full = "ui-castingbar-interrupted",
		glow = "ui-castingbar-full-glow-standard",
	},
};

TRP3_CastingBarMixin = {};

function TRP3_CastingBarMixin:OnLoad()
	self.StagePoints = {};
	self.StagePips = {};
	self.StageTiers = {};

	self.showCastbar = true;
	self.showIcon = true;

	local point, _, _, _, offsetY = self.Spark:GetPoint(1);
	if ( point == "CENTER" ) then
		self.Spark.offsetY = offsetY;
	end
end

function TRP3_CastingBarMixin:GetEffectiveType(isChannel, notInterruptible, isTradeSkill, isEmpowered)
	if isTradeSkill then
		return CastingBarType.ApplyingCrafting;
	end
	if notInterruptible then
		return CastingBarType.Uninterruptable;
	end
	if isChannel then
		return CastingBarType.Channel;
	end
	if isEmpowered then
		return CastingBarType.Empowered;
	end
	return CastingBarType.Standard;
end

function TRP3_CastingBarMixin:IsInterruptable()
	return self.barType ~= CastingBarType.Uninterruptable;
end

function TRP3_CastingBarMixin:GetTypeInfo(barType)
	if not barType then
		barType = CastingBarType.Standard;
	end
	return CastingBarTypeInfo[barType];
end

function TRP3_CastingBarMixin:OnUpdate(elapsed)
	if ( self.casting or self.reverseChanneling) then
		self.value = self.value + elapsed;
		if(self.reverseChanneling and self.NumStages > 0) then
			self:UpdateStage();
		end
		if ( self.value >= self.maxValue ) then
			self:SetValue(self.maxValue);
			self:UpdateCastTimeText();
			if (not self.reverseChanneling) then
				self:FinishSpell();
			else
				if self.FlashLoopingAnim and not self.FlashLoopingAnim:IsPlaying() then
					self.FlashLoopingAnim:Play();
					self.Flash:Show();
				end
			end
			self:HideSpark();
			return;
		end
		self:SetValue(self.value);
		self:UpdateCastTimeText();
		if ( self.Flash ) then
			self.Flash:Hide();
		end
	elseif ( self.channeling ) then
		self.value = self.value - elapsed;
		if ( self.value <= 0 ) then
			self:FinishSpell();
			return;
		end
		self:SetValue(self.value);
		self:UpdateCastTimeText();
		if ( self.Flash ) then
			self.Flash:Hide();
		end
	end

	if ( self.casting or self.reverseChanneling or self.channeling ) then
		if ( self.Spark ) then
			local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
			self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, self.Spark.offsetY or 0);
		end
	end
end

function TRP3_CastingBarMixin:ApplyAlpha(alpha)
	self:SetAlpha(alpha);
	if self.additionalFadeWidgets then
		for widget in pairs(self.additionalFadeWidgets) do
			widget:SetAlpha(alpha);
		end
	end
end

function TRP3_CastingBarMixin:FinishSpell()
	if self.maxValue and not self.reverseChanneling and not self.channeling then
		self:SetValue(self.maxValue);
		self:UpdateCastTimeText();
	end
	local barTypeInfo = self:GetTypeInfo(self.barType);
	self:SetStatusBarTexture(barTypeInfo.full);

	self:HideSpark();

	if ( self.Flash ) then
		self.Flash:SetAtlas(barTypeInfo.glow);
		self.Flash:SetAlpha(0.0);
		self.Flash:Show();
	end

	self:PlayFadeAnim();
	self:PlayFinishAnim();

	self.casting = nil;
	self.channeling = nil;
	self.reverseChanneling = nil;
end

function TRP3_CastingBarMixin:ShowSpark()
	if ( self.Spark ) then
		self.Spark:Show();
	end

	local currentBarType = self.barType;

	if currentBarType == CastingBarType.Interrupted then
		self.Spark:SetAtlas("ui-castingbar-pip-red");
		self.Spark.offsetY = 0;
	elseif currentBarType == CastingBarType.Empowered then
		self.Spark:SetAtlas("ui-castingbar-empower-cursor");
		self.Spark.offsetY = 4;
	else
		self.Spark:SetAtlas("ui-castingbar-pip");
		self.Spark.offsetY = 0;
	end

	for barType, barTypeInfo in pairs(CastingBarTypeInfo) do
		local sparkFx = barTypeInfo.sparkFx and self[barTypeInfo.sparkFx];
		if sparkFx then
			sparkFx:SetShown(self.playCastFX and barType == currentBarType);
		end
	end
end

function TRP3_CastingBarMixin:HideSpark()
	if ( self.Spark ) then
		self.Spark:Hide();
	end

	for _, barTypeInfo in pairs(CastingBarTypeInfo) do
		local sparkFx = barTypeInfo.sparkFx and self[barTypeInfo.sparkFx];
		if sparkFx then
			sparkFx:Hide();
		end
	end
end

function TRP3_CastingBarMixin:PlayInterruptAnims()
	if self.HoldFadeOutAnim then
		self.HoldFadeOutAnim:Play();
	end

	if not self.playCastFX then
		return;
	end

	if self.InterruptShakeAnim and tonumber(GetCVar("ShakeStrengthUI")) > 0 then
		self.InterruptShakeAnim:Play();
	end
	if self.InterruptGlowAnim then
		self.InterruptGlowAnim:Play();
	end
	if self.InterruptSparkAnim then
		self.InterruptSparkAnim:Play();
	end
end

function TRP3_CastingBarMixin:StopInterruptAnims()
	if self.HoldFadeOutAnim then
		self.HoldFadeOutAnim:Stop();
	end
	if self.InterruptShakeAnim then
		self.InterruptShakeAnim:Stop();
	end
	if self.InterruptGlowAnim then
		self.InterruptGlowAnim:Stop();
	end
	if self.InterruptSparkAnim then
		self.InterruptSparkAnim:Stop();
	end
end

function TRP3_CastingBarMixin:PlayFadeAnim()
	if self.FlashLoopingAnim then
		self.FlashLoopingAnim:Stop();
	end

	if self.FlashAnim then
		self.FlashAnim:Play();
	end

	if self.FadeOutAnim and self:GetAlpha() > 0 and self:IsVisible() then
		if self.reverseChanneling and self.CurrSpellStage < self.NumStages then
			self.HoldFadeOutAnim:Play();
		elseif not self.isInEditMode then
			self.FadeOutAnim:Play();
		end
	end
end

function TRP3_CastingBarMixin:PlayFinishAnim()
	if not self.playCastFX then
		return;
	end

	local barTypeInfo = self:GetTypeInfo(self.barType);

	local playFinish = not barTypeInfo.finishCondition or barTypeInfo.finishCondition(self);
	if playFinish then
		local finishAnim = barTypeInfo.finishAnim and self[barTypeInfo.finishAnim];
		if finishAnim then
			finishAnim:Play();
		end
	end

	if self.barType == CastingBarType.Empowered then
		for i = 1, self.CurrSpellStage do
			local stageTier = self.StageTiers[i];
			if stageTier and stageTier.FinishAnim then
				stageTier.FlashAnim:Stop();
				stageTier.FinishAnim:Play();
			end
		end
	end
end

function TRP3_CastingBarMixin:StopFinishAnims()
	if self.FlashAnim then
		self.FlashAnim:Stop();
	end
	if self.FadeOutAnim then
		self.FadeOutAnim:Stop();
	end

	for _, barTypeInfo in pairs(CastingBarTypeInfo) do
		local finishAnim = barTypeInfo.finishAnim and self[barTypeInfo.finishAnim];
		if finishAnim then
			finishAnim:Stop();
		end
	end
end

function TRP3_CastingBarMixin:StopAnims()
	self:StopInterruptAnims();
	self:StopFinishAnims();
end

function TRP3_CastingBarMixin:SetCastTimeTextShown(showCastTime)
	self.showCastTimeSetting = showCastTime;
	self:UpdateCastTimeTextShown();
end

function TRP3_CastingBarMixin:UpdateCastTimeTextShown()
	if not self.CastTimeText then
		return;
	end

	local showCastTime = self.showCastTimeSetting and (self.casting or self.channeling or self.isInEditMode);
	self.CastTimeText:SetShown(showCastTime);
	if showCastTime and self.isInEditMode and not self.CastTimeText.text then
		self:UpdateCastTimeText();
	end
end

function TRP3_CastingBarMixin:UpdateCastTimeText()
	if not self.CastTimeText then
		return;
	end

	local seconds = 0;
	if self.casting or self.channeling then
		local min, max = self:GetMinMaxValues();
		if self.casting then
			seconds = math.max(min, max - self:GetValue());
		else
			seconds = math.max(min, self:GetValue());
		end
	elseif self.isInEditMode then
		seconds = 10;
	end

	local text = string.format(CAST_BAR_CAST_TIME, seconds);
	self.CastTimeText:SetText(text);
end

function TRP3_CastingBarMixin:SetNameTextShown(showNameText)
	if not self.Text then
		return;
	end

	self.Text:SetShown(showNameText);
end

function TRP3_CastingBarMixin:SetIconShown(showIcon)
	if not self.Icon then
		return;
	end

	self.showIcon = showIcon;

	self:UpdateIconShown();
end

function TRP3_CastingBarMixin:ShouldIconBeShown()
	if not self.showIcon then
		return false;
	end

	if self.look ~= nil and self.look ~= "UNITFRAME" then
		return false;
	end

	if self.HideIconWhenNotInterruptible and not self:IsInterruptable() then
		return false;
	end

	return true;
end

function TRP3_CastingBarMixin:UpdateIconShown()
	if not self.Icon and not self.BorderShield then
		return;
	end

	local iconShown = self:ShouldIconBeShown();
	if self.Icon then
		self.Icon:SetShown(iconShown);
	end

	if self.BorderShield then
		local shieldShown = self.showShield and not self:IsInterruptable();
		self.BorderShield:SetShown(shieldShown);
			if self.BarBorder then
			self.BarBorder:SetShown(not shieldShown);
			end
			end
end

function TRP3_CastingBarMixin:ClearStages()

	if self.ChargeGlow then
		self.ChargeGlow:SetShown(false);
	end
	if self.ChargeFlash then
		self.ChargeFlash:SetAlpha(0);
	end

	for _, stagePip in pairs(self.StagePips) do
		local maxStage = self.NumStages;
		for i = 1, maxStage do
			local stageAnimName = "Stage" .. i;
			local stageAnim = stagePip[stageAnimName];
			if stageAnim then
				stageAnim:Stop();
			end
		end
		stagePip:Hide();
	end

	for _, stageTier in pairs(self.StageTiers) do
		stageTier:Hide();
	end

	self.NumStages = 0;
	table.wipe(self.StagePoints);
	table.wipe(self.StageTiers);
end
