local _, addon = ...
local loc = TRP3_API.loc;

local CACHED_GAME_EVENTS; -- load on demand
local CACHED_EMOTES; -- load on demand
local CREATION_ID_REGEX = "^[^%" .. TRP3_API.extended.ID_SEPARATOR .. "]*";
local RELATIVE_ID_REGEX = "(.*)%" .. TRP3_API.extended.ID_SEPARATOR .. "+([^%" .. TRP3_API.extended.ID_SEPARATOR .. "]+)$";

addon.utils = {};

function addon.utils.deepCompare(object1, object2)
	local stack1 = {object1};
	local stack2 = {object2};
	while TableHasAnyEntries(stack1) do
		top1 = table.remove(stack1);
		top2 = table.remove(stack2);
		for field, value in pairs(top1) do
			if value ~= top2[field] then
				if type(value) == "table" and top2[field] and type(top2[field]) == "table" then
					table.insert(stack1, value);
					table.insert(stack2, top2[field]);
				else
					print("diff", field, value, top2[field]) -- TODO remove
					return false;
				end
			end
		end
		for field, value in pairs(top2) do
			if value ~= nil and top1[field] == nil then
				print("miss", field, value, top1[field]) -- TODO remove
				return false;
			end
		end
	end
	return true;
end

function addon.utils.createEmptyClass(type)
	local class;
	local field = "IN";
	if type == TRP3_DB.types.ITEM then
		class = {
			TY = TRP3_DB.types.ITEM,
			MD = {
				MO = TRP3_DB.modes.EXPERT
			},
			BA = {
				NA = loc.IT_NEW_NAME
			}
		};
	elseif type == TRP3_DB.types.AURA then
		class = {
			TY = TRP3_DB.types.AURA,
			MD = {
				MO = TRP3_DB.modes.EXPERT
			},
			BA = {
				NA = loc.AU_NEW_NAME,
				HE = true,
				CC = true,
			}
		};
	elseif type == TRP3_DB.types.DOCUMENT then
		class = {
			TY = TRP3_DB.types.DOCUMENT,
			MD = {
				MO = TRP3_DB.modes.EXPERT
			},
			BA = {
				NA = loc.DO_NEW_DOC
			},
			BT = true,
		};
	elseif type == TRP3_DB.types.DIALOG then
		class = {
			TY = TRP3_DB.types.DIALOG,
			MD = {
				MO = TRP3_DB.modes.EXPERT
			},
			BA = {},
			DS = {
				{
					TX = "Text."
				}
			}
		};
	elseif type == TRP3_DB.types.QUEST then
		class = {
			TY = TRP3_DB.types.QUEST,
			BA = {
				NA = loc.QE_NAME_NEW,
				IC = "achievement_quests_completed_07",
				DE = loc.QE_DESCRIPTION_TT,
				PR = true,
			},
			ST = {
				step_1_first = select(1, addon.utils.createEmptyClass(TRP3_DB.types.QUEST_STEP))
			},
			OB = {},
			MD = {
				MO = TRP3_DB.modes.EXPERT,
			}
		}
		class.ST.step_1_first.BA.IN = true;
		field = "QE";
	elseif type == TRP3_DB.types.QUEST_STEP then
		class = {
			TY = TRP3_DB.types.QUEST_STEP,
			BA = {
				TX = loc.QE_STEP_NAME_NEW,
			},
			MD = {
				MO = TRP3_DB.modes.EXPERT,
			}
		};
		field = "ST";
	end
	return class, field;
end

-- this function is heuristic
-- TODO check if there's a more precise way feasible.
-- corner case:
--  old id = "X", while "XX" exists
function addon.utils.replaceId(object, oldId, newId)
	if type(object) ~= "table" then return end

	local stack = {};
	local count = 0;

	while object ~= nil do
		for k, v in pairs(object) do
			local varType = type(v);
			if varType == "table" then
				count = count + 1;
				stack[count] = v;
			elseif varType == "string" then
				object[k] = v:gsub(oldId, newId);
			end
		end

		object = stack[count];
		stack[count] = nil;
		count = count - 1;
	end
