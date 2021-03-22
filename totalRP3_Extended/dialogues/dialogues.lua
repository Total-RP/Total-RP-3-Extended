----------------------------------------------------------------------------------
-- Total RP 3: Dialogues system
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
local _G, wipe, tostring, tinsert, strsplit, pairs, type, tonumber = _G, wipe, tostring, tinsert, strsplit, pairs, type, tonumber;
local loc = TRP3_API.loc;
local EMPTY = TRP3_API.globals.empty;
local Log = Utils.log;
local getClass = TRP3_API.extended.getClass;
local UnitExists = UnitExists;
local setTooltipAll = TRP3_API.ui.tooltip.setTooltipAll;

local dialogFrame = TRP3_DialogFrame;
local CHAT_MARGIN = 70;

local LINE_FEED_CODE = string.char(10);
local CARRIAGE_RETURN_CODE = string.char(13);
local WEIRD_LINE_BREAK = LINE_FEED_CODE .. CARRIAGE_RETURN_CODE .. LINE_FEED_CODE;

local scalingLib = LibStub:GetLibrary("TRP-Dialog-Scaling-DB");
local animationLib = LibStub:GetLibrary("TRP-Dialog-Animation-DB");

local historyFrame = TRP3_DialogFrameHistory;
local UnitPosition = TRP3_API.extended.getUnitPositionSafe;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Models and animations
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local modelLeft, modelRight, image = dialogFrame.Models.Me, dialogFrame.Models.You, dialogFrame.Image;

local function loadScalingParameters(data, model, facing)
	scalingLib:SetModelHeight(data.scale, model);
	scalingLib:SetModelFeet(data.feet, model);
	scalingLib:SetModelOffset(data.offset, model, facing);
	scalingLib:SetModelFacing(data.facing, model, facing);
end

local function playTextAnim(context)
	if not dialogFrame.textLineToken or not dialogFrame.ND or dialogFrame.ND == "NONE" then
		return;
	end
--	Log.log("AnimWithToken: " .. context);

	-- Animations
	local targetModel = dialogFrame.ND == "LEFT" and modelLeft or modelRight;
	local animTab = targetModel.animTab;
	local delay = 0;
	for _, sequence in pairs(animTab) do
		delay = animationLib:PlayAnimationDelay(targetModel, sequence, animationLib:GetAnimationDuration(targetModel.model, sequence), delay, dialogFrame.textLineToken);
	end
	dialogFrame.textLineToken = nil;
end

local function modelsLoaded()
	if modelRight.modelLoaded and modelLeft.modelLoaded then

		dialogFrame.loaded = true;

		modelLeft.model = modelLeft:GetModelFileID();
		if modelLeft.model then
			modelLeft.model = tostring(modelLeft.model);
		end

		modelRight.model = modelRight:GetModelFileID();
		if modelRight.model then
			modelRight.model = tostring(modelRight.model);
		end

		local dataLeft, dataRight = scalingLib:GetModelCoupleProperties(modelLeft.model, modelRight.model);

		-- Configuration for model left.
		if modelLeft.model then
			loadScalingParameters(dataLeft, modelLeft, true);
		end

		-- Configuration for model right
		if modelRight.model then
			loadScalingParameters(dataRight, modelRight, false);
		end

		playTextAnim("On model loaded");
	end
end

local function reinitModel(frame)
	frame.modelLoaded = false;
	frame.model = nil;
	frame.unit = nil;
end

local function loadModel(frame, unit)
	reinitModel(frame);
	frame.unit = unit;
	frame:SetUnit(unit, false);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- TEXT ANIMATION
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local ANIMATION_TEXT_SPEED = 160;
local sqrt = sqrt;

