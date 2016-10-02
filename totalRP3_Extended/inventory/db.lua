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
	securityLevel = 3,
	TY = TRP3_DB.types.ITEM,
	BA = {
		NA = "Main inventory",
	},
	CO = {},
}

TRP3_DB.inner.bag = {
	TY = TRP3_DB.types.ITEM,
	securityLevel = 3,
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
		["NA"] = "Default bag",
		["WE"] = 500,
		["CT"] = true,
	},
	["MD"] = {
		["CD"] = "28/04/16 17:36:38",
		["CB"] = "TRP3 Team",
		["SB"] = "TRP3 Team",
		["MO"] = "NO",
		["SD"] = "28/04/16 17:36:41",
		["V"] = 2,
	},
}

TRP3_DB.inner.rifle = {
	securityLevel = 3,
	["IN"] = {
		["bullet"] = {
			["US"] = {
				["SC"] = "onUse",
			},
			NT = "This inner object is the bullet to be used in the Simple rifle root object.",
			["BA"] = {
				["DE"] = "Made to be charged in a [Simple rifle] ammo clip.",
				["IC"] = "INV_Misc_Ammo_Bullet_02",
				["LE"] = "Ammunition",
				["CO"] = false,
				["NA"] = "Simple bullet",
				["ST"] = false,
				["QA"] = 1,
				["SB"] = false,
				["WA"] = false,
				["VA"] = 0,
				["CR"] = true,
				["RI"] = "12mm",
				["US"] = false,
				["UN"] = false,
				["QE"] = false,
				["CT"] = false,
				["WE"] = 100,
			},
			["SC"] = {
				["onUse"] = {
					["ST"] = {
					},
				},
			},
			["CO"] = {
				["OI"] = false,
				["MW"] = 0,
				["DU"] = 0,
				["SC"] = "4",
				["SI"] = "5x4",
				["SR"] = "5",
			},
			["IN"] = {
			},
			["MD"] = {
				["MO"] = "EX",
			},
			["TY"] = "IT",
		},
	},
	["TY"] = "IT",
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
				["3"] = {
					["i"] = 1,
					["c"] = 1,
					["d"] = 0.8,
					["t"] = "delay",
					["n"] = "4",
				},
				["2"] = {
					["b"] = {
						{
							["n"] = "3",
							["cond"] = {
								{
									{
										["i"] = "inv_item_count_con",
										["a"] = {
											"rifle bullet", -- [1]
										},
									}, -- [1]
									">", -- [2]
									{
										["v"] = 0,
									}, -- [3]
								}, -- [1]
							},
						}, -- [1]
					},
					["t"] = "branch",
				},
				["5"] = {
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
					["n"] = "6",
				},
				["4"] = {
					["e"] = {
						{
							["id"] = "item_remove",
							["args"] = {
								"rifle bullet", -- [1]
								1, -- [2]
								"self", -- [3]
							},
						}, -- [1]
					},
					["t"] = "list",
					["n"] = "5",
				},
				["7"] = {
					["b"] = {
						{
							["n"] = "8",
							["cond"] = {
								{
									{
										["i"] = "unit_exists",
										["a"] = {
											"target", -- [1]
										},
									}, -- [1]
									"==", -- [2]
									{
										["v"] = true,
									}, -- [3]
								}, -- [1]
							},
						}, -- [1]
					},
					["t"] = "branch",
				},
				["6"] = {
					["e"] = {
						{
							["id"] = "item_cooldown",
							["args"] = {
								3, -- [1]
							},
						}, -- [1]
					},
					["t"] = "list",
					["n"] = "7",
				},
				["9"] = {
					["e"] = {
						{
							["id"] = "text",
							["args"] = {
								"Stop shooting people!", -- [1]
								1, -- [2]
							},
						}, -- [1]
					},
					["t"] = "list",
				},
				["8"] = {
					["i"] = 1,
					["c"] = 1,
					["d"] = 0.5,
					["t"] = "delay",
					["n"] = "9",
				},
			},
		},
	},
	NT = "This item shows you that a container is not limited to be a bag. Here we have a gun and it's a container to be able to contain the needed ammo.",
	["US"] = {
		["SC"] = "onUse",
		["AC"] = "Pull the trigger",
	},
	["CO"] = {
		["OI"] = true,
		["MW"] = 0,
		["DU"] = 25,
		["SC"] = "4",
		["SI"] = "1x4",
		["SR"] = "1",
	},
	["MD"] = {
		["CD"] = "26/05/16 11:42:07",
		["CB"] = "TRP3 Team",
		["SB"] = "TRP3 Team",
		["MO"] = "NO",
		["SD"] = "19/06/16 16:14:15",
		["V"] = 44,
	},
	["BA"] = {
		["DE"] = "A rifle with a 4 slots clip. Double click on the rifle to open the ammo clip. Example item from TRP3 authors.",
		["US"] = true,
		["LE"] = "Weapon",
		["CO"] = false,
		["NA"] = "Simple rifle",
		["ST"] = false,
		["QA"] = 2,
		["SB"] = false,
		["QE"] = false,
		["CR"] = false,
		["RI"] = "Gun",
		["IC"] = "INV_Firearm_2h_Rifle_DraenorCrafted_D_01_B_alliance",
		["VA"] = 50000,
		["WA"] = true,
		["CT"] = true,
		["WE"] = 5000,
	},
};

