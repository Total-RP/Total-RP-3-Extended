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
local loc = TRP3_API.locale.getText;
local EMPTY = TRP3_API.globals.empty;
local Log = Utils.log;
local getClass = TRP3_API.extended.getClass;
local UnitExists = UnitExists;

local dialogFrame = TRP3_DialogFrame;
local CHAT_MARGIN = 70;

local LINE_FEED_CODE = string.char(10);
local CARRIAGE_RETURN_CODE = string.char(13);
local WEIRD_LINE_BREAK = LINE_FEED_CODE .. CARRIAGE_RETURN_CODE .. LINE_FEED_CODE;

local scalingLib = LibStub:GetLibrary("TRP-Dialog-Scaling-DB");
local animationLib = LibStub:GetLibrary("TRP-Dialog-Animation-DB");

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Models and animations
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local modelLeft, modelRight, image = dialogFrame.Models.Me, dialogFrame.Models.You, dialogFrame.Image;
local generateID = Utils.str.id;

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
end

local function setupChoices(choices)
	for choiceIndex, choiceData in pairs(choices) do
		local choiceButton = modelLeft.choices[choiceIndex];
		choiceButton.Text:SetText(choiceData.TX);
		choiceButton.Click:SetScript("OnClick", function()
			dialogFrame.stepIndex = choiceData.N;
			processDialogStep();
		end);
		choiceButton:Show();
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
	wipe(modelLeft.animTab);
	wipe(modelRight.animTab);
	modelLeft.token = nil;
	modelRight.token = nil;

	-- Choices
	for _, choiceButton in pairs(modelLeft.choices) do
		choiceButton:Hide();
	end

	-- Animations
	local targetModel = dialogFrame.ND == "LEFT" and modelLeft or modelRight;
	local animTab = targetModel.animTab;

	-- Text color (emote)
	if text:byte() == 60 then
		local color = Utils.color.colorCodeFloat(ChatTypeInfo["MONSTER_EMOTE"].r, ChatTypeInfo["MONSTER_EMOTE"].g, ChatTypeInfo["MONSTER_EMOTE"].b);
		text = text:gsub("<", color):gsub(">", "|r");
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

	dialogFrame.Chat.Next:SetText(loc("DI_NEXT"));
	dialogFrame.Chat.NextButton:Enable();
	if not dialogFrame.isPreview and dialogFrame.LO then
		dialogFrame.Chat.NextButton:Disable();
		dialogFrame.Chat.Next:SetText(loc("DI_WAIT_LOOT"));
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
			dialogFrame.Chat.NextButton:Disable();
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

	resizeChat();
end

local function onLootAll()
	if dialogFrame:IsVisible() and dialogFrame.LO then
		dialogFrame.Chat.NextButton:GetScript("OnClick")(dialogFrame.Chat.NextButton, "LeftButton");
	end
end

