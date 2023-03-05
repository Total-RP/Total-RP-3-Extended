TRP3_API.extended.auras.EFFECTS = {
	["aura_apply"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(structure, cArgs, eArgs)
			eArgs.LAST = 0
			TRP3_API.extended.auras.apply(
				cArgs[1] or "", 
				cArgs[2]
			)
		end,
	},
	["aura_duration"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(structure, cArgs, eArgs)
			eArgs.LAST = 0
			TRP3_API.extended.auras.setDuration(
				cArgs[1] or "",
				tonumber(TRP3_API.script.parseArgs(cArgs[2] or "0", eArgs)), 
				cArgs[3] or "+"
			)
		end,
	},
	["aura_remove"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(structure, cArgs, eArgs)
			eArgs.LAST = 0
			TRP3_API.extended.auras.remove(
				cArgs[1] or ""
			)
		end,
	},
	["aura_var_set"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(structure, cArgs, eArgs)
			eArgs.LAST = 0
			TRP3_API.extended.auras.setVariable(
				cArgs[1] or "",
				cArgs[2] or "[=]",
				cArgs[3] or "",
				TRP3_API.script.parseArgs(cArgs[4], eArgs)
			)
		end,
	},
	["aura_run_workflow"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(structure, cArgs, eArgs)
			eArgs.LAST = 0
			TRP3_API.extended.auras.runWorkflow(
				cArgs[1] or "",
				cArgs[2] or "",
				eArgs
			)
		end,
	},
}
