local _, addon = ...
local loc = TRP3_API.loc;

addon.static_analysis = {};

function addon.static_analysis.initialize()
	TRP3_Tools_StaticAnalysis:Initialize();
end

function addon.static_analysis.run()

	local results = {};
	
	local function push(absoluteId, relativeId, class, title, description)
		local icon, link = addon.utils.getObjectIconAndLink(class, relativeId);
		table.insert(results, {
			title       = title,
			description = description,
			location    = absoluteId,
			icon        = icon,
			link        = link
		});
	end

	addon.editor.forEachObjectInCurrentDraft(function(absoluteId, relativeId, class)

		if relativeId:find(TRP3_API.extended.ID_SEPARATOR) then
			push(absoluteId, relativeId, class, "Unsupported id", "It is strongly discouraged to use spaces in the object's id.|nConsider removing the space character from the id.");
		end

		if class.TY == TRP3_DB.types.ITEM and class.BA and class.BA.CR and (tonumber(class.BA.ST) or 0) > 1 then
			push(absoluteId, relativeId, class, "Item is crafted and stackable", "An item shouldn't be crafted and stackable at the same time.");
		end

		if class.TY == TRP3_DB.types.ITEM then
			local useScript = 
				(class.US and class.US.SC and class.SC and class.SC[class.US.SC]) or
				(class.LI and class.LI.OU and class.SC[class.LI.OU])
			; 
			if not useScript and class.BA and class.BA.US then
				push(absoluteId, relativeId, class, "Missing \"use\" workflow", "The item is marked as usable but has no corresponding \"use\" workflow.|nConsider adding a \"when used\" trigger.");
			end
			if useScript and (not class.BA or not class.BA.US) then
				push(absoluteId, relativeId, class, "Missing \"usable\" mark", "The item has a \"when used\" workflow, so it should be marked as usable in the item properties.");
			end
		end

		for scriptId, scriptData in pairs(class.SC or TRP3_API.globals.empty) do
			if not scriptData.ST or TableIsEmpty(scriptData.ST) then
				push(absoluteId, relativeId, class, "Empty workflow", ("The workflow %s does nothing because it has no effects in it.|nConsider deleting it or adding effects."):format(addon.script.formatters.constant(scriptId)));
			else
				local effect = scriptData.ST["1"];
				local count = CountTable(scriptData.ST);
				local nextIndex;
				local lastEffect;
				local hasDelay = false;
				while effect and count > 0 do
					lastEffect = effect;
					nextIndex = nil;
					if effect.t == TRP3_DB.elementTypes.EFFECT then
						nextIndex = effect.n;
						if hasDelay and effect.e and effect.e[1] then
							if effect.e[1].id == "speech_player" and effect.e[1].args and (effect.e[1].args[1] == TRP3_API.ui.misc.SPEECH_PREFIX.SAYS or effect.e[1].args[1] == TRP3_API.ui.misc.SPEECH_PREFIX.YELLS) then
								push(absoluteId, relativeId, class, "Delayed speech effect", ("Sending say or yell messages won't work after a delay.|nConsider moving the effect to the beginning of workflow %s or use an emote message."):format(addon.script.formatters.constant(scriptId)));
							end
							if effect.e[1].id == "secure_macro" then
								push(absoluteId, relativeId, class, "Delayed macro effect", ("The macro effect won't work after a delay.|nConsider moving the effect to the beginning of workflow %s."):format(addon.script.formatters.constant(scriptId)));
							end
						end
					elseif effect.t == TRP3_DB.elementTypes.DELAY then
						hasDelay = true;
						nextIndex = effect.n;
					elseif effect.t == TRP3_DB.elementTypes.CONDITION then
						nextIndex = effect.b and effect.b[1] and effect.b[1].n;
					end
					effect = nextIndex and scriptData.ST[nextIndex];
					count = count - 1;
				end
				if lastEffect and lastEffect.t == TRP3_DB.elementTypes.CONDITION then
					push(absoluteId, relativeId, class, "Condition at the end", ("It doesn't make a lot of sense to have a condition at the end of workflow %s.|nConsider removing the condition or adding more effects afterwards."):format(addon.script.formatters.constant(scriptId)));
				end
				if lastEffect and lastEffect.t == TRP3_DB.elementTypes.DELAY and lastEffect.c == 1 then
					push(absoluteId, relativeId, class, "Delay at the end", ("It doesn't make a lot of sense to have a delay at the end of workflow %s.|nConsider removing the delay or turning it into a cast."):format(addon.script.formatters.constant(scriptId)));
				end
			end
		end

		if class.TY == TRP3_DB.types.QUEST then
			local hasFinalStep = false;
			for stepId, stepClass in pairs(class.ST) do
				if stepClass.BA and stepClass.BA.FI then
					hasFinalStep = true;
					break;
				end
			end
			if not hasFinalStep then
				push(absoluteId, relativeId, class, "Non-completable quest", "A quest should have a final step, otherwise players will never be able to complete it.|nConsider adding a final step or making one of the steps final.");
			end
		end
	end);

	local inaccessibleQuests     = {}; -- Map[absoluteId -> relativeId]
	local inaccessibleQuestSteps = {}; -- Map[absoluteId -> relativeId]
	local inaccessibleObjectives = {}; -- Map[absoluteId -> Map[objectiveId -> relativeId]]
	local inaccessibleAuras      = {}; -- Map[absoluteId -> relativeId]
	local nastyAuras             = {}; -- Map[absoluteId -> relativeId]
	local inaccessibleCutscenes  = {}; -- Map[absoluteId -> relativeId]
	local inaccessibleDocuments  = {}; -- Map[absoluteId -> relativeId]

	addon.editor.forEachObjectInCurrentDraft(function(absoluteId, relativeId, class)
		if class.TY == TRP3_DB.types.QUEST then
			if not class.BA or not class.BA.IN then
				inaccessibleQuests[absoluteId] = relativeId;
			end
			inaccessibleObjectives[absoluteId] = {};
			for objectiveId, objective in pairs(class.OB or TRP3_API.globals.empty) do
				if not objective.AA then
					inaccessibleObjectives[absoluteId][objectiveId] = relativeId;
				end
			end
		end

		if class.TY == TRP3_DB.types.QUEST_STEP and (not class.BA or not class.BA.IN) then
			inaccessibleQuestSteps[absoluteId] = relativeId;
		end

		if class.TY == TRP3_DB.types.AURA then
			inaccessibleAuras[absoluteId] = relativeId;
			if class.BA and (class.BA.DU or math.huge) == math.huge and not class.BA.CC then
				nastyAuras[absoluteId] = relativeId;
			end
		end
		
		if class.TY == TRP3_DB.types.DOCUMENT then
			inaccessibleDocuments[absoluteId] = relativeId;
		end
		
		if class.TY == TRP3_DB.types.DIALOG then
			inaccessibleCutscenes[absoluteId] = relativeId;
		end
	end);

	addon.editor.forEachObjectInCurrentDraft(function(absoluteId, relativeId, class)
		for _, script in pairs(class.SC or TRP3_API.globals.empty) do
			for _, STData in pairs(script.ST) do
				if STData.t == TRP3_DB.elementTypes.EFFECT and STData.e and STData.e[1] and STData.e[1].args then
					local effect = STData.e[1];
					if effect.id == "quest_start" then
						inaccessibleQuests[effect.args[1] or ""] = nil;
					end
					if effect.id == "quest_goToStep" then
						inaccessibleQuestSteps[effect.args[1] or ""] = nil;
					end
					if effect.id == "quest_revealObjective" and inaccessibleObjectives[effect.args[1] or ""] then
						inaccessibleObjectives[effect.args[1] or ""][effect.args[2] or ""] = nil;
					end
					if effect.id == "aura_apply" then
						inaccessibleAuras[effect.args[1] or ""] = nil;
					end
					if effect.id == "aura_remove" then
						nastyAuras[effect.args[1] or ""] = nil;
					end
					if effect.id == "aura_duration" and effect.args[3] == "=" then
						nastyAuras[effect.args[1] or ""] = nil;
					end
					if effect.id == "dialog_start" then
						inaccessibleCutscenes[effect.args[1] or ""] = nil;
					end
					if effect.id == "document_show" then
						inaccessibleDocuments[effect.args[1] or ""] = nil;
					end
				end
			end
		end
	end);

	for absoluteId, relativeId in pairs(inaccessibleQuests) do
		push(absoluteId, relativeId, addon.editor.getCurrentDraftClass(absoluteId), "Unused quest", "This quest appears to be never revealed.|nConsider using the \"reveal quest\" effect or change the quest to be auto-reveal.");
	end

	for absoluteId, relativeId in pairs(inaccessibleQuestSteps) do
		push(absoluteId, relativeId, addon.editor.getCurrentDraftClass(absoluteId), "Unreachable quest step", "This quest step appears to be unreachable.|nConsider using the \"change quest step\" effect or make this step the initial step.");
	end

	for absoluteId, objective in pairs(inaccessibleObjectives) do
		for objectiveId, relativeId in pairs(objective) do
			push(absoluteId, relativeId, addon.editor.getCurrentDraftClass(absoluteId), "Unused objective", ("The quest objective %s appears nowhere to be revealed.|nConsider using the \"reveal objective\" effect or change it to be auto-reveal."):format(addon.script.formatters.constant(objectiveId)));
		end
	end

	for absoluteId, relativeId in pairs(inaccessibleAuras) do
		push(absoluteId, relativeId, addon.editor.getCurrentDraftClass(absoluteId), "Unused aura", "This aura appears not to be applied anywhere.|nConsider using the \"apply aura\" effect.");
	end

	for absoluteId, relativeId in pairs(nastyAuras) do
		push(absoluteId, relativeId, addon.editor.getCurrentDraftClass(absoluteId), "Nasty aura", "It appears that you're creating a non-cancellable aura that lasts indefinitely.|nMake sure the player can eventually remove it or use the \"remove aura\" or \"set aura duration\" effect.");
	end

	for absoluteId, relativeId in pairs(inaccessibleCutscenes) do
		push(absoluteId, relativeId, addon.editor.getCurrentDraftClass(absoluteId), "Unused cutscene", "This cutscene appears not to be started anywhere.|nConsider using the \"start cutscene\" effect.");
	end

	for absoluteId, relativeId in pairs(inaccessibleDocuments) do
		push(absoluteId, relativeId, addon.editor.getCurrentDraftClass(absoluteId), "Unused document", "This document appears not to be shown anywhere.|nConsider using the \"show document\" effect.");
	end

	local creationId = addon.editor.getCurrentDraftCreationId();

	addon.editor.forEachObjectInCurrentDraft(function(absoluteId, relativeId, class)
		for scriptId, script in pairs(class.SC or TRP3_API.globals.empty) do
			for stepId, STData in pairs(script.ST) do
				if STData.t == TRP3_DB.elementTypes.EFFECT and STData.e and STData.e[1] then
					local effectData = STData.e[1];
					local effectSpec = addon.script.getEffectById(effectData.id);
					local args = (effectSpec.boxed and (effectData.args or TRP3_API.globals.empty)[1] or effectData.args) or TRP3_API.globals.empty;
					for paramIndex, parameter in ipairs(effectSpec.parameters) do
						if addon.script.parameter.objectMap[parameter.type] then
							local referencedAbsoluteId = args[paramIndex];
							if referencedAbsoluteId and TRP3_API.extended.classExists(referencedAbsoluteId) and not addon.utils.isInnerIdOrEqual(creationId, referencedAbsoluteId) then
								push(absoluteId, relativeId, class, "Cross-creation reference", ("An object from a different creation is used in step %s of workflow %s.|nIf you plan to share this creation, consider consolidating all required objects into one creation, or share it together with the referenced object."):format(addon.script.formatters.constant(stepId), addon.script.formatters.constant(scriptId)));
							end
						end
					end
				end
				-- TODO external references can also occur in all sorts of conditions, maybe check those as well?
			end
		end
	end);

	local referencedCampaignWorkflows = {};
	local referencedAuraWorkflows = {};
	local referencedItemWorkflows = {};
	addon.editor.forEachObjectInCurrentDraft(function(absoluteId, relativeId, class)
		for scriptId, script in pairs(class.SC or TRP3_API.globals.empty) do
			for stepId, STData in pairs(script.ST) do
				if STData.t == TRP3_DB.elementTypes.EFFECT and STData.e and STData.e[1] then
					local effect = STData.e[1];
					if effect.id == "run_workflow" and effect.args and effect.args[1] == "c" and effect.args[2] then
						referencedCampaignWorkflows[effect.args[2]] = true;
					end
					if effect.id == "var_prompt" and effect.args and effect.args[5] == "c" and effect.args[4] then
						referencedCampaignWorkflows[effect.args[4]] = true;
					end
					if effect.id == "run_item_workflow" and effect.args[2] then
						referencedItemWorkflows[effect.args[2]] = true;
					end
					if effect.id == "aura_run_workflow" and effect.args[1] and effect.args[2] then
						referencedAuraWorkflows[effect.args[1]] = referencedAuraWorkflows[effect.args[1]] or {};
						referencedAuraWorkflows[effect.args[1]][effect.args[2]] = true;
					end
				end
			end
		end
	end);

	addon.editor.forEachObjectInCurrentDraft(function(absoluteId, relativeId, class)
		local unusedScripts = {};
		for scriptId, _ in pairs(class.SC or TRP3_API.globals.empty) do
			unusedScripts[scriptId] = true;
		end
		for scriptId, script in pairs(class.SC or TRP3_API.globals.empty) do
			for stepId, STData in pairs(script.ST) do
				if STData.t == TRP3_DB.elementTypes.EFFECT and STData.e and STData.e[1] then
					if STData.e[1].id == "run_workflow" and STData.e[1].args and STData.e[1].args[1] == "o" and STData.e[1].args[2] then
						unusedScripts[STData.e[1].args[2]] = nil;
					end
					if STData.e[1].id == "var_prompt" and STData.e[1].args and STData.e[1].args[5] == "o" and STData.e[1].args[4] then
						unusedScripts[STData.e[1].args[4]] = nil;
					end
				end
				if STData.t == TRP3_DB.elementTypes.CONDITION and STData.b and STData.b[1] and STData.b[1].failWorkflow then
					unusedScripts[STData.b[1].failWorkflow] = nil;
				end
			end
		end

		if addon.script.supportsTriggerType(class.TY, addon.script.triggerType.OBJECT) then
			for _, scriptId in pairs(class.LI or TRP3_API.globals.empty) do
				unusedScripts[scriptId] = nil;
			end
		end

		if addon.script.supportsTriggerType(class.TY, addon.script.triggerType.ACTION) then
			for _, action in pairs(class.AC or TRP3_API.globals.empty) do
				unusedScripts[action.SC or ""] = nil;
			end
		end

		if addon.script.supportsTriggerType(class.TY, addon.script.triggerType.EVENT) then
			for _, event in pairs(class.HA or TRP3_API.globals.empty) do
				unusedScripts[event.SC or ""] = nil;
			end
		end

		if class.TY == TRP3_DB.types.CAMPAIGN then
			for scriptId, _ in pairs(referencedCampaignWorkflows) do
				unusedScripts[scriptId] = nil;
			end
		end
		if class.TY == TRP3_DB.types.AURA and referencedAuraWorkflows[absoluteId] then
			for scriptId, _ in pairs(referencedAuraWorkflows[absoluteId]) do
				unusedScripts[scriptId] = nil;
			end
		end
		if class.TY == TRP3_DB.types.ITEM then
			for scriptId, _ in pairs(referencedItemWorkflows) do
				unusedScripts[scriptId] = nil;
			end
			if class.US and class.US.SC then
				unusedScripts[class.US.SC] = nil;
			end
		end
		if class.TY == TRP3_DB.types.DOCUMENT then
			for scriptId, _ in pairs(unusedScripts) do
				local linkPattern1 = "{link*" .. scriptId ..  "*"; -- heuristic
				local linkPattern2 = "{link*" .. scriptId ..  "(";
				for _, page in ipairs(class.PA or TRP3_API.globals.empty) do
					if page.TX and (page.TX:find(linkPattern1, 1, true) or page.TX:find(linkPattern2, 1, true)) then
						unusedScripts[scriptId] = nil;
						break;
					end
				end
			end
		end
		if class.TY == TRP3_DB.types.DIALOG then
			for _, step in pairs(class.DS or TRP3_API.globals.empty) do
				if step.WO then
					unusedScripts[step.WO] = nil;
				end
			end
		end

		for scriptId, _ in pairs(unusedScripts) do
			push(absoluteId, relativeId, class, "Unused workflow", ("It seems that the workflow %s isn't used.|nConsider creating a trigger for it or remove it, if you don't need it anymore."):format(addon.script.formatters.constant(scriptId)));
		end
	end);

	addon.modal:ShowModal(TRP3_API.popup.STATIC_ANALYSIS, {results});
end
