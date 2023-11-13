local EMPTY = TRP3_API.globals.empty;
local getClass = TRP3_API.extended.getClass;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;
local registerEffectEditor = TRP3_API.extended.tools.registerEffectEditor;
local registerOperandEditor = TRP3_API.extended.tools.registerOperandEditor;
local loc = TRP3_API.loc;
local stEtN = TRP3_API.utils.str.emptyToNil;

local function getAuraNameFromClassId(classId)
	local id = tostring(classId);
	local class = getClass(id);
	if class ~= TRP3_DB.missing then
		return TRP3_API.inventory.getItemLink(class, id);
	else
		return id;
	end
end

local function setupAuraBrowser(editor)
	editor.browse:SetText(BROWSE);
	editor.browse:SetScript("OnClick", function()
		TRP3_API.popup.showPopup(TRP3_API.popup.OBJECTS, {parent = editor, point = "RIGHT", parentPoint = "LEFT"}, {function(id)
			editor.id:SetText(id);
		end, "AU"});
	end);

	editor.id.title:SetText(loc.AURA_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, loc.AURA_ID, loc.EFFECT_AURA_ID_TT);
end

local function aura_apply_init()
	local editor = TRP3_EffectEditorAuraApply;
	local mergeModeText = {
		[""] = loc.EFFECT_AURA_APPLY_DO_NOTHING,
		["="] = loc.EFFECT_AURA_APPLY_REFRESH,
		["+"] = loc.EFFECT_AURA_APPLY_EXTEND,
	};

	registerEffectEditor("aura_apply", {
		title = loc.EFFECT_AURA_APPLY,
		icon = "ability_priest_spiritoftheredeemer",
		description = loc.EFFECT_AURA_APPLY_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetFormattedText(
				loc.EFFECT_AURA_APPLY_PREVIEW,
				getAuraNameFromClassId(args[1]),
				loc.EFFECT_AURA_APPLY_MERGE_MODE,
				"|cff00ff00" .. mergeModeText[args[2] or ""] .. "|r"
			);
		end,
		getDefaultArgs = function()
			return {"", ""};
		end,
		editor = editor;
	});

	setupAuraBrowser(editor);

	local methods = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_AURA_APPLY_MERGE_MODE, loc.EFFECT_AURA_APPLY_DO_NOTHING), "", loc.EFFECT_AURA_APPLY_DO_NOTHING_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_AURA_APPLY_MERGE_MODE, loc.EFFECT_AURA_APPLY_REFRESH), "=", loc.EFFECT_AURA_APPLY_REFRESH_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_AURA_APPLY_MERGE_MODE, loc.EFFECT_AURA_APPLY_EXTEND), "+", loc.EFFECT_AURA_APPLY_EXTEND_TT},
	}
	TRP3_API.ui.listbox.setupListBox(editor.mergeMode, methods, nil, nil, 250, true);

	function editor.load(scriptData)
		local data = scriptData.args or EMPTY;
		editor.id:SetText(data[1] or "");
		editor.mergeMode:SetSelectedValue(data[2] or "");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
		scriptData.args[2] = editor.mergeMode:GetSelectedValue();
	end
end

local function aura_remove_init()
	local editor = TRP3_EffectEditorAuraRemove;

	registerEffectEditor("aura_remove", {
		title = loc.EFFECT_AURA_REMOVE,
		icon = "ability_titankeeper_cleansingorb",
		description = loc.EFFECT_AURA_REMOVE,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetFormattedText(
				loc.EFFECT_AURA_REMOVE_PREVIEW,
				getAuraNameFromClassId(args[1])
			);
		end,
		getDefaultArgs = function()
			return {""};
		end,
		editor = editor;
	});

	setupAuraBrowser(editor);

	function editor.load(scriptData)
		local data = scriptData.args or EMPTY;
		editor.id:SetText(data[1] or "");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
	end
end

