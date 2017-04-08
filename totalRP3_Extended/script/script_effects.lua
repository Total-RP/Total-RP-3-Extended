----------------------------------------------------------------------------------
-- Total RP 3
-- Scripts : Effects
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@telkostrasz.be)
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

local assert, type, tostring, error, tonumber, pairs, unpack, wipe = assert, type, tostring, error, tonumber, pairs, unpack, wipe;
local loc = TRP3_API.locale.getText;

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
		return ("%s %s: %s"):format(npcName, loc("NPC_SAYS"), text);
	elseif speechPrefix == SPEECH_PREFIX.YELLS then
		return ("%s %s: %s"):format(npcName, loc("NPC_YELLS"), text);
	elseif speechPrefix == SPEECH_PREFIX.WHISPERS then
		return ("%s %s: %s"):format(npcName, loc("NPC_WHISPERS"), text);
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

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effetc structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local security = TRP3_API.security.SECURITY_LEVEL;

local EFFECTS = {

	["MISSING"] = {
		codeReplacementFunc = function (_, id)
			return ("message(\"|cffff0000" .. loc("SCRIPT_UNKNOWN_EFFECT") .. ": %s\", 1); args.LAST = nil;"):format(id);
		end,
		env = {
			message = "TRP3_API.utils.message.displayMessage",
		},
		secured = security.HIGH,
	},

	-- Graphic
	["text"] = {
		getCArgs = function(args)
			local text = args[1] or "";
			local type = tonumber(args[2]) or 1;
			return text, type;
		end,
		codeReplacementFunc = function (structure, args)
			local text, type = structure.getCArgs(args);
			return ("message(var(\"%s\", args), %s); args.LAST = 0;"):format(text, type);
		end,
		env = {
			message = "TRP3_API.utils.message.displayMessage",
		},
		method = function(structure, args, eArgs)
			local text, type = structure.getCArgs(args);
			TRP3_API.utils.message.displayMessage(TRP3_API.script.parseArgs(text, eArgs), type);
			eArgs.LAST = 0;
		end,
		secured = security.HIGH,
	},

	-- Speech
	["speech_env"] = {
		codeReplacementFunc = function (structure, args)
			local text = args[1] or "";
			return ("SendChatMessage(var(\"|| %s\", args), 'EMOTE'); args.LAST = 0;"):format(text);
		end,
		env = {
			SendChatMessage = "SendChatMessage",
		},
		method = function(structure, cArgs, eArgs)
			local text = cArgs[1] or "";
			SendChatMessage(TRP3_API.script.parseArgs("|| " .. text, eArgs), 'EMOTE');
			eArgs.LAST = 0;
		end,
		securedCodeReplacementFunc = function (structure, args)
			local text = args[1] or "";
			return ("message(var(\"%s\", args), 1); args.LAST = 0;"):format(text);
		end,
		securedEnv = {
			message = "TRP3_API.utils.message.displayMessage",
		},
		securedMethod = function(structure, cArgs, eArgs)
			local text = cArgs[1] or "";
			TRP3_API.utils.message.displayMessage(TRP3_API.script.parseArgs(text, eArgs), 1);
			eArgs.LAST = 0;
		end,
		secured = security.LOW,
	},
	["speech_npc"] = {
		getCArgs = function(args)
			local name = args[1] or "";
			local type = args[2] or TRP3_API.ui.misc.SPEECH_PREFIX.SAYS;
			local text = args[3] or "";
			return name, type, text;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local name, type, text = structure.getCArgs(cArgs);
			return ("SendChatMessage(var(\"|| %s\", args), 'EMOTE'); args.LAST = 0;"):format(getSpeechPrefixText(type, name, text));
		end,
		env = {
			SendChatMessage = "SendChatMessage",
		},
		method = function(structure, cArgs, eArgs)
			local name, type, text = structure.getCArgs(cArgs);
			SendChatMessage(TRP3_API.script.parseArgs("|| " .. getSpeechPrefixText(type, name, text), eArgs), 'EMOTE');
			eArgs.LAST = 0;
		end,
		securedCodeReplacementFunc = function (structure, cArgs)
			local name, type, text = structure.getCArgs(cArgs);
			return ("message(var(\"%s\", args), 1); args.LAST = 0;"):format(getSpeechPrefixText(type, name, text));
		end,
		securedEnv = {
			message = "TRP3_API.utils.message.displayMessage",
		},
		securedMethod = function(structure, cArgs, eArgs)
			local name, type, text = structure.getCArgs(cArgs);
			TRP3_API.utils.message.displayMessage(TRP3_API.script.parseArgs(getSpeechPrefixText(type, name, text), eArgs), 1);
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
		codeReplacementFunc = function (structure, cArgs)
			local channel, text = structure.getCArgs(cArgs);
			return ("SendChatMessage(var(\"%s\", args), \"%s\"); args.LAST = 0;"):format(text, getSpeechChannel(channel));
		end,
		env = {
			SendChatMessage = "SendChatMessage",
		},
		method = function(structure, cArgs, eArgs)
			local channel, text = structure.getCArgs(cArgs);
			SendChatMessage(TRP3_API.script.parseArgs(text, eArgs), getSpeechChannel(channel));
			eArgs.LAST = 0;
		end,
		securedCodeReplacementFunc = function (structure, cArgs)
			local prefix, text = structure.getCArgs(cArgs);
			return ("message(var(\"%s\", args), 1); args.LAST = 0;"):format(getSpeech(text, prefix));
		end,
		securedEnv = {
			message = "TRP3_API.utils.message.displayMessage",
		},
		securedMethod = function(structure, cArgs, eArgs)
			local prefix, text = structure.getCArgs(cArgs);
			TRP3_API.utils.message.displayMessage(TRP3_API.script.parseArgs(getSpeech(text, prefix), eArgs), 1);
			eArgs.LAST = 0;
		end,
		secured = security.LOW,
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
		codeReplacementFunc = function (structure, cArgs)
			local source, operationType, varName, varValue = structure.getCArgs(cArgs);
			return ("setVar(args, \"%s\", \"%s\", \"%s\", var(\"%s\", args)); args.LAST = 0;"):format(source, operationType, varName, varValue);
		end,
		method = function(structure, cArgs, eArgs)
			local source, operationType, varName, varValue = structure.getCArgs(cArgs);
			TRP3_API.script.setVar(eArgs, source, operationType, varName, TRP3_API.script.parseArgs(varValue, eArgs));
			eArgs.LAST = 0;
		end,
		env = {
			setVar = "TRP3_API.script.setVar",
		},
		secured = security.HIGH,
	},

	["var_operand"] = {
		getCArgs = function(args)
			local varName = args[1] or "var";
			local source = args[2] or "w";
			local operandID = args[3] or "random";
			local operandArgs = args[4];
			local operand = TRP3_API.script.getOperand(operandID);
			local code = "";
			if operand and operand.codeReplacement then
				code = operand.codeReplacement(operandArgs);
			end
			return source, varName, code, operand;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local source, varName, code, operand = structure.getCArgs(cArgs);
			return ("setVar(args, \"%s\", \"=\", \"%s\", tostring(%s)); args.LAST = 0;"):format(source, varName, code), operand.env;
		end,
		methodTODO = function(structure, cArgs, eArgs)
			local source, varName, code, operand = structure.getCArgs(cArgs);
			TRP3_API.script.setVar(eArgs, source, "=", varName, tostring(code())); -- Use operand method
			eArgs.LAST = 0;
		end,
		env = {
			setVar = "TRP3_API.script.setVar",
		},
		secured = security.HIGH,
	},

	["signal_send"] = {
		getCArgs = function(args)
			local varName = args[1] or "";
			local varValue = args[2] or "";
			return varName, varValue;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local varName, varValue = structure.getCArgs(cArgs);
			return ("sendSignal(\"%s\", var(\"%s\", args)); args.LAST = 0;"):format(varName, varValue);
		end,
		method = function(structure, cArgs, eArgs)
			local varName, varValue = structure.getCArgs(cArgs);
			TRP3_API.extended.sendSignal(varName, TRP3_API.script.parseArgs(varValue, eArgs));
			eArgs.LAST = 0;
		end,
		env = {
			sendSignal = "TRP3_API.extended.sendSignal",
		},
		secured = security.HIGH,
	},

	["run_workflow"] = {
		getCArgs = function(args)
			local source = args[1] or "o";
			local id = args[2] or "";
			return source, id;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local source, id = structure.getCArgs(cArgs);
			return ("runWorkflow(args, \"%s\", \"%s\"); args.LAST = 0;"):format(source, id);
		end,
		method = function(structure, cArgs, eArgs)
			local varName, varValue = structure.getCArgs(cArgs);
			TRP3_API.script.runWorkflow(eArgs, varName, varValue);
			eArgs.LAST = 0;
		end,
		env = {
			runWorkflow = "TRP3_API.script.runWorkflow",
		},
		secured = security.HIGH,
	},

	-- Sounds
	["sound_id_self"] = {
		getCArgs = function(args)
			local soundID = tonumber(args[2] or 0);
			local channel = args[1] or "SFX";
			local source = "Script"; -- TODO: get source
			return soundID, channel, source;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local soundID, channel, source = structure.getCArgs(cArgs);
			return ("args.LAST = playSoundID(%s, \"%s\", \"%s\");"):format(soundID, channel, source);
		end,
		method = function(structure, cArgs, eArgs)
			local soundID, channel, source = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.utils.music.playSoundID(soundID, channel, source);
		end,
		env = {
			playSoundID = "TRP3_API.utils.music.playSoundID",
		},
		secured = security.HIGH,
	},

	["sound_music_self"] = {
		codeReplacementFunc = function (structure, args)
			local path = (args[1] or ""):gsub("\\", "\\\\");
			return ("args.LAST = playMusic(\"%s\");"):format(path);
		end,
		method = function(structure, cArgs, eArgs)
			local path = (cArgs[1] or ""):gsub("\\", "\\\\");
			eArgs.LAST = TRP3_API.utils.music.playMusic(path);
		end,
		env = {
			playMusic = "TRP3_API.utils.music.playMusic",
		},
		secured = security.HIGH,
	},

	["sound_music_stop"] = {
		codeReplacementFunc = function ()
			return "stopMusic(); args.LAST = 0;";
		end,
		method = function(structure, cArgs, eArgs)
			TRP3_API.utils.music.stopMusic();
			eArgs.LAST = 0;
		end,
		env = {
			stopMusic = "TRP3_API.utils.music.stopMusic",
		},
		secured = security.HIGH,
	},

	["sound_id_local"] = {
		getCArgs = function(args)
			local soundID = tonumber(args[2] or 0);
			local channel = args[1] or "SFX";
			local distance = tonumber(args[3] or 0);
			local source = "Script"; -- TODO: get source
			return soundID, channel, distance, source;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local soundID, channel, distance, source = structure.getCArgs(cArgs);
			return ("args.LAST = playLocalSoundID(%s, \"%s\", %s, \"%s\");"):format(soundID, channel, distance, source);
		end,
		method = function(structure, cArgs, eArgs)
			local soundID, channel, distance, source = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.utils.music.playLocalSoundID(soundID, channel, distance, source);
		end,
		env = {
			playLocalSoundID = "TRP3_API.utils.music.playLocalSoundID",
		},
		securedCodeReplacementFunc = function (structure, cArgs)
			local soundID, channel, _, source = structure.getCArgs(cArgs);
			return ("args.LAST = playSoundID(%s, \"%s\", \"%s\");"):format(soundID, channel, source);
		end,
		methodSecured = function(structure, cArgs, eArgs)
			local soundID, channel, _, source = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.utils.music.playSoundID(soundID, channel, source);
		end,
		securedEnv = {
			playSoundID = "TRP3_API.utils.music.playSoundID",
		},
		secured = security.MEDIUM,
	},

	["sound_music_local"] = {
		getCArgs = function(args)
			local musicPath = (args[1] or ""):gsub("\\", "\\\\");
			local distance = tonumber(args[2] or 0);
			local source = "Script"; -- TODO: get source
			return musicPath, distance, source;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local musicPath, distance, source = structure.getCArgs(cArgs);
			return ("args.LAST = playLocalMusic(\"%s\", %s, \"%s\");"):format(musicPath, distance, source);
		end,
		method = function(structure, cArgs, eArgs)
			local musicPath, distance, source = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.utils.music.playLocalMusic(musicPath, distance, source);
		end,
		env = {
			playLocalMusic = "TRP3_API.utils.music.playLocalMusic",
		},
		securedCodeReplacementFunc = function (structure, cArgs)
			local musicPath = structure.getCArgs(cArgs);
			return ("args.LAST = playMusic(\"%s\", %s, \"%s\");"):format(musicPath);
		end,
		methodSecured = function(structure, cArgs, eArgs)
			local musicPath = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.utils.music.playMusic(musicPath);
		end,
		securedEnv = {
			playMusic = "TRP3_API.utils.music.playMusic",
		},
		secured = security.MEDIUM,
	},

	-- Companions
	["companion_dismiss_mount"] = {
		codeReplacementFunc = function ()
			return "DismissCompanion(\"MOUNT\"); args.LAST = 0;"
		end,
		method = function(structure, cArgs, eArgs)
			DismissCompanion("MOUNT");
			eArgs.LAST = 0;
		end,
		env = {
			DismissCompanion = "DismissCompanion",
		},
		securedCodeReplacementFunc = function ()
			return "args.LAST = 0;";
		end,
		methodSecured = function(structure, cArgs, eArgs)
			eArgs.LAST = 0;
		end,
		secured = security.MEDIUM,
	},

	["companion_dismiss_critter"] = {
		codeReplacementFunc = function ()
			return "DismissCompanion(\"CRITTER\"); args.LAST = 0;"
		end,
		method = function(structure, cArgs, eArgs)
			DismissCompanion("CRITTER");
			eArgs.LAST = 0;
		end,
		env = {
			DismissCompanion = "DismissCompanion",
		},
		secured = security.HIGH,
	},

	["companion_random_critter"] = {
		codeReplacementFunc = function ()
			return "SummonRandomPet(); args.LAST = 0;"
		end,
		method = function(structure, cArgs, eArgs)
			SummonRandomPet();
			eArgs.LAST = 0;
		end,
		env = {
			SummonRandomPet = "C_PetJournal.SummonRandomPet",
		},
		secured = security.HIGH,
	},

	["companion_summon_mount"] = {
		codeReplacementFunc = function (args)
			local mountId = tonumber(args[1] or 0);
			return ("SummonByID(%s); args.LAST = 0;"):format(mountId);
		end,
		method = function(structure, cArgs, eArgs)
			local mountId = tonumber(cArgs[1] or 0);
			SummonByID(mountId);
			eArgs.LAST = 0;
		end,
		env = {
			SummonByID = "C_MountJournal.SummonByID",
		},
		securedCodeReplacementFunc = function ()
			return "args.LAST = 0;";
		end,
		secured = security.MEDIUM,
	},

	-- DEBUG EFFECTs
	["debug_dump_text"] = {
		codeReplacementFunc = function (args)
			local value = tostring(args[1]);
			return ("debug(var(\"%s\", args), DEBUG);"):format(value);
		end,
		method = function(structure, cArgs, eArgs)
			local value = tostring(cArgs[1]);
			TRP3_API.utils.log.log(TRP3_API.script.parseArgs("%s", eArgs), TRP3_API.utils.log.level.DEBUG);
			eArgs.LAST = 0;
		end,
		env = {
			debug = "TRP3_API.utils.log.log",
			DEBUG = "TRP3_API.utils.log.level.DEBUG",
		},
		secured = security.HIGH,
	},

	["debug_dump_args"] = {
		codeReplacementFunc = function ()
			return "dump(args);";
		end,
		method = function(structure, cArgs, eArgs)
			TRP3_API.utils.table.dump(eArgs);
			eArgs.LAST = 0;
		end,
		env = {
			dump = "TRP3_API.utils.table.dump",
		},
		secured = security.HIGH,
	},

	-- Camera effects
	["cam_zoom_in"] = {
		codeReplacementFunc = function (args)
			local distance = args[1] or "0";
			return ("CameraZoomIn(tonumber(var(\"%s\", args)) or 0); args.LAST = 0;"):format(distance);
		end,
		method = function(structure, cArgs, eArgs)
			local distance = cArgs[1] or "0";
			CameraZoomIn(tonumber(TRP3_API.script.parseArgs(distance, eArgs)) or 0);
			eArgs.LAST = 0;
		end,
		env = {
			CameraZoomIn = "CameraZoomIn",
		},
		secured = security.HIGH,
	},
	["cam_zoom_out"] = {
		codeReplacementFunc = function (args)
			local distance = args[1] or "0";
			return ("CameraZoomOut(tonumber(var(\"%s\", args)) or 0); args.LAST = 0;"):format(distance);
		end,
		method = function(structure, cArgs, eArgs)
			local distance = cArgs[1] or "0";
			CameraZoomOut(tonumber(TRP3_API.script.parseArgs(distance, eArgs)) or 0);
			eArgs.LAST = 0;
		end,
		env = {
			CameraZoomOut = "CameraZoomOut",
		},
		secured = security.HIGH,
	},
	["cam_save"] = {
		codeReplacementFunc = function (args)
			local slot = tonumber(args[1]) or 1;
			return ("SaveView(%s); args.LAST = 0;"):format(slot);
		end,
		method = function(structure, cArgs, eArgs)
			local slot = tonumber(cArgs[1]) or 1;
			SaveView(slot);
			eArgs.LAST = 0;
		end,
		env = {
			SaveView = "SaveView",
		},
		secured = security.HIGH,
	},
	["cam_load"] = {
		codeReplacementFunc = function (args)
			local slot = tonumber(args[1]) or 1;
			return ("SetView(%s); args.LAST = 0;"):format(slot);
		end,
		method = function(structure, cArgs, eArgs)
			local slot = tonumber(cArgs[1]) or 1;
			SetView(slot);
			eArgs.LAST = 0;
		end,
		env = {
			SetView = "SetView",
		},
		secured = security.HIGH,
	},

	-- SCRIPT
	["script"] = {
		codeReplacementFunc = function (structure, args)
			local value = tostring(args[1]);
			return ("script(\"%s\", args, false);"):format(value);
		end,
		securedCodeReplacementFunc = function (structure, args)
			local value = tostring(args[1]);
			return ("script(\"%s\", args, true);"):format(value);
		end,
		env = {
			script = "TRP3_API.script.runLuaScriptEffect",
		},
		secured = security.LOW,
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