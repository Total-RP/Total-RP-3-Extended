local _, addon = ...
local loc = TRP3_API.loc;

TRP3_Tools_EditorObjectRibbonMixin = {};

local function recalculateLayout(frame, leftIndent, spacing, rightIndent, doFill)
	local prev;
	local count = 0;
	local width = 0;
	for _, child in ipairs{frame:GetChildren()} do
		if child:IsShown() then
			if prev then
				child:SetPoint("LEFT", prev, "RIGHT", spacing, 0);
			else
				child:SetPoint("LEFT", leftIndent, 0);
			end
			prev = child;
			count = count + 1;
			width = width + child:GetWidth();
		end
	end
	if count > 0 then
		if doFill then
			prev:SetPoint("RIGHT", -rightIndent);
		else
			frame:SetWidth(width + leftIndent + rightIndent + (count - 1) * spacing);
		end
		frame:Show();
	else
		frame:Hide();
	end
end

function TRP3_Tools_EditorObjectRibbonMixin:Initialize()
	self.noteButton:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.NOTE_EDITOR, {self.NT, function(note) 
			self:SetNote(note);
		end});
	end);
	self.innerObjectsPanel.QU:SetScale(0.9375);
	self.innerObjectsPanel.ST:SetScale(0.9375);
	self.innerObjectsPanel.IT:SetScale(0.9375);
	self.innerObjectsPanel.AU:SetScale(0.9375);
	self.innerObjectsPanel.DO:SetScale(0.9375);
	self.innerObjectsPanel.DI:SetScale(0.9375);
	self.innerObjectsPanel.QU.Icon:SetTexture("Interface\\ICONS\\achievement_quests_completed_07");
	self.innerObjectsPanel.ST.Icon:SetTexture("Interface\\gossipframe\\incompletequesticon");
	self.innerObjectsPanel.IT.Icon:SetTexture("Interface\\ICONS\\inv_misc_generic_craftingreagent04");
	self.innerObjectsPanel.AU.Icon:SetTexture("Interface\\ICONS\\ability_priest_spiritoftheredeemer");
	self.innerObjectsPanel.DO.Icon:SetTexture("Interface\\ICONS\\inv_inscription_scroll");
	self.innerObjectsPanel.DI.Icon:SetTexture("Interface\\ICONS\\ui_chat");
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.innerObjectsPanel.QU, "BOTTOMRIGHT", 0, 0, loc.IN_INNER_ADD .. ": " .. addon.main.getTypeLocale(TRP3_DB.types.QUEST), loc.IN_INNER_HELP);
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.innerObjectsPanel.ST, "BOTTOMRIGHT", 0, 0, loc.IN_INNER_ADD .. ": " .. addon.main.getTypeLocale(TRP3_DB.types.QUEST_STEP), loc.IN_INNER_HELP);
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.innerObjectsPanel.IT, "BOTTOMRIGHT", 0, 0, loc.IN_INNER_ADD .. ": " .. addon.main.getTypeLocale(TRP3_DB.types.ITEM), loc.IN_INNER_HELP);
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.innerObjectsPanel.AU, "BOTTOMRIGHT", 0, 0, loc.IN_INNER_ADD .. ": " .. addon.main.getTypeLocale(TRP3_DB.types.AURA), loc.IN_INNER_HELP);
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.innerObjectsPanel.DO, "BOTTOMRIGHT", 0, 0, loc.IN_INNER_ADD .. ": " .. addon.main.getTypeLocale(TRP3_DB.types.DOCUMENT), loc.IN_INNER_HELP);
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.innerObjectsPanel.DI, "BOTTOMRIGHT", 0, 0, loc.IN_INNER_ADD .. ": " .. addon.main.getTypeLocale(TRP3_DB.types.DIALOG), loc.IN_INNER_HELP);
	self.innerObjectsPanel.QU:SetScript("OnClick", function() 
		addon.editor.requestInnerObject(addon.editor.getCurrentObjectAbsoluteId(), TRP3_DB.types.QUEST);
	end);
	self.innerObjectsPanel.ST:SetScript("OnClick", function() 
		addon.editor.requestInnerObject(addon.editor.getCurrentObjectAbsoluteId(), TRP3_DB.types.QUEST_STEP);
	end);
	self.innerObjectsPanel.IT:SetScript("OnClick", function() 
		addon.editor.requestInnerObject(addon.editor.getCurrentObjectAbsoluteId(), TRP3_DB.types.ITEM);
	end);
	self.innerObjectsPanel.AU:SetScript("OnClick", function() 
		addon.editor.requestInnerObject(addon.editor.getCurrentObjectAbsoluteId(), TRP3_DB.types.AURA);
	end);
	self.innerObjectsPanel.DO:SetScript("OnClick", function() 
		addon.editor.requestInnerObject(addon.editor.getCurrentObjectAbsoluteId(), TRP3_DB.types.DOCUMENT);
	end);
	self.innerObjectsPanel.DI:SetScript("OnClick", function() 
		addon.editor.requestInnerObject(addon.editor.getCurrentObjectAbsoluteId(), TRP3_DB.types.DIALOG);
	end);

	self.documentPreview:SetScript("OnClick", function()
		local temp = {};
		addon.editor.getCurrentPropertiesEditor():InterfaceToClass(temp);
		TRP3_API.extended.document.showDocumentClass(temp, nil);
	end);

	self.cutscenePreview:SetScript("OnClick", function()
		addon.editor.getCurrentPropertiesEditor():SaveCurrentStep();
		local dialogData = {};
		addon.editor.getCurrentPropertiesEditor():InterfaceToClass(dialogData);
		TRP3_API.extended.dialog.startDialog(nil, dialogData);
	end);
	
	self.auraPreview:SetScript("OnEnter", function()
		addon.editor.getCurrentPropertiesEditor():UpdatePreview(true);
		TRP3_AuraTooltip:Attach(self.auraPreview.aura);
	end);

	self.auraPreview:SetScript("OnLeave", function()
		TRP3_AuraTooltip:Detach(self.auraPreview.aura);
	end);

	self.itemPreview:SetScript("OnEnter", function(self)
		addon.editor.getCurrentPropertiesEditor():UpdatePreview();
		self.item:LockHighlight();
		TRP3_API.inventory.showItemTooltip(self, {madeBy = TRP3_API.globals.player_id}, self.item.class, true);
		
		local containerSize;
		if self.item.class.BA.CT then
			containerSize = self.item.class.CO.SI;
			local durability = "";
			if self.item.class.CO.DU and self.item.class.CO.DU > 0 then
				durability = (TRP3_API.utils.str.texture("Interface\\GROUPFRAME\\UI-GROUP-MAINTANKICON", 15) .. "%s/%s"):format(self.item.class.CO.DU, self.item.class.CO.DU);
			end
			
			for _, bagPreview in pairs({"bag5x4", "bag2x4", "bag1x4"}) do
				TRP3_API.inventory.decorateContainer(self[bagPreview], self.item.class);
				self[bagPreview].DurabilityText:SetText(durability);
				self[bagPreview].WeightText:SetText(TRP3_API.extended.formatWeight(0) .. TRP3_API.utils.str.texture("Interface\\GROUPFRAME\\UI-Group-MasterLooter", 15));
			end
		end
		self.bag5x4:SetShown(containerSize == "5x4");
		self.bag2x4:SetShown(containerSize == "2x4");
		self.bag1x4:SetShown(containerSize == "1x4");
	end);

	self.itemPreview:SetScript("OnLeave", function(self)
		self.item:UnlockHighlight();
		TRP3_ItemTooltip:Hide();
		self.bag5x4:Hide();
		self.bag2x4:Hide();
		self.bag1x4:Hide();
	end);
	
	self.itemPreview.item:SetMouseMotionEnabled(false);
	self.itemPreview.item:SetMouseClickEnabled(false);

	self.itemPreview.item.info = {
		count = 1
	};

	for _, bagPreview in pairs({"bag5x4", "bag2x4", "bag1x4"}) do
		self.itemPreview[bagPreview].close:Disable();
		self.itemPreview[bagPreview].LockIcon:Hide();
	end

	self.actionsPanel.addItem:SetScale(0.9375);
	self.actionsPanel.showVariables:SetScale(0.9375);
	self.actionsPanel.startQuest:SetScale(0.9375);
	self.actionsPanel.unrevealQuest:SetScale(0.9375);
	self.actionsPanel.goToStep:SetScale(0.9375);
	self.actionsPanel.applyAura:SetScale(0.9375);
	
	self.actionsPanel.addItem.Icon:SetTexture("Interface\\ICONS\\garrison_weaponupgrade");
	self.actionsPanel.showVariables.Icon:SetAtlas("GarrMission_MissionIcon-Patrol");
	self.actionsPanel.startQuest.Icon:SetAtlas("common-icon-forwardarrow");
	self.actionsPanel.unrevealQuest.Icon:SetAtlas("common-icon-redx");
	self.actionsPanel.goToStep.Icon:SetAtlas("common-icon-forwardarrow");
	self.actionsPanel.applyAura.Icon:SetAtlas("common-icon-forwardarrow");

	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.actionsPanel.addItem      , "BOTTOMRIGHT", 0, 0, loc.DB_ADD_ITEM     , "Add this item to your inventory.|n|n|cffff9900You can do this because this is your own object.|r");
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.actionsPanel.showVariables, "BOTTOMRIGHT", 0, 0, "Variable inspector", "Show all variables currently stored in this object.|n|n|cffff9900You can do this because this is your own object.|r");
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.actionsPanel.startQuest   , "BOTTOMRIGHT", 0, 0, "Start quest"       , "Start or restart this quest.|n|n|cffff9900You can do this because this is your own object.|r");
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.actionsPanel.unrevealQuest, "BOTTOMRIGHT", 0, 0, "Unreveal quest"    , "Reset the quest to \"not revealed\" state.|n|n|cffff9900You can do this because this is your own object.|r");
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.actionsPanel.goToStep     , "BOTTOMRIGHT", 0, 0, "Go to this step"   , "Sets this step as the current quest step.|n|n|cffff9900You can do this because this is your own object.|r");
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.actionsPanel.applyAura    , "BOTTOMRIGHT", 0, 0, "Apply aura"        , "Apply this aura to your current profile.|n|n|cffff9900You can do this because this is your own object.|r");

	self.actionsPanel.addItem:SetScript("OnClick", function()
		if TRP3_API.extended.classExists(addon.editor.getCurrentObjectAbsoluteId()) then
			local creationClass = TRP3_API.extended.getClass(addon.editor.getCurrentDraftCreationId());
			local _ , link = addon.utils.getObjectIconAndLink(addon.editor.getCurrentDraftClass());
			TRP3_API.popup.showNumberInputPopup(loc.DB_ADD_COUNT:format(link), function(inputValue)
				TRP3_API.inventory.addItem(nil, addon.editor.getCurrentObjectAbsoluteId(), {count = inputValue or 1, madeBy = creationClass.BA and creationClass.BA.CR});
			end, nil, 1);		
		else
			TRP3_API.utils.message.displayMessage("The item cannot be added because it hasn't been saved.", 4);
		end
	end);
	self.actionsPanel.showVariables:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.VARIABLE_INSPECTOR, {addon.editor.getCurrentObjectAbsoluteId(), addon.editor.getCurrentDraftClass().TY});
	end);
	self.actionsPanel.startQuest:SetScript("OnClick", function()
		if TRP3_API.extended.classExists(addon.editor.getCurrentObjectAbsoluteId()) then
			TRP3_API.quest.startQuest(addon.editor.getCurrentDraftCreationId(), addon.editor.getCurrentObjectRelativeId());
		else
			TRP3_API.utils.message.displayMessage("The quest cannot be started because it hasn't been saved.", 4);
		end
	end);
	self.actionsPanel.unrevealQuest:SetScript("OnClick", function()
		local campaignId = addon.editor.getCurrentDraftCreationId();
		local questLog   = TRP3_API.quest.getQuestLog()[campaignId];
		local questId    = addon.editor.getCurrentObjectRelativeId();
		if questLog and questLog.QUEST then
			if questLog.QUEST[questId] and questLog.QUEST[questId].CS then
				TRP3_API.quest.clearStepHandlers(TRP3_API.extended.getFullID(campaignId, questId, questLog.QUEST[questId].CS));
			end
			TRP3_API.quest.clearQuestHandlers(TRP3_API.extended.getFullID(campaignId, questId));
			questLog.QUEST[questId] = nil;
		end
		TRP3_Extended:TriggerEvent(TRP3_Extended.Events.CAMPAIGN_REFRESH_LOG); -- unreveal is not part of the API
	end);
	self.actionsPanel.goToStep:SetScript("OnClick", function()
		local absoluteId = addon.editor.getCurrentObjectAbsoluteId();
		if TRP3_API.extended.classExists(absoluteId) then
			local questAbsoluteId, stepId = addon.utils.splitId(absoluteId);
			local campaignId, questId = addon.utils.splitId(questAbsoluteId);
			local questLog = TRP3_API.quest.getQuestLog()[campaignId];
			if not questLog or not questLog.QUEST or not questLog.QUEST[questId] then
				TRP3_API.quest.startQuest(campaignId, questId);
			end
			if questLog and questLog.QUEST and questLog.QUEST[questId] then
				TRP3_API.quest.goToStep(campaignId, questId, stepId);
			end
		else
			TRP3_API.utils.message.displayMessage("The quest step cannot be activated because it hasn't been saved.", 4);
		end
	end);
	self.actionsPanel.applyAura:SetScript("OnClick", function()
		local absoluteId = addon.editor.getCurrentObjectAbsoluteId();
		if TRP3_API.extended.classExists(absoluteId) then
			TRP3_API.extended.auras.apply(absoluteId);
		else
			TRP3_API.utils.message.displayMessage("The aura cannot be activated because it hasn't been saved.", 4);
		end
	end);