local function onUpdateChatText(self, elapsed)
	if self.start and dialogFrame.Chat.Text:GetText() and dialogFrame.Chat.Text:GetText():len() > 0 then
		local speedFactor = 0.5;
		self.start = self.start + (elapsed * (ANIMATION_TEXT_SPEED * speedFactor));
		if speedFactor == 0 or self.start >= dialogFrame.Chat.Text:GetText():len() then
			self.start = nil;
			dialogFrame.Chat.Text:SetAlphaGradient(dialogFrame.Chat.Text:GetText():len(), 1);
		else
			dialogFrame.Chat.Text:SetAlphaGradient(self.start, 30);
		end
	end
	if dialogFrame.distanceLimit > 0 then
		local posY, posX = UnitPosition("player");
		local distance = sqrt((posY - dialogFrame.posY) ^ 2 + (posX - dialogFrame.posX) ^ 2);
		if distance >= dialogFrame.distanceLimit then
			dialogFrame:Hide();
		end
	end
end


--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local UnitName = UnitName;
local processDialogStep;
local DEFAULT_BG = "Interface\\DRESSUPFRAME\\DressUpBackground-NightElf1";
local after = C_Timer.After;

local function finishDialog()
	dialogFrame:Hide();
	if dialogFrame.classID and dialogFrame.class.LI and dialogFrame.class.LI.OE and dialogFrame.class.SC then
		local retCode = TRP3_API.script.executeClassScript(dialogFrame.class.LI.OE, dialogFrame.class.SC, {}, dialogFrame.classID);
	end
end

local function setupChoices(choices)
	local index = 1;
	for _, choiceData in pairs(choices) do
		local choiceButton = dialogFrame.choices[index];
		if TRP3_API.script.generateAndRunCondition(choiceData.C, dialogFrame.args) then
			local text = TRP3_API.script.parseArgs(choiceData.TX or "", dialogFrame.args);
			choiceButton.Text:SetText(text);
			choiceButton.Click:SetScript("OnClick", function()
				if choiceData.N and choiceData.N ~= 0 and (dialogFrame.class.DS or EMPTY)[choiceData.N] then
					dialogFrame.stepIndex = choiceData.N;
					processDialogStep();
				else
					finishDialog();
				end
			end);
			choiceButton:Show();
			index = index + 1;
		end
	end
end

local resizeChat = function()
	dialogFrame.Chat.Text:SetWidth(dialogFrame:GetWidth() - 150);
	dialogFrame.Chat:SetHeight(dialogFrame.Chat.Text:GetHeight() + CHAT_MARGIN + 5);
end

