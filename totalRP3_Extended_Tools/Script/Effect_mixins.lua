local _, addon = ...
local loc = TRP3_API.loc;

local effectEditors = {};

local function buildEffectEditor(effect, scriptContextFunction)
	local editor = CreateFrame("Frame", "TRP3_ToolFrameEffectEditor_" .. effect.id, nil, "BackdropTemplate");
	editor:SetBackdrop(TRP3_BACKDROP_MIXED_TUTORIAL_TOOLTIP_418_24_5555);
	editor.widgets = {};
	editor.effect = effect;
	editor.widgets, editor.groups = addon.script.parameter.acquireWidgets(effect.parameters, editor.widgets, scriptContextFunction);
	
	local leftOffset = 0;
	local rightOffset = 0;
	for index, parameter in ipairs(effect.parameters) do
		local doLayout = true;
		if parameter.groupId then
			doLayout = index == math.min(unpack(editor.groups[parameter.groupId]));
		end
		if doLayout then
			local widget = editor.widgets[index];
			widget:SetParent(editor);
			widget:Show();
			local width, height = widget:GetGridDimensions();
			if parameter.layoutLeft then
				widget:SetPoint("TOP", 0, -(parameter.layoutLeft*35 + 20));
				widget:SetPoint("LEFT", 20, 0);
				widget:SetPoint("RIGHT", editor, "CENTER", -10, 0);
				leftOffset = math.max(leftOffset, parameter.layoutLeft + height);
			elseif parameter.layoutRight then
				widget:SetPoint("TOP", 0, -(parameter.layoutRight*35 + 20));
				widget:SetPoint("LEFT", editor, "CENTER", 10, 0);
				widget:SetPoint("RIGHT", -20, 0);
				rightOffset = math.max(rightOffset, parameter.layoutRight + height);
			elseif width > 1 then
				leftOffset = math.max(leftOffset, rightOffset);
				widget:SetPoint("TOP", 0, -(leftOffset*35 + 20));
				widget:SetPoint("LEFT", 20, 0);
				widget:SetPoint("RIGHT", -20, 0);
				leftOffset = leftOffset + height;
				rightOffset = leftOffset;
			elseif rightOffset < leftOffset then
				widget:SetPoint("TOP", 0, -(rightOffset*35 + 20));
				widget:SetPoint("LEFT", editor, "CENTER", 10, 0);
				widget:SetPoint("RIGHT", -20, 0);
				rightOffset = rightOffset + height;
			else
				widget:SetPoint("TOP", 0, -(leftOffset*35 + 20));
				widget:SetPoint("LEFT", 20, 0);
				widget:SetPoint("RIGHT", editor, "CENTER", -10, 0);
				leftOffset = leftOffset + height;
			end
			widget:SetHeight(height*35-10);
		end
	end

	editor:SetHeight(math.max(leftOffset, rightOffset) * 35 + 30); -- 30 = -10 + 20 + 20
	return editor;
end

local function getEffectEditor(effectId, scriptContextFunction)
	local effect = addon.script.getEffectById(effectId);
	if TableHasAnyEntries(effect.parameters) then
		if not effectEditors[effect.id] then
			effectEditors[effect.id] = buildEffectEditor(effect, scriptContextFunction);
		end
		return effectEditors[effect.id];
	else
		return nil;
	end
end

local function setEffectEditorParameters(effectEditor, parameters)
	addon.script.parameter.setValues(effectEditor.widgets, effectEditor.effect.parameters, parameters, effectEditor.groups);
end

local function getEffectEditorParameters(effectEditor, parameters)
	parameters = parameters or {};
	wipe(parameters);
	if effectEditor then
		addon.script.parameter.getValues(effectEditor.widgets, effectEditor.effect.parameters, parameters);
	end
	return parameters;
end


TRP3_Tools_EditorEffectMixin = {};

