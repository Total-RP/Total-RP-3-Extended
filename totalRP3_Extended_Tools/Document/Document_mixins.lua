local _, addon = ...

local loc = TRP3_API.loc;

local MIN_TOOLBAR_BUTTON_WIDTH = 50;
local MAX_TOOLBAR_BUTTON_WIDTH = 120;

TRP3_Tools_EditorDocumentMixin = CreateFromMixins(TRP3_Tools_EditorObjectMixin);

function TRP3_Tools_EditorDocumentMixin:OnSizeChanged()
	-- custom adaptive toolbar layout, don't tell meorawr
	local toolbarWidthAvailable = self.pages.toolbar:GetWidth() - 10;
	local numButtons = self.pages.toolbar:GetNumChildren();
	local maxButtonsPerLine = math.floor(toolbarWidthAvailable / MIN_TOOLBAR_BUTTON_WIDTH);
	local minLinesRequired = math.ceil(numButtons / maxButtonsPerLine);
	local actButtonsPerLine = math.ceil(numButtons / minLinesRequired);
	local actButtonWidth = math.min(MAX_TOOLBAR_BUTTON_WIDTH, toolbarWidthAvailable/actButtonsPerLine);

	local buttons = {self.pages.toolbar:GetChildren()};
	for index, button in ipairs(buttons) do
		button:ClearAllPoints();
		button:SetWidth(actButtonWidth);
		button:SetPoint("TOPLEFT", 5 + ((index-1) % actButtonsPerLine) * actButtonWidth, -(7 + math.floor((index-1)/actButtonsPerLine) * button:GetHeight()));
	end
	self.pages.toolbar:SetHeight(12 + minLinesRequired*buttons[1]:GetHeight());
end

