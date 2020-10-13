----------------------------------------------------------------------------------
--- Total RP 3
---
--- Quest Operands Tests
---	---------------------------------------------------------------------------
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
