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
local getSpeechPrefixText = TRP3_API.ui.misc.getSpeechPrefixText;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effetc structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local security = TRP3_API.security.SECURITY_LEVEL;

local EFFECTS = {

	["MISSING"] = {
		codeReplacementFunc = function (_, id)
			return ("message(\"|cffff0000" .. loc("SCRIPT_UNKNOWN_EFFECT") .. ": %s\", 1); lastEffectReturn = nil;"):format(id);
		end,
		env = {
			message = "TRP3_API.utils.message.displayMessage",
		},
		secured = security.HIGH,
	},

	-- Graphic
	["text"] = {
		codeReplacementFunc = function (args)
			local text = args[1] or "";
			local type = tonumber(args[2]) or 1;
			return ("message(\"%s\", %s); lastEffectReturn = 0;"):format(text, type);
		end,
		env = {
			message = "TRP3_API.utils.message.displayMessage",
		},
		secured = security.HIGH,
	},

	-- Speech
	["speech_env"] = {
		codeReplacementFunc = function (args)
			local text = args[1] or "";
			return ("SendChatMessage(\"|| %s\", 'EMOTE'); lastEffectReturn = 0;"):format(text);
		end,
		env = {
			SendChatMessage = "SendChatMessage",
		},
		securedCodeReplacementFunc = function (args)
			local text = args[1] or "";
			return ("message(\"%s\", %s); lastEffectReturn = 0;"):format(text, 1);
		end,
		securedEnv = {
			message = "TRP3_API.utils.message.displayMessage",
		},
		secured = security.LOW,
	},
	["speech_npc"] = {
		codeReplacementFunc = function (args)
			local name = args[1] or "";
			local type = args[2] or TRP3_API.ui.misc.SPEECH_PREFIX.SAYS;
			local text = args[3] or "";
			return ("SendChatMessage(\"|| %s\", 'EMOTE'); lastEffectReturn = 0;"):format(getSpeechPrefixText(type, name, text));
		end,
		env = {
			SendChatMessage = "SendChatMessage",
		},
		securedCodeReplacementFunc = function (args)
			local name = args[1] or "";
			local type = args[2] or TRP3_API.ui.misc.SPEECH_PREFIX.SAYS;
			local text = args[3] or "";
			return ("message(\"%s\", %s); lastEffectReturn = 0;"):format(getSpeechPrefixText(type, name, text), 1);
		end,
		securedEnv = {
			message = "TRP3_API.utils.message.displayMessage",
		},
		secured = security.LOW,
	},

	-- Programmic
	["var_set_execenv"] = {
		codeReplacementFunc = function (args)
			local varName = args[1] or "var";
			local varValue = args[2] or "";
			return ("args.custom[\"%s\"] = \"%s\"; lastEffectReturn = 0;"):format(varName, varValue);
		end,
		env = {},
		secured = security.HIGH,
	},

	-- Sounds
	["sound_id_self"] = {
		codeReplacementFunc = function (args)
			local soundID = tonumber(args[2] or 0);
			local channel = args[1] or "SFX";
			local source = "Script"; -- TODO: get source
			return ("lastEffectReturn = playSoundID(%s, \"%s\", \"%s\");"):format(soundID, channel, source);
		end,
		env = {
			playSoundID = "TRP3_API.utils.music.playSoundID",
		},
		secured = security.HIGH,
	},

	["sound_music_self"] = {
		codeReplacementFunc = function (args)
			local path = (args[1] or ""):gsub("\\", "\\\\");
			return ("lastEffectReturn = playMusic(\"%s\");"):format(path);
		end,
		env = {
			playMusic = "TRP3_API.utils.music.playMusic",
		},
		secured = security.HIGH,
	},

	["sound_music_stop"] = {
		codeReplacementFunc = function ()
			return "stopMusic(); lastEffectReturn = 0;";
		end,
		env = {
			stopMusic = "TRP3_API.utils.music.stopMusic",
		},
		secured = security.HIGH,
	},

	["sound_id_local"] = {
		codeReplacementFunc = function (args)
			local soundID = tonumber(args[2] or 0);
			local channel = args[1] or "SFX";
			local distance = tonumber(args[3] or 0);
			local source = "Script"; -- TODO: get source
			return ("lastEffectReturn = playLocalSoundID(%s, \"%s\", %s, \"%s\");"):format(soundID, channel, distance, source);
		end,
		env = {
			playLocalSoundID = "TRP3_API.utils.music.playLocalSoundID",
		},
		securedCodeReplacementFunc = function (args)
			local soundID = tonumber(args[2] or 0);
			local channel = args[1] or "SFX";
			local source = "Script"; -- TODO: get source
			return ("lastEffectReturn = playSoundID(%s, \"%s\", \"%s\");"):format(soundID, channel, source);
		end,
		securedEnv = {
			playSoundID = "TRP3_API.utils.music.playSoundID",
		},
		secured = security.MEDIUM,
	},

	["sound_music_local"] = {
		codeReplacementFunc = function (args)
			local musicPath = (args[1] or ""):gsub("\\", "\\\\");
			local distance = tonumber(args[2] or 0);
			local source = "Script"; -- TODO: get source
			return ("lastEffectReturn = playLocalMusic(\"%s\", %s, \"%s\");"):format(musicPath, distance, source);
		end,
		env = {
			playLocalMusic = "TRP3_API.utils.music.playLocalMusic",
		},
		securedCodeReplacementFunc = function (args)
			local path = (args[1] or ""):gsub("\\", "\\\\");
			return ("lastEffectReturn = playMusic(\"%s\");"):format(path);
		end,
		securedEnv = {
			playMusic = "TRP3_API.utils.music.playMusic",
		},
		secured = security.MEDIUM,
	},

	-- Companions

	["companion_dismiss_mount"] = {
		codeReplacementFunc = function ()
			return "DismissCompanion(\"MOUNT\"); lastEffectReturn = 0;"
		end,
		env = {
			DismissCompanion = "DismissCompanion",
		},
		securedCodeReplacementFunc = function ()
			return "lastEffectReturn = 0;";
		end,
		secured = security.MEDIUM,
	},

	["companion_dismiss_critter"] = {
		codeReplacementFunc = function ()
			return "DismissCompanion(\"CRITTER\"); lastEffectReturn = 0;"
		end,
		env = {
			DismissCompanion = "DismissCompanion",
		},
		secured = security.HIGH,
	},

	["companion_random_critter"] = {
		codeReplacementFunc = function ()
			return "SummonRandomPet(); lastEffectReturn = 0;"
		end,
		env = {
			SummonRandomPet = "C_PetJournal.SummonRandomPet",
		},
		secured = security.HIGH,
	},

	-- DEBUG EFFECTs
	["debug_dump_text"] = {
		codeReplacementFunc = function (args)
			local value = tostring(args[1]);
			return ("debug(\"%s\", DEBUG);"):format(value);
		end,
		env = {
			debug = "TRP3_API.utils.log.log",
			DEBUG = "TRP3_API.utils.log.level.DEBUG",
		},
		secured = security.HIGH,
	},

	["debug_dump_arg"] = {
		codeReplacementFunc = function (args)
			local value = tostring(args[1]);
			return ("debug(\"Dumping args.custom['%s']\", DEBUG); dump(args.custom[\"%s\"]);"):format(value, value);
		end,
		env = {
			dump = "TRP3_API.utils.table.dump",
			debug = "TRP3_API.utils.log.log",
			DEBUG = "TRP3_API.utils.log.level.DEBUG",
		},
		secured = security.HIGH,
	},

	["debug_dump_args"] = {
		codeReplacementFunc = function ()
			return "dump(args);";
		end,
		env = {
			dump = "TRP3_API.utils.table.dump",
		},
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