-- Prepare all the texts for a step
function processDialogStep()
	wipe(dialogFrame.texts);
	local dialogClass = dialogFrame.class;
	local dialogStepClass  = (dialogClass.DS or EMPTY)[dialogFrame.stepIndex] or EMPTY;

	-- Names
	dialogFrame.ND = dialogStepClass.ND or dialogFrame.ND or "NONE";
	dialogFrame.NA = dialogStepClass.NA or dialogFrame.NA or "player";
	if dialogFrame.NA == "player" or dialogFrame.NA == "target" then
		dialogFrame.NA = UnitName(dialogFrame.NA);
	end
	dialogFrame.Chat.Right:Hide();
	dialogFrame.Chat.Left:Hide();
	if dialogFrame.ND == "RIGHT" then
		dialogFrame.Chat.Right:Show();
		dialogFrame.Chat.Right.Name:SetText(dialogFrame.NA);
		dialogFrame.Chat.Right:SetWidth(dialogFrame.Chat.Right.Name:GetStringWidth() + 20);
	elseif dialogFrame.ND == "LEFT" then
		dialogFrame.Chat.Left:Show();
		dialogFrame.Chat.Left.Name:SetText(dialogFrame.NA);
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

	modelLeft.modelLoaded = false;
	modelLeft:Hide();
	modelLeft.model = "";
	dialogFrame.LU = dialogStepClass.LU or dialogFrame.LU or "player";
	if dialogFrame.LU:len() == 0 then
		modelLeft.modelLoaded = true;
	elseif dialogFrame.LU ~= "target" or UnitExists("target") then
		modelLeft:Show();
		if dialogFrame.LU == "target" or dialogFrame.LU == "player" then
			modelLeft:SetUnit(dialogFrame.LU, true);
		else
			modelLeft:SetDisplayInfo(tonumber(dialogFrame.LU) or 0);
		end
	end

	modelRight.modelLoaded = false;
	modelRight:Hide();
	modelRight.model = "";
	dialogFrame.RU = dialogStepClass.RU or dialogFrame.RU or "player";
	if dialogFrame.RU:len() == 0 then
		modelRight.modelLoaded = true;
	elseif dialogFrame.RU ~= "target" or UnitExists("target") then
		modelRight:Show();
		if dialogFrame.RU == "target" or dialogFrame.RU == "player" then
			modelRight:SetUnit(dialogFrame.RU, false);
		else
			modelRight:SetDisplayInfo(tonumber(dialogFrame.RU) or 0);
		end
	end

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
		local retCode = TRP3_API.script.executeClassScript(dialogStepClass.WO, dialogClass.SC,
			{
				class = dialogClass,
				dialogStepClass = dialogStepClass,
			}, dialogFrame.classID);
	end

	playDialogStep();
end

local function startDialog(dialogID, class)
	local dialogClass = dialogID and getClass(dialogID) or class;
	-- By default, launch the step 1
	image.previous = nil;
	dialogFrame.classID = dialogID;
	dialogFrame.background.current = nil;
	dialogFrame.isPreview = dialogID == nil;
	dialogFrame.class = dialogClass;
	dialogFrame.stepIndex = dialogClass.BA.FS or 1;
	dialogFrame:Show();
	dialogFrame:Raise();

	processDialogStep();

	dialogFrame:SetSize(dialogFrame.width or 950, dialogFrame.height or 670);
	resizeChat();
end

TRP3_API.extended.dialog.startDialog = startDialog;

function TRP3_API.extended.dialog.startQuickDialog(text)
	local class = {
		TY = TRP3_DB.types.DIALOG,
		BA = {},
		DS = {
			{
				["TX"] = text,
				["ND"] = "RIGHT",
				["NA"] = "target",
				["LU"] = "player",
				["RU"] = "target",
			},
		}
	}
	startDialog(nil, class)
end

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
			codeReplacementFunc = function(args)
				local dialogID = args[1];
				return ("lastEffectReturn = startDialog(\"%s\");"):format(dialogID);
			end,
			env = {
				startDialog = "TRP3_API.extended.dialog.startDialog",
			}
		},
	});

	TRP3_API.script.registerEffects({
		dialog_quick = {
			secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
			codeReplacementFunc = function(args)
				local dialogText = args[1];
				return ("lastEffectReturn = startQuickDialog(\"%s\");"):format(dialogText);
			end,
			env = {
				startQuickDialog = "TRP3_API.extended.dialog.startQuickDialog",
			}
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
	local setupButton = function(button, iconIndex)
		local QUEST_POI_ICONS_PER_ROW = 8;
		local QUEST_POI_ICON_SIZE = 0.125;
		local yOffset = 0.5 + floor(iconIndex / QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
		local xOffset = mod(iconIndex, QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
		button.Number:SetTexCoord(xOffset, xOffset + QUEST_POI_ICON_SIZE, yOffset, yOffset + QUEST_POI_ICON_SIZE);
	end
	setupButton(modelLeft.Choice1.Num, 0);
	setupButton(modelLeft.Choice2.Num, 1);
	setupButton(modelLeft.Choice3.Num, 2);
	setupButton(modelLeft.Choice4.Num, 3);
	setupButton(modelLeft.Choice5.Num, 4);
	modelLeft.choices = { modelLeft.Choice1, modelLeft.Choice2, modelLeft.Choice3, modelLeft.Choice4, modelLeft.Choice5}

end