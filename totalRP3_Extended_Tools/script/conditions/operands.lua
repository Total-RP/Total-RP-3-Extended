----------------------------------------------------------------------------------
-- Total RP 3: Extended features
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
----------------------------------------------------------------------------------

local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local tonumber, tostring, type, tinsert, wipe, strtrim = tonumber, tostring, type, tinsert, wipe, strtrim;
local tsize, EMPTY = Utils.table.size, Globals.empty;
local loc = TRP3_API.loc;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local registerOperandEditor = TRP3_API.extended.tools.registerOperandEditor;
local getUnitText = TRP3_API.extended.tools.getUnitText;
local UnitPosition = TRP3_API.extended.getUnitPositionSafe;

local unitTypeEditor, stringEditor, numericEditor = TRP3_OperandEditorUnitType, TRP3_OperandEditorString, TRP3_OperandEditorNumeric;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Shared editors
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local unitType;

local function initEnitTypeEditor()
	TRP3_API.ui.listbox.setupListBox(unitTypeEditor.type, unitType, nil, nil, 180, true);

	function unitTypeEditor.load(args)
		unitTypeEditor.type:SetSelectedValue((args or EMPTY)[1] or "target");
	end

	function unitTypeEditor.save()
		return {unitTypeEditor.type:GetSelectedValue() or "target"};
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Operands basic
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function string_init()
	registerOperandEditor("string", {
		title = loc.OP_STRING,
		noPreview = true,
		getText = function(args)
			local value = tostring(args or "");
			return loc.OP_STRING .. ": \"" .. value .. "\"";
		end,
		editor = stringEditor,
	});

	-- Text
	stringEditor.input.title:SetText(loc.OP_STRING);

	function stringEditor.load(value)
		stringEditor.input:SetText(value or "");
	end

	function stringEditor.save()
		return stringEditor.input:GetText();
	end
end

local function numeric_init()
	registerOperandEditor("numeric", {
		title = loc.OP_NUMERIC,
		noPreview = true,
		getText = function(args)
			local value = tonumber(args or 0) or 0;
			return loc.OP_NUMERIC .. ": " .. value .. "";
		end,
		editor = numericEditor,
	});

	-- Text
	numericEditor.input.title:SetText(loc.OP_NUMERIC);

	function numericEditor.load(value)
		numericEditor.input:SetText(tonumber(value or 0) or 0);
	end

	function numericEditor.save()
		return tonumber(numericEditor.input:GetText()) or 0;
	end
end

