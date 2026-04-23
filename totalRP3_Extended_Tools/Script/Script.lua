-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local _, addon = ...
local loc = TRP3_API.loc;

local effects = {};
local operands = {};
local operandMenu;
local operandMenuWithLiterals;
local effectMenu;
local effectMenuRestricted;
local variableManipulationEffects;
local STATIC_PLAYER_TAGS;
local STATIC_TARGET_TAGS;

addon.script = {};

addon.script.triggerType = {
	OBJECT = "LI",
	ACTION = "AC",
	EVENT  = "HA"
};

addon.script.logicalOperation = {
	AND = "+",
	OR  = "*"
};

local UNKNOWN_OBJECT_TRIGGER = {
	text  = "Unknown object trigger %s",
	tt    = "This trigger is unknown. It might have been created with another version of the addon.",
	conditionText = "When %s is triggered",
	icon  = TRP3_InterfaceIcons.Default,
	defaultName = "onObjectTrigger",
	unknown = true
};

local UNKNOWN_ACTION_TRIGGER = {
	text  = "%s",
	icon  = TRP3_InterfaceIcons.Default,
	unknown = true,
	defaultName = "onAction",
	GetFormattedText = function(self, id) 
		return addon.script.formatters.unknown(id or "");
	end
};

local UNKNOWN_OPERAND = {
	id          = nil,
	title       = "Unknown operand",
	description = "This operand is unknown. It might have been created with another version of the addon.",
	GetPreview  = function(self, operand) return addon.script.formatters.unknown(operand.id or ""); end,
	returnType  = "string",
	parameters  = {},
	unknown     = true
};

local UNKNOWN_EFFECT = {
	id          = nil,
	title       = "Unknown effect",
	description = "This effect is unknown. It might have been created with another version of the addon.",
	GetPreview  = function(self, effect) return addon.script.formatters.unknown(effect.id or ""); end,
	icon        = TRP3_InterfaceIcons.Default,
	returnType  = "string",
	parameters  = {},
	canHaveConstraint = true,
	unknown     = true
};

