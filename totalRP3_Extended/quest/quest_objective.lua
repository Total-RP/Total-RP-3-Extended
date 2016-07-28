----------------------------------------------------------------------------------
-- Total RP 3: Quest objectives
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
----------------------------------------------------------------------------------

local function init()
	TRP3_QuestObjectives:Show();

	-- Temp
	TRP3_QuestObjectives:SetFontObject("p", GameTooltipHeader);
	TRP3_QuestObjectives:SetTextColor("p", 0.95, 0.95, 0.95);
	TRP3_QuestObjectives:SetShadowOffset("p", 0, 0)
	TRP3_QuestObjectives:SetFontObject("h1", DestinyFontHuge);
	TRP3_QuestObjectives:SetTextColor("h1", 0.95, 0.95, 0.95);
	TRP3_QuestObjectives:SetFontObject("h2", QuestFont_Huge);
	TRP3_QuestObjectives:SetTextColor("h2", 0.95, 0.95, 0.95);
	TRP3_QuestObjectives:SetFontObject("h3", GameFontNormalLarge);
	TRP3_QuestObjectives:SetTextColor("h3", 1, 1, 1);
	TRP3_QuestObjectives.html = Utils.str.toHTML("Objectives");
	TRP3_QuestObjectives:SetText(TRP3_QuestObjectives.html);

	if ObjectiveTrackerBlocksFrame.QuestHeader.module.lastBlock then
		TRP3_QuestObjectives:SetPoint("TOP", ObjectiveTrackerBlocksFrame.QuestHeader.module.lastBlock, "BOTTOM", 0, 0);
	end
end