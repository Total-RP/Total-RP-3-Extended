local _, addon = ...
local loc = TRP3_API.loc;

local function evaluateOperand(operandData)
	local operandInfo = TRP3_API.script.getOperand(operandData.id);
	if operandInfo then
		return TRP3_API.script.generateAndRun("return " .. operandInfo:CodeReplacement(operandData.parameters), nil, operandInfo.env);
	elseif addon.script.getOperandById(operandData.id).literal then
		return operandData.parameters[1];
	end
	return nil;
end

TRP3_Tools_ScriptConstraintEditorMixin = {};

function TRP3_Tools_ScriptConstraintEditorMixin:PostInitialize()
	self.sharedLeftTermDropdown = CreateFrame("DropdownButton", nil, nil, "TRP3_Tools_TitledDropdownButtonTemplate");
	self.sharedLeftTermDropdown:Hide();
	self.sharedLeftTermDropdown.title:SetText("First operand");
	self.sharedComparatorDropdown = CreateFrame("DropdownButton", nil, nil, "TRP3_Tools_TitledDropdownButtonTemplate");
	self.sharedComparatorDropdown:Hide();
	self.sharedComparatorDropdown.title:SetText("Comparator");
	self.sharedRightTermDropdown = CreateFrame("DropdownButton", nil, nil, "TRP3_Tools_TitledDropdownButtonTemplate");
	self.sharedRightTermDropdown:Hide();
	self.sharedRightTermDropdown.title:SetText("Second operand");
	self.sharedApplyLeftToRightButton = CreateFrame("Button", nil, nil, "TRP3_CommonButton");
	self.sharedApplyLeftToRightButton:Hide();
	self.sharedApplyLeftToRightButton:SetSize(25, 25);
	self.sharedApplyLeftToRightButton:SetText("|TInterface\\\MONEYFRAME\\Arrow-Right-Down:16:16|t");
	addon.utils.prepareForMultiSelectionMode(self);
end

function TRP3_Tools_ScriptConstraintEditorMixin:Update()
	local model = {};

	local orStart, prev;
	local hasAnd = false;
	for index, equation in ipairs(self.constraint or TRP3_API.globals.empty) do
		local modelItem = {
			equation           = equation,
			isOpenParenthesis  = false,
			isCloseParenthesis = false,
			active             = index == self.activeIndex,
			index              = index,
			selected           = (self.model:FindByPredicate(function(x) return x.equation == equation and x.selected; end) ~= nil)
		};
		if index > 1 then
			if equation.logicalOperation == addon.script.logicalOperation.OR then
				orStart = orStart or prev;
			elseif equation.logicalOperation == addon.script.logicalOperation.AND then
				hasAnd = true;
				if orStart then
					orStart.isOpenParenthesis = true;
					prev.isCloseParenthesis = true;
					orStart = nil;
				end
			end
		end
		prev = modelItem;
		table.insert(model, modelItem);
	end
	if hasAnd and orStart then
		orStart.isOpenParenthesis = true;
		prev.isCloseParenthesis = true;
	end
	if self.constraint then
		table.insert(model, {});
	end
	
	local scrollPct = self.widget:GetScrollPercentage();
	self.sharedLeftTermDropdown:Hide();
	self.sharedComparatorDropdown:Hide();
	self.sharedRightTermDropdown:Hide();
	self.sharedApplyLeftToRightButton:Hide();
	self.model:Flush();
	self.model:InsertTable(model);
	self.widget:SetScrollPercentage(scrollPct);
end

function TRP3_Tools_ScriptConstraintEditorMixin:LinkWithConstraint(constraint)
	self.activeIndex = nil;
	self.constraint = constraint;
	for _, frame in pairs(self.widget:GetFrames()) do
		frame.invalidated = true;
	end
	self.model:Flush();
	self.widget:SetScrollPercentage(0);
	self:Update();
end

function TRP3_Tools_ScriptConstraintEditorMixin:Unlink()
	local constraint = self.constraint;
	self.model:Flush();
	self.constraint = nil;
	return constraint;
end

function TRP3_Tools_ScriptConstraintEditorMixin:SetScriptContext(scriptContextFunction)
	self.GetScriptContext = scriptContextFunction;
