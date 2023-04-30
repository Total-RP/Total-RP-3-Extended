local assert = assert;
local toolFrame;
local loc = TRP3_API.loc;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Aura base frame
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

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

local function onLoad()
	assert(toolFrame.rootClassID, "rootClassID is nil");
	assert(toolFrame.fullClassID, "fullClassID is nil");
	assert(toolFrame.rootDraft, "rootDraft is nil");
	assert(toolFrame.specificDraft, "specificDraft is nil");

	toolFrame.aura.normal:Show();
	toolFrame.aura.normal.load();
end

local function onSave()
	assert(toolFrame.specificDraft, "specificDraft is nil");
	toolFrame.aura.normal.saveToDraft();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initAura(ToolFrame)
	toolFrame = ToolFrame;
	toolFrame.aura.onLoad = onLoad;
	toolFrame.aura.onSave = onSave;

	TRP3_API.extended.tools.initAuraEditorNormal(toolFrame);
end