function addon.script:Initialize()

	self.actionTriggers = {};
	self.actionTriggersSorted = {};

	for _, actionId in pairs(TRP3_API.quest.ACTION_TYPES) do
		self.actionTriggers[actionId] = {
			id   = actionId,
			text = TRP3_API.quest.getActionTypeLocale(actionId),
			icon = TRP3_API.quest.getActionTypeIcon(actionId),
			defaultName = "on" .. actionId:lower():gsub("^%l", string.upper),
			GetFormattedText = function(self) 
				return addon.script.formatters.constant(self.text);
			end
		};
		table.insert(self.actionTriggersSorted, self.actionTriggers[actionId]);
	end
	table.sort(self.actionTriggersSorted, function(a, b) return a.id < b.id; end);

	self.comparators = {
		{loc.OP_COMP_EQUALS           , "=="},
		{loc.OP_COMP_NEQUALS          , "~="},
		{loc.OP_COMP_LESSER           , "<"},
		{loc.OP_COMP_LESSER_OR_EQUALS , "<="},
		{loc.OP_COMP_GREATER          , ">"},
		{loc.OP_COMP_GREATER_OR_EQUALS, ">="}
	};

	self.objectTriggers = {
		[TRP3_DB.types.CAMPAIGN] = {
			{
				text  = loc.CA_LINKS_ON_START,
				tt    = loc.CA_LINKS_ON_START_TT,
				conditionText = "When the campaign starts",
				icon  = "achievement_quests_completed_08",
				defaultName = "onStart",
				id = "OS",
			}
		},
		[TRP3_DB.types.QUEST] = {
			{
				text  = loc.QE_LINKS_ON_START,
				tt    = loc.QE_LINKS_ON_START_TT,
				conditionText = "When the quest starts",
				icon  = "achievement_quests_completed_02",
				defaultName = "onStart",
				id = "OS",
			},
			{
				text  = loc.QE_LINKS_ON_OBJECTIVE,
				tt    = loc.QE_LINKS_ON_OBJECTIVE_TT,
				conditionText = "When a quest objective is fulfilled",
				icon  = "achievement_quests_completed_uldum",
				defaultName = "onObjectiveCompleted",
				id = "OOC",
			}
		},
		[TRP3_DB.types.QUEST_STEP] = {
			{
				text  = loc.QE_ST_LINKS_ON_START,
				tt    = loc.QE_ST_LINKS_ON_START_TT,
				conditionText = "When the quest step starts",
				icon  = "achievement_quests_completed_03",
				defaultName = "onStart",
				id = "OS",
			},
			{
				text  = loc.QE_ST_LINKS_ON_LEAVE,
				tt    = loc.QE_ST_LINKS_ON_LEAVE_TT,
				conditionText = "When progressing to another quest step",
				icon  = "achievement_quests_completed_04",
				defaultName = "onLeave",
				id = "OL",
			}
		},
		[TRP3_DB.types.ITEM] = {
			{
				text  = loc.IT_TRIGGER_ON_USE,
				tt    = loc.IT_TRIGGER_ON_USE_TT,
				conditionText = "When the item is used",
				icon  = "ability_paladin_handoflight",
				defaultName = "onUse",
				id = "OU",
			},
			{
				text  = loc.IT_TRIGGER_ON_DESTROY,
				tt    = loc.IT_TRIGGER_ON_DESTROY_TT,
				conditionText = "When the item is destroyed",
				icon  = "spell_sandexplosion",
				defaultName = "onStackDestroy",
				id = "OD",
			},
		},
		[TRP3_DB.types.DOCUMENT] = {
			{
				text  = loc.DO_LINKS_ONOPEN,
				tt    = loc.DO_LINKS_ONOPEN_TT,
				conditionText = "When the document is opened",
				icon  = "inv_inscription_scrollofwisdom_01",
				defaultName = "onOpen",
				id = "OO",
			},
			{
				text  = loc.DO_LINKS_ONCLOSE,
				tt    = loc.DO_LINKS_ONCLOSE_TT,
				conditionText = "When the document is closed",
				icon  = "inv_inscription_scrollofwisdom_02",
				defaultName = "onClose",
				id = "OC",
			}
		},
		[TRP3_DB.types.DIALOG] = {
			{
				text  = loc.DI_LINKS_ONSTART,
				tt    = loc.DI_LINKS_ONSTART_TT,
				conditionText = "When the cutscene starts",
				icon  = "ability_priest_heavanlyvoice",
				defaultName = "onStart",
				id = "OS",
			},
			{
				text  = loc.DI_LINKS_ONEND,
				tt    = loc.DI_LINKS_ONEND_TT,
				conditionText = "When the cutscene ends",
				icon  = "achievement_BG_captureflag_EOS",
				defaultName = "onEnd",
				id = "OE",
			}
		},
		[TRP3_DB.types.AURA] = {
			{
				text  = loc.AU_LINKS_ON_APPLY,
				tt    = loc.AU_LINKS_ON_APPLY_TT,
				conditionText = "When the aura is applied",
				icon  = "ability_priest_spiritoftheredeemer",
				defaultName = "onApply",
				id = "OA",
			},
			{
				text  = loc.AU_LINKS_ON_TICK,
				tt    = loc.AU_LINKS_ON_TICK_TT,
				conditionText = "When the aura ticks",
				icon  = "spell_holy_borrowedtime",
				defaultName = "onTick",
				id = "OT",
			},
			{
				text  = loc.AU_LINKS_ON_EXPIRE,
				tt    = loc.AU_LINKS_ON_EXPIRE_TT,
				conditionText = "When the aura expires",
				icon  = "ability_titankeeper_cleansingorb",
				defaultName = "onExpire",
				id = "OE",
			},
			{
				text  = loc.AU_LINKS_ON_CANCEL,
				tt    = loc.AU_LINKS_ON_CANCEL_TT,
				conditionText = "When the aura is cancelled",
				icon  = "misc_rnrredxbutton",
				defaultName = "onCancel",
				id = "OC",
			},
		},
	};
	-- TODO localize it
	STATIC_PLAYER_TAGS = {
		{"Name"         , "${wow:player}"                     , "Player's name, as returned by UnitName(\"player\")"},
		{"Id"           , "${wow:player:id}"                  , "Player's id in the form of player_name-realm"},
		{"Race"         , "${wow:player:race}"                , "Player's race"},
		{"Class"        , "${wow:player:class}"               , "Player's class"},
		{"RP full name" , "${trp:player:full}"                , "Player's TRP3 first name + last name"},
		{"RP first name", "${trp:player:first}"               , "Player's TRP3 first name"},
		{"RP last name" , "${trp:player:last}"                , "Player's TRP3 last name"},
		{"RP race"      , "${trp:player:race}"                , "Player's TRP3 race"},
		{"RP class"     , "${trp:player:class}"               , "Player's TRP3 class"},
		{"Gender"       , "${gender:player:if_male:if_female}", "if_male if the player is male, if_female if is female"},
	};
	-- TODO localize it
	STATIC_TARGET_TAGS = {
		{"Name"         , "${wow:target}"                     , "Target's name, as returned by UnitName(\"target\") or \"No target\" if no target"},
		{"Id"           , "${wow:target:id}"                  , "Target's id in the form of player_name-realm or \"No target\" if no target"},
		{"Race"         , "${wow:target:race}"                , "Target's race or \"No target\" if no target"},
		{"Class"        , "${wow:target:class}"               , "Target's class or \"No target\" if no target"},
		{"RP full name" , "${trp:target:full}"                , "Target's TRP3 first name + last name or UnitName(\"target\") if does not have TRP3 profile or the NPC custom name if the target is a custom NPC from the active campaign or \"No target\" if no target"},
		{"RP first name", "${trp:target:first}"               , "Target's TRP3 first name or \"No target\" if no target"},
		{"RP last name" , "${trp:target:last}"                , "Target's TRP3 last name or \"No target\" if no target"},
		{"RP race"      , "${trp:target:race}"                , "Target's TRP3 race or \"No target\" if no target"},
		{"RP class"     , "${trp:target:class}"               , "Target's TRP3 class or \"No target\" if no target"},
		{"Gender"       , "${gender:target:if_male:if_female}", "if_male if the target is male, if_female if is female. Unknown if the gender can't be determined"},
	};

	addon.script.formatters:Initialize();
	addon.script.registerBuiltinEffects();
	addon.script.registerBuiltinOperands();

