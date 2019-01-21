if not WoWUnit then
	return
end

---@type TRP3_API
local TRP3_API = TRP3_API;

local Tests = WoWUnit('TRP3:E Emotes', "PLAYER_ENTERING_WORLD");

-- TODO Replace this test with the actual expected values
function Tests:SplitEmotesList()
	-- Given
	local input = {
		"d",
		"b",
		"a",
		"c"
	}

	-- When
	local splittedTable = TRP3_API.utils.splitTableIntoSmallerAlphabetizedTables(input)

	-- Then
	WoWUnit.AreEqual(splittedTable, {
		"a",
		"b",
		"c",
		"d"
	})
end

WoWUnit:Show()
