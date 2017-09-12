local _, ns = ...
local oUF = oUF or ns.oUF or ElvUF
if not oUF then return end

local unpack = unpack
local find = string.find

local GetInventoryItemID = GetInventoryItemID
local GetSpellInfo = GetSpellInfo
local UnitCastingInfo = UnitCastingInfo
local UnitAttackSpeed = UnitAttackSpeed
local UnitRangedDamage = UnitRangedDamage
local GetTime = GetTime

local MainhandID = GetInventoryItemID("player", 16)
local OffhandID = GetInventoryItemID("player", 17)
local RangedID = GetInventoryItemID("player", 18)

local meleeing
local rangeing
local lasthit

local function SwingStopped(element)
	local bar = element.__owner

	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand

	if swing:IsShown() then return end
	if swingMH:IsShown() then return end
	if swingOH:IsShown() then return end

	bar:Hide()
end

local OnDurationUpdate
do
	local checkelapsed = 0
	local slamelapsed = 0
	local slamtime = 0
	local now
	local slam = GetSpellInfo(1464)

	function OnDurationUpdate(self, elapsed)
		now = GetTime()

		if meleeing then
			if checkelapsed > 0.02 then
				if lasthit + self.speed + slamtime < now then
					self:Hide()
					self:SetScript("OnUpdate", nil)
					SwingStopped(self)
					meleeing = false
					rangeing = false
				end
				
				checkelapsed = 0
			else
				checkelapsed = checkelapsed + elapsed
			end
		end

		local spell = UnitCastingInfo("player")

		if slam == spell then
			slamelapsed = slamelapsed + elapsed
			slamtime = slamtime + elapsed
		else
			if slamelapsed ~= 0 then
				self.min = self.min + slamelapsed
				self.max = self.max + slamelapsed
				self:SetMinMaxValues(self.min, self.max)
				slamelapsed = 0
			end

			if now > self.max then
				if meleeing then
					if lasthit then
						self.min = self.max
						self.max = self.max + self.speed
						self:SetMinMaxValues(self.min, self.max)
						slamtime = 0
					end
				else
					self:Hide()
					self:SetScript("OnUpdate", nil)
					meleeing = false
					rangeing = false
				end
			else
				self:SetValue(now)
				if self.Text then
					if self.__owner.OverrideText then
						self.__owner.OverrideText(self, now)
					else
						self.Text:SetFormattedText("%.1f", self.max - now)
					end
				end
			end
		end
	end
end

local function MeleeChange(self, event, unit)
	if unit ~= "player" then return end
	if not meleeing then return end

	local bar = self.Swing
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand
	local NewMainhandID = GetInventoryItemID("player", 16)
	local NewOffhandID = GetInventoryItemID("player", 17)
	local now = GetTime()
	local mhspeed, ohspeed = UnitAttackSpeed("player")

	if MainhandID ~= NewMainhandID or OffhandID ~= NewOffhandID then
		if ohspeed then
			swing:Hide()
			swing:SetScript("OnUpdate", nil)

			swingMH.min = GetTime()
			swingMH.max = swingMH.min + mhspeed
			swingMH.speed = mhspeed

			swingMH:Show()
			swingMH:SetMinMaxValues(swingMH.min, swingMH.max)
			swingMH:SetScript("OnUpdate", OnDurationUpdate)

			swingOH.min = GetTime()
			swingOH.max = swingOH.min + ohspeed
			swingOH.speed = ohspeed

			swingOH:Show()
			swingOH:SetMinMaxValues(swingOH.min, swingMH.max)
			swingOH:SetScript("OnUpdate", OnDurationUpdate)
		else
			swing.min = GetTime()
			swing.max = swing.min + mhspeed
			swing.speed = mhspeed

			swing:Show()
			swing:SetMinMaxValues(swing.min, swing.max)
			swing:SetScript("OnUpdate", OnDurationUpdate)

			swingMH:Hide()
			swingMH:SetScript("OnUpdate", nil)

			swingOH:Hide()
			swingOH:SetScript("OnUpdate", nil)
		end

		lasthit = now

		MainhandID = NewMainhandID
		OffhandID = NewOffhandID
	else
		if ohspeed then
			if swingMH.speed ~= mhspeed then
				local percentage = (swingMH.max - now) / (swingMH.speed)
				swingMH.min = now - mhspeed * (1 - percentage)
				swingMH.max = now + mhspeed * percentage
				swingMH:SetMinMaxValues(swingMH.min, swingMH.max)
				swingMH.speed = mhspeed
			end
			if swingOH.speed ~= ohspeed then
				local percentage = (swingOH.max - now) / (swingOH.speed)
				swingOH.min = now - ohspeed * (1 - percentage)
				swingOH.max = now + ohspeed * percentage
				swingOH:SetMinMaxValues(swingOH.min, swingOH.max)
				swingOH.speed = ohspeed
			end
		else
			if swing.speed ~= mhspeed then
				local percentage = (swing.max - now) / (swing.speed)
				swing.min = now - mhspeed * (1 - percentage)
				swing.max = now + mhspeed * percentage
				swing:SetMinMaxValues(swing.min, swing.max)
				swing.speed = mhspeed
			end
		end
	end