end

function addon.script.addStaticTagsToMenu(menu, onClick)
	local playerTagMenu = menu:CreateButton("Player tags");
	for _, tag in ipairs(STATIC_PLAYER_TAGS) do
		local tagButton = playerTagMenu:CreateButton(tag[1], onClick, tag[2]);
		TRP3_MenuUtil.SetElementTooltip(tagButton, tag[3] .. "|n|n" .. TRP3_API.Colors.Orange(TRP3_API.script.parseArgs(tag[2])));
	end
	local targetTagMenu = menu:CreateButton("Target tags");
	for _, tag in ipairs(STATIC_TARGET_TAGS) do
		local tagButton = targetTagMenu:CreateButton(tag[1], onClick, tag[2]);
		TRP3_MenuUtil.SetElementTooltip(tagButton, tag[3] .. "|n|n" .. TRP3_API.Colors.Orange(TRP3_API.script.parseArgs(tag[2])));
	end
end

function addon.script.getObjectTrigger(objectType, triggerId)
	for index, trigger in ipairs(addon.script.objectTriggers[objectType or ""] or TRP3_API.globals.empty) do
		if triggerId == trigger.id then
			return trigger, index;
		end
	end
	return UNKNOWN_OBJECT_TRIGGER, 0;
end

function addon.script.getActionTrigger(triggerId)
	return addon.script.actionTriggers[triggerId or ""] or UNKNOWN_ACTION_TRIGGER;
end

function addon.script.supportsTriggerType(objectType, triggerType)
	if triggerType == addon.script.triggerType.OBJECT then
		return (objectType and addon.script.objectTriggers[objectType]) and true or false;
	elseif triggerType == addon.script.triggerType.ACTION then
		return objectType == TRP3_DB.types.CAMPAIGN or objectType == TRP3_DB.types.QUEST or objectType == TRP3_DB.types.QUEST_STEP;
	elseif triggerType == addon.script.triggerType.EVENT then
		return objectType == TRP3_DB.types.CAMPAIGN or objectType == TRP3_DB.types.QUEST or objectType == TRP3_DB.types.QUEST_STEP or objectType == TRP3_DB.types.AURA;	
	end
	return false;
end

