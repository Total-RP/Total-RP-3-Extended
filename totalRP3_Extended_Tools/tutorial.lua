----------------------------------------------------------------------------------
-- Total RP 3: Extended features
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

local Globals, Events, Utils, EMPTY = TRP3_API.globals, TRP3_API.events, TRP3_API.utils, TRP3_API.globals.empty;
local wipe, pairs, strsplit, tinsert, type, _G = wipe, pairs, strsplit, tinsert, type, _G;
local loc = TRP3_API.loc;

local ToolFrame, buttonWidget;

local currentList = {};
local currentStructure;

local function onStep(step)
	local stepInfo = currentStructure[step];
	local cancel = false;

	local cancelMessage;
	if stepInfo.callback then
		cancel, cancelMessage = stepInfo.callback();
	end

	if cancel then
		ToolFrame.tutoframe:Hide();
		Utils.message.displayMessage(cancelMessage, 4);
		return;
	end

	local frame = stepInfo.box;
	if frame and type(frame) == "string" then
		frame = _G[stepInfo.box];
	end

	if frame and frame:IsVisible() then
		buttonWidget.boxHighlight:SetAllPoints(stepInfo.box);
	else
		buttonWidget.boxHighlight:SetAllPoints(ToolFrame);
	end

	buttonWidget:ClearAllPoints();
	buttonWidget:SetPoint( stepInfo.anchor, buttonWidget.boxHighlight, stepInfo.anchor, stepInfo.x, stepInfo.y );

	TRP3_API.navigation.hideTutorialTooltip(buttonWidget);
	buttonWidget.arrow = stepInfo.arrow or "RIGHT";
	buttonWidget.text = loc(stepInfo.text);
	buttonWidget.textWidth = stepInfo.textWidth or 220;
	TRP3_API.navigation.showTutorialTooltip(buttonWidget);

	ToolFrame.tutoframe.previous:Enable();
	if step == 1 then
		ToolFrame.tutoframe.previous:Disable();
	end
	ToolFrame.tutoframe.next:Enable();
	if step == #currentStructure then
		ToolFrame.tutoframe.next:Disable();
	end

	ToolFrame.tutoframe.currentStep = step;
end

local function startTutorial(step)
	if ToolFrame.tutoframe:IsVisible() then
		ToolFrame.tutoframe:Hide();
	else
		ToolFrame.tutoframe:Show();
		ToolFrame.tutorialhide:Show();
		TRP3_API.ui.listbox.setupListBox(ToolFrame.tutoframe.step, currentList, onStep, nil, 200, true);
		ToolFrame.tutoframe.step:SetSelectedValue(step or 1);
		ToolFrame.tutoframe:SetFrameLevel(ToolFrame:GetFrameLevel() + 100);
		ToolFrame.tutorialhide:SetFrameLevel(ToolFrame:GetFrameLevel() + 50);
	end
end

function TRP3_ExtendedTutorial.loadStructure(structure)
	ToolFrame.tutorial:Hide();
	currentStructure = structure;

	if not structure then
		return;
	end

	wipe(currentList);
	for index, info in pairs(currentStructure) do
		tinsert(currentList, {index .. " - " .. loc(info.title), index});
	end

	ToolFrame.tutorial:Show();
	ToolFrame.tutorial:SetFrameLevel(ToolFrame:GetFrameLevel() + 100);
end

function TRP3_ExtendedTutorial.init(toolFrame)
	ToolFrame = toolFrame;

	TRP3_API.ui.tooltip.setTooltipAll(ToolFrame.tutorial, "TOP", 0, 0, loc.UI_TUTO_BUTTON, loc.UI_TUTO_BUTTON_TT);
	ToolFrame.tutoframe.title:SetText(loc.TU_TITLE);
	ToolFrame.tutorial:SetScript("OnClick", function()
		startTutorial(1);
	end);

	ToolFrame.tutoframe.next:SetText(">");
	ToolFrame.tutoframe.next:SetScript("OnClick", function()
		ToolFrame.tutoframe.step:SetSelectedValue(ToolFrame.tutoframe.currentStep + 1);
	end);

	ToolFrame.tutoframe.previous:SetText("<");
	ToolFrame.tutoframe.previous:SetScript("OnClick", function()
		ToolFrame.tutoframe.step:SetSelectedValue(ToolFrame.tutoframe.currentStep - 1);
	end);

	ToolFrame.tutoframe.close:SetScript("OnClick", function()
		ToolFrame.tutoframe:Hide();
	end);

	-- Create button
	buttonWidget = CreateFrame( "Button", nil, ToolFrame.tutoframe, "TRP3_TutorialButton" );
	buttonWidget.boxHighlight = CreateFrame( "Frame", nil, ToolFrame.tutoframe, "HelpPlateBoxHighlight" );
	buttonWidget:SetSize(46, 46);
	buttonWidget:Show();
	buttonWidget.boxHighlight:Show();
	buttonWidget.click = CreateFrame( "Button", nil, TRP3_TutorialTooltip, "TRP3_InvisibleButton" );
	buttonWidget.click:SetAllPoints(TRP3_TutorialTooltip);
	buttonWidget.click:SetScript("OnClick", function()
		if ToolFrame.tutoframe.next:IsEnabled() then
			ToolFrame.tutoframe.step:SetSelectedValue(ToolFrame.tutoframe.currentStep + 1);
		else
			ToolFrame.tutoframe:Hide();
		end
	end);
	ToolFrame.tutoframe:SetScript("OnHide", function()
		TRP3_API.navigation.hideTutorialTooltip(buttonWidget);
		ToolFrame.tutorialhide:Hide();
	end);
	ToolFrame:SetScript("OnHide", function()
		ToolFrame.tutoframe:Hide();
	end);
end