end

function TRP3_Tools_EditorObjectRibbonMixin:ClassToInterface(class)
	self.title:SetText(addon.main.getTypeLocale(class.TY));
	self.id:SetText(addon.editor.getCurrentObjectRelativeId());
	self.innerObjectsPanel.QU:SetShown(class.TY == TRP3_DB.types.CAMPAIGN);
	self.innerObjectsPanel.ST:SetShown(class.TY == TRP3_DB.types.QUEST);
	self.documentPreview:SetShown(class.TY == TRP3_DB.types.DOCUMENT);
	self.cutscenePreview:SetShown(class.TY == TRP3_DB.types.DIALOG);
	self.auraPreview:SetShown(class.TY == TRP3_DB.types.AURA);
	self.itemPreview:SetShown(class.TY == TRP3_DB.types.ITEM);
	self:SetNote(class.NT);

	if TRP3_API.extended.isObjectMine(addon.editor.getCurrentDraftCreationId()) then
		self.actionsPanel.showVariables:SetShown(class.TY == TRP3_DB.types.CAMPAIGN or class.TY == TRP3_DB.types.AURA or class.TY == TRP3_DB.types.ITEM);
		self.actionsPanel.startQuest:SetShown(class.TY == TRP3_DB.types.QUEST);
		self.actionsPanel.unrevealQuest:SetShown(class.TY == TRP3_DB.types.QUEST);
		self.actionsPanel.goToStep:SetShown(class.TY == TRP3_DB.types.QUEST_STEP);
		self.actionsPanel.applyAura:SetShown(class.TY == TRP3_DB.types.AURA);
		self.actionsPanel.addItem:SetShown(class.TY == TRP3_DB.types.ITEM);
	else
		self.actionsPanel.showVariables:Hide();
		self.actionsPanel.startQuest:Hide();
		self.actionsPanel.unrevealQuest:Hide();
		self.actionsPanel.goToStep:Hide();
		self.actionsPanel.applyAura:Hide();
		self.actionsPanel.addItem:Hide();
	end
	recalculateLayout(self.innerObjectsPanel, 8, 6, -2);
	recalculateLayout(self.actionsPanel, 8, 6, 4);
	recalculateLayout(self, 160, 2, 2, true);
	
