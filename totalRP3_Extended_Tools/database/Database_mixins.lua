local _, addon = ...
local loc = TRP3_API.loc;

TRP3_Tools_FilterTabsMixin = {};

function TRP3_Tools_FilterTabsMixin:OnActivate(tab, data)
	if data.filter then
		addon.database.setFilter(data.filter, tab.Text:GetText());
	elseif data.newFilterDummy then
		addon.modal:ShowModal(
			TRP3_API.popup.DB_FILTER, 
			{addon.database.suggestFilterName(), {}, false, function(accepted, filterName, filterConditions, persistent) 
				if accepted then
					addon.database.addFilter(filterName, filterConditions, persistent);
				else
					addon.database.resetNewFilterTab();
				end
			end}
		);
	end
end

function TRP3_Tools_FilterTabsMixin:OnRightClick(tab, data)
	if data.editable then
		TRP3_MenuUtil.CreateContextMenu(tab, function(_, contextMenu)
			contextMenu:CreateTitle(data.name);

			local applyOption = contextMenu:CreateButton("Apply", function()
				tab.tabBar:Activate(tab);
			end);
			TRP3_MenuUtil.SetElementTooltip(applyOption, "Apply this filter");

			local editOption = contextMenu:CreateButton("Edit", function()
				addon.modal:ShowModal(
					TRP3_API.popup.DB_FILTER, 
					{data.name, data.filterConditions, data.persistent, function(accepted, filterName, filterConditions, persistent) 
						if accepted then
							addon.database.updateFilter(tab, filterName, filterConditions, persistent);
						end
					end}
				);
			end);
			TRP3_MenuUtil.SetElementTooltip(editOption, "Edit this filter");

			contextMenu:CreateDivider();
			local deleteOption = contextMenu:CreateButton("Delete", function()
				tab.tabBar:CloseRequest(tab);
			end);
			TRP3_MenuUtil.SetElementTooltip(deleteOption, "Delete this filter");			
			
		end);
	end
end

function TRP3_Tools_FilterTabsMixin:CloseRequest(tab, data)
	if data.persistent then
		TRP3_API.popup.showConfirmPopup(("Are you sure you want to permanently delete the filter [%s]?"):format(data.name), function()
			addon.database.removeFilter(tab, data);
		end);
	else
		addon.database.removeFilter(tab, data);
	end
end

TRP3_Tools_CreationsListElementMixin = {};

function TRP3_Tools_CreationsListElementMixin:Initialize(data)
	self.data = data;
	
	if data.isMine then
		self.creator:SetText(TRP3_API.Colors.White("You"));
	else
		self.creator:SetText(data.creator:gsub("-.*", "")); -- character name without realm
	end
	
	if data.creationId == data.absoluteId then
		self.link:SetText(data.link);
		if data.type == TRP3_DB.types.ITEM then
			self.typeIcon:SetTexture("Interface\\GossipFrame\\VendorGossipIcon");
		elseif data.type == TRP3_DB.types.CAMPAIGN then
			self.typeIcon:SetTexture("Interface\\GossipFrame\\CampaignAvailableQuestIcon");
		else
			self.typeIcon:SetTexture();
		end
	else
		self.link:SetText(data.link .. " |TInterface\\\MONEYFRAME\\Arrow-Left-Down:20:20|t " .. data.creationLink);
		self.typeIcon:SetTexture();
	end
		
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, data.link, data.tooltip);
end

function TRP3_Tools_CreationsListElementMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
	if self.data.type == TRP3_DB.types.ITEM then
		local class = TRP3_API.extended.getClass(self.data.absoluteId);
		TRP3_API.inventory.showItemTooltip(self, {id = self.data.absoluteId}, class, true, "ANCHOR_RIGHT");
	end
end

function TRP3_Tools_CreationsListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
	TRP3_ItemTooltip:Hide();
end

