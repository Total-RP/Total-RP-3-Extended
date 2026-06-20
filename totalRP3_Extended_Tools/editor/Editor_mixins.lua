local _, addon = ...
local loc = TRP3_API.loc;

TRP3_Tools_CreationTreeNodeMixin = {}

function TRP3_Tools_CreationTreeNodeMixin:Initialize(node)
	self.node = node;
	self:Refresh();
end

function TRP3_Tools_CreationTreeNodeMixin:Refresh()
	self.link:SetText(self.node.data.link);
	self.icon:SetTexture(self.node.data.icon);
	if TableHasAnyEntries(self.node:GetNodes()) then
		self.toggleChildren:Show();
		if self.node:IsCollapsed() then
			self.toggleChildren.normalTexture:SetTexture("Interface\\Buttons\\UI-PlusButton-UP");
			self.toggleChildren.pushedTexture:SetTexture("Interface\\Buttons\\UI-PlusButton-DOWN");
		else
			self.toggleChildren.normalTexture:SetTexture("Interface\\Buttons\\UI-MinusButton-UP");
			self.toggleChildren.pushedTexture:SetTexture("Interface\\Buttons\\UI-MinusButton-DOWN");
		end
		self.icon:SetPoint("LEFT", 32, 0);
	else
		self.toggleChildren:Hide();
		self.icon:SetPoint("LEFT", 8, 0);
	end
	self:SetActive(self.node.data.active);
	self:SetSelected(self.node.data.selected);

	local tooltipText =
		"Inner id: " .. self.node.data.relativeId .. "|n" ..
		"Type: " .. addon.main.getTypeLocale((addon.editor.getCurrentDraftClass(self.node.data.absoluteId) or TRP3_API.globals.empty).TY or "") .. "|n|n" ..
		TRP3_API.FormatShortcutWithInstruction("LCLICK", "edit object") .. "|n" ..
		TRP3_API.FormatShortcutWithInstruction("RCLICK", "more options") .. "|n" ..
		TRP3_API.FormatShortcutWithInstruction("SHIFT-CLICK", "select range") .. "|n" ..
		TRP3_API.FormatShortcutWithInstruction("CTRL-CLICK", "select this object")
	;

	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, self.node.data.link, tooltipText);
end

function TRP3_Tools_CreationTreeNodeMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_CreationTreeNodeMixin:OnLeave()
	TRP3_MainTooltip:Hide();
	TRP3_ItemTooltip:Hide();
end

function TRP3_Tools_CreationTreeNodeMixin:SetActive(active)
	self:SetHighlight(active);
	self.highlightArrow:SetShown(active);
	self.link:SetPoint("RIGHT", active and -24 or -8, 0);
end

