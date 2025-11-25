-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

local loc = TRP3_API.loc;
local getClass = TRP3_API.extended.getClass;
local getRootClassID = TRP3_API.extended.getRootClassID;
local CUSTOM_EVENTS = TRP3_API.extended.CUSTOM_EVENTS;

--[[
	maximum number of iterations within one auraCore:Update() batch
	this is to avoid calling Update() recursively and also to repaint the UI only once
]]--
local MAX_AURA_UPDATE_CYCLES = 10;

--[[
	minimum time to pass until the next automated call to auraCore:Update()
	Update calls via event do not adhere to this minimum, however Update will ensure
	that there is at maximum one active C_Timer
]]--
local MIN_AURA_UPDATE_INTERVAL = 0.1;

--[[
	Update frequency for dynamic auras. Since variables can change at any time, let's just update
	auras every DYN_AURA_UPDATE_INTERVAL seconds, if they happen to display variables
]]--
local DYN_AURA_UPDATE_INTERVAL = 1;

local INSPECT_AURA_OFFSET = 10;
local INSPECT_AURA_HEIGHT = 36;
local INSPECT_AURA_COL_WIDTH = 36;
local INSPECT_AURAS_PER_COL = 8;

local AURA_HEIGHT = 48;
local AURA_WIDTH = 36;
local AURA_MARGIN = 16;
local AURA_MARGIN_TOP = 24;
local AURA_ROW_LENGTH = 8;

--[[ DATA MAP

				auraCore.activeAuras[i]                        TRP3_API.profile.getPlayerCurrentProfile().auras[j]

						|																|
						v																v

	+-----------------------------------------------+          +------------------------------------------------+
	| t persistent  pointer to stored part ---------|--------> | s id            full class id                  |
	| t class       cached class data (pointer)     |          | t vars          aura variables                 |
	| s duration    remaining duration string       |          | n expiry        expiry timestamp               |
	| s overlay     overlay string                  |          | n dormantSince  timestamp of last deactivation |
	| b hasDynamicDescription   whether or not the  |          | n lastTick      timestamp of the last onTick   |
	|               description text has tags       |          | b invalid       invalidated flag (aura should  |
	| b hasDynamicOverlay       whether or not the  |          |                 be removed on next Update)     |
	|               overlay text has tags           |          +------------------------------------------------+
	+-----------------------------------------------+

]]--

local function NextValidAura(auras, index)
	index = index + 1;
	while auras[index] do
		local aura = auras[index];
		if not aura.persistent.invalid then
			return index, aura;
		else
			index = index + 1;
		end
	end
end

local function EnumerateValidAuras(auras)
	return NextValidAura, auras, 0;
end

local auraCore = {
	activeAuras = {},
	timer       = nil,
	isUpdating  = false,
	scriptsEnabled = true,
	buffs = {},
	debuffs = {},
	inspectBuffs = {},
	inspectDebuffs = {},
	auraLayout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopRightToBottomLeft, AURA_ROW_LENGTH, AURA_WIDTH-32, AURA_HEIGHT-32),
	inspectBuffLayout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRightVertical, INSPECT_AURAS_PER_COL, INSPECT_AURA_COL_WIDTH-32, INSPECT_AURA_HEIGHT-32),
	inspectDebuffLayout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopRightToBottomLeftVertical, INSPECT_AURAS_PER_COL, INSPECT_AURA_COL_WIDTH-32, INSPECT_AURA_HEIGHT-32),
};

-- a more precise version of time() that includes milliseconds
function auraCore:Now()
	return self.baseTime + GetTime();
end