end

function TRP3_Tools_ScriptConstraintEditorMixin:SetActiveIndex(index)
	self.activeIndex = index;
	self:Update();
end

function TRP3_Tools_ScriptConstraintEditorMixin:AddEquation(equation, index, silent)
	local insertPosition = index or #self.constraint + 1;
	table.insert(self.constraint, insertPosition, equation or {
		logicalOperation = addon.script.logicalOperation.AND,
		leftTerm         = {id = "unit_name", parameters = {"target"}},
		comparator       = "==",
		rightTerm        = {id = "literal_string", parameters = {"Elsa"}},
	});
	if not silent then
		self.activeIndex = insertPosition;
		self:Update();
	end
end

function TRP3_Tools_ScriptConstraintEditorMixin:DeleteIndex(index)
	if self.activeIndex then
		if self.activeIndex == index then
			self.activeIndex = nil;
		elseif self.activeIndex > index then
			self.activeIndex = self.activeIndex - 1;
		end
	end
	table.remove(self.constraint, index);
	self:Update();
end

function TRP3_Tools_ScriptConstraintEditorMixin:DeleteSelected()
	for _, data in self.model:ReverseEnumerateEntireRange() do
		if data.selected then
			if self.activeIndex then
				if self.activeIndex == data.index then
					self.activeIndex = nil;
				elseif self.activeIndex > data.index then
					self.activeIndex = self.activeIndex - 1;
				end
			end
			table.remove(self.constraint, data.index);
		end
	end
	self:Update();
end

TRP3_Tools_ScriptConstraintEditorListElementMixin = {};

function TRP3_Tools_ScriptConstraintEditorListElementMixin:GetList()
	return self:GetParent():GetParent():GetParent();
end

