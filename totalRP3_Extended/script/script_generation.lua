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
local assert, type, tostring, error, tonumber, pairs, loadstring, wipe, strsplit = assert, type, tostring, error, tonumber, pairs, loadstring, wipe, strsplit;
local tableCopy = TRP3_API.utils.table.copy;
local log, logLevel = TRP3_API.utils.log.log, TRP3_API.utils.log.level;
local writeElement;
local loc = TRP3_API.locale.getText;

local DEBUG = false;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Utils
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function escapeString(value)
	return value:gsub("\"", "\\\"");
end

-- Escape " in string argument, to avoid script injection
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

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LEVEL 1 : Test
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getTestOperande(id)
	return TRP3_API.script.getOperand(id);
end

local function writeOperand(testStructure, comparatorType, env)
	local code;
	assert(type(testStructure) == "table", "testStructure is not a table");
	assert(testStructure.v or testStructure.i, "No operand info");

	if testStructure.v then
		if comparatorType == "number" then
			assert(tonumber(testStructure.v) ~= nil, "Cannot parse operand numeric value: " .. testStructure.v);
			code = testStructure.v;
		else
			code = "\"" .. escapeString(tostring(testStructure.v)) .. "\"";
		end
	else
		local operandInfo = getTestOperande(testStructure.i);
		assert(operandInfo, "Unknown operand ID: " .. testStructure.i);
		assert(comparatorType ~= "number" or operandInfo.numeric, "Operand ID is not numeric: " .. testStructure.i);

		if comparatorType == "number" then
			code = ("(tonumber(%s) or -1)"):format(operandInfo.codeReplacement(escapeArguments(testStructure.a)));
		else
			code = ("tostring(%s)"):format(operandInfo.codeReplacement(escapeArguments(testStructure.a)));
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

local function writeCondition(conditionStructure, conditionID)
	assert(type(conditionStructure) == "table", "conditionStructure is not a table");
	local code = "";
	local previousType;
	local isInParenthesis = false;
	for index, element in pairs(conditionStructure) do
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
				code = code .. writeTest(element) .. " ) ";
				isInParenthesis = false;
			elseif index < #conditionStructure then
				if conditionStructure[index + 1] == "+" and isInParenthesis then
					code = code .. writeTest(element) .. " ) ";
					isInParenthesis = false;
				elseif conditionStructure[index + 1] == "*" and not isInParenthesis then
					code = code .. "( " .. writeTest(element) .. " ";
					isInParenthesis = true;
				else
					code = code .. writeTest(element) .. " ";
				end
			else
				code = code .. writeTest(element) .. " ";
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

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LEVEL 3 : Effect
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local EFFECT_MISSING_ID = "MISSING";

local function getEffectInfo(id)
	return TRP3_API.script.getEffect(id) or TRP3_API.script.getEffect(EFFECT_MISSING_ID);
end

function TRP3_API.script.protected()
	print("Protected !");
	return -1;
end

local function writeEffect(effectStructure)
	assert(type(effectStructure) == "table", "effectStructure is not a table");
	assert(effectStructure.id, "Effect don't have ID");
	local effectInfo = getEffectInfo(effectStructure.id);
	assert(effectInfo, "Unknown effect ID: " .. effectStructure.id);

	local effectCode, secured;

	if effectInfo.secured and effectInfo.secured ~= TRP3_API.security.SECURITY_LEVEL.HIGH then
		secured = TRP3_API.security.resolveEffectSecurity(CURRENT_CLASS_ID, effectStructure.id);
	else
		secured = true;
	end

	if secured then
		-- Register operand environment
		if effectInfo.env then
			for map, g in pairs(effectInfo.env) do
				CURRENT_ENVIRONMENT[map] = g;
			end
		end
		effectCode = effectInfo.codeReplacementFunc(escapeArguments(effectStructure.args) or EMPTY, effectStructure.id);
	elseif effectInfo.securedCodeReplacementFunc and effectInfo.securedEnv then
		-- Register operand environment
		if effectInfo.securedEnv then
			for map, g in pairs(effectInfo.securedEnv) do
				CURRENT_ENVIRONMENT[map] = g;
			end
		end
		effectCode = effectInfo.securedCodeReplacementFunc(escapeArguments(effectStructure.args) or EMPTY, effectStructure.id);
	else
		-- TODO: better than that
		effectCode = "print('Effect blocked: " .. effectStructure.id  .. "')";
		CURRENT_ENVIRONMENT["print"] = "print";
	end

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

	writeLine(("delayed(%s, function() "):format(delayStructure.d));
	addIndent();
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
local BASE_ENV = { ["tostring, EMPTY, delayed, eval, tonumber, var"]
	= "tostring, TRP3_API.globals.empty, TRP3_API.script.delayed, TRP3_API.script.eval, tonumber, TRP3_API.script.parseArgs" };

