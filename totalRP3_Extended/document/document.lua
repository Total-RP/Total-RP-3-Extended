----------------------------------------------------------------------------------
-- Total RP 3: Document system
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
local _G, assert, tostring, tinsert, wipe, pairs = _G, assert, tostring, tinsert, wipe, pairs;
local loc = TRP3_API.locale.getText;
local Log = Utils.log;
local EMPTY = TRP3_API.globals.empty;
local getClass = TRP3_API.extended.getClass;

local documentFrame = TRP3_DocumentFrame;
local HTMLFrame = documentFrame.scroll.child.HTML;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UTILS
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local MARGIN = 100;

local function setFrameSize(width, height)
	TRP3_DocumentFrame:SetSize(width, height);
	HTMLFrame:SetSize(width - MARGIN, 5);
	HTMLFrame:SetText(HTMLFrame.html);
end

local function setFrameHTML(html)
	HTMLFrame.html = Utils.str.toHTML(html);
	HTMLFrame:SetText(HTMLFrame.html);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Document API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.extended.document.BorderType = {
	PARCHMENT = 1,
}

local function showDocumentClass(document, documentID)
	documentFrame:Hide();

	local HTML = "";
	if document.PA and document.PA[1] then
		HTML = document.PA[1].TX or "";
	end

	documentFrame.ID = documentID;
	documentFrame.class = document;

	if document.BT == true then
		documentFrame.bTile:Show();
		documentFrame.bTile:SetTexture(TRP3_API.ui.frame.getTiledBackground(document.BCK or 8), true, true);
		documentFrame.bNotTile:Hide();
	else
		documentFrame.bNotTile:Show();
		documentFrame.bNotTile:SetTexture(TRP3_API.ui.frame.getTiledBackground(document.BCK or 8));
		documentFrame.bTile:Hide();
	end

	setFrameSize(document.WI or 450, document.HE or 600);

	if document.FR then
		documentFrame.Resize:Show();
	else
		documentFrame.Resize:Hide();
	end
	documentFrame.Resize.minWidth = document.WI or 450;
	documentFrame.Resize.minHeight = document.HE or 600;
	documentFrame.Resize.onResizeStop = function()
		setFrameSize(documentFrame:GetWidth(), documentFrame:GetHeight());
	end;

	HTMLFrame:SetTextColor("p", 0.2824, 0.0157, 0.0157);
	HTMLFrame:SetShadowOffset("p", 0, 0);
	HTMLFrame:SetTextColor("h1", 0, 0, 0);
	HTMLFrame:SetShadowOffset("h1", 0, 0);
	HTMLFrame:SetTextColor("h2", 0, 0, 0);
	HTMLFrame:SetShadowOffset("h2", 0, 0);
	HTMLFrame:SetTextColor("h3", 0, 0, 0);
	HTMLFrame:SetShadowOffset("h3", 0, 0);

	HTMLFrame:SetFontObject("h1", _G[document.H1_F or "DestinyFontHuge"]);
	HTMLFrame:SetFontObject("h2", _G[document.H2_F or "QuestFont_Huge"]);
	HTMLFrame:SetFontObject("h3", _G[document.H3_F or "GameFontNormalLarge"]);
	HTMLFrame:SetFontObject("p", _G[document.P_F or "GameTooltipHeader"]);

	setFrameHTML(HTML);

	documentFrame:Show();
end
TRP3_API.extended.document.showDocumentClass = showDocumentClass;

local function showDocument(documentID)
	local document = getClass(documentID);
	if document == TRP3_DB.missing then
		Utils.message.displayMessage(loc("DOC_UNKNOWN_ALERT"), Utils.message.type.ALERT_MESSAGE);
	else
		showDocumentClass(document, documentID);
	end
end
TRP3_API.extended.document.showDocument = showDocument;

local function onLinkClicked(self, url)
	if documentFrame.class and documentFrame.class.AC and documentFrame.class.AC[url] and documentFrame.class.SC then
		local scriptID = documentFrame.class.AC[url];
		local retCode = TRP3_API.script.executeClassScript(scriptID, documentFrame.class.SC,
			{
				documentID = documentFrame.ID, documentClass = documentFrame.class
			});
	end
end

local function closeDocument(documentID)
	if documentFrame:IsVisible() and documentFrame.ID == documentID then
		documentFrame:Hide();
	end
end
TRP3_API.extended.document.closeDocument = closeDocument;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function onLoaded()

end

function TRP3_API.extended.document.onStart()

	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, onLoaded);

	documentFrame.Resize.resizableFrame = documentFrame;

	-- Customize HTML
	HTMLFrame:SetScript("OnHyperlinkClick", onLinkClicked);

	-- Effect and operands
	TRP3_API.script.registerEffects({
		document_show = {
			codeReplacementFunc = function (args)
				local documentID = args[1];
				return ("lastEffectReturn = showDocument(\"%s\");"):format(documentID);
			end,
			env = {
				showDocument = "TRP3_API.extended.document.showDocument",
			},
		},

		document_close = {
			codeReplacementFunc = function (args)
				local documentID = args[1];
				return ("lastEffectReturn = closeDocument(\"%s\");"):format(documentID);
			end,
			env = {
				closeDocument = "TRP3_API.extended.document.closeDocument",
			}
		}
	});
end
