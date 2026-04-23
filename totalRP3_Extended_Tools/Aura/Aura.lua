local loc = TRP3_API.loc;

function TRP3_API.extended.tools.getAuraItemData(id)
	local data = TRP3_API.extended.tools.getBlankItemData(TRP3_DB.modes.NORMAL);
	data.BA.IC = "ability_priest_spiritoftheredeemer";
	data.BA.US = true;
	data.US = {
		AC = loc.EFFECT_AURA_APPLY,
		SC = "onUse"
	};
	data.SC = {
		["onUse"] = {
			ST = {
				["1"] = {
					e = {
						{
							id = "aura_apply",
							args = {
								id .. TRP3_API.extended.ID_SEPARATOR .. "aura",
								"=",
							},
						},
					},
					t = "list",
				}
			}
		}
	};
	data.IN = {
		["aura"] = {
			MD = {
				MO = TRP3_DB.modes.NORMAL,
			},
			TY = TRP3_DB.types.AURA,
			BA = {
				NA = loc.AU_NEW_NAME,
				IC = "ability_priest_spiritoftheredeemer",
				DU = 300,
				HE = true,
				CC = true,
				WE = true,
			},
		},
	};
	return data;
end
