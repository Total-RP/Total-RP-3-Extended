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

---@type TotalRP3_Extended_NumericOperand
local NumericOperand = TRP3_API.script.NumericOperand;
local getSafe = TRP3_API.getSafeValueFromTable;

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

local itemWeightOperand = NumericOperand("inv_item_weight", {
	["getContainerWeight"] = "TRP3_API.inventory.getContainerWeight"
});

function itemWeightOperand:CodeReplacement(args)
	local source = getSafe(args, 1, "nil");
	if source == "parent" then
		source = "args.container";
	elseif source == "self" then
		source = "args.object";
	end
	return ([[getContainerWeight(%s)]]):format(source);
end