local IMPORT_PATTERN = "local %s = %s;";

local function writeImports()
	for alias, global in pairs(CURRENT_ENVIRONMENT) do
		writeLine(IMPORT_PATTERN:format(alias, global), true);
	end
	if DEBUG then
		writeLine("-- Imports", true);
	end
end

local function generateCode(effectStructure, classID)
	CURRENT_CLASS_ID = classID;
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
	writeLine("local lastEffectReturn;"); -- Store last return value from effect, to be able to test it in further conditions.
	writeElement("1"); -- 1 is always the first element
	writeLine("return 0, conditionStorage;");
	closeBlock();
	writeImports();
	writeLine("setfenv(func, {});");
	writeLine("return func;");

	return CURRENT_CODE;
end

local function generate(effectStructure, classID)
	log("Generate FX", logLevel.DEBUG);
	local code = generateCode(effectStructure, classID);

	-- Generating factory
	local func, errorMessage = loadstring(code, "Generated code");
	if not func then
		print(errorMessage); -- TODO: could happens if syntax error, make a proper message
		return nil, code;
	end

	return func, code;
end

local function getFunction(structure, classID)
	local functionFactory, code = generate(structure, classID);

	if DEBUG then
		TRP3_DEBUG_CODE_FRAME:Show();
		TRP3_DEBUG_CODE_FRAME_TEXT:SetText(code);
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
		TRP3_API.utils.message.displayMessage(loc("SEC_SCRIPT_ERROR"):format(scriptID or "preview"), 4);
		log(tostring(ret), logLevel.WARN);
	end
end
TRP3_API.script.executeFunction = executeFunction;

local compiledScript = {}

local function executeClassScript(scriptID, classScripts, args, innerClassID)
	assert(scriptID and classScripts, "Missing arguments.");
	assert(innerClassID, "ClassID is needed for security purpose.");


	if not classScripts[scriptID] then
		TRP3_API.utils.message.displayMessage("|cffff0000" .. loc("SEC_MISSING_SCRIPT"):format(scriptID), 4);
		return;
	end

	local parts = {strsplit(TRP3_API.extended.ID_SEPARATOR, innerClassID)};
	local classID = parts[1];
	local class = classScripts[scriptID];

	-- Not compiled yet
	if not compiledScript[innerClassID] or not compiledScript[innerClassID][scriptID] then
		if not compiledScript[innerClassID] then
			compiledScript[innerClassID] = {};
		end
		compiledScript[innerClassID][scriptID] = getFunction(class.ST, classID);
	end
	return executeFunction(compiledScript[innerClassID][scriptID], args, scriptID);
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
	code = "local func = function(args) " .. code .. " end setfenv(func, {}); return func;";

	for alias, global in pairs(env or EMPTY) do
		code = "\n" .. IMPORT_PATTERN:format(alias, global) .. code;
	end

	-- Generating factory
	local func, errorMessage = loadstring(code, "Generated code");
	if not func then
		print(errorMessage);
		return nil, code;
	end

	-- Execute
	func()(args);
end

function TRP3_API.script.parseArgs(text, args)
	text = text:gsub("%$%{(.-)%}", function(capture)
		return (args.custom or EMPTY)[capture] or ((args.object or EMPTY).vars or EMPTY)[capture];
	end);
	return text;
end

function TRP3_API.script.parseObjectArgs(text, vars)
	text = text:gsub("%$%{(.-)%}", function(capture)
		return (vars or EMPTY)[capture];
	end);
	return text;
end

function TRP3_API.script.setWorkflowVar(workflowVars, varName, varValue, initOnly)
	if workflowVars then
		if not initOnly or not workflowVars[varName] then
			workflowVars[varName] = varValue;
		end
	end
end

function TRP3_API.script.setObjectVar(object, varName, varValue, initOnly)
	if object then
		if not object.vars then object.vars = {} end
		if not initOnly or not object.vars[varName] then
			object.vars[varName] = varValue;
		end
	end
end