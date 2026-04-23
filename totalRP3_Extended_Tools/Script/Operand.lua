local _, addon = ...
local loc = TRP3_API.loc;

addon.script.operand = {};

-- this function will only work properly as long as all operand parameters have grid height 1
-- be careful when adding new operands
function addon.script.operand.getOperandEditorExtent(operandId)
	local operand = addon.script.getOperandById(operandId);
	local extent = 0;
	for _, parameter in ipairs(operand.parameters) do
		if not parameter.groupId or parameter.memberIndex == 1 then
			extent = extent + 1;
		end
	end
	return extent;
end

function addon.script.operand.acquireOperandEditor(operandData, widgetList, scriptContextFunction)
	local operandSpec = addon.script.getOperandById(operandData.id);
	local _, groups = addon.script.parameter.acquireWidgets(operandSpec.parameters, widgetList, scriptContextFunction);
	addon.script.parameter.setValues(widgetList, operandSpec.parameters, operandData.parameters, groups);
	local widgetSkipList = {};
	for groupId, group in pairs(groups) do
		local first = math.min(unpack(group));
		for index, mIndex in ipairs(group) do
			if mIndex > first then
				widgetSkipList[mIndex] = true;
			end
		end
	end
	return widgetSkipList;
end

function addon.script.operand.getDefaultOperandEditorValues(operandData)
	local operandSpec = addon.script.getOperandById(operandData.id);
	wipe(operandData.parameters);
	for index, parameter in ipairs(operandSpec.parameters) do
		table.insert(operandData.parameters, parameter.default);
	end
end

function addon.script.operand.getOperandEditorValues(operandData, widgetList)
	local operandSpec = addon.script.getOperandById(operandData.id);
	wipe(operandData.parameters);
	return addon.script.parameter.getValues(widgetList, operandSpec.parameters, operandData.parameters);
end

function addon.script.operand.releaseOperandEditor(widgetList)
	addon.script.parameter.releaseWidgets(widgetList);
end
