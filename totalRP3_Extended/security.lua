----------------------------------------------------------------------------------
-- Total RP 3
--	---------------------------------------------------------------------------
--	Copyright 2016 Sylvain Cossement (telkostrasz@totalrp3.info)
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

local Globals, Events, Utils, EMPTY = TRP3_API.globals, TRP3_API.events, TRP3_API.utils, TRP3_API.globals.empty;
local assert, pairs, tinsert, wipe = assert, pairs, tinsert, wipe;
local tsize = Utils.table.size;
local iterateObject = TRP3_API.extended.iterateObject;
local loc = TRP3_API.locale.getText;
local getClass = TRP3_API.extended.getClass;
local ELEMENT_TYPE = TRP3_DB.elementTypes;

TRP3_API.security = {};
local securityVault;

local SECURITY_LEVEL = {
	LOW = 1,
	MEDIUM = 2,
	HIGH = 3,
};
TRP3_API.security.SECURITY_LEVEL = SECURITY_LEVEL;

local RESOLUTION_REASON = {
	WHITELISTED_SENDER = 1,
	EFFECT_GROUP = 2,
	EFFECT = 3,
	MY = 4,
};
TRP3_API.security.RESOLUTION_REASON = RESOLUTION_REASON;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- LOGIC
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local effectGroupDefaultLevel = {
	SEC_REASON_TALK = SECURITY_LEVEL.LOW,
	SEC_REASON_SOUND = SECURITY_LEVEL.NORMAL,
	SEC_REASON_DISMOUNT = SECURITY_LEVEL.NORMAL,
}

local transposition = {
	speech_env = "SEC_REASON_TALK",
	speech_npc = "SEC_REASON_TALK",
	sound_id_local = "SEC_REASON_SOUND",
	sound_music_local = "SEC_REASON_SOUND",
	companion_dismiss_mount = "SEC_REASON_DISMOUNT",
}

local function resolveEffectGroupSecurity(classID, effectGroupID)
	if classID then
		if TRP3_DB.my and TRP3_DB.my[classID] then
			return true, RESOLUTION_REASON.MY;
		end
		if securityVault.sender[classID] and securityVault.whitelist[securityVault.sender[classID]] then
			return true, RESOLUTION_REASON.WHITELISTED_SENDER;
		end
	end
	if effectGroupID then
		if securityVault.global[effectGroupID] then
			return true, RESOLUTION_REASON.EFFECT_GROUP;
		end
		if securityVault.specific[classID] and securityVault.specific[classID][effectGroupID] then
			return true, RESOLUTION_REASON.EFFECT;
		end
	end
	return false;
end
TRP3_API.security.resolveEffectGroupSecurity = resolveEffectGroupSecurity;

local function resolveEffectSecurity(classID, effectID)
	return resolveEffectGroupSecurity(classID, transposition[effectID]);
end
TRP3_API.security.resolveEffectSecurity = resolveEffectSecurity;

local function getEffectSecurity(effectID)
	local effect = TRP3_API.script.getEffect(effectID);
	if effect then
		return effect.secured or SECURITY_LEVEL.LOW;
	end
	return SECURITY_LEVEL.LOW;
end
TRP3_API.security.getEffectSecurity = getEffectSecurity;

local function computeSecurity(rootObjectID, rootObject, details)
	rootObject = rootObject or getClass(rootObjectID);

	assert(rootObject, "Nil argument");
	assert(rootObject.TY, "Object has no type.");
	assert(rootObject.TY == TRP3_DB.types.ITEM or rootObject.TY == TRP3_DB.types.CAMPAIGN, "Object is not an item or a campaign.");

	local details = details or {};

	local minSecurity = SECURITY_LEVEL.HIGH;
	iterateObject(rootObjectID, rootObject, function(childID, childClass)
		for workflowID, workflow in pairs(childClass.SC or EMPTY) do
			for stepID, step in pairs(workflow.ST or EMPTY) do
				if step.t == ELEMENT_TYPE.EFFECT then
					for effectIndex, effect in pairs(step.e or EMPTY) do
						local effectID = effect.id;
						local securityLevel = getEffectSecurity(effectID);
						minSecurity = math.min(minSecurity, securityLevel);
						if details and securityLevel < SECURITY_LEVEL.HIGH and transposition[effectID] then
							if not details[transposition[effectID]] then
								details[transposition[effectID]] = {};
							end
							tinsert(details[transposition[effectID]], childID);
						end
					end
				end
			end
		end
	end);

	rootObject.securityLevel = minSecurity;
	rootObject.details = details;

	return details;
