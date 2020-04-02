----------------------------------------------------------------------------------
-- Total RP 3
-- Scripts : Code generation
-- ---------------------------------------------------------------------------
-- Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
----------------------------------------------------------------------------------

TRP3_API.script = {};

local EMPTY = TRP3_API.globals.empty;
local assert, type, tostring, error, tonumber, pairs, ipairs, loadstring, wipe, strsplit = assert, type, tostring, error, tonumber, pairs, ipairs, loadstring, wipe, strsplit;
local tableCopy = TRP3_API.utils.table.copy;
local log, logLevel = TRP3_API.utils.log.log, TRP3_API.utils.log.level;
local getUnitID, isUnitIDKnown, getUnitIDCurrentProfile = TRP3_API.utils.str.getUnitID, TRP3_API.register.isUnitIDKnown, TRP3_API.register.getUnitIDCurrentProfile;
local writeElement;
local loc = TRP3_API.loc;

local DEBUG = false;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Utils
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function escapeString(value)
	return value:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n");
end

-- Escape string arguments, to avoid script injection
local function escapeArguments(args)
	if not args then return end
	local escaped = {};
	for index, arg in pairs(args) do
		if type(arg) == "string" then
			escaped[index] = escapeString(arg);
		else
			escaped[index] = arg;
		end
	end
	return escaped;
end

TRP3_API.script.escapeArguments = escapeArguments;

TRP3_API.script.eval = function(conditionValue, conditionID, conditionStorage)
	if conditionID then
		conditionStorage[conditionID] = conditionValue;
	end
	return conditionValue;
end

local after = C_Timer.After;
TRP3_API.script.delayed = function(delay, func)
	if func and delay then
		after(delay, func);
	end
end
TRP3_API.script.cast = function(delay, func)
	if GetUnitSpeed("player") == 0 then
		if func and delay then
			after(delay, func);
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Script parsing
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local EFFECT_MISSING_ID = "MISSING";

local function getEffectInfo(id)
	return TRP3_API.script.getEffect(id) or TRP3_API.script.getEffect(EFFECT_MISSING_ID);
end

local function playEffect(effectID, shouldBeSecured, eArgs, ...)
	local cArgs = {...};
	local effectInfo = getEffectInfo(effectID);
	if effectInfo then
		if shouldBeSecured and effectInfo.securedMethod then
			effectInfo.securedMethod(effectInfo, cArgs, eArgs);
		elseif effectInfo.method then
			effectInfo.method(effectInfo, cArgs, eArgs);
		else
			error("This effect ID is unknown or can't be used in script: " .. effectID);
		end
	end
end
TRP3_API.script.playEffect = playEffect;


local function operand(operandID, eArgs, ...)
	local cArgs = {...};
	---@type TotalRP3_Extended_Operand
	local operandInfo = TRP3_API.script.getOperand(operandID);
	if operandInfo then
		local code = "return function(args)\nreturn " .. operandInfo:CodeReplacement(escapeArguments(cArgs) or EMPTY) .. "\nend;";
		-- Compile
		-- TODO: with proper method
		local factory, errorMessage = loadstring(code, "Generated direct operand code");
		if not factory then
			error("Error in script effect:\n" .. errorMessage);
		end
		return factory()(eArgs);
	else
		error("This operand ID is unknown or can't be used in script: " .. operandID);
	end
end

local function effect(effectID, eArgs, ...)
	playEffect(effectID, false, eArgs, ...);
end

local function securedEffect(effectID, eArgs, ...)
	playEffect(effectID, true, eArgs, ...);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Writer
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local CURRENT_CODE, CURRENT_INDENT, CURRENT_STRUCTURE, CURRENT_CLASS_ID;
local CURRENT_ENVIRONMENT = {};
local INDENT_CHAR = "\t";

local function writeLine(code, onTop)
	if onTop then
		CURRENT_CODE = CURRENT_INDENT .. code .. "\n" .. CURRENT_CODE;
	else
		CURRENT_CODE = CURRENT_CODE .. CURRENT_INDENT .. code .. "\n";
	end
