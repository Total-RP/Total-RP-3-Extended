local _, addon = ...

local loc = TRP3_API.loc;

TRP3_Tools_EditorQuestMixin = CreateFromMixins(TRP3_Tools_EditorObjectMixin);

function TRP3_Tools_EditorQuestMixin:Initialize()

	self.main.description:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);
	self.objective.sharedObjectiveEditor.text:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);

	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.main.icon, "RIGHT", 0, 5, "Quest icon", loc.EDITOR_ICON_SELECT);
	self.main.icon:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.ICONS, {function(icon) 
				self.main.icon.Icon:SetTexture("Interface\\ICONS\\" .. icon);
				self.main.icon.selectedIcon = icon;
			end, 
			nil, 
			nil, 
			self.main.icon.selectedIcon});
	end);
	
end

function TRP3_Tools_EditorQuestMixin:ClassToInterface(class, creationClass, cursor)
	local BA = class.BA or TRP3_API.globals.empty;

	self.main.name:SetText(BA.NA or "");
	self.main.description:SetText(BA.DE or "");
	self.main.auto:SetChecked(BA.IN or false);
	self.main.progress:SetChecked(BA.PR or false);
	self.main.icon.Icon:SetTexture("Interface\\ICONS\\" .. (BA.IC or "TEMP"));
	self.main.icon.selectedIcon = BA.IC;

	local objectives = {};
	for objectiveId, objectiveData in pairs(class.OB or TRP3_API.globals.empty) do
		table.insert(objectives, {
			ID = objectiveId,
			TX = objectiveData.TX,
			AA = objectiveData.AA,
		});
	end
	table.sort(objectives, function(a, b) return a.ID < b.ID; end);
	table.insert(objectives, {
		isAddButton = true
	});
	
	self.objective.list.model:Flush();
	self.objective.list.model:InsertTable(objectives);
	self.objective.sharedObjectiveEditor:Hide();
end

function TRP3_Tools_EditorQuestMixin:InterfaceToClass(targetClass, targetCursor)
	self:SaveActiveObjectiveIndex();

	targetClass.BA = targetClass.BA or {};
	targetClass.BA.NA = TRP3_API.utils.str.emptyToNil(strtrim(self.main.name:GetText()));
	targetClass.BA.DE = TRP3_API.utils.str.emptyToNil(strtrim(self.main.description:GetText()));
	targetClass.BA.IC = self.main.icon.selectedIcon;
	targetClass.BA.IN = self.main.auto:GetChecked();
	targetClass.BA.PR = self.main.progress:GetChecked();
	
	targetClass.OB = targetClass.OB or {};
	wipe(targetClass.OB);
	for _, objectiveData in self.objective.list.model:EnumerateEntireRange() do
		if not objectiveData.isAddButton and objectiveData.ID then
			targetClass.OB[objectiveData.ID] = {
				TX = objectiveData.TX,
				AA = objectiveData.AA,
			};
		end
	end

	
end

function TRP3_Tools_EditorQuestMixin:ListObjectives()
	local OB = {};
	for _, objectiveData in self.objective.list.model:EnumerateEntireRange() do
		if not objectiveData.isAddButton and objectiveData.ID then
			OB[objectiveData.ID] = {
				TX = objectiveData.TX,
				AA = objectiveData.AA,
			};
		end
	end
	return OB;
end

function TRP3_Tools_EditorQuestMixin:SaveActiveObjectiveIndex()
	for index, data in self.objective.list.model:EnumerateEntireRange() do
		if data.active then
			self.objective.list.model:ReplaceAtIndex(index, data);
			break;
		end
	end
end

function TRP3_Tools_EditorQuestMixin:SetActiveObjectiveIndex(index)
	for objectiveIndex, objectiveData in self.objective.list.model:EnumerateEntireRange() do
		if objectiveData.active then
			objectiveData.active = nil;
			self.objective.list.model:ReplaceAtIndex(objectiveIndex, objectiveData);
			break;
		end
	end
	local data = self.objective.list.model:Find(index);
	if data and not data.isAddButton then
		data.active = true;
		self.objective.list.model:ReplaceAtIndex(index, data);
		self.objective.list.widget:ScrollToElementDataIndex(index);
	end
end

function TRP3_Tools_EditorQuestMixin:AddObjective()
	local numElements = self.objective.list.model:GetSize();
	local proposedIndex = numElements;
	local proposedId = ("objective%02d"):format(proposedIndex);
	while self.objective.list.model:FindByPredicate(function(e) return e.ID == proposedId; end) do
		proposedIndex = proposedIndex + 1;
		proposedId = ("objective%02d"):format(proposedIndex);
	end
	local newObjective = {
		ID = proposedId
	};
	self.objective.list.model:InsertAtIndex(newObjective, numElements);
	self:SetActiveObjectiveIndex(numElements)
