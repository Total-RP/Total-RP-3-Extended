local EMPTY = TRP3_API.globals.empty;
local getClass = TRP3_API.extended.getClass
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame
local registerEffectEditor = TRP3_API.extended.tools.registerEffectEditor
local registerOperandEditor = TRP3_API.extended.tools.registerOperandEditor
local L = TRP3_API.loc
local TRP3_DB = TRP3_DB
local stEtN = TRP3_API.utils.str.emptyToNil

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

	editor.id.title:SetText(L.AURA_ID);
	setTooltipForSameFrame(editor.id.help, "RIGHT", 0, 5, L.AURA_ID, L.EFFECT_AURA_ID_TT);
end

local function aura_apply_init()
	local editor = TRP3_EffectEditorAuraApply;

	registerEffectEditor("aura_apply", {
		title = L.EFFECT_AURA_APPLY,
		icon = "ability_priest_spiritoftheredeemer",
		description = L.EFFECT_AURA_APPLY_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetFormattedText(
				L.EFFECT_AURA_APPLY_PREVIEW,
				getAuraNameFromClassId(args[1]),
				args[2] and L.EFFECT_AURA_APPLY_EXTEND_FRAGMENT or ""
			);
		end,
		getDefaultArgs = function()
			return {"", false};
		end,
		editor = editor;
	});

	setupAuraBrowser(editor);
	
	editor.extend.Text:SetText(L.EFFECT_AURA_APPLY_EXTEND);
	setTooltipForSameFrame(editor.extend, "RIGHT", 0, 5, L.EFFECT_AURA_APPLY_EXTEND, L.EFFECT_AURA_APPLY_EXTEND_TT);
	
	function editor.load(scriptData)
		local data = scriptData.args or EMPTY;
		editor.id:SetText(data[1] or "");
		editor.extend:SetChecked(data[2]);
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
		scriptData.args[2] = editor.extend:GetChecked();
	end
end

