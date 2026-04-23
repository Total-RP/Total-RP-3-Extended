local _, addon = ...

local loc = TRP3_API.loc;
local DEFAULT_BG = "Interface\\DRESSUPFRAME\\DressUpBackground-NightElf1";

local function newStep()
	return {
		TX = "Text."
	};
end

TRP3_Tools_EditorCutsceneMixin = CreateFromMixins(TRP3_Tools_EditorObjectMixin);

function TRP3_Tools_EditorCutsceneMixin:Initialize()

	TRP3_API.ui.listbox.setupListBox(self.step.directionValue, {
		{loc.CM_LEFT, "LEFT"},
		{loc.CM_RIGHT, "RIGHT"},
		{loc.REG_RELATION_NONE, "NONE"}
	});

	self.step.text:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);

	self.step.backgroundBrowse:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.IMAGES, {function(image)
			self.step.backgroundValue:SetText(image.url);
		end});
	end);

	self.step.imageBrowse:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.IMAGES, {function(image)
			self.step.imageValue:SetText(image.url);
		end});
	end);

	self.step.leftUnitTarget:SetScript("OnClick", function()
		if TRP3_API.utils.str.getUnitNPCID("target") then
			self.step.leftUnitValue:SetText(TRP3_API.utils.str.getUnitNPCID("target"));
		end
	end);

	self.step.rightUnitTarget:SetScript("OnClick", function()
		if TRP3_API.utils.str.getUnitNPCID("target") then
			self.step.rightUnitValue:SetText(TRP3_API.utils.str.getUnitNPCID("target"));
		end
	end);

	self.step.direction:SetScript("OnClick", function()
		self.step.directionValue:SetShown(self.step.direction:GetChecked());
	end);

	self.step.name:SetScript("OnClick", function()
		self.step.nameValue:SetShown(self.step.name:GetChecked());
	end);
	self.step.nameValue:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);
	
	self.step.background:SetScript("OnClick", function()
		self.step.backgroundBrowse:SetShown(self.step.background:GetChecked());
		self.step.backgroundValue:SetShown(self.step.background:GetChecked());
	end);
	
	self.step.image:SetScript("OnClick", function()
		self.step.imageBrowse:SetShown(self.step.image:GetChecked());
		self.step.imageValue:SetShown(self.step.image:GetChecked());
		self.step.imageMore:SetShown(self.step.image:GetChecked());
	end);

	self.step.leftUnit:SetScript("OnClick", function()
		self.step.leftUnitTarget:SetShown(self.step.leftUnit:GetChecked());
		self.step.leftUnitValue:SetShown(self.step.leftUnit:GetChecked());
	end);
	
	self.step.rightUnit:SetScript("OnClick", function()
		self.step.rightUnitTarget:SetShown(self.step.rightUnit:GetChecked());
		self.step.rightUnitValue:SetShown(self.step.rightUnit:GetChecked());
	end);

	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.step.imageMore, "BOTTOMRIGHT", 0, 0, loc.EDITOR_MORE);
	self.step.imageMore:SetScript("OnClick", function()
		if self.step.imageEditor:IsVisible() then
			self.step.imageEditor:Hide();
		else
			self.step.imageEditor.ArrowLEFT:SetPoint("LEFT", self.step.imageEditor, "RIGHT", 3, -60);
			TRP3_API.ui.frame.configureHoverFrame(self.step.imageEditor, self.step.imageMore, "RIGHT", -10, 60);
		end
	end);

	addon.utils.prepareForMultiSelectionMode(self.main.list);
	
	TRP3_API.ui.listbox.setupListBox(self.step.workflow, {{"(no workflow)", ""}});

	TRP3_Tools_EditorCutsceneChoicePopup:Initialize();
	self.step.choices:SetScript("OnClick", function()
		local index, element = self.main.list.model:FindByPredicate(function(e) return e.active; end);
		if element then
			self:SaveCurrentStep();
			addon.modal:ShowModal(TRP3_API.popup.CUTSCENE_CHOICE, {element.step.CH, function(CH)
				element.step.CH = CH;
				self:ShowStep(index);
			end});
		end
	end);

end