function auraCore:Initialize()
	self.baseTime = time() - GetTime();
	self.auraFramePool = CreateFramePool("Frame", TRP3_AuraBarFrame, "TRP3_AuraTemplate", function(_, frame)
		frame:Reset();
	end);

	self.inspectionAuraFramePool = CreateFramePool("Frame", TRP3_InspectionFrame.Main, "TRP3_AuraTemplate", function(_, frame)
		frame:Reset();
	end);

	self.timeFormatterCompact = CreateFromMixins(SecondsFormatterMixin);
	self.timeFormatterCompact:Init(0, SecondsFormatter.Abbreviation.OneLetter);
	self.timeFormatterCompact:SetDesiredUnitCount(1);

	self.timeFormatterNormal = CreateFromMixins(SecondsFormatterMixin);
	self.timeFormatterNormal:Init();

	TRP3_AuraTooltip:Init(self);

	TRP3_API.RegisterCallback(TRP3_Addon, "REGISTER_PROFILES_LOADED", function()
		auraCore:LoadProfile();
	end);

	TRP3_API.RegisterCallback(TRP3_API.GameEvents, "PLAYER_LEAVING_WORLD", function()
		auraCore:UpdateDormancy();
	end);

	TRP3_API.slash.registerCommand({
		id = "debug_clear_auras",
		helpLine = " " .. loc.DEBUG_CLEAR_AURAS,
		handler = function()
			auraCore:SetScriptsEnabled(false);
			auraCore:RemoveAllAuras();
			auraCore:SetScriptsEnabled(true);
		end
	});

	self:LoadProfile();
end

function auraCore:SetScriptsEnabled(scriptsEnabled)
	self.scriptsEnabled = scriptsEnabled;
end

function auraCore:IsScriptsEnabled()
	return self.scriptsEnabled;
end

function auraCore:RunAuraScript(scriptId, classScripts, args, classId)
	if self.scriptsEnabled then
		TRP3_API.script.executeClassScript(scriptId, classScripts, args, classId);
	end
end

function auraCore:InvalidateCampaignAuras(campaignId)
	local hasChanges = false;
	for _, persistent in ipairs(self.currentProfile.auras) do
		local class = getClass(persistent.id);
		if class.missing then
			persistent.invalid = true;
			hasChanges = true;
		elseif class.BA.BC and campaignId == getRootClassID(persistent.id) then
			persistent.invalid = true;
			hasChanges = true;
		end
	end
	if hasChanges then
		for _, aura in ipairs(self.activeAuras) do
			if aura.persistent.invalid then
				self:UnregisterAuraEvents(aura);
			end
		end
		self:Update(true);
	end
end

function auraCore:UpdateDormancy()
	local now = auraCore:Now();
	for _, aura in ipairs(self.activeAuras) do
		aura.persistent.dormantSince = now;
	end
end

local function onAuraEvent(aura, eventId, handler, ...)
	local payload = {...};
	if (eventId == "COMBAT_LOG_EVENT" or eventId == "COMBAT_LOG_EVENT_UNFILTERED") then
		payload = {CombatLogGetCurrentEventInfo()};
	end
	local args = { object = aura.persistent, event = payload };
	if not handler.CO or TRP3_API.script.generateAndRunCondition(handler.CO, args) then
		auraCore:RunAuraScript(handler.SC, aura.class.SC, args, aura.persistent.id);
	end
end

function auraCore:RegisterAuraEvents(aura)
	if not aura.class.HA then return end

	local events = TRP3_API.CreateCallbackGroup();

	for _, handler in ipairs(aura.class.HA) do
		local source;

		if CUSTOM_EVENTS[handler.EV] then
			source = TRP3_Extended;
		else
			source = TRP3_API.GameEvents;
		end

		local function OnEventTriggered(_, ...)
			onAuraEvent(aura, handler.EV, handler, ...);
		end

		events:RegisterCallback(source, handler.EV, OnEventTriggered);
	end

	aura.events = events;
end

function auraCore:UnregisterAuraEvents(aura)
	if aura.events then
		aura.events:Unregister();
		aura.events = nil;
	end
end