function TRP3_Tools_EditorEffectMixin:Initialize()
	self.effectCancelButton:SetScript("OnClick", function() 
		self:ShowEffectMain();
	end);

	self.cancelButton:SetScript("OnClick", function() 
		self:Hide();
	end);
	self.applyButton:SetScript("OnClick", function() 
		self.constraint.list:Update();
		getEffectEditorParameters(self.effectEditor, self.effectData.parameters);
		local effectClass = addon.script.getEffectById(self.effectData.id);
		if not effectClass.canHaveConstraint then
			wipe(self.effectData.constraint);
		end
		addon.editor.script:OnEffectApplied(self.effectData);
		self:Hide();
	end);
	self.constraint.title:SetRotation(math.pi/2); -- not possible to do in XML
	TRP3_API.popup.EFFECT = "effect";
	TRP3_API.popup.POPUPS[TRP3_API.popup.EFFECT] = {
		frame = self,
		showMethod = function(effectData, scriptId)
			self:OpenForEffect(effectData, scriptId);
		end,
	};

	self.recentEffects = {};
end

function TRP3_Tools_EditorEffectMixin:PushRecentEffect(effectId)
	for idx, id in ipairs(self.recentEffects) do
		if id == effectId then
			table.remove(self.recentEffects, idx);
			break; 
		end
	end
	table.insert(self.recentEffects, 1, effectId);
	if CountTable(self.recentEffects) > 8 then
		table.remove(self.recentEffects);
	end
end

function TRP3_Tools_EditorEffectMixin:SetEffect(effectId)

	local effectClass = addon.script.getEffectById(effectId);

	if self.effectData.id ~= effectId then
		self.effectData.id = effectId;
		wipe(self.effectData.parameters);
		for index, parameter in ipairs(effectClass.parameters) do
			table.insert(self.effectData.parameters, parameter.default);
		end
	end
	
	if self.effectEditor then
		self.effectEditor:Hide();
		self.effectEditor:SetParent(nil);
	end

	self.effectEditor = getEffectEditor(self.effectData.id, function() 
		return self:GetScriptContext();
	end);
	if self.effectEditor then
		self.effectEditor:SetParent(self);
		self.effectEditor:ClearAllPoints();
		
		self.effectEditor:SetPoint("TOP", self.effect, "BOTTOM", 0, -10);
		self.effectEditor:SetPoint("LEFT", 20, 0);
		self.effectEditor:SetPoint("RIGHT", -20, 0);
		self.effectEditor:Show();

		setEffectEditorParameters(self.effectEditor, self.effectData.parameters);
	end

	if effectClass.canHaveConstraint then
		self.constraint:SetPoint("TOP", self.effectEditor or self.effect, "BOTTOM", 0, -10);
	end

	self.effect.titleText:SetText(addon.script.getEffectTitle(self.effectData));
	self.effect.icon.Icon:SetTexture("Interface\\Icons\\" .. addon.script.getEffectIcon(self.effectData));
	
end

function TRP3_Tools_EditorEffectMixin:ShowEffectMenu(noCancel)
	self:SetTitle("Choose an effect");
	self.effect:Hide();
	self.constraint:Hide();
	self.applyButton:Hide();
	self.cancelButton:Hide();
	if self.effectEditor then
		self.effectEditor:Hide();
	end

	self.effectTree:Show();
	self.effectCancelButton:SetShown(not noCancel);

	local model = CreateTreeDataProvider();
	if TableHasAnyEntries(self.recentEffects) then
		local recentCategoryNode = model:Insert({
			title = "Recently used",
			isCategory = true
		});
		for _, effectId in ipairs(self.recentEffects) do
			local effect = addon.script.getEffectById(effectId);
			recentCategoryNode:Insert({
				title = effect.title,
				id = effect.id,
				tooltip = effect.description,
				icon = "Interface\\Icons\\" .. effect.icon
			});
		end
		recentCategoryNode:SetCollapsed(false);
	end
	for _, category in ipairs(addon.script.getEffectMenu()) do
		local categoryNode = model:Insert({
			title = category[1],
			isCategory = true
		});
		for _, effect in ipairs(category[2]) do
			categoryNode:Insert({
				title = effect[1],
				id = effect[2],
				tooltip = effect[3],
				icon = "Interface\\Icons\\" .. effect[4]
			});
		end
		categoryNode:SetCollapsed(true);
	end
	self.effectTree.model = model;
	self.effectTree.widget:SetDataProvider(model);
