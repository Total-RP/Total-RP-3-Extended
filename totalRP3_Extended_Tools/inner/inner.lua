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
local CreateFrame = CreateFrame;
local wipe, pairs, error, assert, tinsert = wipe, pairs, error, assert, tinsert;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local loc = TRP3_API.locale.getText;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local initList = TRP3_API.ui.list.initList;

local toolFrame;
local editor = TRP3_InnerObjectEditor;
editor.browser.container.lines = {};

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Inner object editor
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function decorateLine()

end

local function refresh()
	assert(toolFrame.specificDraft.IN, "No toolFrame.specificDraft.IN for refresh.");
	initList(
		{
			widgetTab = editor.browser.container.lines,
			decorate = decorateLine
		},
		toolFrame.specificDraft.IN,
		editor.browser.container.slider
	);
end
editor.refresh = refresh;

local function onLineClicked(line, button)

end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function editor.init(ToolFrame)
	toolFrame = ToolFrame;

	handleMouseWheel(editor.browser.container, editor.browser.container.slider);
	editor.browser.container.slider:SetValue(0);
	-- Create lines
	for line = 0, 8 do
		local lineFrame = CreateFrame("Button", "TRP3_InnerObjectEditorLine" .. line, editor.browser.container, "TRP3_InnerObjectEditorLine");
		lineFrame:SetPoint("TOP", editor.browser.container, "TOP", 0, -10 + (line * (-31)));
		lineFrame:SetScript("OnClick", onLineClicked);
		tinsert(editor.browser.container.lines, lineFrame);
	end
end