function TRP3_Tools_CreationTreeNodeMixin:OnClick(button)
	if button == "LeftButton" then
		if IsControlKeyDown() then
			self.node.data.selected = not self.node.data.selected;
			addon.editor.refreshObjectTree();
		elseif IsShiftKeyDown() then
			local parent = self.node:GetParent();
			local targetElementIndex;
			for index, n in ipairs(parent:GetNodes()) do
				if n == self.node then
					targetElementIndex = index;
					break;
				end
			end
			if not targetElementIndex then
				return
			end

			local min = math.huge;
			local max = 0;

			for index, node in ipairs(parent:GetNodes()) do
				if node.data.selected and min > index then
					min = index;
				end
				if node.data.selected and max < index then
					max = index;
				end
			end

			if max < min then
				self.node.data.selected = true;
			elseif targetElementIndex < min then
				for index = targetElementIndex, max do
					parent:GetNodes()[index].data.selected = true;
				end
			elseif targetElementIndex > max then
				for index = min, targetElementIndex do
					parent:GetNodes()[index].data.selected = true;
				end
			elseif self.node.data.selected then
				for index = min, max do
					parent:GetNodes()[index].data.selected = false;
				end
			else
				for index = min, max do
					parent:GetNodes()[index].data.selected = true;
				end
			end
			addon.editor.refreshObjectTree();
		elseif not self.node.data.active then
			addon.editor.updateCurrentObjectDraft();
			addon.editor.displayObject(self.node.data.absoluteId);
			addon.editor.refreshObjectTree();
		end
	elseif button == "RightButton" then
		TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
			contextMenu:CreateTitle(("|T%s:16:16|t %s"):format(self.node.data.icon, self.node.data.link));

			local class = addon.editor.getCurrentDraftClass(self.node.data.absoluteId);

			local openOption = contextMenu:CreateButton("Open", function()
				addon.editor.updateCurrentObjectDraft();
				addon.editor.displayObject(self.node.data.absoluteId);
				addon.editor.refreshObjectTree();
			end);
			TRP3_MenuUtil.SetElementTooltip(openOption, "Open element...");

			local openNewOption = contextMenu:CreateButton("Open in new tab", function()
				addon.editor.updateCurrentObjectDraft();
				addon.editor.save();
				local clonedCursor = {};
				TRP3_API.utils.table.copy(clonedCursor, addon.editor.getCurrentDraftCursor());
				clonedCursor.objectId = self.node.data.absoluteId;
				addon.main.openDraft(addon.editor.getCurrentDraftCreationId(), true, clonedCursor);
			end);
			TRP3_MenuUtil.SetElementTooltip(openNewOption, "Open element in new tab...");

			if class.TY == TRP3_DB.types.ITEM then
				local isStored = TRP3_API.extended.classExists(self.node.data.absoluteId);
				local storedClass = isStored and TRP3_API.extended.getClass(self.node.data.absoluteId);
				local addItemOption = contextMenu:CreateButton(loc.DB_ADD_ITEM, function()
					TRP3_API.popup.showNumberInputPopup(loc.DB_ADD_COUNT:format(self.node.data.link), function(inputValue)
						TRP3_API.inventory.addItem(nil, self.node.data.absoluteId, {count = inputValue or 1, madeBy = storedClass.BA and storedClass.BA.CR});
					end, nil, 1);
				end);
				-- TODO check if madeBy should use the BA.CR from the creation instead
				if not isStored then
					addItemOption:SetEnabled(false);
					TRP3_MenuUtil.SetElementTooltip(addItemOption, "Can't add an unsaved item.");
				elseif not TRP3_API.extended.isObjectMine(addon.editor.getCurrentDraftCreationId()) and storedClass.BA and storedClass.BA.PA then
					addItemOption:SetEnabled(false);
					TRP3_MenuUtil.SetElementTooltip(addItemOption, "The creator doesn't want you to add this item manually.");
				else
					addItemOption:SetEnabled(true);
					TRP3_MenuUtil.SetElementTooltip(addItemOption, loc.DB_ADD_ITEM_TT);
				end
			end

			local createInnerOption = contextMenu:CreateButton(loc.IN_INNER_ADD);

			if class.TY == TRP3_DB.types.CAMPAIGN then
				createInnerOption:CreateButton(loc.TYPE_QUEST, function()
					addon.editor.requestInnerObject(self.node.data.absoluteId, TRP3_DB.types.QUEST);
				end);
			end
			if class.TY == TRP3_DB.types.QUEST then
				createInnerOption:CreateButton(loc.TYPE_QUEST_STEP, function()
					addon.editor.requestInnerObject(self.node.data.absoluteId, TRP3_DB.types.QUEST_STEP);
				end);
			end
			createInnerOption:CreateButton(loc.TYPE_ITEM, function()
				addon.editor.requestInnerObject(self.node.data.absoluteId, TRP3_DB.types.ITEM);
			end);
			createInnerOption:CreateButton(loc.TYPE_AURA, function()
				addon.editor.requestInnerObject(self.node.data.absoluteId, TRP3_DB.types.AURA);
			end);
			createInnerOption:CreateButton(loc.TYPE_DOCUMENT, function()
				addon.editor.requestInnerObject(self.node.data.absoluteId, TRP3_DB.types.DOCUMENT);
			end);
			createInnerOption:CreateButton(loc.TYPE_DIALOG, function()
				addon.editor.requestInnerObject(self.node.data.absoluteId, TRP3_DB.types.DIALOG);
			end);

			contextMenu:CreateDivider();

			if self.node:GetDepth() > 1 then
				local renameOption = contextMenu:CreateButton(loc.IN_INNER_ID_ACTION, function()
					TRP3_API.popup.showTextInputPopup(loc.IN_INNER_ID:format(self.node.data.link, self.node.data.relativeId), function(newId)
						newId = TRP3_API.extended.checkID(newId);
						if newId:len() == 0 or newId == self.node.data.relativeId then
							return;
						elseif newId:find(" ") then
							TRP3_API.popup.showAlertPopup(loc.IN_INNER_ENTER_ID_NO_SPACE);
						else
							local success, message = addon.editor.changeRelativeId(self.node.data.absoluteId, newId);
							if not success then
								TRP3_API.utils.message.displayMessage(message, 4);
							end
						end
					end, nil, self.node.data.relativeId);
				end);
				TRP3_MenuUtil.SetElementTooltip(renameOption, loc.IN_INNER_ID_ACTION); -- TODO add a real description
			end

			local copyIdOption = contextMenu:CreateButton(loc.EDITOR_ID_COPY, function()
				TRP3_API.popup.showTextInputPopup(loc.EDITOR_ID_COPY_POPUP, nil, nil, self.node.data.absoluteId);
			end);
			TRP3_MenuUtil.SetElementTooltip(copyIdOption, loc.DB_COPY_ID_TT);

			local copyOption = contextMenu:CreateButton("Copy", function()
				addon.editor.updateCurrentObjectDraft();
				addon.clipboard.clear();
				addon.clipboard.append(class, class.TY, self.node.data.absoluteId, self.node.data.relativeId);
			end);
			TRP3_MenuUtil.SetElementTooltip(copyOption, "Create a copy to insert somewhere else. TODO reword this.");

			if self.node.data.selected then
				contextMenu:CreateButton("Copy selected", function()
					addon.clipboard.clear();
					addon.editor.copySelectedTreeObjects();
				end);
			end

			if addon.clipboard.isReplaceCompatible(class.TY) then
				local pasteOption = contextMenu:CreateButton("Paste here", function()
					TRP3_API.popup.showConfirmPopup(loc.IN_INNER_PASTE_CONFIRM, function()
						addon.editor.replaceCurrentDraftClass(self.node.data.absoluteId, addon.clipboard.retrieveShallow(), addon.clipboard.retrieveId());
					end);
				end);
				TRP3_MenuUtil.SetElementTooltip(pasteOption, "Paste copied content.|nThis will replace any data in here!");
			end

			if addon.clipboard.isInnerCompatible(class.TY) then
				local pasteInnerOption = contextMenu:CreateButton("Paste as inner objects", function()
					local success, message = addon.editor.pasteClipboardAsInnerObjects(self.node.data.absoluteId);
					if not success then
						TRP3_API.utils.message.displayMessage(message, 4);
					end
				end);
				TRP3_MenuUtil.SetElementTooltip(pasteInnerOption, "Paste content as inner objects.");
			end

			if self.node:GetDepth() > 1 then
				contextMenu:CreateDivider();
				local deleteOption = contextMenu:CreateButton(DELETE, function()
					addon.editor.deleteInnerObjectsById(self.node.data.absoluteId);
				end);
				TRP3_MenuUtil.SetElementTooltip(deleteOption, loc.DB_DELETE_TT);

				if self.node.data.selected then
					contextMenu:CreateButton("Delete selected", function()
						addon.editor.deleteSelectedTreeObjects();
					end);
				end
			end
		end);
	end
end

function TRP3_Tools_CreationTreeNodeMixin:OnToggleChildren()
	self.node:ToggleCollapsed();
	addon.editor.refreshObjectTree();
end