-- fields
-- id          - internal id
-- title       - title text
-- description - usually in the tooltip
-- summary     - short description using effect parameters
-- type        - list | branch | delay
-- icon        - path to effect icon, realtive to Interface/Icons
-- boxed       - whether or not the parameters are boxed (i.e. args = {{...}} instead of {...})
-- parameters  - table
--     .title
--     .description
--     .type
--     .values
function addon.script.registerEffect(effect)
	assert(effect.id, "no effect id provided");
	assert(effect.GetPreview, "no effect previewer provided");
	assert(not effects[effect.id], "effect with id " .. effect.id .. " already present");
	effect.type = effect.type or TRP3_DB.elementTypes.EFFECT;
	effect.parameters = effect.parameters or {};
	for index, parameter in ipairs(effect.parameters) do
		if parameter.values then
			parameter.dropdownValues = {};
			for _, value in ipairs(parameter.values) do
				table.insert(parameter.dropdownValues, {value[2], value[1], value[3]});
			end
		end
	end
	effect.canHaveConstraint = effect.canHaveConstraint ~= false;
	effects[effect.id] = effect;
	effectMenu = nil;
	effectMenuRestricted = nil;
	variableManipulationEffects = nil;
end
TRP3_API.extended.tools.registerEffect = addon.script.registerEffect;

function addon.script.registerOperand(operand)
	assert(operand.id, "no operand id provided");
	assert(operand.GetPreview, "no operand previewer provided");
	assert(not operands[operand.id], "operand with id " .. operand.id .. " already present");
	operand.parameters = operand.parameters or {};
	for _, parameter in ipairs(operand.parameters) do
		if parameter.values then
			parameter.dropdownValues = {};
			for _, value in ipairs(parameter.values) do
				table.insert(parameter.dropdownValues, {value[2], value[1], value[3]});
			end
		end
	end
	operands[operand.id] = operand;
	operandMenu = nil;
	operandMenuWithLiterals = nil;
end
TRP3_API.extended.tools.registerOperand = addon.script.registerOperand;

local function buildOperandMenu(includeLiterals)
	local menu = {};
	local catIndex = {};
	for id, operand in pairs(operands) do
		if includeLiterals or not operand.literal then
			if operand.category then
				if not catIndex[operand.category] then
					catIndex[operand.category] = #menu + 1;
					table.insert(menu, {operand.category, {}});
				end
				table.insert(menu[catIndex[operand.category]][2], {operand.title, operand.id, operand.description});
			else
				table.insert(menu, {operand.title, operand.id, operand.description});
			end
		end
	end
	table.sort(menu, function(a, b) 
		if type(a[2]) ~= type(b[2]) then
			return type(a[2]) == "string";
		end
		return a[1] < b[1];
	end);
	for index, item in ipairs(menu) do
		if type(item[2]) == "table" then
			table.sort(item[2], function(a, b) 
				return a[1] < b[1];
			end);
		end
	end
	return menu;
end

function addon.script.getOperandMenu(includeLiterals)
	operandMenu = operandMenu or buildOperandMenu(false);
	operandMenuWithLiterals = operandMenuWithLiterals or buildOperandMenu(true);
	return includeLiterals and operandMenuWithLiterals or operandMenu;
end

local function buildEffectMenu(restricted)
	local EFFECT_ORDER_INDEX = {
		[loc.WO_EFFECT_CAT_COMMON]   =  1,
		[loc.EFFECT_CAT_SPEECH]      =  2,
		[loc.INV_PAGE_CHARACTER_INV] =  3,
		[loc.TYPE_DOCUMENT]          =  4,
		[loc.TYPE_AURA]              =  5,
		[loc.EFFECT_CAT_CAMPAIGN]    =  6,
		[loc.EFFECT_CAT_SOUND]       =  7,
		[loc.REG_COMPANIONS]         =  8,
		[loc.EFFECT_CAT_CAMERA]      =  9,
		[loc.MODE_EXPERT]            = 10,
	};

	local menu = {};
	local catIndex = {};
	for id, effect in pairs(effects) do
		if not restricted or effect.type == TRP3_DB.elementTypes.EFFECT then
			local category = effect.category or loc.WO_EFFECT_CAT_COMMON;
			if not catIndex[category] then
				catIndex[category] = #menu + 1;
				table.insert(menu, {category, {}});
			end
			table.insert(menu[catIndex[category]][2], {effect.title, effect.id, effect.description, effect.icon});
		end
	end
	table.sort(menu, function(a, b) 
		if type(a[2]) ~= type(b[2]) then
			return type(a[2]) == "string";
		end
		return (EFFECT_ORDER_INDEX[a[1]] or 0) < (EFFECT_ORDER_INDEX[b[1]] or 0);
	end);
	for index, item in ipairs(menu) do
		if type(item[2]) == "table" then
			table.sort(item[2], function(a, b) 
				return a[1] < b[1];
			end);
		end
	end
	return menu;
end

