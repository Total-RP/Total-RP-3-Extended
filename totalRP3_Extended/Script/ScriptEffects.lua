-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

-- Fixed the "Summon Mount" effect (Paul Corlay)

local _, Private_TRP3E = ...;

---@type SecuredMacroCommandsEnclave
local SecuredMacroCommandsEnclave = Private_TRP3E.SecuredMacroCommandsEnclave;

local assert, type, tostring, tonumber, pairs = assert, type, tostring, tonumber, pairs;
local loc = TRP3_API.loc;
local stEtN = TRP3_API.utils.str.emptyToNil;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- NPC speech
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local SPEECH_PREFIX = {
	SAYS = "/s",
	YELLS = "/y",
	WHISPERS = "/w",
	EMOTES = "/e"
}
TRP3_API.ui.misc.SPEECH_PREFIX = SPEECH_PREFIX;

local SPEECH_CHANNEL = {
	[SPEECH_PREFIX.SAYS] = "SAY",
	[SPEECH_PREFIX.YELLS] = "YELL",
	[SPEECH_PREFIX.EMOTES] = "EMOTE",
}

local function getSpeechPrefixText(speechPrefix, npcName, text)
	if speechPrefix == SPEECH_PREFIX.SAYS then
		return ("%s %s: %s"):format(npcName, loc.NPC_SAYS, text);
	elseif speechPrefix == SPEECH_PREFIX.YELLS then
		return ("%s %s: %s"):format(npcName, loc.NPC_YELLS, text);
	elseif speechPrefix == SPEECH_PREFIX.WHISPERS then
		return ("%s %s: %s"):format(npcName, loc.NPC_WHISPERS, text);
	elseif speechPrefix == SPEECH_PREFIX.EMOTES then
		return ("%s %s"):format(npcName, text);
	end
	return "(error in getSpeechPrefixText: " .. tostring(speechPrefix) .. ")";
end
TRP3_API.ui.misc.getSpeechPrefixText = getSpeechPrefixText;

local function getSpeechChannel(speechPrefix)
	return SPEECH_CHANNEL[speechPrefix or SPEECH_PREFIX.SAYS] or "SAY";
end

local function getSpeech(text, speechPrefix)
	return getSpeechPrefixText(speechPrefix, UnitName("player"), text);
end
TRP3_API.ui.misc.getSpeech = getSpeech;

local FOR_THE_ALLIANCE_EMOTE = "FORTHEALLIANCE"
local FOR_THE_HORDE_EMOTE = "FORTHEHORDE"

--- Swaps faction restricted emote tokens if needed.
--- For example, only the Alliance can do /forthealliance and only the Horde can do /forthehorde.
---@return string An emote token that was checked against the player faction
local function swapFactionRestrictedEmotesIfNeeded(emoteToken)
	if emoteToken == FOR_THE_ALLIANCE_EMOTE or emoteToken == FOR_THE_HORDE_EMOTE then
		local factionGroup = UnitFactionGroup("player");
		if emoteToken == FOR_THE_ALLIANCE_EMOTE and factionGroup == "Horde" then
			emoteToken = FOR_THE_HORDE_EMOTE
		elseif emoteToken == FOR_THE_HORDE_EMOTE and factionGroup == "Alliance" then
			emoteToken = FOR_THE_ALLIANCE_EMOTE
		end
	end
	return emoteToken
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effetc structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local operandCode = [[local func = function(args)
	return %s;
end;
setfenv(func, {});
return func;]];
local IMPORT_PATTERN = "local %s = %s;";

local security = TRP3_API.security.SECURITY_LEVEL;