function TRP3_Tools_CreationsListElementMixin:OnClick(button)
	if button == "LeftButton" then
		addon.main.openDraft(self.data.creationId, false, {objectId = self.data.absoluteId});
	elseif button == "RightButton" then
		TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
			contextMenu:CreateTitle(self.data.link);

			local openOption = contextMenu:CreateButton("Open", function()
				addon.main.openDraft(self.data.creationId, false, {objectId = self.data.absoluteId});
			end);
			TRP3_MenuUtil.SetElementTooltip(openOption, "Open element...");

			if addon.main.findDraft(self.data.creationId) then
				local openNewOption = contextMenu:CreateButton("Open in new tab", function()
					addon.main.openDraft(self.data.creationId, true, {objectId = self.data.absoluteId});
				end);
				TRP3_MenuUtil.SetElementTooltip(openNewOption, "Open element in new tab...");
			end

			if TRP3_API.extended.isObjectMine(self.data.creationId) or TRP3_API.extended.isObjectExchanged(self.data.creationId) then
				local securityOption = contextMenu:CreateButton(loc.SEC_LEVEL_DETAILS, function()
					TRP3_API.security.showSecurityDetailFrame(self.data.creationId);
				end);
				TRP3_MenuUtil.SetElementTooltip(securityOption, loc.DB_SECURITY_TT);
			end

			if self.data.type == TRP3_DB.types.ITEM then
				local class = TRP3_API.extended.getClass(self.data.absoluteId);
				local addItemOption = contextMenu:CreateButton(loc.DB_ADD_ITEM, function()
					TRP3_API.popup.showNumberInputPopup(loc.DB_ADD_COUNT:format(self.data.link), function(inputValue)
						TRP3_API.inventory.addItem(nil, self.data.absoluteId, {count = inputValue or 1, madeBy = class.BA and class.BA.CR});
					end, nil, 1);
				end);
				local addItemEnabled = TRP3_API.extended.isObjectMine(self.data.creationId) or (class.BA and not class.BA.PA);
				addItemOption:SetEnabled(addItemEnabled);
				if addItemEnabled then
					TRP3_MenuUtil.SetElementTooltip(addItemOption, loc.DB_ADD_ITEM_TT);
				else
					TRP3_MenuUtil.SetElementTooltip(addItemOption, loc.DB_ADD_ITEM_TT .. "|n|nThe creator of this item doesn't want you to add this item manually to your bag.");
				end
			end
			
			if ChatEdit_GetActiveWindow() and (self.data.type == TRP3_DB.types.ITEM or self.data.type == TRP3_DB.types.CAMPAIGN) then
				local linkOption = contextMenu:CreateButton("Create chat link", function() 
					if self.data.type == TRP3_DB.types.ITEM then
						TRP3_API.ChatLinks:OpenMakeImportablePrompt(loc.CL_EXTENDED_ITEM, function(canBeImported)
							TRP3_API.extended.ItemsChatLinksModule:InsertLink(self.data.absoluteId, self.data.creationId, {}, canBeImported);
						end);
					elseif self.data.type == TRP3_DB.types.CAMPAIGN then
						TRP3_API.ChatLinks:OpenMakeImportablePrompt(loc.CL_EXTENDED_CAMPAIGN, function(canBeImported)
							TRP3_API.extended.CampaignsChatLinksModule:InsertLink(self.data.absoluteId, self.data.creationId, canBeImported);
						end);
					end				
				end);
				TRP3_MenuUtil.SetElementTooltip(linkOption, "inserts link to this item into your current chat"); -- TODO
			end

			local copyOption = contextMenu:CreateButton(loc.EDITOR_ID_COPY, function() 
				TRP3_API.popup.showTextInputPopup(loc.EDITOR_ID_COPY_POPUP, nil, nil, self.data.absoluteId);
			end);
			TRP3_MenuUtil.SetElementTooltip(copyOption, loc.DB_COPY_ID_TT);

			if self.data.type == TRP3_DB.types.ITEM then
				local innerCopyOption = contextMenu:CreateButton(loc.IN_INNER_COPY_ACTION, function()
					local class = TRP3_API.extended.getClass(self.data.absoluteId);
					addon.clipboard.clear();
					addon.clipboard.append(class, class.TY, self.data.absoluteId, select(2, addon.utils.splitId(self.data.absoluteId)));
				end);
				TRP3_MenuUtil.SetElementTooltip(innerCopyOption, loc.DB_COPY_TT);
			end
			
			if self.data.creationId == self.data.absoluteId then
				local copyOption = contextMenu:CreateButton("Create a copy", function()
					addon.database.copyCreation(self.data.creationId);
				end);
				TRP3_MenuUtil.SetElementTooltip(copyOption, "Inserts a copy of the object into the database");
				
				local exportOption = contextMenu:CreateButton(loc.DB_EXPORT, function()
					addon.database.serializeCreation(self.data.creationId);
				end);
				TRP3_MenuUtil.SetElementTooltip(exportOption, loc.DB_EXPORT_TT_2);
				
				local fullExportOption = contextMenu:CreateButton(loc.DB_FULL_EXPORT, function() 
					addon.database.exportCreation(self.data.creationId);
				end);
				TRP3_MenuUtil.SetElementTooltip(fullExportOption, loc.DB_FULL_EXPORT_TT);
				
				if TRP3_API.extended.isObjectMine(self.data.creationId) or TRP3_API.extended.isObjectExchanged(self.data.creationId) then
					contextMenu:CreateDivider()
					local deleteOption = contextMenu:CreateButton(DELETE, function()
						local _, name = addon.main.getClassDataSafeByType(TRP3_API.extended.getClass(self.data.creationId));
						TRP3_API.popup.showConfirmPopup(loc.DB_REMOVE_OBJECT_POPUP:format(self.data.creationId, name or UNKNOWN), function()
							addon.database.removeCreation(self.data.creationId);
						end);
					end);
					TRP3_MenuUtil.SetElementTooltip(deleteOption, loc.DB_DELETE_TT);
				end
			end
			
		end);
	end
