local _, addon = ...

local loc = TRP3_API.loc;

addon.editor = {};

local editorFrame;
local statusBar;
local objectTree;
local objectEditor;
local objectRibbon;
local PROPERTY_EDITORS = {};

local currentEditor;
local currentDraft;
local currentObject;

local DUMMY_TREE_MODEL = CreateTreeDataProvider();

local function updateTabBar()
	addon.main.forEachTab(function(tab, editor) 
		if editor.creationId == currentEditor.creationId then
			local body;
			local absoluteId = "";
			local root, last;
			local level = 0;
			for relativeId in editor.cursor.objectId:gmatch("[^%" .. TRP3_API.extended.ID_SEPARATOR .. "]+") do
				absoluteId = absoluteId .. relativeId;
				if currentDraft.index[absoluteId] then
					if level == 0 then
						local icon, link = addon.utils.getObjectIconAndLink(currentDraft.index[absoluteId].class);
						root = ("|T%s:16:16|t %s"):format(icon, link);
					else
						local icon, link = addon.utils.getObjectIconAndLink(currentDraft.index[absoluteId].class);
						last = ("|T%s:16:16|t %s"):format(icon, link);
						local indent = ("|n|TInterface\\COMMON\\spacer:16:%d|t|TInterface\\\MONEYFRAME\\Arrow-Right-Down:16:16|t"):format(level*16);
						body = (body or "") .. indent .. last;
					end
					level = level + 1;
				end
				absoluteId = absoluteId .. TRP3_API.extended.ID_SEPARATOR;
			end
			tab:SetLabel(root);
			tab:SetTooltip(root, body);
		end
	end);
	addon.main.refreshTabs();
end

local function isRelativeIdAvailable(class, relativeId)
	return 
		(not class.QE or not class.QE[relativeId])
	and (not class.ST or not class.ST[relativeId])
	and (not class.IN or not class.IN[relativeId])
	;
end

local function buildObjectTree(creationId, creationClass)
	local index = {};
	local stack = {};
	local model = CreateTreeDataProvider();
	table.insert(stack, {
		relativeId = creationId,
		absoluteId = creationId,
		class      = creationClass,
		parent     = model
	});
	while TableHasAnyEntries(stack) do
		local top = table.remove(stack);
		local icon, link = addon.utils.getObjectIconAndLink(top.class);
		local node = top.parent:Insert({
			icon       = icon,
			link       = link,
			relativeId = top.relativeId,
			absoluteId = top.absoluteId
		});
		index[top.absoluteId] = {
			class = top.class,
			node  = node
		};
		for _, childKey in ipairs_reverse({"QE", "ST", "IN"}) do
			if top.class[childKey] then
				local tmp = {};
				for id, _ in pairs(top.class[childKey]) do
					table.insert(tmp, id);
				end
				table.sort(tmp);
				for _, id in ipairs_reverse(tmp) do
					table.insert(stack, {
						relativeId = id,
						absoluteId = top.absoluteId .. TRP3_API.extended.ID_SEPARATOR .. id,
						class      = top.class[childKey][id],
						parent     = node;
					});
				end
			end
		end
	end
	model:CollapseAll();
	return model, index;
end

local function rebuildTreeAndShow(absoluteId)

	currentEditor.cursor.objects = currentEditor.cursor.objects or {};
	for id, object in pairs(currentDraft.index or TRP3_API.globals.empty) do
		currentEditor.cursor.objects[id] = currentEditor.cursor.objects[id] or {};
		currentEditor.cursor.objects[id].collapsed = (not addon.utils.isInnerIdOrEqual(id, absoluteId)) and object.node:IsCollapsed();
	end

	local model, index = buildObjectTree(currentEditor.creationId, currentDraft.class);
	currentObject = nil;
	currentDraft.model = model;
	currentDraft.index = index;

	local treeScroll = objectTree.widget:GetScrollPercentage();

	objectTree.widget:SetDataProvider(DUMMY_TREE_MODEL);
	for absoluteId, objectCursor in pairs(currentEditor.cursor.objects) do
		if currentDraft.index[absoluteId] then
			currentDraft.index[absoluteId].node:SetCollapsed(objectCursor.collapsed);
		else
			currentEditor.cursor.objects[absoluteId] = nil;
		end
	end

	objectTree.model = currentDraft.model;
	objectTree.widget:SetDataProvider(currentDraft.model);
	objectTree.widget:SetScrollPercentage(treeScroll);

	addon.editor.displayObject(absoluteId);
	addon.editor.refreshObjectTree();