function TRP3_Tools_EditorDocumentMixin:Initialize()
	
	local display = self.display;
	local pages = self.pages;
	
	-- Background
	display.background:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.BACKGROUNDS, {function(imageInfo) self.BCK = imageInfo and imageInfo.id or 8; end, nil, nil, self.BCK or 8});
	end);

	-- Border
	TRP3_API.ui.listbox.setupListBox(display.border, {
		{loc.DO_PAGE_BORDER_1, TRP3_API.extended.document.BorderType.PARCHMENT},
	});

	display.h1_font.title:SetText(loc.DO_PAGE_FONT:format("H1"));
	display.h2_font.title:SetText(loc.DO_PAGE_FONT:format("H2"));
	display.h3_font.title:SetText(loc.DO_PAGE_FONT:format("H3"));
	display.p_font.title:SetText(loc.DO_PAGE_FONT:format("P"));

	local getFontStructure = function(h)
		return {
			{"DestinyFontHuge", "DestinyFontHuge"},
			{"QuestFont_Huge", "QuestFont_Huge"},
			{"GameFontNormalLarge", "GameFontNormalLarge"},
			{"GameTooltipHeader", "GameTooltipHeader"},
		};
	end

	TRP3_API.ui.listbox.setupListBox(display.h1_font, getFontStructure("H1"));
	TRP3_API.ui.listbox.setupListBox(display.h2_font, getFontStructure("H2"));
	TRP3_API.ui.listbox.setupListBox(display.h3_font, getFontStructure("H3"));
	TRP3_API.ui.listbox.setupListBox(display.p_font, getFontStructure("P"));
	
	TRP3_API.ui.text.setupToolbar(pages.toolbar, pages.editor.scroll.text, TRP3_ToolFrame, "CENTER", "CENTER");
	
	display.importBook:SetScript("OnClick", function()
		self:ImportItemTextFrame();
	end);

	pages.editor:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);

	-- TODO this is repetition of TRP3_API.ui.text.setupToolbar in totalRP3\Core\UITools.lua,
	-- consider consolidating it
	local function textElementCallback(parent, widget, textElement)
		local function addElement(alignmentQualifier)
			widget:Insert(("{%1$s%2$s}%3$s{/%1$s}"):format(textElement:lower(), alignmentQualifier, loc.REG_PLAYER_ABOUT_T1_YOURTEXT));
		end
		TRP3_MenuUtil.CreateContextMenu(parent, function(_, menu)
			if textElement == "P" then
				menu:CreateTitle(loc.REG_PLAYER_ABOUT_P);
			else
				menu:CreateTitle(loc.REG_PLAYER_ABOUT_HEADER);
			end
			menu:CreateButton(loc.CM_LEFT,   addElement, ""); -- TODO not sure why p isn't selectable in the original
			menu:CreateButton(loc.CM_CENTER, addElement, ":c");
			menu:CreateButton(loc.CM_RIGHT,  addElement, ":r");
		end);
		widget:SetFocus();
	end
	pages.editor:AddTextControl("H1", function(button, widget)
		textElementCallback(button, widget, "H1");
	end);
	pages.editor:AddTextControl("H2", function(button, widget)
		textElementCallback(button, widget, "H2");
	end);
	pages.editor:AddTextControl("H3", function(button, widget)
		textElementCallback(button, widget, "H3");
	end);
	pages.editor:AddTextControl("P", function(button, widget)
		textElementCallback(button, widget, "P");
	end);
	pages.editor:AddTextControl(loc.CM_IMAGE, function(button, widget)
		addon.modal:ShowModal(TRP3_API.popup.IMAGES, {function(image)
			local tag = ("{img:%s:%s:%s}"):format(image.url, math.min(image.width, 512), math.min(image.height, 512));
			widget:Insert(tag);
			widget:SetFocus();
		end});
	end);
	pages.editor:AddTextControl(loc.CM_ICON, function(button, widget)
		addon.modal:ShowModal(TRP3_API.popup.ICONS, {function(icon)
			local tag = ("{icon:%s:25}"):format(icon);
			widget:Insert(tag);
			widget:SetFocus();
		end});
	end);
	pages.editor:AddTextControl(loc.CM_COLOR, function(button, widget)
		addon.modal:ShowModal(TRP3_API.popup.COLORS, {function(red, green, blue)
			local tag = ("{col:%s}{/col}"):format(TRP3_API.CreateColorFromBytes(red, green, blue):GenerateHexColorOpaque());
			widget:Insert(tag);
			widget:SetFocus();
		end});
	end);
	
	pages.editor:AddTextControl(loc.CM_LINK, function(button, widget)
		local tag = ("{link*%s*%s}"):format(loc.UI_LINK_URL, loc.UI_LINK_TEXT);
		widget:Insert(tag);
		widget:SetFocus();
	end);
	
	addon.utils.prepareForMultiSelectionMode(self.display.list);

end

function TRP3_Tools_EditorDocumentMixin:ClassToInterface(class, creationClass, cursor)
	self.display.border:SetSelectedValue(class.BO or TRP3_API.extended.document.BorderType.PARCHMENT);
	self.display.height:SetText(class.HE or "600");
	self.display.width:SetText(class.WI or "450");
	self.display.h1_font:SetSelectedValue(class.H1_F or "DestinyFontHuge");
	self.display.h2_font:SetSelectedValue(class.H2_F or "QuestFont_Huge");
	self.display.h3_font:SetSelectedValue(class.H3_F or "GameFontNormalLarge");
	self.display.p_font:SetSelectedValue(class.P_F or "GameTooltipHeader");
	self.display.tile:SetChecked(class.BT or false);
	self.display.resizable:SetChecked(class.FR or false);

	self.BCK = class.BCK or 8;
	self:ClassToPages(class);
	if cursor and cursor.page and self.display.list.model:Find(cursor.page) then
		self:ShowPage(cursor.page);
	else
		self:ShowPage(1);
	end
end

