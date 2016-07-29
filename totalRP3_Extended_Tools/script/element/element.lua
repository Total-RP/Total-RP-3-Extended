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

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local wipe, pairs, tostring, tinsert, tonumber = wipe, pairs, tostring, tinsert, tonumber;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local delayEditor = TRP3_ScriptEditorDelay;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Delay
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function delayEditor.save(scriptStepStructure)
	scriptStepStructure.d = tonumber(delayEditor.duration:GetText()) or 1;
	scriptStepStructure.c = delayEditor.type:GetSelectedValue() or 1;
	scriptStepStructure.i = delayEditor.interrupt:GetSelectedValue() or 1;
end

function delayEditor.load(scriptStepStructure)
	delayEditor.type:SetSelectedValue(scriptStepStructure.c or 1);
	delayEditor.interrupt:SetSelectedValue(scriptStepStructure.i or 1);
	delayEditor.duration:SetText(scriptStepStructure.d or 0);
end

function delayEditor.init()
	-- Duration
	delayEditor.duration.title:SetText(loc("WO_DELAY_DURATION"));
	setTooltipForSameFrame(delayEditor.duration.help, "RIGHT", 0, 5, loc("WO_DELAY_DURATION"), loc("WO_DELAY_DURATION_TT"));

	-- Delay type
	local type = {
		{TRP3_API.formats.dropDownElements:format(loc("WO_DELAY_TYPE"), loc("WO_DELAY_TYPE_1")), 1}
	}
	TRP3_API.ui.listbox.setupListBox(delayEditor.type, type, nil, nil, 200, true);

	-- Interruption
	local type = {
		{TRP3_API.formats.dropDownElements:format(loc("WO_DELAY_INTERRUPT"), loc("WO_DELAY_INTERRUPT_1")), 1}
	}
	TRP3_API.ui.listbox.setupListBox(delayEditor.interrupt, type, nil, nil, 200, true);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Object browser
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local objectBrowser = TRP3_ObjectBrowser;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local CreateFrame = CreateFrame;
local initList = TRP3_API.ui.list.initList;
local safeMatch = TRP3_API.utils.str.safeMatch;
local filteredObjectList = {};

local function onBrowserClose()
	TRP3_API.popup.hidePopups();
	objectBrowser:Hide();
end

local function onBrowserIconClick(frame)
	onBrowserClose();
	if objectBrowser.onSelectCallback then
		objectBrowser.onSelectCallback(frame.objectID);
	end
end

local function decorateBrowserIcon(frame, index)
	local objectID = filteredObjectList[index];
	local class = getClass(objectID);
	local icon, name = TRP3_API.extended.tools.getClassDataSafeByType(class);
	local link = TRP3_API.inventory.getItemLink(class, objectID);

	frame:SetNormalTexture("Interface\\ICONS\\" .. icon);
	frame:SetPushedTexture("Interface\\ICONS\\" .. icon);
	setTooltipForSameFrame(frame, "TOP", 0, 5, link, objectID);
	frame.objectID = objectID;
end

local function filterMatch(filter, value)
	-- No filter or bad filter
	if filter == nil or filter:len() == 0 then
		return true;
	end
	return safeMatch(value:lower(), filter:lower());
end

local function filteredObjectBrowser()
	local filter = objectBrowser.filter.box:GetText();
	wipe(filteredObjectList);

	local total, count = 0, 0;
	for objectFullID, class in pairs(TRP3_DB.global) do
		if not class.hideFromList and class.TY == objectBrowser.type then
			local _, name = TRP3_API.extended.tools.getClassDataSafeByType(class);
			if filterMatch(filter, objectFullID) or filterMatch(filter, name) then
				tinsert(filteredObjectList, objectFullID);
				count = count + 1;
			end
			total = total + 1;
		end
	end
	objectBrowser.filter.total:SetText( (#filteredObjectList) .. " / " .. total );

	initList(
		{
			widgetTab = objectBrowser.widgetTab,
			decorate = decorateBrowserIcon
		},
		filteredObjectList,
		objectBrowser.content.slider
	);
end

local function showObjectBrowser(onSelectCallback, type)
	objectBrowser.title:SetText(loc("DB_BROWSER") .. " (" .. TRP3_API.extended.tools.getTypeLocale(type) .. ")")
	objectBrowser.onSelectCallback = onSelectCallback;
	objectBrowser.type = type;
	objectBrowser.filter.box:SetText("");
	objectBrowser.filter.box:SetFocus();
	filteredObjectBrowser();
end

function objectBrowser.init()
	handleMouseWheel(objectBrowser.content, objectBrowser.content.slider);
	objectBrowser.content.slider:SetValue(0);

	-- Create icons
	local row, column;
	objectBrowser.widgetTab = {};

	for row = 0, 5 do
		for column = 0, 7 do
			local button = CreateFrame("Button", "TRP3_ObjectBrowserButton_"..row.."_"..column, objectBrowser.content, "TRP3_IconBrowserButton");
			button:ClearAllPoints();
			button:SetPoint("TOPLEFT", objectBrowser.content, "TOPLEFT", 15 + (column * 45), -15 + (row * (-45)));
			button:SetScript("OnClick", onBrowserIconClick);
			tinsert(objectBrowser.widgetTab, button);
		end
	end

	objectBrowser.filter.box:SetScript("OnTextChanged", filteredObjectBrowser);
	objectBrowser.close:SetScript("OnClick", onBrowserClose);

	objectBrowser.filter.box.title:SetText(loc("UI_FILTER"));

	TRP3_API.popup.OBJECTS = "objects";
	TRP3_API.popup.POPUPS[TRP3_API.popup.OBJECTS] = {
		frame = objectBrowser,
		showMethod = showObjectBrowser,
	};
end