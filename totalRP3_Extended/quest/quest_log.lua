----------------------------------------------------------------------------------
-- Total RP 3: Quest log
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

local Ellyb = TRP3_API.Ellyb;

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local _G, assert, tostring, tinsert, wipe, pairs = _G, assert, tostring, tinsert, wipe, pairs;
local CreateFrame = CreateFrame;
local loc = TRP3_API.loc;
local EMPTY = TRP3_API.globals.empty;
local Log = Utils.log;
local getClass, getClassDataSafe, getClassesByType = TRP3_API.extended.getClass, TRP3_API.extended.getClassDataSafe, TRP3_API.extended.getClassesByType;
local getQuestLog = TRP3_API.quest.getQuestLog;
local IsShiftKeyDown = IsShiftKeyDown;

local TRP3_QuestLogPage = TRP3_QuestLogPage;

-- Total RP 3 modules

local goToPage, refreshCampaignList;
local TAB_CAMPAIGNS = "campaigns";
local TAB_QUESTS = "quests";
local TAB_STEPS = "steps";
TRP3_QuestLogPage.TAB_QUESTS = TAB_QUESTS;
TRP3_QuestLogPage.TAB_STEPS = TAB_STEPS;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CAMPAIGN
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onCampaignActionSelected(value, button)
	assert(button.campaignID, "No campaign ID in button");
	if value == 1 then
		TRP3_API.popup.showConfirmPopup(loc.QE_RESET_CONFIRM, function()
			TRP3_API.quest.resetCampaign(button.campaignID);
		end);
	elseif value == 2 then
		TRP3_API.quest.activateCampaign(button.campaignID);
		refreshCampaignList();
	end
end

local function onCampaignButtonClick(button, mouseButton)
	assert(button.campaignID, "No campaign ID in button");
	local campaignID = button.campaignID;
	local _, campaignName = getClassDataSafe(getClass(campaignID));
	if ChatEdit_GetActiveWindow() and IsModifiedClick("CHATLINK") then
		TRP3_API.ChatLinks:OpenMakeImportablePrompt(loc.CL_EXTENDED_CAMPAIGN, function(canBeImported)
			TRP3_API.extended.CampaignsChatLinksModule:InsertLink(campaignID, canBeImported);
		end);
	else
		if mouseButton == "LeftButton" then
			goToPage(false, TAB_QUESTS, campaignID, campaignName);
		else
			local values = {};
			tinsert(values, {campaignName});
			tinsert(values, {loc.QE_CAMPAIGN_RESET, 1});
			tinsert(values, {loc.QE_CAMPAIGN_START_BUTTON, 2});
			TRP3_API.ui.listbox.displayDropDown(button, values, onCampaignActionSelected, 0, true);
		end
	end
end

local BASE_BKG = "Interface\\QuestionFrame\\question-background";
local DEFAULT_CAMPAIGN_IMAGE = "GarrZoneAbility-Stables";


local function getCampaignProgression(campaignID)
	local campaignClass = getClass(campaignID);
	local progression = 0;
	local progressionQuestIds = {};
	local completed, total = 0, 0;
	local campaignLog = (getQuestLog()[campaignID] or EMPTY).QUEST or EMPTY;
	for questID, quest in pairs(campaignClass.QE or EMPTY) do
		if quest.BA.PR then
			total = total + 1;
			if campaignLog[questID] and campaignLog[questID].FI then
				completed = completed + 1;
			end
		end
	end
	if total ~= 0 then
		return math.floor( (completed / total) * 100);
	else
		return 0;
	end
end
TRP3_API.quest.getCampaignProgression = getCampaignProgression;

