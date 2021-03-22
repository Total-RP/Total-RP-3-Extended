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

-- Fixed the issue when trying to roll multiple dices and only rolling the first ones (Paul Corlay)

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
			local amount = args[2] or "0";
			local type = args[1];
			return target, amount, type;
		end,
		method = function(structure, cArgs, eArgs)
			local target, amount, type = structure.getCArgs(cArgs);
			amount = tonumber(TRP3_API.script.parseArgs(amount, eArgs));
			if type == "DAMAGE" then
				amount = - amount;
			end
			eArgs.LAST = TRP3_API.inventory.changeContainerDurability(eArgs[target], amount);
		end,
	},

	["item_sheath"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(structure, cArgs, eArgs)
			ToggleSheath(); eArgs.LAST = 0;
		end,
	},

	["item_consume"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(structure, cArgs, eArgs)
			local amount = tonumber(cArgs[1]) or 1;
			eArgs.LAST = TRP3_API.inventory.consumeItem(eArgs.object, eArgs.container, amount);
		end,
	},

	["item_add"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		getCArgs = function(args)
			local targetContainer = args[4] or "parent";
			local id = args[1] or "";
			local count = args[2] or "1";
			local madeBy = args[3] or false;
			return targetContainer, id, count, madeBy;
		end,
		method = function(structure, cArgs, eArgs)
			local targetContainer, id, count, madeBy = structure.getCArgs(cArgs);
			count = tonumber(TRP3_API.script.parseArgs(count, eArgs));
			if targetContainer == "parent" then
				targetContainer = eArgs.container;
			elseif targetContainer == "self" then
				targetContainer = eArgs.object;
			else
				targetContainer = nil;
			end
			eArgs.LAST = TRP3_API.inventory.addItem(targetContainer, id, {count = count, madeBy = madeBy}, true);
		end,
	},

	["item_remove"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		getCArgs = function(args)
			local id = args[1] or "";
			local count = args[2] or "1";
			local source = args[3];
			return id, count, source;
		end,
		method = function(structure, cArgs, eArgs)
			local id, count, source = structure.getCArgs(cArgs);
			count = tonumber(TRP3_API.script.parseArgs(count, eArgs));
			if source == "parent" then
				source = eArgs.container;
			elseif source == "self" then
				source = eArgs.object;
			else
				source = nil;
			end
			eArgs.LAST = TRP3_API.inventory.removeItem(id, count, source);
		end,
	},

	["item_cooldown"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		method = function(structure, cArgs, eArgs)
			local duration = tonumber(TRP3_API.script.parseArgs(cArgs[1], eArgs)) or 1;
			eArgs.LAST = TRP3_API.inventory.startCooldown(eArgs.object, duration, eArgs.container);
		end,
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
		method = function(structure, cArgs, eArgs)
			local isDrop, lootID = structure.getCArgs(cArgs);
			if not isDrop then
				eArgs.LAST = TRP3_API.inventory.presentLootID(lootID, nil, eArgs.dialogStepClass and eArgs.dialogStepClass.LO);
			else
				eArgs.LAST = TRP3_API.inventory.dropLoot(lootID);
			end
		end,
	},

	["item_use"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		getCArgs = function(args)
			local slotID = tostring(tonumber(args[1] or 0) or 0);
			return slotID;
		end,
		method = function(structure, cArgs, eArgs)
			local slotID = structure.getCArgs(cArgs);
			eArgs.LAST = TRP3_API.inventory.useContainerSlotID(eArgs.object, slotID);
		end,
	},

	["item_roll_dice"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		getCArgs = function(args)
			local roll = tostring(args[1]) or "1d100";
			local serial = strjoin("\", args), var(\"", strsplit(" ", roll));
			local varName = args[2] or "";
			local varSource = args[3] or "w";
			return serial, varName, varSource;
		end,
		method = function(structure, cArgs, eArgs)
			local serial, varName, varSource = structure.getCArgs(cArgs);
			local rollResult = TRP3_API.slash.rollDices(strsplit(" ",TRP3_API.script.parseArgs(serial, eArgs)));
			if varName ~= "" then
				TRP3_API.script.setVar(eArgs, varSource, "=", varName, rollResult);
			end
			eArgs.LAST = rollResult;
		end,
	},

	["run_item_workflow"] = {
		getCArgs = function(args)
			local source = args[1] or "p";
			local id = args[2] or "";
			local slotID = args[3] or "";
			return source, id, slotID;
		end,
		method = function(structure, cArgs, eArgs)
			local source, id, slotID = structure.getCArgs(cArgs);
			TRP3_API.script.runWorkflow(eArgs, source, id, slotID); eArgs.LAST = 0;
		end,
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
	},

}