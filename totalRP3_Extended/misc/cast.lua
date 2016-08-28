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
local loc = TRP3_API.locale.getText;

local frame = TRP3_CastingBarFrame;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Casting bar
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

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
	end
end

function TRP3_API.extended.showCastingBar(duration, interruptMode, class)
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

	if class and class.US and class.US.AC then
		frame.Text:SetText(class.US.AC);
	else
		frame.Text:SetText(loc("IT_CAST"));
	end

	CastingBarFrame_ApplyAlpha(frame, 1.0);
	frame.holdTime = 0;
	frame.casting = true;
	frame.channeling = nil;
	frame.fadeOut = nil;

	frame.Spark:Show();

	frame:Show();

	return frame.castID;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Init
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function frame.init()
	frame:RegisterEvent("PLAYER_STARTED_MOVING");
	frame:SetScript("OnEvent", function()
		interrupt();
	end);
end