function addon.script.getEffectMenu(restricted)
	effectMenu = effectMenu or buildEffectMenu();
	effectMenuRestricted = effectMenuRestricted or buildEffectMenu(true);
	return restricted and effectMenuRestricted or effectMenu;
end

local function buildVariableManipulationEffectMap()
	local map = {};
	local tmp = {};
	for id, effect in pairs(effects) do
		wipe(tmp);
		for index, parameter in ipairs(effect.parameters) do
			if parameter.type == "variable" then
				tmp[parameter.groupId or tostring(index)] = {nameIndex = index, scope = parameter.scope};
			end
		end
		for index, parameter in ipairs(effect.parameters) do
			if parameter.type == "scope" and parameter.groupId and tmp[parameter.groupId] then
				tmp[parameter.groupId].scopeIndex = index;
			end
		end
		if TableHasAnyEntries(tmp) then
			map[id] = {};
			for _, manipulationParameter in pairs(tmp) do
				table.insert(map[id], manipulationParameter);
			end
		end
	end
	return map;
end

function addon.script.getVariableManipulationEffects()
	variableManipulationEffects = variableManipulationEffects or buildVariableManipulationEffectMap();
	return variableManipulationEffects;
end

function addon.script.getComparatorText(comparator)
	for index, comp in ipairs(addon.script.comparators) do
		if comp[2] == comparator then
			return addon.script.formatters.comparator(comp[1]);
		end
	end
	return addon.script.formatters.unknown(comparator or "");
end
TRP3_API.extended.tools.getComparatorText = addon.script.getComparatorText;

---------------------------------------------------------------
--               getNormalized* functions                    --
-- convert save file format to an easier to handle UI format --
---------------------------------------------------------------

function addon.script.getNormalizedEffectData(STdata)
	local id;
	local parameters = {};
	local constraint;
	local successor;
	if STdata then
		if STdata.t == TRP3_DB.elementTypes.EFFECT then
			if STdata.e and STdata.e[1] then
				id = STdata.e[1].id;
				if id and effects[id] and effects[id].boxed then
					TRP3_API.utils.table.copy(parameters, STdata.e[1].args and STdata.e[1].args[1] or TRP3_API.globals.empty);
				else
					TRP3_API.utils.table.copy(parameters, STdata.e[1].args);
				end
				constraint = addon.script.getNormalizedConstraintData(STdata.e[1].cond);
				successor = STdata.n;
			end
		elseif STdata.t == TRP3_DB.elementTypes.DELAY then
			id = TRP3_DB.elementTypes.DELAY;
			parameters[1] = STdata.d;
			parameters[2] = STdata.i;
			parameters[3] = STdata.c;
			parameters[4] = STdata.s;
			parameters[5] = STdata.f;
			parameters[6] = STdata.x;
			constraint = {};
			successor = STdata.n;
		elseif STdata.t == TRP3_DB.elementTypes.CONDITION then
			id = TRP3_DB.elementTypes.CONDITION;
			if STdata.b and STdata.b[1] then
				constraint = addon.script.getNormalizedConstraintData(STdata.b[1].cond);
				parameters[1] = STdata.b[1].failMessage;
				parameters[2] = STdata.b[1].failWorkflow;
				successor = STdata.b[1].n;
			end
		end
	end
	return {id = id, parameters = parameters, constraint = constraint}, successor;
end

function addon.script.getNormalizedEffectListData(scriptData)
	local effectList = {};
	if scriptData.ST then
		local count = CountTable(scriptData.ST);
		local effect = scriptData.ST["1"];
		while effect and count > 0 do
			local data, nextIndex = addon.script.getNormalizedEffectData(effect);
			table.insert(effectList, data);
			effect = nextIndex and scriptData.ST[nextIndex];
			count = count - 1;
		end
	end
	return effectList;
end

function addon.script.sanitizeScriptId(scriptId, availableScripts)
	if scriptId and availableScripts[scriptId] then
		return scriptId;
	end
	return nil;
end

