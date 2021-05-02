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
local loc = TRP3_API.loc;
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
	HTMLFrame.html = Utils.str.toHTML(html, true);
	HTMLFrame:SetText(HTMLFrame.html);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Document API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.extended.document.BorderType = {
	PARCHMENT = 1,
}

local function loadPage(page)
	assert(documentFrame.class, "documentFrame.class is nil");
	local data = documentFrame.class;
	local pages = data.PA or EMPTY;
	local total = #pages;

	documentFrame.next:Disable();
	documentFrame.previous:Disable();
	if page > 1 then
		documentFrame.previous:Enable();
	end
	if page < total then
		documentFrame.next:Enable();
	end

	local text = TRP3_API.script.parseArgs(pages[page] and pages[page].TX or "", documentFrame.parentArgs);

	setFrameHTML(text);
	documentFrame.current = page;
end

local function showDocumentClass(document, documentID, parentArgs)
	documentFrame:Hide();

	documentFrame.ID = documentID;
	documentFrame.class = document;
	documentFrame.parentArgs = parentArgs;

	if document.BT == true then
		documentFrame.bTile:Show();
		documentFrame.bTile:SetTexture(TRP3_API.ui.frame.getTiledBackground(document.BCK or 8), true, true);
		documentFrame.bNotTile:Hide();
	else
		documentFrame.bNotTile:Show();
		documentFrame.bNotTile:SetTexture(TRP3_API.ui.frame.getTiledBackground(document.BCK or 8));
		documentFrame.bTile:Hide();
	end

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

	loadPage(1);

	documentFrame:Show();

	setFrameSize(document.WI or 450, document.HE or 600);

	if documentFrame.ID then
		if document.LI and document.LI.OO and document.SC and document.SC[document.LI.OO] then
			local retCode = TRP3_API.script.executeClassScript(document.LI.OO, documentFrame.class.SC, {
				object = parentArgs.object
			}, documentFrame.ID);
		end
	end
end
TRP3_API.extended.document.showDocumentClass = showDocumentClass;

local function showDocument(documentID, parentArgs)
	local document = getClass(documentID);
	if document == TRP3_DB.missing then
		Utils.message.displayMessage(loc.DOC_UNKNOWN_ALERT, Utils.message.type.ALERT_MESSAGE);
	else
		showDocumentClass(document, documentID, parentArgs);
	end
end
TRP3_API.extended.document.showDocument = showDocument;

local function onLinkClicked(self, url)
	if documentFrame.ID and documentFrame.class then
		local document = documentFrame.class;
		local parentArgs = documentFrame.parentArgs;
		if document.SC and document.SC[url] then
			local retCode = TRP3_API.script.executeClassScript(url, document.SC, {
				object = parentArgs.object
			}, documentFrame.ID);
		else
			TRP3_API.Ellyb.Popups:OpenURL(url, loc.UI_LINK_WARNING);
		end
	end
end

local function closeDocumentFrame(parentArgs)
	documentFrame:Hide();
	if documentFrame.ID and documentFrame.class then
		local document = documentFrame.class;
		local parentArgs = documentFrame.parentArgs;
		if document.LI and document.LI.OC and document.SC and document.SC[document.LI.OC] then
			local retCode = TRP3_API.script.executeClassScript(document.LI.OC, document.SC, {
				object = parentArgs.object
			}, documentFrame.ID);
		end
	end
end

local function closeDocument(parentArgs)
	if documentFrame:IsVisible() then
		closeDocumentFrame(parentArgs);
	end
end
TRP3_API.extended.document.closeDocument = closeDocument;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

function TRP3_API.extended.document.onStart()
	documentFrame.Resize.resizableFrame = documentFrame;

	-- Customize HTML
	HTMLFrame:SetScript("OnHyperlinkClick", onLinkClicked);

	setTooltipForSameFrame(documentFrame.next, "BOTTOM", 0, -5, loc.DO_PAGE_NEXT);
	setTooltipForSameFrame(documentFrame.previous, "BOTTOM", 0, -5, loc.DO_PAGE_PREVIOUS);
	documentFrame.next:SetText(">");
	documentFrame.previous:SetText("<");
	documentFrame.previous:SetScript("OnClick", function() loadPage(documentFrame.current - 1); end);
	documentFrame.next:SetScript("OnClick", function() loadPage(documentFrame.current + 1); end);
	documentFrame.Close:SetScript("OnClick", function() closeDocumentFrame(); end);

	-- Effect and operands
	TRP3_API.script.registerEffects({
		document_show = {
			secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
			method = function(structure, cArgs, eArgs)
				local documentID = cArgs[1];
				eArgs.LAST = showDocument(documentID, eArgs);
			end,
		},

		document_close = {
			secured = TRP3_API.security.SECURITY_LEVEL.HIGH,
			method = function(structure, cArgs, eArgs)
				eArgs.LAST = closeDocument(eArgs);
			end,
		}
	});

	TRP3_API.ui.frame.setupMove(documentFrame);
end
