-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local Communications = AddOn_TotalRP3.Communications;
local Globals, Utils = TRP3_API.globals, TRP3_API.utils;
local pairs, strsplit, floor, sqrt, tonumber = pairs, strsplit, math.floor, sqrt, tonumber;
local getConfigValue = TRP3_API.configuration.getValue;
local loc = TRP3_API.loc;

local UnitPosition = TRP3_API.extended.getUnitPositionSafe;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Local sounds
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local LOCAL_SOUND_COMMAND = "PLS";
local LOCAL_SOUNDFILE_COMMAND = "PSF";
local LOCAL_STOPSOUND_COMMAND = "STS";

local function getPosition()
	local posY, posX, posZ, instanceID = UnitPosition("player");
	posY = floor(posY + 0.5);
	posX = floor(posX + 0.5);
	return posY, posX, posZ, instanceID;
end

function Utils.music.playLocalSoundID(soundID, channel, distance)
	-- Get current position
	local posY, posX, posZ, instanceID = getPosition();
	if instanceID then
		Communications.broadcast.broadcast(LOCAL_SOUND_COMMAND, TRP3_API.BroadcastMethod.World, soundID, channel, distance, instanceID, posY, posX, posZ);
	end
end

function Utils.music.playLocalSoundFileID(soundFileID, channel, distance)
	-- Get current position
	local posY, posX, posZ, instanceID = getPosition();
	if instanceID then
		Communications.broadcast.broadcast(LOCAL_SOUNDFILE_COMMAND, TRP3_API.BroadcastMethod.World, soundFileID, channel, distance, instanceID, posY, posX, posZ);
	end
end

function Utils.music.playLocalMusic(soundID, distance)
	-- Get current position
	local posY, posX, posZ, instanceID = getPosition();
	if instanceID then
		Communications.broadcast.broadcast(LOCAL_SOUND_COMMAND, TRP3_API.BroadcastMethod.World, soundID, "Music" , distance, instanceID, posY, posX, posZ);
	end
end

function Utils.music.stopLocalSoundID(soundID, channel, fadeout)
	soundID = soundID or 0;
	fadeout = fadeout or 0;
	Communications.broadcast.broadcast(LOCAL_STOPSOUND_COMMAND, TRP3_API.BroadcastMethod.World, soundID, channel, fadeout);
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
		if getConfigValue(TRP3_API.extended.CONFIG_SOUNDS_ACTIVE) and not IsInInstance() then
			if soundID and channel and distance and instanceID and posY and posX and posZ then
				distance = tonumber(distance) or 0;
				posY = tonumber(posY) or 0;
				posX = tonumber(posX) or 0;
				instanceID = tonumber(instanceID) or -1;

				if sender == Globals.player_id then
					if channel ~= "Music" then
						Utils.music.playSoundID(soundID, channel, Globals.player_id);
					else
						Utils.music.playMusic(soundID, Globals.player_id);
					end
				else
					-- Get current position
					local myPosY, myPosX, _, myInstanceID = UnitPosition("player");
					myPosY = floor(myPosY + 0.5);
					myPosX = floor(myPosX + 0.5);

					if instanceID == myInstanceID and isInRadius(distance, posY, posX, myPosY, myPosX) then
						if channel ~= "Music" then
							if getConfigValue(TRP3_API.extended.CONFIG_SOUNDS_METHOD) == TRP3_API.extended.CONFIG_SOUNDS_METHODS.PLAY then
								Utils.music.playSoundID(soundID, channel, sender);
							--else
								-- TODO: ask permission in chat
							end
						else
							if getConfigValue(TRP3_API.extended.CONFIG_MUSIC_METHOD) == TRP3_API.extended.CONFIG_SOUNDS_METHODS.PLAY then
								Utils.music.playMusic(soundID, sender);
							--else
								-- TODO: ask permission in chat
							end
						end
					end
				end
			end
		end
	end);

	Communications.broadcast.registerCommand(LOCAL_SOUNDFILE_COMMAND, function(sender, soundID, channel, distance, instanceID, posY, posX, posZ)
		if getConfigValue(TRP3_API.extended.CONFIG_SOUNDS_ACTIVE) and not IsInInstance() then
			if soundID and channel and distance and instanceID and posY and posX and posZ then
				distance = tonumber(distance) or 0;
				posY = tonumber(posY) or 0;
				posX = tonumber(posX) or 0;
				instanceID = tonumber(instanceID) or -1;

				if sender == Globals.player_id then
					Utils.music.playSoundFileID(soundID, channel, Globals.player_id);
				else
					-- Get current position
					local myPosY, myPosX, _, myInstanceID = UnitPosition("player");
					myPosY = floor(myPosY + 0.5);
					myPosX = floor(myPosX + 0.5);

					if instanceID == myInstanceID and isInRadius(distance, posY, posX, myPosY, myPosX) then
						if getConfigValue(TRP3_API.extended.CONFIG_SOUNDS_METHOD) == TRP3_API.extended.CONFIG_SOUNDS_METHODS.PLAY then
							Utils.music.playSoundFileID(soundID, channel, sender);
							--else
							-- TODO: ask permission in chat
						end
					end
				end
			end
		end
	end);

	Communications.broadcast.registerCommand(LOCAL_STOPSOUND_COMMAND, function(sender, soundID, channel, fadeout)
		if getConfigValue(TRP3_API.extended.CONFIG_SOUNDS_ACTIVE) then
			fadeout = (fadeout or 0) * 1000
			Utils.music.stopSoundID(soundID, channel, sender, fadeout);
		end
	end);

end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Sound history
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local historyFrame = TRP3_SoundsHistoryFrame;

local function onLinkClicked(self, link)

	local mode, id, channel, soundType = strsplit(":", link);

	if mode == "stop" then
		if channel == "Music" then
			Utils.music.stopMusic();
		else
			Utils.music.stopSound(id);
		end
	elseif mode == "replay" then
		if channel == "Music" then
			Utils.music.playMusic(id);
		elseif soundType == "1" then
			Utils.music.playSoundFileID(id, channel, Globals.player_id);
		else
			Utils.music.playSoundID(id, channel, Globals.player_id);
		end
	--elseif mode == "source" then
		-- TODO?
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
		string = string .. (" |Hreplay:%s:%s:%s|h|cffffff00[%s]|h"):format(handler.id, handler.channel, handler.soundFile and "1" or "0", loc.EX_SOUND_HISTORY_REPLAY);
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
	TRP3_API.RegisterCallback(TRP3_Addon, TRP3_Addon.Events.WORKFLOW_ON_LOADED, function()
		if TRP3_API.toolbar then
			local toolbarButton = {
				id = "bb_extended_sounds",
				icon = "trade_archaeology_delicatemusicbox",
				configText = loc.EX_SOUND_HISTORY,
				tooltip = loc.EX_SOUND_HISTORY,
				tooltipSub = loc.EX_SOUND_HISTORY_TT .. "\n\n" .. TRP3_API.FormatShortcutWithInstruction("LCLICK", loc.EX_SOUND_HISTORY_ACTION_OPEN)  .. "\n"  .. TRP3_API.FormatShortcutWithInstruction("RCLICK", loc.EX_SOUND_HISTORY_ACTION_STOP),
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

	historyFrame.container:SetTimeVisible(120.0);
	historyFrame.container:SetMaxLines(128);
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
