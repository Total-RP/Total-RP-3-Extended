----------------------------------------------------------------------------------
--- Total RP 3
---	------------------------------------------------------------------------------
--- Copyright 2018 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
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

local _, Private_TRP3E = ...;

--- This module is responsible for securely collecting macro commands to run for the user.
--- This should be as secure as humanly possible, avoid calling global functions.
---@class SecureEnclave
local SecureEnclave = {};

local enclave = {};
local shouldEnclaveCollectCommands = false;

function SecureEnclave:StartCollectingSecureCommands()
	shouldEnclaveCollectCommands = true;
	enclave = {};
end

---@param macroCommands string
function SecureEnclave:AddSecureCommands(macroCommands)
	if shouldEnclaveCollectCommands then
		enclave[#enclave + 1] = macroCommands;
	end
end

---@return string
function SecureEnclave:GetSecureCommands()

	-- Create a copy of the table instead of passing a direct reference, for security reasons
	local enclaveContent = "";
	for i = 1, #enclave do
		enclaveContent = enclaveContent .. enclave[i] .. "\n";
	end

	shouldEnclaveCollectCommands = false;
	enclave = {};

	return enclaveContent;
end

Private_TRP3E.SecureEnclave = SecureEnclave