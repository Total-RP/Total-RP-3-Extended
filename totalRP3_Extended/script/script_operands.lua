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

local assert, type, tostring, error, tonumber, pairs, unpack, wipe = assert, type, tostring, error, tonumber, pairs, unpack, wipe;

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