----------------------------------------------------------------------------------
-- Total RP 3: Campaign system
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

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local CAMPAIGN_DB = TRP3_DB.campaign;
local EMPTY = TRP3_API.globals.empty;
local tostring, assert, pairs, wipe, tinsert = tostring, assert, pairs, wipe, tinsert;
local loc = TRP3_API.loc;
local Log = Utils.log;
local getClass, getClassDataSafe = TRP3_API.extended.getClass, TRP3_API.extended.getClassDataSafe;

local tooltip = TRP3_NPCTooltip;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- On target
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local getUnitDataFromGUID = Utils.str.getUnitDataFromGUID;

local function onTargetChanged()
	local unitType, npcID = getUnitDataFromGUID("target");
	if unitType == "Creature" and npcID then
		local campaignClass = TRP3_API.quest.getCurrentCampaignClass();
		if campaignClass and campaignClass.ND and campaignClass.ND[npcID] then
			local npcData = campaignClass.ND[npcID];
			if npcData.NA then
				TargetFrameTextureFrameName:SetText(npcData.NA);
			end
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- On mouse over
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local npcTooltipBuilder = TRP3_API.ui.tooltip.createTooltipBuilder(tooltip);

local function getCurrentMaxSize()
	return 300;
end

local function showIcon()
	return true;
end

local function embedOriginal()
	return false;
end

local function onMouseOver()
	tooltip:Hide();
	local unitType, npcID = getUnitDataFromGUID("mouseover");
	if unitType == "Creature" and npcID then
		local campaignClass = TRP3_API.quest.getCurrentCampaignClass();
		if campaignClass and campaignClass.ND and campaignClass.ND[npcID] then
			local npcData = campaignClass.ND[npcID];
			local originalName = UnitName("mouseover");
			local originalTexts = TRP3_API.ui.tooltip.getGameTooltipTexts(GameTooltip);

			tooltip.unitType = unitType;
			tooltip.targetID = npcID;
			tooltip:SetOwner(GameTooltip, "ANCHOR_TOPRIGHT");

			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			-- Icon and name
			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

			local leftIcons = "";

			if showIcon() then
				-- Companion icon
				if npcData.IC then
					leftIcons = strconcat(Utils.str.icon(npcData.IC, 25), leftIcons, " ");
				end
			end

			npcTooltipBuilder:AddLine(leftIcons .. (npcData.NA or originalName), 1, 1, 1, TRP3_API.ui.tooltip.getMainLineFontSize());

			npcTooltipBuilder:AddLine("< " .. loc.QE_NPC .. " >", 0, 1, 0, TRP3_API.ui.tooltip.getSubLineFontSize());

			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			-- Description
			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

			if (npcData.DE or ""):len() > 0 then
				local text = strtrim(npcData.DE);
				if text:len() > getCurrentMaxSize() then
					text = text:sub(1, getCurrentMaxSize()) .. "…";
				end
				npcTooltipBuilder:AddSpace();
				npcTooltipBuilder:AddLine("\"" .. text .. "\"", 1, 0.75, 0, TRP3_API.ui.tooltip.getSmallLineFontSize(), true);
			end

			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			-- Original text
			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

			if embedOriginal() then
				npcTooltipBuilder:AddSpace();
				for _, text in pairs(originalTexts) do
					npcTooltipBuilder:AddLine(text, 1, 1, 1, TRP3_API.ui.tooltip.getSmallLineFontSize());
				end
			end

			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			-- Build
			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

			npcTooltipBuilder:Build();

			if embedOriginal() then
				GameTooltip:Hide();
			end
			tooltip:ClearAllPoints();
		end
	end
end

local function onTooltipUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	if self.TimeSinceLastUpdate > 0.5 then
		self.TimeSinceLastUpdate = 0;
		if self.targetID and not self.isFading then
			local unitType, npcID = getUnitDataFromGUID("mouseover");
			if self.unitType ~= unitType or self.targetID ~= npcID then
				self.isFading = true;
				self.targetID = nil;
				self:FadeOut();
			end
		end
	end
end

local UnitExists = UnitExists;

function TRP3_API.quest.UnitIsCampaignNPC(unit)
	if UnitExists(unit) then
		local unitType, npcID = getUnitDataFromGUID(unit);
		if unitType == "Creature" and npcID then
			local campaignClass = TRP3_API.quest.getCurrentCampaignClass();
			if campaignClass and campaignClass.ND and campaignClass.ND[npcID] then
				return true;
			end
		end
	end
	return false;
end

function TRP3_API.quest.GetCampaignNPCName(unit)
	local unitType, npcID = getUnitDataFromGUID(unit);
	if unitType == "Creature" and npcID then
		local campaignClass = TRP3_API.quest.getCurrentCampaignClass();
		if campaignClass and campaignClass.ND and campaignClass.ND[npcID] then
			local npcData = campaignClass.ND[npcID];
			if npcData.NA then
				return npcData.NA;
			end
		end
	end
	return nil;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Init
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function init()
	Utils.event.registerHandler("PLAYER_TARGET_CHANGED", onTargetChanged);
	Utils.event.registerHandler("UPDATE_MOUSEOVER_UNIT", onMouseOver);

	tooltip.TimeSinceLastUpdate = 0;
	tooltip:SetScript("OnUpdate", onTooltipUpdate);

	-- Slash command to reset frames
	TRP3_API.slash.registerCommand({
		id = "getID",
		helpLine = loc.COM_NPC_ID,
		handler = function()
			print(getUnitDataFromGUID("target"));
		end
	});
end

TRP3_API.quest.npcInit = init;