local function aura_duration_init()
	local editor = TRP3_EffectEditorAuraDuration;

	registerEffectEditor("aura_duration", {
		title = loc.EFFECT_AURA_DURATION,
		icon = "achievement_guildperk_workingovertime",
		description = loc.EFFECT_AURA_DURATION_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetFormattedText(
				loc.EFFECT_AURA_DURATION_PREVIEW,
				getAuraNameFromClassId(args[1]),
				args[2] or "0",
				args[3]
			);
		end,
		getDefaultArgs = function()
			return {"", "0", "="};
		end,
		editor = editor;
	});

	setupAuraBrowser(editor);

	editor.duration.title:SetText(loc.AU_FIELD_DURATION);
	setTooltipForSameFrame(editor.duration.help, "RIGHT", 0, 5, loc.AU_FIELD_DURATION, loc.AU_FIELD_DURATION_TT);

	local methods = {
		{TRP3_API.formats.dropDownElements:format(loc.AU_FIELD_DURATION, loc.EFFECT_AURA_DURATION_SET), "=", loc.EFFECT_AURA_DURATION_SET_TT},
		{TRP3_API.formats.dropDownElements:format(loc.AU_FIELD_DURATION, loc.EFFECT_AURA_DURATION_ADD), "+", loc.EFFECT_AURA_DURATION_ADD_TT},
		{TRP3_API.formats.dropDownElements:format(loc.AU_FIELD_DURATION, loc.EFFECT_AURA_DURATION_SUBTRACT), "-", loc.EFFECT_AURA_DURATION_SUBTRACT_TT},
	}
	TRP3_API.ui.listbox.setupListBox(editor.method, methods, nil, nil, 250, true);

	function editor.load(scriptData)
		local data = scriptData.args or EMPTY;
		editor.id:SetText(data[1] or "");
		editor.duration:SetText(data[2] or "0");
		editor.method:SetSelectedValue(data[3] or "=");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
		scriptData.args[2] = stEtN(strtrim(editor.duration:GetText()));
		scriptData.args[3] = editor.method:GetSelectedValue();
	end
end

local function aura_var_set_init()
	local editor = TRP3_EffectEditorAuraVarChange;

	registerEffectEditor("aura_var_set", {
		title = loc.EFFECT_VAR_AURA_CHANGE,
		icon = "inv_10_inscription2_repcontracts_scroll_02_uprez",
		description = loc.EFFECT_VAR_AURA_CHANGE_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetFormattedText(
				loc.EFFECT_VAR_AURA_CHANGE_PREVIEW,
				getAuraNameFromClassId(args[1]),
				args[2],
				args[3] or "",
				args[4] or ""
			);
		end,
		getDefaultArgs = function()
			return {"", "[=]", "varName", "0"};
		end,
		editor = editor,
	});

	setupAuraBrowser(editor);

	-- Var name
	editor.var.title:SetText(loc.EFFECT_VAR);
	setTooltipForSameFrame(editor.var.help, "RIGHT", 0, 5, loc.EFFECT_VAR, "");

	-- Var value
	editor.value.title:SetText(loc.EFFECT_OPERATION_VALUE);
	setTooltipForSameFrame(editor.value.help, "RIGHT", 0, 5, loc.EFFECT_OPERATION_VALUE, "");

	-- Type
	local types = {
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_INIT), "[=]", loc.EFFECT_OPERATION_TYPE_INIT_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_SET), "=", loc.EFFECT_OPERATION_TYPE_SET_TT},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_ADD), "+"},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_SUB), "-"},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_MULTIPLY), "x"},
		{TRP3_API.formats.dropDownElements:format(loc.EFFECT_OPERATION_TYPE, loc.EFFECT_OPERATION_TYPE_DIV), "/"}
	};
	TRP3_API.ui.listbox.setupListBox(editor.type, types, nil, nil, 250, true);

	function editor.load(scriptData)
		local data = scriptData.args or EMPTY;
		editor.id:SetText(data[1] or "");
		editor.type:SetSelectedValue(data[2] or "[=]");
		editor.var:SetText(data[3] or "varName");
		editor.value:SetText(data[4] or "0");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText())) or "";
		scriptData.args[2] = editor.type:GetSelectedValue() or "[=]";
		scriptData.args[3] = stEtN(strtrim(editor.var:GetText())) or "";
		scriptData.args[4] = stEtN(strtrim(editor.value:GetText())) or "";
	end

