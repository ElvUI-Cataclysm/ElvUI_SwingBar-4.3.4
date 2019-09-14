local _, ns = ...
local oUF = oUF or ns.oUF or ElvUF
if not oUF then return end

local unpack = unpack
local find = string.find

local GetInventoryItemID = GetInventoryItemID
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local UnitAttackSpeed = UnitAttackSpeed
local UnitCastingInfo = UnitCastingInfo
local UnitRangedDamage = UnitRangedDamage

local MainhandID = GetInventoryItemID("player", 16)
local OffhandID = GetInventoryItemID("player", 17)
local RangedID = GetInventoryItemID("player", 18)

local meleeing, rangeing, lasthit

local function SwingStopped(element)
	local bar = element.__owner

	if bar.Twohand:IsShown() then return end
	if bar.Mainhand:IsShown() then return end
	if bar.Offhand:IsShown() then return end

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

local function MeleeChange(self, _, unit)
	if unit ~= "player" then return end
	if not meleeing then return end

	local element = self.Swing

	local NewMainhandID = GetInventoryItemID("player", 16)
	local NewOffhandID = GetInventoryItemID("player", 17)

	local now = GetTime()
	local mhspeed, ohspeed = UnitAttackSpeed("player")

	if MainhandID ~= NewMainhandID or OffhandID ~= NewOffhandID then
		if ohspeed then
			element.Twohand:Hide()
			element.Twohand:SetScript("OnUpdate", nil)

			element.Mainhand.min = GetTime()
			element.Mainhand.max = element.Mainhand.min + mhspeed
			element.Mainhand.speed = mhspeed

			element.Mainhand:Show()
			element.Mainhand:SetMinMaxValues(element.Mainhand.min, element.Mainhand.max)
			element.Mainhand:SetScript("OnUpdate", OnDurationUpdate)

			element.Offhand.min = GetTime()
			element.Offhand.max = element.Offhand.min + ohspeed
			element.Offhand.speed = ohspeed

			element.Offhand:Show()
			element.Offhand:SetMinMaxValues(element.Offhand.min, element.Mainhand.max)
			element.Offhand:SetScript("OnUpdate", OnDurationUpdate)
		else
			element.Twohand.min = GetTime()
			element.Twohand.max = element.Twohand.min + mhspeed
			element.Twohand.speed = mhspeed

			element.Twohand:Show()
			element.Twohand:SetMinMaxValues(element.Twohand.min, element.Twohand.max)
			element.Twohand:SetScript("OnUpdate", OnDurationUpdate)

			element.Mainhand:Hide()
			element.Mainhand:SetScript("OnUpdate", nil)

			element.Offhand:Hide()
			element.Offhand:SetScript("OnUpdate", nil)
		end

		lasthit = now

		MainhandID = NewMainhandID
		OffhandID = NewOffhandID
	else
		if ohspeed then
			if element.Mainhand.speed ~= mhspeed then
				local percentage = (element.Mainhand.max - now) / (element.Mainhand.speed)
				element.Mainhand.min = now - mhspeed * (1 - percentage)
				element.Mainhand.max = now + mhspeed * percentage
				element.Mainhand:SetMinMaxValues(element.Mainhand.min, element.Mainhand.max)
				element.Mainhand.speed = mhspeed
			end
			if element.Offhand.speed ~= ohspeed then
				local percentage = (element.Offhand.max - now) / (element.Offhand.speed)
				element.Offhand.min = now - ohspeed * (1 - percentage)
				element.Offhand.max = now + ohspeed * percentage
				element.Offhand:SetMinMaxValues(element.Offhand.min, element.Offhand.max)
				element.Offhand.speed = ohspeed
			end
		else
			if element.Twohand.speed ~= mhspeed then
				local percentage = (element.Twohand.max - now) / (element.Twohand.speed)
				element.Twohand.min = now - mhspeed * (1 - percentage)
				element.Twohand.max = now + mhspeed * percentage
				element.Twohand:SetMinMaxValues(element.Twohand.min, element.Twohand.max)
				element.Twohand.speed = mhspeed
			end
		end
	end
end

local function RangedChange(self, _, unit)
	if unit ~= "player" then return end
	if not rangeing then return end

	local element = self.Swing
	local NewRangedID = GetInventoryItemID("player", 18)
	local now = GetTime()
	local speed = UnitRangedDamage("player")

	if RangedID ~= NewRangedID then
		element.Twohand.speed = UnitRangedDamage(unit)
		element.Twohand.min = GetTime()
		element.Twohand.max = element.Twohand.min + element.Twohand.speed

		element.Twohand:Show()
		element.Twohand:SetMinMaxValues(element.Twohand.min, element.Twohand.max)
		element.Twohand:SetScript("OnUpdate", OnDurationupdate)
	else
		if element.Twohand.speed ~= speed then
			local percentage = (element.Twohand.max - GetTime()) / (element.Twohand.speed)
			element.Twohand.min = now - speed * (1 - percentage)
			element.Twohand.max = now + speed * percentage
			element.Twohand.speed = speed
		end
	end