end

TRP3_Tools_CreationsActionsMixin = {};

function TRP3_Tools_CreationsActionsMixin:Initialize()
	
	self.blankItem:SetScript("OnClick", function()
		local itemID, _ = TRP3_API.extended.tools.createItem(TRP3_API.extended.tools.getBlankItemData(TRP3_DB.modes.EXPERT));
		addon.main.openDraft(itemID);
	end);

	self.containerItem:SetScript("OnClick", function()
		local itemID, _ = TRP3_API.extended.tools.createItem(TRP3_API.extended.tools.getContainerItemData());
		addon.main.openDraft(itemID);
	end);

	self.documentItem:SetScript("OnClick", function()
		local generatedID = TRP3_API.utils.str.id();
		local itemID, _ = TRP3_API.extended.tools.createItem(TRP3_API.extended.tools.getDocumentItemData(generatedID), generatedID);
		addon.main.openDraft(itemID);
	end);

	self.auraItem:SetScript("OnClick", function()
		local generatedID = TRP3_API.utils.str.id();
		local itemID, _ = TRP3_API.extended.tools.createItem(TRP3_API.extended.tools.getAuraItemData(generatedID), generatedID);
		addon.main.openDraft(itemID);
	end);

	self.blankCampaign:SetScript("OnClick", function()
		local generatedID = TRP3_API.utils.str.id();
		local campaignID, _ = TRP3_API.extended.tools.createCampaign(TRP3_API.extended.tools.getCampaignData(generatedID), generatedID);
		addon.main.openDraft(campaignID);
	end);

	self.import:SetScript("OnClick", function()
		TRP3_ToolFrame.database.import.content.scroll.text:SetText("");
		TRP3_ToolFrame.database.import:Show();
	end);

	self.importFull:SetScript("OnClick", function()
		if C_AddOns.IsAddOnLoaded("totalRP3_Extended_ImpExport") then
			if TRP3_Extended_ImpExport.object then
				local version = TRP3_Extended_ImpExport.version;
				local ID = TRP3_Extended_ImpExport.id;
				local data = TRP3_Extended_ImpExport.object;
				local displayVersion = TRP3_API.utils.str.sanitizeVersion(TRP3_Extended_ImpExport.display_version);
				local link = TRP3_API.inventory.getItemLink(data);
				local by = data.MD.CB;
				local objectVersion = data.MD.V or 0;
				local type = addon.main.getTypeLocale(data.TY);
				TRP3_API.popup.showConfirmPopup(loc.DB_IMPORT_FULL_CONFIRM:format(type, link, by, objectVersion), function()
					C_Timer.After(0.25, function()
						addon.database.importCreation(version, ID, data, displayVersion);
					end);
				end);
			else
				TRP3_API.utils.message.displayMessage(loc.DB_IMPORT_EMPTY, 2);
			end
		else
			TRP3_API.utils.message.displayMessage(loc.DB_EXPORT_MODULE_NOT_ACTIVE, 2);
		end
	end);

	self.hardsave:SetScript("OnClick", function()
		ReloadUI();
	end);

	self.credits:SetScript("OnClick", function()
		addon.main.openCredits();
	end);
	