function TRP3_Tools_EditorCutsceneMixin:ClassToInterface(class, creationClass, cursor)
	local BA = class.BA or TRP3_API.globals.empty;
	self.main.distance:SetText(BA.DI or "0");

	local steps = {};
	for _, step in ipairs(class.DS) do
		local copy = {};
		TRP3_API.utils.table.copy(copy, step);
		table.insert(steps, {step = copy});
	end
	if TableIsEmpty(steps) then
		table.insert(steps, {step = newStep()});
	end
	table.insert(steps, {isAddButton = true});
	self.main.list.model:Flush();
	self.main.list.model:InsertTable(steps);
	self.main.alternate:SetChecked(cursor and cursor.alternate);
	self.deferShowStep = true; -- wait for the OnScriptsChanged from the scripts frame to load workflow ids, then show first step
	self.cursor = cursor;
end

function TRP3_Tools_EditorCutsceneMixin:InterfaceToClass(targetClass, targetCursor)
	self:SaveCurrentStep();
	targetClass.BA = targetClass.BA or {};
	targetClass.BA.DI = tonumber(strtrim(self.main.distance:GetText())) or 0;
	targetClass.DS = targetClass.DS or {};
	wipe(targetClass.DS);
	for _, element in self.main.list.model:EnumerateEntireRange() do
		if element.step then
			local copy = {};
			TRP3_API.utils.table.copy(copy, element.step);
			table.insert(targetClass.DS, copy);
		end
	end
	if targetCursor then
		targetCursor.stepIndex = self.main.list.model:FindByPredicate(function(e) return e.active; end);
		targetCursor.alternate = self.main.alternate:GetChecked();
	end
end

function TRP3_Tools_EditorCutsceneMixin:OnScriptsChanged(changes)
	local scriptMap = {};
	local scriptListWithNoneOption = {};
	for _, script in pairs(changes) do
		if script.newId then
			table.insert(scriptListWithNoneOption, {script.newId, script.newId});
			if script.oldId then
				scriptMap[script.oldId] = script.newId;
			end
		end
	end
	table.insert(scriptListWithNoneOption, {"(no workflow)", ""});
	TRP3_API.ui.listbox.setupListBox(self.step.workflow, scriptListWithNoneOption);

	self:SaveCurrentStep();

	for _, element in self.main.list.model:EnumerateEntireRange() do
		if element.step and element.step.WO then
			element.step.WO = scriptMap[element.step.WO];
		end
	end

	if self.deferShowStep then
		if self.cursor and self:StepExists(self.cursor.stepIndex) then
			self:ShowStep(self.cursor.stepIndex);
		else
			self:ShowStep(1);
		end
		self.deferShowStep = nil;
	else
		local index, element = self.main.list.model:FindByPredicate(function(e) return e.active; end);
		if element then
			self:ShowStep(index);
		end
	end
end

function TRP3_Tools_EditorCutsceneMixin:CountScriptReferences(scriptId)
	self:SaveCurrentStep();
	local count = 0;
	for _, element in self.main.list.model:EnumerateEntireRange() do
		if element.step and element.step.WO == scriptId then
			count = count + 1;
		end
	end
	return count;
end

function TRP3_Tools_EditorCutsceneMixin:SaveCurrentStep()
	local index, element = self.main.list.model:FindByPredicate(function(e) return e.active; end);
	if element and element.step then
		self.step.imageEditor:Hide();
		element.step.TX = TRP3_API.utils.str.emptyToNil(strtrim(self.step.text:GetText()));
		element.step.LO = self.step.loot:GetChecked();
		element.step.EP = self.step.endpoint:GetChecked();
		element.step.N  = tonumber(self.step.next:GetText());
		element.step.ND = self.step.direction:GetChecked()  and self.step.directionValue:GetSelectedValue() or nil;
		element.step.NA = self.step.name:GetChecked()       and self.step.nameValue:GetText()               or nil;
		element.step.LU = self.step.leftUnit:GetChecked()   and self.step.leftUnitValue:GetText()           or nil;
		element.step.RU = self.step.rightUnit:GetChecked()  and self.step.rightUnitValue:GetText()          or nil;
		element.step.BG = self.step.background:GetChecked() and self.step.backgroundValue:GetText()         or nil;
		if self.step.image:GetChecked() then
			element.step.IM = {
				UR = self.step.imageValue:GetText(),
				TO = tonumber(self.step.imageEditor.top:GetText()),
				BO = tonumber(self.step.imageEditor.bottom:GetText()),
				LE = tonumber(self.step.imageEditor.left:GetText()),
				RI = tonumber(self.step.imageEditor.right:GetText()),
				WI = tonumber(self.step.imageEditor.width:GetText()),
				HE = tonumber(self.step.imageEditor.height:GetText()),
			};
		else
			element.step.IM = nil;
		end
		element.step.WO = TRP3_API.utils.str.emptyToNil(self.step.workflow:GetSelectedValue());
	end