end

function addon.utils.isInnerId(ancestorId, descendantId)
	return
		ancestorId 
	and (descendantId:sub(1, ancestorId:len()) == ancestorId)
	and (descendantId:sub(ancestorId:len() + 1, ancestorId:len() + 1) == TRP3_API.extended.ID_SEPARATOR);
end

function addon.utils.isInnerIdOrEqual(ancestorId, descendantId)
	return ancestorId == descendantId or addon.utils.isInnerId(ancestorId, descendantId);
end

function addon.utils.getCreationId(absoluteId)
	return absoluteId:match(CREATION_ID_REGEX);
end

-- splits an id into a parent and child part, such that the full id is the composition of parent and child part
-- if the object denoted by the absolute id is a root object, then the parent part is nil
function addon.utils.splitId(absoluteId)
	if not absoluteId:find(TRP3_API.extended.ID_SEPARATOR) then
		return nil, absoluteId;
	end
	local parentId, relativeId = absoluteId:match(RELATIVE_ID_REGEX);
	if parentId and relativeId and (TRP3_API.extended.classExists(parentId) or not TRP3_API.extended.classExists(absoluteId)) then
		return parentId, relativeId;
	end
	-- legacy case with ID_SEPARATOR in the id components
	parentId = nil;
	relativeId = nil;
	local allTokens;
	local relativeTokens;
	for token in absoluteId:gmatch("[^%" .. TRP3_API.extended.ID_SEPARATOR .. "]+") do
		allTokens = (allTokens and (allTokens .. TRP3_API.extended.ID_SEPARATOR) or "") .. token;
		relativeTokens = (relativeTokens and (relativeTokens .. TRP3_API.extended.ID_SEPARATOR) or "") .. token;
		if TRP3_API.extended.classExists(allTokens) then
			if parentId and relativeId then
				parentId = parentId .. TRP3_API.extended.ID_SEPARATOR .. relativeId;
				relativeId = relativeTokens;
				relativeTokens = nil;
			elseif parentId then
				relativeId = relativeTokens;
				relativeTokens = nil;
			else
				parentId = allTokens;
				relativeId = nil;
			end
		end		
	end
	if parentId and relativeId then
		return parentId, relativeId;
	end
	return nil, absoluteId; -- this shouldn't happen even in legacy case
end

-- simplified multi selection mode
-- single select equivalent to CTRL+click in a common OS
-- SHIFT+click is different, because the unmodified click is reserved for something more important
function addon.utils.prepareForMultiSelectionMode(list, selectedAttributeName, singleSelectMethodName, rangeSelectMethodName, globalSelectMethodName)
	selectedAttributeName  = selectedAttributeName  or "selected";
	singleSelectMethodName = singleSelectMethodName or "ToggleSingleSelect";
	rangeSelectMethodName  = rangeSelectMethodName  or "ToggleRangeSelect";
	globalSelectMethodName = globalSelectMethodName or "SetAllSelected"

	list[singleSelectMethodName] = function(self, element)
		element[selectedAttributeName] = not element[selectedAttributeName];
		self:Refresh();
	end

	list[rangeSelectMethodName] = function(self, targetElement)
		local targetElementIndex = self.model:FindIndex(targetElement);
		if not targetElementIndex then
			return
		end

		local min = math.huge;
		local max = 0;

		for index, element in self.model:EnumerateEntireRange() do
			if element[selectedAttributeName] and min > index then
				min = index;
			end
			if element[selectedAttributeName] and max < index then
				max = index;
			end
		end

		if max < min then
			targetElement[selectedAttributeName] = true;
		elseif targetElementIndex < min then
			for index, element in self.model:Enumerate(targetElementIndex, max) do
				element[selectedAttributeName] = true;
			end
		elseif targetElementIndex > max then
			for index, element in self.model:Enumerate(min, targetElementIndex) do
				element[selectedAttributeName] = true;
			end
		elseif targetElement[selectedAttributeName] then
			for index, element in self.model:Enumerate(min, max) do
				element[selectedAttributeName] = false;
			end
		else
			for index, element in self.model:Enumerate(min, max) do
				element[selectedAttributeName] = true;
			end
		end
		
		self:Refresh();
	end

	list[globalSelectMethodName] = function(self, selected)
		for index, element in self.model:EnumerateEntireRange() do
			element[selectedAttributeName] = selected;
		end
		self:Refresh();
	end
