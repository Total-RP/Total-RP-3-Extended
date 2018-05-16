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
local wipe, pairs, strsplit, tinsert, tonumber, strtrim = wipe, pairs, strsplit, tinsert, tonumber, strtrim;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local stEtN = Utils.str.emptyToNil;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local delayEditor = TRP3_ScriptEditorDelay;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Delay
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function delayEditor.decorate(scriptStep)
	local strToFormat = "%s: " .. TRP3_API.Ellyb.ColorManager.YELLOW("%s %s|r");
	local delayText;
	if scriptStep.c == 2 then
		delayText = loc.WO_DELAY_CAST;
	else
		delayText = loc.WO_DELAY_WAIT;
	end
	return strToFormat:format(delayText, scriptStep.d or 0, loc.WO_DELAY_SECONDS);
end

function delayEditor.save(scriptStepStructure)
	scriptStepStructure.d = tonumber(delayEditor.duration:GetText()) or 1;
	scriptStepStructure.s = tonumber(delayEditor.sound:GetText()) or 0;
	scriptStepStructure.c = delayEditor.type:GetSelectedValue() or 1;
	scriptStepStructure.i = delayEditor.interrupt:GetSelectedValue() or 1;
	scriptStepStructure.x = stEtN(strtrim(delayEditor.text:GetText() or ""));
end

function delayEditor.load(scriptStepStructure)
	delayEditor.type:SetSelectedValue(scriptStepStructure.c or 1);
	delayEditor.interrupt:SetSelectedValue(scriptStepStructure.i or 1);
	delayEditor.duration:SetText(scriptStepStructure.d or 0);
	delayEditor.sound:SetText(scriptStepStructure.s or 0);
	delayEditor.text:SetText(scriptStepStructure.x or "");
end