end

function TRP3_Tools_EditorCutsceneMixin:ShowStep(stepIndex)
	local list = self.main.list;
	for index, element in list.model:EnumerateEntireRange() do
		element.active = index == stepIndex;
	end
	list.widget:ScrollToElementDataIndex(stepIndex);
	list:Refresh();
	local element = list.model:Find(stepIndex);
	if element and element.step then
		self.step.imageEditor:Hide();
		--self.step.title:SetText(("%s: %d"):format(loc.DI_STEP_EDIT, stepIndex));
		self.step.text:SetText(element.step.TX or "");
		self.step.next:SetText(element.step.N or "");
		local numOptions = CountTable(element.step.CH or TRP3_API.globals.empty);
		if numOptions > 0 then
			self.step.choices:SetText(numOptions .. " " .. loc.DI_CHOICES);
		else
			self.step.choices:SetText(loc.DI_CHOICES);
		end
		self.step.loot:SetChecked(element.step.LO or false);
		self.step.endpoint:SetChecked(element.step.EP or false);
		self.step.direction:SetChecked(element.step.ND ~= nil);
		self.step.direction:GetScript("OnClick")();
		self.step.directionValue:SetSelectedValue(element.step.ND or "NONE");
		self.step.name:SetChecked(element.step.NA ~= nil);
		self.step.name:GetScript("OnClick")();
		self.step.nameValue:SetText(element.step.NA or "${trp:player:full}");
		self.step.leftUnit:SetChecked(element.step.LU ~= nil);
		self.step.leftUnit:GetScript("OnClick")();
		self.step.leftUnitValue:SetText(element.step.LU or "player");
		self.step.rightUnit:SetChecked(element.step.RU ~= nil);
		self.step.rightUnit:GetScript("OnClick")();
		self.step.rightUnitValue:SetText(element.step.RU or "target");
		self.step.background:SetChecked(element.step.BG ~= nil);
		self.step.background:GetScript("OnClick")();
		self.step.backgroundValue:SetText(element.step.BG or DEFAULT_BG);
		self.step.image:SetChecked(element.step.IM ~= nil);
		self.step.image:GetScript("OnClick")();
		self.step.imageValue:SetText(element.step.IM and element.step.IM.UR or "");
		self.step.workflow:SetSelectedValue(element.step.WO or "");
		self.step.imageEditor.width:SetText(element.step.IM and element.step.IM.WI or "256");
		self.step.imageEditor.height:SetText(element.step.IM and element.step.IM.HE or "256");
		self.step.imageEditor.top:SetText(element.step.IM and element.step.IM.TO or "0");
		self.step.imageEditor.bottom:SetText(element.step.IM and element.step.IM.BO or "1");
		self.step.imageEditor.left:SetText(element.step.IM and element.step.IM.LE or "0");
		self.step.imageEditor.right:SetText(element.step.IM and element.step.IM.RI or "1");
	end
	self.step.text.scroll.text:SetFocus();
end

function TRP3_Tools_EditorCutsceneMixin:AddStep(targetIndex, step, noUpdate)
	local list = self.main.list;
	targetIndex = targetIndex or list.model:GetSize();

	for _, element in list.model:EnumerateEntireRange() do
		if element.step then
			if element.step.N and element.step.N >= targetIndex then
				element.step.N = element.step.N + 1;
			end
			for _, option in pairs(element.step.CH or TRP3_API.globals.empty) do
				if option.N and option.N >= targetIndex then
					option.N = option.N + 1;
				end
			end
		end
	end

	local stepToAdd = step;
	if not stepToAdd then
		stepToAdd = newStep();
		if self.main.alternate:GetChecked() then
			local directionRefElement;
			if targetIndex > 1 then
				directionRefElement = list.model:Find(targetIndex - 1);
			elseif targetIndex < list.model:GetSize() - 1 then
				directionRefElement = list.model:Find(targetIndex + 1);
			end
			if directionRefElement and directionRefElement.step then
				if directionRefElement.step.ND == "LEFT" then
					stepToAdd.ND = "RIGHT";
				elseif directionRefElement.step.ND == "RIGHT" then
					stepToAdd.ND = "LEFT";
				end
			end

			local nameRefElement;
			if targetIndex > 2 then
				nameRefElement = list.model:Find(targetIndex - 2);
			elseif targetIndex < list.model:GetSize() - 2 then
				nameRefElement = list.model:Find(targetIndex + 2);
			end
			if nameRefElement and nameRefElement.step then
				stepToAdd.NA = nameRefElement.step.NA;
			end
		end
	end

	list.model:InsertAtIndex({step = stepToAdd}, targetIndex);
	if noUpdate then
		return
	end
	self:ShowStep(targetIndex);