end

function addon.utils.getObjectIconAndLink(class, relativeId)
	local icon, name, quality = TRP3_API.inventory.getBaseClassDataSafe(class);
	local color;
	if class.TY == TRP3_DB.types.ITEM then
		color = TRP3_API.inventory.getQualityColorText(quality);
	else
		color = "|cffffffff";
	end
	if class.TY == TRP3_DB.types.DOCUMENT then
		icon = "interface\\icons\\inv_inscription_scroll";
		name = relativeId or loc.TYPE_DOCUMENT;
	elseif class.TY == TRP3_DB.types.DIALOG then
		icon = "interface\\icons\\ui_chat";
		name = relativeId or loc.TYPE_DIALOG;
	elseif class.TY == TRP3_DB.types.QUEST_STEP then
		if class.BA and class.BA.FI then
			icon = "interface\\raidframe\\readycheck-ready";
		else
			icon = "interface\\gossipframe\\incompletequesticon";
		end
		name = relativeId or loc.TYPE_QUEST_STEP;
	else
		icon = "interface\\icons\\" .. icon;
	end
	if class.TY == TRP3_DB.types.ITEM or class.TY == TRP3_DB.types.CAMPAIGN then
		name = "[" .. name .. "]";
	end
	return icon, color .. name .. "|r";
end

function addon.utils.getEmoteList()
	if CACHED_EMOTES then
		return CACHED_EMOTES;
	end
	CACHED_EMOTES = {};
	local animatedEmotesIndex = {};
	for _, token in pairs(EmoteList) do
		animatedEmotesIndex[token] = true;
	end
	local spokenEmotesIndex = {};
	for _, token in pairs(TextEmoteSpeechList) do
		spokenEmotesIndex[token] = true;
	end
	spokenEmotesIndex["FORTHEALLIANCE"] = true;
	spokenEmotesIndex["FORTHEHORDE"] = true;
	for index = 1, MAXEMOTEINDEX do
		local token = _G["EMOTE" .. index .. "_TOKEN"];
		if token then
			local emote = {
				token      = token,
				isAnimated = animatedEmotesIndex[token] or false,
				isSpoken   = spokenEmotesIndex[token] or false,
				slashCommands = {};
			};
			local cIndex = 1;
			local slashCmd = "EMOTE" .. index .. "_CMD" .. cIndex;
			while _G[slashCmd] do
				table.insert(emote.slashCommands, _G[slashCmd]);
				cIndex = cIndex + 1;
				slashCmd = "EMOTE" .. index .. "_CMD" .. cIndex;
			end
			table.insert(CACHED_EMOTES, emote);
		end
	end
	return CACHED_EMOTES;
end

-- weighted edit distance for similarity search
-- returns 0 for equal strings, 1 for "totally" different strings
-- insDelCost can be used to discount prefixes or suffixes, but should not be below 0.5
function addon.utils.editDistance(str1, str2, insDelCost)
	local len1 = string.len(str1);
	local len2 = string.len(str2);
	local matrix = {};
	local cost = 0;
	insDelCost = insDelCost or 1;
	
	if (len1 == 0) then
		return len2 > 0 and 1 or 0;
	elseif (len2 == 0) then
		return 1;
	elseif (str1 == str2) then
		return 0;
	end
	
	for i = 0, len1, 1 do
		matrix[i] = {};
		matrix[i][0] = i*insDelCost;
	end
	for j = 0, len2, 1 do
		matrix[0][j] = j*insDelCost;
	end
	
	for i = 1, len1, 1 do
		for j = 1, len2, 1 do
			if (str1:byte(i) == str2:byte(j)) then
				cost = 0;
			else
				cost = 1;
			end
			matrix[i][j] = math.min(matrix[i-1][j] + insDelCost, matrix[i][j-1] + insDelCost, matrix[i-1][j-1] + cost);
		end
	end
	
	return matrix[len1][len2]/math.max(len1, len2);
