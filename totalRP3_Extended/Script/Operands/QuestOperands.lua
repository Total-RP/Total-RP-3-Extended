-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

---@type TRP3_API
local TRP3_API = TRP3_API

---@type TotalRP3_Extended_Operand
local Operand = TRP3_API.script.Operand;
local getSafe = TRP3_API.getSafeValueFromTable;

local questIsAtStepOperand = Operand("quest_is_step", {
	["getQuestCurrentStep"] = "TRP3_API.quest.getQuestCurrentStep"
});

local function getSafeSplit(args, numberOfArgsExpected, defaultValue)
	local values = { TRP3_API.extended.splitID(getSafe(args, 1, defaultValue)) }
	for i = 1, numberOfArgsExpected do
		if values[i] == nil then
			values[i] = defaultValue
		end
	end
	return unpack(values)
end

function questIsAtStepOperand:CodeReplacement(args)
	local campaignID, questID = getSafeSplit(args, 2, "");
	return ([[getQuestCurrentStep("%s", "%s")]]):format(campaignID, questID);
end

local isQuestObjectiveCompletedOperand = Operand("quest_obj", {
	["isQuestObjectiveDone"] = "TRP3_API.quest.isQuestObjectiveDone"
});

function isQuestObjectiveCompletedOperand:CodeReplacement(args)
	local campaignID, questID = getSafeSplit(args, 2, "");
	local objectiveID = getSafe(args, 2, "");
	return ([[isQuestObjectiveDone("%s", "%s", "%s")]]):format(campaignID, questID, objectiveID);
end

local isQuestObjectiveCurrentOperand = Operand("quest_obj_current", {
	["isAllQuestObjectiveDone"] = "TRP3_API.quest.isAllQuestObjectiveDone"
});

function isQuestObjectiveCurrentOperand:CodeReplacement(args)
	local campaignID, questID = getSafeSplit(args, 2, "");
	return ([[isAllQuestObjectiveDone("%s", "%s", false)]]):format(campaignID, questID);
end

local areAllQuestObjectivesCompletedOperand = Operand("quest_obj_all", {
	["isAllQuestObjectiveDone"] = "TRP3_API.quest.isAllQuestObjectiveDone"
});

function areAllQuestObjectivesCompletedOperand:CodeReplacement(args)
	local campaignID, questID = getSafeSplit(args, 2, "");
	return ([[isAllQuestObjectiveDone("%s", "%s", true)]]):format(campaignID, questID);
end

local isUnitAQuestNpcOperand = Operand("quest_is_npc", {
	["UnitIsCampaignNPC"] = "TRP3_API.quest.UnitIsCampaignNPC"
});

function isUnitAQuestNpcOperand:CodeReplacement(args)
	local unitId = getSafe(args, 1, "target");
	return ([[UnitIsCampaignNPC("%s")]]):format(unitId);
end

local activeCampaignOperand = Operand("quest_active_campaign", {
	["getCurrentCampaignID"] = "TRP3_API.quest.getCurrentCampaignID"
});

function activeCampaignOperand:CodeReplacement()
	return ([[getCurrentCampaignID()]]);
end