local function aura_remove_init()
	local editor = TRP3_EffectEditorAuraRemove;

	registerEffectEditor("aura_remove", {
		title = L.EFFECT_AURA_REMOVE,
		icon = "ability_titankeeper_cleansingorb",
		description = L.EFFECT_AURA_REMOVE,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetFormattedText(
				L.EFFECT_AURA_REMOVE_PREVIEW,
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
		title = L.EFFECT_AURA_DURATION,
		icon = "achievement_guildperk_workingovertime",
		description = L.EFFECT_AURA_DURATION_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetFormattedText(
				L.EFFECT_AURA_DURATION_PREVIEW,
				getAuraNameFromClassId(args[1]),
				args[2],
				args[3]
			);
		end,
		getDefaultArgs = function()
			return {"", "0", "="};
		end,
		editor = editor;
	});

	setupAuraBrowser(editor);

	editor.duration.title:SetText(L.AURA_DURATION);
	setTooltipForSameFrame(editor.duration.help, "RIGHT", 0, 5, L.AURA_DURATION, L.AURA_DURATION_TT);
	
	local methods = {
		{TRP3_API.formats.dropDownElements:format(L.AURA_DURATION, L.EFFECT_AURA_DURATION_SET), "=", L.EFFECT_AURA_DURATION_SET_TT},
		{TRP3_API.formats.dropDownElements:format(L.AURA_DURATION, L.EFFECT_AURA_DURATION_ADD), "+", L.EFFECT_AURA_DURATION_ADD_TT},
		{TRP3_API.formats.dropDownElements:format(L.AURA_DURATION, L.EFFECT_AURA_DURATION_SUBTRACT), "-", L.EFFECT_AURA_DURATION_SUBTRACT_TT},
	}
	TRP3_API.ui.listbox.setupListBox(editor.method, methods, nil, nil, 250, true);
	
	function editor.load(scriptData)
		local data = scriptData.args or EMPTY;
		editor.id:SetText(data[1] or "");
		editor.duration:SetText(data[2] or "0");
		editor.method:SetSelectedValue(data[3] or "=")
	end

	function editor.save(scriptData)
		scriptData.args[1] = stEtN(strtrim(editor.id:GetText()));
		scriptData.args[2] = stEtN(strtrim(editor.duration:GetText()));
		scriptData.args[3] = editor.method:GetSelectedValue()
	end
end

local function aura_var_set_init()
	local editor = TRP3_EffectEditorAuraVarChange;

	registerEffectEditor("aura_var_set", {
		title = L.EFFECT_VAR_AURA_CHANGE,
		icon = "inv_10_inscription2_repcontracts_scroll_02_uprez",
		description = L.EFFECT_VAR_AURA_CHANGE_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			scriptStepFrame.description:SetFormattedText(
				L.EFFECT_VAR_AURA_CHANGE_PREVIEW,
				getAuraNameFromClassId(args[1]),
				args[2],
				tostring(args[3]),
				tostring(args[4])
			);
		end,
		getDefaultArgs = function()
			return {"", "[=]", "varName", 0};
		end,
		editor = editor,
	});

	setupAuraBrowser(editor);
	
	-- Var name
	editor.var.title:SetText(L.EFFECT_VAR)
	setTooltipForSameFrame(editor.var.help, "RIGHT", 0, 5, L.EFFECT_VAR, "");

	-- Var value
	editor.value.title:SetText(L.EFFECT_OPERATION_VALUE);
	setTooltipForSameFrame(editor.value.help, "RIGHT", 0, 5, L.EFFECT_OPERATION_VALUE, "");

	-- Type
	local types = {
		{TRP3_API.formats.dropDownElements:format(L.EFFECT_OPERATION_TYPE, L.EFFECT_OPERATION_TYPE_INIT), "[=]", L.EFFECT_OPERATION_TYPE_INIT_TT},
		{TRP3_API.formats.dropDownElements:format(L.EFFECT_OPERATION_TYPE, L.EFFECT_OPERATION_TYPE_SET), "=", L.EFFECT_OPERATION_TYPE_SET_TT},
		{TRP3_API.formats.dropDownElements:format(L.EFFECT_OPERATION_TYPE, L.EFFECT_OPERATION_TYPE_ADD), "+"},
		{TRP3_API.formats.dropDownElements:format(L.EFFECT_OPERATION_TYPE, L.EFFECT_OPERATION_TYPE_SUB), "-"},
		{TRP3_API.formats.dropDownElements:format(L.EFFECT_OPERATION_TYPE, L.EFFECT_OPERATION_TYPE_MULTIPLY), "x"},
		{TRP3_API.formats.dropDownElements:format(L.EFFECT_OPERATION_TYPE, L.EFFECT_OPERATION_TYPE_DIV), "/"}
	}
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
		title = L.EFFECT_AURA_RUN_WORKFLOW,
		icon = "inv_engineering_90_electrifiedether",
		description = L.EFFECT_AURA_RUN_WORKFLOW_TT,
		effectFrameDecorator = function(scriptStepFrame, args)
			local id = tostring(args[2]);
			scriptStepFrame.description:SetText(
				L.EFFECT_AURA_RUN_WORKFLOW_PREVIEW,
				getAuraNameFromClassId(args[1]),
				tostring(args[2])
			);
		end,
		getDefaultArgs = function()
			return {"", "id"};
		end,
		editor = editor
	});

	setupAuraBrowser(editor);

	editor.workflow.title:SetText(L.EFFECT_RUN_WORKFLOW_ID);
	setTooltipForSameFrame(editor.workflow.help, "RIGHT", 0, 5, L.EFFECT_RUN_WORKFLOW_ID, L.EFFECT_RUN_WORKFLOW_ID_TT);

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
		title = L.OP_OP_AURA_ACTIVE,
		description = L.OP_OP_AURA_ACTIVE_TT,
		returnType = false,
		getText = function(args)
			return L.OP_OP_AURA_ACTIVE_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
		end,
		editor = editor,
		getDefaultArgs = function()
			return {""};
		end,
	});
	
	registerOperandEditor("aura_duration", {
		title = L.OP_OP_AURA_DURATION,
		description = L.OP_OP_AURA_DURATION_TT,
		returnType = 0,
		getText = function(args)
			return L.OP_OP_AURA_DURATION_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
		end,
		editor = editor,
		getDefaultArgs = function()
			return {""};
		end,
	});
	
	registerOperandEditor("aura_helpful", {
		title = L.OP_OP_AURA_HELPFUL,
		description = L.OP_OP_AURA_HELPFUL_TT,
		returnType = false,
		getText = function(args)
			return L.OP_OP_AURA_HELPFUL_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
		end,
		editor = editor,
		getDefaultArgs = function()
			return {""};
		end,
	});
	
	registerOperandEditor("aura_cancellable", {
		title = L.OP_OP_AURA_CANCELLABLE,
		description = L.OP_OP_AURA_CANCELLABLE_TT,
		returnType = false,
		getText = function(args)
			return L.OP_OP_AURA_CANCELLABLE_PREVIEW:format(getAuraNameFromClassId(args and args[1] or ""));
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
		return {strtrim(editor.id:GetText()) or ""};
	end
end

local function check_var_init()
	local editor = TRP3_OperandEditorAuraCheckVar;

	registerOperandEditor("aura_var_check", {
		title = L.OP_OP_AURA_CHECK_VAR,
		description = L.OP_OP_AURA_CHECK_VAR_TT,
		returnType = "",
		noPreview = true,
		getText = function(args)
			return L.OP_OP_AURA_CHECK_VAR_PREVIEW:format(
				getAuraNameFromClassId(args and args[1] or ""), 
				tostring((args or EMPTY)[2] or "var")
			);
		end,
		editor = editor,
	});
	
	registerOperandEditor("aura_var_check_n", {
		title = L.OP_OP_AURA_CHECK_VAR_N,
		description = L.OP_OP_AURA_CHECK_VAR_N_TT,
		returnType = 0,
		noPreview = true,
		getText = function(args)
			return L.OP_OP_AURA_CHECK_VAR_N_PREVIEW:format(
				getAuraNameFromClassId(args and args[1] or ""), 
				tostring((args or EMPTY)[2] or "var")
			);
		end,
		editor = editor,
	});

	setupAuraBrowser(editor);

	-- Var name
	editor.var.title:SetText(L.EFFECT_VAR)
	setTooltipForSameFrame(editor.var.help, "RIGHT", 0, 5, L.EFFECT_VAR, "");

	function editor.load(args)
		editor.id:SetText((args or EMPTY)[1] or "");
		editor.var:SetText((args or EMPTY)[2] or "var");
	end

	function editor.save()
		return {strtrim(editor.id:GetText()) or "", strtrim(editor.var:GetText()) or "var"};
	end

end

function aura_id_init()
	local editor = TRP3_OperandEditorAuraId;
	registerOperandEditor("aura_id", {
		title = L.OP_OP_AURA_ID,
		description = L.OP_OP_AURA_ID_TT,
		returnType = "",
		noPreview = true,
		getText = function(args)
			return L.OP_OP_AURA_ID_PREVIEW:format(
				args and args[1] or "1"
			);
		end,
		editor = editor,
	});
	
	editor.index.title:SetText(L.OP_OP_AURA_ID_INDEX)
	setTooltipForSameFrame(editor.index.help, "RIGHT", 0, 5, L.OP_OP_AURA_ID_INDEX, L.OP_OP_AURA_ID_INDEX_TT);

	function editor.load(args)
		editor.index:SetText((args or EMPTY)[1] or "1");
	end

	function editor.save()
		return {strtrim(editor.index:GetText()) or "1"};
	end
end

function aura_count_init()
	registerOperandEditor("aura_count", {
		title = L.OP_OP_AURA_COUNT,
		description = L.OP_OP_AURA_COUNT_TT,
		returnType = 0,
		getText = function(args) -- luacheck: ignore 212
			return L.OP_OP_AURA_COUNT;
		end,
	});
end

TRP3_API.extended.tools.initAuraEffects = function()
	aura_apply_init()
	aura_remove_init()
	aura_duration_init()
	aura_var_set_init()
	run_workflow_init()
	
	aura_count_init()
	aura_id_init()
	aura_property_init()
	check_var_init()
end
