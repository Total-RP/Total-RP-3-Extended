local assert = assert;
local toolFrame;
local loc = TRP3_API.loc;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Aura base frame
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.getAuraItemData(id)

	local profile = TRP3_API.profile.getPlayerCurrentProfile();
	if not profile or not profile.player or not profile.player.misc or not profile.player.misc.PE then
		return nil
	end
	local numTraits = 0;
	for index, trait in pairs(profile.player.misc.PE) do
		if trait.AC then
			numTraits = numTraits + 1
		end
	end
	if numTraits == 0 then
		return nil
	end
	
	local data = TRP3_API.extended.tools.getBlankItemData(TRP3_DB.modes.NORMAL);
	data.BA.IC = "ability_priest_spiritoftheredeemer";
	data.BA.US = true;
	data.US = {
		AC = loc.AU_EXAMPLE_ACTION,
		SC = "onUse"
	};
	data.SC = {
		["onUse"] = {
			ST = {
			}
		}
	};
	data.IN = {
	};
	local currTrait = 0
	for index, trait in pairs(profile.player.misc.PE) do
		if trait.AC then
			currTrait = currTrait + 1
			local innerId = "aura" .. tostring(index)
			data.IN[innerId] = {
				MD = {
					MO = TRP3_DB.modes.NORMAL,
				},
				TY = TRP3_DB.types.AURA,
				BA = {
					NA = trait.TI,
					DE = trait.TX,
					IC = trait.IC,
					HE = true,
					CC = true,
				},
			};
			local step = {
				e = {
					{
						id = "aura_apply",
						args = {
							id .. TRP3_API.extended.ID_SEPARATOR .. innerId,
							false,
						},
					},
				},
				t = "list",
			};
			if currTrait < numTraits then
				step.n = tostring(currTrait + 1)
			end	
			data.SC["onUse"].ST[tostring(currTrait)] = step;
		end
	end

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