function addon.script.getNormalizedTriggerData(class, availableScripts)

	local triggers = {};

	if addon.script.supportsTriggerType(class.TY, addon.script.triggerType.OBJECT) and class.LI then
		for _, trigger in ipairs(addon.script.objectTriggers[class.TY] or TRP3_API.globals.empty) do
			if class.LI[trigger.id] then
				table.insert(triggers, {
					id         = trigger.id,
					script     = addon.script.sanitizeScriptId(class.LI[trigger.id], availableScripts),
					type       = addon.script.triggerType.OBJECT,
					constraint = {}
				});
			end
		end
	end

	-- special case: the "on use" workflow is defined either in US.SC or LI.OU or both
	-- LI.OU takes precedence over US.SC
	-- this is a remnant from the "normal" edit mode auto-generating a workflow for usable items
	if class.TY == TRP3_DB.types.ITEM and class.US and class.US.SC and (not class.LI or not class.LI.OU) then
		table.insert(triggers, {
			id         = "OU",
			script     = addon.script.sanitizeScriptId(class.US.SC, availableScripts),
			type       = addon.script.triggerType.OBJECT,
			constraint = {}
		});
	end

	if addon.script.supportsTriggerType(class.TY, addon.script.triggerType.ACTION) and class.AC then
		for _, trigger in ipairs(class.AC) do
			table.insert(triggers, {
				id         = trigger.TY,
				script     = addon.script.sanitizeScriptId(trigger.SC, availableScripts),
				type       = addon.script.triggerType.ACTION,
				constraint = addon.script.getNormalizedConstraintData(trigger.CO)
			});
		end
	end

	if addon.script.supportsTriggerType(class.TY, addon.script.triggerType.EVENT) and class.HA then
		for _, trigger in ipairs(class.HA) do
			table.insert(triggers, {
				id         = trigger.EV,
				script     = addon.script.sanitizeScriptId(trigger.SC, availableScripts),
				type       = addon.script.triggerType.EVENT,
				constraint = addon.script.getNormalizedConstraintData(trigger.CO)
			});
		end
	end

	return triggers;
end

function addon.script.getNormalizedOperandData(operandData)
	local operand = {
		id = nil,
		parameters = {};
	};
	if type(operandData) == "table" then
		if operandData.v ~= nil then
			if type(operandData.v) == "number" then
				operand.id = "literal_number";
			elseif type(operandData.v) == "boolean" then
				operand.id = "literal_boolean";
			elseif type(operandData.v) == "string" then
				operand.id = "literal_string";
			end
			table.insert(operand.parameters, operandData.v);
		else
			operand.id = tostring(operandData.i);
			if type(operandData.a) == "table" then
				TRP3_API.utils.table.copy(operand.parameters, operandData.a);
			end
		end
	end
	return operand;
end

function addon.script.getNormalizedConstraintData(constraintData)
	local constraint = {};
	if type(constraintData) == "table" then
		local operation = addon.script.logicalOperation.OR;
		for index, constraintLine in ipairs(constraintData) do
			if constraintLine == addon.script.logicalOperation.OR then
				operation = constraintLine;
			elseif constraintLine == addon.script.logicalOperation.AND then
				operation = constraintLine;
			elseif type(constraintLine) == "table" then
				table.insert(constraint, {
					logicalOperation = operation,
					leftTerm         = addon.script.getNormalizedOperandData(constraintLine[1]),
					comparator       = constraintLine[2] or "==",
					rightTerm        = addon.script.getNormalizedOperandData(constraintLine[3])
				});
			end -- else ignore
		end
	end
	return constraint;
end

---------------------------------------------------------------
--               getSaveFormat* functions                    --
--          convert UI format to save file format            --
---------------------------------------------------------------

-- be aware the "n" field is not included
function addon.script.getSaveFormatEffectData(normalizedEffect)
	local effectClass = addon.script.getEffectById(normalizedEffect.id);
	local effectData = {
		t = effectClass.type
	};
	if effectClass.type == TRP3_DB.elementTypes.EFFECT then
		effectData.e = {};
		table.insert(effectData.e, {
			id = normalizedEffect.id
		});
		if TableHasAnyEntries(normalizedEffect.parameters) then
			local args = {};
			TRP3_API.utils.table.copy(args, normalizedEffect.parameters);
			if effectClass.boxed then
				effectData.e[1].args = {args};
			else
				effectData.e[1].args = args;
			end
		end
		effectData.e[1].cond = addon.script.getSaveFormatConstraintData(normalizedEffect.constraint); -- might be nil
	elseif effectClass.type == TRP3_DB.elementTypes.DELAY then
		effectData.d = normalizedEffect.parameters[1];
		effectData.i = normalizedEffect.parameters[2];
		effectData.c = normalizedEffect.parameters[3];
		effectData.s = normalizedEffect.parameters[4];
		effectData.f = normalizedEffect.parameters[5];
		effectData.x = normalizedEffect.parameters[6];
	elseif effectClass.type == TRP3_DB.elementTypes.CONDITION then
		effectData.b = {};
		table.insert(effectData.b, {});
		effectData.b[1].cond = addon.script.getSaveFormatConstraintData(normalizedEffect.constraint);
		effectData.b[1].failMessage = normalizedEffect.parameters[1];
		effectData.b[1].failWorkflow = normalizedEffect.parameters[2];
	end
	return effectData;