function auraCore:LoadProfile()

	self.isUpdating = false;
	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end

	local now = self:Now();

	for _, aura in ipairs(self.activeAuras) do
		self:UnregisterAuraEvents(aura);
		aura.persistent.dormantSince = now;
	end

	self.currentProfile = TRP3_API.profile.getPlayerCurrentProfile();
	assert(self.currentProfile, "currentProfile is nil");
	self.currentProfile.auras = self.currentProfile.auras or {};
	self.activeAuras = {};

	self.currentCampaignClassId = TRP3_API.quest.getQuestLog().currentCampaign; -- might be nil

	for _, persistent in ipairs(self.currentProfile.auras) do
		persistent.expiry = persistent.expiry or math.huge; -- Inf is stored as nil
		local class = getClass(persistent.id);
		if class.missing or persistent.invalid then
			persistent.invalid = true;
		elseif class.BA.AA and persistent.expiry < now and not class.BA.EE then
			persistent.invalid = true;
		elseif not class.BA.BC or self.currentCampaignClassId == getRootClassID(persistent.id) then
			local dormancyDuration = 0;
			if not class.BA.AA then
				dormancyDuration = now - persistent.dormantSince;
			end
			persistent.expiry = persistent.expiry + dormancyDuration;

			if class.BA.IV and class.BA.IV < math.huge then
				local elapsedTime = now - persistent.lastTick - dormancyDuration;
				persistent.lastTick = now - (elapsedTime % math.abs(class.BA.IV));
			end
			persistent.dormantSince = now;
			local aura = {
				class = class,
				persistent = persistent,
				color = self:GetAuraColorFromClass(class),
			};
			self:AnalyzeAuraClass(aura);
			tinsert(self.activeAuras, aura);
			self:RegisterAuraEvents(aura);
		end
	end

	self:SetScriptsEnabled(true);

	self:Update(true);
end

-- desired side effect: sets properties in aura
function auraCore:AnalyzeAuraClass(aura)
	aura.hasDynamicDescription = aura.class.BA.DE and aura.class.BA.DE:match("%$%{(.-)%}");
	aura.hasDynamicOverlay     = aura.class.BA.OV and aura.class.BA.OV:match("%$%{(.-)%}");
end

function auraCore:ModifyAuraDuration(aura, duration, method)
	local currentExpiry = aura.persistent.expiry;
	local newExpiry = currentExpiry;
	local now = self:Now();
	if method == "+" then
		newExpiry = currentExpiry + duration;
	elseif method == "-" then
		if duration < math.huge then
			newExpiry = currentExpiry - duration;
		end
	else -- "="
		newExpiry = now + duration;
	end
	if newExpiry ~= currentExpiry then
		aura.persistent.expiry = newExpiry;
		self:Update();
	end
end

function auraCore:SetAuraVariable(aura, opType, varName, value)
	local shouldUpdate = false;
	if opType == "[=]" then
		if not aura.persistent.vars or aura.persistent.vars[varName] == nil then
			aura.persistent.vars = aura.persistent.vars or {};
			aura.persistent.vars[varName] = value;
			shouldUpdate = aura.hasDynamicOverlay;
		end
	elseif opType == "=" then
		aura.persistent.vars = aura.persistent.vars or {};
		aura.persistent.vars[varName] = value;
		shouldUpdate = aura.hasDynamicOverlay;
	else
		aura.persistent.vars = aura.persistent.vars or {};
		local op1 = tonumber(aura.persistent.vars[varName]) or 0;
		local op2 = tonumber(value) or 0;
		if opType == "+" then
			aura.persistent.vars[varName] = op1 + op2;
		elseif opType == "-" then
			aura.persistent.vars[varName] = op1 - op2;
		elseif opType == "x" then
			aura.persistent.vars[varName] = op1 * op2;
		elseif opType == "/" then
			aura.persistent.vars[varName] = op1 / op2;
		end
		shouldUpdate = aura.hasDynamicOverlay;
	end

	if shouldUpdate then
		self:Update();
	end