end

local function Ranged(self, _, unit, spellName)
	if unit ~= "player" then return end
	if spellName ~= GetSpellInfo(75) and spellName ~= GetSpellInfo(5019) then return end

	local element = self.Swing

	meleeing = false
	rangeing = true

	element:Show()

	element.Twohand.speed = UnitRangedDamage(unit)
	element.Twohand.min = GetTime()
	element.Twohand.max = element.Twohand.min + element.Twohand.speed

	element.Twohand:Show()
	element.Twohand:SetMinMaxValues(element.Twohand.min, element.Twohand.max)
	element.Twohand:SetScript("OnUpdate", OnDurationUpdate)

	element.Mainhand:Hide()
	element.Mainhand:SetScript("OnUpdate", nil)

	element.Offhand:Hide()
	element.Offhand:SetScript("OnUpdate", nil)
end

local function Melee(self, event, _, subevent, _, GUID)
	if UnitGUID("player") ~= GUID then return end
	if not find(subevent, "SWING") then return end

	local element = self.Swing

	if not meleeing then
		element:Show()

		element.Twohand:Hide()
		element.Mainhand:Hide()
		element.Offhand:Hide()

		element.Twohand:SetScript("OnUpdate", nil)
		element.Mainhand:SetScript("OnUpdate", nil)
		element.Offhand:SetScript("OnUpdate", nil)

		local mhspeed, ohspeed = UnitAttackSpeed("player")

		if ohspeed then
			element.Mainhand.min = GetTime()
			element.Mainhand.max = element.Mainhand.min + mhspeed
			element.Mainhand.speed = mhspeed

			element.Mainhand:Show()
			element.Mainhand:SetMinMaxValues(element.Mainhand.min, element.Mainhand.max)
			element.Mainhand:SetScript("OnUpdate", OnDurationUpdate)

			element.Offhand.min = GetTime()
			element.Offhand.max = element.Offhand.min + ohspeed
			element.Offhand.speed = ohspeed

			element.Offhand:Show()
			element.Offhand:SetMinMaxValues(element.Offhand.min, element.Offhand.max)
			element.Offhand:SetScript("OnUpdate", OnDurationUpdate)
		else
			element.Twohand.min = GetTime()
			element.Twohand.max = element.Twohand.min + mhspeed
			element.Twohand.speed = mhspeed

			element.Twohand:Show()
			element.Twohand:SetMinMaxValues(element.Twohand.min, element.Twohand.max)
			element.Twohand:SetScript("OnUpdate", OnDurationUpdate)
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

	local element = self.Swing
	local _, dualwield = UnitAttackSpeed("player")
	local now = GetTime()

	if dualwield then
		local percentage = (element.Mainhand.max - now) / element.Mainhand.speed

		if percentage > 0.6 then
			element.Mainhand.max = now + element.Mainhand.speed * 0.6
			element.Mainhand.min = now - (element.Mainhand.max - now) * percentage / (1 - percentage)
			element.Mainhand:SetMinMaxValues(element.Mainhand.min, element.Mainhand.max)
		elseif percentage > 0.2 then
			element.Mainhand.max = now + element.Mainhand.speed * 0.2
			element.Mainhand.min = now - (element.Mainhand.max - now) * percentage / (1 - percentage)
			element.Mainhand:SetMinMaxValues(element.Mainhand.min, element.Mainhand.max)
		end

		percentage = (element.Offhand.max - now) / element.Offhand.speed

		if percentage > 0.6 then
			element.Offhand.max = now + element.Offhand.speed * 0.6
			element.Offhand.min = now - (element.Offhand.max - now) * percentage / (1 - percentage)
			element.Offhand:SetMinMaxValues(element.Offhand.min, element.Offhand.max)
		elseif percentage > 0.2 then
			element.Offhand.max = now + element.Offhand.speed * 0.2
			element.Offhand.min = now - (element.Offhand.max - now) * percentage / (1 - percentage)
			element.Offhand:SetMinMaxValues(element.Offhand.min, element.Offhand.max)
		end
	else
		local percentage = (element.Twohand.max - now) / element.Twohand.speed

		if percentage > 0.6 then
			element.Twohand.max = now + element.Twohand.speed * 0.6
			element.Twohand.min = now - (element.Twohand.max - now) * percentage / (1 - percentage)
			element.Twohand:SetMinMaxValues(element.Twohand.min, element.Twohand.max)
		elseif percentage > 0.2 then
			element.Twohand.max = now + element.Twohand.speed * 0.2
			element.Twohand.min = now - (element.Twohand.max - now) * percentage / (1 - percentage)
			element.Twohand:SetMinMaxValues(element.Twohand.min, element.Twohand.max)
		end
	end
end