end

local function addIndent()
	CURRENT_INDENT = CURRENT_INDENT .. INDENT_CHAR;
end

local function removeIndent()
	if CURRENT_INDENT:len() > 1 then
		CURRENT_INDENT = CURRENT_INDENT:sub(1, -2);
	else
		CURRENT_INDENT = "";
	end
end

local function startIf(content)
	writeLine(("if %s then"):format(content));
	addIndent();
end

local function closeBlock()
	removeIndent();
	writeLine("end");
end

local function doElse()
	removeIndent();
	writeLine("else");
	addIndent();
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LEVEL 1 : Test
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function writeOperand(testStructure, comparatorType, env)
	local code;
	assert(type(testStructure) == "table", "testStructure is not a table");
	assert(testStructure.v ~= nil or testStructure.i ~= nil, "No operand info");

	if testStructure.v ~= nil then
		if comparatorType == "number" then
			assert(tonumber(testStructure.v) ~= nil, "Cannot parse operand numeric value: " .. testStructure.v);
			code = testStructure.v;
		else
			code = "var(\"" .. escapeString(tostring(testStructure.v)) .. "\", args)";
		end
	else
		---@type TotalRP3_Extended_Operand
		local operandInfo = TRP3_API.script.getOperand(testStructure.i);
		assert(operandInfo, "Unknown operand ID: " .. testStructure.i);
		assert(comparatorType ~= "number" or operandInfo.numeric, "Operand ID is not numeric: " .. testStructure.i);

		if comparatorType == "number" then
			code = ("(tonumber(%s) or -1)"):format(operandInfo:CodeReplacement(escapeArguments(testStructure.a) or EMPTY));
		else
			code = ("tostring(%s)"):format(operandInfo:CodeReplacement(escapeArguments(testStructure.a) or EMPTY));
		end


		-- Register operand environment
		if operandInfo.env then
			for map, g in pairs(operandInfo.env) do
				(env or CURRENT_ENVIRONMENT)[map] = g;
			end
		end
	end
	return code;
end