end

local paramaterPoolCollection = CreateFramePoolCollection();

local function getWidget(template, frameType)
	paramaterPoolCollection:GetOrCreatePool(frameType, nil, template);
	return paramaterPoolCollection:Acquire(template);
end

TRP3_Tools_FilterBuilderListElementMixin = {};

function TRP3_Tools_FilterBuilderListElementMixin:Initialize(data)
	self.data = data;
	self.open:SetShown(self.data.open);
	self.close:SetShown(self.data.close);
	self.delete:SetShown(self.data.canDelete);
	self.logicalOperatorButton:SetShown(self.data.index > 1);
	if data.predicate[1] == "OR" then
		self.logicalOperatorButton:SetText(loc.OP_OR);
	else
		self.logicalOperatorButton:SetText(loc.OP_AND);
	end
	self.widgets = self.widgets or {};
	TRP3_API.ui.listbox.setupListBox(
		self.predicate, 
		addon.database.filters.getPredicateMenu(), 
		function(predicateId)
			if predicateId then
				local formalPredicate = addon.database.filters.getPredicateById(predicateId);
				local op = self.data.predicate[1];
				if predicateId ~= self.data.predicate[2] then
					wipe(self.data.predicate);
					for index, parameter in ipairs(formalPredicate.parameters) do
						self.data.predicate[2+index] = parameter.default;
					end
				end
				self.data.predicate[1] = op;
				self.data.predicate[2] = predicateId;
				if self.data.spawnNewPredicate then
					self.data.list:AddPredicate();
				else
					for index, widget in ipairs(self.widgets) do
						paramaterPoolCollection:Release(widget);
					end
					wipe(self.widgets);
					local prev = self.predicate;
					for index, parameter in ipairs(formalPredicate.parameters) do
						local parameterWidget;
						if parameter.values then
							parameterWidget = getWidget("TRP3_Tools_TitledDropdownButtonTemplate", "DropdownButton");
							TRP3_API.ui.listbox.setupListBox(parameterWidget, parameter.dropdownValues);
							parameterWidget:SetSelectedValue(self.data.predicate[2+index]);
						else
							parameterWidget = getWidget("TRP3_Tools_TitledHelpEditBoxTemplate", "EditBox");
							parameterWidget:SetText(self.data.predicate[2+index]);
						end
						table.insert(self.widgets, parameterWidget);
						parameterWidget:SetParent(self);
						parameterWidget:SetPoint("LEFT", prev, "RIGHT", 10, 0);
						parameterWidget:SetWidth(150);
						parameterWidget:Show();
						prev = parameterWidget;
					end
				end
			end
		end, 
		"(select condition)"
	);
	self.predicate:SetSelectedValue(data.predicate[2]);