end

function addon.editor.currentDraftClassExists(absoluteId)
	return absoluteId and currentDraft and currentDraft.index and currentDraft.index[absoluteId] ~= nil;
end

function addon.editor.getCurrentDraftClass(absoluteId)
	if absoluteId then
		return currentDraft and currentDraft.index and currentDraft.index[absoluteId] and currentDraft.index[absoluteId].class or nil;
	else
		return currentObject and currentObject.class or nil;
	end
end

function addon.editor.getCurrentDraftCreationId()
	return currentEditor and currentEditor.creationId;
end

function addon.editor.getCurrentDraftCursor()
	return currentEditor.cursor;
end

function addon.editor.getRelativeId(absoluteId)
	if currentDraft and currentDraft.index and currentDraft.index[absoluteId] then
		return currentDraft.index[absoluteId].node.data.relativeId;
	else
		return nil;
	end
end

-- callback(absoluteId, relativeId, class)
function addon.editor.forEachObjectInCurrentDraft(callback)
	if not currentDraft then 
		return;
	end
	for absoluteId, object in pairs(currentDraft.index or TRP3_API.globals.empty) do
		callback(absoluteId, object.node.data.relativeId, object.class);
	end
end

-----------------------
-- Tree manipulation --
-----------------------

function addon.editor.copySelectedTreeObjects()
	addon.editor.updateCurrentObjectDraft();
	for absoluteId, object in pairs(currentDraft.index) do
		if object.node.data.selected then
			addon.clipboard.append(object.class, object.class.TY, absoluteId, object.node.data.relativeId);
		end
	end
end

