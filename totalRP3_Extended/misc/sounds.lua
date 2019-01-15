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

local Communications = AddOn_TotalRP3.Communications;
local Globals, Utils = TRP3_API.globals, TRP3_API.utils;
local pairs, strsplit, floor, sqrt, tonumber = pairs, strsplit, math.floor, sqrt, tonumber;
local getConfigValue = TRP3_API.configuration.getValue;
local loc = TRP3_API.loc;
local Log = TRP3_API.utils.log;

local UnitPosition = TRP3_API.extended.getUnitPositionSafe;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Local sounds
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local LOCAL_SOUND_COMMAND = "PLS";
local LOCAL_STOPSOUND_COMMAND = "STS";

local function getPosition()
	local posY, posX, posZ, instanceID = UnitPosition("player");
	posY = floor(posY + 0.5);
	posX = floor(posX + 0.5);
	return posY, posX, posZ, instanceID;
end

function Utils.music.playLocalSoundID(soundID, channel, distance, source)
	-- Get current position
	local posY, posX, posZ, instanceID = getPosition();
	if instanceID then
		Communications.broadcast.broadcast(LOCAL_SOUND_COMMAND, soundID, channel, distance, instanceID, posY, posX, posZ);
	end
end

function Utils.music.playLocalMusic(soundID, distance, source)
	-- Get current position
	local posY, posX, posZ, instanceID = getPosition();
	if instanceID then
		Communications.broadcast.broadcast(LOCAL_SOUND_COMMAND, soundID, "Music" , distance, instanceID, posY, posX, posZ);
	end
end

function Utils.music.stopLocalSoundID(soundID, channel)
	soundID = soundID or 0;
	Communications.broadcast.broadcast(LOCAL_STOPSOUND_COMMAND, soundID, channel);
end

function Utils.music.stopLocalMusic(soundID)
	Utils.music.stopLocalSoundID(soundID, "Music");
end

local function isInRadius(maxDistance, posY, posX, myPosY, myPosX)
	local myMaxDistance = getConfigValue(TRP3_API.extended.CONFIG_SOUNDS_MAXRANGE);
	local distance = sqrt((posY - myPosY) ^ 2 + (posX - myPosX) ^ 2);
	return distance <= maxDistance and distance <= myMaxDistance;
end

local function initSharedSound()
	Communications.broadcast.registerCommand(LOCAL_SOUND_COMMAND, function(sender, soundID, channel, distance, instanceID, posY, posX, posZ)
		if getConfigValue(TRP3_API.extended.CONFIG_SOUNDS_ACTIVE) then
			if soundID and channel and distance and instanceID and posY and posX and posZ then
				distance = tonumber(distance) or 0;
				posY = tonumber(posY) or 0;
				posX = tonumber(posX) or 0;
				posZ = tonumber(posZ) or 0;
				instanceID = tonumber(instanceID) or -1;

				if sender == Globals.player_id then
					if channel ~= "Music" then
						Utils.music.playSoundID(soundID, channel, Globals.player_id);
					else
						Utils.music.playMusic(soundID, Globals.player_id);
					end
				else
					-- Get current position
					local myPosY, myPosX, myPosZ, myInstanceID = UnitPosition("player");
					myPosY = floor(myPosY + 0.5);
					myPosX = floor(myPosX + 0.5);

					if instanceID == myInstanceID and isInRadius(distance, posY, posX, myPosY, myPosX) then
						if channel ~= "Music" then
							if getConfigValue(TRP3_API.extended.CONFIG_SOUNDS_METHOD) == TRP3_API.extended.CONFIG_SOUNDS_METHODS.PLAY then
								Utils.music.playSoundID(soundID, channel, sender);
							else
								-- TODO: ask permission in chat
							end
						else
							if getConfigValue(TRP3_API.extended.CONFIG_MUSIC_METHOD) == TRP3_API.extended.CONFIG_SOUNDS_METHODS.PLAY then
								Utils.music.playMusic(soundID, sender);
							else
								-- TODO: ask permission in chat
							end
						end
					end
				end
			end
		end
	end);

	Communications.broadcast.registerCommand(LOCAL_STOPSOUND_COMMAND, function(sender, soundID, channel)
		if getConfigValue(TRP3_API.extended.CONFIG_SOUNDS_ACTIVE) then
			Utils.music.stopSoundID(soundID, channel, sender);
		end
	end);