local function Ooc(self)
	local element = self.Swing

	meleeing = false
	rangeing = false

	if not element.hideOoc then return end

	element:Hide()
	element.Twohand:Hide()
	element.Mainhand:Hide()
	element.Offhand:Hide()
end

local function Enable(self, unit)
	local element = self.Swing

	if element and unit == "player" then
		if not element.Twohand then
			element.Twohand = CreateFrame("StatusBar", nil, element)
			element.Twohand:SetPoint("TOPLEFT", element, "TOPLEFT", 0, 0)
			element.Twohand:SetPoint("BOTTOMRIGHT", element, "BOTTOMRIGHT", 0, 0)
			element.Twohand:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			element.Twohand:SetStatusBarColor(1, 1, 1, 1)
			element.Twohand:SetFrameLevel(20)
			element.Twohand:Hide()

			element.Twohand.bg = element.Twohand:CreateTexture(nil, "BACKGROUND")
			element.Twohand.bg:SetAllPoints(element.Twohand)
			element.Twohand.bg:SetTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			element.Twohand.bg:SetVertexColor(0, 0, 0, 1)
		end
		element.Twohand.__owner = element

		if element.Text then
			element.Twohand.Text = element.Text
			element.Twohand.Text:SetParent(element.Twohand)
		end

		if element.Twohand.Spark and element.Twohand.Spark:IsObjectType("Texture") and not element.Twohand.Spark:GetTexture() then
			element.Twohand.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
		end

		if not element.Mainhand then
			element.Mainhand = CreateFrame("StatusBar", nil, element)
			element.Mainhand:SetPoint("TOPLEFT", element, "TOPLEFT", 0, 0)
			element.Mainhand:SetPoint("BOTTOMRIGHT", element, "RIGHT", 0, 0)
			element.Mainhand:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			element.Mainhand:SetStatusBarColor(1, 1, 1, 1)
			element.Mainhand:SetFrameLevel(20)
			element.Mainhand:Hide()

			element.Mainhand.bg = element.Mainhand:CreateTexture(nil, "BACKGROUND")
			element.Mainhand.bg:SetAllPoints(element.Mainhand)
			element.Mainhand.bg:SetTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			element.Mainhand.bg:SetVertexColor(0, 0, 0, 1)
		end
		element.Mainhand.__owner = element

		if element.TextMH then
			element.Mainhand.Text = element.TextMH
			element.Mainhand.Text:SetParent(element.Mainhand)
		end

		if element.Mainhand.Spark and element.Mainhand.Spark:IsObjectType("Texture") and not element.Mainhand.Spark:GetTexture() then
			element.Mainhand.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
		end

		if not element.Offhand then
			element.Offhand = CreateFrame("StatusBar", nil, element)
			element.Offhand:SetPoint("TOPLEFT", element, "LEFT", 0, 0)
			element.Offhand:SetPoint("BOTTOMRIGHT", element, "BOTTOMRIGHT", 0, 0)
			element.Offhand:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			element.Offhand:SetStatusBarColor(1, 1, 1, 1)
			element.Offhand:SetFrameLevel(20)
			element.Offhand:Hide()

			element.Offhand.bg = element.Offhand:CreateTexture(nil, "BACKGROUND")
			element.Offhand.bg:SetAllPoints(element.Offhand)
			element.Offhand.bg:SetTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			element.Offhand.bg:SetVertexColor(0, 0, 0, 1)
		end
		element.Offhand.__owner = element

		if element.TextOH then
			element.Offhand.Text = element.TextOH
			element.Offhand.Text:SetParent(element.Offhand)
		end

		if element.OverrideText then
			element.Twohand.OverrideText = element.OverrideText
			element.Mainhand.OverrideText = element.OverrideText
			element.Offhand.OverrideText = element.OverrideText
		end

		if element.Offhand.Spark and element.Offhand.Spark:IsObjectType("Texture") and not element.Offhand.Spark:GetTexture() then
			element.Offhand.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
		end

		if not element.disableRanged then
			self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Ranged)
--			self:RegisterEvent("UNIT_RANGEDDAMAGE", RangedChange)
		end

		if not element.disableMelee then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Melee)
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", ParryHaste)
			self:RegisterEvent("UNIT_ATTACK_SPEED", MeleeChange)
		end

		self:RegisterEvent("PLAYER_REGEN_ENABLED", Ooc)

		return true
	end
end

local function Disable(self)
	local element = self.Swing
	if element then
		if not element.disableRanged then
			self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Ranged)
--			self:UnregisterEvent("UNIT_RANGEDDAMAGE", RangedChange)
		end

		if not element.disableMelee then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Melee)
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", ParryHaste)
			self:UnregisterEvent("UNIT_ATTACK_SPEED", MeleeChange)
		end

		self:UnregisterEvent("PLAYER_REGEN_ENABLED", Ooc)

		element:Hide()
	end
end

oUF:AddElement("Swing", nil, Enable, Disable)