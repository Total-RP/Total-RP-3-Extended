local _, addon = ...

local loc = TRP3_API.loc;

local CAMPAIGN_PORTRAITS = {
	"AirStrike",
	"Amber",
	"BrewmoonKeg",
	"ChampionLight",
	"Default",
	"Engineering",
	"EyeofTerrok",
	"Fel",
	"FengBarrier",
	"FengShroud",
	"GarrZoneAbility-Armory",
	"GarrZoneAbility-BarracksAlliance",
	"GarrZoneAbility-BarracksHorde",
	"GarrZoneAbility-Inn",
	"GarrZoneAbility-LumberMill",
	"GarrZoneAbility-MageTower",
	"GarrZoneAbility-Stables",
	"GarrZoneAbility-TradingPost",
	"GarrZoneAbility-TrainingPit",
	"GarrZoneAbility-Workshop",
	"GreenstoneKeg",
	"HozuBar",
	"LightningKeg",
	"Smash",
	"SoulSwap",
	"Ultraxion",
	"Ysera",
};

TRP3_Tools_EditorCampaignMixin = CreateFromMixins(TRP3_Tools_EditorObjectMixin);

function TRP3_Tools_EditorCampaignMixin:Initialize()

	self.main.name:SetScript("OnTextChanged", function()
		self:UpdatePreview();
	end);

	self.main.description:SetupSuggestions("Tag", addon.editor.populateObjectTagMenu);

	local vignetteMenu = {};
	for _, value in ipairs(CAMPAIGN_PORTRAITS) do
		table.insert(vignetteMenu, {
			value,
			value,
			("|TInterface\\ExtraButton\\%s:96:192|t"):format(value)
		});
	end
	TRP3_API.ui.listbox.setupListBox(self.main.vignette, vignetteMenu, function(value) self:UpdatePreview(); end);

	TRP3_API.ui.tooltip.setTooltipForSameFrame(self.main.icon, "RIGHT", 0, 5, loc.CA_ICON, loc.CA_ICON_TT);
	self.main.icon:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.ICONS, {function(icon) 
				self.main.icon.Icon:SetTexture("Interface\\ICONS\\" .. icon);
				self.main.icon.selectedIcon = icon;
				self:UpdatePreview();
			end, 
			nil, 
			nil, 
			self.main.icon.selectedIcon});
	end);

	local sharedNPCEditor = self.npc.sharedNPCEditor;
	sharedNPCEditor.icon:SetScript("OnClick", function()
		addon.modal:ShowModal(TRP3_API.popup.ICONS, {function(icon) 
				TRP3_API.ui.frame.setupIconButton(sharedNPCEditor.icon, icon);
				sharedNPCEditor.icon.selectedIcon = icon;
			end, nil, nil, sharedNPCEditor.icon.selectedIcon});
	end);

	sharedNPCEditor.target:SetScript("OnClick", function()
		if UnitExists("target") then
			local unitType, npcTargetID = TRP3_API.utils.str.getUnitDataFromGUID("target");
			if unitType == "Creature" and npcTargetID then
				sharedNPCEditor.id:SetText(npcTargetID);
				if strtrim(sharedNPCEditor.name:GetText()) == "" then
					sharedNPCEditor.name:SetText(UnitName("target") or "");
				end
			end
		end
	end);
	
end

function TRP3_Tools_EditorCampaignMixin:ClassToInterface(class, creationClass, cursor)
	local BA = class.BA or TRP3_API.globals.empty;
	self.main.name:SetText(BA.NA or "");
	self.main.description:SetText(BA.DE or "");
	self.main.icon.Icon:SetTexture("Interface\\ICONS\\" .. (BA.IC or "TEMP"));
	self.main.icon.selectedIcon = BA.IC;
	self.main.vignette:SetSelectedValue(BA.IM or "GarrZoneAbility-Stables");
	self:UpdatePreview();

	local npcs = {};
	for npcId, npcData in pairs(class.ND or TRP3_API.globals.empty) do
		table.insert(npcs, {
			ID = npcId,
			NA = npcData.NA,
			FT = npcData.FT,
			DE = npcData.DE,
			IC = npcData.IC,
		});
	end
	table.sort(npcs, function(a, b) return (tonumber(a.ID) or 0) < (tonumber(b.ID) or 0); end); -- the sort order might not be preserved when new npcs are added
	table.insert(npcs, {
		isAddButton = true
	});
	
	self.npc.list.model:Flush();
	self.npc.list.model:InsertTable(npcs);
	self.npc.sharedNPCEditor:Hide();
