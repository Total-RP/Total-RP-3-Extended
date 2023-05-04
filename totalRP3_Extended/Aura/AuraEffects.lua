-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

TRP3_API.extended.auras.EFFECTS = {
	["aura_apply"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(_, cArgs, eArgs)
			eArgs.LAST = 0;
			TRP3_API.extended.auras.apply(
				TRP3_API.script.parseArgs(cArgs[1] or "", eArgs),
				cArgs[2]
			);
		end,
	},
	["aura_duration"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(_, cArgs, eArgs)
			eArgs.LAST = 0;
			TRP3_API.extended.auras.setDuration(
				TRP3_API.script.parseArgs(cArgs[1] or "", eArgs),
				tonumber(TRP3_API.script.parseArgs(cArgs[2], eArgs)) or 0,
				cArgs[3] or "+"
			);
		end,
	},
	["aura_remove"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(_, cArgs, eArgs)
			eArgs.LAST = 0;
			TRP3_API.extended.auras.remove(
				TRP3_API.script.parseArgs(cArgs[1] or "", eArgs)
			);
		end,
	},
	["aura_var_set"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(_, cArgs, eArgs)
			eArgs.LAST = 0;
			TRP3_API.extended.auras.setVariable(
				TRP3_API.script.parseArgs(cArgs[1] or "", eArgs),
				cArgs[2] or "[=]",
				cArgs[3] or "",
				TRP3_API.script.parseArgs(cArgs[4], eArgs)
			);
		end,
	},
	["aura_run_workflow"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(_, cArgs, eArgs)
			eArgs.LAST = 0;
			TRP3_API.extended.auras.runWorkflow(
				TRP3_API.script.parseArgs(cArgs[1] or "", eArgs),
				cArgs[2] or "",
				eArgs
			);
		end,
	},
};
