local _, addon = ...
local loc = TRP3_API.loc;

addon.database.filters = {};
local PREDICATES = {};
local FILTER_AND = "AND";
local FILTER_OR  = "OR";
local PREDICATES_MENU;

local function defaultPredicateParameterFormatter(parameter, value)
	for _, v in ipairs(parameter.values or TRP3_API.globals.empty) do
		if v[1] == value then
			return v[2];
		end
	end
	return tostring(value);
end

local function defaultPredicateFormatter(self, ...)
	local formattedPredicate = self.title;
	for index, parameter in ipairs(self.parameters) do
		formattedPredicate = formattedPredicate .. " " .. defaultPredicateParameterFormatter(parameter, select(index, ...));
	end
	return formattedPredicate;
end

local function booleanPredicateFormatter(self, ...)
	local formattedPredicate = self.title;
	for index, parameter in ipairs(self.parameters) do
		formattedPredicate = formattedPredicate .. ": " .. defaultPredicateParameterFormatter(parameter, select(index, ...));
	end
	return formattedPredicate;
end

function addon.database.filters.registerPredicate(predicate)
	assert(predicate.id, "no predicate id provided");
	assert(predicate.title, "no predicate title provided");
	assert(not PREDICATES[predicate.id], "predicate with id " .. predicate.id .. " already present");
	PREDICATES[predicate.id] = predicate;
	predicate.parameters = predicate.parameters or {};
	for _, parameter in ipairs(predicate.parameters) do
		if parameter.values then
			parameter.dropdownValues = {};
			for _, value in ipairs(parameter.values) do
				table.insert(parameter.dropdownValues, {value[2], value[1]});
			end
		end
	end
	predicate.Format = predicate.Format or defaultPredicateFormatter;
	PREDICATES_MENU = nil;
end

local UNKNOWN_PREDICATE = {
	title      = addon.script.formatters.unknown("unkown condition"),
	parameters = {};
	compile    = function() return function() return true; end end,
	Format     = defaultPredicateFormatter
};

function addon.database.filters.getPredicateById(predicateId)
	return PREDICATES[predicateId or ""] or UNKNOWN_PREDICATE;
end

function addon.database.filters.getPredicateMenu()
	if PREDICATES_MENU then
		return PREDICATES_MENU;
	end
	PREDICATES_MENU = {};
	for id, predicate in pairs(PREDICATES) do
		table.insert(PREDICATES_MENU, {predicate.title, predicate.id});
	end
	return PREDICATES_MENU;
end

local compileAnd = function(predicates)
	if TableIsEmpty(predicates) then
		return function()
			return true;
		end
	elseif CountTable(predicates) == 1 then
		return predicates[1];
	end
	return function(creationId, absoluteId, class)
		for _, predicate in ipairs(predicates) do
			if not predicate(creationId, absoluteId, class) then
				return false;
			end
		end
		return true;
	end
end

local compileOr = function(predicates)
	if TableIsEmpty(predicates) then
		return function()
			return false;
		end
	elseif CountTable(predicates) == 1 then
		return predicates[1];
	end
	return function(creationId, absoluteId, class)
		for _, predicate in ipairs(predicates) do
			if predicate(creationId, absoluteId, class) then
				return true;
			end
		end
		return false;
	end
end

