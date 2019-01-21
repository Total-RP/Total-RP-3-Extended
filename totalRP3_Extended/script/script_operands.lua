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

---@type TRP3_API
local TRP3_API = TRP3_API;
local Ellyb = TRP3_API.Ellyb;


---@type TotalRP3_Extended_Operand[]
local OPERANDS= {}

---@param operand TotalRP3_Extended_Operand
function TRP3_API.script.registerOperand(operand)
	assert(Ellyb.Assertions.isInstanceOf(operand, TRP3_API.script.Operand, "operand"));
	assert(not OPERANDS[operand.id], "Already registered operand id: " .. operand.id);
	OPERANDS[operand.id] = operand;
end

function TRP3_API.script.getOperand(operandID)
	return OPERANDS[operandID];
end