end

function TRP3_Tools_EditorObjectRibbonMixin:InterfaceToClass(class)
	class.NT = self.NT;
end

function TRP3_Tools_EditorObjectRibbonMixin:SetNote(note)
	self.NT = TRP3_API.utils.str.emptyToNil(strtrim(note or ""));
	if self.NT then
		self.noteButton.text:SetText(TRP3_API.Colors.Yellow(loc.EDITOR_NOTES .. ": ") .. self.NT);
	else
		self.noteButton.text:SetText(TRP3_API.Colors.Yellow(loc.EDITOR_NOTES .. ": ") .. TRP3_API.Colors.Grey("(click to add notes)"));
	end
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.noteButton, "BOTTOMRIGHT", 0, 0, loc.EDITOR_NOTES, 
		(self.NT or "") .. "\n\n" ..
		TRP3_API.FormatShortcutWithInstruction("LCLICK", "edit free notes")
	);
end

function TRP3_Tools_EditorObjectRibbonMixin:SetAuraPreview(aura)
	self.auraPreview.aura:SetAuraAndShow(aura);
	self.auraPreview.aura:SetAuraTexts(nil, aura.class.BA.OV);
end

function TRP3_Tools_EditorObjectRibbonMixin:SetItemPreview(itemClass)
	self.itemPreview.item.class = itemClass;
	TRP3_API.inventory.containerSlotUpdate(self.itemPreview.item);
end
