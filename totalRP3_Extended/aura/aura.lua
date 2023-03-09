local pairs, tostring, tinsert, tonumber, math = pairs, tostring, tinsert, tonumber, math
local C_Timer, GetTime = C_Timer, GetTime
local TRP3_API = TRP3_API
local L = TRP3_API.loc
local Globals, Events, Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
local hexaToFloat = Utils.color.hexaToFloat;

local TRP3_AuraFrame, TRP3_AuraFrameCollapseAndExpandButton, TRP3_InspectionFrame = TRP3_AuraFrame, TRP3_AuraFrameCollapseAndExpandButton, TRP3_InspectionFrame;

local getRootClassID = TRP3_API.extended.getRootClassID

local EMPTY = Globals.empty

--[[
	maximum number of iterations within one auraCore:Update() batch
	this is to avoid calling Update() recursively and also to repaint the UI only once
]]--
local MAX_AURA_UPDATE_CYCLES = 10

--[[
	minimum time to pass until the next automated call to auraCore:Update()
	Update calls via event do not adhere to this minimum, however Update will ensure
	that there is at maximum one active C_Timer
]]--
local MIN_AURA_UPDATE_INTERVAL = 0.02

--[[
	Update frequency for dynamic auras. Since variables can change at any time, let's just update
	auras every DYN_AURA_UPDATE_INTERVAL seconds, if they happen to display variables
]]--
local DYN_AURA_UPDATE_INTERVAL = 1

--[[ DATA MAP

	            auraCore.activeAuras[i]                        TRP3_API.profile.getPlayerCurrentProfile().auras[j]
	
	                     |                                                              |
	                    \|/                                                            \|/
	
	+-----------------------------------------------+          +------------------------------------------------+
	| t persistent  pointer to stored part ---------|--------> | s id            full class id                  |
	| t class       cached class data (pointer)     |          | t vars          aura variables                 |
	| s duration    remaining duration string       |          | n expiry        expiry timestamp               |
	| s overlay     overlay string                  |          | n dormantSince  timestamp of last deactivation |
	| b initialize  flag to run the onInit script   |          | n lastTick      timestamp of the last onTick   |
	| b expired     flags the aura as expired       |          | b invalid       invalidated flag (aura should  |
	| b cancel      flag to run the onCancel script |          |                 be removed on next Update)     |
	| b cancelled   flags the aura as cancelled     |          +------------------------------------------------+
	| b hasDynamicDescription   whether or not the  |
	|               description text has tags       |
	| b hasDynamicOverlay       whether or not the  |
	|               overlay text has tags           |
	+-----------------------------------------------+

]]--

local CUSTOM_EVENTS = TRP3_API.extended.CUSTOM_EVENTS;

