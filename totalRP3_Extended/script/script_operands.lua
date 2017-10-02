----------------------------------------------------------------------------------
-- Total RP 3
-- Scripts : Operands
--	---------------------------------------------------------------------------
--	Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
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

-- Added achievement condition (Paul Corlay)

local assert, type, tonumber = assert, type, tonumber;

local OPERANDS = {

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- UNIT VALUE
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	["unit_name"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("UnitName(\"%s\")"):format(unitID);
		end,
		env = {
			["UnitName"] = "UnitName",
		},
	},

	["unit_id"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("UnitID(\"%s\")"):format(unitID);
		end,
		env = {
			["UnitID"] = "TRP3_API.utils.str.getUnitID",
		},
	},

	["unit_npc_id"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("getUnitNPCID(\"%s\")"):format(unitID);
		end,
		env = {
			["getUnitNPCID"] = "TRP3_API.utils.str.getUnitNPCID",
		},
	},

	["unit_guild"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("GetGuildName(\"%s\")"):format(unitID);
		end,
		env = {
			["GetGuildName"] = "TRP3_API.utils.str.GetGuildName",
		},
	},

	["unit_guild_rank"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("GetGuildRank(\"%s\")"):format(unitID);
		end,
		env = {
			["GetGuildRank"] = "TRP3_API.utils.str.GetGuildRank",
		},
	},

	["unit_class"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("(GetClass(\"%s\") or \"\"):lower()"):format(unitID);
		end,
		env = {
			["GetClass"] = "TRP3_API.utils.str.GetClass",
		},
	},

	["unit_race"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("(GetRace(\"%s\") or \"\"):lower()"):format(unitID);
		end,
		env = {
			["GetRace"] = "TRP3_API.utils.str.GetRace",
		},
	},

	["unit_sex"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("UnitSex(\"%s\") or 1"):format(unitID);
		end,
		env = {
			["UnitSex"] = "UnitSex",
		},
	},

	["unit_faction"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("(GetFaction(\"%s\") or \"\"):lower()"):format(unitID);
		end,
		env = {
			["GetFaction"] = "TRP3_API.utils.str.GetFaction",
		},
	},

	["unit_classification"] = {
		numeric = true,
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("UnitClassification(\"%s\")"):format(unitID);
		end,
		env = {
			["UnitClassification"] = "UnitClassification",
		},
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- UNIT NUMERIC
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	["unit_health"] = {
		numeric = true,
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("UnitHealth(\"%s\")"):format(unitID);
		end,
		env = {
			["UnitHealth"] = "UnitHealth",
		},
	},

	["unit_level"] = {
		numeric = true,
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("UnitLevel(\"%s\")"):format(unitID);
		end,
		env = {
			["UnitLevel"] = "UnitLevel",
		},
	},

	["unit_speed"] = {
		numeric = true,
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("GetUnitSpeed(\"%s\")"):format(unitID);
		end,
		env = {
			["GetUnitSpeed"] = "GetUnitSpeed",
		},
	},

	["unit_position_x"] = {
		numeric = true,
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("({UnitPosition(\"%s\")})[2]"):format(unitID);
		end,
		env = {
			["UnitPosition"] = "UnitPosition",
		},
	},

	["unit_position_y"] = {
		numeric = true,
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("({UnitPosition(\"%s\")})[1]"):format(unitID);
		end,
		env = {
			["UnitPosition"] = "UnitPosition",
		},
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- UNIT CHECK
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	["unit_exists"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("UnitExists(\"%s\")"):format(unitID);
		end,
		env = {
			["UnitExists"] = "UnitExists",
		},
	},

	["unit_is_player"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("UnitIsPlayer(\"%s\")"):format(unitID);
		end,
		env = {
			["UnitIsPlayer"] = "UnitIsPlayer",
		},
	},

	["unit_is_dead"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("UnitIsDeadOrGhost(\"%s\")"):format(unitID);
		end,
		env = {
			["UnitIsDeadOrGhost"] = "UnitIsDeadOrGhost",
		},
	},

	["unit_distance_trade"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("CheckInteractDistance(\"%s\", 2)"):format(unitID);
		end,
		env = {
			["CheckInteractDistance"] = "CheckInteractDistance",
		},
	},

	["unit_distance_inspect"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("CheckInteractDistance(\"%s\", 1)"):format(unitID);
		end,
		env = {
			["CheckInteractDistance"] = "CheckInteractDistance",
		},
	},

	["unit_distance_point"] = {
		numeric = true,
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			local x = args[2] or 0;
			local y = args[3] or 0;
			return ("unitDistancePoint(\"%s\", %s, %s)"):format(unitID, x, y);
		end,
		env = {
			["unitDistancePoint"] = "TRP3_API.extended.unitDistancePoint",
		},
	},

	["unit_distance_me"] = {
		numeric = true,
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("unitDistanceMe(\"%s\")"):format(unitID);
		end,
		env = {
			["unitDistanceMe"] = "TRP3_API.extended.unitDistanceMe",
		},
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- CHARACTER values
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	["char_facing"] = {
		numeric = true,
		codeReplacement = function(args)
			return "GetPlayerFacing()";
		end,
		env = {
			["GetPlayerFacing"] = "GetPlayerFacing",
		},
	},

	["char_falling"] = {
		numeric = false,
		codeReplacement = function(args)
			return "IsFalling()";
		end,
		env = {
			["IsFalling"] = "IsFalling",
		},
	},

	["char_stealth"] = {
		numeric = false,
		codeReplacement = function(args)
			return "IsStealthed()";
		end,
		env = {
			["IsStealthed"] = "IsStealthed",
		},
	},

	["char_flying"] = {
		numeric = false,
		codeReplacement = function(args)
			return "IsFlying()";
		end,
		env = {
			["IsFlying"] = "IsFlying",
		},
	},

	["char_mounted"] = {
		numeric = false,
		codeReplacement = function(args)
			return "IsMounted()";
		end,
		env = {
			["IsMounted"] = "IsMounted",
		},
	},

	["char_resting"] = {
		numeric = false,
		codeReplacement = function(args)
			return "IsResting()";
		end,
		env = {
			["IsResting"] = "IsResting",
		},
	},

	["char_swimming"] = {
		numeric = false,
		codeReplacement = function(args)
			return "IsSwimming()";
		end,
		env = {
			["IsSwimming"] = "IsSwimming",
		},
	},

	["char_zone"] = {
		numeric = false,
		codeReplacement = function(args)
			return "GetZoneText()";
		end,
		env = {
			["GetZoneText"] = "GetZoneText",
		},
	},

	["char_subzone"] = {
		numeric = false,
		codeReplacement = function(args)
			return "GetSubZoneText()";
		end,
		env = {
			["GetSubZoneText"] = "GetSubZoneText",
		},
	},

	["char_minimap"] = {
		numeric = false,
		codeReplacement = function(args)
			return "GetMinimapZoneText()";
		end,
		env = {
			["GetMinimapZoneText"] = "GetMinimapZoneText",
		},
	},

	["char_cam_distance"] = {
		numeric = true,
		codeReplacement = function(args)
			return "GetCameraZoom()";
		end,
		env = {
			["GetCameraZoom"] = "GetCameraZoom",
		},
	},
	
	["char_achievement"] = {
		numeric = false,
		codeReplacement = function(args)
			local completedByIndex = 4;
			if args[1] == "account" then
				completedByIndex = 4; -- We get the "completed" return
			elseif args[1] == "character" then
				completedByIndex = 13; -- We get the "wasEarnedByMe" return
			end
			local id = args[2] or "";
			return ("({GetAchievementInfo(%s)})[%s]"):format(id, completedByIndex);
		end,
		env = {
			["GetAchievementInfo"] = "GetAchievementInfo",
		},
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Inventory
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	["inv_item_count"] = {
		numeric = true,
		codeReplacement = function(args)
			local id = args[1] or "";
			local source = "nil";
			if args[2] == "parent" then
				source = "args.container";
			elseif args[2] == "self" then
				source = "args.object";
			end
			return ("getItemCount(\"%s\", %s)"):format(id, source);
		end,
		env = {
			["getItemCount"] = "TRP3_API.inventory.getItemCount",
		},
	},

	["inv_item_weight"] = {
		numeric = true,
		codeReplacement = function(args)
			local source = "nil";
			if args[1] == "parent" then
				source = "args.container";
			elseif args[1] == "self" then
				source = "args.object";
			end
			return ("getContainerWeight(%s)"):format(source);
		end,
		env = {
			["getContainerWeight"] = "TRP3_API.inventory.getContainerWeight",
		},
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- QUEST
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	["quest_is_step"] = {
		codeReplacement = function(args)
			local campaignID, questID = TRP3_API.extended.splitID(args[1] or "");
			return ("getQuestCurrentStep(\"%s\", \"%s\")"):format(campaignID, questID);
		end,
		env = {
			["getQuestCurrentStep"] = "TRP3_API.quest.getQuestCurrentStep",
		},
	},

	["quest_obj"] = {
		codeReplacement = function(args)
			local campaignID, questID = TRP3_API.extended.splitID(args[1] or "");
			local objectiveID = args[2] or "";
			return ("isQuestObjectiveDone(\"%s\", \"%s\", \"%s\")"):format(campaignID, questID, objectiveID);
		end,
		env = {
			["isQuestObjectiveDone"] = "TRP3_API.quest.isQuestObjectiveDone",
		},
	},

	["quest_obj_current"] = {
		codeReplacement = function(args)
			local campaignID, questID = TRP3_API.extended.splitID(args[1] or "");
			return ("isAllQuestObjectiveDone(\"%s\", \"%s\", false)"):format(campaignID, questID);
		end,
		env = {
			["isAllQuestObjectiveDone"] = "TRP3_API.quest.isAllQuestObjectiveDone",
		},
	},

	["quest_obj_all"] = {
		codeReplacement = function(args)
			local campaignID, questID = TRP3_API.extended.splitID(args[1] or "");
			return ("isAllQuestObjectiveDone(\"%s\", \"%s\", true)"):format(campaignID, questID);
		end,
		env = {
			["isAllQuestObjectiveDone"] = "TRP3_API.quest.isAllQuestObjectiveDone",
		},
	},

	["quest_is_npc"] = {
		codeReplacement = function(args)
			local unitID = args[1] or "target";
			return ("UnitIsCampaignNPC(\"%s\")"):format(unitID);
		end,
		env = {
			["UnitIsCampaignNPC"] = "TRP3_API.quest.UnitIsCampaignNPC",
		},
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- EXPERT
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	["var_check"] = {
		codeReplacement = function(args)
			local source = args[1] or "w";
			local var = args[2] or "";
			return ("varCheck(args, \"%s\", \"%s\")"):format(source, var);
		end,
		env = {
			["varCheck"] = "TRP3_API.script.varCheck",
		},
	},

	["var_check_n"] = {
		numeric = true,
		codeReplacement = function(args)
			local source = args[1] or "w";
			local var = args[2] or "";
			return ("varCheckN(args, \"%s\", \"%s\")"):format(source, var);
		end,
		env = {
			["varCheckN"] = "TRP3_API.script.varCheckN",
		},
	},

	["check_event_var"] = {
		codeReplacement = function(args)
			local var = tonumber(args[1] or 1) or 1;
			return ("eventVarCheck(args, %s)"):format(var);
		end,
		env = {
			["eventVarCheck"] = "TRP3_API.script.eventVarCheck",
		},
	},

	["check_event_var_n"] = {
		numeric = true,
		codeReplacement = function(args)
			local var = tonumber(args[1] or 1) or 1;
			return ("eventVarCheckN(args, %s)"):format(var);
		end,
		env = {
			["eventVarCheckN"] = "TRP3_API.script.eventVarCheckN",
		},
	},

	["random"] = {
		numeric = true,
		codeReplacement = function(args)
			local from = tonumber(args[1] or 1) or 1;
			local to = tonumber(args[2] or 100) or 100;
			return ("random(%s, %s)"):format(from, to);
		end,
		env = {
			["random"] = "math.random",
		},
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- OTHERS
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Let you test a previous test results
	["cond"] = {
		codeReplacement = "tostring(conditionStorage[\"%s\"])",
	},

	-- Let you test the return value from the last effect
	["last_return"] = {
		codeReplacement = "tostring(args.LAST)",
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Time
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	["time_hour"] = {
		numeric = true,
		codeReplacement = function(args)
			return "({GetGameTime()})[1]";
		end,
		env = {
			["GetGameTime"] = "GetGameTime",
		},
	},

	["time_minute"] = {
		numeric = true,
		codeReplacement = function(args)
			return "({GetGameTime()})[2]";
		end,
		env = {
			["GetGameTime"] = "GetGameTime",
		},
	},
};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Logic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.script.registerOperand = function(operand)
	assert(type(operand) == "table" and operand.id, "Operand must have an id.");
	assert(not OPERANDS[operand.id], "Already registered operand id: " .. operand.id);
	OPERANDS[operand.id] = operand;
end

TRP3_API.script.getOperand = function(operandID)
	return OPERANDS[operandID];
end