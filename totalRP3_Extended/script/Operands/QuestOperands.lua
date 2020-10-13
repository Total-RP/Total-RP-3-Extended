----------------------------------------------------------------------------------
--- Total RP 3
--- Scripts : Quest Operands
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