end

function auraCore:GetAuraColorFromClass(class)
	if class.BA.CO then
		local colorCached = {
			h = class.BA.CO
		}
		colorCached.r, colorCached.g, colorCached.b = TRP3_API.CreateColorFromHexString(class.BA.CO):GetRGB();
		return colorCached;
	else
		return nil;
	end
end

function auraCore:InsertNewAura(auraId, class)
	local now = self:Now();
	local newAuraPersistent = {
		id = auraId,
		expiry = now + math.abs(class.BA.DU or math.huge),
		lastTick = now,
		dormantSince = now
	};
	tinsert(self.currentProfile.auras, newAuraPersistent);
	local aura = {
		class = class,
		persistent = newAuraPersistent,
		color = self:GetAuraColorFromClass(class)
	};
	self:AnalyzeAuraClass(aura);
	tinsert(self.activeAuras, aura);
	self:RegisterAuraEvents(aura);
	if aura.class.LI and aura.class.LI.OA then
		self:RunAuraScript(aura.class.LI.OA, aura.class.SC or {}, { object = aura.persistent }, aura.persistent.id);
	end
	self:Update(true);
end

function auraCore:CancelAura(auraId)
	local aura = self:FindAura(auraId);
	if aura then
		if aura.class.LI and aura.class.LI.OC then
			self:RunAuraScript(aura.class.LI.OC, aura.class.SC or {}, { object = aura.persistent }, aura.persistent.id);
		end
		aura.persistent.invalid = true;
		self:UnregisterAuraEvents(aura);
		self:Update(true);
		return true;
	end
	return false;
end

function auraCore:RemoveAura(auraId)
	local aura = self:FindAura(auraId);
	if aura then
		aura.persistent.invalid = true;
		self:UnregisterAuraEvents(aura);
		self:Update(true);
		return true;
	end
	return false;
end

function auraCore:RemoveAllAuras()
	for _, aura in EnumerateValidAuras(self.activeAuras) do
		aura.persistent.invalid = true;
		self:UnregisterAuraEvents(aura);
	end
	self:Update(true);
end

function auraCore:FindAura(auraId)
	for _, aura in EnumerateValidAuras(self.activeAuras) do
		if aura.persistent.id == auraId then
			return aura;
		end
	end
	return nil;
end

function auraCore:GetAuraAt(index)
	for i, aura in EnumerateValidAuras(self.activeAuras) do
		if i == index then
			return aura;
		end
	end
	return nil;
end

function auraCore:CountActiveAuras()
	local count = 0;
	for _ in EnumerateValidAuras(self.activeAuras) do
		count = count + 1;
	end
	return count;
end

function auraCore:IsAuraActive(auraId)
	return self:FindAura(auraId) ~= nil;
end