end

function addon.script.getSaveFormatEffectListData(normalizedEffectList)
	local effectListData = {
		ST = {}
	};
	for index, normalizedEffect in ipairs(normalizedEffectList) do
		local currIndex = tostring(index);
		effectListData.ST[currIndex] = addon.script.getSaveFormatEffectData(normalizedEffect);
		if index > 1 then
			local prevIndex = tostring(index-1);
			if effectListData.ST[prevIndex].t == TRP3_DB.elementTypes.CONDITION then
				effectListData.ST[prevIndex].b[1].n = currIndex;
			else
				effectListData.ST[prevIndex].n = currIndex;
			end
		end
	end
	return effectListData;
end

function addon.script.getSaveFormatOperandData(normalizedOperand)
	local operandClass = addon.script.getOperandById(normalizedOperand.id);
	local operandData = {};
	if operandClass.literal then
		operandData.v = normalizedOperand.parameters[1];
	else
		operandData.i = normalizedOperand.id;
		if TableHasAnyEntries(normalizedOperand.parameters) then
			operandData.a = {};
			TRP3_API.utils.table.copy(operandData.a, normalizedOperand.parameters);
		end
	end
	return operandData;
end

function addon.script.getSaveFormatConstraintData(normalizedConstraint)
	local constraintData = nil;
	if TableHasAnyEntries(normalizedConstraint) then
		constraintData = {};
		for index, equation in ipairs(normalizedConstraint) do
			if index > 1 then
				table.insert(constraintData, equation.logicalOperation);
			end
			table.insert(constraintData, {
				addon.script.getSaveFormatOperandData(equation.leftTerm),
				equation.comparator,
				addon.script.getSaveFormatOperandData(equation.rightTerm)
			});
		end
	end
	return constraintData;
end



function addon.script.getEffectById(effectId)
	return effects[effectId or ""] or UNKNOWN_EFFECT;
end

function addon.script.getEffectTitle(effect)
	return (effects[effect.id or ""] or UNKNOWN_EFFECT).title;
end

function addon.script.getEffectIcon(effect)
	return (effects[effect.id or ""] or UNKNOWN_EFFECT).icon;
end