end

function TRP3_Tools_EditorCutsceneMixin:DeleteStep(stepElement)
	local list = self.main.list;
	local stepIndex = list.model:FindIndex(stepElement);
	if stepIndex then

		for _, element in list.model:EnumerateEntireRange() do
			if element.step then
				if element.step.N and element.step.N > stepIndex then
					element.step.N = element.step.N - 1;
				elseif element.step.N and element.step.N == stepIndex then
					element.step.N = nil;
				end
				for _, option in pairs(element.step.CH or TRP3_API.globals.empty) do
					if option.N and option.N > stepIndex then
						option.N = option.N - 1;
					elseif option.N and option.N == stepIndex then
						option.N = nil;
					end
				end
			end
		end

		list.model:RemoveIndex(stepIndex);
		if list.model:GetSize() <= 1 then
			list.model:InsertAtIndex({step = newStep()}, 1);
		end
		if stepElement.active then
			self:ShowStep(math.max(stepIndex-1, 1));
		else
			list:Refresh();
		end
	end
end

function TRP3_Tools_EditorCutsceneMixin:DeleteSelectedSteps()
	local list = self.main.list;
	local steps = {};
	local stepIndex;
	local stepIndexMapping = {};
	for index, element in list.model:EnumerateEntireRange() do
		if element.step then
			if not element.selected then
				table.insert(steps, element);
				stepIndexMapping[index] = #steps;
			elseif element.active then
				stepIndex = #steps;
			end
		end
	end
	if TableIsEmpty(steps) then
		table.insert(steps, {step = newStep()});
	end
	table.insert(steps, {isAddButton = true});
	list.model:Flush();
	list.model:InsertTable(steps);

	for _, element in list.model:EnumerateEntireRange() do
		if element.step then
			if element.step.N then
				element.step.N = stepIndexMapping[element.step.N];
			end
			for _, option in pairs(element.step.CH or TRP3_API.globals.empty) do
				if option.N then
					option.N = stepIndexMapping[option.N];
				end
			end
		end
	end

	stepIndex = math.max(1, stepIndex or list.model:FindByPredicate(function(e) return e.active; end) or 1);
	self:ShowStep(stepIndex);
end

function TRP3_Tools_EditorCutsceneMixin:StepExists(stepIndex)
	local element = self.main.list.model:Find(stepIndex);
	return element and (element.step ~= nil);
end

TRP3_Tools_CutsceneStepListElementMixin = {};

function TRP3_Tools_CutsceneStepListElementMixin:Initialize(element)
	self.element = element;
	self:Refresh();
end

function TRP3_Tools_CutsceneStepListElementMixin:Refresh()
	local tooltipTitle;
	local tooltipText;
	if self.element.isAddButton then
		self.icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus");
		self.label:SetText(loc.DI_STEP_ADD);
		self:SetActive(false);
		self:SetSelected(false);
		self.delete:Hide();
		tooltipTitle = loc.DI_STEP_ADD;
		tooltipText = TRP3_API.FormatShortcutWithInstruction("LCLICK", loc.DI_STEP_ADD);
	elseif self.element.step then
		self.label:SetText(("|cff00ff00Step %d:|r |cffffffff%s|r"):format(self:GetElementDataIndex(), self.element.step.TX or ""));

		if self.element.step.CH then
			self.icon:SetTexture("Interface\\GossipFrame\\ActiveLegendaryQuestIcon");
			tooltipTitle = loc.DI_CHOICES;
		elseif self.element.step.EP then
			self.icon:SetTexture("Interface\\GossipFrame\\AvailableLegendaryQuestIcon");
			tooltipTitle = loc.DI_END;
		else
			self.icon:SetTexture("Interface\\GossipFrame\\PetitionGossipIcon");
			tooltipTitle = loc.DI_STEP;
		end

		self:SetActive(self.element.active);
		self:SetSelected(self.element.selected);
		self.delete:Show();

		tooltipText = 
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "edit step") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("RCLICK", "more options") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("SHIFT-CLICK", "select range") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("CTRL-CLICK", "select this step")
		;
	end
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, tooltipTitle, tooltipText);
end