end

--[[
local function RangedChange(self, event, unit)
	if unit ~= "player" then return end
	if not rangeing then return end

	local bar = self.Swing
	local swing = bar.Twohand
	local NewRangedID = GetInventoryItemID("player", 18)
	local now = GetTime()
	local speed = UnitRangedDamage("player")

	if RangedID ~= NewRangedID then
		swing.speed = UnitRangedDamage(unit)
		swing.min = GetTime()
		swing.max = swing.min + swing.speed

		swing:Show()
		swing:SetMinMaxValues(swing.min, swing.max)
		swing:SetScript("OnUpdate", OnDurationupdate)
	else
		if swing.speed ~= speed then
			local percentage = (swing.max - GetTime()) / (swing.speed)
			swing.min = now - speed * (1 - percentage)
			swing.max = now + speed * percentage
			swing.speed = speed
		end
	end
end
]]

local function Ranged(self, event, unit, spellName)
	if unit ~= "player" then return end
	if spellName ~= GetSpellInfo(75) and spellName ~= GetSpellInfo(5019) then return end

	local bar = self.Swing
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand

	meleeing = false
	rangeing = true

	bar:Show()

	swing.speed = UnitRangedDamage(unit)
	swing.min = GetTime()
	swing.max = swing.min + swing.speed

	swing:Show()
	swing:SetMinMaxValues(swing.min, swing.max)
	swing:SetScript("OnUpdate", OnDurationUpdate)

	swingMH:Hide()
	swingMH:SetScript("OnUpdate", nil)

	swingOH:Hide()
	swingOH:SetScript("OnUpdate", nil)
end

local function Melee(self, event, _, subevent, _, GUID)
	if UnitGUID("player") ~= GUID then return end
	if not find(subevent, "SWING") then return end

	local bar = self.Swing
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand

	if not meleeing then
		bar:Show()

		swing:Hide()
		swingMH:Hide()
		swingOH:Hide()

		swing:SetScript("OnUpdate", nil)
		swingMH:SetScript("OnUpdate", nil)
		swingOH:SetScript("OnUpdate", nil)

		local mhspeed, ohspeed = UnitAttackSpeed("player")

		if ohspeed then
			swingMH.min = GetTime()
			swingMH.max = swingMH.min + mhspeed
			swingMH.speed = mhspeed

			swingMH:Show()
			swingMH:SetMinMaxValues(swingMH.min, swingMH.max)
			swingMH:SetScript("OnUpdate", OnDurationUpdate)

			swingOH.min = GetTime()
			swingOH.max = swingOH.min + ohspeed
			swingOH.speed = ohspeed

			swingOH:Show()
			swingOH:SetMinMaxValues(swingOH.min, swingOH.max)
			swingOH:SetScript("OnUpdate", OnDurationUpdate)
		else
			swing.min = GetTime()
			swing.max = swing.min + mhspeed
			swing.speed = mhspeed

			swing:Show()
			swing:SetMinMaxValues(swing.min, swing.max)
			swing:SetScript("OnUpdate", OnDurationUpdate)
		end

		meleeing = true
		rangeing = false
	end

	lasthit = GetTime()