function auraCore:Update(doHardRefresh)
	if self.isUpdating then
		self.doHardRefresh = self.doHardRefresh or doHardRefresh;
		self.repeatUpdate = true;
		return;
	end

	self.isUpdating = true;
	if self.timer then
		self.timer:Cancel();
	end

	local now = self:Now();
	self.doHardRefresh = doHardRefresh;

	for _ = 1,MAX_AURA_UPDATE_CYCLES do
		for _, aura in EnumerateValidAuras(self.activeAuras) do
			if aura.class.BA.IV and aura.class.BA.IV < math.huge then
				local nextTick = aura.persistent.lastTick + math.abs(aura.class.BA.IV);
				if nextTick <= now then
					aura.persistent.lastTick = nextTick;
					if aura.class.LI and aura.class.LI.OT then
						self:RunAuraScript(aura.class.LI.OT, aura.class.SC or {}, { object = aura.persistent }, aura.persistent.id);
					end
				end
			end
			if aura.persistent.expiry <= now then
				if aura.class.LI and aura.class.LI.OE then
					self:RunAuraScript(aura.class.LI.OE, aura.class.SC or {}, { object = aura.persistent }, aura.persistent.id);
				end
				if aura.persistent.expiry <= now then -- the script might have delayed the expiry
					aura.persistent.invalid = true;
					self:UnregisterAuraEvents(aura);
					self.doHardRefresh = true;
				end
			end
		end
		if not self.repeatUpdate then
			break;
		end
		self.repeatUpdate = false;
	end

	if self:RemoveInvalidAuras() then
		self.doHardRefresh = true;
	end

	local nextTimestamp = math.huge;

	for _, aura in ipairs(self.activeAuras) do
		aura.persistent.dormantSince = now;
		if aura.class.BA.OV then
			aura.overlay = TRP3_API.script.parseArgs(aura.class.BA.OV, { object = aura.persistent });
		else
			aura.overlay = nil;
		end

		if aura.persistent.expiry < math.huge then
			aura.duration = self.timeFormatterCompact:Format(aura.persistent.expiry - now);
		else
			aura.duration = nil;
		end

		if aura.class.BA.IV and aura.class.BA.IV < math.huge then
			local nextTick = aura.persistent.lastTick + math.abs(aura.class.BA.IV);
			nextTimestamp = math.min(nextTimestamp, nextTick);
		end

		if aura.hasDynamicOverlay then
			nextTimestamp = math.min(nextTimestamp, now + DYN_AURA_UPDATE_INTERVAL);
		end

		if aura.persistent.expiry < math.huge then
			nextTimestamp = math.min(nextTimestamp, aura.persistent.expiry);
			local timeTillExpiry = aura.persistent.expiry - now;
			if timeTillExpiry < 60 then
				nextTimestamp = math.min(nextTimestamp, aura.persistent.expiry - math.floor(timeTillExpiry));
			elseif timeTillExpiry < 3600 then
				nextTimestamp = math.min(nextTimestamp, aura.persistent.expiry - math.floor(timeTillExpiry/60) * 60);
			else
				nextTimestamp = math.min(nextTimestamp, aura.persistent.expiry - math.floor(timeTillExpiry/3600) * 3600);
			end
		end

	end

	if self.doHardRefresh then
		self:HardRefresh();
	else
		self:SoftRefresh();
	end

	if nextTimestamp < math.huge then
		self.timer = C_Timer.NewTimer(math.max(nextTimestamp - now, MIN_AURA_UPDATE_INTERVAL), function()
			auraCore:Update();
		end)
	end

	self.isUpdating = false;
end

function auraCore:RemoveInvalidAuras()
	local activeAurasRemoved = false;
	-- 1st pass: remove from active auras list
	local n = #self.activeAuras;
	local j = 1;
	for i = 1,n do
		if self.activeAuras[i].persistent.invalid then
			self.activeAuras[i] = nil;
			activeAurasRemoved = true;
		else
			if i ~= j then
				self.activeAuras[j] = self.activeAuras[i];
				self.activeAuras[i] = nil;
			end
			j = j + 1;
		end
	end
	-- 2nd pass: remove from all auras list
	n = #self.currentProfile.auras;
	j = 1;
	for i = 1,n do
		if self.currentProfile.auras[i].invalid then
			self.currentProfile.auras[i] = nil;
		else
			if i ~= j then
				self.currentProfile.auras[j] = self.currentProfile.auras[i];
				self.currentProfile.auras[i] = nil;
			end
			j = j + 1;
		end
	end
	return activeAurasRemoved;
end

local function getBuffByIndex(index)
	local frame = auraCore.auraFramePool:Acquire();
	local aura = auraCore.buffs[index];
	frame:SetAuraAndShow(aura);
	aura.frame = frame;
	return frame;
end

local function getDebuffByIndex(index)
	local frame = auraCore.auraFramePool:Acquire();
	local aura = auraCore.debuffs[index];
	frame:SetAuraAndShow(aura);
	aura.frame = frame;
	return frame;
