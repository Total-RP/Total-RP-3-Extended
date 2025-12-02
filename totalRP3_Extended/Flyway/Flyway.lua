-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

TRP3_API.extended.flyway = {};

local type, tostring = type, tostring;

local SCHEMA_VERSION = 2;

if not TRP3_Extended_Flyway then
	TRP3_Extended_Flyway = {};
end

local function applyPatches(fromBuild, toBuild)
	for i=fromBuild, toBuild do
		if type(TRP3_API.extended.flyway.patches[tostring(i)]) == "function" then
			TRP3_API.Logf("Applying patch %s for Extended", i);
			TRP3_API.extended.flyway.patches[tostring(i)]();
		end
	end
	TRP3_Extended_Flyway.log = ("Patch applied from %s to %s on %s"):format(fromBuild - 1, toBuild, date("%d/%m/%y %H:%M:%S"));
end

function TRP3_API.extended.flyway.applyPatches()
	if not TRP3_Extended_Flyway.currentBuild or TRP3_Extended_Flyway.currentBuild < SCHEMA_VERSION then
		applyPatches( (TRP3_Extended_Flyway.currentBuild or 0) + 1, SCHEMA_VERSION);
	end
	TRP3_Extended_Flyway.currentBuild = SCHEMA_VERSION;
end