end

function TRP3_Tools_EditorQuestMixin:DeleteObjectiveAtIndex(index)
	self.objective.list.model:RemoveIndex(index);
end

TRP3_Tools_QuestObjectiveListElementMixin = {};

function TRP3_Tools_QuestObjectiveListElementMixin:Initialize(data)
	self.data = data;
	self:Refresh();
end

function TRP3_Tools_QuestObjectiveListElementMixin:Refresh()
	local tooltipTitle;
	local tooltipText;
	local editor = addon.editor.getCurrentPropertiesEditor().objective.sharedObjectiveEditor;
	if self.data.isAddButton then
		self.id:Show();
		self.id:SetText("|TInterface\\PaperDollInfoFrame\\Character-Plus:16:16|t " .. loc.QE_OBJ_ADD);
		self.text:Hide();
		self.delete:Hide();

		tooltipTitle = loc.QE_OBJ_ADD;
		tooltipText = TRP3_API.FormatShortcutWithInstruction("LCLICK", loc.QE_OBJ_ADD);
		self.editor = nil;
	elseif self.data.active then
		self.id:Hide();
		self.text:Hide();
		self.delete:Show();

		self.editor = editor;
		self.editor:SetParent(self);
		self.editor:SetAllPoints();
		self.editor.id:SetText(self.data.ID or "");
		self.editor.text:SetText(self.data.TX or "");
		self.editor.auto:SetChecked(self.data.AA == true);
		
		self.editor:Show();
	else
		self.id:Show();
		local idText;
		if self.data.ID then
			idText = self.data.ID;
		else
			idText = addon.script.formatters.unknown("id");
		end
		if self.data.AA then
			idText = idText .. " |cFF00FF00(" .. loc.QE_OBJ_AUTO .. ")|r";
		end
		self.id:SetText(idText);
		self.text:Show();
		self.text:SetText(self.data.TX or addon.script.formatters.unknown(loc.QE_OBJ_TEXT));
		self.delete:Show();

		tooltipTitle = loc.QE_OBJ_SINGULAR;
		if self.data.ID then
			tooltipText	= "";
		else
			tooltipText = "|cFFFF0000This objective won't be saved unless an id is specified.|r|n|n";
		end
		tooltipText = 
			tooltipText .. 
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "edit objective") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("RCLICK", "more options")
		;
		self.editor = nil;
	end
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, tooltipTitle, tooltipText);
end

function TRP3_Tools_QuestObjectiveListElementMixin:GetElementExtent(data)
	if data.active then
		return 144
	elseif data.isAddButton then
		return 36
	else
		return 60;
	end
end

function TRP3_Tools_QuestObjectiveListElementMixin:Reset()
	if self.editor then
		self.data.ID = TRP3_API.utils.str.emptyToNil(strtrim(self.editor.id:GetText()));
		self.data.TX = TRP3_API.utils.str.emptyToNil(strtrim(self.editor.text:GetText()));
		self.data.AA = self.editor.auto:GetChecked();
		self.editor:SetParent(nil);
		self.editor:Hide();
		self.editor = nil;
	end
end

function TRP3_Tools_QuestObjectiveListElementMixin:OnClick(button)
	local questEditor = addon.editor.getCurrentPropertiesEditor();
	local objectiveIndex = questEditor.objective.list.model:FindIndex(self.data);
	if self.data.isAddButton then
		questEditor:AddObjective();
	elseif button == "LeftButton" and not self.data.active then
		questEditor:SetActiveObjectiveIndex(objectiveIndex);
	elseif button == "RightButton" and not self.data.active then
		TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
			contextMenu:CreateTitle(loc.QE_OBJ_SINGULAR);
			
			local editOption = contextMenu:CreateButton("Edit", function()
				questEditor:SetActiveObjectiveIndex(objectiveIndex);
			end);
			TRP3_MenuUtil.SetElementTooltip(editOption, "Edit objective");

			contextMenu:CreateDivider();
			local deleteOption = contextMenu:CreateButton(DELETE, function()
				questEditor:DeleteObjectiveAtIndex(objectiveIndex);
			end);
		end);

	end
end

function TRP3_Tools_QuestObjectiveListElementMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_QuestObjectiveListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end

function TRP3_Tools_QuestObjectiveListElementMixin:OnDelete()
	local questEditor = addon.editor.getCurrentPropertiesEditor();
	local objectiveIndex = questEditor.objective.list.model:FindIndex(self.data);
	questEditor:DeleteObjectiveAtIndex(objectiveIndex);
end
