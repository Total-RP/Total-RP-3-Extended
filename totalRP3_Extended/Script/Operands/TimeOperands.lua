-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

---@type TotalRP3_Extended_NumericOperand
local NumericOperand = TRP3_API.script.NumericOperand;

local timeHourOperand = NumericOperand("time_hour", {
	["GetGameTime"] = "GetGameTime"
});

function timeHourOperand:CodeReplacement()
	return "({GetGameTime()})[1]";
end

local timeMinuteOperand = NumericOperand("time_minute", {
	["GetGameTime"] = "GetGameTime"
})

function timeMinuteOperand:CodeReplacement()
	return "({GetGameTime()})[2]";
end

local dateDayOperand = NumericOperand("date_day", {
	["date"] = "date"
})

function dateDayOperand:CodeReplacement()
	return "date(\"*t\").day";
end

local dateMonthOperand = NumericOperand("date_month", {
	["date"] = "date"
})

function dateMonthOperand:CodeReplacement()
	return "date(\"*t\").month";
end

local dateYearOperand = NumericOperand("date_year", {
	["date"] = "date"
})

function dateYearOperand:CodeReplacement()
	return "date(\"*t\").year";
end

local dateDayOfWeekOperand = NumericOperand("date_day_of_week", {
	["date"] = "date"
})

function dateDayOfWeekOperand:CodeReplacement()
	return "date(\"*t\").wday";
end
