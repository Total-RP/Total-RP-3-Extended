----------------------------------------------------------------------------------
--- Total RP 3
--- Scripts : Operands
---	---------------------------------------------------------------------------
--- Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
--- Copyright 2019 Morgane "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---
--- Licensed under the Apache License, Version 2.0 (the "License");
--- you may not use this file except in compliance with the License.
--- You may obtain a copy of the License at
---
---  http://www.apache.org/licenses/LICENSE-2.0
---
--- Unless required by applicable law or agreed to in writing, software
--- distributed under the License is distributed on an "AS IS" BASIS,
--- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--- See the License for the specific language governing permissions and
--- limitations under the License.
----------------------------------------------------------------------------------

--region Operand class declaration
---@class TotalRP3_Extended_Operand
local Operand = TRP3_API.Ellyb.Class("TotalRP3_Extended_Operand");

---@param operandId string A unique ID to refer to this operand
---@param environment table<string, string> An environment table that will be used to map functions that will be made available to the operand code when executed.
function Operand:initialize(operandId, environment)
	Ellyb.Assertions.isType(operandId, "string", "operandId");
	self.id = operandId
	self.env = environment or {};

	-- Backward compatibility: provide a non object oriented method
	---@deprecated
	self.codeReplacement = function(args)
		TRP3_API.Ellyb.DeprecationWarnings.warn("Operand.codeReplacement(args) is deprecated, please use Operand:CodeReplacement(args) from now on.")
		return self:CodeReplacement(args)
	end

	-- The operand register itself when created
	TRP3_API.script.registerOperand(self)
end

--[[ Override ]] function Operand:CodeReplacement(args)
	error("Operand:CodeReplacement(args) should be overriden by the operand to execute the desired code replacement.");
end

---@class TotalRP3_Extended_NumericOperand: TotalRP3_Extended_Operand
local NumericOperand = TRP3_API.Ellyb.Class("TotalRP3_Extended_NumericOperand", Operand);
NumericOperand.numeric = true

TRP3_API.script.Operand = Operand;
TRP3_API.script.NumericOperand = NumericOperand;

--endregion

--region utils

--- Retrieve a specific desired argument from the arguments passed to an operand in a safe way.
--- The arguments table is checked to be valid and that the desired argument has been provided, otherwise the default
--- value provided is returned.
---@generic T
---@param arguments table|nil The arguments given to the operand
---@param argumentIndex number|string The index where the desired argument should be stored in the arguments table
---@param defaultValue T A default value that should be returned if the desired argument could not be retrieved.
---@return T Either the value passed via the arguments if found or the default value
function TRP3_API.getSafeValueFromTable(arguments, argumentIndex, defaultValue)
	if arguments == nil or type(arguments) ~= "table" or arguments[argumentIndex] == nil then
		return defaultValue
	else
		return arguments[argumentIndex]
	end
end

--endregion