end

-- simplistic serialization
-- cannot handle cycles
-- cannot handle associative tables
-- cannot handle functions
function addon.utils.serializeLua(object)
	if type(object) == "nil" then
		return "nil";
	elseif type(object) == "boolean" then
		return object and "true" or "false";
	elseif type(object) == "number" then
		return tostring(object);
	elseif type(object) == "string" then
		return string.format("%q", object);
	elseif type(object) == "table" then
		local out = "{";
		local s = "";
		for _, element in ipairs(object) do
			out = out .. s .. addon.utils.serializeLua(element);
			s = ", ";
		end
		out = out .. "}";
		return out;
	end
	return "";
end

function addon.utils.getGameEvents()

	if CACHED_GAME_EVENTS then
		return CACHED_GAME_EVENTS;
	end

	CACHED_GAME_EVENTS = {
		{
			NA = "Total RP 3 Extended events",
			PR = true, -- priority in list
			EV =
			{
				{
					NA = "TRP3_KILL",
					PA =
					{
						{ NA = "unitType", TY = "string" }, -- [1]
						{ NA = "killerGUID", TY = "string" }, -- [2]
						{ NA = "killerName", TY = "string" }, -- [3]
						{ NA = "victimGUID", TY = "string" }, -- [4]
						{ NA = "victimName", TY = "string" }, -- [5]
						{ NA = "victimNPC_ID / victimPlayerClassID", TY = "string" }, -- [6]
						{ NA = "victimPlayerClassName", TY = "string" }, -- [7]
						{ NA = "victimPlayerRaceID", TY = "string" }, -- [8]
						{ NA = "victimPlayerRaceName", TY = "string" }, -- [9]
						{ NA = "victimPlayerGender", TY = "number" } -- [10]
					}
	
				},
				{
					NA = "TRP3_SIGNAL",
					PA =
					{
						{ NA = "signalID", TY = "string" }, -- [1]
						{ NA = "signalValue", TY = "string" }, -- [2]
						{ NA = "senderName", TY = "string" } -- [3]
					}
	
				},
				{
					NA = "TRP3_EMOTE",
					PA =
					{
						{ NA = "emoteToken", TY = "string" }, -- [1]
					}
				},
				{
					NA = "TRP3_ROLL",
					PA =
					{
						{ NA = "diceRolled", TY = "string" }, -- [1]
						{ NA = "result", TY = "number" } -- [2]
					}
	
				},
				{
					NA = "TRP3_ITEM_USED",
					PA =
					{
						{ NA = "itemID", TY = "string" }, -- [1]
						{ NA = "errorMessage", TY = "string" } -- [2]
					}
				}
			}
		}
	};

	APIDocumentation_LoadUI();

	local apiTable = APIDocumentation:GetAPITableByTypeName("system");
	for _, apiSystem in pairs(apiTable) do
		if apiSystem.Events and issecurevariable(apiSystem, "Events") and TableHasAnyEntries(apiSystem.Events) then
			local system = {NA = apiSystem.Name, EV = {}};
			for _, apiEvent in pairs(apiSystem.Events) do
				local event = {NA = apiEvent.LiteralName, PA = {}};
				for argIndex, payloadArg in pairs(apiEvent.Payload or TRP3_API.globals.empty) do
					table.insert(event.PA, {NA = payloadArg.Name, TY = payloadArg.Type, IX = argIndex});
				end
				table.sort(event.PA, function(a, b) return a.IX < b.IX; end);
				table.insert(system.EV, event);
			end
			table.sort(system.EV, function(a, b) return a.NA < b.NA; end);
			table.insert(CACHED_GAME_EVENTS, system);
		end
	end
	table.sort(CACHED_GAME_EVENTS, function(a, b) 
		if a.PR ~= b.PR then 
			return a.PR or false;
		end
		return a.NA < b.NA;
	end);

	return CACHED_GAME_EVENTS;
end