local EFFECTS = {

	["MISSING"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			TRP3_API.utils.message.displayMessage("|cffff0000" .. loc.SCRIPT_UNKNOWN_EFFECT, 1);
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	-- Graphic
	["text"] = {
		getCArgs = function(args)
			local text = args[1] or "";
			local textType = tonumber(args[2]) or 1;
			return text, textType;
		end,
		method = function(structure, args, eArgs)
			local text, textType = structure.getCArgs(args);
			TRP3_API.utils.message.displayMessage(TRP3_API.script.parseArgs(text, eArgs), textType);
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	-- Speech
	["speech_env"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local text = cArgs[1] or "";
			C_ChatInfo.SendChatMessage(TRP3_API.script.parseArgs("|| " .. text, eArgs), 'EMOTE');
			eArgs.LAST = 0;
		end,
		securedMethod = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local text = cArgs[1] or "";
			TRP3_API.utils.message.displayMessage(TRP3_API.script.parseArgs(text, eArgs), 1);
			eArgs.LAST = 0;
		end,
		secured = security.LOW,
	},
	["speech_npc"] = {
		getCArgs = function(args)
			local name = args[1] or "";
			local speechType = args[2] or TRP3_API.ui.misc.SPEECH_PREFIX.SAYS;
			local text = args[3] or "";
			return name, speechType, text;
		end,
		method = function(structure, cArgs, eArgs)
			local name, speechType, text = structure.getCArgs(cArgs);
			C_ChatInfo.SendChatMessage(TRP3_API.script.parseArgs("|| " .. getSpeechPrefixText(speechType, name, text), eArgs), 'EMOTE');
			eArgs.LAST = 0;
		end,
		securedMethod = function(structure, cArgs, eArgs)
			local name, speechType, text = structure.getCArgs(cArgs);
			TRP3_API.utils.message.displayMessage(TRP3_API.script.parseArgs(getSpeechPrefixText(speechType, name, text), eArgs), 1);
			eArgs.LAST = 0;
		end,
		secured = security.LOW,
	},
	["speech_player"] = {
		getCArgs = function(args)
			local channel = args[1] or TRP3_API.ui.misc.SPEECH_PREFIX.SAYS;
			local text = args[2] or "";
			return channel, text;
		end,
		method = function(structure, cArgs, eArgs)
			local channel, text = structure.getCArgs(cArgs);

			local registration = TRP3_API.RegisterCallback(TRP3_API.GameEvents, "ADDON_ACTION_BLOCKED", function(_, addon)
				if addon == "totalRP3_Extended" then
					TRP3_API.utils.message.displayMessage(loc.ERROR_SPEECH_EFFECT, 4);
				end
			end);

			C_ChatInfo.SendChatMessage(TRP3_API.script.parseArgs(text, eArgs), getSpeechChannel(channel));
			registration:Unregister();

			eArgs.LAST = 0;
		end,
		securedMethod = function(structure, cArgs, eArgs)
			local prefix, text = structure.getCArgs(cArgs);
			TRP3_API.utils.message.displayMessage(TRP3_API.script.parseArgs(getSpeech(text, prefix), eArgs), 1);
			eArgs.LAST = 0;
		end,
		secured = security.LOW,
	},
	["do_emote"] = {
		getCArgs = function(args)
			local emoteToken = args[1] or "";
			return emoteToken;
		end,
		method = function(structure, cArgs, eArgs)
			local emoteToken = structure.getCArgs(cArgs);
			emoteToken = swapFactionRestrictedEmotesIfNeeded(emoteToken);
			if stEtN(emoteToken) then
				C_ChatInfo.PerformEmote(emoteToken);
			end
			eArgs.LAST = 0;
		end,
		securedMethod = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			-- TODO: Secured emote effect.
			local emoteToken = structure.getCArgs(cArgs);
			emoteToken = swapFactionRestrictedEmotesIfNeeded(emoteToken);
			if stEtN(emoteToken) then
				TRP3_API.utils.message.displayMessage("/" .. emoteToken:lower(), 1);
			end
			eArgs.LAST = 0;
		end,
		secured = security.MEDIUM,
	},

	-- Expert
	["var_object"] = {
		getCArgs = function(args)
			local source = args[1] or "w";
			local operationType = args[2] or "i";
			local varName = args[3] or "var";
			local varValue = args[4] or "0";
			return source, operationType, varName, varValue;
		end,
		method = function(structure, cArgs, eArgs)
			local source, operationType, varName, varValue = structure.getCArgs(cArgs);
			TRP3_API.script.setVar(eArgs, source, operationType, varName, TRP3_API.script.parseArgs(varValue, eArgs));
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	["var_operand"] = {
		getCArgs = function(args)
			local varName = args[1] or "var";
			local source = args[2] or "w";
			local operandID = args[3] or "random";
			local operandArgs = args[4];
			---@type TotalRP3_Extended_Operand
			local operand = TRP3_API.script.getOperand(operandID);
			local code = "";
			if operand and operand.CodeReplacement then
				code = operand:CodeReplacement(operandArgs);
			end
			return source, varName, code, operand;
		end,
		method = function(structure, cArgs, eArgs)
			local source, varName, code, operand = structure.getCArgs(cArgs);
			code = operandCode:format(code);
			for alias, global in pairs(operand.env) do
				code = IMPORT_PATTERN:format(alias, global) .. "\n" .. code;
			end
			-- Generating factory
			local func, errorMessage = loadstring(code, "Generated operand code");
			if not func then
				print(errorMessage);
				return nil, code;
			end
			TRP3_API.script.setVar(eArgs, source, "=", varName, func()(eArgs)); -- Use operand method
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	["signal_send"] = {
		getCArgs = function(args)
			local varName = args[1] or "";
			local varValue = args[2] or "";
			return varName, varValue;
		end,
		method = function(structure, cArgs, eArgs)
			local varName, varValue = structure.getCArgs(cArgs);
			TRP3_API.extended.sendSignal(varName, TRP3_API.script.parseArgs(varValue, eArgs));
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	["run_workflow"] = {
		getCArgs = function(args)
			local source = args[1] or "o";
			local id = args[2] or "";
			return source, id;
		end,
		method = function(structure, cArgs, eArgs)
			local workflowSource, workflowID = structure.getCArgs(cArgs);
			TRP3_API.script.runWorkflow(eArgs, workflowSource, workflowID);
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	-- Sounds
	["sound_id_self"] = {
		getCArgs = function(args)
			local soundID = tonumber(args[2] or 0);
			local channel = args[1] or "SFX";
			local source = "Script"; -- TODO: get source
			local isSoundFileID = args[3] or false;
			return soundID, channel, source, isSoundFileID;
		end,
		method = function(structure, cArgs, eArgs)
			local soundID, channel, source, isSoundFileID = structure.getCArgs(cArgs);
			if isSoundFileID then
				eArgs.LAST = TRP3_API.utils.music.playSoundFileID(soundID, channel, source);
			else
				eArgs.LAST = TRP3_API.utils.music.playSoundID(soundID, channel, source);
			end
		end,
		secured = security.HIGH,
	},

	["sound_id_stop"] = {
		getCArgs = function(args)
			local soundID = tonumber(args[2] or 0);
			local channel = args[1] or "SFX";
			local fadeout = args[3] or 0;
			return soundID, channel, fadeout;
		end,
		method = function(structure, cArgs, eArgs)
			local soundID, channel, fadeout = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.utils.music.stopSoundID(soundID, channel, nil, fadeout * 1000);
		end,
		secured = security.HIGH,
	},

	["sound_music_self"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local musicPath = cArgs[1] or "";
			local musicID = tonumber(musicPath) or TRP3_API.utils.music.convertPathToID(musicPath) or musicPath;
			eArgs.LAST = TRP3_API.utils.music.playMusic(musicID);
		end,
		secured = security.HIGH,
	},

	["sound_music_stop"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			TRP3_API.utils.music.stopMusic();
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	["sound_id_local"] = {
		getCArgs = function(args)
			local soundID = tonumber(args[2] or 0);
			local channel = args[1] or "SFX";
			local distance = tonumber(args[3] or 0);
			local source = "Script"; -- TODO: get source
			local isSoundFileID = args[4] or false;
			return soundID, channel, distance, source, isSoundFileID;
		end,
		method = function(structure, cArgs, eArgs)
			local soundID, channel, distance, _, isSoundFileID = structure.getCArgs(cArgs);
			if isSoundFileID then
				eArgs.LAST = TRP3_API.utils.music.playLocalSoundFileID(soundID, channel, distance);
			else
				eArgs.LAST = TRP3_API.utils.music.playLocalSoundID(soundID, channel, distance);
			end
		end,
		securedMethod = function(structure, cArgs, eArgs)
			local soundID, channel, _, source, isSoundFileID = structure.getCArgs(cArgs);
			if isSoundFileID then
				eArgs.LAST = TRP3_API.utils.music.playSoundFileID(soundID, channel, source);
			else
				eArgs.LAST = TRP3_API.utils.music.playSoundID(soundID, channel, source);
			end
		end,
		secured = security.MEDIUM,
	},

	["sound_id_local_stop"] = {
		getCArgs = function(args)
			local soundID = tonumber(args[2] or 0);
			local channel = args[1] or "SFX";
			local fadeout = args[3] or 0;
			return soundID, channel, fadeout;
		end,
		method = function(structure, cArgs, eArgs)
			local soundID, channel, fadeout = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.utils.music.stopLocalSoundID(soundID, channel, fadeout);
		end,
		secured = security.HIGH,
	},

	["sound_music_local"] = {
		getCArgs = function(args)
			local musicPath = args[1] or "";
			local musicID = tonumber(musicPath) or TRP3_API.utils.music.convertPathToID(musicPath) or musicPath;
			local distance = tonumber(args[2] or 0);
			local source = "Script"; -- TODO: get source
			return musicID, distance, source;
		end,
		method = function(structure, cArgs, eArgs)
			local musicID, distance = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.utils.music.playLocalMusic(musicID, distance);
		end,
		securedMethod = function(structure, cArgs, eArgs)
			local musicID = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.utils.music.playMusic(musicID);
		end,
		secured = security.MEDIUM,
	},

	["sound_music_local_stop"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			TRP3_API.utils.music.stopLocalMusic();
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	-- Companions
	["companion_dismiss_mount"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			DismissCompanion("MOUNT");
			eArgs.LAST = 0;
		end,
		securedMethod = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			eArgs.LAST = 0;
		end,
		secured = security.MEDIUM,
	},

	["companion_dismiss_critter"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			if C_PetJournal.GetSummonedPetGUID() then
				C_PetJournal.SummonPetByGUID(C_PetJournal.GetSummonedPetGUID());
			end
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	["companion_random_critter"] = {
		getCArgs = function(args)
			local summonFav = args[1] or false;
			return summonFav;
		end,
		method = function(structure, cArgs, eArgs)
			local summonFav = structure.getCArgs(cArgs);
			C_PetJournal.SummonRandomPet(summonFav);
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	["companion_summon_mount"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local mountId = tonumber(cArgs[1] or 0);
			C_MountJournal.SummonByID(mountId);
			eArgs.LAST = 0;
		end,
		securedMethod = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			eArgs.LAST = 0;
		end,
		secured = security.MEDIUM,
	},

	-- Camera effects
	["cam_zoom_in"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local distance = cArgs[1] or "0";
			CameraZoomIn(tonumber(TRP3_API.script.parseArgs(distance, eArgs)) or 0);
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},
	["cam_zoom_out"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local distance = cArgs[1] or "0";
			CameraZoomOut(tonumber(TRP3_API.script.parseArgs(distance, eArgs)) or 0);
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},
	["cam_save"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local slot = tonumber(cArgs[1]) or 1;
			SaveView(slot);
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},
	["cam_load"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local slot = tonumber(cArgs[1]) or 1;
			SetView(slot);
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	-- SCRIPT
	["script"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local value = tostring(cArgs[1]);
			TRP3_API.script.runLuaScriptEffect(value, eArgs, false);
			eArgs.LAST = 0;
		end,
		securedMethod = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local value = tostring(cArgs[1]);
			TRP3_API.script.runLuaScriptEffect(value, eArgs, true);
			eArgs.LAST = 0;
		end,
		secured = security.LOW,
	},

	-- SECURED MACRO
	["secure_macro"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local macroText = tostring(cArgs[1]);
			macroText = TRP3_API.script.parseArgs(macroText, eArgs);
			SecuredMacroCommandsEnclave:AddSecureCommands(macroText);
			eArgs.LAST = 0
		end,
		securedMethod = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			local macroText = tostring(cArgs[1]);
			macroText = TRP3_API.script.parseArgs(macroText, eArgs);
			TRP3_API.utils.message.displayMessage(loc.EFFECT_SECURE_MACRO_BLOCKED .. " " .. tostring(macroText), 1);
			eArgs.LAST = 0
		end,
		secured = security.LOW,
	},

	-- PROMPT
	["var_prompt"] = {
		method = function(structure, cArgs, eArgs) -- luacheck: ignore 212
			C_Timer.After(0.1, function()
				TRP3_API.popup.showTextInputPopup(cArgs[1] or "",
				function(value)
					TRP3_API.script.setVar(eArgs, cArgs[3] or "o", "=", cArgs[2] or "var", value);
					if cArgs[4] and cArgs[4] ~= "" then
						TRP3_API.script.runWorkflow(eArgs, cArgs[5] or "o", cArgs[4])
					end
				end,
				function()
					if cArgs[4] and cArgs[4] ~= "" then
						TRP3_API.script.runWorkflow(eArgs, cArgs[5] or "o", cArgs[4]);
					end
				end, "");
			eArgs.LAST = 0;
			end);
		end,
		secured = security.HIGH,
	},
}


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function registerEffect(effectID, effect)
	assert(type(effect) == "table" and effectID, "Effect must have an id.");
	assert(not EFFECTS[effectID], "Already registered effect id: " .. effectID);
	EFFECTS[effectID] = effect;
end
TRP3_API.script.registerEffect = registerEffect;

TRP3_API.script.registerEffects = function(effects)
	for effectID, effect in pairs(effects) do
		registerEffect(effectID, effect);
	end
end

TRP3_API.script.getEffect = function(effectID)
	return EFFECTS[effectID];
end