TRP3_DB.inner.letterexample = {
	securityLevel = 3,
	["US"] = {
		["AC"] = "Read the letter",
		["SC"] = "onUse",
	},
	NT = "This is an example of a simple item showing a document when used.",
	["BA"] = {
		["QA"] = 8,
		["ST"] = false,
		["DE"] = "Sealed with wax that smells like rose.",
		["SB"] = false,
		["WA"] = false,
		["VA"] = 0,
		["IC"] = "INV_Letter_04",
		["CR"] = false,
		["US"] = true,
		["QE"] = false,
		["LE"] = "Mysterious mail",
		["CO"] = false,
		["UN"] = false,
		["NA"] = "Anonymous letter",
		["CT"] = false,
		["WE"] = 120,
	},
	["SC"] = {
		["onUse"] = {
			["ST"] = {
				["1"] = {
					["e"] = {
						{
							["id"] = "document_show",
							["args"] = {
								"letterexample letter", -- [1]
							},
						}, -- [1]
					},
					["t"] = "list",
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
	["IN"] = {
		["letter"] = {
			["BT"] = true,
			["WI"] = 450,
			["PA"] = {
				{
					["TX"] = "{h1:c}Plate Fetish Night{/h1}\n{img:Interface\\ARCHEOLOGY\\ArchRare-DraeneiRelic:400:200}\n\nDear subscriber,\n\nYou received this letter because your are a precious member of the Plate Fetish Circle (PFC).\n\nIt's with joy that we invite you to our monthly fetish night, where all dreams become true.\n\nIt's on this Friday 10 PM at the Goldshire Inn\n\nKind regards,\n\n{h2:r}The PFC{/h2}",
				}, -- [1]
				{
					["TX"] = "(PS: Please bring your own dishes)",
				}, -- [2]
			},
			["TY"] = "DO",
			["BCK"] = 8,
			["HE"] = 600,
			["BO"] = 1,
			["BA"] = {
				["NA"] = "Letter",
			},
			["FR"] = false,
			["MD"] = {
				["MO"] = "NO",
			},
			["H1_F"] = "DestinyFontHuge",
			["H2_F"] = "QuestFont_Huge",
			["P_F"] = "GameTooltipHeader",
			["H3_F"] = "GameFontNormalLarge",
		},
	},
	["MD"] = {
		["CD"] = "29/04/16 20:29:09",
		["CB"] = "TRP3 Team",
		["SB"] = "TRP3 Team",
		["MO"] = "NO",
		["SD"] = "30/04/16 19:27:36",
		["V"] = 8,
	},
	["TY"] = "IT",
};