local _, addon = ...

local loc = TRP3_API.loc;

TRP3_Tools_EditorQuestStepMixin = CreateFromMixins(TRP3_Tools_EditorObjectMixin);

function TRP3_Tools_EditorQuestStepMixin:Initialize()
	self.main.pre:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);
	self.main.post:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);
end

function TRP3_Tools_EditorQuestStepMixin:ClassToInterface(class, creationClass, cursor)
	local BA = class.BA or TRP3_API.globals.empty;
	self.main.pre:SetText(BA.TX or "");
	self.main.post:SetText(BA.DX or "");
	self.main.auto:SetChecked(BA.IN or false);
	self.main.final:SetChecked(BA.FI or false);
end

function TRP3_Tools_EditorQuestStepMixin:InterfaceToClass(targetClass, targetCursor)
	targetClass.BA = targetClass.BA or {};
	targetClass.BA.NA = addon.editor.getCurrentObjectRelativeId(); -- TODO why is this needed?
	targetClass.BA.TX = TRP3_API.utils.str.emptyToNil(strtrim(self.main.pre:GetText()));
	targetClass.BA.DX = TRP3_API.utils.str.emptyToNil(strtrim(self.main.post:GetText()));
	targetClass.BA.IN = self.main.auto:GetChecked();
	targetClass.BA.FI = self.main.final:GetChecked();
end