end

local function ParryHaste(self, event, _, subevent, _, _, _, _, _, tarGUID, _, missType)
	if UnitGUID("player") ~= tarGUID then return end
	if not meleeing then return end
	if not find(subevent, "MISSED") then return end
	if missType ~= "PARRY" then return end
	
	local bar = self.Swing
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand
	local _, dualwield = UnitAttackSpeed("player")
	local now = GetTime()

	if dualwield then
		local percentage = (swingMH.max - now) / swingMH.speed

		if percentage > 0.6 then
			swingMH.max = now + swingMH.speed * 0.6
			swingMH.min = now - (swingMH.max - now) * percentage / (1 - percentage)
			swingMH:SetMinMaxValues(swingMH.min, swingMH.max)
		elseif percentage > 0.2 then
			swingMH.max = now + swingMH.speed * 0.2
			swingMH.min = now - (swingMH.max - now) * percentage / (1 - percentage)
			swingMH:SetMinMaxValues(swingMH.min, swingMH.max)
		end

		percentage = (swingOH.max - now) / swingOH.speed

		if percentage > 0.6 then
			swingOH.max = now + swingOH.speed * 0.6
			swingOH.min = now - (swingOH.max - now) * percentage / (1 - percentage)
			swingOH:SetMinMaxValues(swingOH.min, swingOH.max)
		elseif percentage > 0.2 then
			swingOH.max = now + swingOH.speed * 0.2
			swingOH.min = now - (swingOH.max - now) * percentage / (1 - percentage)
			swingOH:SetMinMaxValues(swingOH.min, swingOH.max)
		end
	else
		local percentage = (swing.max - now) / swing.speed

		if percentage > 0.6 then
			swing.max = now + swing.speed * 0.6
			swing.min = now - (swing.max - now) * percentage / (1 - percentage)
			swing:SetMinMaxValues(swing.min, swing.max)
		elseif percentage > 0.2 then
			swing.max = now + swing.speed * 0.2
			swing.min = now - (swing.max - now) * percentage / (1 - percentage)
			swing:SetMinMaxValues(swing.min, swing.max)
		end
	end
end

local function Ooc(self)
	local swing = self.Swing

	meleeing = false
	rangeing = false

	if not swing.hideOoc then return end

	swing:Hide()
	swing.Twohand:Hide()
	swing.Mainhand:Hide()
	swing.Offhand:Hide()
end