end

-- updates the aura display entirely, re-assigning frames etc.
-- do this, when auras are added or removed
function auraCore:HardRefresh()
	self.auraFramePool:ReleaseAll();

	self.buffs = {};
	self.debuffs = {};

	for _, aura in ipairs(self.activeAuras) do
		if aura.class.BA.HE then
			tinsert(self.buffs, aura);
		else
			tinsert(self.debuffs, aura);
		end
	end

	local buffCount = #self.buffs;
	local debuffCount = #self.debuffs;

	local debuffOffset = AURA_MARGIN_TOP;
	if buffCount > 0 then
		local buffAnchor = AnchorUtil.CreateAnchor("TOPRIGHT", TRP3_AuraBarFrame, "TOPRIGHT", -AURA_MARGIN, -AURA_MARGIN_TOP);
		AnchorUtil.GridLayoutFactoryByCount(getBuffByIndex, buffCount, buffAnchor, self.auraLayout);
		debuffOffset = debuffOffset + AURA_HEIGHT/2 + (math.ceil(buffCount/AURA_ROW_LENGTH) * AURA_HEIGHT);
	end
	if debuffCount > 0 then
		local debuffAnchor = AnchorUtil.CreateAnchor("TOPRIGHT", TRP3_AuraBarFrame, "TOPRIGHT", -AURA_MARGIN, -debuffOffset);
		AnchorUtil.GridLayoutFactoryByCount(getDebuffByIndex, debuffCount, debuffAnchor, self.auraLayout);
	end

	if buffCount > 0 or debuffCount > 0 then
		local w = math.max(math.min(AURA_ROW_LENGTH, math.max(buffCount, debuffCount))*AURA_WIDTH + AURA_MARGIN*2, 200);
		local h = AURA_MARGIN_TOP + AURA_MARGIN;
		h = h + math.ceil(buffCount/AURA_ROW_LENGTH) * AURA_HEIGHT;
		if buffCount > 0 and debuffCount > 0 then
			h = h + AURA_HEIGHT/2;
		end
		h = h + math.ceil(debuffCount/AURA_ROW_LENGTH) * AURA_HEIGHT;
		TRP3_AuraBarFrame:SetSize(w, h);
		TRP3_AuraBarFrame:SetShown(TRP3_AuraFrameCollapseAndExpandButton:GetChecked());
		TRP3_AuraFrameCollapseAndExpandButton:Show();
	else
		TRP3_AuraBarFrame:Hide();
		TRP3_AuraFrameCollapseAndExpandButton:Hide();
	end

	self:SoftRefresh();
end

-- updates aura text and duration only
function auraCore:SoftRefresh()
	for _, aura in ipairs(self.activeAuras) do
		if aura.frame then
			aura.frame:SetAuraTexts(aura.duration, aura.overlay);
		end
	end
end

function auraCore:GetAuraTooltipLines(aura)
	local title, category, description, flavor, expiry, cancelText;

	if aura.class.BA.NA then
		title = aura.class.BA.NA;
	end

	if aura.class.BA.CA and aura.class.BA.CA:len() > 0 then
		category = aura.class.BA.CA;
	end

	if aura.class.BA.DE then
		description = TRP3_API.script.parseArgs(aura.class.BA.DE, { object = aura.persistent });
	end

	if aura.class.BA.FL then
		flavor = aura.class.BA.FL;
	end

	if aura.persistent.expiry < math.huge then
		expiry = loc.AU_EXPIRY:format(self.timeFormatterNormal:Format(aura.persistent.expiry - self:Now()));
	end

	if aura.class.BA.CC then
		cancelText = TRP3_API.FormatShortcutWithInstruction("RCLICK", CANCEL);
	end

	return title, category, description, flavor, expiry, cancelText;
end