local auraCore;
auraCore = {
	
	activeAuras = {},
	-- a more precise version of time() that includes milliseconds
	Now = function(self) 
		return self.baseTime + GetTime()
	end,
	
	Initialize = function(self)
		self.baseTime = time() - GetTime()
		self.auraFramePool = CreateFramePool("Frame", TRP3_AuraFrame, "TRP3_AuraTemplate", function(pool, frame)
			frame:Hide()
			frame:ClearAllPoints()
			frame.overlay:SetText("")
			frame.duration:SetText("")
			frame.aura = nil
		end)
		
		self.inspectionAuraFramePool = CreateFramePool("Frame", TRP3_InspectionFrame.Main, "TRP3_AuraTemplate", function(pool, frame)
			frame:Hide()
			frame:ClearAllPoints()
			frame.overlay:SetText("")
			frame.duration:SetText("")
			frame.aura = nil
		end)
		
		self.timeFormatterCompact = CreateFromMixins(SecondsFormatterMixin)
		self.timeFormatterCompact:Init(0, SecondsFormatter.Abbreviation.OneLetter)
		self.timeFormatterCompact:SetDesiredUnitCount(1)
		
		self.timeFormatterNormal = CreateFromMixins(SecondsFormatterMixin)
		self.timeFormatterNormal:Init()
		
		Events.listenToEvent(Events.REGISTER_PROFILES_LOADED, function()
			auraCore:LoadProfile()
		end)
		
		Utils.event.registerHandler("PLAYER_LEAVING_WORLD", function()
			auraCore:UpdateDormancy(auraCore:Now())
		end)
		 
		self:LoadProfile()
	end,
	
	InvalidateCampaignAuras = function(self, campaignId)
		local hasChanges = false
		for i = 1,#self.currentProfile.auras do
			local class = TRP3_API.extended.getClass(self.currentProfile.auras[i].id)
			if class.missing then
				self.currentProfile.auras[i].invalid = true
				hasChanges = true
			elseif class.BA.BC and campaignId == getRootClassID(self.currentProfile.auras[i].id) then
				self.currentProfile.auras[i].invalid = true
				hasChanges = true
			end
		end
		if hasChanges then
			self:Update()
		end
	end,
	
	UpdateDormancy = function(self, timestamp)
		for i = 1,#self.activeAuras do
			self.activeAuras[i].persistent.dormantSince = timestamp
		end
	end,
	
	RegisterAuraEvents = function(self, aura)
		if not aura.class.HA then return end
		
		local events = {}
		for i = 1,#aura.class.HA do
			if aura.class.HA[i].EV then
				events[aura.class.HA[i].EV] = aura.class.HA[i].EV
			end
		end
		
		for eventId, _ in pairs(events) do
			local handlerId
			if CUSTOM_EVENTS[eventId] then
				handlerId = Events.registerCallback(eventId, function(...)
					if not aura.class.HA then return end
					
					local payload = {...}
					
					local args = { object = aura.persistent, event = payload }
					
					for i = 1,#aura.class.HA do
						if aura.class.HA[i].EV == eventId then
							if not aura.class.HA[i].CO or TRP3_API.script.generateAndRunCondition(aura.class.HA[i].CO, args) then
								TRP3_API.script.executeClassScript(aura.class.HA[i].SC, aura.class.SC, args, aura.persistent.id)
								break
							end
						end
					end
				end)
			else
				handlerId = Utils.event.registerHandler(eventId, function(...)
					if not aura.class.HA then return end
					
					local payload = {...}
					if (eventId == "COMBAT_LOG_EVENT" or eventId == "COMBAT_LOG_EVENT_UNFILTERED") then
						payload = {CombatLogGetCurrentEventInfo()}
					end
					
					local args = { object = aura.persistent, event = payload }
					
					for i = 1,#aura.class.HA do
						if aura.class.HA[i].EV == eventId then
							if not aura.class.HA[i].CO or TRP3_API.script.generateAndRunCondition(aura.class.HA[i].CO, args) then
								TRP3_API.script.executeClassScript(aura.class.HA[i].SC, aura.class.SC, args, aura.persistent.id)
								break
							end
						end
					end
				end);
			end
			events[eventId] = handlerId
		end
		aura.events = events
	end,
	
	UnregisterAuraEvents = function(self, aura)
		if not aura.events then return end
		
		for eventId, handlerId in pairs(aura.events) do
			if CUSTOM_EVENTS[eventId] then
				Events.unregisterCallback(handlerId)
			else
				Utils.event.unregisterHandler(handlerId)
			end
		end
		
		aura.events = nil
		
	end,
	
	timer = nil,
	
	LoadProfile = function(self)
		
		self.isUpdating = false
		if self.timer then
			self.timer:Cancel()
			self.timer = nil
		end
	
		local now = self:Now()
		
		for i = 1,#self.activeAuras do
			self:UnregisterAuraEvents(self.activeAuras[i])
			self.activeAuras[i].persistent.dormantSince = now
		end
		
		self.currentProfile = TRP3_API.profile.getPlayerCurrentProfile()
		if not self.currentProfile then -- not sure if this can happen at all
			self.currentProfile = {}
		end
		self.currentProfile.auras = self.currentProfile.auras or {}
		self.activeAuras = {}
		
		self.currentCampaignClassId = TRP3_API.quest.getQuestLog().currentCampaign -- might be nil
		
		for i = 1,#self.currentProfile.auras do
			local persistent = self.currentProfile.auras[i]
			persistent.expiry = persistent.expiry or math.huge -- Inf is stored as nil
			local class = TRP3_API.extended.getClass(persistent.id)
			if class.missing or persistent.invalid then
				persistent.invalid = true
			else
				if class.BA.AA and persistent.expiry < now and not class.BA.EE then
					persistent.invalid = true
				elseif not class.BA.BC or self.currentCampaignClassId == getRootClassID(persistent.id) then
					local dormancyDuration = 0
					if not class.BA.AA then
						dormancyDuration = now - persistent.dormantSince
					end
					persistent.expiry = persistent.expiry + dormancyDuration
					
					if class.BA.IV and class.BA.IV < math.huge then
						local elapsedTime = now - persistent.lastTick - dormancyDuration
						persistent.lastTick = now - (elapsedTime % math.abs(class.BA.IV))
					end
					persistent.dormantSince = now
					local aura = {
						class = class,
						persistent = persistent,
						color = self:GetAuraColorFromClass(class),
					}
					self:AnalyzeAuraClass(aura)
					tinsert(self.activeAuras, aura)
					self:RegisterAuraEvents(aura)
				end
			end
		end
		
		self:RemoveInvalidAuras()
		
		self:Update(true)
	end,
	
	-- desired side effect: sets properties in aura
	AnalyzeAuraClass = function(self, aura)
		aura.hasDynamicDescription = aura.class.BA.DE and aura.class.BA.DE:match("%$%{(.-)%}")
		aura.hasDynamicOverlay     = aura.class.BA.OV and aura.class.BA.OV:match("%$%{(.-)%}")
	end,
	
	ModifyAuraDuration = function(self, aura, duration, method)
		local currentExpiry = aura.persistent.expiry
		local newExpiry = currentExpiry
		local now = self:Now()
		if method == "+" then
			newExpiry = currentExpiry + duration
		elseif method == "-" then
			if duration < math.huge then
				newExpiry = currentExpiry - duration
			end
		else -- "="
			newExpiry = now + duration
		end
		if newExpiry ~= currentExpiry then
			aura.persistent.expiry = newExpiry
			if newExpiry > now then
				aura.expired = nil
			end
			self:Update()
		end
	end,
	
	SetAuraVariable = function(self, aura, opType, varName, value)
		local shouldUpdate = false
		if opType == "[=]" then
			if not aura.persistent.vars or aura.persistent.vars[varName] == nil then
				aura.persistent.vars = aura.persistent.vars or {}
				aura.persistent.vars[varName] = value
				shouldUpdate = aura.hasDynamicOverlay
			end
		elseif opType == "=" then
			aura.persistent.vars = aura.persistent.vars or {}
			aura.persistent.vars[varName] = value
			shouldUpdate = aura.hasDynamicOverlay
		else
			aura.persistent.vars = aura.persistent.vars or {}
			local op1 = tonumber(aura.persistent.vars[varName]) or 0
			local op2 = tonumber(value) or 0
			if opType == "+" then
				aura.persistent.vars[varName] = op1 + op2
			elseif opType == "-" then
				aura.persistent.vars[varName] = op1 - op2
			elseif opType == "x" then
				aura.persistent.vars[varName] = op1 * op2
			elseif opType == "/" then
				aura.persistent.vars[varName] = op1 / op2
			end
			shouldUpdate = aura.hasDynamicOverlay
		end
		
		if shouldUpdate then
			self:Update()
		end
	end,
	
	GetAuraColorFromClass = function(self, class)
		if class.BA.CO then
			local colorCached = {
				h = class.BA.CO
			}
			colorCached.r, colorCached.g, colorCached.b = hexaToFloat(class.BA.CO)
			return colorCached
		else
			return nil
		end
	end,
	
	InsertNewAura = function(self, auraId, class)
		local now = self:Now()
		local newAuraPersistent = {
			id = auraId,
			expiry = now + math.abs(class.BA.DU or math.huge),
			lastTick = now,
			dormantSince = now
		}
		tinsert(self.currentProfile.auras, newAuraPersistent)
		local newAura = {
			class = class,
			persistent = newAuraPersistent,
			color = self:GetAuraColorFromClass(class),
			initialize = true
		}
		self:AnalyzeAuraClass(newAura)
		tinsert(self.activeAuras, newAura)
		self:RegisterAuraEvents(newAura)
		self:Update()
	end,
	
	CancelAura = function(self, auraId)
		local aura = self:FindAura(auraId)
		if aura then
			aura.cancel = true
			self:Update()
			return true
		end
		return false
	end,
	
	RemoveAura = function(self, auraId)
		local aura = self:FindAura(auraId)
		if aura then
			aura.persistent.invalid = true
			self:UnregisterAuraEvents(aura)
			self:Update()
			return true
		end
		return false
	end,
	
	FindAura = function(self, auraId)
		for i=1,#self.activeAuras do
			if not self.activeAuras[i].persistent.invalid and self.activeAuras[i].persistent.id == auraId then
				return self.activeAuras[i]
			end
		end
		return nil
	end,
	
	GetAuraAt = function(self, index)
		local j = 1
		for i = 1,#self.activeAuras do
			if not self.activeAuras[i].persistent.invalid then
				if j == index then
					return self.activeAuras[i]
				end
				j = j + 1
			end

		end
		return nil
	end,
	
	CountActiveAuras = function(self)
		local count = 0
		for i = 1,#self.activeAuras do
			if not self.activeAuras[i].persistent.invalid then
				count = count + 1
			end
		end
		return count
	end,
	
	IsAuraActive = function(self, auraId)
		return self:FindAura(auraId) ~= nil
	end,
	
	isUpdating = false,
	
	Update = function(self, forceHardRefresh)
		if self.isUpdating then return end
		
		self.isUpdating = true
		if self.timer then
			self.timer:Cancel()
		end
		
		local now = self:Now()
		local needsHardRefresh = forceHardRefresh
		local aurasRemoved = false
		
		local updateCycle = 1
		
		while updateCycle <= MAX_AURA_UPDATE_CYCLES do
			
			local scriptList = {}
			
			-- part 1: determine workflows that need to run
			for i = 1,#self.activeAuras do
				local aura = self.activeAuras[i]
				if not aura.persistent.invalid then
					
					if aura.initialize then
						if aura.class.LI and aura.class.LI.OA then
							tinsert(scriptList, {
								aura.class.LI.OA,
								aura.class.SC or {},
								{ object = aura.persistent },
								aura.persistent.id
							})
						end
						needsHardRefresh = true
						aura.initialize = nil
					end

					if aura.class.BA.IV and aura.class.BA.IV < math.huge then
						local nextTick = aura.persistent.lastTick + math.abs(aura.class.BA.IV)
						if nextTick <= now then
							aura.persistent.lastTick = nextTick
							if aura.class.LI and aura.class.LI.OT then
								tinsert(scriptList, {
									aura.class.LI.OT,
									aura.class.SC or {},
									{ object = aura.persistent },
									aura.persistent.id
								})
							end
						end
					end
					
					if aura.cancel then
						aura.cancel = nil
						aura.cancelled = true
						if aura.class.LI and aura.class.LI.OC then
							tinsert(scriptList, {
								aura.class.LI.OC,
								aura.class.SC or {},
								{ object = aura.persistent },
								aura.persistent.id
							})
						end
					end
					
					if aura.persistent.expiry <= now then
						aura.expired = true
						if aura.class.LI and aura.class.LI.OE then
							tinsert(scriptList, {
								aura.class.LI.OE,
								aura.class.SC or {},
								{ object = aura.persistent },
								aura.persistent.id
							})
						end
					end
				end
			end
			
			-- part 2: run required workflows
			local numScripts = #scriptList
			for i = 1,numScripts do
				TRP3_API.script.executeClassScript(scriptList[i][1], scriptList[i][2], scriptList[i][3], scriptList[i][4])
			end
			
			-- part 3: invalidate auras
			for i = 1,#self.activeAuras do
				if not self.activeAuras[i].persistent.invalid then
					if self.activeAuras[i].cancelled or self.activeAuras[i].expired then
						self.activeAuras[i].persistent.invalid = true
						self:UnregisterAuraEvents(self.activeAuras[i])
						aurasRemoved = true
					end
				else
					aurasRemoved = true
				end
			end
			
			-- part 4: do it again in case there were workflows running
			if numScripts <= 0 then
				updateCycle = MAX_AURA_UPDATE_CYCLES + 1 -- get out of the loop
			end
			
		end
		
		if aurasRemoved then
			needsHardRefresh = true
			self:RemoveInvalidAuras()
		end
		
		local nextTimestamp = math.huge
		
		for i = 1,#self.activeAuras do
			local aura = self.activeAuras[i]
			aura.persistent.dormantSince = now
			if aura.class.BA.OV then
				aura.overlay = TRP3_API.script.parseArgs(aura.class.BA.OV, { object = aura.persistent })
			else
				aura.overlay = nil
			end
			
			if aura.persistent.expiry < math.huge then
				aura.duration = self.timeFormatterCompact:Format(aura.persistent.expiry - now)
			else
				aura.duration = nil
			end
			
			if aura.class.BA.IV and aura.class.BA.IV < math.huge then
				local nextTick = aura.persistent.lastTick + math.abs(aura.class.BA.IV)
				nextTimestamp = math.min(nextTimestamp, nextTick)
			end
			
			if aura.hasDynamicOverlay then
				nextTimestamp = math.min(nextTimestamp, now + DYN_AURA_UPDATE_INTERVAL)
			end
			
			if aura.persistent.expiry < math.huge then
				nextTimestamp = math.min(nextTimestamp, aura.persistent.expiry)
				local timeTillExpiry = aura.persistent.expiry - now
				if timeTillExpiry < 60 then
					nextTimestamp = math.min(nextTimestamp, aura.persistent.expiry - math.floor(timeTillExpiry))
				elseif timeTillExpiry < 3600 then
					nextTimestamp = math.min(nextTimestamp, aura.persistent.expiry - math.floor(timeTillExpiry/60) * 60)
				else
					nextTimestamp = math.min(nextTimestamp, aura.persistent.expiry - math.floor(timeTillExpiry/3600) * 3600)
				end
			end
			
		end
		
		if needsHardRefresh then
			self:HardRefresh()
		else
			self:SoftRefresh()
		end
		
		if nextTimestamp < math.huge then
			self.timer = C_Timer.NewTimer(math.max(nextTimestamp - now, MIN_AURA_UPDATE_INTERVAL), function() 
				auraCore:Update()
			end)
		end
		
		self.isUpdating = false
	end,
	
	RemoveInvalidAuras = function(self)
		-- 1st pass: remove from active auras list
		local n = #self.activeAuras
		local j = 1
		for i = 1,n do
			if self.activeAuras[i].persistent.invalid then
				self.activeAuras[i] = nil
			else
				if i ~= j then
					self.activeAuras[j] = self.activeAuras[i]
					self.activeAuras[i] = nil
				end
				j = j + 1
			end
		end
		-- 2nd pass: remove from all auras list
		local n = #self.currentProfile.auras
		local j = 1
		for i = 1,n do
			if self.currentProfile.auras[i].invalid then
				self.currentProfile.auras[i] = nil
			else
				if i ~= j then
					self.currentProfile.auras[j] = self.currentProfile.auras[i]
					self.currentProfile.auras[i] = nil
				end
				j = j + 1
			end
		end
	end,
	
	-- updates the aura display entirely, re-assigning frames etc.
	-- do this, when auras are added or removed
	HardRefresh = function(self)
		self.auraFramePool:ReleaseAll()
		
		local numBuffs, numDebuffs = 0, 0
		for i = 1,#self.activeAuras do
			if self.activeAuras[i].class.BA.HE then
				numBuffs = numBuffs + 1
			else
				numDebuffs = numDebuffs + 1
			end
		end
		
		local buffY = 20
		local debuffY = 20
		if numBuffs > 0 then
			debuffY = debuffY + 24 + (math.ceil(numBuffs/8) * 48)
		end
		
		local buffNum, debuffNum = 0, 0
		
		for i = 1,#self.activeAuras do
			local frame = self.auraFramePool:Acquire()
			if self.activeAuras[i].class.BA.HE then
				frame:SetPoint("TOPRIGHT", -(16 + (buffNum % 8)*36), -buffY)
				if buffNum % 8 == 7 then
					buffY = buffY + 48
				end
				buffNum = buffNum + 1	
			else
				frame:SetPoint("TOPRIGHT", -(16 + (debuffNum % 8)*36), -debuffY)
				if debuffNum % 8 == 7 then
					debuffY = debuffY + 48
				end
				debuffNum = debuffNum + 1
			end
			frame.icon:SetTexture("Interface\\ICONS\\" .. (self.activeAuras[i].class.BA.IC or "TEMP"))
			
			if self.activeAuras[i].color then
				frame.border:SetVertexColor(self.activeAuras[i].color.r, self.activeAuras[i].color.g, self.activeAuras[i].color.b)
				frame.border:Show()
			else
				frame.border:Hide()
			end
			
			frame:Show()
			frame.aura = self.activeAuras[i]
			self.activeAuras[i].frame = frame
		end
		
		if numBuffs > 0 or numDebuffs > 0 then
			local w = math.max(math.min(8, math.max(numBuffs, numDebuffs))*36 + 32, 200)
			local h = 36
			h = h + math.ceil(numBuffs/8) * 48
			if numBuffs > 0 and numDebuffs > 0 then
				h = h + 24
			end
			h = h + math.ceil(numDebuffs/8) * 48
			TRP3_AuraFrame:SetSize(w, h)
			TRP3_AuraFrame:SetShown(TRP3_AuraFrameCollapseAndExpandButton:GetChecked())
			TRP3_AuraFrameCollapseAndExpandButton:Show()
		else
			TRP3_AuraFrame:Hide()
			TRP3_AuraFrameCollapseAndExpandButton:Hide()
		end
		
		self:SoftRefresh()
	end,
	
	-- updates aura text and duration only
	SoftRefresh = function(self)
		for i = 1,#self.activeAuras do
			local frame = self.activeAuras[i].frame
			if frame then
				frame.overlay:SetText(self.activeAuras[i].overlay)
				frame.duration:SetText(self.activeAuras[i].duration)
			end
		end
		if TRP3_AuraTooltip:IsShown() then
			TRP3_API.extended.auras.showTooltip(TRP3_AuraTooltip:GetOwner())
		end
	end,
	
	GetAuraTooltipLines = function(self, aura)
		local title, category, description, flavor, expiry, cancelText
	
		if aura.class.BA.NA then
			title = aura.class.BA.NA
		end
		
		if aura.class.BA.CA and aura.class.BA.CA:len() > 0 then
			if aura.color then
				category = "|cff" ..aura.color.h .. aura.class.BA.CA .. "|r"
			else
				category = aura.class.BA.CA
			end
		end
		
		if aura.class.BA.DE then
			description = TRP3_API.script.parseArgs(aura.class.BA.DE, { object = aura.persistent })
		end
		
		if aura.class.BA.FL then
			flavor = aura.class.BA.FL
		end
		
		if aura.persistent.expiry < math.huge then
			expiry = L.AU_EXPIRY:format(self.timeFormatterNormal:Format(aura.persistent.expiry - self:Now()))
		end
		
		if aura.class.BA.CC then
			cancelText = L.AU_CANCEL_TEXT
		end
		
		return title, category, description, flavor, expiry, cancelText
	end,
	
	GetAurasForInspection = function(self)
		local auras = {}
		for i = 1,#self.activeAuras do
			local aura = self.activeAuras[i]
			if not aura.persistent.invalid and aura.class.BA.WE then
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
				})
			end
		end
		return auras
	end,
	
	UpdateInspectionFrame = function(self, auras)
		self.inspectionAuraFramePool:ReleaseAll()
		
		if not auras then return end
		
		local buffNum, debuffNum = 0, 0
		
		for i = 1,#auras do
			local frame = self.inspectionAuraFramePool:Acquire()
			if auras[i].class.BA.HE then
				frame:SetPoint("TOPLEFT", TRP3_InspectionFrame.Main.Model, "TOPLEFT", 10 + math.floor(buffNum/8)*36, -10 - (buffNum % 8) * 36)
				buffNum = buffNum + 1	
			else
				frame:SetPoint("TOPRIGHT", TRP3_InspectionFrame.Main.Model, "TOPRIGHT", -(10 + math.floor(debuffNum/8)*36), -10 - (debuffNum % 8) * 36)
				debuffNum = debuffNum + 1
			end
			frame.icon:SetTexture("Interface\\ICONS\\" .. (auras[i].class.BA.IC or "TEMP"))
			frame.overlay:SetText(auras[i].class.BA.OV)
			frame.duration:SetText("")
			auras[i].persistent.expiry = auras[i].persistent.expiry or math.huge
			auras[i].color = self:GetAuraColorFromClass(auras[i].class)
			if auras[i].color then
				frame.border:SetVertexColor(auras[i].color.r, auras[i].color.g, auras[i].color.b)
				frame.border:Show()
			else
				frame.border:Hide()
			end
			frame.aura = auras[i]
			auras[i].frame = frame
			frame:Show()
		end
		
	end,
}