end

function TRP3_Tools_EditorCampaignMixin:InterfaceToClass(targetClass, targetCursor)
	self:SaveActiveNPCIndex();
	targetClass.BA = targetClass.BA or {};
	
	targetClass.BA.NA = TRP3_API.utils.str.emptyToNil(strtrim(self.main.name:GetText()));
	targetClass.BA.DE = TRP3_API.utils.str.emptyToNil(strtrim(self.main.description:GetText()));
	targetClass.BA.IC = self.main.icon.selectedIcon;
	targetClass.BA.IM = self.main.vignette:GetSelectedValue();
	
	targetClass.ND = targetClass.ND or {}; -- TODO maybe set nil if empty?
	wipe(targetClass.ND);
	for _, npcData in self.npc.list.model:EnumerateEntireRange() do
		if not npcData.isAddButton and npcData.ID then
			targetClass.ND[npcData.ID] = {
				NA = npcData.NA,
				FT = npcData.FT,
				DE = npcData.DE,
				IC = npcData.IC,
			};
		end
	end
end

function TRP3_Tools_EditorCampaignMixin:UpdatePreview()
	self.main.previewIcon:SetTexture("Interface\\ICONS\\" .. (self.main.icon.selectedIcon or "TEMP"));
	self.main.previewIconBorder:SetTexture("Interface\\ExtraButton\\" .. self.main.vignette:GetSelectedValue());
	self.main.previewName:SetText(self.main.name:GetText());
end

function TRP3_Tools_EditorCampaignMixin:SaveActiveNPCIndex()
	for index, data in self.npc.list.model:EnumerateEntireRange() do
		if data.active then
			self.npc.list.model:ReplaceAtIndex(index, data);
			break;
		end
	end
end

function TRP3_Tools_EditorCampaignMixin:SetActiveNPCIndex(index)
	for npcIndex, npcData in self.npc.list.model:EnumerateEntireRange() do
		if npcData.active then
			npcData.active = nil;
			self.npc.list.model:ReplaceAtIndex(npcIndex, npcData);
			break;
		end
	end
	local data = self.npc.list.model:Find(index);
	if data and not data.isAddButton then
		data.active = true;
		self.npc.list.model:ReplaceAtIndex(index, data);
		self.npc.list.widget:ScrollToElementDataIndex(index);
	end
end

function TRP3_Tools_EditorCampaignMixin:AddNPC()
	local numElements = self.npc.list.model:GetSize();
	local newNPC = {
	};
	if UnitExists("target") then
		local unitType, npcTargetID = TRP3_API.utils.str.getUnitDataFromGUID("target");
		if unitType == "Creature" and npcTargetID then
			newNPC.ID = npcTargetID;
			newNPC.NA = UnitName("target");
		end
	end
	self.npc.list.model:InsertAtIndex(newNPC, numElements);
	self:SetActiveNPCIndex(numElements)
end

function TRP3_Tools_EditorCampaignMixin:DeleteNPCAtIndex(index)
	self.npc.list.model:RemoveIndex(index);
end

TRP3_Tools_CampaignNPCListElementMixin = {};

function TRP3_Tools_CampaignNPCListElementMixin:Initialize(data)
	self.data = data;
	self:Refresh();
end

