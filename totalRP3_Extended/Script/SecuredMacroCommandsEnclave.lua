----------------------------------------------------------------------------------
--- Total RP 3
---	------------------------------------------------------------------------------
--- Copyright 2018 Morgane "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
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
---@class SecuredMacroCommandsEnclave
local SecuredMacroCommandsEnclave = {};

local enclave = {};
local shouldEnclaveCollectCommands = false;

--- Ask the SecuredMacroCommandsEnclave to start collecting macro commands
function SecuredMacroCommandsEnclave:StartCollectingSecureCommands()
	shouldEnclaveCollectCommands = true;
	enclave = {};
end

--- Add a macro command to the SecuredMacroCommandsEnclave.
--- The command will be ignored if added add at a time when the enclave is not collecting.
---@param macroCommands string
function SecuredMacroCommandsEnclave:AddSecureCommands(macroCommands)
	if shouldEnclaveCollectCommands then
		enclave[#enclave + 1] = macroCommands;
	end
end

--- Fetch all macro commands from the SecuredMacroCommandsEnclave
---@return string
function SecuredMacroCommandsEnclave:GetSecureCommands()

	-- Create a copy of the table instead of passing a direct reference, for security reasons
	local enclaveContent = "";
	for i = 1, #enclave do
		enclaveContent = enclaveContent .. enclave[i] .. "\n";
	end

	shouldEnclaveCollectCommands = false;
	enclave = {};

	return enclaveContent;
end

Private_TRP3E.SecuredMacroCommandsEnclave = SecuredMacroCommandsEnclave