function TRP3_Tools_EditorDocumentMixin:InterfaceToClass(targetClass, targetCursor)

	self:SaveCurrentPage();

	targetClass.BO = self.display.border:GetSelectedValue() or TRP3_API.extended.document.BorderType.PARCHMENT;
	targetClass.HE = tonumber(self.display.height:GetText()) or 600;
	targetClass.WI = tonumber(self.display.width:GetText()) or 450;
	targetClass.H1_F = self.display.h1_font:GetSelectedValue() or "DestinyFontHuge";
	targetClass.H2_F = self.display.h2_font:GetSelectedValue() or "QuestFont_Huge";
	targetClass.H3_F = self.display.h3_font:GetSelectedValue() or "GameFontNormalLarge";
	targetClass.P_F = self.display.p_font:GetSelectedValue() or "GameTooltipHeader";
	targetClass.BT = self.display.tile:GetChecked();
	targetClass.FR = self.display.resizable:GetChecked();

	targetClass.BCK = self.BCK or 8;
	self:PagesToClass(targetClass);
	if targetCursor then
		targetCursor.page = self.display.list.model:FindByPredicate(function(e) return e.active; end);
	end
end

function TRP3_Tools_EditorDocumentMixin:ClassToPages(class)
	local list = self.display.list;
	local pages = {};
	if class.PA and TableHasAnyEntries(class.PA) then
		for index, page in ipairs(class.PA) do
			table.insert(pages, {
				active = index == 1,
				page = {TX = page.TX}
			});
		end
	else
		table.insert(pages, {
			active = true,
			page = {TX = ""}
		});
	end

	table.insert(pages, {
		isAddButton = true
	});

	--local scrollPct = list.widget:GetScrollPercentage();
	list.model:Flush();
	list.model:InsertTable(pages);
	--list.widget:SetScrollPercentage(0);
	
end

function TRP3_Tools_EditorDocumentMixin:PagesToClass(targetClass)
	targetClass.PA = targetClass.PA or {};
	wipe(targetClass.PA);
	for index, element in self.display.list.model:EnumerateEntireRange() do
		if element.page then
			table.insert(targetClass.PA, {
				TX = element.page.TX
			});
		end
	end
end

function TRP3_Tools_EditorDocumentMixin:SaveCurrentPage()
	local index, element = self.display.list.model:FindByPredicate(function(e) return e.active; end);
	if element and element.page then
		element.page.TX = self.pages.editor.scroll.text:GetText();
	end
end

function TRP3_Tools_EditorDocumentMixin:ShowPage(pageIndex)
	local list = self.display.list;
	for index, element in list.model:EnumerateEntireRange() do
		element.active = element.page ~= nil and index == pageIndex;
	end
	list.widget:ScrollToElementDataIndex(pageIndex);
	list:Refresh();
	local elementToShow = list.model:Find(pageIndex);
	if elementToShow.page then
		self.pages.editor.scroll.text:SetText(elementToShow.page.TX or "");
	else
		self.pages.editor.scroll.text:SetText("");
	end
	self.pages.editor.scroll.text:SetFocus();
end

function TRP3_Tools_EditorDocumentMixin:AddPage(targetIndex, page, noUpdate)
	local list = self.display.list;
	targetIndex = targetIndex or list.model:GetSize();
	list.model:InsertAtIndex({
		page = page or {TX = ""}
	}, targetIndex);
	if noUpdate then
		return
	end
	self:ShowPage(targetIndex);
end

function TRP3_Tools_EditorDocumentMixin:DeletePage(pageElement)
	local list = self.display.list;
	local pageIndex = list.model:FindIndex(pageElement);
	if pageIndex then
		list.model:RemoveIndex(pageIndex);
		
		if list.model:GetSize() <= 1 then
			list.model:InsertAtIndex({page = {TX = ""}}, 1);
		end
		if pageElement.active then
			self:ShowPage(math.max(pageIndex-1, 1));
		else
			list:Refresh();
		end
	end
end