TRP3_API.extended.auras.apply = function(auraId, extend)
	local class = TRP3_API.extended.getClass(auraId)
	if class.missing then return end
	if class.BA.BC and auraCore.currentCampaignClassId ~= getRootClassID(auraId) then return end
	local aura = auraCore:FindAura(auraId)
	if aura then
		if extend then
			auraCore:ModifyAuraDuration(aura, class.BA.DU or math.huge, "+")
		end
	else
		auraCore:InsertNewAura(auraId, class)
	end
end

TRP3_API.extended.auras.setVariable = function(auraId, opType, varName, value)
	local aura = auraCore:FindAura(auraId)
	if aura then
		auraCore:SetAuraVariable(aura, opType, varName, value)
	end
end

TRP3_API.extended.auras.isActive = function(auraId)
	return auraCore:IsAuraActive(auraId)
end

TRP3_API.extended.auras.getDuration = function(auraId)
	local aura = auraCore:FindAura(auraId)
	if aura then
		return aura.persistent.expiry - auraCore:Now()
	else
		return 0
	end
end

TRP3_API.extended.auras.isHelpful = function(auraId)
	local aura = auraCore:FindAura(auraId)
	if aura then
		return aura.class.HE
	else
		return false
	end
end

TRP3_API.extended.auras.isCancellable = function(auraId)
	local aura = auraCore:FindAura(auraId)
	if aura then
		return aura.class.CC
	else
		return false
	end