-- Called to play one text
local function playDialogStep()
	local dialogClass = dialogFrame.class;
	local dialogStepClass = dialogFrame.dialogStepClass;
	local text = dialogFrame.texts[dialogFrame.stepDialogIndex];
	text = TRP3_API.script.parseArgs(text or "", dialogFrame.args);
	wipe(modelLeft.animTab);
	wipe(modelRight.animTab);
	modelLeft.token = nil;
	modelRight.token = nil;

	-- Choices
	for _, choiceButton in pairs(dialogFrame.choices) do
		choiceButton:Hide();
	end

	-- Animations
	local targetModel = dialogFrame.ND == "LEFT" and modelLeft or modelRight;
	local animTab = targetModel.animTab;

	-- Text color (emote)
	if text:byte() == 60 or text:byte() == 42 then
		local color = Utils.color.colorCodeFloat(ChatTypeInfo["MONSTER_EMOTE"].r, ChatTypeInfo["MONSTER_EMOTE"].g, ChatTypeInfo["MONSTER_EMOTE"].b);
		text = text:gsub("<", color):gsub(">", "|r");
		text = text:gsub("^%*", color):gsub("%*$", "|r");
	else
		text:gsub("[%.%?%!]+", function(finder)
			animTab[#animTab + 1] = animationLib:GetDialogAnimation(targetModel.model, finder:sub(1, 1));
			animTab[#animTab + 1] = 0;
		end);
	end

	-- Animation
	if #animTab == 0 then
		animTab[1] = 0;
	end
	dialogFrame.textLineToken = Utils.str.id();
	if dialogFrame.loaded then
		playTextAnim("On step");
	end

	-- Play text
	dialogFrame.Chat.Text:SetText(text);
	dialogFrame.Chat.start = 0; -- Automatically starts the fade-in animation for text

	dialogFrame.Chat.Next:SetText("");
	dialogFrame.Chat.NextButton:Enable();
	if not dialogFrame.isPreview and dialogFrame.LO then
		dialogFrame.Chat.NextButton:Disable();
		dialogFrame.Chat.Next:SetText(loc.DI_WAIT_LOOT);
	end

	-- What to do next
	if dialogFrame.texts[dialogFrame.stepDialogIndex + 1] then
		-- If there is a text next in the same step
		dialogFrame.Chat.NextButton:SetScript("OnClick", function()
			dialogFrame.stepDialogIndex = dialogFrame.stepDialogIndex + 1;
			playDialogStep();
		end);
	else
		-- If there is a choice to make
		if dialogStepClass.CH then
			setupChoices(dialogStepClass.CH);
			dialogFrame.Chat.Next:SetText(loc.DI_CHOICE_TEXT);
			dialogFrame.Chat.NextButton:Disable();
		else
			if dialogStepClass.EP then
				-- End point
				dialogFrame.Chat.NextButton:SetScript("OnClick", finishDialog);
			else
				dialogFrame.stepIndex = dialogStepClass.N or (dialogFrame.stepIndex + 1);

				-- Else go to the next step if exists
				if (dialogClass.DS or EMPTY)[dialogFrame.stepIndex] then
					dialogFrame.Chat.NextButton:SetScript("OnClick", function()
						processDialogStep();
					end);
				else
					-- Or finish the cutscene
					dialogFrame.Chat.NextButton:SetScript("OnClick", finishDialog);
				end
			end
		end
	end

	-- History
	if dialogFrame.ND ~= "NONE" then
		if dialogFrame.NA == "${trp:player:full}" then
			historyFrame.container:AddMessage(("|cff00ff00[%s]|r %s"):format(dialogFrame.NA_PARSED or UNKNOWN, text));
		else
			historyFrame.container:AddMessage(("|cffff9900[%s]|r %s"):format(dialogFrame.NA_PARSED or UNKNOWN, text));
		end
	else
		historyFrame.container:AddMessage(text, 1, 0.75, 0);
	end


	resizeChat();
end

local function onLootAll()
	if dialogFrame:IsVisible() and dialogFrame.LO then
		dialogFrame.Chat.NextButton:GetScript("OnClick")(dialogFrame.Chat.NextButton, "LeftButton");
	end
end

local function setModel(model, dialogStepClass, field)
	model.modelLoaded = false;
	model:Hide();
	model.model = "";
	dialogFrame[field] = dialogStepClass[field] or dialogFrame[field];
	local modelID = dialogFrame[field];

	if not modelID or modelID:len() == 0 or (modelID == "target" and not UnitExists("target")) then
		model.modelLoaded = true;
	else
		model:Show();
		if modelID == "target" or modelID == "player" then
			model:SetUnit(modelID, true);
		elseif modelID:sub(1, 3) == "DID" then
			model:SetDisplayInfo(tonumber(modelID:sub(4, modelID:len())) or 0);
		else
			model:SetCreature(tonumber(modelID) or 0);
		end
	end
end

-- Prepare all the texts for a step
function processDialogStep()
	wipe(dialogFrame.texts);
	local dialogClass = dialogFrame.class;
	local dialogStepClass  = (dialogClass.DS or EMPTY)[dialogFrame.stepIndex] or EMPTY;

	-- Names
	dialogFrame.ND = dialogStepClass.ND or dialogFrame.ND or "NONE";
	dialogFrame.NA = dialogStepClass.NA or dialogFrame.NA or "${trp:player:full}";
	dialogFrame.NA_PARSED = TRP3_API.script.parseArgs(dialogFrame.NA, dialogFrame.args);
	dialogFrame.Chat.Right:Hide();
	dialogFrame.Chat.Left:Hide();
	if dialogFrame.ND == "RIGHT" then
		dialogFrame.Chat.Right:Show();
		dialogFrame.Chat.Right.Name:SetText(dialogFrame.NA_PARSED);
		dialogFrame.Chat.Right:SetWidth(dialogFrame.Chat.Right.Name:GetStringWidth() + 20);
	elseif dialogFrame.ND == "LEFT" then
		dialogFrame.Chat.Left:Show();
		dialogFrame.Chat.Left.Name:SetText(dialogFrame.NA_PARSED);
		dialogFrame.Chat.Left:SetWidth(dialogFrame.Chat.Left.Name:GetStringWidth() + 20);
	end

	-- Wait for loot
	dialogFrame.LO = dialogStepClass.LO;

	-- Background
	dialogFrame.BG = dialogStepClass.BG or dialogFrame.BG or DEFAULT_BG;
	local setBackground;
	setBackground = function(forceNoFade)
		if dialogFrame.background.current ~= dialogFrame.BG then
			if forceNoFade or dialogFrame.background.current == nil then
				dialogFrame.background:SetTexture(dialogFrame.BG);
				dialogFrame.background.current = dialogFrame.BG;
				if not forceNoFade then
					dialogFrame.background:SetAlpha(0);
					TRP3_API.ui.misc.playAnimation(dialogFrame.background.FadeIn);
				end
			else
				dialogFrame.background.current = nil;
				TRP3_API.ui.misc.playAnimation(dialogFrame.background.FadeOut);
				after(0.5, function()
					setBackground();
				end)
			end
		end
	end
	if dialogFrame.BG then
		setBackground(dialogFrame.stepIndex == 1);
	end


	-- Image
	image:Hide();
	dialogFrame.IM = dialogStepClass.IM or dialogFrame.IM;
	local setImage = function()
		image:SetTexture(dialogFrame.IM.UR);
		image:SetTexCoord(dialogFrame.IM.LE or 0, dialogFrame.IM.RI or 1, dialogFrame.IM.TO or 0, dialogFrame.IM.BO or 1);
		image:SetSize(dialogFrame.IM.WI or 256, dialogFrame.IM.HE or 256);
		TRP3_API.ui.misc.playAnimation(image.FadeIn);
	end
	if dialogFrame.IM then
		image:Show();
		if not image.previous then
			setImage();
		elseif image.previous and image.previous ~= dialogFrame.IM.UR then
			TRP3_API.ui.misc.playAnimation(image.FadeOut);
			after(1, function()
				setImage();
			end)
		end
		image.previous = dialogFrame.IM.UR;
	end

	-- Models
	dialogFrame.loaded = false;
	setModel(modelLeft, dialogStepClass, "LU");
	setModel(modelRight, dialogStepClass, "RU");

	-- Process text
	if dialogStepClass.TX then
		local fullText = dialogStepClass.TX;
		fullText = fullText:gsub(LINE_FEED_CODE .. "+", "\n");
		fullText = fullText:gsub(WEIRD_LINE_BREAK, "\n");

		local texts = { strsplit("\n", fullText) };
		-- If last is empty, remove last
		if texts[#texts]:len() == 0 then
			texts[#texts] = nil;
		end

		dialogFrame.texts = texts;
	end

	dialogFrame.stepDialogIndex = 1;
	dialogFrame.dialogStepClass = dialogStepClass;

	if dialogFrame.classID and dialogStepClass.WO then
		local retCode = TRP3_API.script.executeClassScript(dialogStepClass.WO, dialogClass.SC, {}, dialogFrame.classID);
	end

	playDialogStep();
end

local function startDialog(dialogID, class, args)
	local dialogClass = dialogID and getClass(dialogID) or class;
	-- By default, launch the step 1
	image.previous = nil;
	dialogFrame.classID = dialogID;
	dialogFrame.background.current = nil;
	dialogFrame.isPreview = dialogID == nil;
	dialogFrame.class = dialogClass;
	dialogFrame.stepIndex = dialogClass.BA.FS or 1;
	dialogFrame.distanceLimit = dialogClass.BA.DI or 0;
	dialogFrame.posY, dialogFrame.posX = UnitPosition("player");
	dialogFrame.args = args;
	-- Reset attributes from previous play
	local ATTRIBUTES_KEY = {
		"NA", "ND", "BG", "IM", "LU", "RU"
	}
	for _, key in pairs(ATTRIBUTES_KEY) do
		dialogFrame[key] = nil;
	end

	if dialogID and dialogClass.LI and dialogClass.LI.OS and dialogClass.SC then
		local retCode = TRP3_API.script.executeClassScript(dialogClass.LI.OS, dialogClass.SC, {}, dialogID);
	end

	historyFrame.container:AddMessage("---------------------------------------------------------------");
	processDialogStep();

	dialogFrame:Show();
	dialogFrame:Raise();

	dialogFrame:SetSize(dialogFrame.width or 950, dialogFrame.height or 670);
	resizeChat();
end

TRP3_API.extended.dialog.startDialog = startDialog;

local function startQuickDialog(text)
	local class = {
		TY = TRP3_DB.types.DIALOG,
		BA = {},
		DS = {
			{
				["TX"] = text,
				["ND"] = "RIGHT",
				["NA"] = "${trp:target:full}",
				["LU"] = "player",
				["RU"] = "target",
			},
		}
	}
	startDialog(nil, class)
end
TRP3_API.extended.dialog.startQuickDialog = startQuickDialog;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onLoaded()

end

function TRP3_API.extended.dialog.onStart()

	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, onLoaded);
	TRP3_API.events.listenToEvent(TRP3_API.inventory.EVENT_LOOT_ALL, onLootAll);

	-- Effect and operands
	TRP3_API.script.registerEffects({
		dialog_start = {
			secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
			method = function(structure, cArgs, eArgs)
				local dialogID = cArgs[1];
				eArgs.LAST = startDialog(dialogID, nil, eArgs);
			end,
		},
	});

	TRP3_API.script.registerEffects({
		dialog_quick = {
			secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
			method = function(structure, cArgs, eArgs)
				local dialogText = cArgs[1];
				eArgs.LAST = startQuickDialog(dialogText);
			end,
		},
	});

	modelLeft.animTab = {};
	modelRight.animTab = {};
	dialogFrame.texts = {};
	dialogFrame.Chat:SetScript("OnUpdate", onUpdateChatText);
	dialogFrame:SetScript("OnHide", function()
		reinitModel(modelLeft);
		reinitModel(modelRight);
	end);

	-- 3D models loaded
	modelLeft:SetScript("OnModelLoaded", function()
		modelLeft.modelLoaded = true;
		modelsLoaded();
	end);
	modelRight:SetScript("OnModelLoaded", function()
		modelRight.modelLoaded = true;
		modelsLoaded();
	end);

	-- Resizing
	dialogFrame.Chat.Text:SetWidth(550);
	dialogFrame.Resize.onResizeStop = function(width, height)
		resizeChat();
		dialogFrame.width = width;
		dialogFrame.height = height;
	end;

	-- Choices
	dialogFrame.Choice1.Num.Display:SetNumber(1);
	dialogFrame.Choice2.Num.Display:SetNumber(2);
	dialogFrame.Choice3.Num.Display:SetNumber(3);
	dialogFrame.Choice4.Num.Display:SetNumber(4);
	dialogFrame.Choice5.Num.Display:SetNumber(5);
	dialogFrame.choices = { dialogFrame.Choice1, dialogFrame.Choice2, dialogFrame.Choice3, dialogFrame.Choice4, dialogFrame.Choice5 }

	-- History
	local function showHistory()
		historyFrame:Show();
	end
	setTooltipAll(dialogFrame.Chat.HistoryButton, "RIGHT", 0, 5, loc.DI_HISTORY, loc.DI_HISTORY_TT);
	dialogFrame.Chat.HistoryButton:SetScript("OnClick", function()
		showHistory();
	end);
	historyFrame.title:SetText(loc.DI_HISTORY);
	historyFrame.Close:SetScript("OnClick", function()
		historyFrame:Hide();
	end);
	historyFrame:SetScript("OnMouseWheel",function(self, delta)
		if delta == -1 then
			historyFrame.container:ScrollDown();
		elseif delta == 1 then
			historyFrame.container:ScrollUp();
		end
	end);
	historyFrame:EnableMouseWheel(1);

	historyFrame.bottom:SetScript("OnClick", function()
		historyFrame.container:ScrollToBottom();
	end);

	historyFrame.container:SetFontObject(ChatFontNormal);
	historyFrame.container:SetJustifyH("LEFT");

	TRP3_API.ui.frame.setupMove(historyFrame);
	TRP3_API.ui.frame.setupMove(dialogFrame);
end