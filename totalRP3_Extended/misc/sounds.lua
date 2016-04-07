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

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local pairs, strsplit = pairs, strsplit;
local loc = TRP3_API.locale.getText;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- SOUNDS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local historyFrame = TRP3_SoundsHistoryFrame;

local function onLinkClicked(self, link, text, button)
	local mode, id, channel = strsplit(":", link);

	if mode == "stop" then
		if channel == "Music" then
			Utils.music.stopMusic();
		else
			Utils.music.stopSound(id);
		end
	elseif mode == "replay" then
		if channel == "Music" then
			Utils.music.playMusic(id);
		else
			Utils.music.playSoundID(id, channel, Globals.player_id);
		end
	end

end

local function showHistory(button)
	if button then
		TRP3_API.ui.frame.configureHoverFrame(historyFrame, button, "TOP", 0, 5, false);
	end

	historyFrame.container:Clear();
	historyFrame.empty:Show();
	for index, handler in pairs(Utils.music.getHandlers()) do
		historyFrame.empty:Hide();
		local string = ("%s) " .. loc("EX_SOUND_HISTORY_LINE")):format(handler.date,
			"|cff00ff00[" .. (handler.source or UNKNOWN) .. "]|r",
			"|cffffff00" .. handler.id .. "|r",
			"|cffffffff" .. handler.channel .. "|r"
		);
		string = string .. (" |Hstop:%s:%s|h|cffff0000[%s]|h"):format(handler.handlerID, handler.channel, loc("EX_SOUND_HISTORY_STOP"));
		string = string .. (" |Hreplay:%s:%s|h|cffffff00[%s]|h"):format(handler.id, handler.channel, loc("EX_SOUND_HISTORY_REPLAY"));
		historyFrame.container:AddMessage(string);
	end

end

function historyFrame.onSoundPlayed()
	if historyFrame:IsVisible() then
		showHistory();
	end
end

function historyFrame.initSound()

	-- Button on target bar
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		if TRP3_API.toolbar then
			local toolbarButton = {
				id = "bb_extended_sounds",
				icon = "trade_archaeology_delicatemusicbox",
				configText = loc("CONF_SOUND"),
				tooltip = loc("CONF_SOUND"),
				tooltipSub = loc("CONF_SOUND_TT"),
				onClick = function(self)
					if historyFrame:IsVisible() then
						historyFrame:Hide();
					else
						showHistory(self);
					end
				end,
				visible = 1
			};
			TRP3_API.toolbar.toolbarAddButton(toolbarButton);
		end
	end);

	historyFrame.title:SetText(loc("EX_SOUND_HISTORY"));
	historyFrame.empty:SetText(loc("EX_SOUND_HISTORY_EMPTY"));
	historyFrame.container:SetScript("OnHyperlinkClick", onLinkClicked);
	historyFrame.Close:SetScript("OnClick", function()
		historyFrame:Hide();
	end);

	historyFrame.stop:SetText(loc("EX_SOUND_HISTORY_STOP_ALL"));
	historyFrame.stop:SetScript("OnClick", function()
		Utils.music.stopChannel();
		Utils.music.stopMusic();
	end);

	historyFrame.clear:SetText(loc("EX_SOUND_HISTORY_CLEAR"));
	historyFrame.clear:SetScript("OnClick", function()
		Utils.music.stopChannel();
		Utils.music.clearHandlers();
		Utils.music.stopMusic();
		showHistory();
	end);
end