function addon.script.getEffectPreview(effect)
	local effectSpec = effects[effect.id or ""] or UNKNOWN_EFFECT;
	return effectSpec:GetPreview(effect, unpack(effect.parameters, 1, #effectSpec.parameters));
end

function addon.script.getEffectSecurity(effect)
	if effect.id == TRP3_DB.elementTypes.DELAY or effect.id == TRP3_DB.elementTypes.CONDITION then
		return TRP3_API.security.SECURITY_LEVEL.HIGH;
	else
		return TRP3_API.security.getEffectSecurity(effect.id);
	end
end

function addon.script.getOperandPreview(operand)
	local operandSpec = operands[operand.id or ""] or UNKNOWN_OPERAND;
	return operandSpec:GetPreview(operand, unpack(operand.parameters, 1, #operandSpec.parameters));
end

function addon.script.getOperandById(id)
	return (operands[id or ""] or UNKNOWN_OPERAND);
end

function addon.script.getTriggerPreview(objectType, triggerId, triggerType)
	local icon, whenText, tooltipTitle, tooltipText;
	if triggerType == addon.script.triggerType.OBJECT then
		local t = addon.script.getObjectTrigger(objectType, triggerId);
		icon         = "Interface\\Icons\\" .. t.icon;
		whenText     = t.conditionText:format(t.id or "nil");
		tooltipTitle = t.text:format(t.id or "nil");
		tooltipText  = t.tt;
	elseif triggerType == addon.script.triggerType.ACTION then
		local t = addon.script.getActionTrigger(triggerId);
		icon         = "Interface\\Icons\\" .. t.icon;
		whenText     = ("When the player uses the action %s"):format(t:GetFormattedText(triggerId));
		tooltipTitle = t.text:format(triggerId or "nil");
		tooltipText  = loc.QUEST_TU_1; -- TODO
	elseif triggerType == addon.script.triggerType.EVENT then
		if triggerId and triggerId:find("TRP3_") == 1 then
			icon = "Interface\\AddOns\\totalRP3_Extended\\resources\\extendedicon";
		else
			icon = "Interface\\Icons\\temp";
		end
		whenText     = ("When the game event %s happens"):format(addon.script.formatters.constant(triggerId));
		tooltipTitle = triggerId or "nil";
		tooltipText  = loc.TU_EL_3_TEXT_V2; -- TODO
	end
	return icon, whenText, tooltipTitle, tooltipText;
end

function addon.script.suggestScriptName(objectType, trigger)
	if trigger.type == addon.script.triggerType.OBJECT then
		local t = addon.script.getObjectTrigger(objectType, trigger.id);
		return t.defaultName;
	elseif trigger.type == addon.script.triggerType.ACTION then
		local t = addon.script.getActionTrigger(trigger.id);
		return t.defaultName;
	elseif trigger.type == addon.script.triggerType.EVENT then
		return ("on_" .. (trigger.id or "event")):lower():gsub("(%_)(%l)", function(_, b) return b:upper(); end);
	end
end

function addon.script.getEffectLua(effectId, parameters)
	local effect = addon.script.getEffectById(effectId);
	local lua = "effect(\"" .. effectId .. "\", args";
	local s = "";
	if effect.boxed then
		lua = lua .. ", {";
	else
		s = ", ";
	end
	if parameters then
		for _, parameter in ipairs(parameters) do
			lua = lua .. s .. addon.utils.serializeLua(parameter);
			s = ", ";
		end
	else
		for _, parameter in ipairs(effect.parameters) do
			lua = lua .. s .. addon.utils.serializeLua(parameter.default);
			s = ", ";
		end
	end
	if effect.boxed then
		lua = lua .. "}";
	end
	lua = lua .. ")";
	return lua;
end

function addon.script.getOperandLua(operandId, parameters)
	local operand = addon.script.getOperandById(operandId);
	local lua = "op(\"" .. operandId .. "\", args";
	if parameters then
		for _, parameter in ipairs(parameters) do
			lua = lua .. ", " .. addon.utils.serializeLua(parameter);
		end
	else
		for _, parameter in ipairs(operand.parameters) do
			lua = lua .. ", " .. addon.utils.serializeLua(parameter.default);
		end
	end
	lua = lua .. ")";
	return lua;
end

function addon.script.getConstraintLua(constraint)
	if constraint and TableHasAnyEntries(constraint) then
		local parenthesis = {};
		local orStart;
		local hasAnd = false;
		for index, equation in ipairs(constraint) do
			local parenthesisByLine = {
				open = "",
				close = ""
			};
			if index > 1 then
				if equation.logicalOperation == addon.script.logicalOperation.OR then
					orStart = orStart or index - 1;
				elseif equation.logicalOperation == addon.script.logicalOperation.AND then
					hasAnd = true;
					if orStart then
						parenthesis[orStart].open = "(";
						parenthesis[index-1].close = ")";
						orStart = nil;
					end
				end
			end
			table.insert(parenthesis, parenthesisByLine);
		end
		if hasAnd and orStart then
			parenthesis[orStart].open = "(";
			parenthesis[#parenthesis].close = ")";
		end
		local lua = "";
		local s = "";
		for index, expression in ipairs(constraint) do
			lua = lua .. s;
			if index > 1 then
				if expression.logicalOperation == addon.script.logicalOperation.OR then
					lua = lua .. " or ";
				elseif expression.logicalOperation == addon.script.logicalOperation.AND then
					lua = lua .. " and ";
				end
			end
			lua = lua .. parenthesis[index].open;
			if addon.script.getOperandById(expression.leftTerm.id).literal then
				lua = lua .. addon.utils.serializeLua(expression.leftTerm.parameters[1]);
			else
				lua = lua .. addon.script.getOperandLua(expression.leftTerm.id, expression.leftTerm.parameters);
			end
			lua = lua .. " " .. expression.comparator .. " ";
			if addon.script.getOperandById(expression.rightTerm.id).literal then
				lua = lua .. addon.utils.serializeLua(expression.rightTerm.parameters[1]);
			else
				lua = lua .. addon.script.getOperandLua(expression.rightTerm.id, expression.rightTerm.parameters);
			end
			lua = lua .. parenthesis[index].close;
			s = "\n";
		end
		return lua;
	else
		return "true";
	end
end