local function decorateCampaignButton(campaignButton, campaignID, noTooltip)
	local campaignClass = getClass(campaignID);
	local campaignIcon, campaignName, campaignDescription = getClassDataSafe(campaignClass);
	local author = campaignClass.MD.CB;
	local logEntry = getQuestLog()[campaignID];
	local progression = getCampaignProgression(campaignID);
	local progress = "%s: %s%%";
	local current = getQuestLog().currentCampaign == campaignID;
	campaignButton:Show();
	campaignButton.name:SetText(campaignName);

	campaignButton.Completed:Hide();
	local color = "";
	if current then
		color = "|cff00ff00";
	end
	if not logEntry then
		campaignButton.range:SetText(color .. loc.QE_CAMPAIGN_NO);
	elseif progression == 100 then
		campaignButton.range:SetText(color .. loc.QE_CAMPAIGN_FULL);
		campaignButton.Completed:Show();
	else
		campaignButton.range:SetText(color .. progress:format(loc.QE_PROGRESS, progression));
	end

	TRP3_API.ui.frame.setupIconButton(campaignButton, campaignIcon);

	if current then
		campaignButton.switchButton:SetNormalTexture("Interface\\TIMEMANAGER\\PauseButton");
		TRP3_API.ui.tooltip.setTooltipAll(campaignButton.switchButton, "TOP", 0, 0, loc.QE_CAMPAIGN_PAUSE);
	else
		campaignButton.switchButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
		TRP3_API.ui.tooltip.setTooltipAll(campaignButton.switchButton, "TOP", 0, 0, loc.QE_CAMPAIGN_START_BUTTON);
	end

	if not noTooltip then
		local createdBy = "|cff00ff00%s: %s|r\n\n";
		TRP3_API.ui.tooltip.setTooltipForSameFrame(campaignButton, "TOPRIGHT", 0, 5, campaignName,
			createdBy:format(loc.DB_FILTERS_OWNER, author)
			.. progress:format(loc.QE_PROGRESS, progression)
			.. ("|r\n")
			.. "\n" .. Ellyb.Strings.clickInstruction(Ellyb.System.CLICKS.LEFT_CLICK, loc.CM_OPEN)
			.. "\n" .. Ellyb.Strings.clickInstruction(Ellyb.System.CLICKS.RIGHT_CLICK, loc.CM_ACTIONS)
			.. "\n" .. Ellyb.Strings.clickInstruction(Ellyb.System:FormatKeyboardShortcut(Ellyb.System.MODIFIERS.SHIFT, Ellyb.System.CLICKS.RIGHT_CLICK), loc.CL_TOOLTIP)
		);
	else
		TRP3_API.ui.tooltip.setTooltipForSameFrame(campaignButton);
	end

	campaignButton.campaignID = campaignID;
end

function refreshCampaignList()
	local campaigns = getClassesByType(TRP3_DB.types.CAMPAIGN) or EMPTY;
	TRP3_API.ui.list.initList(TRP3_QuestLogPage.Campaign, campaigns, TRP3_QuestLogPage.Campaign.slider);
end

local function goToCampaignPage(skipButton)
	if not skipButton then
		NavBar_Reset(TRP3_QuestLogPage.navBar);
	end
	refreshCampaignList();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- QUEST
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local onQuestTabClick;

local function onQuestButtonEnter(button)
	local questClass = getClass(button.campaignID, button.questID) or EMPTY;
	local questIcon, questName = getClassDataSafe(questClass);
	local currentStep = button.questInfo.CS;
	local objectives = button.questInfo.OB;
	local stepText, objectivesText;

	if currentStep then
		if questClass.ST and questClass.ST[currentStep] then
			stepText = questClass.ST[currentStep].BA.TX or "";
		else
			stepText = "|cffff0000" .. loc.QE_STEP_MISSING .. "|r";
		end
		stepText = loc.QE_QUEST_TT_STEP:format(stepText);
	end

	if objectives then
		for objectiveID, state in pairs(objectives) do
			local objectiveClass = questClass.OB[objectiveID];
			if objectiveClass and state == false then
				local obectiveText = objectiveClass.TX or "";
				if not objectivesText then
					objectivesText = "|cff00ff00- " .. obectiveText;
				else
					objectivesText = objectivesText .. "\n- " .. obectiveText;
				end
			end
		end
	end

	local finalText;
	if stepText and not objectivesText then finalText = stepText; end
	if objectivesText and not stepText then finalText = objectivesText; end
	if objectivesText and stepText then finalText = stepText .. "\n\n" .. objectivesText; end
	if finalText then
		finalText = TRP3_API.script.parseArgs(finalText, TRP3_API.quest.getCampaignVarStorage());
	end

	setTooltipForSameFrame(button, "RIGHT", 0, 5, questName, finalText);
	TRP3_RefreshTooltipForFrame(button);
end

