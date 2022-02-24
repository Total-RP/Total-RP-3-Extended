----------------------------------------------------------------------------------
--- Total RP 3
--- Scripts : Time Operands
---	---------------------------------------------------------------------------
--- Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
--- Copyright 2019 Morgane "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---
--- Licensed under the Apache License, Version 2.0 (the "License");
--- you may not use this file except in compliance with the License.
--- You may obtain a copy of the License at
---
---  http://www.apache.org/licenses/LICENSE-2.0
---
--- Unless required by applicable law or agreed to in writing, software
--- distributed under the License is distributed on an "AS IS" BASIS,
--- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--- See the License for the specific language governing permissions and
--- limitations under the License.
----------------------------------------------------------------------------------

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