function delayEditor.init()
	-- Duration
	delayEditor.duration.title:SetText(loc.WO_DELAY_DURATION);
	setTooltipForSameFrame(delayEditor.duration.help, "RIGHT", 0, 5, loc.WO_DELAY_DURATION, loc.WO_DELAY_DURATION_TT);

	-- Cast sound
	delayEditor.sound.title:SetText(loc.WO_DELAY_CAST_SOUND);
	setTooltipForSameFrame(delayEditor.sound.help, "RIGHT", 0, 5, loc.WO_DELAY_CAST_SOUND, loc.WO_DELAY_CAST_SOUND_TT);

	-- Cast text
	delayEditor.text.title:SetText(loc.WO_DELAY_CAST_TEXT);
	setTooltipForSameFrame(delayEditor.text.help, "RIGHT", 0, 5, loc.WO_DELAY_CAST_TEXT, loc.WO_DELAY_CAST_TEXT_TT);

	-- Delay type
	local type = {
		{TRP3_API.formats.dropDownElements:format(loc.WO_DELAY_TYPE, loc.WO_DELAY_TYPE_1), 1, loc.WO_DELAY_TYPE_1_TT},
		{TRP3_API.formats.dropDownElements:format(loc.WO_DELAY_TYPE, loc.WO_DELAY_TYPE_2), 2, loc.WO_DELAY_TYPE_2_TT}
	}
	TRP3_API.ui.listbox.setupListBox(delayEditor.type, type, function(value)
		if value == 2 then
			delayEditor.sound:Show();
			delayEditor.text:Show();
		else
			delayEditor.sound:Hide();
			delayEditor.text:Hide();
		end
	end, nil, 200, true);

	-- Interruption
	local type = {
		{TRP3_API.formats.dropDownElements:format(loc.WO_DELAY_INTERRUPT, loc.WO_DELAY_INTERRUPT_1), 1},
		{TRP3_API.formats.dropDownElements:format(loc.WO_DELAY_INTERRUPT, loc.WO_DELAY_INTERRUPT_2), 2}
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

local function onBrowserLineClick(frame)
	onBrowserClose();
	if objectBrowser.onSelectCallback then
		objectBrowser.onSelectCallback(frame.objectID);
	end
end

local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local ID_SEPARATOR = TRP3_API.extended.ID_SEPARATOR;
local fieldFormat = "%s: " .. TRP3_API.Ellyb.ColorManager.YELLOW("%s|r");

local function decorateBrowserLine(frame, index)
	local objectID = filteredObjectList[index];
	local class = getClass(objectID);
	local icon, name = TRP3_API.extended.tools.getClassDataSafeByType(class);
	local fullLink = TRP3_API.inventory.getItemLink(class, objectID, true);
	local link = TRP3_API.inventory.getItemLink(class, objectID);

	_G[frame:GetName().."Text"]:SetText(fullLink);

	local text = "";
	local title = fullLink;
	local parts = {strsplit(ID_SEPARATOR, objectID)};
	local rootClass = getClass(parts[1]);
	local metadata = rootClass.MD or EMPTY;

	text = text .. fieldFormat:format(loc.TYPE, getTypeLocale(class.TY));
	text = text .. "\n" .. fieldFormat:format(loc.ROOT_CREATED_BY, metadata.CB or "?");
	text = text .. "\n" .. fieldFormat:format(loc.SEC_LEVEL, TRP3_API.security.getSecurityText(rootClass.securityLevel or SECURITY_LEVEL.LOW));

	if class.TY == TRP3_DB.types.ITEM then
		local base = class.BA or EMPTY;

		text = text .. "\n";

		text = text .. "\n" .. Utils.str.icon(base.IC or "temp", 25) .. " " .. link;
		if base.LE or base.RI then
			if base.LE and not base.RI then
				text = text .. "\n" .. TRP3_API.Ellyb.ColorManager.WHITE(base.LE);
			elseif base.RI and not base.LE then
				text = text .. "\n" .. TRP3_API.Ellyb.ColorManager.WHITE(base.RI);
			else
				text = text .. "\n" .. TRP3_API.Ellyb.ColorManager.WHITE(base.LE .. " - " .. base.RI);
			end
		end
		if base.DE then
			local argsStructure = {object = {id = objectID}};
			text = text .. "\n" .. TRP3_API.Ellyb.ColorManager.ORANGE("\"" .. TRP3_API.script.parseArgs(base.DE .. "\"", argsStructure));
		end
		text = text .. "\n" .. TRP3_API.Ellyb.ColorManager.WHITE(TRP3_API.extended.formatWeight(base.WE or 0) .. " - " .. GetCoinTextureString(base.VA or 0));

	end

	setTooltipForSameFrame(frame, "TOP", 0, 5, title, text);

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
			if not objectBrowser.itemFilter or class.TY ~= TRP3_DB.types.ITEM or not class.BA or not class.BA.PA then
				local _, name = TRP3_API.extended.tools.getClassDataSafeByType(class);
				if filterMatch(filter, objectFullID) or filterMatch(filter, name) then
					tinsert(filteredObjectList, objectFullID);
					count = count + 1;
				end
				total = total + 1;
			end
		end
	end
	objectBrowser.filter.total:SetText( (#filteredObjectList) .. " / " .. total );

	table.sort(filteredObjectList);

	initList(
		{
			widgetTab = objectBrowser.widgetTab,
			decorate = decorateBrowserLine
		},
		filteredObjectList,
		objectBrowser.content.slider
	);
end

local function showObjectBrowser(onSelectCallback, type, itemFilter)
	objectBrowser.title:SetText(loc.DB_BROWSER .. " (" .. getTypeLocale(type) .. ")")
	objectBrowser.onSelectCallback = onSelectCallback;
	objectBrowser.type = type;
	objectBrowser.filter.box:SetText("");
	objectBrowser.filter.box:SetFocus();
	objectBrowser.itemFilter = itemFilter;
	filteredObjectBrowser();
end

function objectBrowser.init()
	handleMouseWheel(objectBrowser.content, objectBrowser.content.slider);
	objectBrowser.content.slider:SetValue(0);

	-- Create icons
	objectBrowser.widgetTab = {};

	-- Create lines
	for line = 0, 8 do
		local button = CreateFrame("Button", "TRP3_ObjectBrowserButton_" .. line, objectBrowser.content, "TRP3_MusicBrowserLine");
		button:SetPoint("TOP", objectBrowser.content, "TOP", 0, -10 + (line * (-31)));
		button:SetScript("OnClick", onBrowserLineClick);
		tinsert(objectBrowser.widgetTab, button);
	end

	objectBrowser.filter.box:SetScript("OnTextChanged", filteredObjectBrowser);
	objectBrowser.close:SetScript("OnClick", onBrowserClose);

	objectBrowser.filter.box.title:SetText(loc.UI_FILTER);

	TRP3_API.popup.OBJECTS = "objects";
	TRP3_API.popup.POPUPS[TRP3_API.popup.OBJECTS] = {
		frame = objectBrowser,
		showMethod = showObjectBrowser,
	};
end