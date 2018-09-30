----------------------------------------------------------------------------------
--- Total RP 3
---    ---------------------------------------------------------------------------
---    Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
--- Copyright 2018 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---                Solanya <solanya@totalrp3.info> @Solanya_
---    Licensed under the Apache License, Version 2.0 (the "License");
---    you may not use this file except in compliance with the License.
---    You may obtain a copy of the License at
---
---        http://www.apache.org/licenses/LICENSE-2.0
---
---    Unless required by applicable law or agreed to in writing, software
---    distributed under the License is distributed on an "AS IS" BASIS,
---    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
---    See the License for the specific language governing permissions and
---    limitations under the License.
----------------------------------------------------------------------------------

local Ellyb = TRP3_API.Ellyb;
---@type AddOn_TotalRP3
local AddOn_TotalRP3 = AddOn_TotalRP3;

--region Lua imports
local tonumber = tonumber;
local insert = table.insert;
--endregion

--region WoW imports
local CreateVector2D = CreateVector2D;
--endregion

--region Total RP 3 imports
local Globals = TRP3_API.globals;
local loc = TRP3_API.loc;
local broadcast = AddOn_TotalRP3.Communications.broadcast;
local Map = AddOn_TotalRP3.Map;
--endregion

--
-- Self stash scan
--

---@type MapScanner
local stashSelfMapScanner = AddOn_TotalRP3.MapScanner("stashSelfScan")
-- Set scan display properties
stashSelfMapScanner.scanIcon = "Inv_misc_map_01"
stashSelfMapScanner.scanOptionText = loc.DR_STASHES_SCAN_MY;
stashSelfMapScanner.scanTitle = loc.DR_STASHES;
-- Indicate the name of the pin template to use with this scan.
-- The MapDataProvider will use this template to generate the pin
stashSelfMapScanner.dataProviderTemplate = TRP3_StashMapPinMixin.TEMPLATE_NAME;

--region Scan behavior
function stashSelfMapScanner:Scan()
	local mapID = WorldMapFrame:GetMapID();
	local stashData = TRP3_Stashes[Globals.player_realm];
	for index, stash in pairs(stashData) do
		if stash.uiMapID == mapID then
			stashSelfMapScanner:OnScanDataReceived(Globals.player_id, stash.mapX, stash.mapY, stash)
		end
	end
end

-- Players can only scan for their own stashes in zones where it is possible to retrieve player coordinates.
function stashSelfMapScanner:CanScan()
	local x, y = Map.getPlayerCoordinates()
	if x and y then
		return true;
	end
	return false;
end
--endregion

--
-- Self drop scan
--

---@type MapScanner
local dropSelfMapScanner = AddOn_TotalRP3.MapScanner("dropSelfScan")
-- Set scan display properties
dropSelfMapScanner.scanIcon = "inv_misc_bag_16"
dropSelfMapScanner.scanOptionText = loc.IT_INV_SCAN_MY_ITEMS;
dropSelfMapScanner.scanTitle = loc.TYPE_ITEMS;
-- Indicate the name of the pin template to use with this scan.
-- The MapDataProvider will use this template to generate the pin
dropSelfMapScanner.dataProviderTemplate = TRP3_DropMapPinMixin.TEMPLATE_NAME;

--region Scan behavior
function dropSelfMapScanner:Scan()
	local mapID = WorldMapFrame:GetMapID();
	local dropData = TRP3_Drop[Globals.player_realm];
	for index, drop in pairs(dropData) do
		if drop.uiMapID == mapID then
			dropSelfMapScanner:OnScanDataReceived(Globals.player_id, drop.mapX, drop.mapY, drop)
		end
	end
end

-- Players can only scan for their own drps in zones where it is possible to retrieve player coordinates.
function dropSelfMapScanner:CanScan()
	local x, y = Map.getPlayerCoordinates()
	if x and y then
		return true;
	end
	return false;
end
--endregion

--
-- Others stash scan
--

local STASHES_SCAN_COMMAND = "S_SCAN";

---@type MapScanner
local stashOthersMapScanner = AddOn_TotalRP3.MapScanner("inventoryOthersScan")
-- Set scan display properties
stashOthersMapScanner.scanIcon = "Icon_treasuremap"
stashOthersMapScanner.scanOptionText = loc.DR_STASHES_SCAN;
stashOthersMapScanner.scanTitle = loc.DR_STASHES;
-- Indicate the name of the pin template to use with this scan.
-- The MapDataProvider will use this template to generate the pin
stashOthersMapScanner.dataProviderTemplate = TRP3_DropMapPinMixin.TEMPLATE_NAME;

--region Scan behavior
function stashOthersMapScanner:Scan()
	broadcast.broadcast(STASHES_SCAN_COMMAND, Map.getDisplayedMapID());
end

-- Players can scan for others' stashes everywhere (as we don't have a way to know if a map is from an instance or not ? Will just get no answers).
function stashOthersMapScanner:CanScan()
	return true;
end
--endregion

--region Broadcast commands
broadcast.registerCommand(STASHES_SCAN_COMMAND, function(sender, mapID)
	if Map.playerCanSeeTarget(sender) then
		mapID = tonumber(mapID);
		if shouldAnswerToLocationRequest() and Map.playerCanSeeTarget(sender) then
			local playerMapID = Map.getPlayerMapID();
			if playerMapID ~= mapID then
				return
			end
			local x, y = Map.getPlayerCoordinates();
			if x and y then
				broadcast.sendP2PMessage(sender, SCAN_COMMAND, x, y, playerMapID);
			end
		end
	end
end)

broadcast.registerP2PCommand(STASHES_SCAN_COMMAND, function(sender, x, y)
	if Map.playerCanSeeTarget(sender) then
		inventorySelfMapScanner:OnScanDataReceived(sender, x, y)
	end
end)
--endregion