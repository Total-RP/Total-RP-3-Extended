----------------------------------------------------------------------------------
-- Total RP 3: Quest DB
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

local DB_TEXTS = {
	doc1 = [[{h1}Contract for job{/h1}
The Valley of Northsire is under the attack of an armed group of orcs and gobelins.
The King is offering rewards to any brave soldiers willing to take the arms

If you want to help protecting your lands, please talk to an Army Registrar in front on the abbey.

For the King,
Marshal McBride





{img:Interface\PvPRankBadges\PvPRankAlliance.blp:128:128}]]
}

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CAMPAIGN DB
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local coinCampaign = {
	["AC"] = {
		{
			["TY"] = "TALK",
			["SC"] = "on_bad_talk",
			["CO"] = {
				{
					{
						["i"] = "unit_npc_id",
						["a"] = {
							"target", -- [1]
						},
					}, -- [1]
					"==", -- [2]
					{
						["v"] = 37776,
					}, -- [3]
				}, -- [1]
				"*", -- [2]
				{
					{
						["i"] = "unit_npc_id",
						["a"] = {
							"target", -- [1]
						},
					}, -- [1]
					"==", -- [2]
					{
						["v"] = 88501,
					}, -- [3]
				}, -- [3]
				"*", -- [4]
				{
					{
						["i"] = "unit_npc_id",
						["a"] = {
							"target", -- [1]
						},
					}, -- [1]
					"==", -- [2]
					{
						["v"] = 88502,
					}, -- [3]
				}, -- [5]
				"*", -- [6]
				{
					{
						["i"] = "unit_npc_id",
						["a"] = {
							"target", -- [1]
						},
					}, -- [1]
					"==", -- [2]
					{
						["v"] = 7292,
					}, -- [3]
				}, -- [7]
				"*", -- [8]
				{
					{
						["i"] = "unit_npc_id",
						["a"] = {
							"target", -- [1]
						},
					}, -- [1]
					"==", -- [2]
					{
						["v"] = 64153,
					}, -- [3]
				}, -- [9]
				"*", -- [10]
				{
					{
						["i"] = "unit_npc_id",
						["a"] = {
							"target", -- [1]
						},
					}, -- [1]
					"==", -- [2]
					{
						["v"] = 65578,
					}, -- [3]
				}, -- [11]
			},
		}, -- [1]
		{
			["TY"] = "TALK",
			["SC"] = "on_talk",
			["CO"] = {
				{
					{
						["i"] = "quest_is_npc",
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
		}, -- [2]
	},
	["BA"] = {
		["IC"] = "inv_misc_coinbag_special",
		["RA"] = "1 - 110",
		["DE"] = "This campaign allows you to talk to bankers in order to get coins.",
		["IM"] = "GarrZoneAbility-TradingPost",
		["NA"] = "Currency",
	},
	["SC"] = {
		["on_talk"] = {
			["ST"] = {
				["1"] = {
					["e"] = {
						{
							["id"] = "dialog_quick",
							["args"] = {
								"Ho! You are here for your money, right? Here, take whatever you want.", -- [1]
							},
						}, -- [1]
					},
					["t"] = "list",
					["n"] = "2",
				},
				["2"] = {
					["e"] = {
						{
							["id"] = "item_loot",
							["args"] = {
								{
									"The bank", -- [1]
									"inv_misc_coinbag_special", -- [2]
									{
										{
											["classID"] = "coinCampaign copper",
											["count"] = 10,
										}, -- [1]
										{
											["classID"] = "coinCampaign silver",
											["count"] = 10,
										}, -- [2]
										{
											["classID"] = "coinCampaign gold",
											["count"] = 10,
										}, -- [3]
										{
											["classID"] = "coinCampaign copper",
											["count"] = 100,
										}, -- [4]
										{
											["classID"] = "coinCampaign silver",
											["count"] = 100,
										}, -- [5]
										{
											["classID"] = "coinCampaign gold",
											["count"] = 100,
										}, -- [6]
									}, -- [3]
								}, -- [1]
								{
								}, -- [2]
							},
						}, -- [1]
					},
					["t"] = "list",
				},
			},
		},
		["on_bad_talk"] = {
			["ST"] = {
				["1"] = {
					["e"] = {
						{
							["id"] = "dialog_quick",
							["args"] = {
								"Hello. What? No, I don't have your money. You should ask one of the banker instead.", -- [1]
							},
						}, -- [1]
					},
					["t"] = "list",
				},
			},
		},
	},
	["securityLevel"] = 3,
	["NT"] = "This campaign shows how a campaign can be used more as a shop/event system than a set of quests.\n\nThis shouldn't be consider as an IC method to get money. ;)\n\nWe suggest that all creators use these coins if there are transactions to be done in their quests.",
	["MD"] = {
		["CD"] = "25/08/16 10:37:19",
		["LO"] = "en",
		["CB"] = "Ellypse-CultedelaRivenoire",
		["SB"] = "Ellÿpse-KirinTor",
		["MO"] = "NO",
		["SD"] = "18/09/16 10:55:14",
		["V"] = 58,
	},
	["ND"] = {
		["29282"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins, if you can catch their attention behind the bars...",
		},
		["98842"] = {
			["IC"] = "Ability_Racial_PackHobgoblin",
			["DE"] = "Talk to this person to get some coins.",
		},
		["88468"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["8123"] = {
			["IC"] = "Ability_Racial_PackHobgoblin",
			["DE"] = "Talk to this person to get some coins.",
		},
		["45661"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["4209"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["44852"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["64023"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["88471"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["43840"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["85957"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["16617"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Bloodelf",
			["DE"] = "Talk to this person to get some coins.",
		},
		["2455"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["63971"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["43723"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["46618"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["63967"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["95966"] = {
			["IC"] = "Ability_Racial_PackHobgoblin",
			["DE"] = "Talk to this person to get some coins.",
		},
		["88472"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["2460"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["95974"] = {
			["IC"] = "Ability_Racial_PackHobgoblin",
			["DE"] = "Talk to this person to get some coins.",
		},
		["4550"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Scourge",
			["DE"] = "Talk to this person to get some coins.",
		},
		["63969"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["43819"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["17632"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Bloodelf",
			["DE"] = "Talk to this person to get some coins.",
		},
		["43724"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["7292"] = {
			["IC"] = "Achievement_Character_Dwarf_Female",
			["DE"] = "She is the vault administrator, she must know where your money is.",
		},
		["98841"] = {
			["IC"] = "Ability_Racial_PackHobgoblin",
			["DE"] = "Talk to this person to get some coins.",
		},
		["63966"] = {
			["IC"] = "Ability_Racial_PackHobgoblin",
			["DE"] = "Talk to this person to get some coins.",
		},
		["63970"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["8357"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Tauren",
			["DE"] = "Talk to this person to get some coins.",
		},
		["45662"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["2625"] = {
			["IC"] = "Ability_Racial_PackHobgoblin",
			["DE"] = "Talk to this person to get some coins.",
		},
		["43824"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["43692"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["30605"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
		["16710"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["43820"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["45081"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["17631"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Bloodelf",
			["DE"] = "Talk to this person to get some coins.",
		},
		["4549"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Scourge",
			["DE"] = "Talk to this person to get some coins.",
		},
		["44770"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["44854"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["96819"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
		["2461"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["30606"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins, if you can catch their attention behind the bars...",
		},
		["43822"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["2457"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["46621"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["28675"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
		["8356"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Tauren",
			["DE"] = "Talk to this person to get some coins.",
		},
		["2996"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Tauren",
			["DE"] = "Talk to this person to get some coins.",
		},
		["88501"] = {
			["IC"] = "Achievement_Character_Dwarf_Male",
			["DE"] = "He's right next to a pile of gold. Does he have your money?",
		},
		["96821"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
		["2458"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Scourge",
			["DE"] = "Talk to this person to get some coins.",
		},
		["63965"] = {
			["IC"] = "Ability_Racial_PackHobgoblin",
			["DE"] = "Talk to this person to get some coins.",
		},
		["46620"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["16616"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Bloodelf",
			["DE"] = "Talk to this person to get some coins.",
		},
		["96818"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
		["96822"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
		["28677"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
		["17773"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["43725"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["96817"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
		["44856"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["88502"] = {
			["IC"] = "Achievement_Character_Dwarf_Female",
			["DE"] = "She's sitting on a chest. Does it contain your money?",
		},
		["44853"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["2456"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["64024"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["43825"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["64153"] = {
			["IC"] = "Achievement_Character_Gnome_Female",
			["DE"] = "She's counting money. Is it yours?",
		},
		["96823"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
		["63968"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["37776"] = {
			["IC"] = "Achievement_KirinTor_Offensive",
			["DE"] = "Is she a banker?",
		},
		["28676"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
		["65578"] = {
			["IC"] = "INV_Helmet_47",
			["DE"] = "This guy looks shady. Does he have your money?",
		},
		["4208"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["2459"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Scourge",
			["DE"] = "Talk to this person to get some coins.",
		},
		["4155"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["16615"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Bloodelf",
			["DE"] = "Talk to this person to get some coins.",
		},
		["30604"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
		["5099"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["17633"] = {
			["IC"] = "Inv_Misc_Tournaments_banner_Bloodelf",
			["DE"] = "Talk to this person to get some coins.",
		},
		["63964"] = {
			["IC"] = "Ability_Racial_PackHobgoblin",
			["DE"] = "Talk to this person to get some coins.",
		},
		["30608"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins, if you can catch their attention behind the bars...",
		},
		["85958"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["88469"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["18350"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["43823"] = {
			["IC"] = "Battleground_Strongbox_Gold_Alliance",
			["DE"] = "Talk to this person to get some coins.",
		},
		["46619"] = {
			["IC"] = "Battleground_Strongbox_Gold_Horde",
			["DE"] = "Talk to this person to get some coins.",
		},
		["30607"] = {
			["IC"] = "inv_misc_coinbag_special",
			["DE"] = "Talk to this person to get some coins.",
		},
	},
	["TY"] = "CA",
	["HA"] = {
	},
	["IN"] = {
		["silver"] = {
			["US"] = {
				["SC"] = "onUse",
			},
			["BA"] = {
				["QA"] = 1,
				["ST"] = 999,
				["DE"] = "A silver coin used for transactions around the world. Worth 100 coppers.",
				["SB"] = false,
				["WA"] = false,
				["QE"] = false,
				["US"] = false,
				["CR"] = false,
				["IC"] = "INV_Misc_Coin_18",
				["UN"] = false,
				["LE"] = "Currency",
				["CO"] = false,
				["VA"] = 100,
				["NA"] = "Silver coin",
				["CT"] = false,
				["WE"] = 10,
			},
			["SC"] = {
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
				["MO"] = "QU",
			},
			["TY"] = "IT",
		},
		["copper"] = {
			["US"] = {
				["SC"] = "onUse",
			},
			["BA"] = {
				["QA"] = 1,
				["ST"] = 999,
				["DE"] = "A copper coin used for transactions around the world.",
				["SB"] = false,
				["WA"] = false,
				["QE"] = false,
				["IC"] = "INV_Misc_Coin_19",
				["CR"] = false,
				["US"] = false,
				["UN"] = false,
				["LE"] = "Currency",
				["CO"] = false,
				["VA"] = 1,
				["NA"] = "Copper coin",
				["CT"] = false,
				["WE"] = 5,
			},
			["SC"] = {
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
				["MO"] = "QU",
			},
			["TY"] = "IT",
		},
		["gold"] = {
			["US"] = {
				["SC"] = "onUse",
			},
			["BA"] = {
				["QA"] = 1,
				["ST"] = 999,
				["DE"] = "A gold coin used for transactions around the world. Worth 100 silvers.",
				["SB"] = false,
				["WA"] = false,
				["QE"] = false,
				["US"] = false,
				["CR"] = false,
				["IC"] = "INV_Misc_Coin_17",
				["UN"] = false,
				["LE"] = "Currency",
				["CO"] = false,
				["VA"] = 10000,
				["NA"] = "Gold coin",
				["CT"] = false,
				["WE"] = 15,
			},
			["SC"] = {
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
				["MO"] = "QU",
			},
			["TY"] = "IT",
		},
	},
	["LI"] = {
	},
	["details"] = {
	},
	["QE"] = {
	},
};
TRP3_DB.inner.coinCampaign = coinCampaign;