end

function TRP3_Tools_FilterBuilderListElementMixin:ToggleLogicalOperator()
	if self.data.predicate[1] == "OR" then
		self.data.predicate[1] = "AND";
	else
		self.data.predicate[1] = "OR";
	end
	self.data.list:Refresh();
end

function TRP3_Tools_FilterBuilderListElementMixin:OnDelete()
	self.data.list:DeleteIndex(self.data.index);
end

function TRP3_Tools_FilterBuilderListElementMixin:Reset()
	local predicateId = self.predicate:GetSelectedValue();
	self.data.predicate[2] = predicateId;
	if self.widgets then
		for index, widget in ipairs(self.widgets) do
			if predicateId then
				local parameter = addon.database.filters.getPredicateById(predicateId).parameters[index];
				if parameter then
					if parameter.values then
						self.data.predicate[2+index] = widget:GetSelectedValue();
					else
						self.data.predicate[2+index] = widget:GetText();
					end
				end
			end
			paramaterPoolCollection:Release(widget);
		end
		wipe(self.widgets);
	end
end

TRP3_Tools_FilterBuilderMixin = {};

function TRP3_Tools_FilterBuilderMixin:Initialize()
	addon.main.localize(self);
	TRP3_API.popup.DB_FILTER = "db_filter";
	TRP3_API.popup.POPUPS[TRP3_API.popup.DB_FILTER] = {
		frame = self,
		showMethod = function(filterName, filterConditions, persistent, callback)
			self.callback = callback;
			self:Open(filterName, filterConditions, persistent);
		end,
	};
end

function TRP3_Tools_FilterBuilderMixin:Open(filterName, filterConditions, persistent)
	self.filter = {};
	self.doApply = false;
	TRP3_API.utils.table.copy(self.filter, filterConditions);
	table.insert(self.filter, {"AND"});
	self.name:SetText(filterName or "");
	self.persistent:SetChecked(persistent);
	self:Refresh(true);
end

function TRP3_Tools_FilterBuilderMixin:Refresh(resetScrollPercentage)
	local scrollPct = resetScrollPercentage and 0 or self.content.list.widget:GetScrollPercentage();
	self.content.list.model:Flush();
	local listItems = {};
	local orStart;
	local hasAnd = false;
	for index, predicate in ipairs(self.filter) do
		table.insert(listItems, {
			index     = index,
			predicate = predicate,
			list      = self,
			canDelete = index < #self.filter or predicate[2] ~= nil
		});
		if index > 1 then
			if predicate[1] == "OR" then
				orStart = orStart or (index-1);
			elseif predicate[1] == "AND" then
				hasAnd = true;
				if orStart then
					listItems[orStart].open = true;
					listItems[index-1].close = true;
					orStart = nil;
				end
			end
		end
	end
	if hasAnd and orStart then
		listItems[orStart].open = true;
		listItems[#listItems].close = true;
	end
	listItems[#listItems].spawnNewPredicate = true;
	self.content.list.model:InsertTable(listItems);
	self.content.list.widget:SetScrollPercentage(scrollPct);
end

function TRP3_Tools_FilterBuilderMixin:AddPredicate()
	table.insert(self.filter, {"AND"});
	self:Refresh();
end

function TRP3_Tools_FilterBuilderMixin:DeleteIndex(index)
	table.remove(self.filter, index);
	self:Refresh();
end

function TRP3_Tools_FilterBuilderMixin:Apply()
	self.content.list.model:Flush();
	if not self.filter[#self.filter][2] then
		table.remove(self.filter);
	end
	self.doApply = true;
	self:Hide();
end

function TRP3_Tools_FilterBuilderMixin:Cancel()
	self:Hide();
end

function TRP3_Tools_FilterBuilderMixin:OnHide()
	if self.callback then
		self.callback(self.doApply, strtrim(self.name:GetText()), self.filter, self.persistent:GetChecked());
	end
end