end

TRP3_API.extended.auras.auraVarCheck = function(auraId, varName)
	local aura = auraCore:FindAura(auraId)
	if aura and aura.persistent.vars and aura.persistent.vars[varName] then
		return tostring(aura.persistent.vars[varName]) or "nil"
	else
		return "nil"
	end
end

TRP3_API.extended.auras.auraVarCheckN = function(auraId, varName)
	local aura = auraCore:FindAura(auraId)
	if aura and aura.persistent.vars and aura.persistent.vars[varName] then
		return tonumber(aura.persistent.vars[varName]) or 0
	else
		return 0
	end
end

TRP3_API.extended.auras.getCount = function()
	return auraCore:CountActiveAuras()
end

TRP3_API.extended.auras.getId = function(index)
	local aura = auraCore:GetAuraAt(index)
	if aura then
		return aura.persistent.id
	else
		return "nil"
	end
end

TRP3_API.extended.auras.setDuration = function(auraId, duration, method)
	local aura = auraCore:FindAura(auraId)
	if aura then
		auraCore:ModifyAuraDuration(aura, duration, method)
	end
end

TRP3_API.extended.auras.cancel = function(auraId)
	local class = TRP3_API.extended.getClass(auraId)
	if class.missing or not class.BA.CC then return false end
	return auraCore:CancelAura(auraId)