function TRP3_Tools_CutsceneStepListElementMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_CutsceneStepListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end

function TRP3_Tools_CutsceneStepListElementMixin:SetActive(active)
	self:SetHighlight(active);
	self.highlightArrow:SetShown(active);
	self.delete:SetPoint("RIGHT", active and -24 or -8, 0);
end

function TRP3_Tools_CutsceneStepListElementMixin:OnClick(button)
	local cutsceneEditor = addon.editor.getCurrentPropertiesEditor();
	local stepIndex = self:GetElementDataIndex();
	
	if self.element.isAddButton then
		if button == "LeftButton" and not IsModifierKeyDown() then
			cutsceneEditor:SaveCurrentStep();
			cutsceneEditor:AddStep(stepIndex);
		end
	elseif button == "LeftButton" then
		if IsControlKeyDown() then
			cutsceneEditor.main.list:ToggleSingleSelect(self.element);
		elseif IsShiftKeyDown() then
			cutsceneEditor.main.list:ToggleRangeSelect(self.element);
		else
			cutsceneEditor:SaveCurrentStep();
			cutsceneEditor:ShowStep(stepIndex);
		end
	elseif button == "RightButton" then
		TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
			contextMenu:CreateTitle(loc.DI_STEP);
			
			local addBeforeOption = contextMenu:CreateButton("Insert step before", function()
				cutsceneEditor:SaveCurrentStep();
				cutsceneEditor:AddStep(stepIndex);
			end);
			TRP3_MenuUtil.SetElementTooltip(addBeforeOption, "Insert a new step before this step");

			local addAfterOption = contextMenu:CreateButton("Insert step after", function()
				cutsceneEditor:SaveCurrentStep();
				cutsceneEditor:AddStep(stepIndex + 1);
			end);
			TRP3_MenuUtil.SetElementTooltip(addAfterOption, "Insert a new step after this step");

			contextMenu:CreateDivider();
			local copyOption = contextMenu:CreateButton("Copy", function()
				addon.clipboard.clear();
				addon.clipboard.append(self.element.step, addon.clipboard.types.DIALOG_STEP);
			end);
			TRP3_MenuUtil.SetElementTooltip(copyOption, "Copy this step");
			if self.element.selected then
				local copySelectionOption = contextMenu:CreateButton("Copy selected steps", function()
					addon.clipboard.clear();
					for index, element in cutsceneEditor.main.list.model:EnumerateEntireRange() do
						if element.selected then
							addon.clipboard.append(element.step, addon.clipboard.types.DIALOG_STEP);
						end
					end
					cutsceneEditor.main.list:SetAllSelected(false);
				end);
				TRP3_MenuUtil.SetElementTooltip(copySelectionOption, "Copy all selected steps");
			end

			if addon.clipboard.isPasteCompatible(addon.clipboard.types.DIALOG_STEP) then
				local count = addon.clipboard.count();

				local beforeText, afterText;
				if count == 1 then
					beforeText = "Paste step before";
					afterText = "Paste step after";
				else
					beforeText = "Paste " .. count .. " steps before";
					afterText = "Paste " .. count .. " steps after";
				end

				local pasteBeforeOption = contextMenu:CreateButton(beforeText, function()
					for index = 1, count do
						cutsceneEditor:AddStep(stepIndex + index - 1, addon.clipboard.retrieve(index), true);
					end
					cutsceneEditor:ShowStep(stepIndex + count - 1);
				end);
				TRP3_MenuUtil.SetElementTooltip(pasteBeforeOption, beforeText);

				local pasteAfterOption = contextMenu:CreateButton(afterText, function()
					for index = 1, count do
						cutsceneEditor:AddStep(stepIndex + index, addon.clipboard.retrieve(index), true);
					end
					cutsceneEditor:ShowStep(stepIndex + count);
				end);
				TRP3_MenuUtil.SetElementTooltip(pasteAfterOption, afterText);
			end

			contextMenu:CreateDivider();
			local deleteOption = contextMenu:CreateButton(DELETE, function()
				self:OnDelete();
			end);
			TRP3_MenuUtil.SetElementTooltip(deleteOption, "Delete this step");

			if self.element.selected then
				local deleteSelectionOption = contextMenu:CreateButton("Delete selection", function()
					cutsceneEditor:SaveCurrentStep();
					cutsceneEditor:DeleteSelectedSteps();
				end);
				TRP3_MenuUtil.SetElementTooltip(deleteSelectionOption, "Delete all selected steps");
			end
			
		end);
	end