local function writeTest(testStructure, env)
	assert(testStructure, "testStructure is nil");
	assert(#testStructure == 3, "testStructure should have three components");
	local comparator, comparatorType;

	-- Comparator
	assert(type(testStructure[2]) == "string", "testStructure comparator is not a string");
	local comparator = tostring(testStructure[2]);
	if comparator == "<" or comparator == ">" or comparator == "<=" or comparator == ">=" then
		comparatorType = "number";
	elseif comparator == "==" or comparator == "~=" then
		comparatorType = "string";
	else
		error("Unknown comparator: " .. tostring(comparator));
	end

	-- Left operande
	local left = writeOperand(testStructure[1], comparatorType, env);

	-- Right operand
	local right = writeOperand(testStructure[3], comparatorType, env)

	-- Write code
	return ("%s %s %s"):format(left, comparator, right);
end
TRP3_API.script.getTestCode = writeTest;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LEVEL 2 : Condition
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function writeCondition(conditionStructure, conditionID, env)
	assert(type(conditionStructure) == "table", "conditionStructure is not a table");
	local code = "";
	local previousType;
	local isInParenthesis = false;
	for index, element in ipairs(conditionStructure) do
		if type(element) == "string" then
			assert(index > 1 and index < #conditionStructure, ("Can't have a logic operator at start or end: index %s for operator %s"):format(index, element));
			assert(previousType ~= "string", "Can't have two successive logic operator");
			if element == "+" then
				code = code .. "and" .. " ";
			elseif element == "*" then
				code = code .. "or" .. " ";
			else
				error("Unknown logic operator: " .. element);
			end
		elseif type(element) == "table" then
			assert(previousType ~= "table", "Can't have two successive tests");
			if index == #conditionStructure and isInParenthesis then -- End of condition
				code = code .. writeTest(element, env) .. " ) ";
				isInParenthesis = false;
			elseif index < #conditionStructure then
				if conditionStructure[index + 1] == "+" and isInParenthesis then
					code = code .. writeTest(element, env) .. " ) ";
					isInParenthesis = false;
				elseif conditionStructure[index + 1] == "*" and not isInParenthesis then
					code = code .. "( " .. writeTest(element, env) .. " ";
					isInParenthesis = true;
				else
					code = code .. writeTest(element, env) .. " ";
				end
			else
				code = code .. writeTest(element, env) .. " ";
			end
		else
			error("Unknown condition element: " .. element);
		end
		previousType = type(element);
	end

	if conditionID then
		code = ("eval(%s, \"%s\", conditionStorage)"):format(code, conditionID);
	end

	return code;
end
TRP3_API.script.getConditionCode = writeCondition;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LEVEL 3 : Effect
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getTableAsString(table)
	local str = "{";
	for i, v in pairs(table) do
		if type(i) == "string" then
			str = str .. "[\"" .. i .. "\"] = ";
		end
		if type(v) == "string" then
			str = str .. "\"" .. v .. "\"";
		elseif type(v) == "table" then
			local escaped = escapeArguments(v);
			str = str .. getTableAsString(escaped);
		else
			str = str .. tostring(v);
		end
		if type(i) == "string" or i < #table then
			str = str .. ", ";
		end
	end
	str = str .. "}";
	return str;
end

local function writeEffect(effectStructure)
	assert(type(effectStructure) == "table", "effectStructure is not a table");
	assert(effectStructure.id, "Effect don't have ID");
	local effectInfo = getEffectInfo(effectStructure.id);
	assert(effectInfo, "Unknown effect ID: " .. effectStructure.id);

	local effectCode, isSecure;

	if TRP3_DB.inner[CURRENT_CLASS_ID] ~= nil or not effectInfo.secured or effectInfo.secured == TRP3_API.security.SECURITY_LEVEL.HIGH then
		isSecure = true;
	elseif effectInfo.secured ~= TRP3_API.security.SECURITY_LEVEL.HIGH then
		isSecure = TRP3_API.security.resolveEffectSecurity(CURRENT_CLASS_ID, effectStructure.id);
	end

	-- Secured
	effectCode = "effect(\"" .. effectStructure.id .. "\", " .. tostring(not isSecure) .. ", args";

	-- Compilation args
	local cArgs = escapeArguments(effectStructure.args) or EMPTY;
	for i, v in pairs(cArgs) do
		effectCode = effectCode .. ", ";
		if type(v) == "string" then
			effectCode = effectCode .. "\"" .. v .. "\"";
		elseif type(v) == "table" then
			local escaped = escapeArguments(v);
			effectCode = effectCode .. getTableAsString(escaped);
		else
			effectCode = effectCode .. tostring(v);
		end
	end
	effectCode = effectCode .. ");";

	if effectStructure.cond and #effectStructure.cond > 0 then
		startIf(writeCondition(effectStructure.cond, effectStructure.condID));
	end

	writeLine(effectCode);

	if effectStructure.cond and #effectStructure.cond > 0 then
		closeBlock();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LEVEL 4  : Effects list
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function writeEffectList(listStructure)
	assert(type(listStructure.e) == "table", "listStructure.e is not a table");

	for _, effect in pairs(listStructure.e) do
		writeEffect(effect);
	end

	if listStructure.n then
		writeElement(listStructure.n);
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LEVEL 4  : Branching
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function writeBranching(branchStructure)
	assert(type(branchStructure.b) == "table", "branchStructure.b is not a table");
	if #branchStructure.b == 0 then return; end

	for index, branch in pairs(branchStructure.b) do
		if DEBUG then
			writeLine("-- branch " .. index);
		end
		if branch.cond and #branch.cond > 0 then
			startIf(writeCondition(branch.cond, branch.condID));
		end
		if branch.n then
			writeElement(branch.n);
		end
		if DEBUG then
			writeLine("");
		end
		if branch.failMessage or branch.failWorkflow then
			doElse();
			if branch.failMessage then
				CURRENT_ENVIRONMENT["message"] = "TRP3_API.utils.message.displayMessage";
				writeLine(("message(\"%s\", 4)"):format(escapeString(branch.failMessage)));
			end
			if branch.failWorkflow then
				CURRENT_ENVIRONMENT["executeClassScript"] = "TRP3_API.script.executeClassScript";
				writeLine(("executeClassScript(\"%s\", args.scripts, args, args.classID);"):format(escapeString(branch.failWorkflow)));
			end
		end
		if branch.cond and #branch.cond > 0 then
			closeBlock();
		end
		if DEBUG then
			writeLine("");
		end
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LEVEL 4  : Delay
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function writeDelay(delayStructure)
	assert(type(delayStructure.d) == "number", "listStructure duration is not a number");

	if delayStructure.c == 2 then
		-- Casting bar
		writeLine(("castID = showCastingBar(%s, %s, args.class, %s, var(\"%s\", args))"):format(delayStructure.d, delayStructure.i or 1, delayStructure.s or 0, delayStructure.x or ""));
		CURRENT_ENVIRONMENT["showCastingBar"] = "TRP3_API.extended.showCastingBar";

		if delayStructure.i == 2 then
			CURRENT_ENVIRONMENT["cast"] = "TRP3_API.script.cast";
			writeLine(("cast(%s, function() "):format(delayStructure.d));
		else
			writeLine(("delayed(%s, function() "):format(delayStructure.d));
		end
	else
		writeLine(("delayed(%s, function() "):format(delayStructure.d));
	end
	addIndent();

	-- Interruption
	if delayStructure.i == 2 then
		CURRENT_ENVIRONMENT["castBar"] = "TRP3_CastingBarFrame";
		writeLine(("if castID ~= castBar.castID then return; end"):format(delayStructure.d));
	end

	if delayStructure.n then
		writeElement(delayStructure.n);
	end
	removeIndent();
	if DEBUG then
		writeLine("");
	end
	writeLine("end);");
	if DEBUG then
		writeLine("");
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LEVEL 5  : Thread
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

writeElement = function(elementID)
	assert(elementID, "elementID is nil");
	local element = CURRENT_STRUCTURE[elementID];

	if DEBUG then
		writeLine("");
		writeLine("-- Element " .. elementID);
	end

	if not element then
		if DEBUG then
			writeLine("-- WARNING: Unknown element ID: " .. elementID);
		end
		return;
	end

	if element.t == "list" then
		writeEffectList(element);
	elseif element.t == "branch" then
		writeBranching(element);
	elseif element.t == "delay" then
		writeDelay(element);
	else
		error("Unknown element type: " .. tostring(element.t));
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Main
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
local BASE_ENV = { ["tostring, EMPTY, delayed, eval, tonumber, var, effect"]
= "tostring, TRP3_API.globals.empty, TRP3_API.script.delayed, TRP3_API.script.eval, tonumber, TRP3_API.script.parseArgs, TRP3_API.script.playEffect" };

local IMPORT_PATTERN = "local %s = %s;";

local function generateFromCode(code)
	-- Generating factory
	local func, errorMessage = loadstring(code, "Generated code");
	if not func then
		print(errorMessage); -- TODO: could happens if syntax error, make a proper message
		return nil, code;
	end

	return func, code;
end

local function writeImports()
	for alias, global in pairs(CURRENT_ENVIRONMENT) do
		writeLine(IMPORT_PATTERN:format(alias, global), true);
	end
	if DEBUG then
		writeLine("-- Imports", true);
	end
end

local function generateCode(effectStructure, rootClassID)
	CURRENT_CLASS_ID = rootClassID;
	CURRENT_CODE = "";
	CURRENT_INDENT = "";

	wipe(CURRENT_ENVIRONMENT);
	tableCopy(CURRENT_ENVIRONMENT, BASE_ENV);

	CURRENT_STRUCTURE = effectStructure;

	writeLine("local func = function(args)");
	addIndent();
	writeLine("args = args or EMPTY;");
	writeLine("if not args.custom then args.custom = {}; end");
	writeLine("local conditionStorage = {};"); -- Store conditions evaluation
	writeLine("local castID;"); -- For any casting bar
	writeElement("1"); -- 1 is always the first element
	writeLine("return 0, conditionStorage;");
	closeBlock();
	writeImports();
	writeLine("setfenv(func, {});");
	writeLine("return func;");

	return CURRENT_CODE;
end

local function generate(effectStructure, rootClassID)
	log("Generate FX", logLevel.DEBUG);
	local code = generateCode(effectStructure, rootClassID);
	return generateFromCode(code);
end

local function getFunction(structure, rootClassID)
	local functionFactory, code = generate(structure, rootClassID);

	if DEBUG then
		TRP3_DEBUG_CODE_FRAME:Show();
		TRP3_DEBUG_CODE_FRAME.scroll.text:SetText(code);
	end

	if functionFactory then
		return functionFactory();
	end
end

local pcall = pcall;
local function executeFunction(func, args, scriptID)
	local status, ret, _ = pcall(func, args);
	if status then
		--		if DEBUG then TRP3_API.utils.table.dump(conditions); end
		return ret;
	else
		TRP3_API.utils.message.displayMessage(loc.SEC_SCRIPT_ERROR:format(scriptID or "preview"), 4);
		TRP3_API.utils.message.displayMessage("|cffff0000" .. tostring(ret));
	end
end
TRP3_API.script.executeFunction = executeFunction;

local compiledScript = {}

local function executeClassScript(scriptID, classScripts, args, fullID)
	assert(scriptID and classScripts, "Missing arguments.");
	assert(fullID, "ClassID is needed for security purpose.");


	if not classScripts[scriptID] then
		TRP3_API.utils.message.displayMessage("|cffff0000" .. loc.SEC_MISSING_SCRIPT:format(scriptID), 4);
		return;
	end

	local parts = {strsplit(TRP3_API.extended.ID_SEPARATOR, fullID)};
	local rootClassID = parts[1];
	local class = classScripts[scriptID];

	-- Not compiled yet
	if not compiledScript[fullID] or not compiledScript[fullID][scriptID] then
		if not compiledScript[fullID] then
			compiledScript[fullID] = {};
		end
		compiledScript[fullID][scriptID] = getFunction(class.ST, rootClassID);
	end
	if not args then
		args = {};
	end
	args.scripts = classScripts;
	args.classID = fullID;
	return executeFunction(compiledScript[fullID][scriptID], args, scriptID);
end
TRP3_API.script.executeClassScript = executeClassScript;

function TRP3_API.script.clearCompilation(classID)
	if compiledScript[classID] then
		wipe(compiledScript[classID]);
	end
	compiledScript[classID] = nil;
end

function TRP3_API.script.clearRootCompilation(rootClassID)
	for classID, compilations in pairs(compiledScript) do
		if classID:sub(1, rootClassID:len()) == rootClassID then
			wipe(compiledScript[classID]);
			compiledScript[classID] = nil;
		end
	end
end

function TRP3_API.script.clearAllCompilations()
	wipe(compiledScript);
end

function TRP3_API.script.generateAndRun(code, args, env)
	code = "local func = function(args)\n" .. code .. "\nend setfenv(func, {}); return func;";

	env = env or {};
	tableCopy(env, BASE_ENV);
	for alias, global in pairs(env) do
		code = "\n" .. IMPORT_PATTERN:format(alias, global) .. code;
	end

	if DEBUG then
		print(code);
	end

	-- Generating factory
	local func, errorMessage = loadstring(code, "Generated code");
	if not func then
		print(errorMessage);
		return nil, code;
	end

	-- Execute
	return func()(args or EMPTY);
end

local directConditionTemplate = [[return %s;]]

local function generateAndRunCondition(conditionStructure, args)
	if not conditionStructure then
		return true;
	end
	local env = {};
	tableCopy(env, BASE_ENV);
	local code = directConditionTemplate:format(writeCondition(conditionStructure, nil, env));

	return TRP3_API.script.generateAndRun(code, args, env);
end
TRP3_API.script.generateAndRunCondition = generateAndRunCondition;

function TRP3_API.script.runWorkflow(args, source, workflowID, slotID)
	if source == "o" then
		-- Workflow in the same object
		executeClassScript(workflowID, args.scripts, args, args.classID);
	elseif source == "c" then
		-- Workflow in the current campaign
		local playerQuestLog = TRP3_API.quest.getQuestLog();
		if playerQuestLog and playerQuestLog.currentCampaign then
			local campaignClass = TRP3_API.extended.getClass(playerQuestLog.currentCampaign);
			if campaignClass and campaignClass.SC then
				executeClassScript(workflowID, campaignClass.SC, args, playerQuestLog.currentCampaign);
			end
		end
	elseif source == "p" then
		if args.container and args.container.id then
			local containerClass = TRP3_API.extended.getClass(args.container.id);
			if containerClass and containerClass.SC then
				-- TODO: Problem here
				args.object = args.container;
				-- args.container = ???
				executeClassScript(workflowID, containerClass.SC, args, args.object.id);
			end
		end
	elseif source == "ch" then
		if args.object and args.object.content and args.object.content[slotID] then
			local itemSlot = args.object.content[slotID];
			local itemClass = TRP3_API.extended.getClass(itemSlot.id);
			if itemClass and itemClass.SC then
				args.container = args.object;
				args.object = itemSlot;
				executeClassScript(workflowID, itemClass.SC, args, args.object.id);
			end
		end
	elseif source == "si" then
		if args.container and args.container.content and args.container.content[slotID] then
			local itemSlot = args.container.content[slotID];
			local itemClass = TRP3_API.extended.getClass(itemSlot.id);
			if itemClass and itemClass.SC then
				args.object = itemSlot;
				executeClassScript(workflowID, itemClass.SC, args, args.object.id);
			end
		end
	else
		error("Bad source type for runWorkflow: " .. tostring(source));
	end
end

local directReplacement;
directReplacement = {
	["wow:target"] = function()
		return UnitName("target") or SPELL_FAILED_BAD_IMPLICIT_TARGETS;
	end,
	["wow:player"] = function()
		return UnitName("player") or UNKNOWN;
	end,
	["wow:target:id"] = function()
		return TRP3_API.utils.str.getUnitID("target") or UnitName("target") or SPELL_FAILED_BAD_IMPLICIT_TARGETS;
	end,
	["wow:player:id"] = function()
		return TRP3_API.utils.str.getUnitID("player") or UnitName("player") or "";
	end,
	["wow:player:race"] = function()
		local race = UnitRace("player");
		return race or UNKNOWN;
	end,
	["wow:target:race"] = function()
		local race = UnitRace("target");
		return race or SPELL_FAILED_BAD_IMPLICIT_TARGETS;
	end,
	["wow:player:class"] = function()
		local class = UnitClass("player");
		return class or UNKNOWN;
	end,
	["wow:target:class"] = function()
		local class = UnitClass("target");
		return class or SPELL_FAILED_BAD_IMPLICIT_TARGETS;
	end,
	["trp:player:full"] = function()
		return TRP3_API.register.getPlayerCompleteName(true) or "";
	end,
	["trp:target:full"] = function()
		return TRP3_API.quest.GetCampaignNPCName("target") or TRP3_API.r.name("target") or SPELL_FAILED_BAD_IMPLICIT_TARGETS;
	end,
	["trp:player:first"] = function()
		return TRP3_API.profile.getData("player/characteristics").FN or "";
	end,
	["trp:player:last"] = function()
		return TRP3_API.profile.getData("player/characteristics").LN or "";
	end,

	["trp:player:class"] = function()
		local defaultClass = UnitClass("player");
		return TRP3_API.profile.getData("player/characteristics").CL or defaultClass or UNKNOWN;
	end,
	["trp:player:race"] = function()
		local defaultRace = UnitRace("player");
		return TRP3_API.profile.getData("player/characteristics").RA or defaultRace or UNKNOWN;
	end,
	["trp:target:first"] = function()
		if UnitIsUnit("target", "player") then
			return directReplacement["trp:player:first"]();
		end
		local defaultName = UnitName("target");
		local unitID = getUnitID("target");
		if unitID and isUnitIDKnown(unitID) then
			local profile = getUnitIDCurrentProfile(unitID);
			if profile and profile.characteristics and profile.characteristics.FN then
				return profile.characteristics.FN;
			end
		end
		return defaultName or SPELL_FAILED_BAD_IMPLICIT_TARGETS;
	end,
	["trp:target:last"] = function()
		if UnitIsUnit("target", "player") then
			return directReplacement["trp:player:last"]();
		end
		local defaultName = UnitName("target");
		local unitID = getUnitID("target");
		if unitID and isUnitIDKnown(unitID) then
			local profile = getUnitIDCurrentProfile(unitID);
			if profile and profile.characteristics and profile.characteristics.LN then
				return profile.characteristics.LN;
			end
		end
		return defaultName or SPELL_FAILED_BAD_IMPLICIT_TARGETS;
	end,
	["trp:target:class"] = function()
		if UnitIsUnit("target", "player") then
			return directReplacement["trp:player:class"]();
		end
		local defaultClass = UnitClass("target");
		local unitID = getUnitID("target");
		if unitID and isUnitIDKnown(unitID) then
			local profile = getUnitIDCurrentProfile(unitID);
			if profile and profile.characteristics and profile.characteristics.CL then
				return profile.characteristics.CL;
			end
		end
		return defaultClass or SPELL_FAILED_BAD_IMPLICIT_TARGETS;
	end,
	["trp:target:race"] = function()
		if UnitIsUnit("target", "player") then
			return directReplacement["trp:player:race"]();
		end
		local defaultRace = UnitClass("target");
		local unitID = getUnitID("target");
		if unitID and isUnitIDKnown(unitID) then
			local profile = getUnitIDCurrentProfile(unitID);
			if profile and profile.characteristics and profile.characteristics.RA then
				return profile.characteristics.RA;
			end
		end
		return defaultRace or SPELL_FAILED_BAD_IMPLICIT_TARGETS;
	end,
	["last.return"] = function(args)
		return args and args.LAST or "";
	end,
}

function TRP3_API.script.parseArgs(text, args)
	if not text then return end;
	args = args or EMPTY;
	text = tostring(text) or "";
	text = text:gsub("%$%{(.-)%}", function(capture)
		local default;
		if capture:find("::") then
			default = capture:sub(capture:find("::") + 2);
			capture = capture:sub(1, capture:find("::") - 1);
		end
		local decimals = 2;
		if capture:find("#") then
			decimals = tonumber(capture:sub(capture:find("#") + 1) or 2) or 2;
			capture = capture:sub(1, capture:find("#") - 1);
		end
		if directReplacement[capture] then
			return directReplacement[capture](args);
		elseif capture:match("gender%:%w+%:[^%:]+%:[^%:]+") then
			local type, male, female = capture:match("gender%:(%w+)%:([^%:]+)%:([^%:]+)");
			if UnitSex(type) == 2 then
				return male;
			elseif UnitSex(type) == 3 then
				return female;
			end
			return UNKNOWN;
		elseif capture:match("event%.%d+") then
			local index = tonumber(capture:match("event%.(%d+)") or 1) or 1;
			return TRP3_API.extended.tools.truncateDecimals( (args.event or EMPTY)[index] or capture, decimals);
		elseif (args.custom or EMPTY)[capture] or ((args.object or EMPTY).vars or EMPTY)[capture] then
			return TRP3_API.extended.tools.truncateDecimals( (args.custom or EMPTY)[capture] or ((args.object or EMPTY).vars or EMPTY)[capture], decimals);
		elseif ((TRP3_API.quest.getActiveCampaignLog() or EMPTY).vars or EMPTY)[capture] then
			return TRP3_API.extended.tools.truncateDecimals( ((TRP3_API.quest.getActiveCampaignLog() or EMPTY).vars or EMPTY)[capture], decimals);
		elseif TRP3_API.extended.classExists(capture) then
			return TRP3_API.inventory.getItemLink(TRP3_API.extended.getClass(capture), capture);
		end
		return default or capture;
	end);
	return text;
end

function TRP3_API.script.setVar(args, source, operationType, varName, varValue)
	if args and source and operationType then

		local storage;

		if source == "w" then
			storage = args.custom;
		elseif source == "o" and args.object then
			if not args.object.vars then
				args.object.vars = {};
			end
			storage = args.object.vars;
		elseif source == "c" and TRP3_API.quest.getActiveCampaignLog() then
			storage = TRP3_API.quest.getActiveCampaignLog();
			if not storage.vars then
				storage.vars = {};
			end
			storage = storage.vars;
		else
			return;
		end
		if not storage then return; end

		-- Init and set operation
		if (operationType == "[=]" and not storage[varName]) or operationType == "=" then
			storage[varName] = varValue;
			return;
		end

		-- Math operations
		local initialValue = tonumber(storage[varName] or 0) or 0;
		local value = tonumber(varValue or 0) or 0;
		if operationType == "+" then
			storage[varName] = initialValue + value;
		elseif operationType == "-" then
			storage[varName] = initialValue - value;
		elseif operationType == "/" then
			storage[varName] = initialValue / value;
		elseif operationType == "x" then
			storage[varName] = initialValue * value;
		end
	end
end

local function setVarValue(args, source, varName, varValue)
	TRP3_API.script.setVar(args, source, "=", varName, varValue);
end

function TRP3_API.script.varCheck(args, source, varName)
	if args and source then

		local storage;

		if source == "w" then
			storage = args.custom;
		elseif source == "o" and args.object then
			if not args.object.vars then
				args.object.vars = {};
			end
			storage = args.object.vars;
		elseif source == "c" and TRP3_API.quest.getActiveCampaignLog() then
			storage = TRP3_API.quest.getActiveCampaignLog();
			if not storage.vars then
				storage.vars = {};
			end
			storage = storage.vars;
		else
			return "nil";
		end
		if not storage then return "nil"; end

		return tostring(storage[varName] or "nil");
	end
	return "nil";
end

function TRP3_API.script.varCheckN(args, source, varName)
	if args and source then

		local storage;

		if source == "w" then
			storage = args.custom;
		elseif source == "o" and args.object then
			if not args.object.vars then
				args.object.vars = {};
			end
			storage = args.object.vars;
		elseif source == "c" and TRP3_API.quest.getActiveCampaignLog() then
			storage = TRP3_API.quest.getActiveCampaignLog();
			if not storage.vars then
				storage.vars = {};
			end
			storage = storage.vars;
		else
			return 0;
		end
		if not storage then return 0; end

		return tonumber(storage[varName] or 0) or 0;
	end
	return 0;
end

function TRP3_API.script.eventVarCheck(args, index)
	if args and args.event and type(index) == "number" then
		return tostring(args.event[index] or "nil");
	end
	return "nil";
end

function TRP3_API.script.eventVarCheckN(args, index)
	if args and args.event and type(index) == "number" then
		return tonumber(args.event[index] or 0);
	end
	return 0;
end

local LUA_ENV = {
	["string"] = string,
	["table"] = table,
	["math"] = math,
	["pairs"] = pairs,
	["ipairs"] = ipairs,
	["next"] = next,
	["select"] = select,
	["unpack"] = unpack,
	["type"] = type,
};
function TRP3_API.script.runLuaScriptEffect(code, args, secured)
	code = "return function(args)\n" .. code .. "\nend;";

	local env = {};
	tableCopy(env, LUA_ENV);
	if secured then
		env["effect"] = securedEffect;
	else
		env["effect"] = effect;
	end

	env["op"] = operand;

	env["getVar"] = TRP3_API.script.varCheck;
	env["setVar"] = setVarValue;

	-- Compile
	local factory, errorMessage = loadstring(code, "Generated code");
	if not factory then
		error("Error in script effect:\n" .. errorMessage);
	end

	-- Create
	setfenv(factory, env);
	local func = factory();
	setfenv(func, env);

	-- Execute
	return func(args or EMPTY);
end