-- filter predicate storage ::=
-- {
--   { "AND"|"OR", predicate_id, arg1, arg2, ... },
--   ...
-- }
function addon.database.filters.compileFilter(filter)
	if TableHasAnyEntries(filter) then
		local orStack = {};
		local andStack = {};
		for index, predicate in ipairs(filter) do
			formalPredicate = addon.database.filters.getPredicateById(predicate[2]);
			compiledPredicate = formalPredicate.compile(unpack(predicate, 3, 2 + #(formalPredicate.parameters)));
			if index > 1 and predicate[1] == FILTER_AND then
				table.insert(andStack, compileOr(orStack));
				orStack = {};
			end
			table.insert(orStack, compiledPredicate);
		end
		if TableHasAnyEntries(orStack) then
			table.insert(andStack, compileOr(orStack));
		end
		return compileAnd(andStack);
	else
		return function()
			return true;
		end
	end
end

function addon.database.filters.formatFilter(filter)
	local filterText = "Showing all objects";
	if TableHasAnyEntries(filter) then
		filterText = filterText .. " with:";
		local open = {};
		local close = {};
		local orStart;
		local hasAnd = false;
		for index, predicate in ipairs(filter) do
			if index > 1 then
				if predicate[1] == FILTER_OR then
					orStart = orStart or (index - 1);
				elseif predicate[1] == FILTER_AND then
					hasAnd = true;
					if orStart then
						open[orStart] = true;
						close[index-1] = true;
						orStart = nil;
					end
				end
			end
		end
		if hasAnd and orStart then
			open[orStart] = true;
			close[CountTable(filter)] = true;
		end
		for index, predicate in ipairs(filter) do
			local formalPredicate = addon.database.filters.getPredicateById(predicate[2]);
			filterText = filterText .. "|n";
			if index > 1 then
				if predicate[1] == FILTER_OR then
					filterText = filterText .. loc.OP_OR .. " ";
				end
				if predicate[1] == FILTER_AND then
					filterText = filterText .. loc.OP_AND .. " ";
				end
			end
			if open[index] then
				filterText = filterText .. "(";
			end
			filterText = filterText .. formalPredicate:Format(unpack(predicate, 3, 2 + #(formalPredicate.parameters)));
			if close[index] then
				filterText = filterText .. ")";
			end
		end
	end
	return filterText;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- defining built-in filters
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function addon.database.filters.initialize()

	local yesNo = {
		type = "boolean",
		values = {
			{true, "yes"},
			{false, "no"},
		},
		default = true
	};
	
	local equalUnequal = {
		type = "boolean",
		values = {
			{true, "is"},
			{false, "isn't"},
		},
		default = true
	};

	local stringComparators = {
		type = "string",
		values = {
			{"===", "is"},
			{"=??", "begins with"},
			{"??=", "ends with"},
			{"?=?", "contains"},
			{"~===", "isn't"},
			{"~=??", "doesn't begin with"},
			{"~??=", "doesn't end with"},
			{"~?=?", "doesn't contain"},
		},
		default = "==="
	};

	local stringCompareFunctions = {
		["==="]  = function(v1, v2) return v1 == v2; end,
		["=??"]  = function(v1, v2) return v1:find(v2) == 1; end,
		["??="]  = function(v1, v2) return v1:sub(-v2:len()) == v2; end,
		["?=?"]  = function(v1, v2) return v1:find(v2) ~= nil; end,
		["~==="] = function(v1, v2) return v1 ~= v2; end,
		["~=??"] = function(v1, v2) return v1:find(v2) ~= 1; end,
		["~??="] = function(v1, v2) return v1:sub(-v2:len()) ~= v2; end,
		["~?=?"] = function(v1, v2) return v1:find(v2) == nil; end,
	};

	addon.database.filters.registerPredicate({
		id    = "IS_CREATION",
		title = "object is a creation",
		parameters = {
			yesNo
		},
		Format = booleanPredicateFormatter,
		compile = function(isCreation)
			return function(creationId, absoluteId, class)
				return (creationId == absoluteId) == isCreation;
			end;
		end
	});

	addon.database.filters.registerPredicate({
		id    = "IS_MINE",
		title = "made by me",
		parameters = {
			yesNo
		},
		Format = booleanPredicateFormatter,
		compile = function(isMine)
			return function(creationId, absoluteId, class)
				return (TRP3_API.extended.isObjectMine(creationId)) == isMine;
			end;
		end
	});

	addon.database.filters.registerPredicate({
		id    = "IS_INNER",
		title = "made by backers",
		parameters = {
			yesNo
		},
		Format = booleanPredicateFormatter,
		compile = function(isBackers)
			return function(creationId, absoluteId, class)
				return (TRP3_API.extended.isObjectBackers(creationId)) == isBackers;
			end;
		end
	});

	addon.database.filters.registerPredicate({
		id    = "IS_OBJECT_TYPE",
		title = "object type",
		parameters = {
			equalUnequal,
			{
				type = "string",
				values = {
					{TRP3_DB.types.ITEM,       addon.main.getTypeLocale(TRP3_DB.types.ITEM)},
					{TRP3_DB.types.AURA,       addon.main.getTypeLocale(TRP3_DB.types.AURA)},
					{TRP3_DB.types.DOCUMENT,   addon.main.getTypeLocale(TRP3_DB.types.DOCUMENT)},
					{TRP3_DB.types.DIALOG,     addon.main.getTypeLocale(TRP3_DB.types.DIALOG)},
					{TRP3_DB.types.CAMPAIGN,   addon.main.getTypeLocale(TRP3_DB.types.CAMPAIGN)},
					{TRP3_DB.types.QUEST,      addon.main.getTypeLocale(TRP3_DB.types.QUEST)},
					{TRP3_DB.types.QUEST_STEP, addon.main.getTypeLocale(TRP3_DB.types.QUEST_STEP)},
				},
				default = TRP3_DB.types.ITEM
			}
		},
		compile = function(isEqual, type)
			return function(creationId, absoluteId, class)
				return (class.TY == type) == isEqual;
			end;
		end
	});

	addon.database.filters.registerPredicate({
		id    = "IS_LOCALE",
		title = "language",
		parameters = {
			equalUnequal,
			{
				type = "string",
				values = {
					{"en", ("|T%s:11:16|t"):format(addon.main.getObjectLocaleImage("en"))},
					{"fr", ("|T%s:11:16|t"):format(addon.main.getObjectLocaleImage("fr"))},
					{"es", ("|T%s:11:16|t"):format(addon.main.getObjectLocaleImage("es"))},
					{"de", ("|T%s:11:16|t"):format(addon.main.getObjectLocaleImage("de"))},
				},
				default = "en"
			}
		},
		compile = function(isEqual, locale)
			return function(creationId, absoluteId, class)
				local creationClass = TRP3_API.extended.getClass(creationId);
				return ((creationClass and creationClass.MD and creationClass.MD.LO or "en") == locale) == isEqual;
			end;
		end
	});

	addon.database.filters.registerPredicate({
		id    = "OBJECT_ID",
		title = "object id",
		parameters = {
			stringComparators,
			{
				type = "string",
				default = ""
			}
		},
		compile = function(comparator, value)
			local cmp = stringCompareFunctions[comparator or "==="] or stringCompareFunctions["==="];
			return function(creationId, absoluteId, class)
				return cmp(absoluteId, value);
			end;
		end
	});

	-- we need to be a bit more lenient here
	-- "Creator IS Peter" should include Peter-Stormscale and Peter-Tichondrius
	-- "Creator IS Peter-Stormscale" should include only Peter-Stormscale
	-- "Creator IS NOT Peter" should exclude all Peter-***s
	-- "Creator IS NOT Peter-Stormscale" should exclude Peter-Stormscale specifically
	addon.database.filters.registerPredicate({
		id    = "CREATOR",
		title = "creator",
		parameters = {
			{
				type = "string",
				values = {
					{"==", "is"},
					{"~=", "isn't"},
					{"===", "is exactly"},
				},
				default = "=="
			},
			{
				type = "string",
				default = ""
			}
		},
		compile = function(comparator, name)
			local fullName = strtrim((name or ""):lower());
			local simpleName = strtrim(fullName:gsub("-.*", ""));
			if comparator == "~=" then 
				if fullName == simpleName then
					return function(creationId, absoluteId, class)
						local creationClass = TRP3_API.extended.getClass(creationId);
						local creator = (creationClass.MD and creationClass.MD.CB or ""):lower();
						return creator:gsub("-.*", "") ~= simpleName;
					end;
				else
					return function(creationId, absoluteId, class)
						local creationClass = TRP3_API.extended.getClass(creationId);
						local creator = (creationClass.MD and creationClass.MD.CB or ""):lower();
						return creator ~= fullName;
					end;
				end
			elseif comparator == "===" then 
				return function(creationId, absoluteId, class)
					local creationClass = TRP3_API.extended.getClass(creationId);
					local creator = creationClass.MD and creationClass.MD.CB or "";
					return creator == name;
				end;
			else -- comparator == "=="
				if fullName == simpleName then
					return function(creationId, absoluteId, class)
						local creationClass = TRP3_API.extended.getClass(creationId);
						local creator = (creationClass.MD and creationClass.MD.CB or ""):lower();
						return creator:gsub("-.*", "") == simpleName;
					end;
				else
					return function(creationId, absoluteId, class)
						local creationClass = TRP3_API.extended.getClass(creationId);
						local creator = (creationClass.MD and creationClass.MD.CB or ""):lower();
						return creator == fullName;
					end;
				end
			end
		end
	});

	addon.database.filters.registerPredicate({
		id    = "NAME",
		title = "name",
		parameters = {
			stringComparators,
			{
				type = "string",
				default = ""
			}
		},
		compile = function(comparator, value)
			local cmp = stringCompareFunctions[comparator or "==="] or stringCompareFunctions["==="];
			local val = strtrim((value or ""):lower());
			return function(creationId, absoluteId, class)
				return cmp((class.BA and class.BA.NA or ""):lower(), val);
			end;
		end
	});

	addon.database.filters.registerPredicate({
		id    = "NOTE",
		title = "note",
		parameters = {
			stringComparators,
			{
				type = "string",
				default = ""
			}
		},
		compile = function(comparator, value)
			local cmp = stringCompareFunctions[comparator or "==="] or stringCompareFunctions["==="];
			local val = strtrim((value or ""):lower());
			return function(creationId, absoluteId, class)
				return cmp((class.NT or ""):lower(), val);
			end;
		end
	});

	addon.database.filters.registerPredicate({
		id    = "TEXT",
		title = "text",
		parameters = {
			stringComparators,
			{
				type = "string",
				default = ""
			}
		},
		compile = function(comparator, value)
			local cmp = stringCompareFunctions[comparator or "==="] or stringCompareFunctions["==="];
			local val = strtrim((value or ""):lower());
			return function(creationId, absoluteId, class)
				-- defining what the "text" is, per object type
				if class.TY == TRP3_DB.types.ITEM then
					return cmp((class.BA and class.BA.DE or ""):lower(), val);
				elseif class.TY == TRP3_DB.types.AURA then
					return cmp((class.BA and class.BA.DE or ""):lower(), val);
				elseif class.TY == TRP3_DB.types.DOCUMENT then
					-- maybe not ideal, we're checking if one page fulfills the filter
					-- this is weird for the "not ***" conditions
					-- on the other hand, "contains" should be the biggest use case
					for _, PA in ipairs(class.PA or TRP3_API.globals.empty) do
						if cmp((PA.TX or ""):lower(), val) then
							return true;
						end
					end
				elseif class.TY == TRP3_DB.types.DIALOG then
					for _, DS in ipairs(class.DS or TRP3_API.globals.empty) do
						if cmp((DS.TX or ""):lower(), val) then
							return true;
						end
					end
				elseif class.TY == TRP3_DB.types.CAMPAIGN then
					return cmp((class.BA and class.BA.DE or ""):lower(), val);
				elseif class.TY == TRP3_DB.types.QUEST then
					return cmp((class.BA and class.BA.DE or ""):lower(), val);
				elseif class.TY == TRP3_DB.types.QUEST_STEP then
					return cmp((class.BA and class.BA.DX or ""):lower(), val) or cmp((class.BA and class.BA.TX or ""):lower(), val);
				end
				return false;
			end;
		end
	});

end