local function Enable(self, unit)
	local swing = self.Swing

	if swing and unit == "player" then
		local normTex = swing.texture or [=[Interface\TargetingFrame\UI-StatusBar]=]
		local bgTex = swing.textureBG or [=[Interface\TargetingFrame\UI-StatusBar]=]
		local r, g, b, a, r2, g2, b2, a2
		
		if swing.color then
			r, g, b, a = unpack(swing.color)
		else
			r, g, b, a = 1, 1, 1, 1
		end
		
		if swing.colorBG then
			r2, g2, b2, a2 = unpack(swing.colorBG) 
		else
			r2, g2, b2, a2 = 0, 0, 0, 1
		end

		if not swing.Twohand then
			swing.Twohand = CreateFrame("StatusBar", nil, swing)
			swing.Twohand:SetPoint("TOPLEFT", swing, "TOPLEFT", 0, 0)
			swing.Twohand:SetPoint("BOTTOMRIGHT", swing, "BOTTOMRIGHT", 0, 0)
			swing.Twohand:SetStatusBarTexture(normTex)
			swing.Twohand:SetStatusBarColor(r, g, b, a)
			swing.Twohand:SetFrameLevel(20)
			swing.Twohand:Hide()

			swing.Twohand.bg = swing.Twohand:CreateTexture(nil, "BACKGROUND")
			swing.Twohand.bg:SetAllPoints(swing.Twohand)
			swing.Twohand.bg:SetTexture(bgTex)
			swing.Twohand.bg:SetVertexColor(r2, g2, b2, a2)
		end
		swing.Twohand.__owner = swing

		if not swing.Mainhand then
			swing.Mainhand = CreateFrame("StatusBar", nil, swing)
			swing.Mainhand:SetPoint("TOPLEFT", swing, "TOPLEFT", 0, 0)
			swing.Mainhand:SetPoint("BOTTOMRIGHT", swing, "RIGHT", 0, 0)
			swing.Mainhand:SetStatusBarTexture(normTex)
			swing.Mainhand:SetStatusBarColor(r, g, b, a)
			swing.Mainhand:SetFrameLevel(20)
			swing.Mainhand:Hide()

			swing.Mainhand.bg = swing.Mainhand:CreateTexture(nil, "BACKGROUND")
			swing.Mainhand.bg:SetAllPoints(swing.Mainhand)
			swing.Mainhand.bg:SetTexture(bgTex)
			swing.Mainhand.bg:SetVertexColor(r2, g2, b2, a2)
		end
		swing.Mainhand.__owner = swing

		if not swing.Offhand then
			swing.Offhand = CreateFrame("StatusBar", nil, swing)
			swing.Offhand:SetPoint("TOPLEFT", swing, "LEFT", 0, 0)
			swing.Offhand:SetPoint("BOTTOMRIGHT", swing, "BOTTOMRIGHT", 0, 0)
			swing.Offhand:SetStatusBarTexture(normTex)
			swing.Offhand:SetStatusBarColor(r, g, b, a)
			swing.Offhand:SetFrameLevel(20)
			swing.Offhand:Hide()

			swing.Offhand.bg = swing.Offhand:CreateTexture(nil, "BACKGROUND")
			swing.Offhand.bg:SetAllPoints(swing.Offhand)
			swing.Offhand.bg:SetTexture(bgTex)
			swing.Offhand.bg:SetVertexColor(r2, g2, b2, a2)
		end
		swing.Offhand.__owner = swing

		if swing.Text then
			swing.Twohand.Text = swing.Text
			swing.Twohand.Text:SetParent(swing.Twohand)
		end

		if swing.TextMH then
			swing.Mainhand.Text = swing.TextMH
			swing.Mainhand.Text:SetParent(swing.Mainhand)
		end

		if swing.TextOH then
			swing.Offhand.Text = swing.TextOH
			swing.Offhand.Text:SetParent(swing.Offhand)
		end

		if swing.OverrideText then
			swing.Twohand.OverrideText = swing.OverrideText
			swing.Mainhand.OverrideText = swing.OverrideText
			swing.Offhand.OverrideText = swing.OverrideText
		end

		if not swing.disableRanged then
			self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Ranged)
--			self:RegisterEvent("UNIT_RANGEDDAMAGE", RangedChange)
		end

		if not swing.disableMelee then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Melee)
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", ParryHaste)
			self:RegisterEvent("UNIT_ATTACK_SPEED", MeleeChange)
		end

		self:RegisterEvent("PLAYER_REGEN_ENABLED", Ooc)

		return true
	end
end

local function Disable(self)
	local swing = self.Swing
	if swing then
		if not swing.disableRanged then
			self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Ranged)
--			self:UnregisterEvent("UNIT_RANGEDDAMAGE", RangedChange)
		end

		if not swing.disableMelee then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Melee)
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", ParryHaste)
			self:UnregisterEvent("UNIT_ATTACK_SPEED", MeleeChange)
		end

		self:UnregisterEvent("PLAYER_REGEN_ENABLED", Ooc)

		swing:Hide()
	end
end

oUF:AddElement("Swing", nil, Enable, Disable)