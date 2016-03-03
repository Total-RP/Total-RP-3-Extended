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
local wipe, pairs, strsplit, tinsert, table = wipe, pairs, strsplit, tinsert, table;
local tsize = Utils.table.size;
local getClass = TRP3_API.extended.getClass;
local getTypeLocale = TRP3_API.extended.tools.getTypeLocale;
local loc = TRP3_API.locale.getText;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local editor = TRP3_ItemQuickEditor;
local onCreatedCallback;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Item quick editor
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onSave()
	local ID, data = TRP3_API.extended.tools.createItem(
		{
			TY = TRP3_DB.types.ITEM,
			BA = {
				NA = editor.name:GetText(),
			}
		}
	);

	if onCreatedCallback then
		onCreatedCallback();
	end
	editor:Hide();
end

function TRP3_API.extended.tools.openItemQuickEditor(anchoredFrame, callback)
	onCreatedCallback = callback;
	TRP3_API.ui.frame.configureHoverFrame(editor, anchoredFrame, "BOTTOM", 0, 5, true);
	editor.name:SetText("New item"); -- TODO: locals
	editor.description:SetText("");
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.extended.tools.initItemQuickEditor()
	editor.title:SetText("Quick item creation"); -- TODO: locals
	editor.name.title:SetText("Item name"); -- TODO: locals
	editor.description.title:SetText("Item description"); -- TODO: locals

	setTooltipForSameFrame(editor.name.help, "RIGHT", 0, 5, "Item name", "It's your item name."); -- TODO: locals
	setTooltipForSameFrame(editor.description.help, "RIGHT", 0, 5, "Item description", "It's your item description."); -- TODO: locals

	TRP3_API.ui.frame.setupFieldPanel(editor.peek, "Peek", 70); -- TODO: locals

	editor.save:SetScript("OnClick", onSave);
	editor:SetScript("OnShow", function()
		editor.name:SetFocus();
	end)
end