end

function TRP3_Tools_EditorEffectMixin:ShowEffectMain()
	self:SetTitle("Edit effect");
	self.effect:Show();
	local effectClass = addon.script.getEffectById(self.effectData.id);
	self.constraint:SetShown(effectClass.canHaveConstraint);
	self.effectTree:Hide();
	self.effectCancelButton:Hide();
	self.applyButton:Show();
	self.cancelButton:Show();
	if self.effectEditor then
		self.effectEditor:Show();
	end

end

function TRP3_Tools_EditorEffectMixin:GetScriptContext()
	return self.scriptId, addon.editor.script:GetTriggeringGameEventsForScript(self.scriptId);
end

function TRP3_Tools_EditorEffectMixin:OpenForEffect(effectData, scriptId)
	self.scriptId = scriptId;
	self.originalEffectData = effectData;

	self.effectData = self.effectData or {};

	wipe(self.effectData);

	TRP3_API.utils.table.copy(self.effectData, effectData);
	self.effectData.constraint = self.effectData.constraint or {};
	self.effectData.parameters = self.effectData.parameters or {};

	self.constraint.list:LinkWithConstraint(self.effectData.constraint);
	self.constraint.list:SetScriptContext(function() 
		return self:GetScriptContext();
	end);

	if effectData then
		self:SetEffect(self.effectData.id);
		self:ShowEffectMain();
	else
		self:ShowEffectMenu(true);
	end

	self:Open();
end


TRP3_Tools_ScriptEffectTreeNodeMixin = {};

function TRP3_Tools_ScriptEffectTreeNodeMixin:Initialize(node)
	self.node = node;
	self:Refresh();
end

function TRP3_Tools_ScriptEffectTreeNodeMixin:Refresh()
	
	self.title:SetText(self.node.data.title);

	local tooltip;
	if self.node.data.isCategory then
		self.icon:Hide();
		self.toggleChildren:Show();
		if self.node:IsCollapsed() then
			self.toggleChildren.normalTexture:SetTexture("Interface\\Buttons\\UI-PlusButton-UP");
			self.toggleChildren.pushedTexture:SetTexture("Interface\\Buttons\\UI-PlusButton-DOWN");
			tooltip = TRP3_API.FormatShortcutWithInstruction("LCLICK", "expand section");
		else
			self.toggleChildren.normalTexture:SetTexture("Interface\\Buttons\\UI-MinusButton-UP");
			self.toggleChildren.pushedTexture:SetTexture("Interface\\Buttons\\UI-MinusButton-DOWN");
			tooltip = TRP3_API.FormatShortcutWithInstruction("LCLICK", "collanpse section");
		end
	else
		self.icon.Icon:SetTexture(self.node.data.icon);
		self.icon:Show();
		self.toggleChildren:Hide();
		tooltip = self.node.data.tooltip .. "|n" .. TRP3_API.FormatShortcutWithInstruction("LCLICK", "select");
	end

	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, self.node.data.title, tooltip);

end

function TRP3_Tools_ScriptEffectTreeNodeMixin:OnClick()
	if self.node.data.isCategory then
		self:OnToggleChildren();
	else
		TRP3_Tools_EditorEffect:PushRecentEffect(self.node.data.id);
		TRP3_Tools_EditorEffect:SetEffect(self.node.data.id);
		TRP3_Tools_EditorEffect:ShowEffectMain();
	end
end

function TRP3_Tools_ScriptEffectTreeNodeMixin:OnToggleChildren()
	self.node:ToggleCollapsed();
	TRP3_Tools_EditorEffect.effectTree:Refresh();
end

function TRP3_Tools_ScriptEffectTreeNodeMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_ScriptEffectTreeNodeMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end