local function boolean_init()
	registerOperandEditor("boolean_true", {
		title = loc.OP_BOOL .. ": " .. loc.OP_BOOL_TRUE,
		noPreview = true,
	});
	registerOperandEditor("boolean_false", {
		title = loc.OP_BOOL .. ": " .. loc.OP_BOOL_FALSE,
		noPreview = true,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Unit value operands
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function unit_name_init()
	registerOperandEditor("unit_name", {
		title = loc.OP_OP_UNIT_NAME,
		description = loc.OP_OP_UNIT_NAME_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_NAME .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_id_init()
	registerOperandEditor("unit_id", {
		title = loc.OP_OP_UNIT_ID,
		description = loc.OP_OP_UNIT_ID_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_ID .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_npc_id_init()
	registerOperandEditor("unit_npc_id", {
		title = loc.OP_OP_UNIT_NPC_ID,
		description = loc.OP_OP_UNIT_NPC_ID_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_NPC_ID .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_guild_init()
	registerOperandEditor("unit_guild", {
		title = loc.OP_OP_UNIT_GUILD,
		description = loc.OP_OP_UNIT_GUILD_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_GUILD .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_guild_rank_init()
	registerOperandEditor("unit_guild_rank", {
		title = loc.OP_OP_UNIT_GUILD_RANK,
		description = loc.OP_OP_UNIT_GUILD_RANK_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_GUILD_RANK .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_race_init()
	registerOperandEditor("unit_race", {
		title = loc.OP_OP_UNIT_RACE,
		description = loc.OP_OP_UNIT_RACE_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_RACE .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_class_init()
	registerOperandEditor("unit_class", {
		title = loc.OP_OP_UNIT_CLASS,
		description = loc.OP_OP_UNIT_CLASS_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_CLASS .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_sex_init()
	registerOperandEditor("unit_sex", {
		title = loc.OP_OP_UNIT_SEX,
		description = loc.OP_OP_UNIT_SEX_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_SEX .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_faction_init()
	registerOperandEditor("unit_faction", {
		title = loc.OP_OP_UNIT_FACTION,
		description = loc.OP_OP_UNIT_FACTION_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_FACTION .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_creature_type_init()
	registerOperandEditor("unit_creature_type", {
		title = loc.OP_OP_UNIT_CREATURE_TYPE,
		description = loc.OP_OP_UNIT_CREATURE_TYPE_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_CREATURE_TYPE .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_creature_family_init()
	registerOperandEditor("unit_creature_family", {
		title = loc.OP_OP_UNIT_CREATURE_FAMILY,
		description = loc.OP_OP_UNIT_CREATURE_FAMILY_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_CREATURE_FAMILY .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_classification_init()
	registerOperandEditor("unit_classification", {
		title = loc.OP_OP_UNIT_CLASSIFICATION,
		description = loc.OP_OP_UNIT_CLASSIFICATION_TT,
		returnType = "",
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_CLASSIFICATION .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_health_init()
	registerOperandEditor("unit_health", {
		title = loc.OP_OP_UNIT_HEALTH,
		description = loc.OP_OP_UNIT_HEALTH_TT,
		returnType = 0,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_HEALTH .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_level_init()
	registerOperandEditor("unit_level", {
		title = loc.OP_OP_UNIT_LEVEL,
		description = loc.OP_OP_UNIT_LEVEL_TT,
		returnType = 0,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_LEVEL .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_speed_init()
	registerOperandEditor("unit_speed", {
		title = loc.OP_OP_UNIT_SPEED,
		description = loc.OP_OP_UNIT_SPEED_TT,
		returnType = 0,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_SPEED .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_position_x_init()
	registerOperandEditor("unit_position_x", {
		title = loc.OP_OP_UNIT_POSITION_X,
		description = loc.OP_OP_UNIT_POSITION_X_TT,
		returnType = 0,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_POSITION_X .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_position_y_init()
	registerOperandEditor("unit_position_y", {
		title = loc.OP_OP_UNIT_POSITION_Y,
		description = loc.OP_OP_UNIT_POSITION_Y_TT,
		returnType = 0,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_POSITION_Y .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_distance_point_init()
	local editor = TRP3_OperandEditorDistancePoint;
	registerOperandEditor("unit_distance_point", {
		title = loc.OP_OP_DISTANCE_POINT,
		description = loc.OP_OP_DISTANCE_POINT_TT,
		returnType = 0,
		getText = function(args)
			args = args or EMPTY;
			return loc.OP_OP_DISTANCE_POINT_PREVIEW:format(args[1] or "target", args[3] or 0, args[2] or 0);	-- See editor.load
		end,
		editor = editor,
	});

	TRP3_API.ui.listbox.setupListBox(editor.type, unitType, nil, nil, 180, true);

	editor.x.title:SetText(loc.OP_OP_DISTANCE_X);
	editor.y.title:SetText(loc.OP_OP_DISTANCE_Y);
	editor.current:SetText(loc.OP_OP_DISTANCE_CURRENT);
	editor.current:SetScript("OnClick", function()
		local uY, uX = UnitPosition("player");
		editor.x:SetText(string.format("%.2f", uX or 0));
		editor.y:SetText(string.format("%.2f", uY or 0));
	end);

	-- To make the coordinates fix compatible with old items, I'm just switching x and y in display and execution, saved data remains the same.
	function editor.load(args)
		editor.type:SetSelectedValue((args or EMPTY)[1] or "target");
		editor.x:SetText((args or EMPTY)[3] or "0");
		editor.y:SetText((args or EMPTY)[2] or "0");
	end

	function editor.save()
		return {editor.type:GetSelectedValue() or "target", tonumber(strtrim(editor.y:GetText())) or 0, tonumber(strtrim(editor.x:GetText())) or 0};
	end

	registerOperandEditor("unit_distance_me", {
		title = loc.OP_OP_DISTANCE_ME,
		description = loc.OP_OP_DISTANCE_ME_TT,
		returnType = 0,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_DISTANCE_ME .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Unit checks operands
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function unit_exists_init()
	registerOperandEditor("unit_exists", {
		title = loc.OP_OP_UNIT_EXISTS,
		description = loc.OP_OP_UNIT_EXISTS_TT,
		returnType = true,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_EXISTS .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_is_player_init()
	registerOperandEditor("unit_is_player", {
		title = loc.OP_OP_UNIT_ISPLAYER,
		description = loc.OP_OP_UNIT_ISPLAYER_TT,
		returnType = true,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_ISPLAYER .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_is_dead_init()
	registerOperandEditor("unit_is_dead", {
		title = loc.OP_OP_UNIT_DEAD,
		description = loc.OP_OP_UNIT_DEAD_TT,
		returnType = true,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_DEAD .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_distance_trade_init()
	registerOperandEditor("unit_distance_trade", {
		title = loc.OP_OP_UNIT_DISTANCE_TRADE,
		description = loc.OP_OP_UNIT_DISTANCE_TRADE_TT,
		returnType = true,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_DISTANCE_TRADE .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

local function unit_distance_inspect_init()
	registerOperandEditor("unit_distance_inspect", {
		title = loc.OP_OP_UNIT_DISTANCE_INSPECT,
		description = loc.OP_OP_UNIT_DISTANCE_INSPECT_TT,
		returnType = true,
		getText = function(args)
			local unitID = (args or EMPTY)[1] or "target";
			return loc.OP_OP_UNIT_DISTANCE_INSPECT .. " (" .. getUnitText(unitID) .. ")";
		end,
		editor = unitTypeEditor,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Character operands
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function char_facing_init()
	registerOperandEditor("char_facing", {
		title = loc.OP_OP_CHAR_FACING,
		description = loc.OP_OP_CHAR_FACING_TT,
		returnType = 0,
		getText = function(args)
			return loc.OP_OP_CHAR_FACING;
		end,
	});
end

local function char_falling_init()
	registerOperandEditor("char_falling", {
		title = loc.OP_OP_CHAR_FALLING,
		description = loc.OP_OP_CHAR_FALLING_TT,
		returnType = true,
		getText = function(args)
			return loc.OP_OP_CHAR_FALLING;
		end,
	});
end

local function char_stealth_init()
	registerOperandEditor("char_stealth", {
		title = loc.OP_OP_CHAR_STEALTH,
		description = loc.OP_OP_CHAR_STEALTH_TT,
		returnType = true,
		getText = function(args)
			return loc.OP_OP_CHAR_STEALTH;
		end,
	});
end

local function char_flying_init()
	registerOperandEditor("char_flying", {
		title = loc.OP_OP_CHAR_FLYING,
		description = loc.OP_OP_CHAR_FLYING_TT,
		returnType = true,
		getText = function(args)
			return loc.OP_OP_CHAR_FLYING;
		end,
	});
end

local function char_mounted_init()
	registerOperandEditor("char_mounted", {
		title = loc.OP_OP_CHAR_MOUNTED,
		description = loc.OP_OP_CHAR_MOUNTED_TT,
		returnType = true,
		getText = function(args)
			return loc.OP_OP_CHAR_MOUNTED;
		end,
	});
end

local function char_resting_init()
	registerOperandEditor("char_resting", {
		title = loc.OP_OP_CHAR_RESTING,
		description = loc.OP_OP_CHAR_RESTING_TT,
		returnType = true,
		getText = function(args)
			return loc.OP_OP_CHAR_RESTING;
		end,
	});
end

local function char_swimming_init()
	registerOperandEditor("char_swimming", {
		title = loc.OP_OP_CHAR_SWIMMING,
		description = loc.OP_OP_CHAR_SWIMMING_TT,
		returnType = true,
		getText = function(args)
			return loc.OP_OP_CHAR_SWIMMING;
		end,
	});
end

local function char_indoors_init()
	registerOperandEditor("char_indoors", {
		title = loc.OP_OP_CHAR_INDOORS,
		description = loc.OP_OP_CHAR_INDOORS_TT,
		returnType = true,
		getText = function(args)
			return loc.OP_OP_CHAR_INDOORS;
		end,
	});
end

local function char_zone_init()
	registerOperandEditor("char_zone", {
		title = loc.OP_OP_CHAR_ZONE,
		description = loc.OP_OP_CHAR_ZONE_TT,
		returnType = "",
		getText = function(args)
			return loc.OP_OP_CHAR_ZONE;
		end,
	});
end

local function char_subzone_init()
	registerOperandEditor("char_subzone", {
		title = loc.OP_OP_CHAR_SUBZONE,
		description = loc.OP_OP_CHAR_SUBZONE_TT,
		returnType = "",
		getText = function(args)
			return loc.OP_OP_CHAR_SUBZONE;
		end,
	});
end

local function char_minimap_init()
	registerOperandEditor("char_minimap", {
		title = loc.OP_OP_CHAR_MINIMAP,
		description = loc.OP_OP_CHAR_MINIMAP_TT,
		returnType = "",
		getText = function(args)
			return loc.OP_OP_CHAR_MINIMAP;
		end,
	});
end

local function char_cam_distance_init()
	registerOperandEditor("char_cam_distance", {
		title = loc.OP_OP_CHAR_CAM_DISTANCE,
		description = loc.OP_OP_CHAR_CAM_DISTANCE_TT,
		returnType = 1,
		getText = function(args)
			return loc.OP_OP_CHAR_CAM_DISTANCE;
		end,
	});
end

local function char_achievement_init()
	local editor = TRP3_OperandEditorAchievementSelection;
	
	local typesText = {
		account = loc.OP_OP_CHAR_ACHIEVEMENT_ACC,
		character = loc.OP_OP_CHAR_ACHIEVEMENT_CHAR
	}
	
	-- Achievement ID
	editor.id.title:SetText(loc.OP_OP_CHAR_ACHIEVEMENT_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.OP_OP_CHAR_ACHIEVEMENT_ID, loc.OP_OP_CHAR_ACHIEVEMENT_ID_TT);
	
	local types = {
		{TRP3_API.formats.dropDownElements:format(loc.OP_OP_CHAR_ACHIEVEMENT_WHO, loc.OP_OP_CHAR_ACHIEVEMENT_ACC), "account", loc.OP_OP_CHAR_ACHIEVEMENT_ACC_TT},
		{TRP3_API.formats.dropDownElements:format(loc.OP_OP_CHAR_ACHIEVEMENT_WHO, loc.OP_OP_CHAR_ACHIEVEMENT_CHAR), "character", loc.OP_OP_CHAR_ACHIEVEMENT_CHAR_TT}
	}
	
	TRP3_API.ui.listbox.setupListBox(editor.type, types, nil, nil, 200, true);
	
	function editor.load(args)
		editor.type:SetSelectedValue((args or EMPTY)[1] or "account");
		editor.id:SetText((args or EMPTY)[2] or "");
	end

	function editor.save()
		return {editor.type:GetSelectedValue() or "account", tonumber(strtrim(editor.id:GetText())) or 0};
	end
	
	registerOperandEditor("char_achievement" , {
		title = loc.OP_OP_CHAR_ACHIEVEMENT,
		description = loc.OP_OP_CHAR_ACHIEVEMENT_TT,
		returnType = true,
		getText = function(args)
			local achievementType = typesText[(args or EMPTY)[1]] or typesText.account;
			local achievementID = (args or EMPTY)[2] or "0";
			local _, achievementName = GetAchievementInfo(tonumber(achievementID));
			if achievementName == nil then
				achievementName = "|cffff0000[WRONG ID]|r"
			else
				achievementName = "|cffffff00[" .. achievementName .. "]|r"
			end
			return loc.OP_OP_CHAR_ACHIEVEMENT_PREVIEW:format(achievementName, achievementType);
		end,
		editor = editor,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Check vars
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function check_var_init()
	local editor = TRP3_OperandEditorCheckVar;

	local sourcesText = {
		w = loc.EFFECT_SOURCE_WORKFLOW,
		o = loc.EFFECT_SOURCE_OBJECT,
		c = loc.EFFECT_SOURCE_CAMPAIGN
	}

	registerOperandEditor("var_check", {
		title = loc.OP_OP_CHECK_VAR,
		description = loc.OP_OP_CHECK_VAR_TT,
		returnType = "",
		noPreview = true,
		getText = function(args)
			local source = sourcesText[(args or EMPTY)[1]] or sourcesText.w;
			local varName = tostring((args or EMPTY)[2] or "var");
			return loc.OP_OP_CHECK_VAR_PREVIEW:format(source, varName);
		end,
		editor = editor,
	});

	-- Source
	local sources = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_WORKFLOW), "w", loc.EFFECT_SOURCE_WORKFLOW_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_OBJECT), "o", loc.EFFECT_SOURCE_OBJECT_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_SOURCE, loc.EFFECT_SOURCE_CAMPAIGN), "c", loc.EFFECT_SOURCE_CAMPAIGN_TT}
	}
	TRP3_API.ui.listbox.setupListBox(editor.source, sources, nil, nil, 200, true);

	-- Var name
	editor.var.title:SetText(loc.EFFECT_VAR)
	setTooltipForSameFrame(editor.var.help, "RIGHT", 0, 5, loc.EFFECT_VAR, "");

	function editor.load(args)
		editor.source:SetSelectedValue((args or EMPTY)[1] or "w");
		editor.var:SetText((args or EMPTY)[2] or "var");
	end

	function editor.save()
		return {editor.source:GetSelectedValue() or "w", strtrim(editor.var:GetText()) or "var"};
	end

	registerOperandEditor("var_check_n", {
		title = loc.OP_OP_CHECK_VAR_N,
		description = loc.OP_OP_CHECK_VAR_N_TT,
		returnType = 0,
		getText = function(args)
			local source = sourcesText[(args or EMPTY)[1]] or sourcesText.w;
			local varName = tostring((args or EMPTY)[2] or "var");
			return loc.OP_OP_CHECK_VAR_N_PREVIEW:format(source, varName);
		end,
		editor = editor,
	});
end

local function check_event_var_init()
	local editor = TRP3_OperandEditorCheckEventArg;

	-- Var name
	editor.index.title:SetText(loc.EFFECT_VAR_INDEX);
	setTooltipForSameFrame(editor.index.help, "RIGHT", 0, 5, loc.EFFECT_VAR_INDEX, loc.EFFECT_VAR_INDEX_TT);

	function editor.load(args)
		editor.index:SetText((args or EMPTY)[1] or "1");
	end

	function editor.save()
		return {tonumber(strtrim(editor.index:GetText())) or 1};
	end

	registerOperandEditor("check_event_var", {
		title = loc.OP_OP_CHECK_EVENT_VAR,
		description = loc.OP_OP_CHECK_EVENT_VAR_TT,
		returnType = "",
		noPreview = true,
		getText = function(args)
			local varName = tostring((args or EMPTY)[1] or "1");
			return loc.OP_OP_CHECK_EVENT_VAR_PREVIEW:format(varName);
		end,
		editor = editor,
	});

	registerOperandEditor("check_event_var_n", {
		title = loc.OP_OP_CHECK_EVENT_VAR_N,
		description = loc.OP_OP_CHECK_EVENT_VAR_N_TT,
		returnType = 0,
		noPreview = true,
		getText = function(args)
			local varName = tostring((args or EMPTY)[1] or "1");
			return loc.OP_OP_CHECK_EVENT_VAR_N_PREVIEW:format(varName);
		end,
		editor = editor,
	});
end

local function random_init()
	local editor = TRP3_OperandEditorRandom;

	-- From
	editor.from.title:SetText(loc.OP_OP_RANDOM_FROM);
	editor.to.title:SetText(loc.OP_OP_RANDOM_TO);

	function editor.load(args)
		editor.from:SetText((args or EMPTY)[1] or "1");
		editor.to:SetText((args or EMPTY)[2] or "100");
	end

	function editor.save()
		return {tonumber(strtrim(editor.from:GetText())) or 1, tonumber(strtrim(editor.to:GetText())) or 100};
	end

	registerOperandEditor("random", {
		title = loc.OP_OP_RANDOM,
		description = loc.OP_OP_RANDOM_TT,
		returnType = 1,
		getText = function(args)
			local from = tostring((args or EMPTY)[1] or "1");
			local to = tostring((args or EMPTY)[2] or "100");
			return loc.OP_OP_RANDOM_PREVIEW:format(from, to);
		end,
		editor = editor,
	});
end

local function time_hour_init()
	registerOperandEditor("time_hour", {
		title = loc.OP_OP_TIME_HOUR,
		description = loc.OP_OP_TIME_HOUR_TT,
		returnType = true,
		getText = function(args)
			return loc.OP_OP_TIME_HOUR;
		end,
	});
end

local function time_minute_init()
	registerOperandEditor("time_minute", {
		title = loc.OP_OP_TIME_MINUTE,
		description = loc.OP_OP_TIME_MINUTE_TT,
		returnType = true,
		getText = function(args)
			return loc.OP_OP_TIME_MINUTE;
		end,
	});
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_ConditionEditor.initOperands()

	unitType = {
		{TRP3_API.formats.dropDownElements:format(loc.OP_UNIT, loc.OP_UNIT_PLAYER), "player"},
		{TRP3_API.formats.dropDownElements:format(loc.OP_UNIT, loc.OP_UNIT_TARGET), "target"},
		{TRP3_API.formats.dropDownElements:format(loc.OP_UNIT, loc.OP_UNIT_NPC), "npc"},
	}

	initEnitTypeEditor();

	string_init();
	boolean_init();
	numeric_init();

	random_init();

	check_var_init();
	check_event_var_init();

	-- Unit string
	unit_name_init();
	unit_id_init();
	unit_npc_id_init();
	unit_guild_init();
	unit_guild_rank_init();
	unit_race_init();
	unit_class_init();
	unit_sex_init();
	unit_faction_init();
	unit_creature_type_init();
	unit_creature_family_init();
	unit_classification_init();

	-- Unit numeric
	unit_health_init();
	unit_level_init();
	unit_speed_init();
	unit_position_x_init();
	unit_position_y_init();
	unit_distance_point_init();

	-- Unit checks
	unit_exists_init();
	unit_is_player_init();
	unit_is_dead_init();
	unit_distance_trade_init();
	unit_distance_inspect_init();

	-- Character values
	char_facing_init();
	char_falling_init();
	char_stealth_init();
	char_flying_init();
	char_mounted_init();
	char_resting_init();
	char_swimming_init();
	char_indoors_init();
	char_zone_init();
	char_subzone_init();
	char_minimap_init();
	char_cam_distance_init();
	char_achievement_init();

	time_hour_init();
	time_minute_init();

end