function addon.editor.pasteClipboardAsInnerObjects(absoluteId)
	local object = currentDraft.index[absoluteId];
	if addon.clipboard.isInnerCompatible(object.class.TY) then
		local newRelativeIds = {};
		for index = 1, addon.clipboard.count() do
			local oldInnerAbsoluteId = addon.clipboard.retrieveId(index);
			local ids = {strsplit(TRP3_API.extended.ID_SEPARATOR, oldInnerAbsoluteId)};
			local relativeId = ids[#ids] or "";
			table.insert(newRelativeIds, relativeId);
			if not isRelativeIdAvailable(object.class, relativeId) then
				return false, "At least one object cannot be pasted here, because its id already exists."; -- TODO
			end
		end
		
		for index = 1, addon.clipboard.count() do
			local oldInnerAbsoluteId = addon.clipboard.retrieveId(index);
			local newRelativeId = newRelativeIds[index];
			local innerClass = addon.clipboard.retrieve(index);
			innerClass.MD = nil;
			addon.utils.replaceId(innerClass, oldInnerAbsoluteId, absoluteId .. TRP3_API.extended.ID_SEPARATOR .. newRelativeId);
			if innerClass.TY == TRP3_DB.types.QUEST then
				object.class.QE = object.class.QE or {};
				object.class.QE[newRelativeId] = innerClass;
			elseif innerClass.TY == TRP3_DB.types.QUEST_STEP then
				object.class.ST = object.class.ST or {};
				object.class.ST[newRelativeId] = innerClass;
			else
				object.class.IN = object.class.IN or {};
				object.class.IN[newRelativeId] = innerClass;
			end
		end
		currentEditor.cursor.objects[absoluteId] = currentEditor.cursor.objects[absoluteId] or {};
		currentEditor.cursor.objects[absoluteId].collapsed = false;
		rebuildTreeAndShow(absoluteId);
		return true;
	else
		return false, "At least one object cannot be pasted here, because the type doesn't fit."; -- TODO
	end
end

function addon.editor.requestInnerObject(absoluteId, type)
	TRP3_API.popup.showTextInputPopup(loc.IN_INNER_ENTER_ID .. "|n|n" .. loc.IN_INNER_ENTER_ID_TT, function(relativeId)
		relativeId = relativeId or "";
		relativeId = TRP3_API.extended.checkID(relativeId);
		if relativeId:len() == 0 then
			return;
		elseif relativeId:find(" ") then
			TRP3_API.popup.showAlertPopup(loc.IN_INNER_ENTER_ID_NO_SPACE);
		else
			local success, message = addon.editor.appendInnerObject(absoluteId, relativeId, type);
			if not success then
				TRP3_API.utils.message.displayMessage(message, 4);
			end
		end
	end, nil, "");
end

function addon.editor.appendInnerObject(absoluteId, relativeId, type)
	local object = currentDraft.index[absoluteId];
	if isRelativeIdAvailable(object.class, relativeId) then
		addon.editor.updateCurrentObjectDraft();
		local innerClass, field = addon.utils.createEmptyClass(type);
		object.class[field] = object.class[field] or {};
		object.class[field][relativeId] = innerClass;
		local innerAbsoluteId = absoluteId .. TRP3_API.extended.ID_SEPARATOR .. relativeId;
		
		currentEditor.cursor.objects[absoluteId] = currentEditor.cursor.objects[absoluteId] or {};
		currentEditor.cursor.objects[absoluteId].collapsed = false;
		currentEditor.cursor.objects[innerAbsoluteId] = currentEditor.cursor.objects[innerAbsoluteId] or {};
		currentEditor.cursor.objects[innerAbsoluteId].collapsed = false;
		
		rebuildTreeAndShow(innerAbsoluteId);
		return true;
	else
		return false, loc.IN_INNER_NO_AVAILABLE;
	end
end

function addon.editor.replaceCurrentDraftClass(absoluteId, newClassShallow, originalAbsoluteId)
	addon.editor.updateCurrentObjectDraft();
	local class = currentDraft.index[absoluteId].class;
	local MD = class.MD;
	wipe(class);
	TRP3_API.utils.table.copy(class, newClassShallow);
	addon.utils.replaceId(class, originalAbsoluteId, absoluteId);
	class.MD = MD;
	rebuildTreeAndShow(absoluteId);
end

function addon.editor.deleteSelectedTreeObjects()
	local toDelete = {};
	for absoluteId, object in pairs(currentDraft.index) do
		if object.node.data.selected then
			table.insert(toDelete, absoluteId);
		end
	end
	addon.editor.deleteInnerObjectsById(unpack(toDelete));
end

function addon.editor.deleteInnerObjectsById(...)
	local toDelete = {};
	for _, absoluteId in ipairs({...}) do
		if currentDraft.index[absoluteId] and absoluteId ~= currentEditor.creationId then
			toDelete[absoluteId] = absoluteId;
		end
	end
	if TableIsEmpty(toDelete) then
		return;
	end
	local ancestors = {};
	for absoluteId in pairs(toDelete) do
		local ancestor   = currentDraft.index[absoluteId].node:GetParent();
		local parent     = currentDraft.index[ancestor.data.absoluteId];
		local object     = currentDraft.index[absoluteId];
		local relativeId = object.node.data.relativeId;
		if object.class.TY == TRP3_DB.types.QUEST then
			parent.class.QE[relativeId] = nil;
		elseif object.class.TY == TRP3_DB.types.QUEST_STEP then
			parent.class.ST[relativeId] = nil;
		else
			parent.class.IN[relativeId] = nil;
		end
		while toDelete[ancestor.data.absoluteId] do
			ancestor = ancestor:GetParent();
		end
		ancestors[absoluteId] = ancestor.data.absoluteId;
	end

	addon.main.forEachTab(function(_, editor) 
		if editor.creationId == currentEditor.creationId then
			for absoluteId, ancestorId in pairs(ancestors) do
				if addon.utils.isInnerIdOrEqual(absoluteId, editor.cursor.objectId) then
					editor.cursor.objectId = ancestorId;
					break;
				end
			end
		end
	end);

	rebuildTreeAndShow(select(2, next(ancestors)));
end

function addon.editor.changeRelativeId(absoluteId, newRelativeId)
	local parentId = currentDraft.index[absoluteId].node:GetParent().data.absoluteId;
	local parent = currentDraft.index[parentId];
	local newAbsoluteId = parentId .. TRP3_API.extended.ID_SEPARATOR .. newRelativeId;
	if isRelativeIdAvailable(parent.class, newRelativeId) and not currentDraft.index[newAbsoluteId] then
		addon.editor.updateCurrentObjectDraft();
		local object = currentDraft.index[absoluteId];
		local oldRelativeId = object.node.data.relativeId;
		if object.class.TY == TRP3_DB.types.QUEST then
			parent.class.QE[newRelativeId] = parent.class.QE[oldRelativeId];
			parent.class.QE[oldRelativeId] = nil;
		elseif object.class.TY == TRP3_DB.types.QUEST_STEP then
			parent.class.ST[newRelativeId] = parent.class.ST[oldRelativeId];
			parent.class.ST[oldRelativeId] = nil;
		else
			parent.class.IN[newRelativeId] = parent.class.IN[oldRelativeId];
			parent.class.IN[oldRelativeId] = nil;
		end
		addon.utils.replaceId(currentDraft.class, absoluteId, newAbsoluteId);
		local currentObjectId = currentEditor.cursor.objectId;
		if absoluteId == currentObjectId then 
			currentObjectId = newAbsoluteId;
		elseif addon.utils.isInnerId(absoluteId, currentObjectId) then
			currentObjectId = newAbsoluteId .. currentObjectId:sub(absoluteId:len() + 1);
		end

		currentEditor.cursor.objects[newAbsoluteId] = currentEditor.cursor.objects[absoluteId] or {};

		addon.main.forEachTab(function(_, editor) 
			if editor.creationId == currentEditor.creationId and addon.utils.isInnerIdOrEqual(absoluteId, editor.cursor.objectId) then
				editor.cursor.objectId = editor.cursor.objectId:gsub(absoluteId, newAbsoluteId);
			end
		end);

		rebuildTreeAndShow(currentObjectId);
		return true;
	else
		return false, loc.IN_INNER_NO_AVAILABLE;
	end
end

-- 
function addon.editor.updateCurrentObjectDraft()
	if not currentObject then
		return
	end
	
	currentEditor.cursor.objects[currentEditor.cursor.objectId] = currentEditor.cursor.objects[currentEditor.cursor.objectId] or {};
	local objectCursor = currentEditor.cursor.objects[currentEditor.cursor.objectId];

	if currentObject.class.TY and PROPERTY_EDITORS[currentObject.class.TY] then
		objectCursor.objectRatio = objectEditor.split:GetRatio();
		PROPERTY_EDITORS[currentObject.class.TY]:InterfaceToClass(currentObject.class, objectCursor);
		currentObject.node.data.icon, currentObject.node.data.link = addon.utils.getObjectIconAndLink(currentObject.class);
		addon.editor.refreshObjectTree();
		updateTabBar();
	end

	currentObject.class.MD = currentObject.class.MD or {MO = TRP3_DB.modes.EXPERT}; -- TODO backwards compatibility
	-- MD serves no purpose in non-root objects, but it will crash older versions if not present
	
	objectRibbon:InterfaceToClass(currentObject.class);
	addon.editor.script:InterfaceToClass(currentObject.class, objectCursor);
end

function addon.editor.save()
	if not currentEditor or not currentDraft then
		return
	end
	currentEditor.cursor.treeRatio = editorFrame.split:GetRatio();
	currentEditor.cursor.treeScroll = objectTree.widget:GetScrollPercentage();

	currentEditor.cursor.objects = currentEditor.cursor.objects or {};
	for absoluteId, object in pairs(currentDraft.index or TRP3_API.globals.empty) do
		currentEditor.cursor.objects[absoluteId] = currentEditor.cursor.objects[absoluteId] or {};
		currentEditor.cursor.objects[absoluteId].collapsed = object.node:IsCollapsed();
	end
end

function addon.editor.reset()
	addon.editor.updateCurrentObjectDraft();
	currentEditor = nil;
	currentDraft = nil;
	currentObject = nil;
end

function addon.editor.displayObject(objectId)
	if not currentEditor then
		return
	end
	
	if currentObject then
		currentObject.node.data.active = false;
	end
	
	currentEditor.cursor.objectId = objectId;
	currentObject = currentDraft.index[currentEditor.cursor.objectId];
	
	currentObject.node.data.active = true;
	
	updateTabBar();
	
	for type, editor in pairs(PROPERTY_EDITORS) do
		editor:SetShown(type == currentObject.class.TY);
	end

	currentEditor.cursor.objects[objectId] = currentEditor.cursor.objects[objectId] or {};
	local objectCursor = currentEditor.cursor.objects[objectId];

	objectRibbon:ClassToInterface(currentObject.class);

	if currentObject.class.TY and PROPERTY_EDITORS[currentObject.class.TY] then
		objectEditor.split:SetRatio(objectCursor.objectRatio or 1);
		PROPERTY_EDITORS[currentObject.class.TY]:ClassToInterface(currentObject.class, currentDraft.class, objectCursor);
		addon.main.setTypeBackground(currentObject.class.TY);
	end
	
	addon.editor.script:ClassToInterface(currentObject.class, currentDraft.class, objectCursor);

end

function addon.editor.getCurrentPropertiesEditor()
	if currentObject then
		return PROPERTY_EDITORS[currentObject.class.TY];
	end
end

function addon.editor.getCurrentObjectRelativeId()
	if currentObject then
		return currentObject.node.data.relativeId;
	end
end

function addon.editor.getCurrentObjectAbsoluteId()
	if currentObject then
		return currentObject.node.data.absoluteId;
	end
end

function addon.editor.gatherVariables(scriptContext, restrictScope)
	if not currentDraft then
		return {};
	end
	local acceptScopeW = (restrictScope or "w") == "w";
	local acceptScopeO = (restrictScope or "o") == "o";
	local acceptScopeC = (restrictScope or "c") == "c";
	local result = {};
	local variableManipulationEffects = addon.script.getVariableManipulationEffects();
	local isCutsceneOrDocument = currentObject.class.TY == TRP3_DB.types.DOCUMENT or currentObject.class.TY == TRP3_DB.types.DIALOG;
	local cutsceneOrDocumentCallers = {};

	-- 1. campaign variables from entire creation
	for absoluteId, object in pairs(currentDraft.index) do
		for scriptId, scriptData in pairs(object.class.SC or TRP3_API.globals.empty) do
			for _, stepData in pairs(scriptData.ST or TRP3_API.globals.empty) do
				if stepData.t == TRP3_DB.elementTypes.EFFECT and stepData.e and stepData.e[1] and stepData.e[1].id then
					if acceptScopeC and variableManipulationEffects[stepData.e[1].id] then
						local effectVarSpec = variableManipulationEffects[stepData.e[1].id];
						local effectSpec = addon.script.getEffectById(stepData.e[1].id);
						local args = stepData.e[1].args or TRP3_API.globals.empty;
						if effectSpec.boxed then
							args = args[1] or TRP3_API.globals.empty;
						end
						for _, variable in pairs(effectVarSpec) do
							if (variable.scopeIndex and args[variable.scopeIndex] or variable.scope) == "c" then
								if (args[variable.nameIndex] or "") ~= "" then
									result[args[variable.nameIndex]] = true;
								end
							end
						end
					end
					if isCutsceneOrDocument
					and (stepData.e[1].id == "document_show" or stepData.e[1].id == "dialog_start") 
					and stepData.e[1].args
					and stepData.e[1].args[1] == currentEditor.cursor.objectId
					then
						cutsceneOrDocumentCallers[absoluteId] = cutsceneOrDocumentCallers[absoluteId] or {};
						cutsceneOrDocumentCallers[absoluteId][scriptId] = true;
					end
				end
			end
		end
	end
	
	-- 2. object variables in this object
	if acceptScopeO then
		for variable, _ in pairs(addon.editor.script:GetVariablesByScope("o")) do
			result[variable] = true;
		end
	end
	
	-- 3. campaign variables in this object (most recent edits to script might not have yet been saved to draft)
	if acceptScopeC then
		for variable, _ in pairs(addon.editor.script:GetVariablesByScope("c")) do
			result[variable] = true;
		end
	end

	-- 4. aura variables set anywhere in the creation
	if acceptScopeO and currentObject.class.TY == TRP3_DB.types.AURA then
		for absoluteId, object in pairs(currentDraft.index) do
			for _, scriptData in pairs(object.class.SC or TRP3_API.globals.empty) do
				for _, stepData in pairs(scriptData.ST or TRP3_API.globals.empty) do
					if stepData.t == TRP3_DB.elementTypes.EFFECT and stepData.e and stepData.e[1] and stepData.e[1].id then
						if  stepData.e[1].id == "aura_var_set"
						and stepData.e[1].args
						and stepData.e[1].args[1] == currentEditor.cursor.objectId
						and (stepData.e[1].args[3] or "") ~= ""
						then
							result[stepData.e[1].args[3]] = true;
						end
					end
				end
			end
		end
		for variable, _ in pairs(addon.editor.script:GetAuraVariablesSet(currentEditor.cursor.objectId)) do
			result[variable] = true;
		end
	end

	-- 5. if document or cutscene, object variables of the calling object
	-- 6. if document or cutscene, workflow variables of the calling workflow
	if isCutsceneOrDocument then
		for absoluteId, callerScripts in pairs(cutsceneOrDocumentCallers) do
			local object = currentDraft.index[absoluteId];
			for scriptId, scriptData in pairs(object.class.SC or TRP3_API.globals.empty) do
				for _, stepData in pairs(scriptData.ST or TRP3_API.globals.empty) do
					if stepData.t == TRP3_DB.elementTypes.EFFECT and stepData.e and stepData.e[1] and stepData.e[1].id then
						if variableManipulationEffects[stepData.e[1].id] then
							local effectVarSpec = variableManipulationEffects[stepData.e[1].id];
							local effectSpec = addon.script.getEffectById(stepData.e[1].id);
							local args = stepData.e[1].args or TRP3_API.globals.empty;
							if effectSpec.boxed then
								args = args[1] or TRP3_API.globals.empty;
							end
							for _, variable in pairs(effectVarSpec) do
								if acceptScopeO and (variable.scopeIndex and args[variable.scopeIndex] or variable.scope) == "o" then
									if (args[variable.nameIndex] or "") ~= "" then
										result[args[variable.nameIndex]] = true;
									end
								end
								if acceptScopeW and callerScripts[scriptId] and (variable.scopeIndex and args[variable.scopeIndex] or variable.scope) == "w" then
									if (args[variable.nameIndex] or "") ~= "" then
										result[args[variable.nameIndex]] = true;
									end
								end
							end
						end
					end
				end
			end
		end
	end

	if acceptScopeW and scriptContext then
		for variable, _ in pairs(addon.editor.script:GetWorkflowVariablesFromScript(scriptContext)) do
			result[variable] = true;
		end
	end

	return result;
end

function addon.editor.populateObjectTagMenu(menu, onAccept, scriptContext, eventContext)
	addon.script.addStaticTagsToMenu(menu, onAccept);
	local campaignVars = addon.editor.gatherVariables(scriptContext);
	local campaignVarsSorted = {};
	for variable, _ in pairs(campaignVars) do
		table.insert(campaignVarsSorted, variable);
	end
	table.sort(campaignVarsSorted);
	if TableHasAnyEntries(campaignVarsSorted) then
		local varsMenu = menu:CreateButton("Variable tags");
		varsMenu:SetScrollMode(400);
		for _, variable in ipairs(campaignVarsSorted) do
			varsMenu:CreateButton(variable, onAccept, "${" .. variable .. "}");
		end
	end
	-- TODO all object types are taggable but I think it makes only sense for those that can have a distinct name
	local objectsMenu = menu:CreateButton("Object tags");
	objectsMenu:CreateButton(loc.TYPE_ITEM, function() 
		addon.modal:ShowModal(TRP3_API.popup.OBJECTS, {function(id) onAccept("${" .. id .. "}"); end, TRP3_DB.types.ITEM});
	end);
	objectsMenu:CreateButton(loc.TYPE_AURA, function() 
		addon.modal:ShowModal(TRP3_API.popup.OBJECTS, {function(id) onAccept("${" .. id .. "}"); end, TRP3_DB.types.AURA});
	end);
	objectsMenu:CreateButton(loc.TYPE_CAMPAIGN, function() 
		addon.modal:ShowModal(TRP3_API.popup.OBJECTS, {function(id) onAccept("${" .. id .. "}"); end, TRP3_DB.types.CAMPAIGN});
	end);
	objectsMenu:CreateButton(loc.TYPE_QUEST, function() 
		addon.modal:ShowModal(TRP3_API.popup.OBJECTS, {function(id) onAccept("${" .. id .. "}"); end, TRP3_DB.types.QUEST});
	end);

	if eventContext then
		for _, system in pairs(addon.utils.getGameEvents()) do
			for _, event in pairs(system.EV) do
				if eventContext[event.NA] and TableHasAnyEntries(event.PA) then
					local eventMenu = menu:CreateButton("Event argument");
					TRP3_MenuUtil.SetElementTooltip(eventMenu, event.NA);
					for index, argument in ipairs(event.PA) do
						local argumentMenu = eventMenu:CreateButton(addon.script.formatters.taggable(("${event.%d}"):format(index)) .. ": " .. argument.NA .. " - " .. argument.TY, onAccept, ("${event.%d}"):format(index));
					end
				end
			end
		end
	end
	
end

function addon.editor.createDraft(creationId)
	local draftClass = {};
	TRP3_API.utils.table.copy(draftClass, TRP3_API.extended.getClass(creationId));
	local model, index = buildObjectTree(creationId, draftClass);
	local draft = {
		class       = draftClass,
		model       = model,
		index       = index
	};
	return draft;
end

local function displayRootInfo()
	assert(currentDraft.class.MD, "No metadata MD in root class.");
	statusBar.id:SetText(currentEditor.creationId);
	statusBar.version:SetText(currentDraft.class.MD.V or 0);
	
	local color = "|cffffff00";
	statusBar.creationTime:SetText("|cffff9900" .. loc.ROOT_CREATED:format(color .. (currentDraft.class.MD.CB or "?") .. "|r|cffff9900", "|r" .. color .. (currentDraft.class.MD.CD or "?") .. "|r"));
	statusBar.changeTime:SetText("|cffff9900" .. loc.ROOT_SAVED:format(color .. (currentDraft.class.MD.SB or "?") .. "|r|cffff9900", "|r" .. color .. (currentDraft.class.MD.SD or "?") .. "|r"));

	statusBar.language:SetSelectedValue(addon.main.getObjectLocale(currentDraft.class));
	
	statusBar.save:SetEnabled(TRP3_Tools_DB[currentEditor.creationId] ~= nil);
end

function addon.editor.show(editor)
	currentEditor = editor;
	currentDraft  = addon.main.getDraft(currentEditor.creationId);
	
	displayRootInfo();
	
	local numObjects = 0;
	for absoluteId, object in pairs(currentDraft.index) do
		object.node.data.selected = false;
		object.node.data.active = absoluteId == currentEditor.cursor.objectId;
		numObjects = numObjects + 1;
	end
	
	if not currentEditor.cursor.treeRatio then
		if numObjects > 1 then
			currentEditor.cursor.treeRatio = 1; -- show tree if there are any inner objects
		else
			currentEditor.cursor.treeRatio = 0;
		end
	end
	editorFrame.split:SetRatio(currentEditor.cursor.treeRatio);
	
	objectTree.widget:SetDataProvider(DUMMY_TREE_MODEL);
	if currentEditor.cursor.objects then
		currentDraft.model:CollapseAll();
		for absoluteId, objectCursor in pairs(currentEditor.cursor.objects) do
			if currentDraft.index[absoluteId] then
				currentDraft.index[absoluteId].node:SetCollapsed(objectCursor.collapsed);
			else
				currentEditor.cursor.objects[absoluteId] = nil;
			end
		end
	else
		currentEditor.cursor.objects = {};
		if numObjects <= 20 then
			currentDraft.model:UncollapseAll();
		else
			currentDraft.model:CollapseAll();
			currentDraft.model:GetFirstChildNode():SetCollapsed(false);
		end
	end

	objectTree.model = currentDraft.model;
	objectTree.widget:SetDataProvider(currentDraft.model);
	objectTree.widget:SetScrollPercentage(currentEditor.cursor.treeScroll or 0);
	
	addon.editor.displayObject(currentEditor.cursor.objectId);
end

function addon.editor.refreshObjectTree()
	objectTree:Refresh();
end

local function onSave()
	addon.editor.updateCurrentObjectDraft();
	
	if not TRP3_Tools_DB[currentEditor.creationId] then
		return
	end
	
	-- TODO should we run static analysis by default when saving?
	-- The system previously in place was the "validator"
	
	addon.main.saveDraft(currentEditor.creationId);
	displayRootInfo();
end

function addon.editor.initialize(frame)

	editorFrame  = frame;
	statusBar    = editorFrame.statusBar;
	objectTree   = editorFrame.split.tree; -- = TRP3_ToolFrameEditorTree
	objectEditor = editorFrame.split.object;
	objectRibbon = editorFrame.split.object.objectRibbon;

	addon.editor.object  = objectRibbon;
	addon.editor.script  = objectEditor.split.script;
	
	PROPERTY_EDITORS[TRP3_DB.types.CAMPAIGN]   = objectEditor.split.properties.campaign;
	PROPERTY_EDITORS[TRP3_DB.types.QUEST]      = objectEditor.split.properties.quest;
	PROPERTY_EDITORS[TRP3_DB.types.QUEST_STEP] = objectEditor.split.properties.questStep;
	PROPERTY_EDITORS[TRP3_DB.types.ITEM]       = objectEditor.split.properties.item;
	PROPERTY_EDITORS[TRP3_DB.types.DOCUMENT]   = objectEditor.split.properties.document;
	PROPERTY_EDITORS[TRP3_DB.types.DIALOG]     = objectEditor.split.properties.cutscene;
	PROPERTY_EDITORS[TRP3_DB.types.AURA]       = objectEditor.split.properties.aura;
	
	objectRibbon:Initialize();
	for _, editor in pairs(PROPERTY_EDITORS) do
		editor:Initialize();
	end
	
	addon.editor.script:Initialize();
	
	local template = "|T%s:11:16|t";
	local types = {
		{template:format(addon.main.getObjectLocaleImage("en")), "en"},
		{template:format(addon.main.getObjectLocaleImage("fr")), "fr"},
		{template:format(addon.main.getObjectLocaleImage("es")), "es"},
		{template:format(addon.main.getObjectLocaleImage("de")), "de"},
	}
	TRP3_API.ui.listbox.setupListBox(statusBar.language, types, function(value)
		if currentDraft.class.MD then
			currentDraft.class.MD.LO = value;
		end
	end);
	
	TRP3_API.ui.tooltip.setTooltipForSameFrame(statusBar.static_analysis, "TOP", 0, 0, "Check creation", "Analyzes the creation for potential problems or unexpected behavior.");
	statusBar.static_analysis:SetScript("OnEnter", function(self)
		TRP3_RefreshTooltipForFrame(self);
	end);
	statusBar.static_analysis:SetScript("OnLeave", function(self)
		TRP3_MainTooltip:Hide();
	end);
	statusBar.static_analysis:SetScript("OnClick", function(self)
		addon.editor.updateCurrentObjectDraft();
		addon.static_analysis.run();
	end);

	statusBar.save:SetScript("OnClick", onSave);
	
end
TRP3_API.extended.tools.initEditor = addon.editor.initialize; -- TODO this shouldn't be in the API
