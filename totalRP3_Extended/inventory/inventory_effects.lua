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

local tonumber = tonumber;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Effetc structure
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local tostring = tostring;

TRP3_API.inventory.EFFECTS = {

	["item_bag_durability"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		codeReplacementFunc = function (args)
			local target = "container";
			if args[3] == "self" then
				target = "object";
			end
			local amount = tonumber(args[2]) or 0;
			if args[1] == "DAMAGE" then
				amount = - amount;
			end
			return ("lastEffectReturn = changeContainerDurability(args.%s, %s);"):format(target, amount);
		end,
		env = {
			changeContainerDurability = "TRP3_API.inventory.changeContainerDurability",
		}
	},

	["item_sheath"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		codeReplacementFunc = function ()
			return "ToggleSheath(); lastEffectReturn = 0;"
		end,
		env = {
			ToggleSheath = "ToggleSheath",
		}
	},

	["item_consume"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		codeReplacementFunc = function (args)
			local amount = tonumber(args[1]) or 1;
			return ("lastEffectReturn = consumeItem(args.object, args.container, %s);"):format(amount);
		end,
		env = {
			consumeItem = "TRP3_API.inventory.consumeItem",
		}
	},

	["item_add"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		codeReplacementFunc = function (args)
			local targetContainer = args[4] or "parent";
			if targetContainer == "parent" then
				targetContainer = "args.container";
			elseif targetContainer == "self" then
				targetContainer = "args.object";
			else
				targetContainer = "nil";
			end
			local id = args[1] or "";
			local count = tonumber(args[2]) or 1;
			local madeBy = args[3] or false;
			return ("lastEffectReturn = addItem(%s, \"%s\", {count = %d, madeBy = %s});"):format(targetContainer, id, count, tostring(madeBy));
		end,
		env = {
			addItem = "TRP3_API.inventory.addItem",
		}
	},

	["item_remove"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		codeReplacementFunc = function (args)
			local id = args[1] or "";
			local count = tonumber(args[2]) or 1;
			local source = args[3] or "inventory";
			if source == "parent" then
				source = "args.container";
			elseif source == "self" then
				source = "args.object";
			else
				source = "nil";
			end
			return ("lastEffectReturn = removeItem(\"%s\", %d, %s);"):format(id, count, source);
		end,
		env = {
			removeItem = "TRP3_API.inventory.removeItem",
		}
	},

	["item_cooldown"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		codeReplacementFunc = function (args)
			local duration = tonumber(args[1]) or 1;
			return ("lastEffectReturn = startCooldown(args.object, %d, args.container);"):format(duration);
		end,
		env = {
			startCooldown = "TRP3_API.inventory.startCooldown",
		}
	},

	["item_loot"] = {
		secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
		codeReplacementFunc = function (args)
			local lootID = args[1];
			return ("lastEffectReturn = presentLoot(\"%s\");"):format(lootID);
		end,
		env = {
			presentLoot = "TRP3_API.inventory.presentLoot",
		}
	},

}