function TRP3_Tools_ScriptConstraintEditorListElementMixin:Initialize(data)
	self.data = data;
	self.leftOperandEditor = self.leftOperandEditor or {};
	self.rightOperandEditor = self.rightOperandEditor or {};
	self:Refresh();
	self.invalidated = nil;
	if self.data.active then
		self:SetHighlightEnabled(false);
		local s = self;

		local left = self:GetList().sharedLeftTermDropdown;
		local comp = self:GetList().sharedComparatorDropdown;
		local right = self:GetList().sharedRightTermDropdown;
		local carry = self:GetList().sharedApplyLeftToRightButton;

		left:SetParent(self);
		left:ClearAllPoints();
		left:SetPoint("TOPLEFT", 70, -35);
		left:SetPoint("RIGHT", self, "CENTER", -55, 0);
		TRP3_API.ui.listbox.setupListBox(left, addon.script.getOperandMenu(), function(operandId)
			if operandId ~= s.data.equation.leftTerm.id then
				s.data.equation.leftTerm.id = operandId;
				addon.script.operand.getDefaultOperandEditorValues(s.data.equation.leftTerm);
				addon.script.operand.getOperandEditorValues(s.data.equation.rightTerm, s.rightOperandEditor);
				s.invalidated = true;
				s:GetList():Update();
			end
		end);
		left:SetSelectedValue(self.data.equation.leftTerm.id);
		left:Show();
		
		comp:SetParent(self);
		comp:ClearAllPoints();
		comp:SetPoint("TOP", 25, -35);
		comp:SetWidth(150);
		TRP3_API.ui.listbox.setupListBox(comp, addon.script.comparators, function(comparator)
			if comparator ~= s.data.equation.comparator then
				s.data.equation.comparator = comparator;
				addon.script.operand.getOperandEditorValues(s.data.equation.leftTerm, s.leftOperandEditor);
				addon.script.operand.getOperandEditorValues(s.data.equation.rightTerm, s.rightOperandEditor);
				s.invalidated = true;
				s:GetList():Update();
			end
		end);
		comp:SetSelectedValue(self.data.equation.comparator);
		comp:Show();

		carry:SetParent(self);
		carry:ClearAllPoints();
		carry:SetPoint("LEFT", comp, "RIGHT", 5, 0);
		carry:SetScript("OnClick", function() 
			addon.script.operand.getOperandEditorValues(self.data.equation.leftTerm, self.leftOperandEditor);
			local leftValue = evaluateOperand(self.data.equation.leftTerm);
			if type(leftValue) == "nil" or type(leftValue) == "string" then
				self.data.equation.rightTerm = {id = "literal_string", parameters = {tostring(leftValue)}};
			elseif type(leftValue) == "boolean" then
				self.data.equation.rightTerm = {id = "literal_boolean", parameters = {leftValue}};
			elseif type(leftValue) == "number" then
				self.data.equation.rightTerm = {id = "literal_number", parameters = {leftValue}};
			end
			self.invalidated = true;
			self:GetList():Update();
		end);
		carry:Show();

		right:SetParent(self);
		right:ClearAllPoints();
		right:SetPoint("TOP", 0, -35);
		right:SetPoint("LEFT", self, "CENTER", 135, 0);
		right:SetPoint("RIGHT", -10, 0);
		TRP3_API.ui.listbox.setupListBox(right, addon.script.getOperandMenu(true), function(operandId)
			if operandId ~= s.data.equation.rightTerm.id then 
				s.data.equation.rightTerm.id = operandId;
				addon.script.operand.getDefaultOperandEditorValues(s.data.equation.rightTerm);
				addon.script.operand.getOperandEditorValues(s.data.equation.leftTerm, s.leftOperandEditor);
				s.invalidated = true;
				s:GetList():Update();
			end
		end);
		right:SetSelectedValue(self.data.equation.rightTerm.id);
		right:Show();

		local offset;
		local leftWidgetSkipList = addon.script.operand.acquireOperandEditor(self.data.equation.leftTerm, self.leftOperandEditor, self:GetList().GetScriptContext);
		offset = 1;
		for index, widget in ipairs(self.leftOperandEditor) do
			if not leftWidgetSkipList[index] then
				widget:SetParent(self);
				widget:SetPoint("TOPLEFT", 70, -35-offset*35);
				widget:SetPoint("RIGHT", self, "CENTER", -55, 0);
				widget:Show();
				offset = offset + 1;
			end
		end

		offset = 1;
		local rightWidgetSkipList = addon.script.operand.acquireOperandEditor(self.data.equation.rightTerm, self.rightOperandEditor, self:GetList().GetScriptContext);
		for index, widget in ipairs(self.rightOperandEditor) do
			if not rightWidgetSkipList[index] then
				widget:SetParent(self);
				widget:SetPoint("TOP", 0, -35-offset*35);
				widget:SetPoint("LEFT", self, "CENTER", 105, 0);
				widget:SetPoint("RIGHT", -10, 0);
				widget:Show();
				offset = offset + 1;
			end
		end
	else
		self:SetHighlightEnabled(true);
	end
end

function TRP3_Tools_ScriptConstraintEditorListElementMixin:ToggleLogicalOperator()
	if self.data.index then
		if self.data.equation.logicalOperation == addon.script.logicalOperation.OR then
			self.data.equation.logicalOperation = addon.script.logicalOperation.AND;
		elseif self.data.equation.logicalOperation == addon.script.logicalOperation.AND then
			self.data.equation.logicalOperation = addon.script.logicalOperation.OR;
		end
		self:GetList():Update();
	else
		self:GetList():AddEquation();
	end
end

function TRP3_Tools_ScriptConstraintEditorListElementMixin:OnDelete()
	self.invalidated = true;
	self:GetList():DeleteIndex(self.data.index);
end

function TRP3_Tools_ScriptConstraintEditorListElementMixin:Refresh()
	if not self.data.index then 
		self.logicalOperatorButton:SetText("|TInterface\\PaperDollInfoFrame\\Character-Plus:12:12|t");
		self.logicalOperatorButton:Show();
		self.open:Hide();
		self.close:Hide();
		self.expression:SetText("Add condition");
		self.delete:Hide();
		self:SetSelected(false);
	else
		self.logicalOperatorButton:SetShown(self.data.index > 1);
		self.open:SetShown(self.data.isOpenParenthesis);
		self.close:SetShown(self.data.isCloseParenthesis);
		if self.data.equation.logicalOperation == addon.script.logicalOperation.OR then
			self.logicalOperatorButton:SetText(loc.OP_OR);
		elseif self.data.equation.logicalOperation == addon.script.logicalOperation.AND then
			self.logicalOperatorButton:SetText(loc.OP_AND);
		end
		self.expression:SetText(addon.script.getOperandPreview(self.data.equation.leftTerm) .. " " .. addon.script.getComparatorText(self.data.equation.comparator) .. " " .. addon.script.getOperandPreview(self.data.equation.rightTerm));
		self.delete:Show();
		self:SetSelected(self.data.selected);
	end
