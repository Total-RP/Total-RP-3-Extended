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

TRP3_DB.inner.rifle = {
	["MD"] = {
		["CD"] = "28/04/16 17:54:05",
		["CB"] = "Akraluk-KirinTor",
		["SB"] = "Akraluk-KirinTor",
		["MO"] = "NO",
		["SD"] = "29/04/16 20:15:01",
		["V"] = 26,
	},
	["BA"] = {
		["DE"] = "When you pull the trigger, it shoots. Simple.",
		["IC"] = "INV_Weapon_Rifle_23",
		["LE"] = "Weapon",
		["CO"] = false,
		["NA"] = "Rifle",
		["ST"] = false,
		["QA"] = 4,
		["SB"] = false,
		["UN"] = 1,
		["VA"] = 50000,
		["CR"] = true,
		["RI"] = "Gun",
		["US"] = true,
		["QE"] = false,
		["WA"] = false,
		["CT"] = false,
		["WE"] = 5000,
	},
	["SC"] = {
		["onUse"] = {
			["ST"] = {
				["1"] = {
					["e"] = {
						{
							["id"] = "sound_id_self",
							["args"] = {
								"SFX", -- [1]
								1147, -- [2]
							},
						}, -- [1]
					},
					["t"] = "list",
					["n"] = "2",
				},
				["4"] = {
					["e"] = {
						{
							["id"] = "sound_id_self",
							["args"] = {
								"SFX", -- [1]
								37089, -- [2]
							},
						}, -- [1]
					},
					["t"] = "list",
				},
				["3"] = {
					["e"] = {
						{
							["id"] = "item_remove",
							["args"] = {
								"rifle bullet", -- [1]
								1, -- [2]
							},
						}, -- [1]
					},
					["t"] = "list",
					["n"] = "4",
				},
				["2"] = {
					["i"] = 1,
					["c"] = 1,
					["t"] = "delay",
					["d"] = 0.8,
					["n"] = "3",
				},
			},
		},
	},
	["CO"] = {
		["SC"] = "4",
		["MW"] = 0,
		["DU"] = 0,
		["SI"] = "5x4",
		["SR"] = "5",
	},
	["IN"] = {
		["bullet"] = {
			["US"] = {
				["SC"] = "onUse",
			},
			["BA"] = {
				["WE"] = 100,
				["ST"] = 20,
				["QA"] = 2,
				["SB"] = false,
				["WA"] = false,
				["VA"] = 100,
				["IC"] = "INV_Misc_Ammo_Bullet_04",
				["CR"] = true,
				["US"] = false,
				["UN"] = false,
				["LE"] = "Ammunition",
				["CO"] = false,
				["QE"] = false,
				["NA"] = "Bullet",
				["CT"] = false,
				["RI"] = "6mm",
			},
			["SC"] = {
				["onUse"] = {
					["ST"] = {
					},
				},
			},
			["CO"] = {
				["SC"] = "4",
				["MW"] = 0,
				["DU"] = 0,
				["SI"] = "5x4",
				["SR"] = "5",
			},
			["IN"] = {
			},
			["MD"] = {
				["MO"] = "NO",
			},
			["TY"] = "IT",
		},
		["press"] = {
			["US"] = {
				["SC"] = "onUse",
				["AC"] = "Create 10 bullets",
			},
			["BA"] = {
				["DE"] = "An ammo press to make bullet.s.",
				["CT"] = false,
				["QA"] = 3,
				["SB"] = false,
				["WA"] = false,
				["VA"] = 4000,
				["IC"] = "INV_Misc_Ammo_Gunpowder_02",
				["CR"] = false,
				["US"] = true,
				["QE"] = false,
				["LE"] = "Tool",
				["CO"] = false,
				["UN"] = false,
				["NA"] = "Bullet press",
				["ST"] = false,
				["WE"] = 4000,
			},
			["SC"] = {
				["onUse"] = {
					["ST"] = {
						["1"] = {
							["e"] = {
								{
									["id"] = "sound_id_self",
									["args"] = {
										"SFX", -- [1]
										17935, -- [2]
									},
								}, -- [1]
							},
							["t"] = "list",
							["n"] = "2",
						},
						["3"] = {
							["e"] = {
								{
									["id"] = "item_add",
									["args"] = {
										"rifle bullet", -- [1]
										10, -- [2]
										true, -- [3]
									},
								}, -- [1]
							},
							["t"] = "list",
						},
						["2"] = {
							["i"] = 1,
							["c"] = 1,
							["d"] = 1.5,
							["t"] = "delay",
							["n"] = "3",
						},
					},
				},
			},
			["CO"] = {
				["SC"] = "4",
				["SR"] = "5",
				["SI"] = "5x4",
				["DU"] = 0,
				["MW"] = 0,
			},
			["TY"] = "IT",
			["MD"] = {
				["MO"] = "NO",
			},
			["IN"] = {
			},
		},
	},
	["US"] = {
		["SC"] = "onUse",
		["AC"] = "Pull the trigger",
	},
	["TY"] = "IT",
};