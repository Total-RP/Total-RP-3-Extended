----------------------------------------------------------------------------------
-- Total RP 3: Item DB
-- ---------------------------------------------------------------------------
-- Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
----------------------------------------------------------------------------------

TRP3_DB.inner.main = {
	hideFromList = true,
	TY = TRP3_DB.types.ITEM,
	BA = {
		NA = "Main inventory",
	},
	CO = {},
}

TRP3_DB.inner.bag = {
	TY = TRP3_DB.types.ITEM,
	["CO"] = {
		["SC"] = "4",
		["MW"] = 0,
		["DU"] = 50,
		["SI"] = "5x4",
		["SR"] = "5",
	},
	["BA"] = {
		["QA"] = 1,
		["IC"] = "INV_Misc_Bag_01",
		["NA"] = "Simple bag",
		["WE"] = 500,
		["CT"] = true,
	},
	["MD"] = {
		["CD"] = "28/04/16 17:36:38",
		["CB"] = "Akraluk-KirinTor",
		["SB"] = "Akraluk-KirinTor",
		["MO"] = "NO",
		["SD"] = "28/04/16 17:36:41",
		["V"] = 2,
	},
}