end

function TRP3_Tools_ScriptConstraintEditorListElementMixin:GetElementExtent(data)
	if data.active then 
		return 38 + 35 + 35*math.max(addon.script.operand.getOperandEditorExtent(data.equation.leftTerm.id), addon.script.operand.getOperandEditorExtent(data.equation.rightTerm.id));
	else
		return 38;
	end
end

function TRP3_Tools_ScriptConstraintEditorListElementMixin:Reset()
	if self.data.active then
		if not self.invalidated then
			addon.script.operand.getOperandEditorValues(self.data.equation.leftTerm, self.leftOperandEditor);
			addon.script.operand.getOperandEditorValues(self.data.equation.rightTerm, self.rightOperandEditor);
		end
		addon.script.operand.releaseOperandEditor(self.leftOperandEditor);
		addon.script.operand.releaseOperandEditor(self.rightOperandEditor);
		self:GetList().sharedLeftTermDropdown:Hide();
		self:GetList().sharedComparatorDropdown:Hide();
		self:GetList().sharedRightTermDropdown:Hide();
		self:GetList().sharedApplyLeftToRightButton:Hide();
	end
end

function TRP3_Tools_ScriptConstraintEditorListElementMixin:OnClick(button)
	if button == "LeftButton" then
		if not self.data.index then
			self:GetList():AddEquation();
		else
			if IsControlKeyDown() then
				self:GetList():ToggleSingleSelect(self.data);
			elseif IsShiftKeyDown() then
				self:GetList():ToggleRangeSelect(self.data);
			elseif not self.data.active then
				self:GetList():SetActiveIndex(self.data.index);
			end
		end
	elseif button == "RightButton" then
		TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
			contextMenu:CreateTitle(loc.WO_CONDITION);
			if not self.data.index then
				local addOption = contextMenu:CreateButton("Add condition", function()
					self:GetList():AddEquation();
				end);
				TRP3_MenuUtil.SetElementTooltip(addOption, "Add a condition");
			elseif self.data.active then
				local collanpseOption = contextMenu:CreateButton("Collapse", function()
					self:GetList():SetActiveIndex();
				end);
				TRP3_MenuUtil.SetElementTooltip(collanpseOption, "Collapse this condition");
			else
				local editOption = contextMenu:CreateButton("Edit", function()
					self:GetList():SetActiveIndex(self.data.index);
				end);
				TRP3_MenuUtil.SetElementTooltip(editOption, "Edit this condition");
			end
			
			if self.data.index then
				contextMenu:CreateDivider();
				local addBeforeOption = contextMenu:CreateButton("Insert condition before", function()
					self:GetList():AddEquation(nil, self.data.index);
				end);
				TRP3_MenuUtil.SetElementTooltip(addBeforeOption, "Insert a new condition before this condition");
				local addAfterOption = contextMenu:CreateButton("Insert condition after", function()
					self:GetList():AddEquation(nil, self.data.index + 1);
				end);
				TRP3_MenuUtil.SetElementTooltip(addAfterOption, "Insert a new condition after this condition");
			end

			if self.data.index or addon.clipboard.isPasteCompatible(addon.clipboard.types.CONDITION_TEST) then
				contextMenu:CreateDivider();
				if self.data.index then
					local copyOption = contextMenu:CreateButton("Copy", function()
						addon.clipboard.clear();
						local equation = self.data.equation;
						self:GetList():Update();
						addon.clipboard.append(equation, addon.clipboard.types.CONDITION_TEST);
					end);
					TRP3_MenuUtil.SetElementTooltip(copyOption, "Copy this condition");
					if self.data.selected then
						local copySelectionOption = contextMenu:CreateButton("Copy selected conditions", function()
							addon.clipboard.clear();
							self:GetList():Update();
							for index, element in self:GetList().model:EnumerateEntireRange() do
								if element.selected then
									addon.clipboard.append(element.equation, addon.clipboard.types.CONDITION_TEST);
								end
							end
							self:GetList():SetAllSelected(false);
						end);
						TRP3_MenuUtil.SetElementTooltip(copySelectionOption, "Copy all selected conditions");
					end
					local copyAllOption = contextMenu:CreateButton("Copy all conditions", function()
						addon.clipboard.clear();
						self:GetList():Update();
						for index, element in self:GetList().model:EnumerateEntireRange() do
							if element.index then
								addon.clipboard.append(element.equation, addon.clipboard.types.CONDITION_TEST);
							end
						end
					end);
					TRP3_MenuUtil.SetElementTooltip(copyAllOption, "Copy all conditions");
				end

				if addon.clipboard.isPasteCompatible(addon.clipboard.types.CONDITION_TEST) then
					local count = addon.clipboard.count();

					local beforeText, afterText;
					if count == 1 then
						beforeText = "Paste condition";
						afterText = "Paste condition after";
					else
						beforeText = "Paste " .. count .. " conditions";
						afterText = "Paste " .. count .. " conditions after";
					end

					local offset;
					if self.data.index then
						beforeText = beforeText .. " before";
						offset = self.data.index;
					else
						offset = #self:GetList().constraint + 1;
					end

					local pasteBeforeOption = contextMenu:CreateButton(beforeText, function()
						for index = 1, count do
							self:GetList():AddEquation(addon.clipboard.retrieve(index), offset + index - 1, true);
						end
						self:GetList().activeIndex = offset + count - 1;
						self:GetList():Update();
					end);
					TRP3_MenuUtil.SetElementTooltip(pasteBeforeOption, beforeText);
					if self.data.index then
						local pasteAfterOption = contextMenu:CreateButton(afterText, function()
							for index = 1, count do
								self:GetList():AddEquation(addon.clipboard.retrieve(index), offset + index, true);
							end
							self:GetList().activeIndex = offset + count;
							self:GetList():Update();
						end);
						TRP3_MenuUtil.SetElementTooltip(pasteAfterOption, afterText);
					end
				end
			end

			if self.data.index then
				contextMenu:CreateDivider();
				local deleteOption = contextMenu:CreateButton(DELETE, function()
					self.invalidated = true;
					self:GetList():DeleteIndex(self.data.index);
				end);
				TRP3_MenuUtil.SetElementTooltip(deleteOption, "Delete this condition");

				if self.data.selected then
					local deleteSelectionOption = contextMenu:CreateButton("Delete selection", function()
						self.invalidated = true;
						self:GetList():DeleteSelected();
					end);
					TRP3_MenuUtil.SetElementTooltip(deleteSelectionOption, "Delete all selected conditions");
				end
			end
		end);
	end
end

function TRP3_Tools_ScriptConstraintEditorListElementMixin:OnEnter()
	if self.data.index then

		if self.data.active and not self.invalidated then
			addon.script.operand.getOperandEditorValues(self.data.equation.leftTerm, self.leftOperandEditor);
			addon.script.operand.getOperandEditorValues(self.data.equation.rightTerm, self.rightOperandEditor);
		end

		local evaluatedPreview = 
			addon.script.formatters.formatType(evaluateOperand(self.data.equation.leftTerm)) .. " " ..
			addon.script.getComparatorText(self.data.equation.comparator) .. " " ..
			addon.script.formatters.formatType(evaluateOperand(self.data.equation.rightTerm));

		local tooltipText = 
			"Test:" .. "|n" ..
			self.expression:GetText() .. "|r|n|n" ..
			"Test preview:|n" ..
			evaluatedPreview .. "|r|n" ..
			"(Not all conditions can be previewed accurately.)|n|n" ..
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "edit condition") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("RCLICK", "more options") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("SHIFT-CLICK", "select range") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("CTRL-CLICK", "select this condition")
		;
		TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, "Condition", tooltipText);
		TRP3_RefreshTooltipForFrame(self);
	end
end

function TRP3_Tools_ScriptConstraintEditorListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end