end

local function run_workflow_init()
	local editor = TRP3_EffectEditorRunAuraWorkflow;

	registerEffectEditor("aura_run_workflow", {
		title = loc.EFFECT_AURA_RUN_WORKFLOW,
		icon = "inv_engineering_90_electrifiedether",
		description = loc.EFFECT_AURA_RUN_WORKFLOW_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetFormattedText(
				loc.EFFECT_AURA_RUN_WORKFLOW_PREVIEW,
				getAuraNameFromClassId(args[1]),
				args[2] or ""
			);
		end,
		getDefaultArgs = function()
			return {"", "id"};
		end,
		editor = editor
	});

	setupAuraBrowser(editor);

	editor.workflow.title:SetText(loc.EFFECT_RUN_WORKFLOW_ID);
	setTooltipForSameFrame(editor.workflow.help, "RIGHT", 0, 5, loc.EFFECT_RUN_WORKFLOW_ID, loc.EFFECT_RUN_WORKFLOW_ID_TT);

	function editor.load(scriptData)
		local data = scriptData.args or EMPTY;
		editor.id:SetText(data[1] or "");
		editor.workflow:SetText(data[2] or "id");
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
		scriptData.args[2] = stEtN(strtrim(editor.workflow:GetText())) or "";
	end

end

local function aura_property_init()
	local editor = TRP3_OperandEditorAuraProperty;

	registerOperandEditor("aura_active", {
		title = loc.OP_OP_AURA_ACTIVE,
		description = loc.OP_OP_AURA_ACTIVE_TT,
		returnType = false,
		getText = function(args)
			return loc.OP_OP_AURA_ACTIVE_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
		end,
		editor = editor,
		getDefaultArgs = function()
			return {""};
		end,
	});

	registerOperandEditor("aura_duration", {
		title = loc.OP_OP_AURA_DURATION,
		description = loc.OP_OP_AURA_DURATION_TT,
		returnType = 0,
		getText = function(args)
			return loc.OP_OP_AURA_DURATION_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
		end,
		editor = editor,
		getDefaultArgs = function()
			return {""};
		end,
	});

	registerOperandEditor("aura_helpful", {
		title = loc.OP_OP_AURA_HELPFUL,
		description = loc.OP_OP_AURA_HELPFUL_TT,
		returnType = false,
		getText = function(args)
			return loc.OP_OP_AURA_HELPFUL_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
		end,
		editor = editor,
		getDefaultArgs = function()
			return {""};
		end,
	});

	registerOperandEditor("aura_cancellable", {
		title = loc.OP_OP_AURA_CANCELLABLE,
		description = loc.OP_OP_AURA_CANCELLABLE_TT,
		returnType = false,
		getText = function(args)
			return loc.OP_OP_AURA_CANCELLABLE_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
		end,
		editor = editor,
		getDefaultArgs = function()
			return {""};
		end,
	});

	registerOperandEditor("aura_name", {
		title = loc.OP_OP_AURA_NAME,
		description = loc.OP_OP_AURA_NAME_TT,
		returnType = "",
		getText = function(args)
			return loc.OP_OP_AURA_NAME_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
		end,
		editor = editor,
		getDefaultArgs = function()
			return {""};
		end,
	});

	registerOperandEditor("aura_category", {
		title = loc.OP_OP_AURA_CATEGORY,
		description = loc.OP_OP_AURA_CATEGORY_TT,
		returnType = "",
		getText = function(args)
			return loc.OP_OP_AURA_CATEGORY_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
		end,
		editor = editor,
		getDefaultArgs = function()
			return {""};
		end,
	});

	registerOperandEditor("aura_icon", {
		title = loc.OP_OP_AURA_ICON,
		description = loc.OP_OP_AURA_ICON_TT,
		returnType = "",
		getText = function(args)
			return loc.OP_OP_AURA_ICON_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
		end,
		editor = editor,
		getDefaultArgs = function()
			return {""};
		end,
	});

	registerOperandEditor("aura_color", {
		title = loc.OP_OP_AURA_COLOR,
		description = loc.OP_OP_AURA_COLOR_TT,
		returnType = "",
		getText = function(args)
			return loc.OP_OP_AURA_COLOR_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
		end,
		editor = editor,
		getDefaultArgs = function()
			return {""};
		end,
	});

	setupAuraBrowser(editor);

	function editor.load(args)
		editor.id:SetText(args and args[1] or "");
	end

	function editor.save()
		return {stEtN(strtrim(editor.id:GetText()))};
	end
