local _, addon = ...
local loc = TRP3_API.loc;

addon.script.formatters = {};

local SPECIAL_FORMATTERS = {};
function addon.script.formatters:Initialize()
	SPECIAL_FORMATTERS.achievement = function(parameter, value)
		local achievementId = tonumber(value or "") or 0;
		local _, achievementName = GetAchievementInfo(achievementId);
		if achievementName then
			return achievementName, false;
		else
			return addon.script.formatters.unknown(tostring(value or "")), true;
		end
	end;
	SPECIAL_FORMATTERS.boolean = function(parameter, value)
		return value and loc.OP_BOOL_TRUE or loc.OP_BOOL_FALSE, false;
	end;
	SPECIAL_FORMATTERS.sound = function(parameter, value, ...)
		value = tonumber(value or "0") or 0;
		if value <= 0 then
			return "no sound", false;
		end
		if select(1, ...) then
			return ("sound file id %d"):format(value), false;
		else
			return ("sound id %d"):format(value), false;
		end
	end;
	SPECIAL_FORMATTERS.music = function(parameter, musicPath)
		local musicId = tonumber(musicPath) or TRP3_API.utils.music.convertPathToID(musicPath) or musicPath;
		return tostring(musicId), false;
	end;
	SPECIAL_FORMATTERS.mount = function(parameter, mountId)
		local sanitizedMountId = tonumber(mountId or "0") or 0;
		if sanitizedMountId == 0 then
			return loc.EFFECT_SUMMOUNT_RANDOMMOUNT, false;
		end
		local mountName = C_MountJournal.GetMountInfoByID(sanitizedMountId);
		if mountName then
			return mountName, false;
		else
			return addon.script.formatters.unknown(tostring(mountId or "")), true;
		end
	end;
	for semanticObjectType, objectType in pairs(addon.script.parameter.objectMap) do
		SPECIAL_FORMATTERS[semanticObjectType] = function(parameter, absoluteId)
			absoluteId = tostring(absoluteId or "");
			local creationId = addon.utils.getCreationId(absoluteId);
			local relativeId;
			local class;
			if addon.editor.getCurrentDraftCreationId() == creationId then
				class = addon.editor.getCurrentDraftClass(absoluteId);
				relativeId = addon.editor.getRelativeId(absoluteId);
			else
				class = TRP3_API.extended.getClass(absoluteId);
				if class.missing then
					class = nil;
				else
					_, relativeId = addon.utils.splitId(absoluteId);
				end
			end
			if class and class.TY == objectType then
				local icon, link = addon.utils.getObjectIconAndLink(class, relativeId);
				link = ("|T%s:16:16|t %s"):format(icon, link);
				return link, true;
			elseif parameter.taggable then
				return absoluteId, false;
			else
				return addon.script.formatters.unknown(absoluteId), true;
			end
		end;
	end
end

function addon.script.formatters.taggable(value)
	return ("|cff8080ff%s|r"):format(value);
end

function addon.script.formatters.constant(value)
	return ("|cff00ff00%s|r"):format(value);
end

function addon.script.formatters.comparator(value)
	return ("|cffff8000%s|r"):format(value);
end

function addon.script.formatters.unknown(value)
	return ("|cffff0000<?%s>|r"):format(value);
end

function addon.script.formatParameter(parameter, value, ...)
	local paramText, paramIsDecorated;
	if SPECIAL_FORMATTERS[parameter.type] then
		paramText, paramIsDecorated = SPECIAL_FORMATTERS[parameter.type](parameter, value, ...);
	elseif parameter.values then
		for _, potentialValue in pairs(parameter.values) do
			if potentialValue[1] == value then
				paramText = potentialValue[2];
				break;
			end
		end
		if not paramText then
			paramText = addon.script.formatters.unknown(tostring(value or ""));
			paramIsDecorated = true;
		end
	else
		paramText = tostring(value or "");
	end
	if paramIsDecorated then
		return paramText;
	elseif parameter.taggable then
		return addon.script.formatters.taggable(paramText);
	else
		return addon.script.formatters.constant(paramText);
	end
end
TRP3_API.extended.tools.formatParameter = addon.script.formatParameter;

function addon.script.formatters.formatType(value)
	if type(value) == "nil" then
		return TRP3_API.Colors.Blue("nil");
	elseif type(value) == "boolean" then
		return TRP3_API.Colors.Blue(value and loc.OP_BOOL_TRUE or loc.OP_BOOL_FALSE);
	elseif type(value) == "number" then
		return TRP3_API.Colors.Green(tostring(value));
	elseif type(value) == "string" then
		return TRP3_API.Colors.White("\"" .. value .. "\"");
	elseif type(value) == "table" then
		return TRP3_API.Colors.Orange("table[" .. CountTable(value) .. "]");
	else
		return TRP3_API.Colors.Yellow(tostring(value));
	end
end