local function decorateQuestButton(questFrame, campaignID, questID, questInfo, questClick)
	local questClass = getClass(campaignID, questID);
	local questIcon, questName, questDescription = getClassDataSafe(questClass);
	questDescription = TRP3_API.script.parseArgs(questDescription or "", TRP3_API.quest.getCampaignVarStorage());

	TRP3_API.ui.frame.setupIconButton(questFrame, questIcon);
	questFrame.Name:SetText(questName);
	questFrame.Name:SetTextColor(0.2824, 0.0157, 0.0157);
	questFrame.InfoText:SetText(questDescription);
	questFrame.InfoText:SetTextColor(0.3824, 0.1157, 0.1157);
	questFrame.Completed:Hide();
	if questInfo.FI == true then
		questFrame.Completed:Show();
		questFrame.Name:SetText(questName .. " " .. Ellyb.ColorManager.GREEN("(" .. loc.QE_COMPLETED .. ")"));
	elseif questInfo.FI == false then
		questFrame.Completed:Show();
		questFrame.Name:SetText(questName .. " " .. Ellyb.ColorManager.RED("(" .. loc.QE_FAILED .. ")"));
	end
	questFrame:SetScript("OnClick", questClick);
	questFrame:SetScript("OnEnter", onQuestButtonEnter);
	questFrame.campaignID = campaignID;
	questFrame.questID = questID;
	questFrame.questInfo = questInfo;
end

local function refreshQuestList(campaignID)
	TRP3_QuestLogPage.Quest.scroll.child.Content.Current:Hide();
	TRP3_QuestLogPage.Quest.Empty:Show();
	local questFrames = TRP3_QuestLogPage.Quest.scroll.child.Content.frames;

	for _, questFrame in pairs(questFrames) do
		questFrame:Hide();
		questFrame:ClearAllPoints();
	end

	local campaignLog = getQuestLog()[campaignID];
	local y = -50;
	if campaignLog then

		local questIDs = {};
		for questID, _ in pairs(campaignLog.QUEST) do
			tinsert(questIDs, questID);
		end
		table.sort(questIDs);

		local index = 1;
		for _, questID in pairs(questIDs) do
			local questInfo = campaignLog.QUEST[questID];
			local questFrame = questFrames[index];
			if not questFrame then
				questFrame = CreateFrame("Button", TRP3_QuestLogPage.Quest:GetName() .. "Slot" .. index,
					TRP3_QuestLogPage.Quest.scroll.child.Content, "TRP3_QuestButtonTemplate");
				tinsert(questFrames, questFrame);
			end

			local _, questName, _ = getClassDataSafe(getClass(campaignID, questID));
			decorateQuestButton(questFrame, campaignID, questID, questInfo, function()
				goToPage(false, TAB_STEPS, campaignID, questID, questName);
			end);
			questFrame:SetPoint("TOPLEFT", 40, y);
			questFrame:Show();

			index = index + 1;
			y = y - 60;
		end

		if index > 1 then
			TRP3_QuestLogPage.Quest.Empty:Hide();
			TRP3_QuestLogPage.Quest.scroll.child.Content.Current:Show();
		elseif Utils.table.size(getClass(campaignID).QE) == 0 then
			TRP3_QuestLogPage.Quest.Empty:SetText(loc.QE_CAMPAIGN_EMPTY);
		else
			TRP3_QuestLogPage.Quest.Empty:SetText(loc.QE_CAMPAIGN_NOQUEST);
		end
	else
		TRP3_QuestLogPage.Quest.Empty:SetText(loc.QE_CAMPAIGN_UNSTARTED);
	end
end

local function refreshQuestVignette(campaignID)
	local campaignClass = getClass(campaignID);
	decorateCampaignButton(TRP3_QuestLogPage.Quest, campaignID, true);
	local image = (campaignClass.BA or EMPTY).IM or DEFAULT_CAMPAIGN_IMAGE;
	TRP3_QuestLogPage.Quest.IconBorder:SetTexture("Interface\\ExtraButton\\" .. image);
	TRP3_QuestLogPage.Quest.bTile:SetTexture(BASE_BKG, true, true);
	local description = (campaignClass.BA or EMPTY).DE or "";
	description = TRP3_API.script.parseArgs(description, TRP3_API.quest.getCampaignVarStorage());
	TRP3_QuestLogPage.Quest.Desc:SetText(description);
end

local function swapCampaignActivation(button)
	onCampaignActionSelected(2, button);
	refreshQuestVignette(button.campaignID);
	refreshQuestList(button.campaignID);
end

local function goToQuestPage(skipButton, campaignID, campaignName)
	if not skipButton then
		NavBar_AddButton(TRP3_QuestLogPage.navBar, {id = campaignID, name = campaignName, OnClick = onQuestTabClick});
	end
	refreshQuestList(campaignID);
	refreshQuestVignette(campaignID);
