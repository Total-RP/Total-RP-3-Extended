----------------------------------------------------------------------------------
--- Total RP 3
--- Scripts : Inventory Operands
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

---@type TRP3_API
local TRP3_API = TRP3_API

---@type TotalRP3_Extended_Operand
local Operand = TRP3_API.script.Operand;
---@type TotalRP3_Extended_NumericOperand
local NumericOperand = TRP3_API.script.NumericOperand;
local getSafe = TRP3_API.getSafeValueFromTable;

local itemNameOperand = Operand("inv_item_name", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["getClass"] = "TRP3_API.extended.getClass",
	["getBaseClassDataSafe"] = "TRP3_API.inventory.getBaseClassDataSafe"
});

function itemNameOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ("({getBaseClassDataSafe(getClass(parseArgs(\"%s\", args)))})[2]"):format(id);
end

local itemIconOperand = Operand("inv_item_icon", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["getClass"] = "TRP3_API.extended.getClass",
	["getBaseClassDataSafe"] = "TRP3_API.inventory.getBaseClassDataSafe"
});

function itemIconOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ("({getBaseClassDataSafe(getClass(parseArgs(\"%s\", args)))})[1]"):format(id);
end

local itemQualityOperand = NumericOperand("inv_item_quality", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["getClass"] = "TRP3_API.extended.getClass",
	["getBaseClassDataSafe"] = "TRP3_API.inventory.getBaseClassDataSafe"
});

function itemQualityOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ("({getBaseClassDataSafe(getClass(parseArgs(\"%s\", args)))})[3]"):format(id);
end

local itemWeightOperand = NumericOperand("inv_item_id_weight", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["getItemWeight"] = "TRP3_API.inventory.getItemWeight"
});

function itemWeightOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[getItemWeight(parseArgs("%s", args))]]):format(id);
end

local itemValueOperand = NumericOperand("inv_item_value", {
	["parseArgs"] = "TRP3_API.script.parseArgs",
	["getItemValue"] = "TRP3_API.inventory.getItemValue"
});

function itemValueOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	return ([[getItemValue(parseArgs("%s", args))]]):format(id);
end

local itemCountOperand = NumericOperand("inv_item_count", {
	["getItemCount"] = "TRP3_API.inventory.getItemCount"
});

function itemCountOperand:CodeReplacement(args)
	local id = getSafe(args, 1, "");
	local source = getSafe(args, 2, "nil");
	if source == "parent" then
		source = "args.container";
	elseif source == "self" then
		source = "args.object";
	end
	return ([[getItemCount("%s", %s)]]):format(id, source);
end

local itemContainerWeightOperand = NumericOperand("inv_item_weight", {
	["getContainerWeight"] = "TRP3_API.inventory.getContainerWeight"
});

function itemContainerWeightOperand:CodeReplacement(args)
	local source = getSafe(args, 1, "nil");
	if source == "parent" then
		source = "args.container";
	elseif source == "self" then
		source = "args.object";
	end
	return ([[getContainerWeight(%s)]]):format(source);
end

local containerSlotIDOperand = Operand("inv_container_slot_id", {
	["EMPTY"] = "TRP3_API.globals.empty"
});

function containerSlotIDOperand:CodeReplacement(args)
	local slotID = getSafe(args, 1, "");
	return ([[((args.object.content or EMPTY)["%s"] or EMPTY).id]]):format(slotID);
end