function auraCore:GetAurasForInspection()
	local auras = {};
	for _, aura in EnumerateValidAuras(self.activeAuras) do
		if aura.class.BA.WE then
			tinsert(auras, {
				class = {
					BA = {
						NA = aura.class.BA.NA,
						CA = aura.class.BA.CA,
						DE = TRP3_API.script.parseArgs(aura.class.BA.DE, { object = aura.persistent }),
						OV = TRP3_API.script.parseArgs(aura.class.BA.OV, { object = aura.persistent }),
						IC = aura.class.BA.IC,
						HE = aura.class.BA.HE,
						FL = aura.class.BA.FL,
						CO = aura.class.BA.CO,
					}
				},
				persistent = {
					expiry = aura.persistent.expiry or math.huge
				}
			});
		end
	end
	return auras;
end

local function getInspectBuffByIndex(index)
	local frame = auraCore.inspectionAuraFramePool:Acquire();
	local aura = auraCore.inspectBuffs[index];
	frame:SetAuraAndShow(aura);
	frame:SetAuraTexts("", aura.class.BA.OV);
	aura.frame = frame;
	return frame;
end

local function getInspectDebuffByIndex(index)
	local frame = auraCore.inspectionAuraFramePool:Acquire();
	local aura = auraCore.inspectDebuffs[index];
	frame:SetAuraAndShow(aura);
	frame:SetAuraTexts("", aura.class.BA.OV);
	aura.frame = frame;
	return frame;
end

function auraCore:UpdateInspectionFrame(auras)
	self.inspectionAuraFramePool:ReleaseAll();

	if not auras then return end

	self.inspectBuffs = {};
	self.inspectDebuffs = {};

	for _, aura in ipairs(auras) do
		if aura.class.BA.HE then
			tinsert(self.inspectBuffs, aura);
		else
			tinsert(self.inspectDebuffs, aura);
		end
		aura.persistent.expiry = aura.persistent.expiry or math.huge;
		aura.color = self:GetAuraColorFromClass(aura.class);
	end

	local buffCount = #self.inspectBuffs;
	local debuffCount = #self.inspectDebuffs;

	if buffCount > 0 then
		local buffAnchor = AnchorUtil.CreateAnchor("TOPLEFT", TRP3_InspectionFrame.Main.Model, "TOPLEFT", INSPECT_AURA_OFFSET, -INSPECT_AURA_OFFSET);
		AnchorUtil.GridLayoutFactoryByCount(getInspectBuffByIndex, buffCount, buffAnchor, self.inspectBuffLayout);
	end

	if debuffCount > 0 then
		local debuffAnchor = AnchorUtil.CreateAnchor("TOPRIGHT", TRP3_InspectionFrame.Main.Model, "TOPRIGHT", -INSPECT_AURA_OFFSET, -INSPECT_AURA_OFFSET);
		AnchorUtil.GridLayoutFactoryByCount(getInspectDebuffByIndex, debuffCount, debuffAnchor, self.inspectDebuffLayout);
	end

end

TRP3_API.extended.auras.apply = function(auraId, mergeMode)
	local class = getClass(auraId);
	if class.missing then return end
	if class.BA.BC and auraCore.currentCampaignClassId ~= getRootClassID(auraId) then return end
	local aura = auraCore:FindAura(auraId);
	if aura then
		if mergeMode == "=" or mergeMode == "+" then
			auraCore:ModifyAuraDuration(aura, class.BA.DU or math.huge, mergeMode);
		end
	else
		auraCore:InsertNewAura(auraId, class);
	end
end

TRP3_API.extended.auras.setVariable = function(auraId, opType, varName, value)
	local aura = auraCore:FindAura(auraId);
	if aura then
		auraCore:SetAuraVariable(aura, opType, varName, value);
	end
end

TRP3_API.extended.auras.isActive = function(auraId)
	return auraCore:IsAuraActive(auraId);