end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Sound history
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
	elseif mode == "source" then

	end

end

local function showHistory()
	historyFrame:Show();
	historyFrame.container:Clear();
	historyFrame.empty:Show();
	for _, handler in pairs(Utils.music.getHandlers()) do
		historyFrame.empty:Hide();
		local source = handler.source or UNKNOWN;
		local string = ("%s) " .. loc.EX_SOUND_HISTORY_LINE):format(handler.date,
			"|Hsource:" .. source .. "|h|cff00ff00[" .. source .. "]|h|r",
			"|cffffff00" .. handler.id .. "|r",
			"|cffffffff" .. handler.channel .. " (" .. handler.handlerID .. ")|r"
		);
		string = string .. (" |Hstop:%s:%s|h|cffff0000[%s]|h"):format(handler.handlerID, handler.channel, loc.EX_SOUND_HISTORY_STOP);
		string = string .. (" |Hreplay:%s:%s|h|cffffff00[%s]|h"):format(handler.id, handler.channel, loc.EX_SOUND_HISTORY_REPLAY);
		historyFrame.container:AddMessage(string);
	end
end

function historyFrame.onSoundPlayed()
	if historyFrame:IsVisible() then
		showHistory();
	end
end

local function stopAll()
	Utils.music.stopChannel();
	Utils.music.stopMusic();
end

local function initHistory()
	-- Button on target bar
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		if TRP3_API.toolbar then
			local toolbarButton = {
				id = "bb_extended_sounds",
				icon = "trade_archaeology_delicatemusicbox",
				configText = loc.EX_SOUND_HISTORY,
				tooltip = loc.EX_SOUND_HISTORY,
				tooltipSub = loc.EX_SOUND_HISTORY_TT,
				onClick = function(self, _, button)
					if button == "LeftButton" then
						if historyFrame:IsVisible() then
							historyFrame:Hide();
						else
							showHistory();
						end
					else
						stopAll();
					end
				end,
				visible = 1
			};
			TRP3_API.toolbar.toolbarAddButton(toolbarButton);
		end
	end);

	historyFrame.container:SetFontObject(ChatFontNormal);
	historyFrame.container:SetHyperlinksEnabled(true);
	historyFrame.container:SetJustifyH("LEFT");

	historyFrame.title:SetText(loc.EX_SOUND_HISTORY);
	historyFrame.empty:SetText(loc.EX_SOUND_HISTORY_EMPTY);
	historyFrame.container:SetScript("OnHyperlinkClick", onLinkClicked);
	historyFrame.Close:SetScript("OnClick", function()
		historyFrame:Hide();
	end);

	historyFrame.stop:SetText(loc.EX_SOUND_HISTORY_STOP_ALL);
	historyFrame.stop:SetScript("OnClick", stopAll);

	historyFrame.clear:SetText(loc.EX_SOUND_HISTORY_CLEAR);
	historyFrame.clear:SetScript("OnClick", function()
		Utils.music.stopChannel();
		Utils.music.clearHandlers();
		Utils.music.stopMusic();
		showHistory();
	end);

	historyFrame:SetScript("OnMouseWheel",function(self, delta)
		if delta == -1 then
			historyFrame.container:ScrollDown();
		elseif delta == 1 then
			historyFrame.container:ScrollUp();
		end
	end);
	historyFrame:EnableMouseWheel(1);

	historyFrame.bottom:SetScript("OnClick", function()
		historyFrame.container:ScrollToBottom();
	end);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Init
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function historyFrame.initSound()
	initSharedSound();
	initHistory();

	TRP3_API.ui.frame.setupMove(historyFrame);
end
