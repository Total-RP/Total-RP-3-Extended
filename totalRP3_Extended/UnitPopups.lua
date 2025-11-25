-- Copyright The Total RP 3 Authors
-- SPDX-License-Identifier: Apache-2.0

TRP3_API.extended.unitpopups = {};

local function ShouldShowExtendedOpenExchange(contextData)
	local unit = contextData.unit;
	local name = contextData.name;
	local server = contextData.server;
	local fullName = string.join("-", name or UNKNOWNOBJECT, server or GetNormalizedRealmName());

	if UnitIsPlayer(unit) and fullName ~= TRP3_API.globals.player_id and not TRP3_API.register.isIDIgnored(fullName) and TRP3_API.register.isUnitKnown(unit) then
		local character = TRP3_API.register.getUnitIDCharacter(fullName);
		return (tonumber(character.extended or 0) or 0) > 0;
	end
	return false;
end

local function ShouldShowExtendedCharacterInspection(contextData)
	local unit = contextData.unit;
	local name = contextData.name;
	local server = contextData.server;
	local fullName = string.join("-", name or UNKNOWNOBJECT, server or GetNormalizedRealmName());

	if UnitIsPlayer(unit) and fullName ~= TRP3_API.globals.player_id and not TRP3_API.register.isIDIgnored(fullName) and TRP3_API.register.isUnitKnown(unit) then
		local character = TRP3_API.register.getUnitIDCharacter(fullName);
		return (tonumber(character.extended or 0) or 0) > 0;
	end
	return false;
end

local function CreateExtendedOpenExchange(menuDescription, contextData)
	if not ShouldShowExtendedOpenExchange(contextData) then
		return nil;
	end

	local function OnClick(contextData)  -- luacheck: no redefined
		local name = contextData.name;
		local server = contextData.server;
		local fullName = string.join("-", name or UNKNOWNOBJECT, server or GetNormalizedRealmName());

		if not string.find(fullName, UNKNOWNOBJECT, 1, true) then
			TRP3_API.inventory.startEmptyExchangeWithUnit(fullName);
		end
	end

	local elementDescription = menuDescription:CreateButton(TRP3_API.loc.UNIT_POPUPS_EXTENDED_OPEN_EXCHANGE);
	elementDescription:SetResponder(OnClick);
	elementDescription:SetData(contextData);
	return elementDescription;
end

local function CreateExtendedCharacterInspection(menuDescription, contextData)
	if not ShouldShowExtendedCharacterInspection(contextData) then
		return nil;
	end

	local function OnClick(contextData)  -- luacheck: no redefined
		local name = contextData.name;
		local server = contextData.server;
		local fullName = string.join("-", name or UNKNOWNOBJECT, server or GetNormalizedRealmName());

		if not string.find(fullName, UNKNOWNOBJECT, 1, true) then
			TRP3_API.inventory.requestCharacterInspection(fullName);
		end
	end

	local elementDescription = menuDescription:CreateButton(TRP3_API.loc.UNIT_POPUPS_EXTENDED_CHARACTER_INSPECTION);
	elementDescription:SetResponder(OnClick);
	elementDescription:SetData(contextData);
	return elementDescription;
end


function TRP3_API.extended.unitpopups.init()
	if not TRP3_UnitPopupsModule then return end

	TRP3_UnitPopupsModule.MenuElementFactories["ExtendedOpenExchange"] = CreateExtendedOpenExchange;
	TRP3_UnitPopupsModule.MenuElementFactories["ExtendedCharacterInspection"] = CreateExtendedCharacterInspection;

	local unitTypesAllowed = {
		"CHAT_ROSTER",
		"COMMUNITIES_GUILD_MEMBER",
		"COMMUNITIES_WOW_MEMBER",
		"FRIEND",
		"PARTY",
		"PLAYER",
		"RAID",
		"RAID_PLAYER",
	};

	for _, unitType in pairs(unitTypesAllowed) do
		tinsert(TRP3_UnitPopupsModule.MenuEntries[unitType], "ExtendedOpenExchange");
		tinsert(TRP3_UnitPopupsModule.MenuEntries[unitType], "ExtendedCharacterInspection");
	end
end
