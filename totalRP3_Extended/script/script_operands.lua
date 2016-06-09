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

local assert, type = assert, type;

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
			return ("UnitSex(\"%s\")"):format(unitID);
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

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Inventory
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	["inv_item_count"] = {
		numeric = true,
		codeReplacement = function(args)
			local id = args[1] or "";
			return ("getItemCount(\"%s\")"):format(id);
		end,
		env = {
			["getItemCount"] = "TRP3_API.inventory.getItemCount",
		},
	},

	["inv_item_count_con"] = {
		numeric = true,
		codeReplacement = function(args)
			local id = args[1] or "";
			return ("getItemCount(\"%s\", args.object)"):format(id);
		end,
		env = {
			["getItemCount"] = "TRP3_API.inventory.getItemCount",
		},
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- OTHERS
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	-- Let you test a previous test results
	["cond"] = {
		codeReplacement= "tostring(conditionStorage[\"%s\"])",
	},

	-- Let you test the return value from the last effect
	["last_return"] = {
		codeReplacement= "tostring(lastEffectReturn)",
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