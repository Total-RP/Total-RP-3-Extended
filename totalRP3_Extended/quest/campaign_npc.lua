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

local Utils = TRP3_API.utils;
local pairs = pairs;
local loc = TRP3_API.loc;
local getConfigValue = TRP3_API.configuration.getValue;

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
				TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:SetText(npcData.NA);
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

local function hideOriginal()
	return getConfigValue(TRP3_API.extended.CONFIG_NPC_HIDE_ORIGINAL);
end

local function embedOriginal()
	return getConfigValue(TRP3_API.extended.CONFIG_NPC_EMBED_ORIGINAL);
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
			local tooltipColors = TRP3_API.ui.tooltip.getTooltipTextColors();

			tooltip.unitType = unitType;
			tooltip.targetID = npcID;
			if hideOriginal() then
				tooltip:SetOwner(UIParent, "ANCHOR_NONE");
				tooltip:SetPoint(GameTooltip:GetPoint(1));
			else
				-- Retrieving tooltip anchor settings
				local anchoredFrameName = getConfigValue("tooltip_char_AnchoredFrame");
				local anchoredFrame = GameTooltip;
				if anchoredFrameName and _G[anchoredFrameName] then
					anchoredFrame = _G[anchoredFrameName];
				end
				local anchoredPosition = getConfigValue("tooltip_char_Anchor");

				tooltip:SetOwner(anchoredFrame, anchoredPosition);
			end

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

			npcTooltipBuilder:AddLine(leftIcons .. (npcData.NA or originalName), TRP3_API.Colors.WHITE, TRP3_API.ui.tooltip.getMainLineFontSize());

			npcTooltipBuilder:AddLine("< " .. loc.QE_NPC .. " >", tooltipColors.TITLE, TRP3_API.ui.tooltip.getSubLineFontSize());

			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			-- Description
			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

			if (npcData.DE or ""):len() > 0 then
				local text = strtrim(TRP3_API.script.parseArgs(npcData.DE, TRP3_API.quest.getCampaignVarStorage()));
				if text:len() > getCurrentMaxSize() then
					text = text:sub(1, getCurrentMaxSize()) .. "…";
				end
				npcTooltipBuilder:AddSpace();
				npcTooltipBuilder:AddLine("\"" .. text .. "\"", tooltipColors.SECONDARY, TRP3_API.ui.tooltip.getSmallLineFontSize(), true);
			end

			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			-- Original text
			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

			if hideOriginal() and embedOriginal() then
				npcTooltipBuilder:AddSpace();
				for _, text in pairs(originalTexts) do
					npcTooltipBuilder:AddLine(text, tooltipColors.MAIN, TRP3_API.ui.tooltip.getSmallLineFontSize());
				end
			end

			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			-- Build
			--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

			npcTooltipBuilder:Build();

			if hideOriginal() then
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
				if getConfigValue("tooltip_no_fade_out") then
					self:Hide();
				else
					self:FadeOut();
				end
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

	GameTooltip:HookScript("OnShow", function()
		if not GameTooltip:GetUnit() then
			tooltip:Hide();
		end
	end);

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
