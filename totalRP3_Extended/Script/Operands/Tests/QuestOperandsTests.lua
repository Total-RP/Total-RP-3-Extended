-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

if not WoWUnit then
	return
end

---@type TRP3_API
local TRP3_API = TRP3_API;

---@type fun(id: string):TotalRP3_Extended_Operand
local getOperand = TRP3_API.script.getOperand;
local execute = TRP3_API.extended.executeOperandInSafeEnv;

local Tests = WoWUnit('TRP3:E Quest Operands', "PLAYER_ENTERING_WORLD");

function Tests:QuestIsAtStep()
	local operand = getOperand("quest_is_step");
	WoWUnit.Replace(TRP3_API.quest, 'getQuestCurrentStep', function(campaignId, questId)
		WoWUnit.AreEqual("my_camp", campaignId)
		WoWUnit.AreEqual("my_quest", questId)
		return 42
	end)
	WoWUnit.AreEqual(42, execute(operand, { "my_camp" .. TRP3_API.extended.ID_SEPARATOR .. "my_quest" }))
end

function Tests:IsQuestObjCompleted()
	local operand = getOperand("quest_obj");
	WoWUnit.Replace(TRP3_API.quest, 'isQuestObjectiveDone', function(campaignId, questId, objectiveId)
		WoWUnit.AreEqual("my_camp", campaignId)
		WoWUnit.AreEqual("my_quest", questId)
		WoWUnit.AreEqual("my_obj", objectiveId)
		return true
	end)
	WoWUnit.IsTrue(execute(operand, { "my_camp".. TRP3_API.extended.ID_SEPARATOR .. "my_quest", "my_obj" }))
end

function Tests:IsQuestObjCurrent()
	local operand = getOperand("quest_obj_current");
	WoWUnit.Replace(TRP3_API.quest, 'isAllQuestObjectiveDone', function(campaignId, questId, flag)
		WoWUnit.AreEqual("my_camp", campaignId)
		WoWUnit.AreEqual("my_quest", questId)
		WoWUnit.IsFalse(flag)
		return true
	end)
	WoWUnit.IsTrue(execute(operand, { "my_camp".. TRP3_API.extended.ID_SEPARATOR .. "my_quest" }))
end

function Tests:AreAllQuestObjCompleted()
	local operand = getOperand("quest_obj_all");
	WoWUnit.Replace(TRP3_API.quest, 'isAllQuestObjectiveDone', function(campaignId, questId, flag)
		WoWUnit.AreEqual("my_camp", campaignId)
		WoWUnit.AreEqual("my_quest", questId)
		WoWUnit.IsTrue(flag)
		return true
	end)
	WoWUnit.IsTrue(execute(operand, { "my_camp" .. TRP3_API.extended.ID_SEPARATOR .. "my_quest" }))
end

function Tests:UnitIsQuestNpc()
	local operand = getOperand("quest_is_npc");
	WoWUnit.Replace(TRP3_API.quest, 'UnitIsCampaignNPC', function(unitId)
		WoWUnit.AreEqual("focus", unitId)
		return true
	end)
	WoWUnit.IsTrue(execute(operand, { "focus" }))
end