end

function onQuestTabClick(button)
	goToPage(true, TAB_QUESTS, button.id, button.name);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- STEPS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local stepHTML = TRP3_QuestLogPage.Step.scroll.child.HTML;

local function refreshStepVignette(campaignID, questID, questInfo)
	decorateQuestButton(TRP3_QuestLogPage.Step.Title, campaignID, questID, questInfo);
end

local function refreshStepContent(campaignID, questID, questInfo)
	local questClass = getClass(campaignID, questID);
	local currentStep = questInfo.CS;
	local objectives = questInfo.OB;
	local html = "";

	if currentStep then
		local currentStepText;
		if questClass.ST and questClass.ST[currentStep] then
			currentStepText = questClass.ST[currentStep].BA.TX or "";
		else
			currentStepText = "|cffff0000" .. loc.QE_STEP_MISSING .. "|r";
		end
		html = html .. ("{h2}%s{/h2}"):format(loc.QE_OVERVIEW);
		html = html .. ("\n%s\n\n"):format(currentStepText);
	end

	if objectives and Utils.table.size(objectives) > 0 then
		local objectivesText = "";
		local sortedID = {};
		for objectiveID, _ in pairs(objectives) do
			tinsert(sortedID, objectiveID);
		end
		table.sort(sortedID);

		for _, objectiveID in pairs(sortedID) do
			local state = objectives[objectiveID];
			local objectiveClass = questClass.OB[objectiveID];
			local objText = UNKNOWN;
			if objectiveClass then
				local obectiveText = objectiveClass.TX or "";
				if state == true then
					objText = "|TInterface\\Scenarios\\ScenarioIcon-Check:12:12|t " .. obectiveText;
				else
					objText = "|TInterface\\GossipFrame\\IncompleteQuestIcon:12:12|t " .. obectiveText;
				end
			end
			objectivesText = objectivesText .. "{p}" .. objText .. "{/p}";
		end
		html = html .. ("{h2}%s{/h2}"):format(QUEST_OBJECTIVES);
		html = html .. ("\n%s"):format(objectivesText);
	end

	if Utils.table.size(questInfo.PS or EMPTY) > 0 then
		html = html .. ("\n{img:%s:256:32}\n"):format("Interface\\QUESTFRAME\\UI-HorizontalBreak");

		local previousStepText = "";
		local index = 1;
		for _, stepID in pairs(questInfo.PS) do
			local stepClass = getClass(campaignID, questID, stepID);
			if stepClass and stepClass.BA.DX then
				previousStepText = previousStepText .. index .. ") " .. stepClass.BA.DX .. "\n\n";
				index = index + 1;
			end
		end

		html = html .. ("{h2}%s{/h2}"):format(loc.QE_PREVIOUS_STEP);
		html = html .. ("\n%s\n"):format(previousStepText);
	end

	stepHTML.html = Utils.str.toHTML(TRP3_API.script.parseArgs(html, TRP3_API.quest.getCampaignVarStorage()));
	stepHTML:SetText(stepHTML.html);
end

local function goToStepPage(skipButton, campaignID, questID, questName)
	if not skipButton then
		NavBar_AddButton(TRP3_QuestLogPage.navBar, {id = questID, name = questName});
	end

	local campaignLog = getQuestLog()[campaignID];
	assert(campaignLog and campaignLog.QUEST[questID], "Trying to goToStepPage from an unstarted campaign or quest: " .. tostring(questID));

	refreshStepVignette(campaignID, questID, campaignLog.QUEST[questID]);
	refreshStepContent(campaignID, questID, campaignLog.QUEST[questID]);
end

local function initStepFrame()
	TRP3_QuestLogPage.Step.Title.Name:SetTextColor(0.1, 0.1, 0.1);
	TRP3_QuestLogPage.Step.Title.InfoText:SetTextColor(0.1, 0.1, 0.1);
	TRP3_API.events.listenToEvent(TRP3_API.events.NAVIGATION_RESIZED, function(containerwidth, containerHeight)
		stepHTML:SetSize(containerwidth - 130, 5);
		stepHTML:SetText(stepHTML.html);
	end);

	stepHTML:SetFontObject("p", GameTooltipHeader);
	stepHTML:SetTextColor("p", 0.2824, 0.0157, 0.0157);
	stepHTML:SetShadowOffset("p", 0, 0)

	stepHTML:SetFontObject("h1", DestinyFontHuge);
	stepHTML:SetTextColor("h1", 0, 0, 0);

	stepHTML:SetFontObject("h2", QuestFont_Huge);
	stepHTML:SetTextColor("h2", 0, 0, 0);

	stepHTML:SetFontObject("h3", GameFontNormalLarge);
	stepHTML:SetTextColor("h3", 1, 1, 1);