function TRP3_Tools_EditorDocumentMixin:DeleteSelectedPages()
	local list = self.display.list;
	local pages = {};
	local pageIndex;
	for index, element in list.model:EnumerateEntireRange() do
		if element.page then
			if not element.selected then
				table.insert(pages, element);
			elseif element.active then
				pageIndex = #pages;
			end
		end
	end
	if TableIsEmpty(pages) then
		table.insert(pages, {
			page = {TX = ""}
		});
	end

	table.insert(pages, {
		isAddButton = true
	});

	list.model:Flush();
	list.model:InsertTable(pages);
	pageIndex = math.max(1, pageIndex or list.model:FindByPredicate(function(e) return e.active; end) or 1);
	self:ShowPage(pageIndex);
end

function TRP3_Tools_EditorDocumentMixin:ImportItemTextFrame()
	if ItemTextFrame:IsShown() then
		self:SaveCurrentPage();
		local list = self.display.list;
		if list.model:GetSize() == 2 and list.model:Find(1).page.TX == nil or list.model:Find(1).page.TX == "" then
			list.model:RemoveIndex(1);
		end
		local insertIndex = list.model:GetSize();
		local currPage = ItemTextGetPage();
		for i = 1,currPage-1 do
			ItemTextPrevPage();
		end
		if ItemTextGetItem() ~= nil and ItemTextGetItem() ~= "" then
			list.model:InsertAtIndex({
				page = {TX = "{h1:c}" .. (ItemTextGetItem() or "") .. "{/h1}\n" .. ItemTextGetText()}
			}, insertIndex);
		else
			list.model:InsertAtIndex({
				page = {TX = ItemTextGetText()}
			}, insertIndex);
		end
		insertIndex = insertIndex + 1;
		while ItemTextHasNextPage() do
			ItemTextNextPage();
			list.model:InsertAtIndex({
				page = {TX = ItemTextGetText()}
			}, insertIndex);
			insertIndex = insertIndex + 1;
		end
		self:ShowPage(insertIndex - 1);
	else
		TRP3_API.utils.message.displayMessage("Please open the object from which you want to import text.", 4);
	end
end

TRP3_Tools_DocumentPageListElementMixin = {};

function TRP3_Tools_DocumentPageListElementMixin:Initialize(element)
	self.element = element;
	self:Refresh();
end

function TRP3_Tools_DocumentPageListElementMixin:Refresh()
	local tooltipTitle;
	local tooltipText;
	if self.element.isAddButton then
		self.label:SetText("|TInterface\\PaperDollInfoFrame\\Character-Plus:16:16|t " .. loc.DO_PAGE_ADD);
		self:SetActive(false);
		self:SetSelected(false);
		self.delete:Hide();
		tooltipTitle = loc.DO_PAGE_ADD;
		tooltipText = TRP3_API.FormatShortcutWithInstruction("LCLICK", loc.DO_PAGE_ADD);
	elseif self.element.page then
		self.label:SetText("Page " .. self:GetElementDataIndex());
		self:SetActive(self.element.active);
		self:SetSelected(self.element.selected);
		self.delete:Show();
		tooltipTitle = "Page " .. self:GetElementDataIndex();
		tooltipText = 
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "edit page") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("RCLICK", "more options") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("SHIFT-CLICK", "select range") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("CTRL-CLICK", "select this page")
		;
	end
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, tooltipTitle, tooltipText);
end

function TRP3_Tools_DocumentPageListElementMixin:SetActive(active)
	self:SetHighlight(active);
	self.highlightArrow:SetShown(active);
	self.delete:SetPoint("RIGHT", active and -24 or -8, 0);
end

function TRP3_Tools_DocumentPageListElementMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_DocumentPageListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end