end

TRP3_API.extended.auras.getDuration = function(auraId)
	local aura = auraCore:FindAura(auraId);
	if aura then
		return aura.persistent.expiry - auraCore:Now();
	else
		return 0;
	end
end

TRP3_API.extended.auras.isHelpful = function(auraId)
	local class = getClass(auraId);
	return class.BA.HE or false;
end

TRP3_API.extended.auras.isCancellable = function(auraId)
	local class = getClass(auraId);
	return class.BA.CC or false;
end

TRP3_API.extended.auras.getStringProperty = function(auraId, property)
	local class = getClass(auraId);
	return class.BA[property] or "";
end

TRP3_API.extended.auras.auraVarCheck = function(auraId, varName)
	local aura = auraCore:FindAura(auraId);
	if aura and aura.persistent.vars and aura.persistent.vars[varName] then
		return tostring(aura.persistent.vars[varName]) or "nil";
	else
		return "nil";
	end
end

TRP3_API.extended.auras.auraVarCheckN = function(auraId, varName)
	local aura = auraCore:FindAura(auraId);
	if aura and aura.persistent.vars and aura.persistent.vars[varName] then
		return tonumber(aura.persistent.vars[varName]) or 0;
	else
		return 0;
	end
end

TRP3_API.extended.auras.getCount = function()
	return auraCore:CountActiveAuras();
end

TRP3_API.extended.auras.getId = function(index)
	local aura = auraCore:GetAuraAt(index);
	if aura then
		return aura.persistent.id;
	else
		return "nil";
	end
end

TRP3_API.extended.auras.setDuration = function(auraId, duration, method)
	local aura = auraCore:FindAura(auraId);
	if aura then
		auraCore:ModifyAuraDuration(aura, duration, method);
	end
end

TRP3_API.extended.auras.cancel = function(auraId)
	local class = getClass(auraId);
	if class.missing then return false end
	if auraCore:IsScriptsEnabled() and not class.BA.CC then return false end
	return auraCore:CancelAura(auraId);
end

TRP3_API.extended.auras.remove = function(auraId)
	return auraCore:RemoveAura(auraId);
end

TRP3_API.extended.auras.runWorkflow = function(auraId, workflowId, eArgs)
	local aura = auraCore:FindAura(auraId);
	if aura and aura.class.SC and aura.class.SC[workflowId] then
		local args = {
			object = aura.persistent
		};
		if eArgs then
			args.custom = eArgs.custom;
			args.event = eArgs.event;
		end
		auraCore:RunAuraScript(workflowId, aura.class.SC or {}, args, aura.persistent.id);
	end
end

TRP3_API.extended.auras.getAurasForInspection = function()
	return auraCore:GetAurasForInspection();
end

TRP3_API.extended.auras.showInspectAuras = function(auras)
	return auraCore:UpdateInspectionFrame(auras);
end

TRP3_API.extended.auras.hideTooltip = function()
	TRP3_AuraTooltip:Hide();
end

TRP3_API.extended.auras.refresh = function()
	auraCore:LoadProfile();
end

TRP3_API.extended.auras.setScriptsEnabled = function(enabled)
	auraCore:SetScriptsEnabled(enabled);
end

TRP3_API.extended.auras.isScriptsEnabled = function()
	return auraCore:IsScriptsEnabled();
end

TRP3_API.extended.auras.resetCampaignAuras = function(campaignId)
	auraCore:InvalidateCampaignAuras(campaignId);
end

TRP3_API.extended.auras.onStart = function()
	TRP3_AuraBarFrame.text:SetText(loc.AURA_FRAME_TITLE);
	TRP3_AuraBarFrame:UpdatePosition();
	TRP3_AuraFrameCollapseAndExpandButton:UpdatePosition();
	TRP3_API.script.registerEffects(TRP3_API.extended.auras.EFFECTS);
	auraCore:Initialize();
end