end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- NAVIGATION
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function goToPage(skipButton, page,  ...)
	TRP3_QuestLogPage.currentPage = page;
	TRP3_QuestLogPage.args = {...};
	TRP3_QuestLogPage.Campaign:Hide();
	TRP3_QuestLogPage.Quest:Hide();
	TRP3_QuestLogPage.Step:Hide();

	if page == TAB_CAMPAIGNS then
		TRP3_QuestLogPage.Campaign:Show();
		goToCampaignPage(skipButton, ...)
	elseif page == TAB_QUESTS then
		TRP3_QuestLogPage.Quest:Show();
		goToQuestPage(skipButton, ...)
	elseif page == TAB_STEPS then
		TRP3_QuestLogPage.Step:Show();
		goToStepPage(skipButton, ...)
	end
end
TRP3_QuestLogPage.goToPage = goToPage;

local getCurrentPageID = TRP3_API.navigation.page.getCurrentPageID;
local function refreshLog()
	if getCurrentPageID() == "player_quest" then
		goToPage(true, TRP3_QuestLogPage.currentPage, unpack(TRP3_QuestLogPage.args));
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- Tutorial
local TUTORIAL_STRUCTURE_CAMPAIGN, TUTORIAL_STRUCTURE_QUEST, TUTORIAL_STRUCTURE_STEP;

local function createTutorialStructure()
	local action = {
		box = {
			x = -15, y = -15, anchor = "TOPRIGHT", width = 30, height = 30
		},
		button = {
			x = 0, y = 0, anchor = "CENTER",
			text = loc.QUEST_TU_1,
			textWidth = 400,
			arrow = "LEFT"
		}
	};

	TUTORIAL_STRUCTURE_CAMPAIGN = {
		action,
		{
			box = {
				allPoints = TRP3_QuestLogPage.Campaign
			},
			button = {
				x = 0, y = 0, anchor = "CENTER",
				text = loc.QUEST_TU_2,
				textWidth = 400,
				arrow = "RIGHT"
			}
		},
	};
	TUTORIAL_STRUCTURE_QUEST = {
		action,
		{
			box = {
				allPoints = TRP3_QuestLogPage.Quest.scroll
			},
			button = {
				x = 0, y = 0, anchor = "CENTER",
				text = loc.QUEST_TU_3,
				textWidth = 400,
				arrow = "DOWN"
			}
		},
	};
	TUTORIAL_STRUCTURE_STEP = {
		action,
		{
			box = {
				allPoints = TRP3_QuestLogPage.Step.scroll
			},
			button = {
				x = 0, y = 0, anchor = "CENTER",
				text = loc.QUEST_TU_4,
				textWidth = 400,
				arrow = "RIGHT"
			}
		},
	};
end