function TRP3_Tools_DocumentPageListElementMixin:OnClick(button)
	local documentEditor = addon.editor.getCurrentPropertiesEditor();
	local pageIndex = self:GetElementDataIndex();
	
	if self.element.isAddButton then
		if button == "LeftButton" and not IsModifierKeyDown() then
			documentEditor:SaveCurrentPage();
			documentEditor:AddPage(stepIndex);
		end
	elseif button == "LeftButton" then
		if IsControlKeyDown() then
			documentEditor.display.list:ToggleSingleSelect(self.element);
		elseif IsShiftKeyDown() then
			documentEditor.display.list:ToggleRangeSelect(self.element);
		else
			documentEditor:SaveCurrentPage();
			documentEditor:ShowPage(self:GetElementDataIndex());
		end
	elseif button == "RightButton" then
		TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
			contextMenu:CreateTitle("Page " .. pageIndex);
			
			local addBeforeOption = contextMenu:CreateButton("Insert page before", function()
				documentEditor:SaveCurrentPage();
				documentEditor:AddPage(pageIndex);
			end);
			TRP3_MenuUtil.SetElementTooltip(addBeforeOption, "Insert an empty page before this page");

			local addAfterOption = contextMenu:CreateButton("Insert page after", function()
				documentEditor:SaveCurrentPage();
				documentEditor:AddPage(pageIndex + 1);
			end);
			TRP3_MenuUtil.SetElementTooltip(addAfterOption, "Insert an empty page after this page");

			contextMenu:CreateDivider();
			local copyOption = contextMenu:CreateButton("Copy", function()
				addon.clipboard.clear();
				addon.clipboard.append(self.element.page, addon.clipboard.types.DOCUMENT_PAGE);
			end);
			TRP3_MenuUtil.SetElementTooltip(copyOption, "Copy this page");
			if self.element.selected then
				local copySelectionOption = contextMenu:CreateButton("Copy selected pages", function()
					addon.clipboard.clear();
					for index, element in documentEditor.display.list.model:EnumerateEntireRange() do
						if element.selected then
							addon.clipboard.append(element.page, addon.clipboard.types.DOCUMENT_PAGE);
						end
					end
					documentEditor.display.list:SetAllSelected(false);
				end);
				TRP3_MenuUtil.SetElementTooltip(copySelectionOption, "Copy all selected pages");
			end

			if addon.clipboard.isPasteCompatible(addon.clipboard.types.DOCUMENT_PAGE) then
				local count = addon.clipboard.count();

				local beforeText, afterText;
				if count == 1 then
					beforeText = "Paste page before";
					afterText = "Paste page after";
				else
					beforeText = "Paste " .. count .. " pages before";
					afterText = "Paste " .. count .. " pages after";
				end

				local pasteBeforeOption = contextMenu:CreateButton(beforeText, function()
					documentEditor:SaveCurrentPage();
					for index = 1, count do
						documentEditor:AddPage(pageIndex + index - 1, addon.clipboard.retrieve(index), true);
					end
					documentEditor:ShowPage(pageIndex + count - 1);
				end);
				TRP3_MenuUtil.SetElementTooltip(pasteBeforeOption, beforeText);

				local pasteBeforeOption = contextMenu:CreateButton(afterText, function()
					documentEditor:SaveCurrentPage();
					for index = 1, count do
						documentEditor:AddPage(pageIndex + index, addon.clipboard.retrieve(index), true);
					end
					documentEditor:ShowPage(pageIndex + count);
				end);
				TRP3_MenuUtil.SetElementTooltip(pasteBeforeOption, afterText);
			end

			contextMenu:CreateDivider();
			local deleteOption = contextMenu:CreateButton(DELETE, function()
				self:OnDelete();
			end);
			TRP3_MenuUtil.SetElementTooltip(deleteOption, "Delete this page");

			if self.element.selected then
				local deleteSelectionOption = contextMenu:CreateButton("Delete selection", function()
					documentEditor:SaveCurrentPage();
					documentEditor:DeleteSelectedPages();
				end);
				TRP3_MenuUtil.SetElementTooltip(deleteSelectionOption, "Delete all selected pages");
			end
			
		end);
	end
end

function TRP3_Tools_DocumentPageListElementMixin:OnDelete()
	addon.editor.getCurrentPropertiesEditor():SaveCurrentPage();
	addon.editor.getCurrentPropertiesEditor():DeletePage(self.element);
end