end

TRP3_API.extended.auras.remove = function(auraId)
	return auraCore:RemoveAura(auraId)
end

TRP3_API.extended.auras.runWorkflow = function(auraId, workflowId, eArgs)
	local aura = auraCore:FindAura(auraId)
	if aura and aura.class.LI and aura.class.LI[workflowId] then
		local args = {
			object = aura.persistent
		}
		if eArgs then
			args.custom = eArgs.custom
			args.event = eArgs.event
		end
		TRP3_API.script.executeClassScript(aura.class.LI[workflowId], aura.class.SC or {}, args, aura.persistent.id)
	end	
end

TRP3_API.extended.auras.showTooltip = function(frame)
	
	if not frame.aura or frame.aura.persistent.invalid then return end

	TRP3_AuraTooltip:Hide()
	TRP3_AuraTooltip:SetOwner(frame, TRP3_AuraFrame.tooltipAnchor, 0, 0)

	local title, category, description, flavor, expiry, cancelText = auraCore:GetAuraTooltipLines(frame.aura)
	
	local i = 1;
	if title or category then
		local r, g, b = TRP3_API.Ellyb.ColorManager.YELLOW:GetRGB();
		TRP3_AuraTooltip:AddDoubleLine(title or "", category or "", r, g, b, r, g, b);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetFontObject(GameFontNormalLarge);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		_G["TRP3_AuraTooltipTextRight"..i]:SetFontObject(GameFontNormalLarge);
		_G["TRP3_AuraTooltipTextRight"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if description and description:len() > 0 then
		local r, g, b = TRP3_API.Ellyb.ColorManager.WHITE:GetRGB();
		TRP3_AuraTooltip:AddLine(description, r, g, b,true);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetFontObject(GameFontNormal);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetSpacing(2);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if flavor and flavor:len() > 0 then
		TRP3_AuraTooltip:AddLine(flavor, 0.0, 0.667, 0.6,true); -- 00AA99
		_G["TRP3_AuraTooltipTextLeft"..i]:SetFontObject(GameFontNormal);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetSpacing(2);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if expiry and expiry:len() > 0 then
		local r, g, b = TRP3_API.Ellyb.ColorManager.GREEN:GetRGB();
		TRP3_AuraTooltip:AddLine(expiry, r, g, b,true);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetFontObject(GameFontNormalSmall);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetSpacing(2);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetNonSpaceWrap(true);
		i = i + 1;
	end

	if cancelText and cancelText:len() > 0 then
		local r, g, b = TRP3_API.Ellyb.ColorManager.WHITE:GetRGB();
		TRP3_AuraTooltip:AddLine(cancelText, r, g, b,true);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetFontObject(GameFontNormalSmall);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetSpacing(2);
		_G["TRP3_AuraTooltipTextLeft"..i]:SetNonSpaceWrap(true);
	end
	
	TRP3_AuraTooltip:Show()
	
	if frame.aura.hasDynamicDescription or frame.aura.persistent.expiry < math.huge then
		C_Timer.After(0.2, function()
			if TRP3_AuraTooltip:IsOwned(frame) then
				TRP3_API.extended.auras.showTooltip(frame)
			end
		end)
	end
	
end

TRP3_API.extended.auras.getAurasForInspection = function()
	return auraCore:GetAurasForInspection()
end

TRP3_API.extended.auras.showInspectAuras = function(auras)
	return auraCore:UpdateInspectionFrame(auras)
end

TRP3_API.extended.auras.hideTooltip = function()
	TRP3_AuraTooltip:Hide()
end

TRP3_API.extended.auras.refresh = function()
	auraCore:LoadProfile()
end

TRP3_API.extended.auras.resetCampaignAuras = function(campaignId)
	auraCore:InvalidateCampaignAuras(campaignId)
end

TRP3_API.extended.auras.onStart = function()
	TRP3_AuraFrame.Text:SetText(L.AURA_FRAME_TITLE)
	TRP3_AuraFrame:UpdatePosition()
	TRP3_AuraFrameCollapseAndExpandButton:UpdatePosition()
	TRP3_API.script.registerEffects(TRP3_API.extended.auras.EFFECTS)
	auraCore:Initialize()
end
