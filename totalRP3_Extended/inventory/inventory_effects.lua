----------------------------------------------------------------------------------
-- Total RP 3
-- Scripts : Inventory Effects
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@telkostrasz.be)
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

local Globals, Events, Utils, EMPTY = TRP3_API.globals, TRP3_API.events, TRP3_API.utils, TRP3_API.globals.empty;
local tonumber = tonumber;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effetc structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tostring = tostring;

TRP3_API.inventory.EFFECTS = {

	["item_bag_durability"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		getCArgs = function(args)
			local target = "container";
			if args[3] == "self" then
				target = "object";
			end
			local amount = tonumber(args[2]) or 0;
			if args[1] == "DAMAGE" then
				amount = - amount;
			end
			return target, amount;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local target, amount = structure.getCArgs(cArgs);
			return ("args.LAST = changeContainerDurability(args.%s, %s);"):format(target, amount);
		end,
		method = function(structure, cArgs, eArgs)
			local target, amount = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.inventory.changeContainerDurability(eArgs[target], amount);
		end,
		env = {
			changeContainerDurability = "TRP3_API.inventory.changeContainerDurability",
		}
	},

	["item_sheath"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		codeReplacementFunc = function ()
			return "ToggleSheath(); args.LAST = 0;"
		end,
		method = function(structure, cArgs, eArgs)
			ToggleSheath(); eArgs.LAST = 0;
		end,
		env = {
			ToggleSheath = "ToggleSheath",
		}
	},

	["item_consume"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		codeReplacementFunc = function (structure, args)
			local amount = tonumber(args[1]) or 1;
			return ("args.LAST = consumeItem(args.object, args.container, %s);"):format(amount);
		end,
		method = function(structure, cArgs, eArgs)
			local amount = tonumber(cArgs[1]) or 1;
			eArgs.LAST = TRP3_API.inventory.consumeItem(eArgs.object, eArgs.container, amount);
		end,
		env = {
			consumeItem = "TRP3_API.inventory.consumeItem",
		}
	},

	["item_add"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		getCArgs = function(args)
			local targetContainer = args[4] or "parent";
			local id = args[1] or "";
			local count = tonumber(args[2]) or 1;
			local madeBy = args[3] or false;
			return targetContainer, id, count, madeBy;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local targetContainer, id, count, madeBy = structure.getCArgs(cArgs);
			if targetContainer == "parent" then
				targetContainer = "args.container";
			elseif targetContainer == "self" then
				targetContainer = "args.object";
			else
				targetContainer = "nil";
			end
			return ("args.LAST = addItem(%s, \"%s\", {count = %d, madeBy = %s}, true);"):format(targetContainer, id, count, tostring(madeBy));
		end,
		method = function(structure, cArgs, eArgs)
			local targetContainer, id, count, madeBy = structure.getCArgs(cArgs);
			if targetContainer == "parent" then
				targetContainer = eArgs.container;
			elseif targetContainer == "self" then
				targetContainer = eArgs.object;
			else
				targetContainer = nil;
			end
			eArgs.LAST = TRP3_API.inventory.addItem(targetContainer, id, {count = count, madeBy = madeBy}, true);
		end,
		env = {
			addItem = "TRP3_API.inventory.addItem",
		}
	},

	["item_remove"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		getCArgs = function(args)
			local id = args[1] or "";
			local count = tonumber(args[2]) or 1;
			local source = args[3];
			return id, count, source;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local id, count, source = structure.getCArgs(cArgs);
			if source == "parent" then
				source = "args.container";
			elseif source == "self" then
				source = "args.object";
			else
				source = "nil";
			end
			return ("args.LAST = removeItem(\"%s\", %d, %s);"):format(id, count, source);
		end,
		method = function(structure, cArgs, eArgs)
			local id, count, source = structure.getCArgs(cArgs);
			if source == "parent" then
				source = args.container;
			elseif source == "self" then
				source = args.object;
			else
				source = nil;
			end
			eArgs.LAST = TRP3_API.inventory.removeItem(id, count, source);
		end,
		env = {
			removeItem = "TRP3_API.inventory.removeItem",
		}
	},

	["item_cooldown"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		codeReplacementFunc = function (structure, args)
			local duration = tonumber(args[1]) or 1;
			return ("args.LAST = startCooldown(args.object, %d, args.container);"):format(duration);
		end,
		method = function(structure, cArgs, eArgs)
			local duration = tonumber(cArgs[1]) or 1;
			eArgs.LAST = TRP3_API.inventory.startCooldown(eArgs.object, duration, eArgs.container);
		end,
		env = {
			startCooldown = "TRP3_API.inventory.startCooldown",
		}
	},

	["item_loot"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		getCArgs = function(args)
			local lootInfo = args[1];
			local isDrop = lootInfo[4] or false;
			local lootID = Utils.str.id();
			TRP3_API.inventory.storeLoot(lootID, lootInfo);
			return isDrop, lootID;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local isDrop, lootID = structure.getCArgs(cArgs);
			if not isDrop then
				return ("args.LAST = presentLootID(\"%s\", nil, args.dialogStepClass and args.dialogStepClass.LO);"):format(lootID);
			else
				return ("args.LAST = dropLoot(\"%s\");"):format(lootID);
			end
		end,
		method = function(structure, cArgs, eArgs)
			local isDrop, lootID = structure.getCArgs(cArgs);
			if not isDrop then
				eArgs.LAST = TRP3_API.inventory.presentLootID(lootID, nil, eArgs.dialogStepClass and eArgs.dialogStepClass.LO);
			else
				eArgs.LAST = TRP3_API.inventory.dropLoot(lootID);
			end
		end,
		env = {
			presentLootID = "TRP3_API.inventory.presentLootID",
			dropLoot = "TRP3_API.inventory.dropLoot",
		}
	},

	["item_use"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		getCArgs = function(args)
			local slotID = tostring(tonumber(args[1] or 0) or 0);
			return slotID;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local slotID = structure.getCArgs(cArgs);
			return ("args.LAST = useContainerSlotID(args.object, \"%s\");"):format(slotID);
		end,
		method = function(structure, cArgs, eArgs)
			local slotID = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.inventory.useContainerSlotID(eArgs.object, slotID);
		end,
		env = {
			useContainerSlotID = "TRP3_API.inventory.useContainerSlotID",
		}
	},

	["item_roll_dice"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		getCArgs = function(args)
			local roll = tostring(args[1]) or "1d100";
			local serial = strjoin("\", args), var(\"", strsplit(" ", roll));
			return serial;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local serial = structure.getCArgs(cArgs);
			return ("args.LAST = rollDices(var(\"%s\", args));"):format(serial);
		end,
		method = function(structure, cArgs, eArgs)
			local serial = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.slash.rollDices(TRP3_API.script.parseArgs(serial, eArgs));
		end,
		env = {
			rollDices = "TRP3_API.slash.rollDices",
		}
	},

	["run_item_workflow"] = {
		getCArgs = function(args)
			local source = args[1] or "p";
			local id = args[2] or "";
			local slotID = args[3] or "";
			return source, id, slotID;
		end,
		codeReplacementFunc = function (structure, cArgs)
			local source, id, slotID = structure.getCArgs(cArgs);
			return ("runWorkflow(args, \"%s\", \"%s\", \"%s\"); args.LAST = 0;"):format(source, id, slotID);
		end,
		method = function(structure, cArgs, eArgs)
			local source, id, slotID = structure.getCArgs(cArgs);
			TRP3_API.script.runWorkflow(eArgs, source, id, slotID); eArgs.LAST = 0;
		end,
		env = {
			runWorkflow = "TRP3_API.script.runWorkflow",
		},
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
	},

}