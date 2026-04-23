local _, addon = ...

local clipboardData = {};

addon.clipboard = {};

addon.clipboard.types = {
	ITEM            = TRP3_DB.types.ITEM,
	AURA            = TRP3_DB.types.AURA,
	DOCUMENT        = TRP3_DB.types.DOCUMENT,
	DIALOG          = TRP3_DB.types.DIALOG,
	CAMPAIGN        = TRP3_DB.types.CAMPAIGN,
	QUEST           = TRP3_DB.types.QUEST,
	QUEST_STEP      = TRP3_DB.types.QUEST_STEP,
	DIALOG_STEP     = "DI_ST",
	DOCUMENT_PAGE   = "DO_PA",
	CAMPAIGN_NPC    = "CA_NPC",
	EFFECT          = "SC_ST", -- "script step"
	CONDITION_TEST  = "CO_EQ"
};

local TYPES_WITH_MD = {
	[TRP3_DB.types.ITEM]       = true,
	[TRP3_DB.types.AURA]       = true,
	[TRP3_DB.types.DOCUMENT]   = true,
	[TRP3_DB.types.DIALOG]     = true,
	[TRP3_DB.types.CAMPAIGN]   = true,
	[TRP3_DB.types.QUEST]      = true,
	[TRP3_DB.types.QUEST_STEP] = true,
};

local function canContain(parentType, innerType)
	return (
		innerType == addon.clipboard.types.ITEM
		or innerType == addon.clipboard.types.AURA
		or innerType == addon.clipboard.types.DOCUMENT
		or innerType == addon.clipboard.types.DIALOG
		or innerType == addon.clipboard.types.QUEST
		or innerType == addon.clipboard.types.QUEST_STEP
	) and (
		innerType ~= addon.clipboard.types.QUEST or parentType == TRP3_DB.types.CAMPAIGN
	) and (
		innerType ~= addon.clipboard.types.QUEST_STEP or parentType == TRP3_DB.types.QUEST
	);
end

function addon.clipboard.clear()
	wipe(clipboardData);
end

function addon.clipboard.append(class, type, absoluteId, relativeId, subId)
	local copy = {};
	TRP3_API.utils.table.copy(copy, class);
	if TYPES_WITH_MD[type] then
		copy.MD = {
			MO = TRP3_DB.modes.EXPERT
		};
	end
	table.insert(clipboardData, {
		class      = copy,
		type       = type,
		absoluteId = absoluteId,
		relativeId = relativeId,
		subId      = subId
	});
end

function addon.clipboard.count()
	return #clipboardData;
end

function addon.clipboard.isReplaceCompatible(type)
	return #clipboardData == 1 and clipboardData[1].type == type;
end

function addon.clipboard.isPasteCompatible(type)
	for _, entry in ipairs(clipboardData) do
		if type ~= entry.type then
			return false;
		end
	end
	return #clipboardData > 0;
end

function addon.clipboard.isInnerCompatible(type)
	for _, entry in ipairs(clipboardData) do
		if not canContain(type, entry.type) then
			return false;
		end
	end
	return #clipboardData > 0;
end

function addon.clipboard.retrieve(index)
	local copy = {};
	TRP3_API.utils.table.copy(copy, clipboardData[index or 1].class);
	return copy;
end

function addon.clipboard.retrieveShallow(index)
	return clipboardData[index or 1].class;
end

function addon.clipboard.retrieveId(index)
	return clipboardData[index or 1].absoluteId;
end