local function init()

	Events.listenToEvent(Events.CAMPAIGN_REFRESH_LOG, refreshLog);

	-- Quest log page and menu
	TRP3_API.navigation.menu.registerMenu({
		id = "main_14_player_quest",
		text = QUEST_LOG,
		onSelected = function()
			TRP3_API.navigation.page.setPage("player_quest");
		end,
		isChildOf = "main_10_player",
	});

	TRP3_API.navigation.page.registerPage({
		id = "player_quest",
		frame = TRP3_QuestLogPage,
		onPagePostShow = function()
			goToPage(false, TAB_CAMPAIGNS);
		end,
		tutorialProvider = function()
			if TRP3_QuestLogPage.currentPage == TAB_CAMPAIGNS then
				return TUTORIAL_STRUCTURE_CAMPAIGN;
			end
			if TRP3_QuestLogPage.currentPage == TAB_QUESTS then
				return TUTORIAL_STRUCTURE_QUEST;
			end
			if TRP3_QuestLogPage.currentPage == TAB_STEPS then
				return TUTORIAL_STRUCTURE_STEP;
			end
		end,
	});

	-- Quest log button on target bar
	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		if TRP3_API.toolbar then
			local toolbarButton = {
				id = "hh_player_e_quest",
				icon = "achievement_quests_completed_06",
				configText = QUEST_LOG,
				tooltip = QUEST_LOG,
				tooltipSub = ("|cffffff00%s: |cff00ff00%s\n"):format(loc.CM_CLICK, loc.QE_BUTTON) .. ("|cffffff00%s: |cff00ff00%s"):format(loc.CM_R_CLICK, loc.CM_ACTIONS),
				onClick = function(self, _, buttonType, _)
					if buttonType == "LeftButton" then
						TRP3_API.navigation.openMainFrame();
						TRP3_API.navigation.menu.selectMenu("main_14_player_quest");
					else
						local values = {};
						tinsert(values, {loc.DI_HISTORY});
						tinsert(values, {loc.CM_OPEN, 0});
						tinsert(values, {loc.CM_ACTIONS});
						tinsert(values, {TRP3_API.formats.dropDownElements:format(loc.QE_ACTION, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.LOOK)), TRP3_API.quest.ACTION_TYPES.LOOK});
						tinsert(values, {TRP3_API.formats.dropDownElements:format(loc.QE_ACTION, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.LISTEN)), TRP3_API.quest.ACTION_TYPES.LISTEN});
						tinsert(values, {TRP3_API.formats.dropDownElements:format(loc.QE_ACTION, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.ACTION)), TRP3_API.quest.ACTION_TYPES.ACTION});
						tinsert(values, {TRP3_API.formats.dropDownElements:format(loc.QE_ACTION, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.TALK)), TRP3_API.quest.ACTION_TYPES.TALK});
						TRP3_API.ui.listbox.displayDropDown(self, values, function(action)
							if action == 0 then
								TRP3_DialogFrameHistory:Show();
							else
								TRP3_API.quest.performAction(action);
							end
						end, 0, true);
					end
				end,
				visible = 1
			};
			TRP3_API.toolbar.toolbarAddButton(toolbarButton);
		end
	end);

	-- Tab bar init
	local homeData = {
		name = loc.QE_CAMPAIGNS,
		OnClick = function()
			goToPage(false, TAB_CAMPAIGNS);
		end,
	}
	TRP3_QuestLogPage.navBar.home:SetWidth(110);
	NavBar_Initialize(TRP3_QuestLogPage.navBar, "NavButtonTemplate", homeData, TRP3_QuestLogPage.navBar.home, TRP3_QuestLogPage.navBar.overflow);

	-- Campaign page init
	TRP3_QuestLogPage.Campaign.widgetTab = {};
	for i=1, 5 do
		local line = TRP3_QuestLogPage.Campaign["Slot" .. i];
		line.switchButton:SetScript("OnClick", function(self) onCampaignActionSelected(2, self:GetParent()) end);
		line:SetScript("OnClick", onCampaignButtonClick);
		line:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		tinsert(TRP3_QuestLogPage.Campaign.widgetTab, line);
	end
	TRP3_QuestLogPage.Campaign.decorate = decorateCampaignButton;
	TRP3_API.ui.list.handleMouseWheel(TRP3_QuestLogPage.Campaign, TRP3_QuestLogPage.Campaign.slider);
	TRP3_QuestLogPage.Campaign.slider:SetValue(0);

	-- Quest page init
	TRP3_QuestLogPage.Quest.scroll.child.Content.Current:SetText(loc.QE_STEP_LIST_CURRENT);
	TRP3_QuestLogPage.Quest.scroll.child.Content.frames = {};
	TRP3_API.ui.tooltip.setTooltipAll(TRP3_QuestLogPage.Quest.PassButton, "TOP", 0, 0, loc.QE_CAMPAIGN_RESET);
	TRP3_QuestLogPage.Quest.PassButton:SetScript("OnClick", function(self)
		TRP3_API.popup.showConfirmPopup(loc.QE_RESET_CONFIRM, function()
			TRP3_API.quest.resetCampaign(self:GetParent().campaignID);
		end);
	end);
	TRP3_QuestLogPage.Quest.switchButton:SetScript("OnClick", function(self) swapCampaignActivation(self:GetParent()) end);

	-- Step page init
	initStepFrame();

	-- Quest toast
	TRP3_QuestToast:SetScript("OnClick", function(self)
		TRP3_API.navigation.openMainFrame();
		TRP3_API.navigation.menu.selectMenu("main_14_player_quest");
		goToPage(false, TAB_QUESTS, self.campaignID, self.campaignName);
		goToPage(false, TAB_STEPS, self.campaignID, self.questID, self.questName);
	end);

	-- Navbar action
	TRP3_API.ui.tooltip.setTooltipAll(TRP3_QuestLogPage.navBar.action, "TOP", 0, 0, loc.CM_ACTIONS);
	TRP3_QuestLogPage.navBar.action:SetScript("OnClick", function(button)
		local values = {};
		tinsert(values, {loc.CM_ACTIONS});
		tinsert(values, {TRP3_API.formats.dropDownElements:format(loc.QE_MACRO, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.LOOK)),
			TRP3_API.quest.ACTION_TYPES.LOOK, loc.QE_MACRO_TT});
		tinsert(values, {TRP3_API.formats.dropDownElements:format(loc.QE_MACRO, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.LISTEN)),
			TRP3_API.quest.ACTION_TYPES.LISTEN, loc.QE_MACRO_TT});
		tinsert(values, {TRP3_API.formats.dropDownElements:format(loc.QE_MACRO, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.ACTION)),
			TRP3_API.quest.ACTION_TYPES.ACTION, loc.QE_MACRO_TT});
		tinsert(values, {TRP3_API.formats.dropDownElements:format(loc.QE_MACRO, TRP3_API.quest.getActionTypeLocale(TRP3_API.quest.ACTION_TYPES.TALK)),
			TRP3_API.quest.ACTION_TYPES.TALK, loc.QE_MACRO_TT});

		TRP3_API.ui.listbox.displayDropDown(button, values, function(action)
			if GetNumMacros() <= 120 then
				if action == TRP3_API.quest.ACTION_TYPES.LISTEN then
					if GetMacroIndexByName("TRP3_Listen") == 0 then
						CreateMacro("TRP3_Listen", TRP3_API.quest.getActionTypeIcon(TRP3_API.quest.ACTION_TYPES.LISTEN), "/script TRP3_API.quest.listen();", 1);
					end
					PickupMacro("TRP3_Listen");
				elseif action == TRP3_API.quest.ACTION_TYPES.LOOK then
					if GetMacroIndexByName("TRP3_Look") == 0 then
						CreateMacro("TRP3_Look", TRP3_API.quest.getActionTypeIcon(TRP3_API.quest.ACTION_TYPES.LOOK), "/script TRP3_API.quest.inspect();", 1);
					end
					PickupMacro("TRP3_Look");
				elseif action == TRP3_API.quest.ACTION_TYPES.ACTION then
					if GetMacroIndexByName("TRP3_Interract") == 0 then
						CreateMacro("TRP3_Interract", TRP3_API.quest.getActionTypeIcon(TRP3_API.quest.ACTION_TYPES.ACTION), "/script TRP3_API.quest.interract();", 1);
					end
					PickupMacro("TRP3_Interract");
				elseif action == TRP3_API.quest.ACTION_TYPES.TALK then
					if GetMacroIndexByName("TRP3_Talk") == 0 then
						CreateMacro("TRP3_Talk", TRP3_API.quest.getActionTypeIcon(TRP3_API.quest.ACTION_TYPES.TALK), "/script TRP3_API.quest.talk();", 1);
					end
					PickupMacro("TRP3_Talk");
				end
			else
				Utils.message.displayMessage(loc.QE_MACRO_MAX, 4);
			end
		end, 0, true);
	end);

	-- Bindings

	BINDING_NAME_TRP3_QUESTLOG = loc.BINDING_NAME_TRP3_QUESTLOG;
	BINDING_NAME_TRP3_QUEST_LOOK = loc.BINDING_NAME_TRP3_QUEST_LOOK;
	BINDING_NAME_TRP3_QUEST_LISTEN = loc.BINDING_NAME_TRP3_QUEST_LISTEN;
	BINDING_NAME_TRP3_QUEST_ACTION = loc.BINDING_NAME_TRP3_QUEST_ACTION;
	BINDING_NAME_TRP3_QUEST_TALK = loc.BINDING_NAME_TRP3_QUEST_TALK;

	-- Events
	Events.listenToEvent(TRP3_API.quest.EVENT_REFRESH_CAMPAIGN, function(rootClassID)
		if getCurrentPageID() == "player_quest" then
			goToPage(false, TAB_CAMPAIGNS);
		end
	end);

	-- Tuto
	createTutorialStructure();
end
TRP3_API.quest.questLogInit = init;