end

function TRP3_Tools_CutsceneStepListElementMixin:OnDelete()
	addon.editor.getCurrentPropertiesEditor():SaveCurrentStep();
	addon.editor.getCurrentPropertiesEditor():DeleteStep(self.element);
end

TRP3_Tools_EditorCutsceneChoiceMixin = {};

function TRP3_Tools_EditorCutsceneChoiceMixin:Initialize()
	self.choiceData = {};
	for index = 1, 5 do
		table.insert(self.choiceData, {constraint = {}});
	end
	self.optionEditor.text:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);
	self.optionEditor.constraint:SetScriptContext(function() 
		return nil, nil;
	end);
	self.optionEditor.title:SetRotation(math.pi/2); -- not possible to do in XML
	
	self.applyButton:SetScript("OnClick", function() 
		self:OpenOption(0); -- will update whatever option is opened
		local choices = {};
		for index, option in ipairs(self.choiceData) do
			if option.text then
				table.insert(choices, {
					TX = option.text,
					N  = option.next,
					C  = addon.script.getSaveFormatConstraintData(option.constraint)
				});
			end
		end
		if TableIsEmpty(choices) then
			choices = nil;
		end
		self:Hide();
		self.callback(choices);
	end);
	addon.main.localize(self);
	TRP3_API.popup.CUTSCENE_CHOICE = "cutscene_choice";
	TRP3_API.popup.POPUPS[TRP3_API.popup.CUTSCENE_CHOICE] = {
		frame = self,
		showMethod = function(choiceData, callback)
			self:OpenForChoice(choiceData, callback);
		end,
	};
end

function TRP3_Tools_EditorCutsceneChoiceMixin:OpenForChoice(choiceData, callback)
	for index, option in ipairs(self.choiceData) do
		option.next = nil;
		option.text = nil;
		option.constraint = {};
		if choiceData and choiceData[index] then
			option.next = choiceData[index].N;
			option.text = choiceData[index].TX;
			option.constraint = addon.script.getNormalizedConstraintData(choiceData[index].C or TRP3_API.globals.empty);
		end
	end
	self.callback = callback;
	self.optionIndex = 0;
	self:OpenOption(0);
	self:Open();
end

function TRP3_Tools_EditorCutsceneChoiceMixin:OpenOption(optionIndex)
	if self.choiceData[self.optionIndex] then
		self.choiceData[self.optionIndex].text = TRP3_API.utils.str.emptyToNil(strtrim(self.optionEditor.text:GetText()));
		self.choiceData[self.optionIndex].next = tonumber(self.optionEditor.next:GetText());
		self.optionEditor.constraint:Unlink();
	end
	self.optionEditor:SetShown(optionIndex > 0); -- careful, ScrollBoxListLinearView may behave strange when using :Show()/:Hide() too often
	self.optionIndex = optionIndex;
	for index, option in ipairs(self.choiceData) do
		local optionFrame = self["option" .. index];
		if self.optionIndex == index then
			optionFrame:SetHeight(200);
			optionFrame.button:Hide();
			self.optionEditor.constraint:LinkWithConstraint(option.constraint);
			self.optionEditor:SetParent(optionFrame);
			self.optionEditor:SetAllPoints();
			self.optionEditor.text:SetText(option.text or "");
			self.optionEditor.next:SetText(option.next or "");
		else
			if option.text then
				if TableHasAnyEntries(option.constraint) then
					optionFrame.button.text:SetText("|cFF00FF00[Conditional]|r " .. option.text);
				else
					optionFrame.button.text:SetText(option.text);
				end
				if not option.next then
					optionFrame.button.next:SetText("|TInterface\\\MONEYFRAME\\Arrow-Right-Down:16:16|t end");
				elseif addon.editor.getCurrentPropertiesEditor():StepExists(option.next) then
					optionFrame.button.next:SetText("|TInterface\\\MONEYFRAME\\Arrow-Right-Down:16:16|t Step " .. (option.next));
				else
					optionFrame.button.next:SetText("|TInterface\\\MONEYFRAME\\Arrow-Right-Down:16:16|t Step " .. addon.script.formatters.unknown(option.next));
				end
			else
				optionFrame.button.text:SetText("|cFF808080(click to add an option)|r");
				optionFrame.button.next:SetText("");
			end
			optionFrame:SetHeight(40);
			optionFrame.button:Show();
		end
	end
	
end