end
TRP3_API.security.computeSecurity = computeSecurity;

function TRP3_API.security.registerSender(classID, sender)
	securityVault.sender[classID] = sender;
end

function TRP3_API.security.whitelistSender(sender, whitelist)
	if whitelist then
		securityVault.whitelist[sender] = true;
	else
		securityVault.whitelist[sender] = nil;
	end
	TRP3_API.script.clearAllCompilations();
	TRP3_API.events.fireEvent(TRP3_API.security.EVENT_SECURITY_CHANGED);
end

function TRP3_API.security.acceptEffectGroup(effectGroupID, accept)
	securityVault.global[effectGroupID] = accept;
	TRP3_API.script.clearAllCompilations();
	TRP3_API.events.fireEvent(TRP3_API.security.EVENT_SECURITY_CHANGED);
end

function TRP3_API.security.acceptSpecificEffectGroup(classID, effectGroupID, accept)
	if not securityVault.specific[classID] then
		securityVault.specific[classID] = {};
	end
	securityVault.specific[classID][effectGroupID] = accept;
	TRP3_API.script.clearRootCompilation(classID);
	TRP3_API.events.fireEvent(TRP3_API.security.EVENT_SECURITY_CHANGED);
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- UI
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
local securityLevelText, securityLevelDetailText, securityResolutionText = {}, {}, nil;

local showSecurityDetailFrame;
local initList = TRP3_API.ui.list.initList;
local handleMouseWheel = TRP3_API.ui.list.handleMouseWheel;
local setTooltipForSameFrame = TRP3_API.ui.tooltip.setTooltipForSameFrame;

local securityFrame = TRP3_SecurityFrame;
local NORMAL_HEIGHT = 280;

local ACTION_FLAG_THIS = "1";
local ACTION_FLAG_ALL = "2";

local function onLineActionSelected(value, button)
	local action = value:sub(1, 1);
	local effectGroup = value:sub(2);

	if action == ACTION_FLAG_THIS then
		TRP3_API.security.acceptSpecificEffectGroup(securityFrame.classID, effectGroup, not (securityVault.specific[securityFrame.classID] and securityVault.specific[securityFrame.classID][effectGroup]));
		showSecurityDetailFrame(securityFrame.classID);
	elseif action == ACTION_FLAG_ALL then
		TRP3_API.security.acceptEffectGroup(effectGroup, not securityVault.global[effectGroup]);
		showSecurityDetailFrame(securityFrame.classID);
	end
end

local function onLineClick(lineWidgetClick)
	local lineWidget = lineWidgetClick:GetParent();
	local values = {};
	tinsert(values, {lineWidget.text:GetText(), nil});
	tinsert(values, {loc("SEC_LEVEL_DETAILS_THIS"), ACTION_FLAG_THIS .. lineWidget.effectGroup, loc("SEC_LEVEL_DETAILS_THIS_TT")});
	tinsert(values, {loc("SEC_LEVEL_DETAILS_ALL"), ACTION_FLAG_ALL .. lineWidget.effectGroup, loc("SEC_LEVEL_DETAILS_ALL_TT")});
	TRP3_API.ui.listbox.displayDropDown(lineWidget, values, onLineActionSelected, 0, true);
end

local function decorateLine(line, effectGroup)
	line.effectGroup = effectGroup;
	line.text:SetText(loc(effectGroup));
	setTooltipForSameFrame(line.click, "BOTTOMRIGHT", 0, 0, loc("SEC_UNSECURED_WHY"), securityFrame.reasons[effectGroup] or "?");

	line.click:SetScript("OnClick", onLineClick);

	local accepted, reason = resolveEffectGroupSecurity(securityFrame.classID, effectGroup);
	local stateText = "";
	if accepted then
		stateText = "|cff00ff00" .. loc("SEC_LEVEL_DETAILS_ACCEPTED");
	else
		stateText = "|cffff0000" .. loc("SEC_LEVEL_DETAILS_BLOCKED")
	end
	if reason then
		stateText = stateText .. " (" .. securityResolutionText[reason] .. ")"
	end
	line.state:SetText(stateText);
end