end

local function check_var_init()
	local editor = TRP3_OperandEditorAuraCheckVar;

	registerOperandEditor("aura_var_check", {
		title = loc.OP_OP_AURA_CHECK_VAR,
		description = loc.OP_OP_AURA_CHECK_VAR_TT,
		returnType = "",
		noPreview = true,
		getText = function(args)
			return loc.OP_OP_AURA_CHECK_VAR_PREVIEW:format(
				getAuraNameFromClassId(args and args[1] or ""),
				(args or EMPTY)[2] or "var"
			);
		end,
		editor = editor,
	});

	registerOperandEditor("aura_var_check_n", {
		title = loc.OP_OP_AURA_CHECK_VAR_N,
		description = loc.OP_OP_AURA_CHECK_VAR_N_TT,
		returnType = 0,
		noPreview = true,
		getText = function(args)
			return loc.OP_OP_AURA_CHECK_VAR_N_PREVIEW:format(
				getAuraNameFromClassId(args and args[1] or ""),
				(args or EMPTY)[2] or "var"
			);
		end,
		editor = editor,
	});

	setupAuraBrowser(editor);

	-- Var name
	editor.var.title:SetText(loc.EFFECT_VAR);
	setTooltipForSameFrame(editor.var.help, "RIGHT", 0, 5, loc.EFFECT_VAR, "");

	function editor.load(args)
		editor.id:SetText((args or EMPTY)[1] or "");
		editor.var:SetText((args or EMPTY)[2] or "var");
	end

	function editor.save()
		return {stEtN(strtrim(editor.id:GetText())), stEtN(strtrim(editor.var:GetText())) or "var"};
	end

end

local function aura_id_init()
	local editor = TRP3_OperandEditorAuraId;
	registerOperandEditor("aura_id", {
		title = loc.OP_OP_AURA_ID,
		description = loc.OP_OP_AURA_ID_TT,
		returnType = "",
		noPreview = true,
		getText = function(args)
			return loc.OP_OP_AURA_ID_PREVIEW:format(
				args and args[1] or "1"
			);
		end,
		editor = editor,
	});

	editor.index.title:SetText(loc.OP_OP_AURA_ID_INDEX);
	setTooltipForSameFrame(editor.index.help, "RIGHT", 0, 5, loc.OP_OP_AURA_ID_INDEX, loc.OP_OP_AURA_ID_INDEX_TT);

	function editor.load(args)
		editor.index:SetText((args or EMPTY)[1] or "1");
	end

	function editor.save()
		return {stEtN(strtrim(editor.index:GetText())) or "1"};
	end
end

local function aura_count_init()
	registerOperandEditor("aura_count", {
		title = loc.OP_OP_AURA_COUNT,
		description = loc.OP_OP_AURA_COUNT_TT,
		returnType = 0,
		getText = function(args) -- luacheck: ignore 212
			return loc.OP_OP_AURA_COUNT;
		end,
	});
end

TRP3_API.extended.tools.initAuraEffects = function()
	aura_apply_init();
	aura_remove_init();
	aura_duration_init();
	aura_var_set_init();
	run_workflow_init();

	aura_count_init();
	aura_id_init();
	aura_property_init();
	check_var_init();
end
