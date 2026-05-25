local _, addon = ...

local paramaterPoolCollection = CreateFramePoolCollection();

local function getWidget(template)
	paramaterPoolCollection:GetOrCreatePool("Frame", nil, template);
	return paramaterPoolCollection:Acquire(template);
end

addon.script.parameter = {};

addon.script.parameter.objectMap = {
	["aura"]     = TRP3_DB.types.AURA,
	["item"]     = TRP3_DB.types.ITEM,
	["campaign"] = TRP3_DB.types.CAMPAIGN,
	["quest"]    = TRP3_DB.types.QUEST,
	["step"]     = TRP3_DB.types.QUEST_STEP,
	["document"] = TRP3_DB.types.DOCUMENT,
	["dialog"]   = TRP3_DB.types.DIALOG
};

local templateMap = {
	["sound"]      = "TRP3_Tools_ScriptParameterSoundTemplate",
	["coordinate"] = "TRP3_Tools_ScriptParameterCoordinateTemplate",
	["boolean"]    = "TRP3_Tools_ScriptParameterBooleanTemplate",
	["music"]      = "TRP3_Tools_ScriptParameterMusicTemplate",
	["emote"]      = "TRP3_Tools_ScriptParameterEmoteTemplate",
	["multiline"]  = "TRP3_Tools_ScriptParameterMultilineTemplate",
	["icon"]       = "TRP3_Tools_ScriptParameterIconTemplate",
	["loot"]       = "TRP3_Tools_ScriptParameterLootTemplate",
	["operand"]    = "TRP3_Tools_ScriptParameterOperandTemplate",
	["script"]     = "TRP3_Tools_ScriptParameterScriptTemplate",
	["macro"]      = "TRP3_Tools_ScriptParameterMacroTemplate",
	["variable"]   = "TRP3_Tools_ScriptParameterVariableTemplate",
	["objective"]  = "TRP3_Tools_ScriptParameterObjectiveTemplate",
};

local function getGroupsFromParameterList(parameters)
	local groups = {};
	for index, parameter in ipairs(parameters) do
		if parameter.groupId then
			groups[parameter.groupId] = groups[parameter.groupId] or {};
			table.insert(groups[parameter.groupId], index);
		end
	end
	for _groupId, members in pairs(groups) do
		table.sort(members, function(m1, m2)
			return parameters[m1].memberIndex < parameters[m2].memberIndex;
		end);
	end
	return groups;
end

function addon.script.parameter.acquireWidgets(parameters, widgetList, scriptContextFunction)
	widgetList = widgetList or {};
	local groups = getGroupsFromParameterList(parameters);
	for index, parameter in ipairs(parameters) do
		local widget;
		if parameter.groupId then
			local firstIndex = math.min(unpack(groups[parameter.groupId]));
			if index == firstIndex then
				local leadParameter = parameters[groups[parameter.groupId][1]];
				local groupParameters = {};
				for _, memberIndex in ipairs(groups[parameter.groupId]) do
					table.insert(groupParameters, parameters[memberIndex]);
				end
				if templateMap[leadParameter.type] then
					widget = getWidget(templateMap[leadParameter.type]);
					widget:Setup(widgetList, unpack(groupParameters));
				else
					assert(false, "group '" .. leadParameter.type .. "' not implemented");
				end
			else
				widget = widgetList[firstIndex];
			end
		elseif parameter.values then
			widget = getWidget("TRP3_Tools_ScriptParameterDropdownTemplate");
			widget:Setup(widgetList, parameter);
		elseif addon.script.parameter.objectMap[parameter.type] then
			widget = getWidget("TRP3_Tools_ScriptParameterObjectTemplate");
			widget:Setup(widgetList, parameter);
		elseif templateMap[parameter.type] then
			widget = getWidget(templateMap[parameter.type]);
			widget:Setup(widgetList, parameter);
		else
			widget = getWidget("TRP3_Tools_ScriptParameterEditBoxTemplate");
			widget:Setup(widgetList, parameter);
		end
		widget:SetScriptContext(scriptContextFunction);
		table.insert(widgetList, widget);
	end
	return widgetList, groups;
end

function addon.script.parameter.setValues(widgets, parameters, values, groups)
	groups = groups or getGroupsFromParameterList(parameters);
	for index, parameter in ipairs(parameters) do
		if parameter.groupId then
			local group = groups[parameter.groupId];
			if index == group[1] then
				local v = {};
				for gIndex, mIndex in ipairs(group) do
					v[gIndex] = values[mIndex]; -- table.insert(v, values[mIndex]);
				end
				widgets[index]:SetValue(unpack(v, 1, #group));
			end
		else
			widgets[index]:SetValue(values[index]);
		end
	end
end

function addon.script.parameter.getValues(widgets, parameters, values)
	values = values or {};
	for index, parameter in ipairs(parameters) do
		local value;
		if parameter.groupId then
			value = select(parameter.memberIndex, widgets[index]:GetValue());
		else
			value = widgets[index]:GetValue();
		end
		if parameter.type == "number" or parameter.type == "integer" or parameter.type == "achievement" or parameter.type == "coordinate" then
			local numericValue = tonumber(value);
			if numericValue and (parameter.type == "integer" or parameter.type == "achievement") then
				numericValue = math.floor(numericValue);
			end
			if parameter.taggable then
				value = numericValue or value or parameter.default;
			else
				value = numericValue or parameter.default;
			end
		end
		if parameter.nillable and value == "" then
			value = nil;
		end
		values[index] = value; -- Not equivalent to table.insert(values, value), some values might be nil!
	end
	return values;
end

function addon.script.parameter.releaseWidgets(widgetList)
	local alreadyReleased = {};
	for _, widget in ipairs(widgetList) do
		local id = tostring(widget);
		if widget and not alreadyReleased[id] then
			paramaterPoolCollection:Release(widget);
			alreadyReleased[id] = true;
		end
	end
	wipe(widgetList);
end
