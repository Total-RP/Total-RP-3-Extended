----------------------------------------------------------------------------------
-- Total RP 3: Extended features
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
----------------------------------------------------------------------------------

local Globals, Comm, Utils = TRP3_API.globals, TRP3_API.communication, TRP3_API.utils;
local loc = TRP3_API.loc;

local frame = TRP3_CastingBarFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Casting bar
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function removeSound()
	if frame.soundHandler then
		Utils.music.stopSound(frame.soundHandler);
		frame.soundHandler = nil;
	end
end

local function interrupt()
	if frame.interruptMode == 2 then
		frame:SetValue(frame.maxValue);
		frame:SetStatusBarColor(frame.failedCastColor:GetRGB());
		frame.Spark:Hide();
		frame.Text:SetText(INTERRUPTED);
		frame.casting = nil;
		frame.channeling = nil;
		frame.fadeOut = true;
		frame.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
		frame.castID = nil;
		frame.interruptMode = nil;
		removeSound();
	end
end

function TRP3_API.extended.showCastingBar(duration, interruptMode, class, soundID, castText)
	if GetUnitSpeed("player") > 0 then
		Utils.message.displayMessage(SPELL_FAILED_MOVING, 4);
		return;
	end

	local startColor = CastingBarFrame_GetEffectiveStartColor(frame, false, interruptMode ~= 2);
	frame:SetStatusBarColor(startColor:GetRGB());

	if frame.flashColorSameAsStart then
		frame.Flash:SetVertexColor(startColor:GetRGB());
	else
		frame.Flash:SetVertexColor(1, 1, 1);
	end

	frame.castID = Utils.str.id();
	frame.interruptMode = interruptMode;
	frame.value = 0;
	frame.maxValue = duration;
	frame:SetMinMaxValues(0, frame.maxValue);
	frame:SetValue(frame.value);


	if castText and castText:len() > 0 then
		frame.Text:SetText(castText);
	elseif class and class.US and class.US.AC then
		frame.Text:SetText(class.US.AC);
	else
		frame.Text:SetText(loc.IT_CAST);
	end

	CastingBarFrame_ApplyAlpha(frame, 1.0);
	frame.holdTime = 0;
	frame.casting = true;
	frame.channeling = nil;
	frame.fadeOut = nil;

	frame.Spark:Show();

	frame:Show();

	removeSound();
	if soundID and soundID ~= 0 then
		local _, handlerID = Utils.music.playSoundID(soundID, "SFX", class and class.BA.NA or "Cast");
		frame.soundHandler = handlerID;
	end

	return frame.castID;
end

local function onUpdate(self, elapsed)
	if ( self.casting ) then
		self.value = self.value + elapsed;
		if ( self.value >= self.maxValue ) then
			self:SetValue(self.maxValue);
			removeSound();
			CastingBarFrame_FinishSpell(self, self.Spark, self.Flash);
			return;
		end
		self:SetValue(self.value);
		if ( self.Flash ) then
			self.Flash:Hide();
		end
		if ( self.Spark ) then
			local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
			self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, self.Spark.offsetY or 2);
		end
	elseif ( GetTime() < self.holdTime ) then
		return;
	elseif ( self.flash ) then
		local alpha = 0;
		if ( self.Flash ) then
			alpha = self.Flash:GetAlpha() + CASTING_BAR_FLASH_STEP;
		end
		if ( alpha < 1 ) then
			if ( self.Flash ) then
				self.Flash:SetAlpha(alpha);
			end
		else
			if ( self.Flash ) then
				self.Flash:SetAlpha(1.0);
			end
			self.flash = nil;
		end
	elseif ( self.fadeOut ) then
		local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if ( alpha > 0 ) then
			CastingBarFrame_ApplyAlpha(self, alpha);
		else
			self.fadeOut = nil;
			self:Hide();
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Init
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function frame.init()
	frame:RegisterEvent("PLAYER_STARTED_MOVING");
	frame:SetScript("OnEvent", function()
		interrupt();
	end);
	frame:SetScript("OnUpdate", onUpdate);
end