function showSecurityDetailFrame(classID, frameFrom)
	local class = getClass(classID);

	securityFrame.securityDetails = class.details;

	local height = NORMAL_HEIGHT;

	securityFrame.empty:Hide();
	if tsize(securityFrame.securityDetails) == 0 then
		securityFrame.empty:Show();
		height = height - 50;
	end

	securityFrame.classID = classID;
	securityFrame.sender = securityVault.sender[classID];

	securityFrame.save:Show();
	securityFrame.whitelist:Show();
	if classID and TRP3_DB.my and TRP3_DB.my[classID] then
		securityFrame.save:Hide();
		securityFrame.whitelist:Hide();
		securityFrame.sender = Globals.player_id;
		height = height - 50;
	else
		securityFrame.whitelist:SetChecked(securityVault.whitelist[securityFrame.sender]);
		securityFrame.whitelist.Text:SetText(loc("SEC_LEVEL_DETAILS_FROM"):format("|cff00ff00" .. securityFrame.sender));
	end


	initList(securityFrame, securityFrame.securityDetails, securityFrame.slider);

	securityFrame.subtitle:SetText(loc("SEC_LEVEL_DETAILS_TT"):format(TRP3_API.inventory.getItemLink(class)));

	securityFrame:SetHeight(height);
	securityFrame:ClearAllPoints();
	securityFrame:SetPoint("CENTER", frameFrom or UIParent, "CENTER", 0, 0);
	securityFrame:Show();
end
TRP3_API.security.showSecurityDetailFrame = showSecurityDetailFrame;

local function getSecurityText(level)
	return securityLevelText[level or SECURITY_LEVEL.LOW] or "?";
end
TRP3_API.security.getSecurityText = getSecurityText;

local function getSecurityDetailText(level)
	return securityLevelDetailText[level or SECURITY_LEVEL.LOW] or "?";
end
TRP3_API.security.getSecurityDetailText = getSecurityDetailText;

local function atLeastOneBlocked(rootClassID)
	local secDetails = TRP3_API.security.computeSecurity(rootClassID);
	for effectGroupID, _ in pairs(secDetails) do
		if not TRP3_API.security.resolveEffectGroupSecurity(rootClassID, effectGroupID) then
			return true;
		end
	end
	return false;
end
TRP3_API.security.atLeastOneBlocked = atLeastOneBlocked;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function TRP3_API.security.initSecurity()
	securityVault = TRP3_Security;

	securityLevelText[SECURITY_LEVEL.LOW] = "|cffff0000" .. loc("SEC_LOW") .. "|r";
	securityLevelText[SECURITY_LEVEL.MEDIUM] = "|cffff9900" .. loc("SEC_MEDIUM") .. "|r";
	securityLevelText[SECURITY_LEVEL.HIGH] = "|cff00ff00" .. loc("SEC_HIGH") .. "|r";
	securityLevelDetailText[SECURITY_LEVEL.LOW] = loc("SEC_LOW_TT");
	securityLevelDetailText[SECURITY_LEVEL.MEDIUM] = loc("SEC_MEDIUM_TT");
	securityLevelDetailText[SECURITY_LEVEL.HIGH] = loc("SEC_HIGH_TT");
	securityResolutionText = {
		"Whitelisted sender", --TODO: locasl
		"For all objects", --TODO: locasl
		"For this object only", --TODO: locasl
		"You are the author", --TODO: locasl
	};

	securityFrame.title:SetText(loc("SEC_LEVEL_DETAILS"));
	securityFrame.empty:SetText(loc("SEC_LEVEL_DETAILS_SECURED"));
	securityFrame.save.Text:SetText(loc("SEC_LEVEL_DETAILS_REMIND"));

	securityFrame.reasons = {};
	securityFrame.reasons["SEC_REASON_TALK"] = "|cffffffff" .. loc("SEC_REASON_TALK_WHY");
	securityFrame.reasons["SEC_REASON_SOUND"] = "|cffffffff" .. loc("SEC_REASON_SOUND_WHY");
	securityFrame.reasons["SEC_REASON_DISMOUNT"] = "|cffffffff" .. loc("SEC_REASON_DISMOUNT_WHY");

	securityFrame.securityDetails = {};
	securityFrame.widgetTab = {};
	for i=1, 8 do
		local line = securityFrame["line" .. i];
		tinsert(securityFrame.widgetTab, line);
	end
	securityFrame.decorate = decorateLine;
	handleMouseWheel(securityFrame, securityFrame.slider);
	securityFrame.slider:SetValue(0);

	securityFrame.whitelist:SetScript("OnClick", function(self)
		TRP3_API.security.whitelistSender(securityFrame.sender, self:GetChecked());
		showSecurityDetailFrame(securityFrame.classID);
	end);

	TRP3_API.security.EVENT_SECURITY_CHANGED = "EVENT_SECURITY_CHANGED";
	TRP3_API.events.registerEvent(TRP3_API.security.EVENT_SECURITY_CHANGED);
end