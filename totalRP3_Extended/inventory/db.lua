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
	TY = TRP3_DB.types.ITEM,
	BA = {
		NA = "Main inventory",
	},
	CO = {},
}

TRP3_DB.inner.bag_normal = {
	TY = TRP3_DB.types.ITEM,
	BA = {
		IC = "inv_misc_bag_11",
		NA = "Simple bag",
		DE = "A classic bag. Nothing special here.",
		UN = 5,
		WE = 600,
	},
	CO = {
		DU = 25,
		MW = 30,
		SI = "5x4",
	},
}

TRP3_DB.inner.bag_small = {
	TY = TRP3_DB.types.ITEM,
	BA = {
		IC = "inv_misc_bag_10",
		NA = "Small bag",
		WE = 400,
	},
	CO = {
		SI = "2x4",
		SR = 2,
	},
}

TRP3_DB.inner.bag_tiny = {
	TY = TRP3_DB.types.ITEM,
	BA = {
		IC = "inv_misc_bag_09",
		NA = "Tiny bag",
		WE = 200,
	},
	CO = {
		SI = "1x4",
		SR = 1,
	},
}

TRP3_DB.inner.currency_coin_copper = {
	TY = TRP3_DB.types.ITEM,
	BA = {
		IC = "INV_Misc_Coin_19",
		NA = "Copper coin",
		DE = "A simple copper coin",
		QA = 2,
		WE = 2,
		VA = 1,
	},
	UN = 10,
	ST = {
		MA = 5,
	},
}