function TRP3_Tools_CampaignNPCListElementMixin:Refresh()
	local tooltipTitle;
	local tooltipText;
	local editor = addon.editor.getCurrentPropertiesEditor().npc.sharedNPCEditor;
	if self.data.isAddButton then
		self.icon:Show();
		self.icon.Icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus");
		self.name:Show();
		self.name:SetText(loc.CA_NPC_ADD);
		self.description:Hide();
		self.id:Hide();
		self.delete:Hide();

		tooltipTitle = loc.CA_NPC_ADD;
		tooltipText = TRP3_API.FormatShortcutWithInstruction("LCLICK", loc.CA_NPC_ADD);
		self.editor = nil;
	elseif self.data.active then
		self.icon:Hide();
		self.name:Hide();
		self.description:Hide();
		self.id:Hide();
		self.delete:Show();

		self.editor = editor;
		self.editor:SetParent(self);
		self.editor:SetAllPoints();
		self.editor.id:SetText(self.data.ID or "");
		self.editor.name:SetText(self.data.NA or "");
		self.editor.title:SetText(self.data.FT or "");
		self.editor.description:SetText(self.data.DE or "");
		TRP3_API.ui.frame.setupIconButton(self.editor.icon, self.data.IC or TRP3_InterfaceIcons.ProfileDefault);
		self.editor.icon.selectedIcon = self.data.IC or TRP3_InterfaceIcons.ProfileDefault;
		self.editor:Show();
	else
		self.icon:Show();
		TRP3_API.ui.frame.setupIconButton(self.icon, self.data.IC or TRP3_InterfaceIcons.ProfileDefault);
		self.name:Show();
		self.name:SetText(self.data.NA or loc.CA_NPC_NAME);
		self.description:Show();
		self.description:SetText(self.data.FT or self.data.DE or "");
		self.id:Show();
		self.id:SetText(loc.CA_NPC_ID .. ": " .. (self.data.ID or addon.script.formatters.unknown("id")));
		self.delete:Show();

		tooltipTitle = "Campaign NPC";
		if self.data.ID then
			tooltipText	= "";
		else
			tooltipText = "|cFFFF0000This NPC won't be saved unless an NPC id is specified.|r|n|n";
		end
		tooltipText = 
			tooltipText .. 
			TRP3_API.FormatShortcutWithInstruction("LCLICK", "edit npc") .. "|n" ..
			TRP3_API.FormatShortcutWithInstruction("RCLICK", "more options")
		;
		self.editor = nil;
	end
	TRP3_API.ui.tooltip.setTooltipForSameFrame(self, "BOTTOMRIGHT", 0, 0, tooltipTitle, tooltipText);
end

function TRP3_Tools_CampaignNPCListElementMixin:GetElementExtent(data)
	return data.active and 230 or 60;
end

function TRP3_Tools_CampaignNPCListElementMixin:Reset()
	if self.editor then
		self.data.ID = TRP3_API.utils.str.emptyToNil(strtrim(self.editor.id:GetText()));
		self.data.NA = TRP3_API.utils.str.emptyToNil(strtrim(self.editor.name:GetText()));
		self.data.FT = TRP3_API.utils.str.emptyToNil(strtrim(self.editor.title:GetText()));
		self.data.DE = TRP3_API.utils.str.emptyToNil(strtrim(self.editor.description:GetText()));
		self.data.IC = self.editor.icon.selectedIcon or TRP3_InterfaceIcons.ProfileDefault;
		self.editor:SetParent(nil);
		self.editor:Hide();
		self.editor = nil;
	end
end

function TRP3_Tools_CampaignNPCListElementMixin:OnClick(button)
	local campaignEditor = addon.editor.getCurrentPropertiesEditor();
	local npcIndex = campaignEditor.npc.list.model:FindIndex(self.data);
	if self.data.isAddButton then
		campaignEditor:AddNPC();
	elseif button == "LeftButton" and not self.data.active then
		campaignEditor:SetActiveNPCIndex(npcIndex);
	elseif button == "RightButton" and not self.data.active then
		TRP3_MenuUtil.CreateContextMenu(self, function(_, contextMenu)
			contextMenu:CreateTitle("Campaign NPC");
			
			local editOption = contextMenu:CreateButton("Edit", function()
				campaignEditor:SetActiveNPCIndex(npcIndex);
			end);
			TRP3_MenuUtil.SetElementTooltip(editOption, "Edit NPC");

			contextMenu:CreateDivider();
			local deleteOption = contextMenu:CreateButton(DELETE, function()
				campaignEditor:DeleteNPCAtIndex(npcIndex);
			end);
		end);

	end
end

function TRP3_Tools_CampaignNPCListElementMixin:OnEnter()
	TRP3_RefreshTooltipForFrame(self);
end

function TRP3_Tools_CampaignNPCListElementMixin:OnLeave()
	TRP3_MainTooltip:Hide();
end

function TRP3_Tools_CampaignNPCListElementMixin:OnDelete()
	local campaignEditor = addon.editor.getCurrentPropertiesEditor();
	local npcIndex = campaignEditor.npc.list.model:FindIndex(self.data);
	campaignEditor:DeleteNPCAtIndex(npcIndex);
end
